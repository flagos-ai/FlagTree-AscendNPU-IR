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

// RUN: bishengir-opt %s -split-input-file | FileCheck %s

// CHECK-LABEL: func.func @test_load_store
// CHECK: hfusion.load
// CHECK: hfusion.store
func.func @test_load_store(%arg: tensor<f32>) -> tensor<f32> {
  %0 = tensor.empty() : tensor<f32>
  %1 = tensor.empty() : tensor<f32>
  %2 = hfusion.load ins(%arg: tensor<f32>) outs(%0: tensor<f32>) -> tensor<f32>
  %3 = hfusion.store ins(%2: tensor<f32>) outs(%1: tensor<f32>) -> tensor<f32>
  return %3 : tensor<f32>
}

// -----

// CHECK-LABEL: func.func @test_memref_load_store
// CHECK: hfusion.load
// CHECK: hfusion.store
func.func @test_memref_load_store(%arg0: memref<f32>, %arg1: memref<f32>) {
  hfusion.load ins(%arg0: memref<f32>) outs(%arg1: memref<f32>)
  hfusion.store ins(%arg0: memref<f32>) outs(%arg1: memref<f32>)
  return
}
