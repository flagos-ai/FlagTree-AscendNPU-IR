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

// RUN: bishengir-opt %s --hfusion-normalize-ops --hfusion-fuse-ops --split-input-file | FileCheck %s

// CHECK: @smallest_0(
// CHECK-SAME: ANY_PB
func.func @smallest(%arg0: tensor<8x768x16x1xf32>, %arg1: tensor<8x768x16x1xf32>) -> tensor<8x768x16x1xf32> attributes {hacc.function_kind = #hacc.function_kind<HOST>, hfusion.fusion_kind = #hfusion.fusion_kind<ANY_PB>} {
    %2 = hfusion.elemwise_unary {fun = #hfusion.unary_fn<rsqrt>} ins(%arg0 : tensor<8x768x16x1xf32>) outs(%arg1 : tensor<8x768x16x1xf32>) -> tensor<8x768x16x1xf32>
    return %2 : tensor<8x768x16x1xf32>
}
