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

// RUN: bishengir-opt -hfusion-eliminate-duplicate-funcs %s -split-input-file -verify-diagnostics | FileCheck %s

// CHECK: func.func @main_single_outlined_0_0
// CHECK-NOT: func.func @main_single_outlined_15_0
// CHECK: func.func @main
// CHECK: func.func @main_single_outlined_0_0_outs_infershape_func
// CHECK-NOT: func.func @main_single_outlined_15_0_outs_infershape_func
module {  
  func.func @main_single_outlined_0_0(%arg0: tensor<256x4096xf16>) -> tensor<256x4096xf32> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hacc.infer_output_shape_function = #hacc.infer_output_shape_function<@main_single_outlined_0_0_outs_infershape_func>, hfusion.fusion_kind = #hfusion.fusion_kind<PURE_ELEMWISE>} {
    %0 = tensor.empty() : tensor<256x4096xf32>
    %1 = hfusion.cast {round_mode = #hfusion.round_mode<rint>} ins(%arg0 : tensor<256x4096xf16>) outs(%0 : tensor<256x4096xf32>) -> tensor<256x4096xf32>
    return %1 : tensor<256x4096xf32>
  }
  func.func @main_single_outlined_15_0(%arg0: tensor<256x4096xf16>) -> tensor<256x4096xf32> attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>, hacc.infer_output_shape_function = #hacc.infer_output_shape_function<@main_single_outlined_15_0_outs_infershape_func>, hfusion.fusion_kind = #hfusion.fusion_kind<PURE_ELEMWISE>} {
    %0 = tensor.empty() : tensor<256x4096xf32>
    %1 = hfusion.cast {round_mode = #hfusion.round_mode<rint>} ins(%arg0 : tensor<256x4096xf16>) outs(%0 : tensor<256x4096xf32>) -> tensor<256x4096xf32>
    return %1 : tensor<256x4096xf32>
  }
  func.func @main(%arg0 : tensor<256x4096xf16>) -> tensor<256x4096xf32> attributes {Graph = true, hacc.function_kind = #hacc.function_kind<HOST>} {
    %0 = call @main_single_outlined_0_0(%arg0) : (tensor<256x4096xf16>) -> tensor<256x4096xf32>
    %1 = call @main_single_outlined_15_0(%arg0) : (tensor<256x4096xf16>) -> tensor<256x4096xf32>
    return %1 : tensor<256x4096xf32>
  }
  func.func @main_single_outlined_0_0_outs_infershape_func(%arg0: tensor<256x4096xf16>) -> tensor<2xindex> attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.host_func_type = #hacc.host_func_type<infer_output_shape_function>, hfusion.fusion_kind = #hfusion.fusion_kind<PURE_ELEMWISE>} {
    %cst = arith.constant dense<[256, 4096]> : tensor<2xindex>
    return %cst : tensor<2xindex>
  }
  func.func @main_single_outlined_15_0_outs_infershape_func(%arg0: tensor<256x4096xf16>) -> tensor<2xindex> attributes {hacc.function_kind = #hacc.function_kind<HOST>, hacc.host_func_type = #hacc.host_func_type<infer_output_shape_function>, hfusion.fusion_kind = #hfusion.fusion_kind<PURE_ELEMWISE>} {
    %cst = arith.constant dense<[256, 4096]> : tensor<2xindex>
    return %cst : tensor<2xindex>
  }
}

// -----
// CHECK: func.func @foo
// CHECK-NOT: func.func @bar
// CHECK: func.func @main
// CHECK: call @foo
// CHECK-NOT: call @bar
module {
  func.func @foo(%arg0 : tensor<256x4096xf16>) -> tensor<256x4096xf32> attributes {Graph = true, hacc.function_kind = #hacc.function_kind<HOST>} {
    %0 = tensor.empty() : tensor<256x4096xf32>
    %1 = hfusion.cast {round_mode = #hfusion.round_mode<rint>} ins(%arg0 : tensor<256x4096xf16>) outs(%0 : tensor<256x4096xf32>) -> tensor<256x4096xf32>
    return %1 : tensor<256x4096xf32>
  }
  func.func @bar(%arg0 : tensor<256x4096xf16>) -> tensor<256x4096xf32> attributes {Graph = true, hacc.function_kind = #hacc.function_kind<HOST>} {
    %0 = tensor.empty() : tensor<256x4096xf32>
    %1 = hfusion.cast {round_mode = #hfusion.round_mode<rint>} ins(%arg0 : tensor<256x4096xf16>) outs(%0 : tensor<256x4096xf32>) -> tensor<256x4096xf32>
    return %1 : tensor<256x4096xf32>
  }
  func.func @main(%arg0 : tensor<256x4096xf16>) -> tensor<256x4096xf32> attributes {Graph = true, hacc.function_kind = #hacc.function_kind<HOST>} {
    %0 = call @foo(%arg0) : (tensor<256x4096xf16>) -> tensor<256x4096xf32>
    %1 = call @bar(%arg0) : (tensor<256x4096xf16>) -> tensor<256x4096xf32>
    return %1 : tensor<256x4096xf32>
  }
}
