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

// RUN: bishengir-opt --hivm-insert-infer-workspace-size-func -split-input-file %s | FileCheck %s -check-prefixes=CHECK
// -----

// CHECK: func.func @insert_infer_workspace_size_func_infer_workspace_shape_function() -> index
// CHECK: %[[BYTE_SIZE:.*]] = arith.constant 3400 : index
// CHECK: return %[[BYTE_SIZE]]
func.func @insert_infer_workspace_size_func(
              %arg0: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>},
              %arg1: memref<?xi8> {hacc.arg_type = #hacc.arg_type<workspace>}){
  %cst_0 = arith.constant 0 : index
  %cst_100 = arith.constant 100 : index
  %cst_200 = arith.constant 200 : index
  memref_ext.alloc_workspace() from %arg1 offset = [%cst_0] : from memref<?xi8> to memref<100xi8>
  memref_ext.alloc_workspace() from %arg1 offset = [%cst_100] : from memref<?xi8> to memref<800xi8>
  memref_ext.alloc_workspace() from %arg1 offset = [%cst_200] : from memref<?xi8> to memref<800xi32>
  return
}
