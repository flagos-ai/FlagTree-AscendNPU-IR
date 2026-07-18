// Copyright 2026 FlagOS Contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// REQUIRES: hivmc
// RUN: bishengir-compile %s

module @M attributes {hivm.func_core_type = #hivm.func_core_type<MIX>} {
  func.func @mul_add_mix_aic(%arg0: memref<64x64xf16>,
                             %arg1: memref<64x64xf16>,
                             %arg2: memref<64x64xf16>,
                             %arg3: memref<64x64xf16>)
                             attributes {hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIC>} {
    hivm.hir.matmul ins(%arg1, %arg2 : memref<64x64xf16>, memref<64x64xf16>)
                    outs(%arg3 : memref<64x64xf16>)
    return
  }

  func.func @mul_add_mix_aiv(%valueA: memref<16xf16, #hivm.address_space<gm>>,
                             %valueB: memref<16xf16, #hivm.address_space<gm>>,
                             %valueC: memref<16xf16, #hivm.address_space<gm>>)
                             attributes {hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<AIV>}
  {
    %ubA = memref.alloc() : memref<16xf16, #hivm.address_space<ub>>
    hivm.hir.load ins(%valueA : memref<16xf16, #hivm.address_space<gm>>) outs(%ubA : memref<16xf16, #hivm.address_space<ub>>)

    %ubB = memref.alloc() : memref<16xf16, #hivm.address_space<ub>>
    hivm.hir.load ins(%valueB : memref<16xf16, #hivm.address_space<gm>>) outs(%ubB : memref<16xf16, #hivm.address_space<ub>>)

    %ubC = memref.alloc() : memref<16xf16, #hivm.address_space<ub>>
    hivm.hir.vadd ins(%ubA, %ubB: memref<16xf16, #hivm.address_space<ub>>, memref<16xf16, #hivm.address_space<ub>>) outs(%ubC: memref<16xf16, #hivm.address_space<ub>>)

    hivm.hir.store ins(%ubC : memref<16xf16, #hivm.address_space<ub>>) outs(%valueC : memref<16xf16, #hivm.address_space<gm>>)
    return
  }
}
