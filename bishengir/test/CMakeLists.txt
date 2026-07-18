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

add_subdirectory(CAPI)
add_subdirectory(lib)

if(MLIR_ENABLE_BINDINGS_PYTHON)
  add_subdirectory(python)
endif()

configure_lit_site_cfg(
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.py.in
  ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg.py
  MAIN_CONFIG
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.cfg.py
)

llvm_canonicalize_cmake_booleans(
  MLIR_ENABLE_BINDINGS_PYTHON
  SHMEM_BUILD_TEMPLATE
)

set(BISHENGIR_TEST_DEPENDS
  FileCheck count not
  bishengir-compile
  bishengir-opt
  bishengir-options-tblgen
  bishengir-target-spec-tblgen
  bishengir-capi-ir-test
  bishengir-capi-pass-test
  # These really shouldnt be here, to remove from the testcases in the future
  opt llc llvm-dis
)

if(MLIR_ENABLE_BINDINGS_PYTHON)
  list(APPEND BISHENGIR_TEST_DEPENDS
    MLIRPythonModules
    BiShengIRPythonModules
  )
endif()

if(MLIR_INCLUDE_INTEGRATION_TESTS)
  option(BISHENGIR_RUN_NPU_TESTS "Run AscendNPU tests.")
endif()

llvm_canonicalize_cmake_booleans(
  LLVM_BUILD_EXAMPLES
  MLIR_INCLUDE_INTEGRATION_TESTS
  BISHENGIR_RUN_NPU_TESTS
)

if(BISHENGIR_RUN_NPU_TESTS)
  add_subdirectory(Integration)
  list(APPEND BISHENGIR_TEST_DEPENDS bishengir-npu-hivm-vec-add)
  set(ASCEND_HOME_PATH $ENV{ASCEND_HOME_PATH}
        CACHE STRING "Ascend CANN install path")
  if(ASCEND_HOME_PATH STREQUAL "")
    message(FATAL_ERROR "ASCEND_HOME_PATH should be set to the installed CANN package dir")
  endif()
endif()

add_lit_testsuite(check-bishengir "Running the bishengir regression tests"
  ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS ${BISHENGIR_TEST_DEPENDS}
)

set_target_properties(check-bishengir PROPERTIES FOLDER "Tests")
