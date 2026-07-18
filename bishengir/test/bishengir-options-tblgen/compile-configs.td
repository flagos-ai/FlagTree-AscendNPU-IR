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

// RUN: bishengir-options-tblgen -gen-compile-configs %s -I %p/../../include/ | FileCheck %s

include "bishengir/Tools/ConfigOptions/Options.td"

def Foo : Option {
  let description = "Foooooo.";
  let type = "int64_t";
  let defaultValue = "1";
  let compileConfigName = "Config";
}

def Bar : Option {
  let type = "bool";
  let defaultValue = "false";
  let externalStorage = 0;
  // No external storage, no getter and setter
  let compileConfigName = "Config";
}

def Nop : Option {
  let type = "unsigned";
  let defaultValue = "1";
  // If specified, will not emit getter/setter. Only declaration.
  let emitGetterSetter = 0;
}

def List : ListOption {
  let type = "std::string";
  let compileConfigName = "Config";
}

// CHECK: protected:
// CHECK:   int64_t fooFlag = 1;

// CHECK: public:
// CHECK:   Config &setFoo(const int64_t& val) {
// CHECK:     fooFlag = val;
// CHECK:     return *this;
// CHECK:   }

// CHECK:   int64_t getFoo() const {
// CHECK:     return fooFlag;
// CHECK:   }

// CHECK: protected:
// CHECK:   std::vector<std::string> listFlag;

// CHECK: public:
// CHECK:   Config &setList(const std::vector<std::string>& val) {
// CHECK:     listFlag = val;
// CHECK:     return *this;
// CHECK:   }

// CHECK:   std::vector<std::string> getList() const {
// CHECK:     return listFlag;
// CHECK:   }

// CHECK: protected:
// CHECK:   unsigned nopFlag = 1;
