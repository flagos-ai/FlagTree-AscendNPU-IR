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

if(MLIR_INCLUDE_TESTS)
  set(TEST_LIBS
    BiShengIRTestDialectHFusion
    MLIRTestDialect
    MLIRTestTransformDialect
    MLIRTestTransforms
    BiShengIRTestDialectUtils
  )
endif()

get_property(BISHENGIR_LIBS GLOBAL PROPERTY BISHENGIR_LIBS)
get_property(BISHENGIR_DIALECT_LIBS GLOBAL PROPERTY BISHENGIR_DIALECT_LIBS)
get_property(BISHENGIR_CONVERSION_LIBS GLOBAL PROPERTY BISHENGIR_CONVERSION_LIBS)
get_property(BISHENGIR_TRANSLATION_LIBS GLOBAL PROPERTY BISHENGIR_TRANSLATION_LIBS)
get_property(BISHENGIR_EXTENSION_LIBS GLOBAL PROPERTY BISHENGIR_EXTENSION_LIBS)

set(LIBS
  ${TEST_LIBS}
  ${BISHENGIR_LIBS}
  ${BISHENGIR_DIALECT_LIBS}
  ${BISHENGIR_CONVERSION_LIBS}
  ${BISHENGIR_TRANSLATION_LIBS}
  ${BISHENGIR_EXTENSION_LIBS}
  BiShengIRToolUtils
  MLIRMlirOptMain
)

add_bishengir_publish_tool(bishengir-opt
  bishengir-opt.cpp

  DEPENDS
  ${LIBS}
)

target_include_directories(bishengir-opt PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
if(MLIR_INCLUDE_TESTS)
  target_include_directories(bishengir-opt PRIVATE ${BISHENGIR_SRC_DIR}/test/lib/Dialect)
endif()

target_link_libraries(bishengir-opt PRIVATE ${LIBS})

mlir_check_all_link_libraries(bishengir-opt)
