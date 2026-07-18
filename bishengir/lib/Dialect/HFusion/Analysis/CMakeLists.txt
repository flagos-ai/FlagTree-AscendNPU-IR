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

add_bishengir_dialect_library(BiShengIRHFusionAnalysis
  ReshapeAnalyzer/ReshapeAnalyzer.cpp
  DimensionAnalyzer/DimensionAnalyzer.cpp
  DimensionAnalyzer/DimensionMarker.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/bishengir/Dialect/HFusion

  DEPENDS
  BiShengIRHFusionTransformsIncGen

  LINK_LIBS PUBLIC
  BiShengIRAnalysis
  BiShengIRDialectUtils
  BiShengIRSCFTransformOps
  BiShengIRTensorTransforms
  BiShengIRTransform
  BiShengIRHACCDialect
  BiShengIRHACCUtils
  MLIRAffineDialect
  MLIRArithDialect
  MLIRDialectUtils
  MLIRFuncDialect
  BiShengIRHFusionDialect
  BiShengIRHFusionUtils
  MLIRLinalgDialect
  MLIRLinalgUtils
  MLIRMemRefDialect
  MLIRPass
  MLIRShapeDialect
  MLIRTensorDialect
  MLIRTensorUtils
)
