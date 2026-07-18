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
// RUN: bishengir-compile -enable-lir-compile=false -enable-hfusion-compile=true -block-dim=20 %s

func.func @single_cube(%arg0: tensor<?x4096xf16>, %arg1: tensor<6144x4096xf16>, %arg2: tensor<?x6144xf16> {hacc.arg_type = #hacc.arg_type<output>, hacc.output_idx = #hacc.output_idx<0>}) -> tensor<?x6144xf16> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hfusion.fusion_kind = #hfusion.fusion_kind<SINGLE_CUBE>} {
  %0 = linalg.matmul_transpose_b ins(%arg0, %arg1 : tensor<?x4096xf16>, tensor<6144x4096xf16>) outs(%arg2 : tensor<?x6144xf16>) -> tensor<?x6144xf16>
  return %0 : tensor<?x6144xf16>
}
