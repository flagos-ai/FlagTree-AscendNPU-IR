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

// RUN: bishengir-opt -hivm-auto-infer-buffer-size -split-input-file %s | FileCheck %s

// CHECK-LABEL: @test_auto_infer_buffer_size
func.func @test_auto_infer_buffer_size(%arg0: index) attributes {enable_auto_mark_buffer_size} {
  // CHECK: %[[ALLOC_0:.*]] = memref.alloc(%arg0) {alignment = 64 : i64} : memref<1x1x?xf32, #hivm.address_space<ub>>
  // CHECK: %[[ALLOC_1:.*]] = memref.alloc(%arg0) {alignment = 64 : i64} : memref<1x1x?xf32, #hivm.address_space<ub>>
  %alloc_0 = memref.alloc(%arg0) {alignment = 64 : i64} : memref<1x1x?xf32, #hivm.address_space<ub>>
  %alloc_1 = memref.alloc(%arg0) {alignment = 64 : i64} : memref<1x1x?xf32, #hivm.address_space<ub>>
  // CHECK: annotation.mark %[[ALLOC_1]] {buffer_size_in_byte = 21824 : i64} : memref<1x1x?xf32, #hivm.address_space<ub>>
  // CHECK: annotation.mark %[[ALLOC_0]] {buffer_size_in_byte = 21824 : i64} : memref<1x1x?xf32, #hivm.address_space<ub>>
  annotation.mark %alloc_0 {buffer_size_in_byte = 21824 : i64} : memref<1x1x?xf32, #hivm.address_space<ub>>
  return
}
