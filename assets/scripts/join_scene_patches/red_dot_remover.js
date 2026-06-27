const RedDotBase_1 = require("../Game/RedDot/RedDotBase.js");
const PersonalDefine_1 = require("../Game/Module/Personal/Model/PersonalDefine.js");
const PersonalPlayerTitleItem_1 = require("../Game/Module/Personal/View/PersonalPlayerTitleItem.js");

RedDotBase_1.RedDotData.StateByGm = false;
PersonalDefine_1.PersonalPlayerTitleData.prototype.GetIsShowRedDot = function () {
  return false;
};

PersonalPlayerTitleItem_1.PersonalPlayerTitleItem.prototype.BNe = function () {
  this.GetItem(0).SetUIActive(false);
};

const setUiItem = RedDotBase_1.RedDotData.prototype.SetUiItem;
RedDotBase_1.RedDotData.prototype.SetUiItem = function (item) {
  setUiItem.call(this, item);
  item?.IsValid?.() && item.SetUIActive(false);
};

RedDotBase_1.RedDotData.prototype.UpdateRedDotUIActive = function () {
  this.SetUIItemActive(false);
};

RedDotBase_1.RedDotData.prototype.SetUIItemActive = function () {
  for (const item of this.GetUiItemSet()) {
    item.IsValid() && item.SetUIActive(false);
  }
};
