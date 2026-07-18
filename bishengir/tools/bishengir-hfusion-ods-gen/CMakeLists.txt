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
  Core
  Support
  )

# New bishengir-hfusion-ods-yaml-gen.
add_mlir_tool(bishengir-hfusion-ods-yaml-gen
  bishengir-hfusion-ods-yaml-gen.cpp
)
llvm_update_compile_flags(bishengir-hfusion-ods-yaml-gen)
target_link_libraries(bishengir-hfusion-ods-yaml-gen PRIVATE
  MLIRIR
  MLIRSupport
  MLIRParser
  )

setup_host_tool(bishengir-hfusion-ods-yaml-gen BISHENGIR_HFUSION_ODS_YAML_GEN BISHENGIR_HFUSION_ODS_YAML_GEN_EXE BISHENGIR_HFUSION_ODS_YAML_GEN_TARGET)

if(NOT ${BISHENGIR_HFUSION_ODS_YAML_GEN_EXE} STREQUAL "bishengir-hfusion-ods-yaml-gen")
  add_custom_target(bishengir-hfusion-ods-yaml-gen-host DEPENDS ${BISHENGIR_HFUSION_ODS_YAML_GEN_EXE})

  if(NOT LLVM_BUILD_UTILS)
    set_target_properties(bishengir-hfusion-ods-yaml-gen PROPERTIES EXCLUDE_FROM_ALL ON)
  endif()
endif()
