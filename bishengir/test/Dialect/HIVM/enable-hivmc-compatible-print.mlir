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

// RUN: bishengir-opt --enable-hivmc-compatible-print -split-input-file %s | FileCheck %s

// CHECK-LABEL: func.func @test_v_0_0_0(
// CHECK: hivm.hir.fixpipe {enable_nz2nd} ins(%[[VAL_0:.*]] : tensor<8xf16>) outs(%[[VAL_1:.*]] : memref<8xf16>) unit_flag{{\[\[}}#hivm.unit_flag<DISABLED>]]
module attributes {hacc.hivmc_compatible_print = true, hacc.hivmc_version = #hacc.hivmc_version<"0.0.0">} {
  func.func @test_v_0_0_0(%arg0: tensor<8xf16>, %arg1: memref<8xf16>) {
    hivm.hir.fixpipe {dma_mode = #hivm.dma_mode<nz2nd>} ins(%arg0 : tensor<8xf16>) outs(%arg1 : memref<8xf16>) unit_flag_mode([#hivm.unit_flag<DISABLED>])
    return
  }
}

// -----
// CHECK-LABEL: func.func @test_v_0_1_0(
// CHECK: hivm.hir.fixpipe {enable_nz2nd} ins(%[[VAL_0:.*]] : tensor<8xf16>) outs(%[[VAL_1:.*]] : memref<8xf16>) unit_flag{{\[\[}}#hivm.unit_flag<DISABLED>]]
module attributes {hacc.hivmc_compatible_print = true, hacc.hivmc_version = #hacc.hivmc_version<"0.1.0">} {
  func.func @test_v_0_1_0(%arg0: tensor<8xf16>, %arg1: memref<8xf16>) {
    hivm.hir.fixpipe {enable_nz2nd} ins(%arg0 : tensor<8xf16>) outs(%arg1 : memref<8xf16>) unit_flag_mode([#hivm.unit_flag<DISABLED>])
    return
  }
}

// -----
// CHECK-LABEL: func.func @test_v_0_2_0(
// CHECK: hivm.hir.fixpipe {dma_mode = #hivm.dma_mode<nz2nd>} ins(%[[VAL_0:.*]] : tensor<8xf16>) outs(%[[VAL_1:.*]] : memref<8xf16>) unit_flag_mode([#hivm.unit_flag<DISABLED>])
module attributes {hacc.hivmc_compatible_print = true, hacc.hivmc_version = #hacc.hivmc_version<"0.2.0">} {
  func.func @test_v_0_2_0(%arg0: tensor<8xf16>, %arg1: memref<8xf16>) {
    hivm.hir.fixpipe {dma_mode = #hivm.dma_mode<nz2nd>}  ins(%arg0 : tensor<8xf16>) outs(%arg1 : memref<8xf16>) unit_flag_mode([#hivm.unit_flag<DISABLED>])
    return
  }
}
