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

# AscendNPU IR users

This project enables multiple operator programming frameworks to target the Ascend backend and provides Ascend-oriented compilation and optimization. Below are examples of languages and frameworks that have integrated or use AscendNPU IR.

## Language ecosystem

| DSL | Description |
| --- | --- |
| [Triton-Ascend](https://gitcode.com/Ascend/triton-ascend) | Enables Triton developers to quickly develop Ascend operators and migrate ecosystems |
| [TileLang-Ascend (branch npuir)](https://github.com/tile-ai/tilelang-ascend/tree/npuir) | Tile-level programming for high-performance kernels, balancing productivity and low-level optimization |
| [DLCompiler](https://github.com/DeepLink-org/DLCompiler) | Deep learning compiler extending Triton, with cross-architecture DSL extension and automatic optimization |
| [FlagTree](https://github.com/flagos-ai/flagtree) | Open-source AI compiler based on Triton with unified compilation across multiple backends |
