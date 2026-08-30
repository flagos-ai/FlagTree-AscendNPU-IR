// RUN: bishengir-opt %s -convert-hivm-to-std | FileCheck %s

module {
  func.func @load_hint(
      %src: memref<16xf32, #hivm.address_space<gm>>,
      %dst: memref<16xf32, #hivm.address_space<ub>>)
      attributes {hacc.function_kind = #hacc.function_kind<DEVICE>} {
    hivm.hir.load ins(%src : memref<16xf32, #hivm.address_space<gm>>)
                  outs(%dst : memref<16xf32, #hivm.address_space<ub>>)
                  {l2_cache_mode = 4 : i32}
    return
  }

  // CHECK-LABEL: func.func @load_hint
  // CHECK: call @load_gm_to_ubuf_1d_float{{.*}} {l2_cache_mode = 4 : i32}

  func.func @store_hint(
      %src: memref<16xf32, #hivm.address_space<ub>>,
      %dst: memref<16xf32, #hivm.address_space<gm>>)
      attributes {hacc.function_kind = #hacc.function_kind<DEVICE>} {
    hivm.hir.store ins(%src : memref<16xf32, #hivm.address_space<ub>>)
                   outs(%dst : memref<16xf32, #hivm.address_space<gm>>)
                   {l2_cache_mode = 4 : i32}
    return
  }

  // CHECK-LABEL: func.func @store_hint
  // CHECK: call @store_ubuf_to_gm_1d_float{{.*}} {l2_cache_mode = 4 : i32}
}
