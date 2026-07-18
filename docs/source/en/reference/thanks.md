<!--
 Copyright 2026 FlagOS Contributors

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 -->

# Related projects and thanks

This document lists open-source projects and ecosystems closely related to AscendNPU IR and thanks the LLVM/MLIR and other communities.

## [MLIR](https://mlir.llvm.org)

MLIR originates from the LLVM community and provides reusable, extensible compiler infrastructure. AscendNPU IR is built on MLIR. We thank all developers and contributors in the LLVM/MLIR community. AscendNPU IR benefits from MLIR in these ways:

- **Modular design**: Define IR at different abstraction levels for progressive lowering.
- **Reuse of infrastructure**: Parsing, transformation, optimization, and code generation from MLIR.
- **Ecosystem interoperability**: Extend MLIR dialects to interact and convert with other dialects (e.g. TensorFlow, PyTorch IR) and integrate with upper-level frameworks.

## [Triton-Ascend](https://gitcode.com/Ascend/triton-ascend)

Triton-Ascend brings Triton programming to Ascend, so Triton code runs efficiently on Ascend hardware. AscendNPU IR serves as the compilation backend for Triton, enabling developers to write high-performance kernels for Ascend NPU with familiar Triton syntax and programming model and lowering the barrier for Python developers.

## [TileLang-Ascend](https://github.com/tile-ai/tilelang-ascend)

TileLang is a domain-specific language for tensor computation; TileLang-Ascend is its Ascend-oriented version. By using AscendNPU IR as the backend, TileLang-Ascend leverages AscendNPU IR’s Ascend-aware optimizations to generate high-performance Ascend operators.
