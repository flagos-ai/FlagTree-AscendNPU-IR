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

// Currently only a roundtrip verifier
func.func @test_arange_tensor(%in : tensor<16x16x16xi32>, %offset : index, %s0:index, %s1:index, %s2:index) {
  // CHECK: hivm.hir.varange
  // CHECK-SAME: offset
  // CHECK-SAME: strides
  // CHECK-SAME: -> tensor<16x16x16xi32>
  %with_offset = hivm.hir.varange offset[%offset] strides[%s0,%s1,%s2] outs(%in: tensor<16x16x16xi32>) -> tensor<16x16x16xi32>
  // CHECK: hivm.hir.varange
  // CHECK-SAME: strides
  // CHECK-SAME: -> tensor<16x16x16xi32>
  %no_offset = hivm.hir.varange strides[%s0,%s1,%s2] outs(%with_offset: tensor<16x16x16xi32>) -> tensor<16x16x16xi32>
  return
}
