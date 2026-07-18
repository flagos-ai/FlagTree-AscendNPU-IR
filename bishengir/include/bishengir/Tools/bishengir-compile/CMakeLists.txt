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

set(LLVM_TARGET_DEFINITIONS Options.td)
set(BS_FEAT_LIST)
if(BISHENGIR_ENABLE_TORCH_CONVERSIONS)
  list(APPEND BS_FEAT_LIST "-DBISHENGIR_ENABLE_TORCH_CONVERSIONS")
endif()
if(BISHENGIR_PUBLISH)
  list(APPEND BS_FEAT_LIST "-DBISHENGIR_PUBLISH")
endif()
bishengir_options_tablegen(CompileOptions.cpp.inc -gen-compile-options ${BS_FEAT_LIST})
bishengir_options_tablegen(CompileConfigs.cpp.inc -gen-compile-configs ${BS_FEAT_LIST})
bishengir_options_tablegen(PassOptions.cpp.inc -gen-pass-options ${BS_FEAT_LIST})
bishengir_options_tablegen(PassPipelineOptions.cpp.inc -gen-pass-pipeline-options ${BS_FEAT_LIST})
bishengir_options_tablegen(ConfigUtils.cpp.inc -gen-configs-and-options-conversion ${BS_FEAT_LIST})
add_public_tablegen_target(BiShengIROptionsIncGen)
add_dependencies(mlir-headers BiShengIROptionsIncGen)
