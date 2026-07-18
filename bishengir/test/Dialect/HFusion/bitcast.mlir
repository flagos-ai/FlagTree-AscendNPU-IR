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

// RUN: bishengir-opt %s -split-input-file -verify-diagnostics | FileCheck %s

module {
  // CHECK-LABEL: @test_bitcast_f32_i32_tensor(
  // CHECK: hfusion.bitcast
  func.func @test_bitcast_f32_i32_tensor(%arg0 : tensor<128x128xf32>, %arg1: tensor<128x128xi32>) -> tensor<128x128xi32> {
    %0 = tensor.empty() : tensor<128x128xi32>
    %1 = hfusion.bitcast
      ins(%arg0 : tensor<128x128xf32>) 
      outs(%0 : tensor<128x128xi32>) -> tensor<128x128xi32>  // Bitcast the f32 value to i32
    %2 = tensor.empty() : tensor<128x128xi32>
    %3 = linalg.matmul ins(%1, %arg1 : tensor<128x128xi32>, tensor<128x128xi32>) outs(%2 : tensor<128x128xi32>) -> tensor<128x128xi32>        // Another constant integer
    return %3 : tensor<128x128xi32>
  }
}

// -----

// CHECK-LABEL: @test_bitcast_f32_i32_memref(
// CHECK: hfusion.bitcast
func.func @test_bitcast_f32_i32_memref(
  %src : memref<6xf32>, %dst : memref<6xi32>){
  hfusion.bitcast 
  ins(%src : memref<6xf32>) 
  outs(%dst : memref<6xi32>)
  return
}
