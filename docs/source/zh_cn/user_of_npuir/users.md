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

# AscendNPU IR 用户

本项目已使能多个算子编程框架接入昇腾后端，并提供面向昇腾的编译优化能力。以下为已对接或使用AscendNPU IR的语言与框架示例。

## 语言生态

| DSL | 简介 |
| --- | --- |
| [Triton-Ascend](https://gitcode.com/Ascend/triton-ascend) | 为`Triton`开发者提供面向昇腾的算子快速开发与生态迁移能力 |
| [TileLang-Ascend (branch npuir)](https://github.com/tile-ai/tilelang-ascend/tree/npuir) | 简化高性能算子开发流程的`Tile`级编程框架，兼顾开发效率与底层优化能力 |
| [DLCompiler](https://github.com/DeepLink-org/DLCompiler) | 扩展`Triton`的深度学习编译器，支持跨架构DSL扩展与智能自动优化 |
| [FlagTree](https://github.com/flagos-ai/flagtree) | 基于`Triton`语言的开源AI编译器，提供跨多后端的统一编译能力 |
