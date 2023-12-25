#include "api/BlockEntityAPI.h"
#include "api/APIHelp.h"
#include "api/BaseAPI.h"
#include "api/BlockAPI.h"
#include "api/NativeAPI.h"
#include "api/NbtAPI.h"
#include "ll/api/memory/Memory.h"
#include "ll/api/service/GlobalService.h"
#include "main/Global.hpp"
#include "mc/dataloadhelper/DataLoadHelper.h"
#include "mc/dataloadhelper/DefaultDataLoadHelper.h"
#include "mc/nbt/CompoundTag.h"
#include "mc/world/level/block/actor/BlockActor.h"

//////////////////// Class Definition ////////////////////

ClassDefine<BlockEntityClass> BlockEntityClassBuilder =
    defineClass<BlockEntityClass>("LLSE_BlockEntity")
        .constructor(nullptr)
        .instanceFunction("asPointer", &BlockEntityClass::asPointer)

        .instanceProperty("name", &BlockEntityClass::getName)
        .instanceProperty("pos", &BlockEntityClass::getPos)
        .instanceProperty("type", &BlockEntityClass::getType)

        .instanceFunction("setNbt", &BlockEntityClass::setNbt)
        .instanceFunction("getNbt", &BlockEntityClass::getNbt)
        .instanceFunction("getBlock", &BlockEntityClass::getBlock)
        .build();

//////////////////// Classes ////////////////////

BlockEntityClass::BlockEntityClass(BlockActor *be, int dim)
    : ScriptClass(ScriptClass::ConstructFromCpp<BlockEntityClass>{}),
      blockEntity(be), dim(dim) {}

Local<Object> BlockEntityClass::newBlockEntity(BlockActor *be, int dim) {
  auto newp = new BlockEntityClass(be, dim);
  return newp->getScriptObject();
}

// 生成函数
BlockActor *BlockEntityClass::extract(Local<Value> v) {
  if (EngineScope::currentEngine()->isInstanceOf<BlockEntityClass>(v))
    return EngineScope::currentEngine()
        ->getNativeInstance<BlockEntityClass>(v)
        ->get();
  else
    return nullptr;
}

// 成员函数
Local<Value> BlockEntityClass::asPointer(const Arguments &args) {
  try {
    return NativePointer::newNativePointer(blockEntity);
  }
  CATCH("Fail in asPointer!")
}

Local<Value> BlockEntityClass::getPos() {
  try {
    return IntPos::newPos(blockEntity->getPosition(), dim);
  }
  CATCH("Fail in getBlockEntityPos!")
}

Local<Value> BlockEntityClass::getName() {
  try {
    return String::newString(blockEntity->getName());
  }
  CATCH("Fail in getName!")
}

Local<Value> BlockEntityClass::getType() {
  try {
    return Number::newNumber((int)blockEntity->getType());
  }
  CATCH("Fail in getBlockEntityType!")
}

Local<Value> BlockEntityClass::getNbt(const Arguments &args) {
  try {
    return NbtCompoundClass::pack(std::move(
        blockEntity->saveToNbt())); // Not sure is that will get right value
  }
  CATCH("Fail in getNbt!")
}

Local<Value> BlockEntityClass::setNbt(const Arguments &args) {
  CHECK_ARGS_COUNT(args, 1);

  try {
    auto nbt = NbtCompoundClass::extract(args[0]);
    if (!nbt)
      return Local<Value>(); // Null
    void *helper = LL_RESOLVE_SYMBOL("??_7DefaultDataLoadHelper@@6B@");
    blockEntity->load(*ll::Global<Level>, *nbt, (DataLoadHelper &)helper);
    return Boolean::newBoolean(true);
  }
  CATCH("Fail in setNbt!")
}

Local<Value> BlockEntityClass::getBlock(const Arguments &args) {
  try {
    BlockPos bp = blockEntity->getPosition();
    return BlockClass::newBlock(Level::getBlock(bp, dim), &bp, dim);
  }
  CATCH("Fail in getBlock!")
}