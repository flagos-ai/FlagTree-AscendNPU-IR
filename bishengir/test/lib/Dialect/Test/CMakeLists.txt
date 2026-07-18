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

set(LLVM_OPTIONAL_SOURCES
   HIVMDialect.cpp
)

set(LLVM_TARGET_DEFINITIONS TestOps.td)
mlir_tablegen(TestOpsDialect.h.inc -gen-dialect-decls -dialect=bishengir_test)
mlir_tablegen(TestOpsDialect.cpp.inc -gen-dialect-defs -dialect=bishengir_test)
mlir_tablegen(TestOps.h.inc -gen-op-decls)
mlir_tablegen(TestOps.cpp.inc -gen-op-defs)
add_public_tablegen_target(BiShengIRTestOpsIncGen)

add_bishengir_library(BiShengIRTestDialect
  TestDialect.cpp

  EXCLUDE_FROM_LIBMLIR

  DEPENDS
  BiShengIRTestOpsIncGen

  LINK_LIBS PUBLIC
  BiShengIRHIVMDialect
  MLIRDestinationStyleOpInterface
)
