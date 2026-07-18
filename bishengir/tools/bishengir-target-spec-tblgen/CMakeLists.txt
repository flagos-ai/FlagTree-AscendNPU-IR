# Copyright 2026 FlagOS Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set(LLVM_LINK_COMPONENTS
  CodeGenTypes
  Demangle
  Support
  TableGen
)

add_tablegen(bishengir-target-spec-tblgen BISHENGIR_TARGET_SPEC
  bishengir-target-spec-tblgen.cpp
  TargetSpecGen.cpp
)

target_link_libraries(bishengir-target-spec-tblgen
  PRIVATE
  MLIRTblgenLib
)

mlir_check_all_link_libraries(bishengir-target-spec-tblgen)
