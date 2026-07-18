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

# RUN: python3 %s | FileCheck %s

from bishengir.ir import *
from bishengir.passmanager import *

from bishengir._mlir_libs._bishengirRegisterEverything import register_dialects


def run(f):
    print("\nTEST:", f.__name__)
    with Context(), Location.unknown():
        f()
    return f


# CHECK-LABEL: testAnnotationLowering
@run
def testAnnotationLowering():
    with Context() as ctx:
        register_dialects(ctx)
        module = Module.parse(
            r"""
module {
  func.func @lowering(%arg1: f32, %arg2: f32, %arg3: f32) -> f32 {
      %1 = arith.mulf %arg1, %arg2 : f32
      %2 = arith.addf %1, %arg3 : f32
      annotation.mark %2 {attr = 2 : i32} : f32
      return %2 : f32
  }                                               
}
    """
        )
    pm = PassManager("any")
    pm.enable_ir_printing()
    pm.add("annotation-lowering")
    pm.run(module.operation)
    print(module)
