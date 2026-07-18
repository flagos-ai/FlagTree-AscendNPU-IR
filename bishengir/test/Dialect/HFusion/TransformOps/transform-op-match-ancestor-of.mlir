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

// RUN: bishengir-opt -transform-interpreter -verify-diagnostics %s | FileCheck %s

module attributes { transform.with_named_sequence } {
  // CHECK-LABEL: match_ancestor_of
  // CHECK: linalg.elemwise_unary {__ancestor__, __result__}
  // CHECK: scf
  // CHECK: linalg.elemwise_unary {__ancestor__}
  func.func @match_ancestor_of(%arg0: tensor<?xf32>, %dim : index) -> (tensor<?xf32>, tensor<?xf32>) {
    %empty = tensor.empty(%dim) : tensor<?xf32>
    %0 = linalg.elemwise_unary {__ancestor__} ins(%arg0: tensor<?xf32>) outs(%empty : tensor<?xf32>) -> tensor<?xf32>
    %1 = linalg.elemwise_unary {__child_a__} ins(%0: tensor<?xf32>) outs(%empty : tensor<?xf32>) -> tensor<?xf32>
    %2 = linalg.elemwise_unary {__child_b__} ins(%0: tensor<?xf32>) outs(%empty : tensor<?xf32>) -> tensor<?xf32>
    func.return %1, %2 : tensor<?xf32>, tensor<?xf32>
  }

  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %0 = transform.structured.match attributes {__child_a__} in %arg0 : (!transform.any_op) -> !transform.any_op
    %tiled_linalg_op, %loops = transform.structured.tile_using_for %0 tile_sizes [16] : (!transform.any_op) -> (!transform.any_op, !transform.any_op)
    %1 = transform.structured.match attributes {__ancestor__} in %arg0 : (!transform.any_op) -> !transform.any_op
    %fused_op, %new_containing_op = transform.structured.extended_fuse_into_containing_op %1 into %loops {duplicate_producer = true} : (!transform.any_op, !transform.any_op) -> (!transform.any_op, !transform.any_op)
    %2 = transform.structured.match attributes {__child_b__} in %arg0 : (!transform.any_op) -> !transform.any_op
    %3 = transform.structured.match.ancestor_of attributes {__ancestor__} in %arg0 ancestor of %2 : (!transform.any_op, !transform.any_op) -> !transform.any_op
    transform.annotate %3 "__result__" : !transform.any_op
    transform.yield
  }
}
