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
// RUN: bishengir-compile --enable-lir-compile=false --enable-hfusion-compile=true --enable-hivm-compile=true %s
module {
  func.func @concat_compile(%arg0: tensor<3x256x12288xi64>, %arg1: tensor<3x256x1024xi64>) -> tensor<3x256x13312xi64> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
    %concat = tensor.concat dim(2) %arg0, %arg1 : (tensor<3x256x12288xi64>, tensor<3x256x1024xi64>) -> tensor<3x256x13312xi64>
    return %concat : tensor<3x256x13312xi64>
  }
}
