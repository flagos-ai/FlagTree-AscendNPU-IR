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
// RUN: bishengir-compile -enable-hfusion-compile=true -enable-hivm-compile=true -enable-lir-compile=false %s

module {
  func.func @reduce_broadcast_reduce(%arg0: tensor<16x32x4096x5120xf32>, %arg1: tensor<16x32x4096x5120xf32>) -> (tensor<16x16x2048x2560xf32>, tensor<16x16x2048x2560xf32>) 
  attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
    %cst = arith.constant 2.560000e+03 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %0 = tensor.empty() : tensor<16x16x2048x2560xf32>
    %1 = tensor.empty() : tensor<16x16xf32>
    %2 = linalg.fill ins(%cst_0 : f32) outs(%1 : tensor<16x16xf32>) -> tensor<16x16xf32>
    %extracted_slice = tensor.extract_slice %arg0[0, 0, 0, 0] [16, 16, 2048, 2560] [1, 1, 1, 1] : tensor<16x32x4096x5120xf32> to tensor<16x16x2048x2560xf32>
    %extracted_slice_1 = tensor.extract_slice %arg1[0, 0, 0, 0] [16, 16, 2048, 2560] [1, 1, 1, 1] : tensor<16x32x4096x5120xf32> to tensor<16x16x2048x2560xf32>
    %3 = linalg.elemwise_binary {fun = #linalg.binary_fn<add>} ins(%extracted_slice, %extracted_slice_1 : tensor<16x16x2048x2560xf32>, tensor<16x16x2048x2560xf32>) outs(%0 : tensor<16x16x2048x2560xf32>) -> tensor<16x16x2048x2560xf32>
    %reduced = linalg.reduce ins(%3 : tensor<16x16x2048x2560xf32>) outs(%2 : tensor<16x16xf32>) dimensions = [2, 3] 
      (%in: f32, %init: f32) {
        %6 = arith.addf %in, %init : f32
        linalg.yield %6 : f32
      }
    %4 = linalg.elemwise_binary {fun = #linalg.binary_fn<add>} ins(%reduced, %cst : tensor<16x16xf32>, f32) outs(%1 : tensor<16x16xf32>) -> tensor<16x16xf32>
    %broadcasted = linalg.broadcast ins(%4 : tensor<16x16xf32>) outs(%0 : tensor<16x16x2048x2560xf32>) dimensions = [2, 3] 
    %reduced_2 = linalg.reduce ins(%broadcasted : tensor<16x16x2048x2560xf32>) outs(%2 : tensor<16x16xf32>) dimensions = [2, 3] 
      (%in: f32, %init: f32) {
        %6 = arith.addf %in, %init : f32
        linalg.yield %6 : f32
      }
    %broadcasted_3 = linalg.broadcast ins(%reduced_2 : tensor<16x16xf32>) outs(%0 : tensor<16x16x2048x2560xf32>) dimensions = [2, 3] 
    %5 = linalg.elemwise_binary {fun = #linalg.binary_fn<mul>} ins(%broadcasted_3, %3 : tensor<16x16x2048x2560xf32>, tensor<16x16x2048x2560xf32>) outs(%0 : tensor<16x16x2048x2560xf32>) -> tensor<16x16x2048x2560xf32>
    return %3, %5 : tensor<16x16x2048x2560xf32>, tensor<16x16x2048x2560xf32>
  }
}
