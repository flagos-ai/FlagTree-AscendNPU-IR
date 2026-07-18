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

// RUN: bishengir-opt %s -hfusion-auto-schedule="block-dim=40 enable-deterministic-computing=false" -split-input-file | FileCheck %s

// CHECK: multicore_reduce_sum
// CHECK: mapping = [#hivm.block]
// CHECK: mapping = [#hivm.block]

func.func @multicore_reduce_sum(%arg0: tensor<1000000x3xf32>) -> tensor<3xf32> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hfusion.fusion_kind = #hfusion.fusion_kind<ANY_PBR>} {
  %0 = tensor.empty() : tensor<3xf32>
  %reduced = linalg.reduce ins(%arg0 : tensor<1000000x3xf32>) outs(%0 : tensor<3xf32>) dimensions = [0] 
    (%in: f32, %init: f32) {
      %1 = arith.addf %in, %init : f32
      linalg.yield %1 : f32
    }
  return %reduced : tensor<3xf32>
}

// CHECK: multicore_reduce_max
// CHECK: mapping = [#hivm.block]
// CHECK: mapping = [#hivm.block]
func.func @multicore_reduce_max(%arg0: tensor<1000000x3xf32>) -> tensor<3xf32> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hfusion.fusion_kind = #hfusion.fusion_kind<ANY_PBR>} {
  %0 = tensor.empty() : tensor<3xf32>
  %reduced = linalg.reduce ins(%arg0 : tensor<1000000x3xf32>) outs(%0 : tensor<3xf32>) dimensions = [0]
    (%in: f32, %init: f32) {
      %1 = arith.maximumf %in, %init : f32
      linalg.yield %1 : f32
    }
  return %reduced : tensor<3xf32>
}

// CHECK: multicore_reduce_min
// CHECK: mapping = [#hivm.block]
// CHECK: mapping = [#hivm.block]
func.func @multicore_reduce_min(%arg0: tensor<1000000x3xf32>) -> tensor<3xf32> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hfusion.fusion_kind = #hfusion.fusion_kind<ANY_PBR>} {
  %0 = tensor.empty() : tensor<3xf32>
  %reduced = linalg.reduce ins(%arg0 : tensor<1000000x3xf32>) outs(%0 : tensor<3xf32>) dimensions = [0]
    (%in: f32, %init: f32) {
      %1 = arith.minimumf %in, %init : f32
      linalg.yield %1 : f32
    }
  return %reduced : tensor<3xf32>
}
