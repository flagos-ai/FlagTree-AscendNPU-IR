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

// RUN: bishengir-opt -convert-tensor-to-hfusion %s -split-input-file -verify-diagnostics | FileCheck %s

// CHECK-LABEL: func.func @test_splat
func.func @test_splat() -> (tensor<2x128x688xf32>, tensor<?x20x?xf32>) {
  // CHECK-NEXT:       %[[CST:.*]] = arith.constant 1.000000e+00 : f32
  %cst = arith.constant 1.000000e+00 : f32
  // CHECK:       %[[EMPTY1:.*]] = tensor.empty() : tensor<2x128x688xf32>
  // CHECK:       %[[FILL1:.*]] = linalg.fill ins(%[[CST]] : f32) outs(%[[EMPTY1]] : tensor<2x128x688xf32>)
  %splat = tensor.splat %cst : tensor<2x128x688xf32>
  // CHECK-NEXT:       %[[M:.*]] = arith.constant 10 : index
  // CHECK-NEXT:       %[[N:.*]] = arith.constant 30 : index
  %m = arith.constant 10 : index
  %n = arith.constant 30 : index
  // CHECK:       %[[EMPTY2:.*]] = tensor.empty(%[[M]], %[[N]]) : tensor<?x20x?xf32>
  // CHECK:       %[[FILL2:.*]] = linalg.fill ins(%[[CST]] : f32) outs(%[[EMPTY2]] : tensor<?x20x?xf32>)
  %dynamic_splat = tensor.splat %cst[%m, %n] : tensor<?x20x?xf32>
  return %splat, %dynamic_splat : tensor<2x128x688xf32>, tensor<?x20x?xf32>
}
