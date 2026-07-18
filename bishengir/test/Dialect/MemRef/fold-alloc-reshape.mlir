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

// RUN: bishengir-opt -fold-alloc-reshape -split-input-file %s | FileCheck %s

// CHECK-LABEL: func @test_single_use
// CHECK-SAME: %[[DIM0:.*]]: index, %[[DIM1:.*]]: index, %[[DIM2:.*]]: index
// CHECK: memref.alloc(%[[DIM1]], %[[DIM2]])
// CHECK-NOT: memref.expand_shape
func.func @test_single_use(%dim0: index, %dim1: index, %dim2: index) {
  %alloc = memref.alloc(%dim0) : memref<?xf32>
  %res = memref.expand_shape %alloc [[0, 1]] output_shape [%dim1, %dim2] : memref<?xf32> into memref<?x?xf32>
  annotation.mark %res : memref<?x?xf32>
  return
}

// -----

// CHECK-LABEL: func @test_multi_use
// CHECK: memref.alloc
// CHECK-SAME: memref<?xf32>
// CHECK: memref.expand_shape
// CHECK: memref.expand_shape
func.func @test_multi_use(%dim0: index, %dim1: index, %dim2: index) {
  %alloc = memref.alloc(%dim0) : memref<?xf32>
  %res0 = memref.expand_shape %alloc [[0, 1]] output_shape [%dim1, %dim2] : memref<?xf32> into memref<?x?xf32>
  %res1 = memref.expand_shape %alloc [[0, 1]] output_shape [%dim2, %dim1] : memref<?xf32> into memref<?x?xf32>
  annotation.mark %res0 : memref<?x?xf32>
  annotation.mark %res1 : memref<?x?xf32>
  return
}
