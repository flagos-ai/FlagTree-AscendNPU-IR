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

func.func @reduce_to_rank0(%arg0: tensor<?x2xf32>, %arg1: i64) -> tensor<f32> 
attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<HOST>, hfusion.fusion_kind = #hfusion.fusion_kind<ANY_PBR>} {
  %cst = arith.constant 0.000000e+00 : f32
  %c0 = arith.constant 0 : index
  %0 = tensor.empty() : tensor<f32>
  %1 = linalg.fill ins(%cst : f32) outs(%0 : tensor<f32>) -> tensor<f32>
  %reduced = linalg.reduce ins(%arg0 : tensor<?x2xf32>) outs(%1 : tensor<f32>) dimensions = [0, 1] 
    (%in: f32, %init: f32) {
      %6 = arith.addf %in, %init : f32
      linalg.yield %6 : f32
    }
  %2 = tensor.empty() : tensor<i64>
  %3 = linalg.fill ins(%arg1 : i64) outs(%2 : tensor<i64>) -> tensor<i64>
  %4 = hfusion.cast {round_mode = #hfusion.round_mode<trunc>} ins(%3 : tensor<i64>) outs(%0 : tensor<f32>) -> tensor<f32>
  %5 = linalg.elemwise_binary {fun = #linalg.binary_fn<div>} ins(%reduced, %4 : tensor<f32>, tensor<f32>) outs(%0 : tensor<f32>) -> tensor<f32>
  return %5 : tensor<f32>
}
