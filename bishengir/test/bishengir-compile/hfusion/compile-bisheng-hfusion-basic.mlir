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
// UNSUPPORTED: bishengir_published
// RUN: bishengir-compile -enable-lir-compile=false -enable-hfusion-compile=true -block-dim=20 %s

func.func @add_mul_reduce(%arg0: tensor<8xf32>, %arg1 : tensor<8xf32>, %arg2 : tensor<8xf32>, %arg3 : tensor<8xf32>) -> tensor<8xf32>
attributes {hacc.function_kind = #hacc.function_kind<HOST>}  {
  %1 = tensor.empty() : tensor<8xf32>
  %2 = linalg.elemwise_binary { mul, fun = #linalg.binary_fn<mul> } ins(%arg0, %arg1 : tensor<8xf32>, tensor<8xf32>) outs(%1 : tensor<8xf32>) -> tensor<8xf32>


  %4 = linalg.elemwise_binary { add, fun = #linalg.binary_fn<add> } ins(%2, %arg2 : tensor<8xf32>, tensor<8xf32>) outs(%arg3 : tensor<8xf32>) -> tensor<8xf32>
  return %4 : tensor<8xf32>
}
