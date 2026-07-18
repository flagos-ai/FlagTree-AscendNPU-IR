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

//===- CopyOpInterface.td - Copy operation interface -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Defines the interface for copy-like operations.
//
// NOTE: Vendored verbatim from MLIR (removed in LLVM 22 by PR #157711). The
// guard, cppNamespace, and method signatures match the upstream definition
// exactly so that on LLVM < 22 (where MLIR still ships this file) the
// include guard deduplicates and there is no double definition.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_INTERFACES_COPYOPINTERFACE
#define MLIR_INTERFACES_COPYOPINTERFACE

include "mlir/IR/OpBase.td"

def CopyOpInterface : OpInterface<"CopyOpInterface"> {
  let description = [{
    A copy-like operation is one that copies from source value to target value.
  }];
  let cppNamespace = "::mlir";

  let methods = [
    InterfaceMethod<
      /*desc=*/"Returns the source value for this copy operation",
      /*retTy=*/"::mlir::Value",
      /*methodName=*/"getSource"
    >,
    InterfaceMethod<
      /*desc=*/"Returns the target value for this copy operation",
      /*retTy=*/"::mlir::Value",
      /*methodName=*/"getTarget"
    >
  ];
}

#endif // MLIR_INTERFACES_COPYOPINTERFACE
