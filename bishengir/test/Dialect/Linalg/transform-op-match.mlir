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

// RUN: bishengir-opt -transform-interpreter -verify-diagnostics -allow-unregistered-dialect -split-input-file %s

// CHECK: foo
module attributes {transform.with_named_sequence} {
  func.func @foo() {
    // expected-remark @below {{0}}
    "some_op"() {__0__} : () -> ()
    "some_op"() {__1__} : () -> ()
    return
  }
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %0 = transform.structured.match attributes{__0__} optional_attributes{} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.debug.emit_remark_at %0, "0" : !transform.any_op
    transform.yield
  }
}

// -----

// CHECK: foo
module attributes {transform.with_named_sequence} {
  func.func @foo() {
    // expected-remark @below {{0 or 1}}
    "some_op"() {__0__} : () -> ()
    // expected-remark @below {{0 or 1}}
    "some_op"() {__1__} : () -> ()
    return
  }
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %0 = transform.structured.match optional_attributes {__0__, __1__} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.debug.emit_remark_at %0, "0 or 1" : !transform.any_op
    transform.yield
  }
}

// -----

// CHECK-NOT: remark: 0 and 1
module attributes {transform.with_named_sequence} {
  func.func @foo() {
    "some_op"() {__0__} : () -> ()
    "some_op"() {__1__} : () -> ()
    return
  }
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %0 = transform.structured.match attributes {__0__, __1__} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.debug.emit_remark_at %0, "0 and 1" : !transform.any_op
    transform.yield
  }
}
