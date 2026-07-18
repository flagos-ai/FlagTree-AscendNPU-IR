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

// RUN: bishengir-opt %s --merge-consecutive-insert-extract-slice --split-input-file --cse --canonicalize-ext | FileCheck %s

// CHECK-LABEL: @test_merge_consecutive_extract_slices_0(
// CHECK-DAG: %[[slice0:.*]] = tensor.extract_slice
// CHECK-DAG: %[[slice1:.*]] = tensor.extract_slice
// CHECK-NOT: tensor.extract_slice
// CHECK: linalg.elemwise_binary {{.*}} ins(%[[slice0]], %[[slice1]]
module {
  func.func @test_merge_consecutive_extract_slices_0(%arg0: tensor<2x15360xbf16>) -> tensor<1x2560xbf16> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hfusion.fusion_kind = #hfusion.fusion_kind<ANY_PBR>} {
    %0 = tensor.empty() : tensor<1x2560xbf16>
    %extracted_slice = tensor.extract_slice %arg0[0, 2560] [2, 2560] [1, 1] : tensor<2x15360xbf16> to tensor<2x2560xbf16>
    %extracted_slice_0 = tensor.extract_slice %extracted_slice[1, 0] [1, 2560] [1, 1] : tensor<2x2560xbf16> to tensor<1x2560xbf16>
    %extracted_slice_1 = tensor.extract_slice %arg0[0, 0] [2, 2560] [1, 1] : tensor<2x15360xbf16> to tensor<2x2560xbf16>
    %extracted_slice_2 = tensor.extract_slice %extracted_slice_1[1, 0] [1, 2560] [1, 1] : tensor<2x2560xbf16> to tensor<1x2560xbf16>
    %1 = linalg.elemwise_binary {fun = #linalg.binary_fn<sub>} ins(%extracted_slice_0, %extracted_slice_2 : tensor<1x2560xbf16>, tensor<1x2560xbf16>) outs(%0 : tensor<1x2560xbf16>) -> tensor<1x2560xbf16>
    return %1 : tensor<1x2560xbf16>
  }
}
