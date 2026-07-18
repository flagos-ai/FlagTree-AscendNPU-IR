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
// RUN: bishengir-compile --enable-lir-compile=false -enable-hfusion-compile=true -block-dim=20  %s

module {
  func.func @fused_mul_pow_mul_split(%arg0: tensor<1xf32>, %arg1: tensor<1xf32>, %arg2: tensor<1xf32>) -> tensor<1xf32>
  attributes {OperatorType = "Default", compute_capability = "", hacc.function_kind = #hacc.function_kind<DEVICE>,
  mindspore_kernel, process = "aicore"} {
    %0 = tensor.empty() : tensor<1xf32>
    %1 = linalg.elemwise_binary {fun = #linalg.binary_fn<mul>} ins(%arg0, %arg1 : tensor<1xf32>, tensor<1xf32>) outs(%0 : tensor<1xf32>) -> tensor<1xf32>
    %cst = arith.constant dense<0.51> : tensor<1xf32>
    %2 = tensor.empty() : tensor<1xf32>
    %3 = hfusion.elemwise_binary {fun = #hfusion.binary_fn<powf>} ins(%1, %cst : tensor<1xf32>, tensor<1xf32>) outs(%2 : tensor<1xf32>) -> tensor<1xf32>
    %cst_0 = arith.constant dense<0.001953125> : tensor<1xf32>
    %4 = tensor.empty() : tensor<1xf32>
    %5 = linalg.elemwise_binary {fun = #linalg.binary_fn<mul>} ins(%3, %cst_0 : tensor<1xf32>, tensor<1xf32>) outs(%arg2 : tensor<1xf32>) -> tensor<1xf32>
    return %5 : tensor<1xf32>
  }
}
