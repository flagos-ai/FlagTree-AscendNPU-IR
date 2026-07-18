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

// RUN: bishengir-opt %s --one-shot-bufferize="dialect-filter=tensor,bufferization copy-before-write unknown-type-conversion=identity-layout-map" -cse -split-input-file | FileCheck %s

// CHECK-LABEL: func @tensor.expand_shape(
// CHECK-SAME:     %[[t1:.*]]: tensor<?xf32>,
// CHECK-SAME:     %[[sz0:.*]]: index,
// CHECK-SAME:     %[[sz1:.*]]: index
func.func @tensor.expand_shape(%t1: tensor<?xf32>, %sz0: index, %sz1: index) -> tensor<?x?xf32> {
  // memref.expand_shape %[[t1]] {{\[\[}}0, 1]] output_shape [%[[sz0]], %[[sz1]]] : memref<?xf32> into memref<?x?xf32>
  %0 = tensor.expand_shape %t1 [[0, 1]] output_shape [%sz0, %sz1]
      : tensor<?xf32> into tensor<?x?xf32>
  return %0 : tensor<?x?xf32>
}
