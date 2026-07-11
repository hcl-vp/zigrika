const sourceMapByEntityId = globalThis.__zigrikaEntitySourceMap ?? new Map();
const repeatBossEntityIds =
  globalThis.__zigrikaRepeatBossEntityIds ?? new Set();
globalThis.__zigrikaEntitySourceMap = sourceMapByEntityId;
globalThis.__zigrikaRepeatBossEntityIds = repeatBossEntityIds;
globalThis.__zigrikaSetEntitySourceMap = (pbDataId, mapId, repeatBoss = false) => {
  sourceMapByEntityId.set(pbDataId, mapId);
  if (repeatBoss) repeatBossEntityIds.add(pbDataId);
  else repeatBossEntityIds.delete(pbDataId);
};

setTimeout(() => {
  if (globalThis.__zigrikaGlobalSpawnPatched) return;
  globalThis.__zigrikaGlobalSpawnPatched = true;

  const { CreatureModel } = require("../Game/World/Model/CreatureModel.js");
  const { ModelManager } = require("../Game/Manager/ModelManager.js");
  const {
    configAkiMapAll,
  } = require("../Core/Define/ConfigQuery/AkiMapAll.js");
  const {
    configLevelEntityConfigByMapIdAndEntityId,
  } = require("../Core/Define/ConfigQuery/LevelEntityConfigByMapIdAndEntityId.js");

  const getEntityData = CreatureModel.prototype.GetEntityData;
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
      sourceMapByEntityId.delete(entityId);
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
      sourceMapByEntityId.delete(pbDataId);
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
}, 200);
