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

add_llvm_executable(bishengir-npu-hivm-vec-add
  main.cpp

  DEPENDS
  bishengir-compile
)

set(ASCEND_HOME_PATH $ENV{ASCEND_HOME_PATH})

target_include_directories(bishengir-npu-hivm-vec-add PUBLIC
  ${ASCEND_HOME_PATH}/include
  ${ASCEND_HOME_PATH}/include/experiment/msprof
)

target_link_directories(bishengir-npu-hivm-vec-add PUBLIC
  ${ASCEND_HOME_PATH}/lib64
)

target_link_libraries(bishengir-npu-hivm-vec-add PUBLIC
  runtime
  ascendcl
)
