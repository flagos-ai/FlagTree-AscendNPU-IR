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

// RUN: bishengir-opt %s  -split-input-file | FileCheck %s

// CHECK-LABEL: bitcast_tensor
// CHECK: hivm.hir.bitcast
func.func @bitcast_tensor(%arg0 : tensor<2x3xf32>) -> tensor<2x3xi32> {
    %res = hivm.hir.bitcast %arg0 : tensor<2x3xf32> -> tensor<2x3xi32>
    return %res : tensor<2x3xi32> 
}

// -----

// CHECK-LABEL: bitcast_memref
// CHECK: hivm.hir.bitcast
func.func @bitcast_memref(%arg0 : memref<2x3xf32>) -> memref<2x3xi32> {
    %res = hivm.hir.bitcast %arg0 : memref<2x3xf32> -> memref<2x3xi32>
    return %res : memref<2x3xi32>
}
