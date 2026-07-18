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

// REQUIRES: hivmc
// Test that --mlir-pass-pipeline-crash-reproducer flag is recognized and doesn't crash.
//
// RUN: bishengir-compile %s --mlir-pass-pipeline-crash-reproducer=%t 2>&1
// Success if we reach here (no crash from reproducer machinery)

func.func @test_func() {
  return
}
