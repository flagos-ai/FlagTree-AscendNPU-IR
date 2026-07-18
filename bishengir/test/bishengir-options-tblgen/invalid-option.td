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

// RUN: not bishengir-options-tblgen -gen-compile-configs %s -I %p/../../include/ 2>&1 | FileCheck %s --check-prefix=COMPILE-CONFIGS

include "bishengir/Tools/ConfigOptions/Options.td"

// COMPILE-CONFIGS: Unknown config name
def Foo : Option {
  let description = "Foooooo.";
  let type = "int64_t";
  let defaultValue = "1";
}
