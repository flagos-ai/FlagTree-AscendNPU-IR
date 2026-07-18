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

// RUN: bishengir-opt %s --hivm-insert-infer-task-type-func -split-input-file -verify-diagnostics | FileCheck %s

module {
  // CHECK: func.func @F1_infer_task_type_function() -> i8
  // CHECK: %[[TASK_TYPE:.*]] = arith.constant 10 : i8
  // CHECK: return %[[TASK_TYPE]]
  func.func @F1() attributes {hacc.entry, hivm.func_core_type = #hivm.func_core_type<AIV>} {
    return
  }
}

// -----

module {
  // CHECK: func.func @F2_infer_task_type_function() -> i8
  // CHECK: %[[TASK_TYPE:.*]] = arith.constant 20 : i8
  // CHECK: return %[[TASK_TYPE]]
  func.func @F2() attributes {hacc.entry, hivm.func_core_type = #hivm.func_core_type<AIC>} {
    return
  }
}

// -----

module {
  // CHECK: func.func @F3_infer_task_type_function() -> i8
  // CHECK: %[[TASK_TYPE:.*]] = arith.constant 32 : i8
  // CHECK: return %[[TASK_TYPE]]
  func.func @F3() attributes {hacc.entry, hivm.func_core_type = #hivm.func_core_type<MIX>} {
    return
  }
}
