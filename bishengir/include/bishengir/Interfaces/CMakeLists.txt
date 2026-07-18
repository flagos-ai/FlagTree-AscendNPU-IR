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

set(LLVM_TARGET_DEFINITIONS BiShengIRAttrs.td)
mlir_tablegen(BiShengIREnums.h.inc -gen-enum-decls)
mlir_tablegen(BiShengIREnums.cpp.inc -gen-enum-defs)
mlir_tablegen(BiShengIRAttrs.h.inc -gen-attrdef-decls -attrdefs-dialect=bishengir)
mlir_tablegen(BiShengIRAttrs.cpp.inc -gen-attrdef-defs -attrdefs-dialect=bishengir)
mlir_tablegen(BiShengIRTypes.h.inc -gen-typedef-decls -typedefs-dialect=bishengir)
mlir_tablegen(BiShengIRTypes.cpp.inc -gen-typedef-defs -typedefs-dialect=bishengir)
add_public_tablegen_target(MLIRBiShengIREnumsIncGen)
add_public_tablegen_target(MLIRBiShengIRAttributesIncGen)
add_dependencies(mlir-headers MLIRBiShengIREnumsIncGen)
add_dependencies(mlir-headers MLIRBiShengIRAttributesIncGen)

add_mlir_interface(AggregatedOpInterface)

# Vendor CopyOpInterface only on LLVM 22+ (MLIR removed it in PR #157711).
# On LLVM < 22 MLIR still ships it and the shared include guard in
# CopyOpInterface.td deduplicates against MLIR's copy.
if(LLVM_MAJOR_VERSION_22_COMPATIBLE)
  add_mlir_interface(CopyOpInterface)
endif()
