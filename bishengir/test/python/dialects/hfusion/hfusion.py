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


# CHECK-LABEL: testHFusionPipeline
@run
def testHFusionPipeline():
    with Context() as ctx:
        register_dialects(ctx)
        module = Module.parse(
            r"""
module {                                                              
  func.func @test_fusing_interm_producers(%arg0: tensor<1024xf32>, %arg1: tensor<1024xf32>,    
                                          %arg2: tensor<1024xf32>) -> tensor<1024xf32>
    attributes {hfusion.fusion_kind=#hfusion.fusion_kind<PURE_ELEMWISE>} {
    %0 = tensor.empty() : tensor<1024xf32>                            
    %1 = tensor.empty() : tensor<1024xf32>                            
    %2 = tensor.empty() : tensor<1024xf32>                            
    %3 = linalg.elemwise_binary {fun = #linalg.binary_fn<mul> }       
            ins(%arg0, %arg1 : tensor<1024xf32>, tensor<1024xf32>)
            outs(%0 : tensor<1024xf32>) -> tensor<1024xf32>
    %4 = linalg.elemwise_binary {fun = #linalg.binary_fn<add>}        
            ins(%3, %arg2 : tensor<1024xf32>, tensor<1024xf32>)           
            outs(%1 : tensor<1024xf32>) -> tensor<1024xf32>           
    %5 = linalg.elemwise_binary {fun = #linalg.binary_fn<sub>}        
            ins(%3, %4 : tensor<1024xf32>, tensor<1024xf32>)              
            outs(%2 : tensor<1024xf32>) -> tensor<1024xf32>           
    return %5 : tensor<1024xf32>                                      
  }                                                                   
}   
    """

        )
        pm = PassManager("builtin.module")
        pm.enable_ir_printing()
        pm.add("lower-hfusion-pipeline")
        pm.run(module.operation)
        print(module)
