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

// RUN: bishengir-opt %s -hacc-rename-func -allow-unregistered-dialect -verify-diagnostics -split-input-file | FileCheck %s

// CHECK: func.func @foo
func.func @test_standalone_func() attributes {hacc.rename_func = #hacc.rename_func<@foo>} {
  return
}

// -----

// CHECK-NOT: bar
func.func @bar() attributes {hacc.rename_func = #hacc.rename_func<@foo>} {
  return
}

func.func @caller() {
  "some_op"() { callee=@bar } : () -> ()
  func.call @bar() : () -> ()
  return
}

// -----

// expected-error@below {{failed to rename function to @foo because there is already a function with the same name!}}
func.func @bar() attributes {hacc.rename_func = #hacc.rename_func<@foo>} {
  return
}

func.func @foo() {
  return
}
