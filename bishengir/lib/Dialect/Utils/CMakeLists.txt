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

if(NOT BISHENGIR_BUILD_STANDALONE_IR_ONLY)
  list(APPEND BS_FEAT_LINK_LIBS BiShengIRLinalgDialectExt)
endif()

add_bishengir_library(BiShengIRDialectUtils
  BytecodeDialectExtensions.cpp
  OpInterfaceUtils.cpp
  ReachabilityAnalyzer.cpp
  UnionFind.cpp
  Util.cpp
  ValueDependencyAnalyzer.cpp

  DEPENDS
  BiShengIRHIVMEnumsIncGen

  LINK_LIBS PUBLIC
  BiShengIRAnnotationDialect
  MLIRArithDialect
  MLIRBufferizationDialect
  MLIRDestinationStyleOpInterface
  MLIRFuncDialect
  BiShengIRHFusionDialect
  MLIRIR
  MLIRLinalgDialect
  MLIRMemRefDialect
  MLIRSCFDialect
  MLIRTensorDialect
  BiShengIRMemRefDialect
  BiShengIRTensorDialect
  ${BS_FEAT_LINK_LIBS}
)
