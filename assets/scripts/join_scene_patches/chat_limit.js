const CommonParamById_1 = require("../Core/Define/ConfigCommon/CommonParamById.js");
const getIntConfig = CommonParamById_1.configCommonParamById.GetIntConfig;

CommonParamById_1.configCommonParamById.GetIntConfig = function (key) {
  if (key === "chat_character") return 777777;
  return getIntConfig.call(this, key);
};
