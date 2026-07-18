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

// RUN: bishengir-opt %s  | FileCheck %s

// -----
module {
  func.func @matmul_gelu(%arg0: tensor<128x4096xf16>,
                         %arg1: tensor<4096x4096xf16>,
                         %arg2: tensor<128x4096xf16>,
                         %arg3: memref<16xi64>) -> tensor<128x4096xf16>
                          {
    %0 = hivm.hir.matmul ins(%arg0, %arg1 : tensor<128x4096xf16>, tensor<4096x4096xf16>)
                         outs(%arg2 : tensor<128x4096xf16>) -> tensor<128x4096xf16>
    // CHECK: annotation.mark
    annotation.mark %0 keys = ["tiling_params"] values = [%arg3: memref<16xi64>] : tensor<128x4096xf16>
    return %0 : tensor<128x4096xf16>
  }
}
