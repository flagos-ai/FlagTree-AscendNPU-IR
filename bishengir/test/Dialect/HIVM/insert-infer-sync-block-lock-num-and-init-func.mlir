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

// RUN: bishengir-opt --hivm-insert-infer-sync-block-lock-num-and-init-func -split-input-file %s | FileCheck %s -check-prefixes=CHECK
// -----

// CHECK: func.func @insert_infer_sync_block_lock_num_and_size_func_infer_sync_block_lock_num_function() -> i64
// CHECK: %[[BYTE_SIZE:.*]] = arith.constant 24 : i64
// CHECK: return %[[BYTE_SIZE]]
// CHECK: func.func @insert_infer_sync_block_lock_num_and_size_func_infer_sync_block_lock_init_function() -> i64
// CHECK: %[[INIT:.*]] = arith.constant 0 : i64
// CHECK: return %[[INIT]]
func.func @insert_infer_sync_block_lock_num_and_size_func(
              %arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>},
              %arg1: memref<?xi8> {hacc.arg_type = #hacc.arg_type<sync_block_lock>}){
  %cst_0 = arith.constant 0 : index
  %cst_8 = arith.constant 8 : index
  %cst_16 = arith.constant 16 : index
  hivm.hir.create_sync_block_lock from %arg1 : from memref<?xi8> to memref<1xi64>
  hivm.hir.create_sync_block_lock from %arg1 : from memref<?xi8> to memref<1xi64>
  hivm.hir.create_sync_block_lock from %arg1 : from memref<?xi8> to memref<1xi64>
  return
}
