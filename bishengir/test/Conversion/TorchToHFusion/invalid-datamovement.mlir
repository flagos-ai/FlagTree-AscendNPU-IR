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

// RUN: bishengir-opt <%s --split-input-file -convert-torch-to-hfusion="ensure-no-implicit-broadcast" | FileCheck %s

// CHECK: broadcast_to_1
// expected-error@below {{unable to perform broadcast operation}}
// expected-error@below {{failed to legalize operation 'torch.aten.broadcast_to' that was explicitly marked illegal}}
func.func @torch.aten.broadcast_to_1() -> !torch.vtensor<[5,6],f32> {
  %0 = torch.vtensor.literal(dense<6.000000e+00> : tensor<f32>) : !torch.vtensor<[],f32>
  %int5 = torch.constant.int 5
  %int6 = torch.constant.int 6
  %1 = torch.prim.ListConstruct %int5, %int6 : (!torch.int, !torch.int) -> !torch.list<int>
  %2 = torch.aten.broadcast_to %0, %1 : !torch.vtensor<[],f32>, !torch.list<int> -> !torch.vtensor<[5,6],f32>
  return %2 : !torch.vtensor<[5,6],f32>
}
