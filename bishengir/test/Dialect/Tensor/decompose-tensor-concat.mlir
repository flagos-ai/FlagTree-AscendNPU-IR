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

// RUN: bishengir-opt --decompose-tensor-concat %s | FileCheck %s

// CHECK-LABEL: @func
// CHECK: tensor.empty
// CHECK-2: tensor.insert_slice

func.func @func(%arg0: tensor<2560xf32>, %arg1: tensor<2560xf32>) -> tensor<5120xf32> {
    %1 = tensor.concat dim(0) %arg0, %arg1: (tensor<2560xf32>, tensor<2560xf32>) -> tensor<5120xf32>
    func.return %1: tensor<5120xf32>
}
