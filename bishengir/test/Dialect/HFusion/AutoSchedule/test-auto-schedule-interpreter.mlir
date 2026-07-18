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

// RUN: bishengir-opt %s --hfusion-auto-schedule-interpreter=kernel-name=foo --verify-diagnostics | FileCheck %s
// RUN: bishengir-opt %s --hfusion-auto-schedule-interpreter="debug-payload-root-tag=foo_payload debug-transform-root-tag=foo_transform" \
// RUN:                  --verify-diagnostics | FileCheck %s

// CHECK: foo
// expected-remark @below {{foo}}
func.func @foo() attributes {transform.target_tag = "foo_payload"} {
  %0 = arith.constant 0 : i32
  return
}

transform.sequence failures(propagate) attributes {transform.target_tag = "foo_transform"} {
  ^bb0(%arg0: !transform.any_op):
    %f = transform.structured.match ops{["func.func"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.debug.emit_remark_at %f, "foo" : !transform.any_op
}
