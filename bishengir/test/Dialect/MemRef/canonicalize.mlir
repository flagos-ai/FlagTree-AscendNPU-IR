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

// RUN: bishengir-opt %s --canonicalize-ext -split-input-file | FileCheck %s

// CHECK-LABEL: func @reinterpret_constant_arg_folder_unranked_memref
func.func @reinterpret_constant_arg_folder_unranked_memref(%arg0 : memref<*xf16>) -> memref<?xf16, strided<[?], offset: ?>> {
  %offset = arith.constant 0 : index
  %size = arith.constant 1024 : index
  %stride = arith.constant 1 : index
  // CHECK: memref.reinterpret_cast %arg0 to offset: [0], sizes: [1024], strides: [1] : memref<*xf16> to memref<1024xf16, strided<[1]>>
  %reinterpret_cast = memref.reinterpret_cast %arg0 to offset: [%offset], sizes: [%size], strides: [%stride] : memref<*xf16> to memref<?xf16, strided<[?], offset: ?>>
  return %reinterpret_cast : memref<?xf16, strided<[?], offset: ?>>
}

// -----

// CHECK-LABEL: func @reinterpret_constant_arg_folder_memref
func.func @reinterpret_constant_arg_folder_memref(%arg0 : memref<?xf16>) -> memref<?xf16, strided<[?], offset: ?>> {
  %offset = arith.constant 0 : index
  %size = arith.constant 1024 : index
  %stride = arith.constant 1 : index
  // CHECK: memref.reinterpret_cast %arg0 to offset: [0], sizes: [1024], strides: [1] : memref<?xf16> to memref<1024xf16, strided<[1]>>
  %reinterpret_cast = memref.reinterpret_cast %arg0 to offset: [%offset], sizes: [%size], strides: [%stride] : memref<?xf16> to memref<?xf16, strided<[?], offset: ?>>
  return %reinterpret_cast : memref<?xf16, strided<[?], offset: ?>>
}
