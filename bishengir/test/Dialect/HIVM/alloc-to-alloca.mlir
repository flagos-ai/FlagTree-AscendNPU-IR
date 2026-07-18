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

// RUN: bishengir-opt --hivm-memref-alloc-to-alloca -split-input-file %s | FileCheck %s

// Alloc to Alloca.
// CHECK-LABEL: func @test_hivm_memory_scope_l1
// CHECK:         %[[M:.*]] = memref.alloca() : memref<32x32xi32, #hivm.address_space<cbuf>>
// CHECK-NEXT:    return %[[M]] : memref<32x32xi32, #hivm.address_space<cbuf>>
func.func @test_hivm_memory_scope_l1() -> memref<32x32xi32, #hivm.address_space<cbuf>> {
    %m = memref.alloc() : memref<32x32xi32, #hivm.address_space<cbuf>>
    return %m : memref<32x32xi32, #hivm.address_space<cbuf>>
}

// -----

// No conversions.
// CHECK-LABEL: func @test_hivm_memory_scope_gm
// CHECK:         %[[M:.*]] = memref.alloc() : memref<32x32xi32, #hivm.address_space<gm>>
// CHECK-NEXT:    return %[[M]] : memref<32x32xi32, #hivm.address_space<gm>>
func.func @test_hivm_memory_scope_gm() -> memref<32x32xi32, #hivm.address_space<gm>> {
    %m = memref.alloc() : memref<32x32xi32, #hivm.address_space<gm>>
    return %m : memref<32x32xi32, #hivm.address_space<gm>>
}

// -----

// No conversions.
// CHECK-LABEL: func @test_other_memory_scope
// CHECK:         %[[M:.*]] = memref.alloc() : memref<32x32xi32, 6>
// CHECK-NEXT:    return %[[M]] : memref<32x32xi32, 6>
func.func @test_other_memory_scope() -> memref<32x32xi32, 6> {
    %m = memref.alloc() : memref<32x32xi32, 6>
    return %m : memref<32x32xi32, 6>
}

// -----

// No conversions.
// CHECK-LABEL: func @test_no_memory_scope
// CHECK:         %[[M:.*]] = memref.alloc() : memref<32x32xi32>
// CHECK-NEXT:    return %[[M]] : memref<32x32xi32>
func.func @test_no_memory_scope() -> memref<32x32xi32> {
    %m = memref.alloc() : memref<32x32xi32>
    return %m : memref<32x32xi32>
}
