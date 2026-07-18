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
// RUN: bishengir-compile %s -enable-lir-compile=false -enable-hfusion-compile=true -enable-torch-compile=true

func.func @torch.aten.mul_tensor(%arg0: !torch.vtensor<[4096],f16>, %arg1: !torch.vtensor<[1,56,4096],f16>) -> !torch.vtensor<[1,56,4096],f16> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
  %0 = torch.aten.mul.Tensor %arg0, %arg1 : !torch.vtensor<[4096],f16>, !torch.vtensor<[1,56,4096],f16> -> !torch.vtensor<[1,56,4096],f16>
  return %0 : !torch.vtensor<[1,56,4096],f16>
}
