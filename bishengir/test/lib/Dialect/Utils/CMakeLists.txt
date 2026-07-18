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

# Exclude tests from libMLIR.so
add_bishengir_library(BiShengIRTestDialectUtils
  BiShengSegmenter.cpp
  InstructionMarker.cpp
  TestDimensionAnalyzer.cpp

  LINK_LIBS PUBLIC
  BiShengIRDialectUtils
  MLIRAnalysis
  BiShengIRAnnotationDialect
  MLIRFuncDialect
  BiShengIRHIVMDialect
  MLIRTensorUtils
  BiShengIRTransform
)

target_include_directories(BiShengIRTestDialectUtils PRIVATE ${BISHENGIR_SRC_DIR}/test/lib/Dialect)
