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

// RUN: bishengir-opt -test-function-call -split-input-file -verify-diagnostics %s | FileCheck %s
func.func @test(%A: tensor<?x4096xf16>, %B: tensor<14336x4096xf16>, %C: tensor<?x14336xf16>,  %D: memref<12xi64>) -> () {
// CHECK: call @extern_callee({{.*}},{{.*}}, {{.*}}, {{.*}}) : (tensor<?x4096xf16>, tensor<14336x4096xf16>, tensor<?x14336xf16>, memref<12xi64>) -> ()
  return
}

func.func @callee(%A: tensor<?x4096xf16>, %B: tensor<14336x4096xf16>, %C: tensor<?x14336xf16>,  %D: memref<12xi64>) -> () {
  return 
}
