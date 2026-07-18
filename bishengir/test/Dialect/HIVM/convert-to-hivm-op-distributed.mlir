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

// RUN: bishengir-opt %s -convert-to-hivm-op -split-input-file -allow-unregistered-dialect | FileCheck %s

// Test ConvertToHIVMOp pass for distributed CustomOp

// -----
// Test memref.copy from distributed CustomOp result

module {
  func.func @copy_from_dist_result(%arg0: memref<128x128xf16>) attributes {hacc.function_kind = #hacc.function_kind<DEVICE>} {
    %0 = hivm.hir.custom
        {hivm.is_distributed,
         hivm.tcore_type = #hivm.tcore_type<VECTOR>,
         hivm.pipe = #hivm.pipe<PIPE_V>,
         symbol = "aclshmem_ptr_half"}
        "dist.aclshmem_ptr_half"
        ins(%arg0 : memref<128x128xf16>) -> memref<128x128xf16, strided<[?, ?], offset: ?>>
    %alloc = memref.alloc() : memref<128x128xf16>
    // CHECK: hivm.hir.load
    memref.copy %0, %alloc : memref<128x128xf16, strided<[?, ?], offset: ?>> to memref<128x128xf16>
    return
  }
}

// -----
// Test memref.copy to distributed CustomOp result

module {
  func.func @copy_from_dist_result(%arg0: memref<128x128xf16>) attributes {hacc.function_kind = #hacc.function_kind<DEVICE>} {
    %0 = hivm.hir.custom
        {hivm.is_distributed,
         hivm.tcore_type = #hivm.tcore_type<VECTOR>,
         hivm.pipe = #hivm.pipe<PIPE_V>,
         symbol = "aclshmem_ptr_half"}
        "dist.aclshmem_ptr_half"
        ins(%arg0 : memref<128x128xf16>) -> memref<128x128xf16, strided<[?, ?], offset: ?>>
    %alloc = memref.alloc() : memref<128x128xf16>
    // CHECK: hivm.hir.store
    memref.copy %alloc, %0 : memref<128x128xf16> to memref<128x128xf16, strided<[?, ?], offset: ?>>
    return
  }
}
