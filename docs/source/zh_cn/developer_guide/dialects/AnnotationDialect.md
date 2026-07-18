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

# `annotation` 方言

`annotation`方言用于提供注解操作，可为指定操作附加扩展属性。

```mlir
// 标记额外属性
annotation.mark %a { attr-dict } : f64
```

## 操作定义

### `annotation.mark` (annotation::MarkOp)

**功能：** 使用键值对形式的属性对IR值添加注解。注解取值分为两种形式，静态取值通过内联属性字典定义，动态取值通过IR运行时值传入。

**语法：**

```mlir
operation ::= `annotation.mark` $src attr-dict
              (`keys` `=` $keys^)?
              (`values` `=` `[`$values^`:`type($values) `]`)?
              `:`type($src)
```

**示例：**

```mlir
annotation.mark %target keys = ["key"] values = [%val]
annotation.mark %target {key : val}
```

**特性：** `AlwaysSpeculatableImplTrait`

**接口：** `ConditionallySpeculatable`、`MemoryEffectOpInterface`、`NoMemoryEffect`

**内存效应：** `MemoryEffects::Effect{MemoryEffects::Write on ::mlir::SideEffects::DefaultResource}`、`MemoryEffects::Effect{}`

**属性：**

| 属性名 | MLIR类型 | 说明 |
| :-----: | ----------- | ---- |
| `keys` | `::mlir::ArrayAttr` | 字符串数组属性 |

**操作数：**

| 操作数 | 说明 |
| :-----: | ----------- |
| `src` | 待注解IR值，支持任意类型 |
| `values` | 变长操作数，支持任意类型 |
