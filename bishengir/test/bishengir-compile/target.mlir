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

// RUN: bishengir-compile --help | FileCheck %s

// CHECK: BiShengIR Target Options:

// CHECK:   --target=<value>                                           - Target device name
// CHECK:     =Ascend910B1                                             -   Ascend910B1
// CHECK:     =Ascend910B2                                             -   Ascend910B2
// CHECK:     =Ascend910B3                                             -   Ascend910B3
// CHECK:     =Ascend910B4                                             -   Ascend910B4
// CHECK:     =Ascend910B4-1                                           -   Ascend910B4-1
// CHECK:     =Ascend910B2C                                            -   Ascend910B2C
// CHECK:     =Ascend910_9362                                          -   Ascend910_9362
// CHECK:     =Ascend910_9372                                          -   Ascend910_9372
// CHECK:     =Ascend910_9381                                          -   Ascend910_9381
// CHECK:     =Ascend910_9382                                          -   Ascend910_9382
// CHECK:     =Ascend910_9391                                          -   Ascend910_9391
// CHECK:     =Ascend910_9392                                          -   Ascend910_9392
// CHECK:     =Ascend910_950z                                          -   Ascend910_950z
// CHECK:     =Ascend910_9579                                          -   Ascend910_9579
// CHECK:     =Ascend910_957b                                          -   Ascend910_957b
// CHECK:     =Ascend910_957d                                          -   Ascend910_957d
// CHECK:     =Ascend910_9581                                          -   Ascend910_9581
// CHECK:     =Ascend910_9589                                          -   Ascend910_9589
// CHECK:     =Ascend910_958a                                          -   Ascend910_958a
// CHECK:     =Ascend910_958b                                          -   Ascend910_958b
// CHECK:     =Ascend910_9599                                          -   Ascend910_9599
// CHECK:     =Unknown                                                 -   Unknown
