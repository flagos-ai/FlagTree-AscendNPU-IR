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

set(LLVM_TARGET_DEFINITIONS SCFTransformOps.td)
mlir_tablegen(SCFTransformOps.h.inc -gen-op-decls)
mlir_tablegen(SCFTransformOps.cpp.inc -gen-op-defs)
add_public_tablegen_target(BiShengIRSCFTransformOpsIncGen)
add_dependencies(mlir-headers BiShengIRSCFTransformOpsIncGen)
add_bishengir_doc(SCFTransformOps BiShengIRSCFLoopTransformOps Dialects/ -gen-op-doc)
