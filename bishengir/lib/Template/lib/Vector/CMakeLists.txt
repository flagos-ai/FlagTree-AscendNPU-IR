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

add_subdirectory(Broadcast)
add_subdirectory(Cast)
add_subdirectory(CmpSel)
add_subdirectory(Elementwise)
add_subdirectory(Reduction)
add_subdirectory(Transpose)
add_subdirectory(Arange)
add_subdirectory(Interleave)
add_subdirectory(Deinterleave)
add_subdirectory(Gather)
add_subdirectory(MulExtended)
add_subdirectory(Pow)
add_subdirectory(Cumulative)
add_subdirectory(Sort)
compile_cpp_to_bc("aiv" "Ascend910B")
