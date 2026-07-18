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

# To silence warning caused by Wundef.
add_definitions(-DGTEST_NO_LLVM_SUPPORT=0)

# Create a main unit test target
add_custom_target(BiShengIRUnitTests)

# Define a custom function to add unit tests
function(add_bishengir_unittest test_name)
  add_unittest(BiShengIRUnitTests ${test_name} ${ARGN})
  set(run_target run-${test_name})

  # Create a custom target for running this specific test
  add_custom_target(${run_target}
    COMMAND $<TARGET_FILE:${test_name}>
    DEPENDS ${test_name}
    COMMENT "Run ${test_name} unit tests"
    EXCLUDE_FROM_ALL
  )
  set_property(GLOBAL APPEND PROPERTY BISHENGIR_UNITTEST_RUN_TARGETS ${run_target})

  # Add the test to the global unit tests target
  add_dependencies(BiShengIRUnitTests ${test_name})
endfunction()

add_subdirectory(Dialect)

get_property(bishengir_unittest_run_targets GLOBAL PROPERTY BISHENGIR_UNITTEST_RUN_TARGETS)
list(SORT bishengir_unittest_run_targets)

# Create a custom target to run all tests
add_custom_target(run-bishengir-unittests
  COMMENT "Run all BiShengIR unit tests"
)

if(bishengir_unittest_run_targets)
  add_dependencies(run-bishengir-unittests ${bishengir_unittest_run_targets})
endif()
