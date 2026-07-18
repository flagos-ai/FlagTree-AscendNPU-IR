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

// RUN: bishengir-options-tblgen -gen-compile-options %s -I %p/../../include/ | FileCheck %s

include "bishengir/Tools/ConfigOptions/Options.td"

def Foo : Option {
  let description = "Foooooo.";
  let type = "int64_t";
  let defaultValue = "1";
  let compileOptionCategories = ["testCategory"];
}

def Bar : Option {
  let type = "bool";
  let defaultValue = "false";
  let externalStorage = 0;
  bit isSharedWithDownstreamToolchain = 1;
}

def Nop : Option {
  let type = "unsigned";
  let defaultValue = "1";
  // If specified, will not emit static registration
  let emitOptionRegistration = 0;
}

def List : ListOption {
  let type = "std::string";
}

// CHECK: #ifdef GEN_OPTION_REGISTRATIONS
// CHECK: static llvm::cl::opt<bool, /*ExternalStorage=*/false> bar(
// CHECK:     "bar"
// CHECK:     ,llvm::cl::desc("")
// CHECK:     ,llvm::cl::init(false)
// CHECK: );
//
// CHECK: static llvm::cl::opt<int64_t, /*ExternalStorage=*/true> foo(
// CHECK:     "foo"
// CHECK:     ,llvm::cl::desc("Foooooo.")
// CHECK:     ,llvm::cl::location(fooFlag)
// CHECK:     ,llvm::cl::init(1)
// CHECK:     ,llvm::cl::cat(testCategory)
// CHECK: );
//
// CHECK: static llvm::cl::list<std::string, std::vector<std::string>> list(
// CHECK:     "list"
// CHECK:     ,llvm::cl::desc("")
// CHECK:     ,llvm::cl::location(listFlag)
// CHECK:     ,llvm::cl::MiscFlags::CommaSeparated
// CHECK: );
//
// CHECK: #undef GEN_OPTION_REGISTRATIONS
// CHECK: #endif // GEN_OPTION_REGISTRATIONS

// CHECK: #ifdef GEN_OPTION_COLLECTION
// CHECK: if (optStr.str() == "bar") {
// CHECK:   const auto &optPtr = static_cast<llvm::cl::opt<bool, /*ExternalStorage=*/false> *>(opt);
// CHECK:   optValue = option_handler::handleOpt(*optPtr);
// CHECK: }
// CHECK: #undef GEN_OPTION_COLLECTION
// CHECK: #endif // GEN_OPTION_COLLECTION
