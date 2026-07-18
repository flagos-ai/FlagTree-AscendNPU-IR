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

// RUN: bishengir-opt %s -hfusion-auto-schedule -split-input-file 2>&1 | FileCheck %s


// CHECK-LABEL: @tile_interchange(
// CHECK: scf.for
// CHECK: scf.for
// CHECK-NOT: scf.for
module {
  func.func @tile_interchange(%arg0: tensor<256x8x16x64xf32>) -> (tensor<256x16x8x64xf32>, tensor<256x8x16x64xf32>) attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hfusion.fusion_kind = #hfusion.fusion_kind<ANY_PBR>} {
    %1 = tensor.empty() : tensor<256x16x8x64xf32>
    %2 = tensor.empty() : tensor<256x8x16x64xf32>
    %5 = linalg.elemwise_binary {fun = #linalg.binary_fn<add>} ins(%arg0, %arg0 : tensor<256x8x16x64xf32>, tensor<256x8x16x64xf32>) outs(%2 : tensor<256x8x16x64xf32>) -> tensor<256x8x16x64xf32>
    %transposed = linalg.transpose ins(%arg0 : tensor<256x8x16x64xf32>) outs(%1 : tensor<256x16x8x64xf32>) permutation = [0, 2, 1, 3]
    return %transposed, %5 : tensor<256x16x8x64xf32>, tensor<256x8x16x64xf32>
  }
}
