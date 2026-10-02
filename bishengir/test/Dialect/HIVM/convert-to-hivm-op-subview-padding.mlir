// RUN: bishengir-opt %s -convert-to-hivm-op -split-input-file -verify-each -allow-unregistered-dialect | FileCheck %s

// A later read window is not padding for an earlier full-buffer transfer.
// In particular, its loop-local offset cannot be used by the load before the
// loop. Keep the consumer live so greedy rewriting cannot erase the subview.
// CHECK-LABEL: func.func @full_copy_before_loop_subview(
// CHECK: %[[FULL:.*]] = memref.alloc() : memref<64x256xi8, #hivm.address_space<cbuf>>
// CHECK: hivm.hir.load ins(%{{.*}} : memref<64x256xi8>) outs(%[[FULL]] : memref<64x256xi8, #hivm.address_space<cbuf>>) init_out_buffer = false
// CHECK: scf.for
// CHECK: %[[OFFSET:.*]] = arith.muli
// CHECK: memref.subview %[[FULL]][0, %[[OFFSET]]]
func.func @full_copy_before_loop_subview(%src: memref<64x256xi8>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  %c128 = arith.constant 128 : index
  %full = memref.alloc() : memref<64x256xi8, #hivm.address_space<cbuf>>
  memref.copy %src, %full : memref<64x256xi8> to memref<64x256xi8, #hivm.address_space<cbuf>>
  scf.for %kb = %c0 to %c2 step %c1 {
    %offset = arith.muli %kb, %c128 : index
    %tile = memref.subview %full[0, %offset] [64, 128] [1, 1] : memref<64x256xi8, #hivm.address_space<cbuf>> to memref<64x128xi8, strided<[256, 1], offset: ?>, #hivm.address_space<cbuf>>
    "test.consume"(%tile) : (memref<64x128xi8, strided<[256, 1], offset: ?>, #hivm.address_space<cbuf>>) -> ()
  }
  return
}

// -----

// Dominance alone is insufficient: a function argument dominates the copy,
// but the later consumer's offset still is not a padding requirement.
// CHECK-LABEL: func.func @full_copy_before_dominating_offset_subview(
// CHECK: %[[FULL:.*]] = memref.alloc() : memref<64x256xi8, #hivm.address_space<cbuf>>
// CHECK: hivm.hir.load ins(%{{.*}} : memref<64x256xi8>) outs(%[[FULL]] : memref<64x256xi8, #hivm.address_space<cbuf>>) init_out_buffer = false
// CHECK: memref.subview %[[FULL]]
func.func @full_copy_before_dominating_offset_subview(%src: memref<64x256xi8>, %offset: index) {
  %full = memref.alloc() : memref<64x256xi8, #hivm.address_space<cbuf>>
  memref.copy %src, %full : memref<64x256xi8> to memref<64x256xi8, #hivm.address_space<cbuf>>
  %tile = memref.subview %full[0, %offset] [64, 128] [1, 1] : memref<64x256xi8, #hivm.address_space<cbuf>> to memref<64x128xi8, strided<[256, 1], offset: ?>, #hivm.address_space<cbuf>>
  "test.consume"(%tile) : (memref<64x128xi8, strided<[256, 1], offset: ?>, #hivm.address_space<cbuf>>) -> ()
  return
}

// -----

// Looking through a cast of the actual target must not turn around and inspect
// another user of the underlying allocation.
// CHECK-LABEL: func.func @full_copy_through_cast_with_consumer_subview(
// CHECK: hivm.hir.load ins({{.*}}) outs({{.*}}) init_out_buffer = false
// CHECK: memref.subview
func.func @full_copy_through_cast_with_consumer_subview(%src: memref<?xi8>, %offset: index) {
  %full = memref.alloc() : memref<64xi8>
  %target = memref.cast %full : memref<64xi8> to memref<?xi8>
  memref.copy %src, %target : memref<?xi8> to memref<?xi8>
  %tile = memref.subview %full[%offset] [16] [1] : memref<64xi8> to memref<16xi8, strided<[1], offset: ?>>
  "test.consume"(%tile) : (memref<16xi8, strided<[1], offset: ?>>) -> ()
  return
}

// -----

// Only the actual target's offset is padding. Reverse sibling creation order
// in the following two functions to make selection independent of use order.
// CHECK-LABEL: func.func @target_subview_before_sibling(
// CHECK-SAME: %[[SRC:[^:]+]]: memref<16xi8>, %[[PAD:[^:]+]]: index, %[[OTHER:[^:]+]]: index)
// CHECK: %[[TARGET:.*]] = memref.subview %{{.*}}[%[[PAD]]] [16] [1]
// CHECK: hivm.hir.load ins(%[[SRC]] : memref<16xi8>) outs(%[[TARGET]] : memref<16xi8, strided<[1], offset: ?>>) left_padding_num = %[[PAD]] : index init_out_buffer = false
func.func @target_subview_before_sibling(%src: memref<16xi8>, %pad: index, %other: index) {
  %full = memref.alloc() : memref<64xi8>
  %target = memref.subview %full[%pad] [16] [1] : memref<64xi8> to memref<16xi8, strided<[1], offset: ?>>
  %sibling = memref.subview %full[%other] [16] [1] : memref<64xi8> to memref<16xi8, strided<[1], offset: ?>>
  memref.copy %src, %target : memref<16xi8> to memref<16xi8, strided<[1], offset: ?>>
  "test.consume"(%sibling, %full) : (memref<16xi8, strided<[1], offset: ?>>, memref<64xi8>) -> ()
  return
}

// -----

// CHECK-LABEL: func.func @sibling_subview_before_target(
// CHECK-SAME: %[[SRC:[^:]+]]: memref<16xi8>, %[[PAD:[^:]+]]: index, %[[OTHER:[^:]+]]: index)
// CHECK: %[[TARGET:.*]] = memref.subview %{{.*}}[%[[PAD]]] [16] [1]
// CHECK: hivm.hir.load ins(%[[SRC]] : memref<16xi8>) outs(%[[TARGET]] : memref<16xi8, strided<[1], offset: ?>>) left_padding_num = %[[PAD]] : index init_out_buffer = false
func.func @sibling_subview_before_target(%src: memref<16xi8>, %pad: index, %other: index) {
  %full = memref.alloc() : memref<64xi8>
  %sibling = memref.subview %full[%other] [16] [1] : memref<64xi8> to memref<16xi8, strided<[1], offset: ?>>
  %target = memref.subview %full[%pad] [16] [1] : memref<64xi8> to memref<16xi8, strided<[1], offset: ?>>
  memref.copy %src, %target : memref<16xi8> to memref<16xi8, strided<[1], offset: ?>>
  "test.consume"(%sibling, %full) : (memref<16xi8, strided<[1], offset: ?>>, memref<64xi8>) -> ()
  return
}

// -----

// Preserve a genuine dynamic destination-subview offset through a memref.cast.
// CHECK-LABEL: func.func @target_subview_through_cast(
// CHECK-SAME: %{{[^:]+}}: memref<?xi8>, %[[PAD:[^:]+]]: index)
// CHECK: hivm.hir.load ins({{.*}}) outs({{.*}}) left_padding_num = %[[PAD]] : index init_out_buffer = false
func.func @target_subview_through_cast(%src: memref<?xi8>, %pad: index) {
  %full = memref.alloc() : memref<64xi8>
  %tile = memref.subview %full[%pad] [16] [1] : memref<64xi8> to memref<16xi8, strided<[1], offset: ?>>
  %target = memref.cast %tile : memref<16xi8, strided<[1], offset: ?>> to memref<?xi8, strided<[1], offset: ?>>
  memref.copy %src, %target : memref<?xi8> to memref<?xi8, strided<[1], offset: ?>>
  "test.consume"(%full) : (memref<64xi8>) -> ()
  return
}

// -----

// A memory-space cast is likewise transparent to the actual target's offset.
// CHECK-LABEL: func.func @target_subview_through_memory_space_cast(
// CHECK-SAME: %{{[^:]+}}: memref<16xi8>, %[[PAD:[^:]+]]: index)
// CHECK: hivm.hir.load ins({{.*}}) outs({{.*}}) left_padding_num = %[[PAD]] : index init_out_buffer = false
func.func @target_subview_through_memory_space_cast(%src: memref<16xi8>, %pad: index) {
  %full = memref.alloc() : memref<64xi8>
  %tile = memref.subview %full[%pad] [16] [1] : memref<64xi8> to memref<16xi8, strided<[1], offset: ?>>
  %target = memref.memory_space_cast %tile : memref<16xi8, strided<[1], offset: ?>> to memref<16xi8, strided<[1], offset: ?>, #hivm.address_space<cbuf>>
  memref.copy %src, %target : memref<16xi8> to memref<16xi8, strided<[1], offset: ?>, #hivm.address_space<cbuf>>
  "test.consume"(%full) : (memref<64xi8>) -> ()
  return
}

// -----

// Preserve static left padding, including creation of the index constant used
// by the load, rather than suppressing padding on every memref.copy.
// CHECK-LABEL: func.func @target_subview_static_padding(
// CHECK: %[[PAD:.*]] = arith.constant 8 : index
// CHECK: hivm.hir.load ins({{.*}}) outs({{.*}}) left_padding_num = %[[PAD]] : index init_out_buffer = false
func.func @target_subview_static_padding(%src: memref<16xi8>) {
  %full = memref.alloc() : memref<64xi8>
  %target = memref.subview %full[8] [16] [1] : memref<64xi8> to memref<16xi8, strided<[1], offset: 8>>
  memref.copy %src, %target : memref<16xi8> to memref<16xi8, strided<[1], offset: 8>>
  "test.consume"(%full) : (memref<64xi8>) -> ()
  return
}

// -----

// A loop-local offset is legitimate when the copy itself targets that subview
// inside the same loop: fixing the hoisted-load bug must not drop this padding.
// CHECK-LABEL: func.func @target_subview_inside_loop(
// CHECK: scf.for
// CHECK: %[[PAD:.*]] = arith.muli
// CHECK: hivm.hir.load ins({{.*}}) outs({{.*}}) left_padding_num = %[[PAD]] : index init_out_buffer = false
func.func @target_subview_inside_loop(%src: memref<16xi8>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  %c16 = arith.constant 16 : index
  %full = memref.alloc() : memref<64xi8>
  scf.for %i = %c0 to %c2 step %c1 {
    %pad = arith.muli %i, %c16 : index
    %target = memref.subview %full[%pad] [16] [1] : memref<64xi8> to memref<16xi8, strided<[1], offset: ?>>
    memref.copy %src, %target : memref<16xi8> to memref<16xi8, strided<[1], offset: ?>>
    "test.consume"(%full) : (memref<64xi8>) -> ()
  }
  return
}

// -----

// Do not expand padding inference to a subview of a reinterpreted allocation.
// Here the dropped dimension's offset is 2, but the remaining dimension has
// stride 8. Treating 2 as left padding in that dimension would move the base
// before the allocation (2 - 2 * 8 = -14). The old allocation-user inference
// did not infer padding through this reinterpret_cast; preserve that boundary.
// CHECK-LABEL: func.func @reinterpret_rank_reducing_subview_no_padding(
// CHECK: %[[MATRIX:.*]] = memref.reinterpret_cast
// CHECK: %[[TARGET:.*]] = memref.subview %[[MATRIX]][0, 2] [8, 1] [1, 1]
// CHECK: hivm.hir.load ins(%{{.*}} : memref<8xi8>) outs(%[[TARGET]] : memref<8xi8, strided<[8], offset: 2>, #hivm.address_space<ub>>) init_out_buffer = false
func.func @reinterpret_rank_reducing_subview_no_padding(%src: memref<8xi8>) {
  %full = memref.alloc() : memref<64xi8, #hivm.address_space<ub>>
  %matrix = memref.reinterpret_cast %full to offset: [0], sizes: [8, 8], strides: [8, 1] : memref<64xi8, #hivm.address_space<ub>> to memref<8x8xi8, #hivm.address_space<ub>>
  %target = memref.subview %matrix[0, 2] [8, 1] [1, 1] : memref<8x8xi8, #hivm.address_space<ub>> to memref<8xi8, strided<[8], offset: 2>, #hivm.address_space<ub>>
  memref.copy %src, %target : memref<8xi8> to memref<8xi8, strided<[8], offset: 2>, #hivm.address_space<ub>>
  "test.consume"(%full, %matrix, %target) : (memref<64xi8, #hivm.address_space<ub>>, memref<8x8xi8, #hivm.address_space<ub>>, memref<8xi8, strided<[8], offset: 2>, #hivm.address_space<ub>>) -> ()
  return
}
