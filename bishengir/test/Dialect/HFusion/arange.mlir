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

// RUN: bishengir-opt %s | bishengir-opt | FileCheck %s
// RUN: bishengir-opt %s -mlir-print-op-generic | FileCheck %s --check-prefix=GENERIC
// Currently only a roundtrip verifier
func.func @test_arange_tensor(%in : tensor<16x16x16xi32>, %offset : index, %s0:index, %s1:index, %s2:index) {
  // CHECK: hfusion.arange
  // CHECK-SAME: offset
  // CHECK-SAME: strides
  // CHECK-SAME: -> tensor<16x16x16xi32>
  // GENERIC-DAG: "linalg.index"() <{dim = 0
  // GENERIC-DAG: "linalg.index"() <{dim = 1
  // GENERIC-DAG: "linalg.index"() <{dim = 2
  // GENERIC: arith.index_cast
  // GENERIC-SAME: (index) -> i32
  %with_offset = hfusion.arange offset[%offset] strides[%s0,%s1,%s2] outs(%in: tensor<16x16x16xi32>) -> tensor<16x16x16xi32>
  // CHECK: hfusion.arange
  // CHECK-SAME: strides
  // CHECK-SAME: -> tensor<16x16x16xi32>
  %no_offset = hfusion.arange offset[%offset] strides[%s0,%s1,%s2] outs(%with_offset: tensor<16x16x16xi32>) -> tensor<16x16x16xi32>
  return
}

func.func @test_arange_memref(%in : memref<16x16xi32>, %offset : index, %s0:index, %s1:index) {
  // CHECK: hfusion.arange
  // CHECK-SAME: offset
  // CHECK-SAME: strides
  hfusion.arange offset[%offset] strides[%s0,%s1] outs(%in: memref<16x16xi32>)
  // CHECK: hfusion.arange
  // CHECK-SAME: strides
  hfusion.arange offset[%offset] strides[%s0,%s1] outs(%in: memref<16x16xi32>)
  return
}
