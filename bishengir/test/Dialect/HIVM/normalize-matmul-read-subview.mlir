// RUN: bishengir-opt %s -hivm-normalize-matmul -split-input-file -verify-each -allow-unregistered-dialect | FileCheck %s

// Full-Y preload followed by a read-only K tile. The tile's logical shape,
// not the allocation's 4096-wide shape or a zero default, determines M/K/N.
// CHECK-LABEL: func.func @full_y_preload_read_subview(
// CHECK-DAG: %[[M:.*]] = arith.constant 128 : index
// CHECK-DAG: %[[K:.*]] = arith.constant 128 : index
// CHECK-DAG: %[[N:.*]] = arith.constant 64 : index
// CHECK: hivm.hir.mmadL1 {b_transpose} ins({{.*}}, {{.*}}, {{.*}}, %[[M]], %[[K]], %[[N]] : tensor<128x128xi8>, tensor<64x128xi8>, i1, index, index, index)
func.func @full_y_preload_read_subview(%gm_a: memref<128x128xi8>, %gm_b: memref<64x4096xi8>, %k_offset: index) -> tensor<128x64xi32> {
  %zero = arith.constant 0 : index
  %true = arith.constant true
  %a = memref.alloc() : memref<128x128xi8>
  hivm.hir.load ins(%gm_a : memref<128x128xi8>) outs(%a : memref<128x128xi8>)
  %at = bufferization.to_tensor %a restrict writable : memref<128x128xi8>
  %b = memref.alloc() : memref<64x4096xi8>
  hivm.hir.load ins(%gm_b : memref<64x4096xi8>) outs(%b : memref<64x4096xi8>)
  %tile = memref.subview %b[0, %k_offset] [64, 128] [1, 1] : memref<64x4096xi8> to memref<64x128xi8, strided<[4096, 1], offset: ?>>
  %bt = bufferization.to_tensor %tile restrict writable : memref<64x128xi8, strided<[4096, 1], offset: ?>>
  %empty = tensor.empty() : tensor<128x64xi32>
  %result = hivm.hir.mmadL1 {b_transpose} ins(%at, %bt, %true, %zero, %zero, %zero : tensor<128x128xi8>, tensor<64x128xi8>, i1, index, index, index) outs(%empty : tensor<128x64xi32>) -> tensor<128x64xi32>
  return %result : tensor<128x64xi32>
}

// -----

// The actual A operand is reached through a cast. Unrelated read-only siblings
// have different sizes and must not supply the matmul's real dimensions.
// CHECK-LABEL: func.func @full_a_copy_with_read_siblings(
// CHECK-DAG: %[[M:.*]] = arith.constant 32 : index
// CHECK-DAG: %[[K:.*]] = arith.constant 256 : index
// CHECK-DAG: %[[N:.*]] = arith.constant 64 : index
// CHECK: hivm.hir.mmadL1 ins({{.*}}, {{.*}}, {{.*}}, %[[M]], %[[K]], %[[N]] : tensor<32x256xi8>, tensor<256x64xi8>, i1, index, index, index)
func.func @full_a_copy_with_read_siblings(%gm_a: memref<256x512xi8>, %gm_b: memref<256x64xi8>, %m_offset: index, %k_offset: index) -> tensor<32x64xi32> {
  %zero = arith.constant 0 : index
  %true = arith.constant true
  %a = memref.alloc() : memref<256x512xi8>
  memref.copy %gm_a, %a : memref<256x512xi8> to memref<256x512xi8>
  %before = memref.subview %a[0, 0] [16, 64] [1, 1] : memref<256x512xi8> to memref<16x64xi8, strided<[512, 1]>>
  %tile = memref.subview %a[%m_offset, %k_offset] [32, 256] [1, 1] : memref<256x512xi8> to memref<32x256xi8, strided<[512, 1], offset: ?>>
  %cast = memref.cast %tile : memref<32x256xi8, strided<[512, 1], offset: ?>> to memref<32x256xi8, strided<[?, ?], offset: ?>>
  %after = memref.subview %a[0, 0] [64, 128] [1, 1] : memref<256x512xi8> to memref<64x128xi8, strided<[512, 1]>>
  %at = bufferization.to_tensor %cast restrict writable : memref<32x256xi8, strided<[?, ?], offset: ?>>
  %b = memref.alloc() : memref<256x64xi8>
  hivm.hir.load ins(%gm_b : memref<256x64xi8>) outs(%b : memref<256x64xi8>)
  %bt = bufferization.to_tensor %b restrict writable : memref<256x64xi8>
  %empty = tensor.empty() : tensor<32x64xi32>
  %result = hivm.hir.mmadL1 ins(%at, %bt, %true, %zero, %zero, %zero : tensor<32x256xi8>, tensor<256x64xi8>, i1, index, index, index) outs(%empty : tensor<32x64xi32>) -> tensor<32x64xi32>
  "test.consume"(%before, %after) : (memref<16x64xi8, strided<[512, 1]>>, memref<64x128xi8, strided<[512, 1]>>) -> ()
  return %result : tensor<32x64xi32>
}

// -----

// The full copies have static, equal source/destination shapes, while the
// consumed windows carry dynamic real dimensions that must be preserved.
// CHECK-LABEL: func.func @full_preload_dynamic_window(
// CHECK-SAME: %[[M:[^:]+]]: index, %[[K:[^:]+]]: index, %[[N:[^:]+]]: index)
// CHECK: hivm.hir.mmadL1 ins({{.*}}, {{.*}}, {{.*}}, %[[M]], %[[K]], %[[N]] : tensor<?x?xi8>, tensor<?x?xi8>, i1, index, index, index)
func.func @full_preload_dynamic_window(%gm_a: memref<128x256xi8>, %gm_b: memref<256x64xi8>, %m: index, %k: index, %n: index) -> tensor<?x?xi32> {
  %zero = arith.constant 0 : index
  %true = arith.constant true
  %a = memref.alloc() : memref<128x256xi8>
  hivm.hir.load ins(%gm_a : memref<128x256xi8>) outs(%a : memref<128x256xi8>)
  %av = memref.subview %a[0, 0] [%m, %k] [1, 1] : memref<128x256xi8> to memref<?x?xi8, strided<[256, 1]>>
  %at = bufferization.to_tensor %av restrict writable : memref<?x?xi8, strided<[256, 1]>>
  %b = memref.alloc() : memref<256x64xi8>
  hivm.hir.load ins(%gm_b : memref<256x64xi8>) outs(%b : memref<256x64xi8>)
  %bv = memref.subview %b[0, 0] [%k, %n] [1, 1] : memref<256x64xi8> to memref<?x?xi8, strided<[64, 1]>>
  %bt = bufferization.to_tensor %bv restrict writable : memref<?x?xi8, strided<[64, 1]>>
  %empty = tensor.empty(%m, %n) : tensor<?x?xi32>
  %result = hivm.hir.mmadL1 ins(%at, %bt, %true, %zero, %zero, %zero : tensor<?x?xi8>, tensor<?x?xi8>, i1, index, index, index) outs(%empty : tensor<?x?xi32>) -> tensor<?x?xi32>
  return %result : tensor<?x?xi32>
}

// -----

// A partial writer still defines the valid extents. Read-only tiles must not
// make the fallback treat the whole allocation (or whole read tile) as valid.
// CHECK-LABEL: func.func @partial_writers_keep_masked_extents(
// CHECK-DAG: %[[M:.*]] = arith.constant 64 : index
// CHECK-DAG: %[[K:.*]] = arith.constant 96 : index
// CHECK-DAG: %[[N:.*]] = arith.constant 32 : index
// CHECK: hivm.hir.mmadL1 ins({{.*}}, {{.*}}, {{.*}}, %[[M]], %[[K]], %[[N]] : tensor<128x128xi8>, tensor<128x64xi8>, i1, index, index, index)
func.func @partial_writers_keep_masked_extents(%gm_a: memref<64x96xi8>, %gm_b: memref<96x32xi8>) -> tensor<128x64xi32> {
  %zero = arith.constant 0 : index
  %pad = arith.constant 0 : i8
  %true = arith.constant true
  %a = memref.alloc() : memref<128x256xi8>
  %aw = memref.subview %a[0, 0] [64, 96] [1, 1] : memref<128x256xi8> to memref<64x96xi8, strided<[256, 1]>>
  hivm.hir.load ins(%gm_a : memref<64x96xi8>) outs(%aw : memref<64x96xi8, strided<[256, 1]>>) pad_mode = <PadValue> pad_value = %pad : i8 left_padding_num = %zero : index init_out_buffer = true
  %av = memref.subview %a[0, 0] [128, 128] [1, 1] : memref<128x256xi8> to memref<128x128xi8, strided<[256, 1]>>
  %at = bufferization.to_tensor %av restrict writable : memref<128x128xi8, strided<[256, 1]>>
  %b = memref.alloc() : memref<256x64xi8>
  %bw = memref.subview %b[0, 0] [96, 32] [1, 1] : memref<256x64xi8> to memref<96x32xi8, strided<[64, 1]>>
  hivm.hir.load ins(%gm_b : memref<96x32xi8>) outs(%bw : memref<96x32xi8, strided<[64, 1]>>) pad_mode = <PadValue> pad_value = %pad : i8 left_padding_num = %zero : index init_out_buffer = true
  %bv = memref.subview %b[0, 0] [128, 64] [1, 1] : memref<256x64xi8> to memref<128x64xi8, strided<[64, 1]>>
  %bt = bufferization.to_tensor %bv restrict writable : memref<128x64xi8, strided<[64, 1]>>
  %empty = tensor.empty() : tensor<128x64xi32>
  %result = hivm.hir.mmadL1 ins(%at, %bt, %true, %zero, %zero, %zero : tensor<128x128xi8>, tensor<128x64xi8>, i1, index, index, index) outs(%empty : tensor<128x64xi32>) -> tensor<128x64xi32>
  return %result : tensor<128x64xi32>
}
