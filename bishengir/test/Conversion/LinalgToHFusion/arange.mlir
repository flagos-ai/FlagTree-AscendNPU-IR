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

// RUN: bishengir-opt -convert-linalg-to-hfusion %s -split-input-file -verify-diagnostics | FileCheck %s

#map = affine_map<(d0) -> (d0)>
// CHECK-LABEL: func.func @test_arange
// CHECK-SAME:    (%[[ARG:.*]]: tensor<6xi32>) -> tensor<6xi32> {
func.func @test_arange(%arg0 : tensor<6xi32>) -> tensor<6xi32> {
  // CHECK-NEXT: %[[CONST1:.*]] = arith.constant 1 : index
  // CHECK-NEXT: %[[CONST0:.*]] = arith.constant 0 : index
  // CHECK-NEXT: %[[RET:.*]] = hfusion.arange offset[%[[CONST0]]] strides[%[[CONST1]]] outs(%[[ARG]] : tensor<6xi32>) -> tensor<6xi32>
  %ret = linalg.generic {indexing_maps = [#map], iterator_types = ["parallel"]} outs(%arg0 : tensor<6xi32>) {
    ^bb0(%out: i32):
      %0 = linalg.index 0 : index
      %1 = arith.index_cast %0 : index to i32
      linalg.yield %1 : i32
    } -> (tensor<6xi32>)
  return %ret : tensor<6xi32>
}
