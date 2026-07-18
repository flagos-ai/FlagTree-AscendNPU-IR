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

// RUN: bishengir-opt -hfusion-add-ffts-addr %s -verify-diagnostics | FileCheck %s

// CHECK-LABEL: func.func @test_add_ffts_addr(
// CHECK-SAME:                         %[[ARG0:.*]]: i64 {hacc.arg_type = #hacc.arg_type<ffts_base_address>},
// CHECK-SAME:                         %[[ARG1:.*]]: tensor<1024x1024xf32>, %[[ARG2:.*]]: tensor<1024x1024xf32>, %[[ARG3:.*]]: tensor<1024x1024xf32>, %[[ARG4:.*]]: tensor<1024x1024xf32>)
func.func @test_add_ffts_addr(%arg0: tensor<1024x1024xf32>, %arg1 : tensor<1024x1024xf32>, %arg2 : tensor<1024x1024xf32>, %arg3 : tensor<1024x1024xf32>) -> (tensor<1024x1024xf32>)
attributes {hfusion.fusion_kind = #hfusion.fusion_kind<SHALLOW_CV>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
  %0 = tensor.empty() : tensor<1024x1024xf32>
  %1 = linalg.matmul ins(%arg0, %arg1 : tensor<1024x1024xf32>, tensor<1024x1024xf32>) outs(%0 : tensor<1024x1024xf32>) -> tensor<1024x1024xf32>

  %2 = tensor.empty() : tensor<1024x1024xf32>
  %3 = linalg.elemwise_binary { add, fun = #linalg.binary_fn<add> } ins(%1, %arg2 : tensor<1024x1024xf32>, tensor<1024x1024xf32>) outs(%2 : tensor<1024x1024xf32>) -> tensor<1024x1024xf32>

  %4 = tensor.empty() : tensor<1024x1024xf32>
  %5 = linalg.elemwise_binary { sub, fun = #linalg.binary_fn<mul> } ins(%3, %arg3: tensor<1024x1024xf32>, tensor<1024x1024xf32>) outs(%4 : tensor<1024x1024xf32>) -> tensor<1024x1024xf32>

  return %5 : tensor<1024x1024xf32>
}
