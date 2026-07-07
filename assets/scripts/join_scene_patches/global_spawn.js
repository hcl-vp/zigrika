const sourceMapByEntityId = globalThis.__zigrikaEntitySourceMap ?? new Map();
globalThis.__zigrikaEntitySourceMap = sourceMapByEntityId;
globalThis.__zigrikaSetEntitySourceMap = (pbDataId, mapId) => {
  sourceMapByEntityId.set(pbDataId, mapId);
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
  let mapIds;

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
    if (entityData || pbDataId === undefined) return entityData;

    const currentMapId = ModelManager.GameModeModel.MapId;
    const checkedMapId = mapId ?? currentMapId;
    const cachedMapId = getCachedMapId(pbDataId, checkedMapId);
    if (cachedMapId !== undefined) {
      const cachedEntityData = getEntityData.call(this, pbDataId, cachedMapId);
      if (cachedEntityData) return cachedEntityData;
      sourceMapByEntityId.delete(pbDataId);
    }

    if (!sourceMapByEntityId.has(pbDataId)) return entityData;

    for (const sourceMapId of getMapIds()) {
      if (sourceMapId === checkedMapId) continue;

      const sourceEntityData = getEntityData.call(this, pbDataId, sourceMapId);
      if (sourceEntityData) {
        sourceMapByEntityId.set(pbDataId, sourceMapId);
        return sourceEntityData;
      }
    }

    return entityData;
  };
}, 200);
