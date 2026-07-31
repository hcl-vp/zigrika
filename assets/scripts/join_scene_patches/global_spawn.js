const sourceMapByEntityId = globalThis.__zigrikaEntitySourceMap ?? new Map();
const repeatBossEntityIds =
  globalThis.__zigrikaRepeatBossEntityIds ?? new Set();
const sourceOwnersByEntityId =
  globalThis.__zigrikaEntitySourceOwners ?? new Map();
globalThis.__zigrikaEntitySourceMap = sourceMapByEntityId;
globalThis.__zigrikaRepeatBossEntityIds = repeatBossEntityIds;
globalThis.__zigrikaEntitySourceOwners = sourceOwnersByEntityId;

const clearEntitySourceMap = (pbDataId) => {
  sourceMapByEntityId.delete(pbDataId);
  repeatBossEntityIds.delete(pbDataId);
  sourceOwnersByEntityId.delete(pbDataId);
};
const clearEntitySourceMaps = () => {
  sourceMapByEntityId.clear();
  repeatBossEntityIds.clear();
  sourceOwnersByEntityId.clear();
};
const removeEntitySourceOwner = (pbDataId, creatureDataId) => {
  const owners = sourceOwnersByEntityId.get(pbDataId);
  if (!owners?.delete(creatureDataId)) return false;
  if (owners.size === 0) clearEntitySourceMap(pbDataId);
  return true;
};

globalThis.__zigrikaClearEntitySourceMap = clearEntitySourceMap;
globalThis.__zigrikaClearEntitySourceMaps = clearEntitySourceMaps;
globalThis.__zigrikaRemoveEntitySourceOwner = removeEntitySourceOwner;
globalThis.__zigrikaSetEntitySourceMap = (
  pbDataId,
  mapId,
  repeatBoss = false,
  creatureDataId
) => {
  const routeChanged =
    sourceMapByEntityId.has(pbDataId) &&
    (sourceMapByEntityId.get(pbDataId) !== mapId ||
      repeatBossEntityIds.has(pbDataId) !== repeatBoss);
  if (routeChanged) sourceOwnersByEntityId.delete(pbDataId);

  sourceMapByEntityId.set(pbDataId, mapId);
  if (repeatBoss) repeatBossEntityIds.add(pbDataId);
  else repeatBossEntityIds.delete(pbDataId);

  if (creatureDataId !== undefined) {
    let owners = sourceOwnersByEntityId.get(pbDataId);
    if (!owners) {
      owners = new Set();
      sourceOwnersByEntityId.set(pbDataId, owners);
    }
    owners.add(creatureDataId);
  }
};

const patchState =
  globalThis.__zigrikaGlobalSpawnPatchState ??
  {
    installed: globalThis.__zigrikaGlobalSpawnPatched === true,
    installing: false,
    retryTimer: undefined,
    attempts: 0,
  };
globalThis.__zigrikaGlobalSpawnPatchState = patchState;
globalThis.__zigrikaGlobalSpawnPatched = patchState.installed;

const installGlobalSpawnPatch = () => {

  const { CreatureModel } = require("../Game/World/Model/CreatureModel.js");
  const { ModelManager } = require("../Game/Manager/ModelManager.js");
  const {
    configAkiMapAll,
  } = require("../Core/Define/ConfigQuery/AkiMapAll.js");
  const {
    configLevelEntityConfigByMapIdAndEntityId,
  } = require("../Core/Define/ConfigQuery/LevelEntityConfigByMapIdAndEntityId.js");

  if (
    typeof CreatureModel?.prototype?.GetEntityData !== "function" ||
    typeof CreatureModel.prototype.RemoveEntity !== "function" ||
    typeof CreatureModel.prototype.OnLeaveLevel !== "function" ||
    typeof configAkiMapAll?.GetConfigList !== "function" ||
    typeof configLevelEntityConfigByMapIdAndEntityId?.GetConfig !== "function"
  ) {
    throw new TypeError("global spawn client methods are unavailable");
  }

  const getEntityData = CreatureModel.prototype.GetEntityData;
  const removeEntity = CreatureModel.prototype.RemoveEntity;
  const onLeaveLevel = CreatureModel.prototype.OnLeaveLevel;
  const getLevelEntityConfig =
    configLevelEntityConfigByMapIdAndEntityId.GetConfig;
  const repeatBossEntityData = new WeakMap();
  const storyBossTag =
    "\u602a\u7269.common.\u5173\u5361.\u96be\u5ea6AI\u5206\u7c7b.\u5267\u60c5";
  const repeatBossTag =
    "\u602a\u7269.common.\u5173\u5361.\u96be\u5ea6AI\u5206\u7c7b.\u9886\u4e3b\u590d\u5237";
  let mapIds;

  const applyRepeatBossStartup = (pbDataId, entityData) => {
    if (!entityData || !repeatBossEntityIds.has(pbDataId)) return entityData;

    const cached = repeatBossEntityData.get(entityData);
    if (cached) return cached;

    const monsterComponent = entityData.GetMonsterComponent?.();
    const initTags = monsterComponent?.InitGasTag;
    if (!initTags?.includes(storyBossTag)) return entityData;

    const patchedMonsterComponent = new Proxy(monsterComponent, {
      get(target, property, receiver) {
        if (property === "InitGasTag") {
          return initTags.map((tag) =>
            tag === storyBossTag ? repeatBossTag : tag
          );
        }
        return Reflect.get(target, property, receiver);
      },
    });
    const patchedEntityData = new Proxy(entityData, {
      get(target, property, receiver) {
        if (property === "GetMonsterComponent") {
          return () => patchedMonsterComponent;
        }
        return Reflect.get(target, property, receiver);
      },
    });
    repeatBossEntityData.set(entityData, patchedEntityData);
    return patchedEntityData;
  };

  const getMapIds = () => {
    mapIds ??= (configAkiMapAll.GetConfigList() ?? []).map((map) => map.MapId);
    return mapIds;
  };

  const getCachedMapId = (pbDataId, checkedMapId) => {
    const cachedMapId = sourceMapByEntityId.get(pbDataId);
    return cachedMapId !== undefined && cachedMapId !== checkedMapId
      ? cachedMapId
      : undefined;
  };

  configLevelEntityConfigByMapIdAndEntityId.GetConfig = function (
    mapId,
    entityId,
    useCache = true
  ) {
    const cachedMapId = getCachedMapId(entityId, mapId);
    if (cachedMapId !== undefined) {
      const cachedConfig = getLevelEntityConfig.call(
        this,
        cachedMapId,
        entityId,
        useCache
      );
      if (cachedConfig) return cachedConfig;
      clearEntitySourceMap(entityId);
    }

    return getLevelEntityConfig.call(this, mapId, entityId, useCache);
  };

  CreatureModel.prototype.GetEntityData = function (pbDataId, mapId) {
    const entityData = getEntityData.call(this, pbDataId, mapId);
    if (entityData || pbDataId === undefined) {
      return applyRepeatBossStartup(pbDataId, entityData);
    }

    const currentMapId = ModelManager.GameModeModel.MapId;
    const checkedMapId = mapId ?? currentMapId;
    const cachedMapId = getCachedMapId(pbDataId, checkedMapId);
    if (cachedMapId !== undefined) {
      const cachedEntityData = getEntityData.call(this, pbDataId, cachedMapId);
      if (cachedEntityData) {
        return applyRepeatBossStartup(pbDataId, cachedEntityData);
      }
      clearEntitySourceMap(pbDataId);
    }

    if (!sourceMapByEntityId.has(pbDataId)) return entityData;

    for (const sourceMapId of getMapIds()) {
      if (sourceMapId === checkedMapId) continue;

      const sourceEntityData = getEntityData.call(this, pbDataId, sourceMapId);
      if (sourceEntityData) {
        sourceMapByEntityId.set(pbDataId, sourceMapId);
        return applyRepeatBossStartup(pbDataId, sourceEntityData);
      }
    }

    return entityData;
  };

  CreatureModel.prototype.RemoveEntity = function (creatureDataId, reason) {
    const entity = this.GetEntity(creatureDataId);
    const pbDataId = this.GetPbDataIdByEntity(entity);
    const removed = removeEntity.call(this, creatureDataId, reason);
    if (removed && sourceMapByEntityId.has(pbDataId)) {
      removeEntitySourceOwner(pbDataId, creatureDataId);
    }
    return removed;
  };

  CreatureModel.prototype.OnLeaveLevel = function (...args) {
    clearEntitySourceMaps();
    return onLeaveLevel.apply(this, args);
  };
};

const scheduleGlobalSpawnPatch = () => {
  if (
    patchState.installed ||
    patchState.installing ||
    patchState.retryTimer !== undefined ||
    patchState.attempts >= 10
  ) {
    return;
  }

  patchState.retryTimer = setTimeout(() => {
    patchState.retryTimer = undefined;
    if (patchState.installed) return;

    patchState.installing = true;
    try {
      installGlobalSpawnPatch();
      patchState.installed = true;
      patchState.attempts = 0;
      globalThis.__zigrikaGlobalSpawnPatched = true;
    } catch {
      patchState.attempts += 1;
    } finally {
      patchState.installing = false;
    }

    if (!patchState.installed) scheduleGlobalSpawnPatch();
  }, 200);
};

if (
  !patchState.installed &&
  !patchState.installing &&
  patchState.retryTimer === undefined
) {
  patchState.attempts = 0;
  scheduleGlobalSpawnPatch();
}
