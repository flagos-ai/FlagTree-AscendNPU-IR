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

// RUN: bishengir-opt --hivm-lower-create-sync-block-lock %s -split-input-file -verify-diagnostics | FileCheck %s

// -----
// CHECK: module
module {
  func.func @test_alloc_sync_block_lock_infer_sync_block_lock_num_function() -> i64 attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.host_func_type = #hacc.host_func_type<infer_sync_block_lock_num_function>} {
    %c1_i64 = arith.constant 1 : i64
    return %c1_i64 : i64
  }
  func.func @test_alloc_sync_block_lock_infer_sync_block_lock_init_function() -> i64 attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.host_func_type = #hacc.host_func_type<infer_sync_block_lock_init_function>} {
    %c0_i64 = arith.constant 0 : i64
    return %c0_i64 : i64
  }
  // CHECK-LABEL: func.func @test_alloc_sync_block_lock
  func.func @test_alloc_sync_block_lock(%arg0: memref<?xi8>, %arg1: memref<?xi8>) -> tensor<1xi64>{
    // %[[view:.*]] = memref.view %[[arg0:.*]][%[[OFFSET:.*]]][] : memref<?xi8> to memref<1xi64>
    %lock_var = hivm.hir.create_sync_block_lock from %arg0 : from memref<?xi8> to memref<1xi64>
    %res = bufferization.to_tensor %lock_var restrict writable : memref<1xi64>
    return %res : tensor<1xi64>
  }
}
