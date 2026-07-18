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

// RUN: bishengir-opt %s --hacc-append-device-spec=target=Ascend910B1 -split-input-file | FileCheck --check-prefix=910B1 %s
// RUN: bishengir-opt %s --hacc-append-device-spec -split-input-file | FileCheck --check-prefix=UNKNOWN %s


// 910B1: dlti.target_system_spec = #dlti.target_system_spec<"NPU"
// 910B1-SAME: "VECTOR_CORE_COUNT", 48
// 910B1-SAME: "UB_SIZE", 1572864
// 910B1-SAME: "L0C_SIZE", 1048576
module {

}

// -----

// expected-warning@+1 {{Overwriting the target by the pass option...}}
module attributes {hacc.target = #hacc.target<"Ascend910B4">} {

}

// -----

// expected-warning@+1 {{Overwriting the device spec...}}
module attributes {
  dlti.target_system_spec = #dlti.target_system_spec<"NPU" :
    #hacc.target_device_spec<
      #dlti.dl_entry<"AI_CORE_COUNT", 24 : i32>
    >
  >} {

}

// -----

// UNKNOWN: dlti.target_system_spec = #dlti.target_system_spec<"NPU"
module attributes {hacc.target = #hacc.target<"Ascend910B4">} {

}
