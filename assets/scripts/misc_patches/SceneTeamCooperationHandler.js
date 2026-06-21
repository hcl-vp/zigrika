const {
  SceneTeamCooperationHandler,
} = require("Game/Module/Battle/Cooperation/CooperationHandler/SceneTeamCooperationHandler.js");
const SceneTeamController_1 = require("../Game/Module/SceneTeam/SceneTeamController.js");
const SceneTeamDefine_1 = require("../Game/Module/SceneTeam/SceneTeamDefine.js");
const ScrollingTipsController_1 = require("Game/Module/ScrollingTips/ScrollingTipsController.js");

const CONTROLLER_TYPE = "{CONTROLLER_TYPE}";

SceneTeamCooperationHandler.prototype.Trigger = function (e, r) {
  var r_EntityHandle = r.EntityHandle;
  let n = r_EntityHandle.Entity.GetComponent(108).IsInQte;
  var r_EntityHandle =
    r_EntityHandle.Entity.CheckGetComponent(103).IsChangeRoleCoolDown();
  if (!n) {
    if (CONTROLLER_TYPE !== "2" && r_EntityHandle) {
      if (CONTROLLER_TYPE === "0")
        ScrollingTipsController_1.ScrollingTipsController.ShowTipsById(
          "EditBattleTeamInCD",
        );

      return false;
    }
    n = e.EntityHandle.Entity.GetComponent(221);
    if (n.HasTag(-2044964178) && n.HasAnyTag(SceneTeamDefine_1.beHitTagList)) {
      if (Log_1.Log.CheckInfo()) {
        Log_1.Log.Info("SceneTeam", 48, "被击硬直时间无法换人", [
          "roleId",
          e.GetConfigId,
        ]);
      }

      return false;
    }
  }

  SceneTeamController_1.SceneTeamController.RequestChangeRole(
    r.GetCreatureDataId(),
    {
      FilterSameRole: true,
      GoDownWaitSkillEnd: true,
      ForceInheritTransform: false,
    },
  );

  return true;
};
