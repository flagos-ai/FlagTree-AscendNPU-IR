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

// RUN: bishengir-opt -transform-interpreter -split-input-file -canonicalize-ext -cse %s | FileCheck %s

func.func @elemwise(%arg0 : memref<?x?xf32>, %arg1 : memref<?x?xf32>,
  %arg2 : memref<?x?xf32>) {
  hfusion.elemwise_binary {fun = #hfusion.binary_fn<maxf>} ins(%arg0, %arg1 : memref<?x?xf32>, memref<?x?xf32>)
      outs(%arg2 : memref<?x?xf32>)
  return
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg1 : !transform.any_op {transform.readonly}) {
    %elemwise = transform.structured.match ops{["hfusion.elemwise_binary"]} in %arg1
      : (!transform.any_op) -> !transform.any_op
    %0 = transform.structured.convert_to_loops %elemwise
      : (!transform.any_op) -> (!transform.any_op)
    transform.yield
  }
}

// CHECK-LABEL: func @elemwise
//  CHECK-SAME:     %[[ARG0:[a-zA-Z0-9]+]]: memref<?x?xf32>
//  CHECK-SAME:     %[[ARG1:[a-zA-Z0-9]+]]: memref<?x?xf32>
//  CHECK-SAME:     %[[ARG2:[a-zA-Z0-9]+]]: memref<?x?xf32>
//   CHECK-DAG:   %[[C0:.+]] = arith.constant 0 : index
//   CHECK-DAG:   %[[C1:.+]] = arith.constant 1 : index
//   CHECK-DAG:   %[[D0:.+]] = memref.dim %[[ARG0]], %[[C0]]
//   CHECK-DAG:   %[[D1:.+]] = memref.dim %[[ARG0]], %[[C1]]
//       CHECK:   scf.for %[[IV0:[a-zA-Z0-9]+]] = %[[C0]] to %[[D0]] step %[[C1]]
//       CHECK:     scf.for %[[IV1:[a-zA-Z0-9]+]] = %[[C0]] to %[[D1]] step %[[C1]]
//   CHECK-DAG:         %[[LHS:.+]] = memref.load %[[ARG0]][%[[IV0]], %[[IV1]]]
//   CHECK-DAG:         %[[RHS:.+]] = memref.load %[[ARG1]][%[[IV0]], %[[IV1]]]
//       CHECK:         %[[MAXF:.+]] = arith.maxnumf %[[LHS]], %[[RHS]]
//       CHECK:         memref.store %[[MAXF]], %[[ARG2]][%[[IV0]], %[[IV1]]]
//   CHECK-NOT:   hfusion.elemwise_binary ins(%arg0, %arg1 : memref<?x?xf32>, memref<?x?xf32>)
