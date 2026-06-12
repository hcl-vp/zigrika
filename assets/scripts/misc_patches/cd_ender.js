const ModelManager_1 = require("../Game/Manager/ModelManager.js");
const EventSystem_1 = require("../Game/Common/Event/EventSystem.js");
const EventDefine_1 = require("../Game/Common/Event/EventDefine.js");
for (const item of ModelManager_1.ModelManager.SceneTeamModel.GetTeamItems()) {
  const entity = item.EntityHandle?.Entity;
  if (entity?.Valid) {
    const skill_cd_comp = entity.GetComponent(223);
    if (skill_cd_comp) {
      for (const skill_id of skill_cd_comp.qzr.keys()) {
        skill_cd_comp.ModifyCdTime([String(skill_id)], -999999, -1);
      }
    }
  }

  for (const item of ModelManager_1.ModelManager.SceneTeamModel.aPr) {
    const entity = item.EntityHandle?.Entity;
    if (!entity?.Valid) continue;
    const comp = entity.CheckGetComponent(103);
    if (!comp) continue;
    comp.Irn = -1;
    EventSystem_1.EventSystem.EmitWithTarget(
      entity,
      EventDefine_1.EEventName.OnChangeRoleCoolDownChanged,
      0,
    );
  }
}
