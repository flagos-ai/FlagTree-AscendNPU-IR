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

add_bishengir_conversion_library(BiShengIRGPUToHFusion
  GPUToHFusion.cpp

  ADDITIONAL_HEADER_DIRS
  ${BISHENGIR_MAIN_INCLUDE_DIR}/bishengir/Conversion/GPUToHFusion

  DEPENDS
  BiShengIRConversionPassIncGen

  LINK_COMPONENTS
  Core

  LINK_LIBS PUBLIC
  BiShengIRDialectUtils
  MLIRArithDialect
  MLIRMathDialect
  MLIRFuncDialect
  MLIRLinalgDialect
  MLIRGPUDialect
  BiShengIRHFusionDialect
  MLIRTransformUtils
  MLIRRewrite
  MLIRPass
)
