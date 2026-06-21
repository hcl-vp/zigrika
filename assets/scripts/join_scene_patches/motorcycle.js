setTimeout(() => {
  const patchMotorAllowed = () => {
    const {
      VehicleController,
    } = require("../Game/NewWorld/Vehicle/Controller/VehicleController.js");
    if (VehicleController.__zigrikaOriginalCheckMotorAllowed) return;

    VehicleController.__zigrikaOriginalCheckMotorAllowed = VehicleController.CheckMotorAllowed;
    VehicleController.CheckMotorAllowed = function () {
      return true;
    };
  };

  const patchAutopilot = () => {
    const { AutoPilotModel } = require("../Game/Module/AutoPilot/AutoPilotModel.js");

    if (!AutoPilotModel.prototype.__zigrikaOriginalCheckCommonConditions) {
      const originalCheckCommonConditions = AutoPilotModel.prototype.CheckCommonConditions;
      AutoPilotModel.prototype.__zigrikaOriginalCheckCommonConditions = originalCheckCommonConditions;
      AutoPilotModel.prototype.CheckCommonConditions = function (...args) {
        const result = originalCheckCommonConditions.apply(this, args);
        return result === false ? false : true;
      };
    }

  };

  const patchFollowShooter = () => {
    const {
      FollowShooterComponent,
    } = require("../Game/NewWorld/Character/Common/Component/Abilities/Follow/FollowShooterComponent.js");
    if (FollowShooterComponent.prototype.__zigrikaOriginalSetEnable) return;

    const originalSetEnable = FollowShooterComponent.prototype.SetEnable;
    FollowShooterComponent.prototype.__zigrikaOriginalSetEnable = originalSetEnable;
    FollowShooterComponent.prototype.SetEnable = function (enabled, priority, reason = "") {
      if (priority === 2 && this.H9g?.m7 && !this.H9g.m7.has(priority)) {
        return false;
      }

      return originalSetEnable.call(this, enabled, priority, reason);
    };
  };

  const patchRideSharing = () => {
    const {
      VehicleController,
    } = require("../Game/NewWorld/Vehicle/Controller/VehicleController.js");
    const {
      VehicleInfoDefines,
    } = require("../Game/NewWorld/Vehicle/Common/VehicleInfoDefines.js");
    const { ModelManager } = require("../Game/Manager/ModelManager.js");
    if (VehicleController.__zigrikaOriginalVehicleUpdateEntity) return;

    const originalVehicleUpdateEntity = VehicleController.VehicleUpdateEntity;
    const pending = new Set();
    const maxReadyChecks = 30;
    const readyCheckDelayMs = 100;

    const getActorMesh = (entity) =>
      entity?.GetComponent(3)?.Actor?.Mesh ||
      entity?.GetComponent(1)?.Actor?.Mesh ||
      entity?.GetComponent(2)?.Actor?.Mesh ||
      entity?.GetComponent(250)?.Actor?.Mesh;

    const hasSeatSocket = (mesh, seat) => {
      if (!mesh) return false;
      if (seat !== 1) return true;

      const socket = VehicleInfoDefines.GetSeatSocketName(seat);
      if (typeof mesh.DoesSocketExist === "function") return mesh.DoesSocketExist(socket);
      if (typeof mesh.K2_DoesSocketExist === "function") return mesh.K2_DoesSocketExist(socket);
      return true;
    };

    const isRideSharingUpdate = (info) => {
      if (info?.Seat !== 1) return false;
      const rideShare = ModelManager.VehicleModel.RideSharingInfoMap.get(info.Seat);
      if (rideShare?.RoleCreatureId === info.EntityCreatureId) return true;

      const passenger = ModelManager.CreatureModel.GetEntity(info.EntityCreatureId)?.Entity;
      const vehicle = ModelManager.CreatureModel.GetEntity(info.VehicleCreatureId)?.Entity;
      return !!(passenger?.GetComponent(247) || vehicle?.GetComponent(249)?.VehicleType === "Motorcycle");
    };

    const isReady = (info) => {
      const passenger = ModelManager.CreatureModel.GetEntity(info.EntityCreatureId)?.Entity;
      const vehicle = ModelManager.CreatureModel.GetEntity(info.VehicleCreatureId)?.Entity;
      const vehiclePerform = vehicle?.GetComponent(249);
      const passengerDrive = passenger?.GetComponent(245) || passenger?.GetComponent(247);
      const vehicleMesh = vehicle?.GetComponent(250)?.Actor?.Mesh;
      return !!(
        passenger?.IsInit &&
        vehicle?.IsInit &&
        vehicle?.Active &&
        vehiclePerform?.VehicleType === "Motorcycle" &&
        passengerDrive &&
        getActorMesh(passenger) &&
        hasSeatSocket(vehicleMesh, info.Seat)
      );
    };

    VehicleController.__zigrikaOriginalVehicleUpdateEntity = originalVehicleUpdateEntity;
    VehicleController.VehicleUpdateEntity = function (info) {
      if (!isRideSharingUpdate(info) || isReady(info)) {
        return originalVehicleUpdateEntity.call(this, info);
      }

      const key = `${info.EntityCreatureId}:${info.VehicleCreatureId}:${info.Seat}`;
      if (pending.has(key)) return;
      pending.add(key);

      let readyChecks = 0;
      const waitForReady = () => {
        if (isReady(info)) {
          pending.delete(key);
          originalVehicleUpdateEntity.call(this, info);
          return;
        }

        readyChecks += 1;
        if (readyChecks >= maxReadyChecks) {
          pending.delete(key);
          return;
        }

        setTimeout(waitForReady, readyCheckDelayMs);
      };

      setTimeout(waitForReady, readyCheckDelayMs);
    };
  };

  patchMotorAllowed();
  patchAutopilot();
  patchFollowShooter();
  patchRideSharing();
}, 200);
