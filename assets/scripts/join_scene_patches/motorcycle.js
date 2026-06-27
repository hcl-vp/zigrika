setTimeout(() => {
  const {
    VehicleController,
  } = require("../Game/NewWorld/Vehicle/Controller/VehicleController.js");
  const { Global } = require("../Game/Global.js");
  const { TeleportCore } = require("../Game/Module/Teleport/TeleportCore.js");

  function leaveCurrentVehicle(reason) {
    Global.BaseCharacter?.CharacterActorComponent?.Entity?.CheckGetComponent(246)?.VehicleEntity?.GetComponent(250)?.TryLeaveAllAtOnce(0, reason);
  }

  VehicleController.CheckMotorAllowed = function () {
    return true;
  };

  const originalTeleportPlayerWithLoading = TeleportCore.prototype.TeleportPlayerWithLoading;
  TeleportCore.prototype.TeleportPlayerWithLoading = async function (...args) {
    leaveCurrentVehicle("TeleportPlayerWithLoading");
    return originalTeleportPlayerWithLoading.apply(this, args);
  };

  const originalTeleportPlayerNoLoading = TeleportCore.prototype.TeleportPlayerNoLoading;
  TeleportCore.prototype.TeleportPlayerNoLoading = async function (...args) {
    leaveCurrentVehicle("TeleportPlayerNoLoading");
    return originalTeleportPlayerNoLoading.apply(this, args);
  };

  TeleportCore.prototype.HandleTakeVehicleDuringTeleport = async function () {
    leaveCurrentVehicle("HandleTakeVehicleDuringTeleport");
  };
}, 200);
