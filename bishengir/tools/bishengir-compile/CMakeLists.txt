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
    BiShengIRTestDialect
    MLIRTestDialect
    MLIRTestTransformDialect
    MLIRTestTransforms
  )
endif()

get_property(PRIVATE_BISHENGIR_LIBS GLOBAL PROPERTY BISHENGIR_LIBS)
get_property(PRIVATE_BISHENGIR_CONVERSION_LIBS GLOBAL PROPERTY BISHENGIR_CONVERSION_LIBS)
get_property(PRIVATE_BISHENGIR_TRANSLATION_LIBS GLOBAL PROPERTY BISHENGIR_TRANSLATION_LIBS)
get_property(PUBLIC_BISHENGIR_CONVERSION_LIBS GLOBAL PROPERTY BISHENGIR_CONVERSION_OPEN_SOURCE_LIBS)

set(LIBS
  ${TEST_LIBS}
  ${PRIVATE_BISHENGIR_LIBS}
  ${PRIVATE_BISHENGIR_CONVERSION_LIBS}
  ${PRIVATE_BISHENGIR_TRANSLATION_LIBS}
  ${PUBLIC_BISHENGIR_CONVERSION_LIBS}
)

add_bishengir_publish_tool(bishengir-compile
  bishengir-compile.cpp

  DEPENDS
  ${LIBS}
)

target_include_directories(bishengir-compile PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(bishengir-compile PRIVATE ${LIBS})
mlir_check_all_link_libraries(bishengir-compile)
