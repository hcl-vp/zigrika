setTimeout(() => {
  const { CreatureModel } = require("../Game/World/Model/CreatureModel.js");
  const { ModelManager } = require("../Game/Manager/ModelManager.js");
  const {
    configAkiMapAll,
  } = require("../Core/Define/ConfigQuery/AkiMapAll.js");

  const getEntityData = CreatureModel.prototype.GetEntityData;
  const sourceMapByEntityId = globalThis.__zigrikaEntitySourceMap ?? new Map();
  globalThis.__zigrikaEntitySourceMap = sourceMapByEntityId;
  globalThis.__zigrikaSetEntitySourceMap = (pbDataId, mapId) => {
    sourceMapByEntityId.set(pbDataId, mapId);
  };
  let mapIds;

  const getMapIds = () => {
    mapIds ??= (configAkiMapAll.GetConfigList() ?? []).map((map) => map.MapId);
    return mapIds;
  };

  CreatureModel.prototype.GetEntityData = function (pbDataId, mapId) {
    const entityData = getEntityData.call(this, pbDataId, mapId);
    if (entityData || pbDataId === undefined) return entityData;

    const currentMapId = ModelManager.GameModeModel.MapId;
    const checkedMapId = mapId ?? currentMapId;
    const cachedMapId = sourceMapByEntityId.get(pbDataId);
    if (cachedMapId !== undefined && cachedMapId !== checkedMapId) {
      const cachedEntityData = getEntityData.call(this, pbDataId, cachedMapId);
      if (cachedEntityData) return cachedEntityData;
      sourceMapByEntityId.delete(pbDataId);
    }

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
