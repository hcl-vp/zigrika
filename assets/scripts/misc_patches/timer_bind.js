const EventSystem_1 = require("../Game/Common/Event/EventSystem.js");
const EventDefine_1 = require("../Game/Common/Event/EventDefine.js");
const InputDistributeController_1 = require("../Game/Ui/InputDistribute/InputDistributeController.js");
const InputMappingsDefine_1 = require("../Game/Ui/InputDistribute/InputMappingsDefine.js");
const ControllerHolder_1 = require("../Game/Manager/ControllerHolder.js");
const Time_1 = require("../Core/Common/Time.js");
const TimeUtil_1 = require("Game/Common/TimeUtil.js");
let startServerTs = 0;
let lastServerTs = 0;
let elapsedMs = 0;
let tickHandle = null;

function StartCountUp() {
  if (tickHandle !== null) {
    elapsedMs = 0;
    EventSystem_1.EventSystem.Emit(
      EventDefine_1.EEventName.OnGamePlayCdChanged,
      0.001,
      0,
    );
    return;
  }
  startServerTs = lastServerTs = TimeUtil_1.TimeUtil.GetServerTimeStamp();
  elapsedMs = 0;

  ControllerHolder_1.ControllerHolder.GenericPromptController.ShowPromptByItsType(
    8,
    undefined,
    undefined,
    undefined,
    ["00", "00", "00"],
    19,
  );
  EventSystem_1.EventSystem.Emit(
    EventDefine_1.EEventName.OnGamePlayCdChanged,
    0.001,
    0,
  );

  tickHandle = setInterval(OnTick, 0);
}

function OnTick() {
  const now = TimeUtil_1.TimeUtil.GetServerTimeStamp();
  const delta = now - lastServerTs;
  lastServerTs = now;

  if (Time_1.Time.FlowTimeDilation !== 0) {
    elapsedMs += delta * Time_1.Time.TimeDilation;
  }

  const elapsedSec = elapsedMs / 1000;

  EventSystem_1.EventSystem.Emit(
    EventDefine_1.EEventName.OnGamePlayCdChanged,
    elapsedSec,
    0,
  );
}

function StopCountUp() {
  if (tickHandle === null) return;
  clearInterval(tickHandle);
  tickHandle = null;

  EventSystem_1.EventSystem.Emit(
    EventDefine_1.EEventName.OnGamePlayCdChanged,
    0,
    0,
  );

  return elapsedMs / 1000;
}

const Start = async (_, state) => {
  if (state !== 1) return;

  StartCountUp();
};

const Stop = async (_, state) => {
  if (state !== 1) return;

  StopCountUp();
};

InputDistributeController_1.InputDistributeController.BindAction(
  InputMappingsDefine_1.actionMappings.UI键盘Y手柄特右,
  Start,
);
InputDistributeController_1.InputDistributeController.BindAction(
  InputMappingsDefine_1.actionMappings.UI键盘Z手柄LT,
  Stop,
);
