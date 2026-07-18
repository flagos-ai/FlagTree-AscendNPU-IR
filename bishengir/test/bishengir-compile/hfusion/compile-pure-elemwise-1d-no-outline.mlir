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

// REQUIRES: hivmc
// UNSUPPORTED: bishengir_published
// RUN: bishengir-compile -enable-lir-compile=false -enable-hfusion-compile=true -enable-hivm-inject-barrier-all-sync  -block-dim=20 %s -o %t.ll
// RUN: bishengir-compile -enable-lir-compile=false -enable-hfusion-compile=true -block-dim=20 %s -o %t.ll
// RUN: bishengir-compile -enable-lir-compile=false -enable-hfusion-compile=true -hfusion-max-buffer-count-tuning=1 %s -o %t.ll

// RUN: FileCheck --input-file=%t.ll %s

// CHECK: LLVMDialectModule
// CHECK: define dso_local void @add_mul_sub_1d
func.func @add_mul_sub_1d(%arg0: tensor<1024xf32>, %arg1 : tensor<1024xf32>, %arg2 : tensor<1024xf32>, %arg3 : tensor<1024xf32>) -> (tensor<1024xf32>)
attributes {hfusion.fusion_kind = #hfusion.fusion_kind<PURE_ELEMWISE>, hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
  %1 = tensor.empty() : tensor<1024xf32>
  %2 = linalg.elemwise_binary { fun = #linalg.binary_fn<mul> } ins(%arg0, %arg1 : tensor<1024xf32>, tensor<1024xf32>) outs(%1 : tensor<1024xf32>) -> tensor<1024xf32>
  %3 = tensor.empty() : tensor<1024xf32>
  %4 = linalg.elemwise_binary { fun = #linalg.binary_fn<add> } ins(%2, %arg2 : tensor<1024xf32>, tensor<1024xf32>) outs(%3 : tensor<1024xf32>) -> tensor<1024xf32>
  %5 = linalg.elemwise_binary { fun = #linalg.binary_fn<sub> } ins(%2, %4 : tensor<1024xf32>, tensor<1024xf32>) outs(%arg3 : tensor<1024xf32>) -> tensor<1024xf32>
  return %5 : tensor<1024xf32>
}
