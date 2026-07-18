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

// RUN: bishengir-opt -propagate-reshape -allow-unregistered-dialect %s -split-input-file -verify-diagnostics | FileCheck %s

// CHECK-LABEL: func.func @test_collapsed_reduce
func.func @test_collapsed_reduce(%src: tensor<7x3x5x13xi32>) {
    %collapsed = tensor.collapse_shape %src [[0, 1, 2, 3]] : tensor<7x3x5x13xi32> into tensor<1365xi32>
    %1 = tensor.empty() : tensor<i32>
    // CHECK: %[[RED:.*]]:2 = hfusion.reduce_with_index {tie_break_left = true} <min> ins(%[[COLLAPSED:.*]]: tensor<1365xi32>) outs(%[[VAR:.*]], %[[VAR:.*]] : tensor<i32>, tensor<i32>) dimensions = {{\[}}0] -> tensor<i32>, tensor<i32>
    %2:2 = hfusion.reduce_with_index {tie_break_left = true} <min> ins(%collapsed : tensor<1365xi32>) outs(%1, %1 : tensor<i32>, tensor<i32>) dimensions = [0] -> tensor<i32>, tensor<i32>
    "some_use"(%2#1) : (tensor<i32>) -> ()
    return
}

// CHECK-LABEL: func.func @test_propagated_collapsed_reduce
func.func @test_propagated_collapsed_reduce(%src: memref<7x3x5x13xi32>) {
    %0 = bufferization.to_tensor %src restrict writable : memref<7x3x5x13xi32>
    %collapsed = tensor.collapse_shape %0 [[0, 1, 2, 3]] : tensor<7x3x5x13xi32> into tensor<1365xi32>
    %1 = tensor.empty() : tensor<i32>
    // CHECK: %[[RED:.*]]:2 = hfusion.reduce_with_index {tie_break_left = true} <min> ins(%[[TENSOR:.*]] : tensor<7x3x5x13xi32>) outs(%[[VAR:.*]], %[[VAR:.*]] : tensor<i32>, tensor<i32>) dimensions = {{\[}}0, 1, 2, 3] -> tensor<i32>, tensor<i32>
    %2:2 = hfusion.reduce_with_index {tie_break_left = true} <min> ins(%collapsed : tensor<1365xi32>) outs(%1, %1 : tensor<i32>, tensor<i32>) dimensions = [0] -> tensor<i32>, tensor<i32>
    "some_use"(%2#0) : (tensor<i32>) -> ()
    return
}
