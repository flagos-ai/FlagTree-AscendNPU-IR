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

add_bishengir_library(BiShengIRTensorTransforms
  BubblePadUp.cpp
  BubbleUpExtractSlice.cpp
  CanonicalizeTensorReshape.cpp
  DecomposeTensorConcat.cpp
  FoldTensorEmpty.cpp
  MergeConsecutiveInsertExtractSlice.cpp
  NarrowTensorOp.cpp
  NormalizeLastDimUnalignedTensorOp.cpp
  NormalizeTensorOps.cpp
  OptimizeDpsOpWithYieldedInsertSlice.cpp
  PropagateReshape.cpp
  PropagateReshape/PropagateCollapseDown.cpp
  PropagateReshape/PropagateExpandUp.cpp
  PropagateReshape/PropagateNearEndExpandDown.cpp
  PropagateReshape/PropagateOp/PropagatableOp.cpp
  PropagateReshape/PropagateOp/ScfForOp.cpp
  PropagateReshape/SwapCollapseExpand.cpp
  PropagateReshape/Utils.cpp
  PropagateReshape/Utils/ConcatUtils.cpp
  ReplicateOutEmptyTensor.cpp
  TilingInterfaceImpl.cpp
  TrickleConcatDown.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/bishengir/Dialect/Tensor/Transforms

  DEPENDS
  MLIRTensorTransformsIncGen

  LINK_LIBS PUBLIC
  BiShengIRDialectUtils
  BiShengIRMemRefTransforms
  BiShengIRTensorUtils
  MLIRControlFlowDialect
  MLIRTensorDialect
  MLIRLinalgDialect
  MLIRIR
  MLIRDialect
  MLIRPass
  BiShengIRAnnotationDialect
  BiShengIRHFusionDialect
  BiShengIRHFusionUtils
  BiShengIRHIVMDialect
  MLIRLinalgTransforms
)
