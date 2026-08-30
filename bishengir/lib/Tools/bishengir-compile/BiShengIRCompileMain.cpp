//===- BiShengIRCompile.cpp - BiShengIR Compile Tool Support -----*- C++-*-===//
//
// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//===----------------------------------------------------------------------===//

#include "bishengir/Dialect/Annotation/IR/Annotation.h"
#include "bishengir/Dialect/HIVM/IR/HIVM.h"
#include "bishengir/Tools/Utils/Utils.h"
#include "bishengir/Tools/RetriablePassManager/RetriablePassManager.h"
#include "bishengir/Tools/RetriablePassManager/CbufOverflowRetryPolicy.h"
#include "bishengir/Tools/RetriablePassManager/CcOverflowRetryPolicy.h"
#include "bishengir/Tools/RetriablePassManager/TuningRetryPolicy.h"
#include "bishengir/Tools/RetriablePassManager/UbOverflowRetryPolicy.h"
#include "bishengir/Tools/bishengir-compile/BiShengIRCompile.h"
#include "bishengir/Tools/bishengir-compile/PassPipeline.h"

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/Interfaces/ViewLikeInterface.h"
#include "llvm/Support/raw_ostream.h"
#include "mlir/Parser/Parser.h"
#include "mlir/Support/FileUtilities.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/Twine.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/LogicalResult.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/VersionTuple.h"
#include <functional>
#include <regex>
#include <set>
#include <vector>

#define DEBUG_TYPE "bishengir-compile"
#define LDBG(X) LLVM_DEBUG(llvm::dbgs() << X << "\n")

using namespace bishengir;
using namespace llvm;
using namespace mlir;

namespace {

/// Get the lib directory path (../lib relative to bishengir-compile
/// executable). Returns canonical absolute path without ".." or ".".
std::string getLibDirFromExecutable(StringRef executablePath) {
  if (executablePath.empty() ||
      (!executablePath.contains('/') && !executablePath.contains('\\')))
    return "";
  llvm::SmallString<256> absPath(executablePath);
  if (llvm::sys::fs::make_absolute(absPath))
    return "";
  llvm::SmallString<256> realPath;
  if (!llvm::sys::fs::real_path(absPath, realPath))
    absPath = realPath;
  llvm::sys::path::remove_filename(absPath);
  llvm::sys::path::append(absPath, "..", "lib");
  llvm::sys::path::remove_dots(absPath, /*remove_dot_dot=*/true);
  return std::string(absPath.str());
}

/// Add bitcode path attributes to ModuleOp from ../lib/*.bc files.
/// Paths are canonical (no ".." or ".") before being stored in attributes.
void addBitcodeAttrsToModule(ModuleOp module, StringRef executablePath,
                             const BiShengIRCompileMainConfig &config) {
  auto version = bishengir::parseHIVMCVersion(config.getHIVMCVersion());
  if (!version.has_value() || version.value().empty() ||
      version.value().getAsString() == "0.1.0")
    return;
  std::string libDir = getLibDirFromExecutable(executablePath);
  // A locally built compiler may use the external hivmc from a separate
  // CANN installation. Fall back to that installation's sibling lib dir when
  // the local compiler package does not ship runtime bitcode.
  auto hasRuntimeBitcode = [](StringRef dir) {
    llvm::SmallString<256> path(dir);
    llvm::sys::path::append(path, "meta_op.aic.bc");
    return llvm::sys::fs::exists(path);
  };
  if (!hasRuntimeBitcode(libDir)) {
    std::string hivmcInstall = bishengir::getBiShengInstallPath();
    llvm::SmallString<256> fallback;
    if (!hivmcInstall.empty()) {
      fallback = hivmcInstall;
      llvm::sys::path::append(fallback, "lib");
    } else if (auto hivmcPath = llvm::sys::findProgramByName("hivmc")) {
      fallback = hivmcPath.get();
      llvm::sys::path::remove_filename(fallback);
      llvm::sys::path::append(fallback, "..", "lib");
      llvm::sys::path::remove_dots(fallback, /*remove_dot_dot=*/true);
    }
    if (!fallback.empty() && hasRuntimeBitcode(fallback))
      libDir = fallback.str().str();
  }
  MLIRContext *ctx = module->getContext();

  using CreateAttrFn =
      std::function<mlir::Attribute(MLIRContext *, mlir::StringAttr)>;
  auto addIfExists = [&](const char *filename, llvm::StringRef attrName,
                         CreateAttrFn createAttr) {
    llvm::SmallString<256> bcPath(libDir);
    llvm::sys::path::append(bcPath, filename);
    if (!llvm::sys::fs::exists(bcPath))
      return;
    llvm::SmallString<256> canonicalPath;
    if (llvm::sys::fs::real_path(bcPath, canonicalPath))
      return;
    module->setAttr(
        attrName,
        createAttr(ctx, mlir::StringAttr::get(ctx, canonicalPath.str().str())));
  };

  addIfExists("meta_op.aic.bc", mlir::hivm::AIC_BITCODEAttr::name,
              [](MLIRContext *c, mlir::StringAttr s) -> mlir::Attribute {
                return mlir::hivm::AIC_BITCODEAttr::get(c, s);
              });
  addIfExists("meta_op.aiv.bc", mlir::hivm::AIV_BITCODEAttr::name,
              [](MLIRContext *c, mlir::StringAttr s) -> mlir::Attribute {
                return mlir::hivm::AIV_BITCODEAttr::get(c, s);
              });
  addIfExists("meta_op.mix.aic.bc", mlir::hivm::MIX_AIC_BITCODEAttr::name,
              [](MLIRContext *c, mlir::StringAttr s) -> mlir::Attribute {
                return mlir::hivm::MIX_AIC_BITCODEAttr::get(c, s);
              });
  addIfExists("meta_op.mix.aiv.bc", mlir::hivm::MIX_AIV_BITCODEAttr::name,
              [](MLIRContext *c, mlir::StringAttr s) -> mlir::Attribute {
                return mlir::hivm::MIX_AIV_BITCODEAttr::get(c, s);
              });
  addIfExists("host.bc", mlir::hivm::HOST_BITCODEAttr::name,
              [](MLIRContext *c, mlir::StringAttr s) -> mlir::Attribute {
                return mlir::hivm::HOST_BITCODEAttr::get(c, s);
              });
}

/// Get the HIVMC binary name.
StringRef getHIVMCName() {
  const char *kBiShengIRHIVMBinaryName = "hivmc";
  return kBiShengIRHIVMBinaryName;
}

std::vector<std::string> skipOptions(const std::vector<std::string> &options,
                                     const std::set<std::string> &skip) {
  std::vector<std::string> result;
  for (const std::string &arg : options) {
    StringRef argRef = arg;
    SmallVector<StringRef> parts;
    argRef.split(parts, '=');
    if (parts.empty()) {
      continue;
    }
    std::string trimArg = parts[0].trim().ltrim('-').str();
    if (skip.count(trimArg) != 0) {
      continue;
    }
    result.push_back(arg);
  }
  return result;
}

std::vector<std::string>
skipDebugOptions(const std::vector<std::string> &options) {
  std::set<std::string> debugOptions = {"debug", "debug-only",
                                        "mlir-print-ir-before-all",
                                        "mlir-print-ir-after-all"};
  return skipOptions(options, debugOptions);
}

static constexpr StringLiteral kL2CacheModeAttr = "l2_cache_mode";

static std::optional<hivm::AddressSpace> getAddressSpace(mlir::Type type) {
  auto memref = dyn_cast<MemRefType>(type);
  if (!memref)
    return std::nullopt;
  auto space = dyn_cast<hivm::AddressSpaceAttr>(memref.getMemorySpace());
  if (!space)
    return std::nullopt;
  return space.getAddressSpace();
}

static bool isTypedGM(mlir::Type type) {
  return getAddressSpace(type) == hivm::AddressSpace::GM;
}

static bool isSupportedLocal(mlir::Type type) {
  auto space = getAddressSpace(type);
  return space == hivm::AddressSpace::UB || space == hivm::AddressSpace::L1 ||
         space == hivm::AddressSpace::L0C;
}

static std::optional<int64_t> elementBytes(mlir::Type type) {
  auto shaped = dyn_cast<ShapedType>(type);
  if (!shaped || !shaped.getElementType().isIntOrFloat())
    return std::nullopt;
  unsigned bits = shaped.getElementType().getIntOrFloatBitWidth();
  if (!bits || bits % 8)
    return std::nullopt;
  return static_cast<int64_t>(bits / 8);
}

static MemRefType getL2GlobalType(MLIRContext *context) {
  return MemRefType::get(
      {1}, mlir::IntegerType::get(context, 64), AffineMap(),
      hivm::AddressSpaceAttr::get(context, hivm::AddressSpace::GM));
}

static FailureOr<memref::GlobalOp> getOrCreateL2Global(ModuleOp module,
                                                       OpBuilder &builder) {
  constexpr StringRef name = "g_opSystemRunCfg";
  auto expectedType = getL2GlobalType(module.getContext());
  if (Operation *symbol = SymbolTable::lookupSymbolIn(module, name)) {
    auto global = dyn_cast<memref::GlobalOp>(symbol);
    if (!global || global.getType() != expectedType) {
      symbol->emitError() << name << " must have type " << expectedType;
      return failure();
    }
    return global;
  }

  OpBuilder::InsertionGuard guard(builder);
  builder.setInsertionPointToStart(module.getBody());
  return builder.create<memref::GlobalOp>(
      module.getLoc(), name, StringAttr(), expectedType, builder.getUnitAttr(),
      false, IntegerAttr());
}

struct L2CacheHintPlan {
  OpOperand *anchor;
  memref::ReinterpretCastOp reinterpretCast;
  SmallVector<Operation *> viewChain;
  int64_t elementBytes;
};

static std::optional<OpOperand *> getGMOperandForHint(Operation *op) {
  if (auto load = dyn_cast<hivm::LoadOp>(op)) {
    if (isTypedGM(load.getSrc().getType()) &&
        isSupportedLocal(load.getDst().getType()))
      return &load->getOpOperand(0);
    return std::nullopt;
  }
  if (auto store = dyn_cast<hivm::StoreOp>(op)) {
    if (isSupportedLocal(store.getSrc().getType()) &&
        isTypedGM(store.getDst().getType()))
      return &store->getOpOperand(1);
    return std::nullopt;
  }
  if (auto copy = dyn_cast<hivm::CopyOp>(op)) {
    bool srcGM = isTypedGM(copy.getSrc().getType());
    bool dstGM = isTypedGM(copy.getDst().getType());
    if (srcGM == dstGM)
      return std::nullopt;
    mlir::Type localType = srcGM ? copy.getDst().getType()
                                 : copy.getSrc().getType();
    if (!isSupportedLocal(localType))
      return std::nullopt;
    return &copy->getOpOperand(srcGM ? 0 : 1);
  }
  if (auto call = dyn_cast<func::CallOp>(op)) {
    auto declaration = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
        call, call.getCalleeAttr());
    bool generatedLibraryCall =
        declaration && declaration.isExternal() && declaration.isPrivate() &&
        declaration->hasAttr("hacc.always_inline") &&
        declaration->hasAttr("llvm.emit_c_interface");
    if (!generatedLibraryCall)
      return std::nullopt;

    // Lowered HIVM transfer calls may have different library names (for
    // example nd2nz and fixpipe). Identify the GM endpoint from the ABI
    // instead of maintaining a name allowlist: a transfer has exactly two
    // memref endpoints, with exactly one in GM and the other on-chip.
    SmallVector<unsigned> memrefOperands;
    for (unsigned i = 0; i < call.getNumOperands(); ++i) {
      if (isa<MemRefType>(call.getOperand(i).getType()))
        memrefOperands.push_back(i);
    }
    if (memrefOperands.size() != 2)
      return std::nullopt;
    bool firstGM = isTypedGM(call.getOperand(memrefOperands[0]).getType());
    bool secondGM = isTypedGM(call.getOperand(memrefOperands[1]).getType());
    if (firstGM == secondGM)
      return std::nullopt;
    unsigned localIndex = firstGM ? memrefOperands[1] : memrefOperands[0];
    if (!isSupportedLocal(call.getOperand(localIndex).getType()))
      return std::nullopt;
    unsigned gmIndex = firstGM ? memrefOperands[0] : memrefOperands[1];
    return &call->getOpOperand(gmIndex);
  }
  return std::nullopt;
}

static void collectGMAnchorsFromValues(mlir::ValueRange values,
                                       SmallVectorImpl<OpOperand *> &anchors) {
  SmallVector<mlir::Value> worklist(values.begin(), values.end());
  llvm::DenseSet<mlir::Value> visited;
  while (!worklist.empty()) {
    mlir::Value value = worklist.pop_back_val();
    if (!visited.insert(value).second)
      continue;

    for (OpOperand &use : value.getUses()) {
      Operation *user = use.getOwner();
      if (auto anchor = getGMOperandForHint(user)) {
        if (*anchor == &use)
          anchors.push_back(*anchor);
        continue;
      }

      auto nextView = dyn_cast<ViewLikeOpInterface>(user);
      if (nextView && nextView.getViewSource() == value) {
        llvm::append_range(worklist, user->getResults());
        continue;
      }
      if (auto cast = dyn_cast<memref::CastOp>(user)) {
        if (cast.getSource() == value)
          worklist.push_back(cast.getResult());
      }
    }
  }
}

static LogicalResult buildL2CacheHintPlan(OpOperand *anchor,
                                           L2CacheHintPlan &plan) {
  mlir::Value value = anchor->get();
  llvm::DenseSet<mlir::Value> visited;
  SmallVector<Operation *> viewChain;
  memref::ReinterpretCastOp selected;

  while (value && visited.insert(value).second) {
    if (auto cast = value.getDefiningOp<memref::ReinterpretCastOp>()) {
      if (isTypedGM(cast.getType())) {
        selected = cast;
        break;
      }
    }
    auto view = value.getDefiningOp<ViewLikeOpInterface>();
    if (view) {
      viewChain.push_back(view.getOperation());
      value = view.getViewSource();
      continue;
    }
    if (auto cast = value.getDefiningOp<memref::CastOp>()) {
      viewChain.push_back(cast.getOperation());
      value = cast.getSource();
      continue;
    }
    break;
  }

  Operation *hintedOp = anchor->getOwner();
  if (!selected)
    return hintedOp->emitError(
        "l2_cache_mode=4 GM operand has no typed-GM memref.reinterpret_cast");
  if (selected.getMixedOffsets().size() != 1)
    return selected.emitError(
        "l2_cache_mode=4 requires reinterpret_cast with exactly one offset");
  OpFoldResult oldOffset = selected.getMixedOffsets().front();
  if (auto attr = dyn_cast<mlir::Attribute>(oldOffset)) {
    if (!isa<IntegerAttr>(attr))
      return selected.emitError("l2_cache_mode=4 offset must be integral");
  } else if (!cast<mlir::Value>(oldOffset).getType().isIndex()) {
    return selected.emitError("l2_cache_mode=4 offset value must be index");
  }
  auto bytes = elementBytes(selected.getType());
  if (!bytes || *bytes <= 0)
    return selected.emitError(
        "l2_cache_mode=4 requires a byte-addressable integer or float element");

  plan = {anchor, selected, std::move(viewChain), *bytes};
  return success();
}

static LogicalResult consumeL2CacheHints(ModuleOp module) {
  if (std::getenv("BISHENGIR_DISABLE_L2_ENCODING")) {
    module.walk([&](Operation *op) { op->removeAttr(kL2CacheModeAttr); });
    return success();
  }

  SmallVector<Operation *> hintedOps;
  bool invalidHint = false;
  module.walk([&](Operation *op) {
    mlir::Attribute rawHint = op->getAttr(kL2CacheModeAttr);
    if (!rawHint)
      return;
    auto hint = dyn_cast<IntegerAttr>(rawHint);
    if (!hint || hint.getInt() < 0 || hint.getInt() > 7) {
      op->emitError("l2_cache_mode must be an integer in [0, 7]");
      invalidHint = true;
      return;
    }
    if (hint.getInt() == 4)
      hintedOps.push_back(op);
  });
  if (invalidHint)
    return failure();
  if (hintedOps.empty()) {
    module.walk([&](Operation *op) { op->removeAttr(kL2CacheModeAttr); });
    return success();
  }

  SmallVector<L2CacheHintPlan> plans;
  llvm::DenseSet<OpOperand *> plannedAnchors;
  for (Operation *op : hintedOps) {
    SmallVector<OpOperand *> anchors;
    if (auto anchor = getGMOperandForHint(op)) {
      anchors.push_back(*anchor);
    } else if (auto mark = dyn_cast<annotation::MarkOp>(op)) {
      collectGMAnchorsFromValues(ValueRange{mark.getSrc()}, anchors);
    } else if (isa<ViewLikeOpInterface>(op)) {
      collectGMAnchorsFromValues(op->getResults(), anchors);
    }

    for (OpOperand *anchor : anchors) {
      if (!plannedAnchors.insert(anchor).second)
        continue;
      L2CacheHintPlan plan;
      if (failed(buildL2CacheHintPlan(anchor, plan)))
        return failure();
      plans.push_back(std::move(plan));
    }
  }
  if (plans.empty())
    return module.emitError(
        "l2_cache_mode=4 does not reach a supported GM load/store operand");

  // Validate every hint before mutating IR. Carrier hints are accepted only
  // when their annotated value reaches a direction-checked DMA anchor.
  for (Operation *op : hintedOps) {
    SmallVector<OpOperand *> anchors;
    if (auto anchor = getGMOperandForHint(op)) {
      anchors.push_back(*anchor);
    } else if (auto mark = dyn_cast<annotation::MarkOp>(op)) {
      collectGMAnchorsFromValues(ValueRange{mark.getSrc()}, anchors);
    } else if (isa<ViewLikeOpInterface>(op)) {
      collectGMAnchorsFromValues(op->getResults(), anchors);
    }
    bool reachesPlan = llvm::any_of(
        anchors, [&](OpOperand *anchor) { return plannedAnchors.contains(anchor); });
    if (!reachesPlan)
      return op->emitError(
          "l2_cache_mode=4 is not attached to a supported GM view path");
  }

  OpBuilder builder(module.getContext());
  FailureOr<memref::GlobalOp> global = getOrCreateL2Global(module, builder);
  if (failed(global))
    return failure();

  for (L2CacheHintPlan &plan : plans) {
    mlir::Location loc = plan.reinterpretCast.getLoc();
    builder.setInsertionPoint(plan.anchor->getOwner());
    auto gm = builder.create<memref::GetGlobalOp>(
        loc, getL2GlobalType(module.getContext()), (*global).getSymName());
    auto zero = builder.create<arith::ConstantIndexOp>(loc, 0);
    auto byteOffset = builder.create<memref::LoadOp>(
        loc, gm.getResult(), ValueRange{zero.getResult()});
    auto divisor = builder.create<arith::ConstantIntOp>(
        loc, plan.elementBytes, builder.getI64Type());
    auto elems = builder.create<arith::DivUIOp>(loc, byteOffset, divisor);
    auto encodedOffset = builder.create<arith::IndexCastOp>(
        loc, builder.getIndexType(), elems);

    OpFoldResult oldOffset = plan.reinterpretCast.getMixedOffsets().front();
    mlir::Value oldOffsetValue;
    if (auto attr = dyn_cast<mlir::Attribute>(oldOffset)) {
      oldOffsetValue = builder.create<arith::ConstantIndexOp>(
          loc, cast<IntegerAttr>(attr).getInt());
    } else {
      oldOffsetValue = cast<mlir::Value>(oldOffset);
    }
    auto offset = builder.create<arith::AddIOp>(loc, oldOffsetValue,
                                                encodedOffset.getResult());
    SmallVector<NamedAttribute> attrs(plan.reinterpretCast->getAttrs().begin(),
                                      plan.reinterpretCast->getAttrs().end());
    auto encodedCast = builder.create<memref::ReinterpretCastOp>(
        loc, plan.reinterpretCast.getType(), plan.reinterpretCast.getSource(),
        offset.getResult(), plan.reinterpretCast.getMixedSizes(),
        plan.reinterpretCast.getMixedStrides(), attrs);
    encodedCast->removeAttr(kL2CacheModeAttr);

    // Clone the path even when the original cast/view has multiple users. This
    // confines the encoded address to this hint's DMA operand and leaves all
    // unhinted uses on the original address.
    IRMapping mapping;
    mapping.map(plan.reinterpretCast.getResult(), encodedCast.getResult());
    for (Operation *view : llvm::reverse(plan.viewChain))
      builder.clone(*view, mapping);
    mlir::Value encodedAnchor = mapping.lookupOrDefault(plan.anchor->get());
    plan.anchor->set(encodedAnchor);
  }

  // The hint is now represented by the selected GM operand address.
  module.walk([&](Operation *op) { op->removeAttr(kL2CacheModeAttr); });
  return success();
}

std::vector<std::string>
getCompatibleOptions(const std::vector<std::string> &arguments,
                     const BiShengIRCompileMainConfig &config) {
  std::vector<std::string> options = arguments;
  // if enabled, skip debug options for compatibility.
  options = skipDebugOptions(options);
  // TODO: support hivmc compatibility for different versions
  auto version = bishengir::parseHIVMCVersion(config.getHIVMCVersion());
  if (!version.has_value() || version.value().empty()) {
    // null or empty version means we are using unknown or legacy hivmc
    // 1. legacy hivmc does not support debug or print
    options = skipDebugOptions(options);
    // 2. legacy hivmc has to manually enable triton compile pipeline
    if (config.getEnableTritonKernelCompile()) {
      options.push_back("--enable-triton-kernel-compile=true");
    }
    // 3. legacy hivmc has some unsupported options
    std::set<std::string> unsupported = {"enable-lir-compile",
                                         "enable-cpu-trace-intrinsic",
                                         "link-aicore-bitcode"};
    options = skipOptions(options, unsupported);
  } else if (version.value().getAsString() == "0.1.0") {
    // 0.1.0 version means we are using legacy hivmc
    std::set<std::string> unsupported = {"link-aicore-bitcode"};
    options = skipOptions(options, unsupported);
  }
  return options;
}

LogicalResult runExternalHIVMC(ModuleOp module,
                               const BiShengIRCompileMainConfig &config) {
  TempDirectoriesStore tempDirsStore;
  std::string inputFile = "module.hivm.opt.mlir";
  std::string outputFile = config.getOutputFile();
  auto inputFileHandler = getTempFile(inputFile, tempDirsStore);
  if (!inputFileHandler) {
    llvm::dbgs()
        << "[ERROR] Failed to create temporary input file needed to run "
           "hivm compile.\n";
    return failure();
  }
  inputFile = inputFileHandler->outputFilename();

  if (failed(consumeL2CacheHints(module)))
    return failure();

  std::string content;
  llvm::raw_string_ostream buffer(content);
  module.print(buffer,
               mlir::OpPrintingFlags().enableDebugInfo(
                   config.getEnableSanitizer() || config.getEnableDebugInfo()));

  // TODO: Once version 0.2.0 is released, warning should be added to notice the
  // user upgrade the hivmc version.
  // TODO: Once version 0.1.0 is not supported, the following regex should be
  // removed.
  std::regex re("hacc\\.(hivmc_compatible_print|hivmc_version)[^,]*,");
  std::string modified = std::regex_replace(content, re, "");

  inputFileHandler->os() << modified;
  inputFileHandler->os().flush();

  std::vector<std::string> arguments;
  arguments.emplace_back("");
  arguments.push_back(inputFile);

  auto hivmcArgs = getCompatibleOptions(config.getHIVMCArgsDashDash(), config);
  arguments.insert(arguments.end(), hivmcArgs.begin(), hivmcArgs.end());
  arguments.emplace_back("-o");
  arguments.push_back(outputFile);
  SmallVector<StringRef> argumentsRef(arguments.begin(), arguments.end());
  if (failed(execute(getHIVMCName(), getBiShengInstallPath(), argumentsRef))) {
    return failure();
  }

  return success();
}

} // namespace

FailureOr<OwningModuleRef>
bishengir::runBiShengIRPipeline(ModuleOp mod,
                                BiShengIRCompileMainConfig config) {
  MLIRContext *ctx = mod->getContext();
  mlir::DiagnosticEngine &diagEngine = ctx->getDiagEngine();
  std::vector<std::unique_ptr<Diagnostic>> collectedDiagnostics;

  // Resolve hivmc backward compatibility
  auto versionMaybe = detectHIVMCVersion(getHIVMCName());
  if (versionMaybe.has_value()) {
    llvm::VersionTuple hivmcVersion = versionMaybe.value();
    config.setHIVMCVersion(hivmcVersion.getAsString());
  } else {
    // Not return failure directly to support run compile without hivmc.
    // Let user to specify hivmc version by commandline.
    llvm::dbgs() << "[WARNING] Failed to detect hivmc version for backward "
                    "compatibility\n";
  }

  // Collect diagnostics and emit them afterwards because we have tuning
  // mechanism.
  auto handlerID = diagEngine.registerHandler([&](Diagnostic &diag) {
    collectedDiagnostics.push_back(
        std::make_unique<Diagnostic>(std::move(diag)));
  });

  RetriablePassManager retriablePm(config, ctx);
  if (config.getEnableTritonKernelCompile()) {
    retriablePm.addPolicy(std::make_unique<UbOverflowRetryPolicy>());
    retriablePm.addPolicy(std::make_unique<CbufOverflowRetryPolicy>());
    retriablePm.addPolicy(std::make_unique<CcOverflowRetryPolicy>());
  }

  if (config.getEnableTuningMode() && !config.getEnableTritonKernelCompile()) {
    retriablePm.addPolicy(std::make_unique<TuningRetryPolicy>());
  }

  std::vector<AppliedCompileFallback> retriablePipelineFallbacks;
  auto buildPipeline = std::bind(buildBiShengHIRPipeline, std::placeholders::_1,
                                 std::cref(config));
  bool hirCompileSuccess =
      succeeded(retriablePm.runWithRetry(mod, buildPipeline, "BiShengHIR",
                                         collectedDiagnostics,
                                         retriablePipelineFallbacks));

  // Restore to the default handler.
  diagEngine.eraseHandler(handlerID);
  for (auto &diag : llvm::reverse(collectedDiagnostics)) {
    [[maybe_unused]] auto res = handleDiagnostic(*diag);
  }

  if (!hirCompileSuccess) {
    RetriablePassManager::emitFallbackSummary(retriablePipelineFallbacks,
                                              /*compilationSucceeded=*/false);
    for (auto &diag : llvm::reverse(collectedDiagnostics)) {
      diagEngine.emit(std::move(*diag));
    }
    return failure();
  }

  RetriablePassManager::emitFallbackSummary(retriablePipelineFallbacks,
                                            /*compilationSucceeded=*/true);

  if (config.shouldEnableCPURunner()) {
    auto outputFile = config.getOutputFile();
    std::string errorMessage;
    std::unique_ptr<llvm::ToolOutputFile> fileHandle =
        mlir::openOutputFile(outputFile, &errorMessage);
    if (!fileHandle) {
      llvm::errs() << "[ERROR] Failed to open: " << outputFile
                   << " error message: " << errorMessage << "\n";
      return failure();
    }
    mod.print(fileHandle->os(),
              mlir::OpPrintingFlags().enableDebugInfo(
                  config.getEnableSanitizer() || config.getEnableDebugInfo()));
    fileHandle->keep();

    return OwningModuleRef(mod);
  }

  // Add bitcode path attributes from ../lib/*.bc to ModuleOp before hivmc.
  // Skip for legacy hivmc (version 0.1.0 or empty) which does not support it.
  addBitcodeAttrsToModule(mod, config.getExecutablePath(), config);

  auto res = runExternalHIVMC(mod, config);
  if (res.failed()) {
    mod.emitError("External hivmc run fails, returning module before running "
                  "external compiler");
    return failure();
  }

  return OwningModuleRef(mod);
}
