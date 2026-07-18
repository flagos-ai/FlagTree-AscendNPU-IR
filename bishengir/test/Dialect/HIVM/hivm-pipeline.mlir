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

// RUN: bishengir-opt -optimize-hivm-pipeline="tile-mix-cube-loop=1 tile-mix-vector-loop=1" %s | FileCheck %s
// RUN: bishengir-opt -optimize-hivm-pipeline="enable-hivm-inject-barrier-all-sync=true tile-mix-cube-loop=1 tile-mix-vector-loop=1" %s | FileCheck %s -check-prefix=CHECK-BAR-ALL

module {
// CHECK: hivm.hir.set_mask_norm

// CHECK-BAR-ALL-NOT: hivm.hir.set_flag
// CHECK-BAR-ALL-NOT: hivm.hir.wait_flag
  func.func @test(%arg0: memref<16xf16, #hivm.address_space<gm>>, %arg1: memref<16xf16, #hivm.address_space<gm>>, %arg2: memref<16xf16, #hivm.address_space<gm>>) attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
    %alloc = memref.alloc() : memref<16xf16, #hivm.address_space<ub>>
    hivm.hir.load ins(%arg0 : memref<16xf16, #hivm.address_space<gm>>) outs(%alloc : memref<16xf16, #hivm.address_space<ub>>)
    %alloc_0 = memref.alloc() : memref<16xf16, #hivm.address_space<ub>>
    hivm.hir.load ins(%arg1 : memref<16xf16, #hivm.address_space<gm>>) outs(%alloc_0 : memref<16xf16, #hivm.address_space<ub>>)
    %alloc_1 = memref.alloc() : memref<16xf16, #hivm.address_space<ub>>
    hivm.hir.vadd ins(%alloc, %alloc_0 : memref<16xf16, #hivm.address_space<ub>>, memref<16xf16, #hivm.address_space<ub>>) outs(%alloc_1 : memref<16xf16, #hivm.address_space<ub>>)
    hivm.hir.store ins(%alloc_1 : memref<16xf16, #hivm.address_space<ub>>) outs(%arg2 : memref<16xf16, #hivm.address_space<gm>>)
    return
  }
}
