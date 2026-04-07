const PositionPanel_1 = require("../Game/Module/BattleUi/Views/BattleChildViewPanel/PositionPanel.js");
const _OnAfterTick =
  PositionPanel_1.PositionPanel.prototype.OnAfterTickBattleChildViewPanel;

PositionPanel_1.PositionPanel.prototype.OnAfterTickBattleChildViewPanel =
  function (e) {
    _OnAfterTick.call(this, e);
    this.pet?.SetUIActive(false);
    this.bac?.SetUIActive(false);
    // this.vet?.SetUIActive(false);
  };
