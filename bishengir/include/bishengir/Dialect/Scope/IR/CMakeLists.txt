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

set(LLVM_TARGET_DEFINITIONS ScopeOps.td)
mlir_tablegen(ScopeDialect.h.inc -gen-dialect-decls -dialect=scope)
mlir_tablegen(ScopeDialect.cpp.inc -gen-dialect-defs -dialect=scope)
mlir_tablegen(ScopeOps.h.inc -gen-op-decls)
mlir_tablegen(ScopeOps.cpp.inc -gen-op-defs)
add_public_tablegen_target(BiShengIRScopeIncGen)

add_bishengir_doc(ScopeOps ScopeDialect Dialects/ -gen-dialect-doc -dialect=scope)
