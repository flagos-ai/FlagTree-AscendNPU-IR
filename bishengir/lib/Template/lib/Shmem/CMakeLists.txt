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

file(GLOB cpp_list "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
set (platform_type "Ascend910B")

foreach (cpp_with_path ${cpp_list})
    compile_shmem_to_bc(${cpp_with_path} "aic" ${platform_type})
    compile_shmem_to_bc(${cpp_with_path} "aiv" ${platform_type})
    compile_shmem_to_bc(${cpp_with_path} "mix_aiv" ${platform_type})
    compile_shmem_to_bc(${cpp_with_path} "mix_aic" ${platform_type})
endforeach()
