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

// RUN: bishengir-compile --help | FileCheck %s

// CHECK-NOT: BiShengIR
// CHECK: OVERVIEW: BiShengIR Compile Tool
// CHECK: OPTIONS:
// CHECK: BiShengIR DFX Control Options:
// CHECK: BiShengIR Feature Control Options:
// CHECK: BiShengIR General Optimization Options:
// CHECK: BiShengIR HFusion Optimization Options:
// CHECK: BiShengIR HIVM Optimization Options:
// CHECK: BiShengIR Target Options:
// CHECK: Options Shared with HIVMC:
// CHECK-NOT: BiShengIR
