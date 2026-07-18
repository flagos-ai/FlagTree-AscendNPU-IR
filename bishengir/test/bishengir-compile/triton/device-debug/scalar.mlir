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

// REQUIRES: hivmc
// UNSUPPORTED: bishengir_published
// RUN: bishengir-compile --enable-lir-compile=false --enable-auto-multi-buffer=true --enable-hfusion-compile=true --enable-hivm-compile=true --enable-triton-kernel-compile=true %s -o %t.ll
// RUN: FileCheck --input-file=%t.ll %s

// CHECK-DAG: @_debug_prefix_0
// CHECK-DAG: @_debug_prefix_1
// CHECK-DAG: @_debug_prefix_2
// CHECK-DAG: declare extern_weak dso_local void @_mlir_ciface_init_debug
// CHECK-DAG: declare extern_weak dso_local void @_mlir_ciface_print_scalar_int32_t_gm
// CHECK-DAG: declare extern_weak dso_local void @_mlir_ciface_finish_debug
// CHECK-DAG: define dso_local void @scalar_twice_kernel(
module {
  func.func private @triton_print_0(i32) attributes {hex = false, prefix = " hello (1): "}
  func.func private @triton_print_1(i32, i32) attributes {hex = false, prefix = " hello (2 & 3): "}
  func.func @scalar_twice_kernel(%arg0: memref<?xi8>, %arg1: memref<?xf32> {tt.divisibility = 16 : i32}, %arg2: i32, %arg3: i32, %arg4: i32, %arg5: i32, %arg6: i32, %arg7: i32) attributes {WorkspaceArgIdx = 0 : i64, global_kernel = "local", mix_mode = "aiv"} {
    %c3_i32 = arith.constant 3 : i32
    %c2_i32 = arith.constant 2 : i32
    %c1_i32 = arith.constant 1 : i32
    call @triton_print_0(%c1_i32) : (i32) -> ()
    call @triton_print_1(%c2_i32, %c3_i32) : (i32, i32) -> ()
    return
  }
}
