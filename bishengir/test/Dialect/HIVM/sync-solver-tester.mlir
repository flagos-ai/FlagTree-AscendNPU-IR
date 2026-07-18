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

// REQUIRES: sync-tester

// RUN: bishengir-opt %s -pass-pipeline="builtin.module(func.func(hivm-graph-sync-solver{enable-tester-mode=true sync-tester-options="10,0,5,5,1,1"}))" | FileCheck %s
// RUN: bishengir-opt %s -pass-pipeline="builtin.module(func.func(hivm-graph-sync-solver{enable-tester-mode=true sync-tester-options="10,0,10,5,1,1"}))" | FileCheck %s
// RUN: bishengir-opt %s -pass-pipeline="builtin.module(func.func(hivm-graph-sync-solver{enable-tester-mode=true sync-tester-options="10,0,20,5,1,1"}))" | FileCheck %s
// RUN: bishengir-opt %s -pass-pipeline="builtin.module(func.func(hivm-graph-sync-solver{enable-tester-mode=true sync-tester-options="10,0,20,20,1,1"}))" | FileCheck %s
// RUN: bishengir-opt %s -pass-pipeline="builtin.module(func.func(hivm-graph-sync-solver{enable-tester-mode=true sync-tester-options="10,0,40,5,1,1"}))" | FileCheck %s
// RUN: bishengir-opt %s -pass-pipeline="builtin.module(func.func(hivm-graph-sync-solver{enable-tester-mode=true sync-tester-options="10,0,40,20,1,1"}))" | FileCheck %s
// RUN: bishengir-opt %s -pass-pipeline="builtin.module(func.func(hivm-graph-sync-solver{enable-tester-mode=true sync-tester-options="10,0,50,5,1,1"}))" | FileCheck %s
// RUN: bishengir-opt %s -pass-pipeline="builtin.module(func.func(hivm-graph-sync-solver{enable-tester-mode=true sync-tester-options="10,0,50,20,1,1"}))" | FileCheck %s

// CHECK: succeeded
// CHECK-NOT: failed
module {
  func.func @kernel() {
    return
  }
}
