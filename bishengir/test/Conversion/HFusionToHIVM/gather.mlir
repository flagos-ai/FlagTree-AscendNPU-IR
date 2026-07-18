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
// CHECK-LABEL: test_vgather
func.func @test_vgather(%src:tensor<16x16xf16>, %idx:tensor<16x4xi32>) -> tensor<16x4xf16>{
  %init = tensor.empty() : tensor<16x4xf16>
  // CHECK: vgather
  %res = hfusion.gather ins(%src, %idx : tensor<16x16xf16>, tensor<16x4xi32>) outs(%init:tensor<16x4xf16>) axis = 1 -> tensor<16x4xf16>
  return %res : tensor<16x4xf16>
}
