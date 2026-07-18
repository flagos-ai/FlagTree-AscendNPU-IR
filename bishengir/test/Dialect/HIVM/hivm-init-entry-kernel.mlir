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

// RUN: bishengir-opt %s --hivm-init-entry-kernel -split-input-file | FileCheck %s

// CHECK-LABEL: func.func @entryKernel
func.func @entryKernel() attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
    // CHECK: hivm.hir.set_mask_norm
    return
}
