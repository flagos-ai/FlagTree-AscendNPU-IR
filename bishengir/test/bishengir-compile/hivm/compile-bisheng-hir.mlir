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

// UNSUPPORTED: bishengir_published
// RUN: bishengir-compile -enable-lir-compile=false %s

module {
  func.func @test_basic__kernel0(%valueA: memref<16xf16, #hivm.address_space<gm>>,
                                 %valueB: memref<16xf16, #hivm.address_space<gm>>,
                                 %valueC: memref<16xf16, #hivm.address_space<gm>>)
                                 attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>}
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
