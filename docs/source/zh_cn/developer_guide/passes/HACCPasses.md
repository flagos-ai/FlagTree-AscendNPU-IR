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

# hacc 方言 Passes

## `-hacc-append-device-spec`

**功能：** 为编译目标追加设备规格信息。

**选项：**

- `-target`：指定设备目标名称。

## `-hacc-rename-func`

**功能：** 基于属性重命名函数。该Pass根据`hacc.rename_func`属性重命名函数，并同步更新模块内所有对该函数的调用引用。

**转换示例：**

转换前：

```mlir
func.func @bar() attributes {hacc.rename_func = #hacc.rename_func<@foo>} {
  return
}

func.func @caller() {
  func.call @bar() : () -> ()
  return
}
```

转换后：

```mlir
func.func @foo() {
  return
}

func.func @caller() {
  func.call @foo() : () -> ()
  return
}
```

**使用限制：**

- 目标函数名不得与模块内已有函数重名。
