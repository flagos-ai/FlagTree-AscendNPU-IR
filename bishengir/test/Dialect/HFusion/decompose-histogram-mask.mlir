// RUN: bishengir-opt --hfusion-decompose --split-input-file %s | FileCheck %s

// CHECK-LABEL: func.func @masked_histogram(
// CHECK: %[[WIDE:.*]] = arith.select %{{.*}}, %{{.*}}, %{{.*}} : tensor<16xi1>, tensor<16xi32>
// CHECK: scf.for
// CHECK: %[[MASK_ELEMENT:.*]] = tensor.extract %[[WIDE]][%{{.*}}] : tensor<16xi32>
// CHECK: arith.cmpi ne, %[[MASK_ELEMENT]], %{{.*}} : i32
// CHECK: %[[OLD:.*]] = tensor.extract %{{.*}}[%{{.*}}] : tensor<4xi32>
// CHECK: %[[NEW:.*]] = arith.addi %[[OLD]], %{{.*}} : i32
// CHECK: %[[VALUE:.*]] = arith.select %{{.*}}, %[[NEW]], %[[OLD]] : i32
// CHECK: %[[HIST:.*]] = tensor.insert %[[VALUE]] into %{{.*}}[%{{.*}}] : tensor<4xi32>
// CHECK-NOT: arith.select {{.*}} : tensor<4xi32>
// CHECK: scf.yield %[[HIST]] : tensor<4xi32>
func.func @masked_histogram(%input: tensor<16xi32>, %mask: tensor<16xi1>) -> tensor<4xi32> {
  %result = hfusion.histogram %input, 4, %mask : tensor<16xi32>, tensor<16xi1> -> tensor<4xi32>
  return %result : tensor<4xi32>
}

// -----

// CHECK-LABEL: func.func @unmasked_histogram_i64(
// CHECK: scf.for
// CHECK: %[[OLD:.*]] = tensor.extract %{{.*}}[%{{.*}}] : tensor<4xi64>
// CHECK: %[[NEW:.*]] = arith.addi %[[OLD]], %{{.*}} : i64
// CHECK: %[[VALUE:.*]] = arith.select %{{.*}}, %[[NEW]], %[[OLD]] : i64
// CHECK: %[[HIST:.*]] = tensor.insert %[[VALUE]] into %{{.*}}[%{{.*}}] : tensor<4xi64>
// CHECK: scf.yield %[[HIST]] : tensor<4xi64>
func.func @unmasked_histogram_i64(%input: tensor<16xi64>) -> tensor<4xi64> {
  %result = hfusion.histogram %input, 4 : tensor<16xi64> -> tensor<4xi64>
  return %result : tensor<4xi64>
}
