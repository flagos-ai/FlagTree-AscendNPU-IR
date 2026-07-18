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

// Test that --save-temps=. produces module.hivm.opt.mlir in the current directory.
//
// RUN: bishengir-compile --save-temps=. %s -o %t.o
// RUN: test -f module.hivm.opt.mlir
// RUN: FileCheck --input-file=module.hivm.opt.mlir %s

// CHECK: module
// CHECK: func.func
func.func @test_func() {
  return
}
