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

// RUN: bishengir-opt %s -hfusion-auto-schedule="block-dim=40" -split-input-file | FileCheck %s

module {
  // CHECK: hacc.block_dim = 40
  func.func @vector_kernel() -> tensor<2x128xf32> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hfusion.fusion_kind = #hfusion.fusion_kind<PURE_ELEMWISE>} {
    %cst = arith.constant 0.000000e+00 : f32
    %0 = tensor.empty() : tensor<2x128xf32>
    %1 = linalg.fill ins(%cst : f32) outs(%0 : tensor<2x128xf32>) -> tensor<2x128xf32>
    return %1 : tensor<2x128xf32>
  }

  // CHECK: hacc.block_dim = 20
  func.func @cube_kernel(%arg0: tensor<?x4096xf16>, %arg1: tensor<6144x4096xf16>, %arg2: tensor<?x6144xf16>) -> tensor<?x6144xf16> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hfusion.fusion_kind = #hfusion.fusion_kind<SINGLE_CUBE>} {
    %0 = linalg.matmul_transpose_b ins(%arg0, %arg1 : tensor<?x4096xf16>, tensor<6144x4096xf16>) outs(%arg2 : tensor<?x6144xf16>) -> tensor<?x6144xf16>
    return %0 : tensor<?x6144xf16>
  }
}
