// RUN: bishengir-opt %s -hivm-normalize-matmul -split-input-file -verify-diagnostics -allow-unregistered-dialect

// A later full copy does not establish valid data at this matmul. Keep the
// existing unsupported-case diagnostic rather than accepting the read shape.
func.func @full_writer_after_consumer(%gm_a: memref<128x256xi8>, %b: tensor<128x64xi8>, %k_offset: index) -> tensor<128x64xi32> {
  %zero = arith.constant 0 : index
  %true = arith.constant true
  // expected-error @+1 {{Don't support the case when the root alloc is subview-ed and written to multiple times}}
  %a = memref.alloc() : memref<128x256xi8>
  %av = memref.subview %a[0, %k_offset] [128, 128] [1, 1] : memref<128x256xi8> to memref<128x128xi8, strided<[256, 1], offset: ?>>
  %at = bufferization.to_tensor %av restrict writable : memref<128x128xi8, strided<[256, 1], offset: ?>>
  %empty = tensor.empty() : tensor<128x64xi32>
  %result = hivm.hir.mmadL1 ins(%at, %b, %true, %zero, %zero, %zero : tensor<128x128xi8>, tensor<128x64xi8>, i1, index, index, index) outs(%empty : tensor<128x64xi32>) -> tensor<128x64xi32>
  hivm.hir.load ins(%gm_a : memref<128x256xi8>) outs(%a : memref<128x256xi8>)
  return %result : tensor<128x64xi32>
}

// -----

// A read-only subview by itself is insufficient: there is no full writer.
func.func @read_subview_without_full_writer(%b: tensor<128x64xi8>, %k_offset: index) -> tensor<128x64xi32> {
  %zero = arith.constant 0 : index
  %true = arith.constant true
  // expected-error @+1 {{Don't support the case when the root alloc is subview-ed and written to multiple times}}
  %a = memref.alloc() : memref<128x256xi8>
  %av = memref.subview %a[0, %k_offset] [128, 128] [1, 1] : memref<128x256xi8> to memref<128x128xi8, strided<[256, 1], offset: ?>>
  %at = bufferization.to_tensor %av restrict writable : memref<128x128xi8, strided<[256, 1], offset: ?>>
  %empty = tensor.empty() : tensor<128x64xi32>
  %result = hivm.hir.mmadL1 ins(%at, %b, %true, %zero, %zero, %zero : tensor<128x128xi8>, tensor<128x64xi8>, i1, index, index, index) outs(%empty : tensor<128x64xi32>) -> tensor<128x64xi32>
  return %result : tensor<128x64xi32>
}

// -----

// Padding metadata is deliberately outside the new full-copy inference case,
// even when the load's source and destination have equal static shapes.
func.func @padded_full_load_keeps_diagnostic(%gm_a: memref<128x256xi8>, %b: tensor<128x64xi8>, %k_offset: index) -> tensor<128x64xi32> {
  %zero = arith.constant 0 : index
  %pad = arith.constant 0 : i8
  %true = arith.constant true
  // expected-error @+1 {{Don't support the case when the root alloc is subview-ed and written to multiple times}}
  %a = memref.alloc() : memref<128x256xi8>
  hivm.hir.load ins(%gm_a : memref<128x256xi8>) outs(%a : memref<128x256xi8>) pad_mode = <PadValue> pad_value = %pad : i8 left_padding_num = %zero : index init_out_buffer = true
  %av = memref.subview %a[0, %k_offset] [128, 128] [1, 1] : memref<128x256xi8> to memref<128x128xi8, strided<[256, 1], offset: ?>>
  %at = bufferization.to_tensor %av restrict writable : memref<128x128xi8, strided<[256, 1], offset: ?>>
  %empty = tensor.empty() : tensor<128x64xi32>
  %result = hivm.hir.mmadL1 ins(%at, %b, %true, %zero, %zero, %zero : tensor<128x128xi8>, tensor<128x64xi8>, i1, index, index, index) outs(%empty : tensor<128x64xi32>) -> tensor<128x64xi32>
  return %result : tensor<128x64xi32>
}
