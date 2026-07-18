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

// RUN: not bishengir-target-spec-tblgen -gen-target-spec-decls %s 2>&1 | FileCheck %s --check-prefix=DECL
// RUN: not bishengir-target-spec-tblgen -gen-target-spec-defs %s 2>&1 | FileCheck %s --check-prefix=DEF

class TargetSpec <string name> {
  string Name = name;
  // DEF: Unsupported spec type: dag
  // DECL: Unsupported spec type to map to c++ type: dag
  dag dagSpec = ?;
}

def X1;

def Spec : TargetSpec<"Unsupported"> {
  let dagSpec = (X1 "Test");
}
