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

// RUN: bishengir-opt -canonicalize-ext -allow-unregistered-dialect -split-input-file %s | FileCheck %s

// CHECK-LABEL: test_fold
// CHECK: %[[S1:.*]] = symbol.symbolic_int @[[S1]]
// CHECK: "some_op"(%[[S1]])
func.func @test_fold(%arg0: i64) {
  %0 = arith.index_cast %arg0 : i64 to index
  %S1 = symbol.symbolic_int @S1 [%0], affine_map<()[s0] -> (s0 + 1)> {max_val = 11 : i64, min_val = 1 : i64} : index
  %S2 = symbol.symbolic_int @S2 [%S1], affine_map<()[s0] -> (s0)> {max_val = 11 : i64, min_val = 1 : i64} : index
  %some_value = "some_op"(%S2) : (index) -> tensor<?x16xf32>
  return
}

// -----

// CHECK-LABEL: test_not_fold
// CHECK: %[[S1:.*]] = symbol.symbolic_int @[[S1]]
// CHECK: %[[S2:.*]] = symbol.symbolic_int @[[S2]]
// CHECK: "some_op"(%[[S2]])
func.func @test_not_fold(%arg0: i64) {
  %0 = arith.index_cast %arg0 : i64 to index
  %S1 = symbol.symbolic_int @S1 [%0], affine_map<()[s0] -> (s0 + 1)> {max_val = 11 : i64, min_val = 1 : i64} : index
  %S2 = symbol.symbolic_int @S2 [%S1], affine_map<()[s0] -> (s0 * 2)> {max_val = 11 : i64, min_val = 1 : i64} : index
  %some_value = "some_op"(%S2) : (index) -> tensor<?x16xf32>
  return
}
