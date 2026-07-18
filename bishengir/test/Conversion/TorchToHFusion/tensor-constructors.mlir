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

// RUN: bishengir-opt <%s --split-input-file -convert-torch-to-hfusion | FileCheck %s

// CHECK-LABEL: @torch.arange.start_step(
// CHECK: hfusion.arange
func.func @torch.arange.start_step() -> !torch.vtensor<[10],si32> {
  %none = torch.constant.none
  %int10 = torch.constant.int 10
  %int0 = torch.constant.int 0
  %int1 = torch.constant.int 1
  %int3 = torch.constant.int 3
  %npu3A0 = torch.constant.device "npu:0"
  %0 = torch.aten.arange.start_step %int0, %int10, %int1, %int3, %none, %npu3A0, %none : !torch.int, !torch.int, !torch.int, !torch.int, !torch.none, !torch.Device, !torch.none -> !torch.vtensor<[10],si32>
  return %0 : !torch.vtensor<[10],si32>
}
