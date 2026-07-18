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

set(LLVM_TARGET_DEFINITIONS Passes.td)
if(BISHENGIR_ENABLE_TORCH_CONVERSIONS)
  mlir_tablegen(Passes.h.inc -gen-pass-decls -name Conversion -DBISHENGIR_ENABLE_TORCH_CONVERSIONS)
else()
  mlir_tablegen(Passes.h.inc -gen-pass-decls -name Conversion)
endif()

add_public_tablegen_target(BiShengIRConversionPassIncGen)
add_dependencies(mlir-headers BiShengIRConversionPassIncGen)
