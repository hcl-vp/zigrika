const ModelManager_1 = require("../Game/Manager/ModelManager.js");
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
}
