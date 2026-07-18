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

// RUN: bishengir-opt --test-assign-fusion-kind --fusion-kind="PURE_ELEMWISE" --hfusion-fuse-ops --split-input-file %s | FileCheck %s
// RUN: bishengir-opt -hfusion-outline-single-op --split-input-file %s | FileCheck %s --check-prefix=SINGLE-OUTLINE

// CHECK-LABEL: func.func @test_opfusion_0
// CHECK: linalg.elemwise_binary
// CHECK: hfusion.deinterleave
// CHECK: linalg.elemwise_unary
// CHECK hfusion.interleave
// CHECK: return
// CHECK-LABEL: func.func @test_opfusion
// CHECK: call @test_opfusion_0
func.func @test_opfusion(%arg0: tensor<4x4xf32>, %arg1 : tensor<4x4xf32>) -> (tensor<4x2xf32>, tensor<4x4xf32>) attributes {hacc.function_kind = #hacc.function_kind<HOST>} {
  %empty = tensor.empty() : tensor<4x4xf32>
  %empty_1 = tensor.empty() : tensor<4x2xf32>
  %1 = linalg.elemwise_binary { mul, fun = #linalg.binary_fn<mul> } ins(%arg0, %arg1 : tensor<4x4xf32>, tensor<4x4xf32>) outs(%empty : tensor<4x4xf32>) -> tensor<4x4xf32>
  %deinterleaved = hfusion.deinterleave %1 channel<0> : tensor<4x4xf32> -> tensor<4x2xf32>
  %2 = linalg.elemwise_unary { fun = #linalg.unary_fn<ceil> } ins(%deinterleaved : tensor<4x2xf32>) outs(%empty_1 : tensor<4x2xf32>) -> tensor<4x2xf32>
  %interleaved = hfusion.interleave %deinterleaved, %2 : tensor<4x2xf32>, tensor<4x2xf32> -> tensor<4x4xf32>
  return %deinterleaved, %interleaved : tensor<4x2xf32>, tensor<4x4xf32>
}

// -----

// SINGLE-OUTLINE-LABEL: func.func @test_single_outline_single_outlined_0_0
// SINGLE-OUTLINE: linalg.elemwise_binary
// SINGLE-OUTLINE-LABEL: func.func @test_single_outline_single_outlined_1_0
// SINGLE-OUTLINE: hfusion.deinterleave
// SINGLE-OUTLINE-LABEL: func.func @test_single_outline_single_outlined_2_0
// SINGLE-OUTLINE: hfusion.interleave
// SINGLE-OUTLINE-LABEL: func.func @test_single_outline(
// SINGLE-OUTLINE-NOT: linalg
// SINGLE-OUTLINE: return
func.func @test_single_outline(%arg0: tensor<4x4xf32>, %arg1 : tensor<4x4xf32>) -> (tensor<4x2xf32>, tensor<4x4xf32>) attributes {hacc.function_kind = #hacc.function_kind<HOST>} {
  %empty = tensor.empty() : tensor<4x4xf32>
  %1 = linalg.elemwise_binary { mul, fun = #linalg.binary_fn<mul> } ins(%arg0, %arg1 : tensor<4x4xf32>, tensor<4x4xf32>) outs(%empty : tensor<4x4xf32>) -> tensor<4x4xf32>
  %deinterleaved = hfusion.deinterleave %1 channel<1> : tensor<4x4xf32> -> tensor<4x2xf32>
  %interleaved = hfusion.interleave %deinterleaved, %deinterleaved : tensor<4x2xf32>, tensor<4x2xf32> -> tensor<4x4xf32>
  return %deinterleaved, %interleaved : tensor<4x2xf32>, tensor<4x4xf32>
}
