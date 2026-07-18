// Copyright 2026 FlagOS Contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// RUN: echo "" | bishengir-opt --show-dialects | FileCheck %s
// CHECK: Available Dialects:
// CHECK-SAME: acc
// CHECK-SAME: affine
// CHECK-SAME: amdgpu
// CHECK-SAME: amx
// CHECK-SAME: annotation
// CHECK-SAME: arith
// CHECK-SAME: arm_neon
// CHECK-SAME: arm_sme
// CHECK-SAME: arm_sve
// CHECK-SAME: async
// CHECK-SAME: bufferization
// CHECK-SAME: builtin
// CHECK-SAME: cf
// CHECK-SAME: complex
// CHECK-SAME: dlti
// CHECK-SAME: emitc
// CHECK-SAME: func
// CHECK-SAME: gpu
// CHECK-SAME: hacc
// CHECK-SAME: hfusion
// CHECK-SAME: hivm
// CHECK-SAME: index
// CHECK-SAME: irdl
// CHECK-SAME: linalg
// CHECK-SAME: llvm
// CHECK-SAME: math
// CHECK-SAME: memref
// CHECK-SAME: ml_program
// CHECK-SAME: nvgpu
// CHECK-SAME: nvvm
// CHECK-SAME: omp
// CHECK-SAME: pdl
// CHECK-SAME: pdl_interp
// CHECK-SAME: quant
// CHECK-SAME: rocdl
// CHECK-SAME: scf
// CHECK-SAME: shape
// CHECK-SAME: sparse_tensor
// CHECK-SAME: spirv
// CHECK-SAME: tensor
// CHECK-SAME: tosa
// CHECK-SAME: transform
// CHECK-SAME: vector
// CHECK-SAME: x86vector

// RUN: bishengir-opt --help-hidden | FileCheck %s -check-prefix=CHECK-HELP
// CHECK-HELP: -p - Alias for --pass-pipeline
