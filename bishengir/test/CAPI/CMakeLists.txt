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

function(_add_capi_test_executable name)
  cmake_parse_arguments(ARG
    ""
    ""
    "LINK_LIBS"
    ${ARGN})
  set(LLVM_LINK_COMPONENTS
    )
  add_llvm_executable(${name}
    PARTIAL_SOURCES_INTENDED
    ${ARG_UNPARSED_ARGUMENTS})
  llvm_update_compile_flags(${name})
  if(MLIR_BUILD_MLIR_C_DYLIB)
    target_link_libraries(${name} PRIVATE
      MLIR-C)
  else()
    target_link_libraries(${name} PRIVATE
      ${ARG_LINK_LIBS})
  endif()
endfunction(_add_capi_test_executable)


_add_capi_test_executable(bishengir-capi-ir-test
  ir.c
  LINK_LIBS PRIVATE
    BiShengIRCAPIRegisterEverything
    MLIRCAPIIR
)

_add_capi_test_executable(bishengir-capi-pass-test
  pass.c
  LINK_LIBS PRIVATE
    BiShengIRCAPIRegisterEverything
    BiShengIRCAPIAnnotation
    MLIRCAPIFunc
    BiShengIRCAPIHFusion
    BiShengIRCAPIHIVM
    MLIRCAPIIR
    MLIRCAPIRegisterEverything
    MLIRCAPITransforms
)
