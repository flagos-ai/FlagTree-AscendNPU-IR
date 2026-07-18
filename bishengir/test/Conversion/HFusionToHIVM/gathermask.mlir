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

// RUN: bishengir-opt -convert-hfusion-to-hivm %s | FileCheck %s
// RUN: bishengir-opt -convert-to-hivm-pipeline %s | FileCheck %s
// CHECK-LABEL:   func.func @test_gathermask(
// CHECK-SAME:                               %[[VAL_0:.*]]: memref<16xf16>,
// CHECK-SAME:                               %[[VAL_1:.*]]: memref<16xi1>) {
// CHECK:           %[[VAL_2:.*]] = memref.alloc() : memref<16xf16>
// CHECK:           %[[VAL_3:.*]] = memref.alloc() : memref<1xi32>
// CHECK:           hivm.hir.vgathermask ins(%[[VAL_0]] : memref<16xf16>) mask(%[[VAL_1]] : memref<16xi1>) outs(%[[VAL_2]], %[[VAL_3]] : memref<16xf16>, memref<1xi32>)
// CHECK:           return
// CHECK:         }

func.func @test_gathermask(%src:memref<16xf16>, %mask:memref<16xi1>) {
  %init_data = memref.alloc() : memref<16xf16>
  %init_size = memref.alloc() : memref<1xi32>
  hfusion.gather_mask ins(%src, %mask : memref<16xf16>, memref<16xi1>) 
                      outs(%init_data, %init_size : memref<16xf16>, memref<1xi32>)
  return
}
