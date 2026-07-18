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

// UNSUPPORTED: bishengir_published
// RUN: bishengir-compile -enable-lir-compile=false -enable-hfusion-compile=true %s

module {
  func.func @model_21(%arg0: tensor<24x192x192xbf16>) -> tensor<24x192x192xf32> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
    %expanded = tensor.expand_shape %arg0 [[0], [1], [2, 3]] output_shape [24, 192, 1, 192] : tensor<24x192x192xbf16> into tensor<24x192x1x192xbf16>
    %0 = tensor.empty() : tensor<24x192x192x1xbf16>
    %transposed = linalg.transpose ins(%expanded : tensor<24x192x1x192xbf16>) outs(%0 : tensor<24x192x192x1xbf16>) permutation = [0, 1, 3, 2] 
    %collapsed = tensor.collapse_shape %transposed [[0], [1], [2, 3]] : tensor<24x192x192x1xbf16> into tensor<24x192x192xbf16>
    %1 = tensor.empty() : tensor<24x192x192xf32>
    %2 = hfusion.cast {round_mode = #hfusion.round_mode<rint>} ins(%collapsed : tensor<24x192x192xbf16>) outs(%1 : tensor<24x192x192xf32>) -> tensor<24x192x192xf32>
    return %2 : tensor<24x192x192xf32>
  }
}
