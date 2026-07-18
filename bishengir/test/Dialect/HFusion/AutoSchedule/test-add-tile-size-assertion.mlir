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

//RUN: bishengir-opt --hfusion-auto-schedule %s | FileCheck %s

module {
  func.func @foo(%arg0: tensor<?x?xbf16>) -> tensor<?x?xbf16> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hfusion.fusion_kind = #hfusion.fusion_kind<PURE_ELEMWISE>} {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %0 = tensor.dim %arg0, %c0: tensor<?x?xbf16>
    %1 = tensor.dim %arg0, %c1: tensor<?x?xbf16>
    %empty = tensor.empty(%1, %0) : tensor<?x?xbf16>
    %transposed = linalg.transpose ins(%arg0 : tensor<?x?xbf16>) outs(%empty : tensor<?x?xbf16>) permutation = [1, 0]
    return %transposed : tensor<?x?xbf16>
  }
}

// CHECK-LABEL:   func.func @foo_tiling_function
// CHECK:           cf.assert %{{.+}}, "Buffer size is not enough for the given tiling!"
