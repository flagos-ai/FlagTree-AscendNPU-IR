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

// RUN: bishengir-opt -cv-pipelining -allow-unregistered-dialect %s 2>&1 | FileCheck %s
// Verify cv-pipelining does not crash when a MarkOp lacks hivm.multi_buffer.
// CHECK-LABEL: @test
func.func @test(%arg0: memref<?xi8> {hacc.arg_type = #hacc.arg_type<workspace>}) attributes {WorkspaceArgIdx = 0 : i16, func_dyn_memref_args = dense<[true]> : vector<1xi1>, global_kernel = "local", hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hivm.func_core_type = #hivm.func_core_type<MIX>, mix_mode = "mix"} {
  %c0 = arith.constant 0 : i32
  %bound = "some_op"() : () -> i32
  scf.for %i = %c0 to %bound step %c0 : i32 {
    %ws = memref_ext.alloc_workspace() from %arg0 : from memref<?xi8> to memref<16xf16>
    annotation.mark %ws {hivm.multi_buffer = 2 : i32} : memref<16xf16>
    annotation.mark %ws {unrelated_attr = 0 : i32} : memref<16xf16>
  }
  return
}
