// temp patch just to get it working
setTimeout(() => {
  const { GameSettingsUtils } = require("../Game/GameSettings/GameSettingsUtils.js");
  const { LocalStorage } = require("../Game/Common/LocalStorage.js");
  const {
    ELocalStoragePlayerKey,
  } = require("../Game/Common/LocalStorageDefine.js");
  const { ModelManager } = require("../Game/Manager/ModelManager.js");
  const {
    ControllerHolder,
  } = require("../Game/Manager/ControllerHolder.js");

  if (GameSettingsUtils.__voiceLanguageFix) return;

  const applyLanguageAudio = GameSettingsUtils.ApplyLanguageAudio;
  if (typeof applyLanguageAudio !== "function") return;

  GameSettingsUtils.__voiceLanguageFix = true;
  GameSettingsUtils.ApplyLanguageAudio = function (...args) {
    const roleLang = ModelManager.RoleLangCustomModel;

    LocalStorage.SetPlayer(ELocalStoragePlayerKey.RoleVoiceMap, new Map());
    if (roleLang) roleLang.KDp = false;

    const result = applyLanguageAudio.apply(this, args);

    LocalStorage.SetPlayer(ELocalStoragePlayerKey.RoleVoiceMap, new Map());
    ControllerHolder.RoleController?.RequestPlayerRoleVoiceSet?.([]);

    return result;
  };
}, 200);
