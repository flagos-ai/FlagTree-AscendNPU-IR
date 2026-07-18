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

// RUN: bishengir-opt %s -split-input-file -verify-diagnostics

// -----

func.func @custom_macro_duplicate_reserved_event(%arg0: memref<4xf32>)
    attributes {hacc.function_kind = #hacc.function_kind<DEVICE>} {
  // expected-error @+1 {{duplicate user-specified sync event id on the same pipe pair}}
  hivm.hir.custom_macro
      {hivm.tcore_type = #hivm.tcore_type<VECTOR>,
       hivm.pipe_in = #hivm.pipe<PIPE_MTE2>,
       hivm.pipe_out = #hivm.pipe<PIPE_V>,
       symbol = "k_dup",
       sync_event_slots = [
         #hivm.sync_event_slot<#hivm.pipe<PIPE_MTE2>, #hivm.pipe<PIPE_MTE1>, wait, <EVENT_ID0>>,
         #hivm.sync_event_slot<#hivm.pipe<PIPE_MTE2>, #hivm.pipe<PIPE_MTE1>, wait, <EVENT_ID0>>
       ]}
      "user.dup"
      ins(%arg0 : memref<4xf32>)
      outs(%arg0 : memref<4xf32>)
  return
}
