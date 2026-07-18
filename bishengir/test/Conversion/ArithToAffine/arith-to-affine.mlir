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

// RUN: bishengir-opt -convert-arith-to-affine %s -split-input-file | FileCheck %s

// CHECK: affine_map<()[s0, s1] -> (s0 + s1)>
// CHECK-NOT: arith.addi
func.func @test_addi(%arg0 : index, %arg1 : index) -> index {
  %ret = arith.addi %arg0, %arg1 : index
  return %ret : index
}

// -----

// CHECK: affine_map<()[s0, s1] -> (s0 - s1)>
// CHECK-NOT: arith.subi
func.func @test_subi(%arg0 : index, %arg1 : index) -> index {
  %ret = arith.subi %arg0, %arg1 : index
  return %ret : index
}

// -----

// CHECK: affine_map<()[s0, s1] -> (s0 * s1)>
// CHECK-NOT: arith.muli
func.func @test_muli(%arg0 : index, %arg1 : index) -> index {
  %ret = arith.muli %arg0, %arg1 : index
  return %ret : index
}

// -----

// CHECK: affine_map<()[s0, s1] -> (s0 ceildiv s1)>
// CHECK-NOT: arith.ceildivsi
func.func @test_ceildivsi(%arg0 : index, %arg1 : index) -> index {
  %ret = arith.ceildivsi %arg0, %arg1 : index
  return %ret : index
}

// -----

// CHECK: affine_map<()[s0, s1] -> (s0 floordiv s1)>
// CHECK-NOT: arith.divsi
func.func @test_divsi(%arg0 : index, %arg1 : index) -> index {
  %ret = arith.divsi %arg0, %arg1 : index
  return %ret : index
}

// -----

// CHECK: affine_map<()[s0, s1] -> (s0 mod s1)>
// CHECK-NOT: arith.remsi
func.func @test_remsi(%arg0 : index, %arg1 : index) -> index {
  %ret = arith.remsi %arg0, %arg1 : index
  return %ret : index
}

// -----

// CHECK: affine_map<()[s0, s1] -> (s0, s1)>
// CHECK-NOT: arith.maxsi
func.func @test_maxsi(%arg0 : index, %arg1 : index) -> index {
  // CHECK: affine.max
  %ret = arith.maxsi %arg0, %arg1 : index
  return %ret : index
}

// -----

// CHECK: affine_map<()[s0, s1] -> (s0, s1)>
// CHECK-NOT: arith.maxui
func.func @test_maxui(%arg0 : index, %arg1 : index) -> index {
  // CHECK: affine.max
  %ret = arith.maxui %arg0, %arg1 : index
  return %ret : index
}

// -----

// CHECK: affine_map<()[s0, s1] -> (s0, s1)>
// CHECK-NOT: arith.minsi
func.func @test_minsi(%arg0 : index, %arg1 : index) -> index {
  // CHECK: affine.min
  %ret = arith.minsi %arg0, %arg1 : index
  return %ret : index
}

// -----

// CHECK: affine_map<()[s0, s1] -> (s0, s1)>
// CHECK-NOT: arith.minui
func.func @test_minui(%arg0 : index, %arg1 : index) -> index {
  // CHECK: affine.min
  %ret = arith.minui %arg0, %arg1 : index
  return %ret : index
}
