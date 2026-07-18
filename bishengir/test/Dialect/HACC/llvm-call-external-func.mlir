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

// RUN: bishengir-opt %s | FileCheck %s

// CHECK: external_tiling_function
module attributes {hivm.module_core_type = #hivm.module_core_type<AIV>} {
  // External functions must have external/extern_weak linkage, which conflicts with private; also must be marked as host
  llvm.func @external_tiling_function(%arg0: i64) -> i64 attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.external_function_path = "test.cpp"}
  llvm.func @external_tiling_function2(%arg0: i64) -> i64 attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.external_function_path = "test2.cpp"}
}
