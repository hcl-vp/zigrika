setTimeout(() => {
  const UE = require('ue')
  const { SequenceCameraPlayerComponent } = require('../../Camera/SequenceCameraPlayerComponent.js')
  const FNameUtil_1 = require('../../../Core/Utils/FNameUtil.js')
  const ActorSystem_1 = require('../../../Core/Actor/ActorSystem.js')
  const MathUtils_1 = require('../../../Core/Utils/MathUtils.js')
  const GlobalData_1 = require('../../../Game/GlobalData.js')
  const Log_1 = require("../../../Core/Common/Log");
  const EventSystem_1 = require("../../../Game/Common/Event/EventSystem.js");
  const EventDefine_1 = require("../../../Game/Common/Event/EventDefine.js");
  const CameraUtility_1 = require("../../../Game/Camera/CameraUtility.js");
  const ControllerHolder_1 = require('../../../Game/Manager/ControllerHolder.js');
  SequenceCameraPlayerComponent.prototype.lwr = function () {
    this._sr.Empty()
    this._sr.Add(
      ControllerHolder_1.ControllerHolder.CameraController.GetCharacter()
    )
    this.sor && this._sr.Add(this.sor)

    ControllerHolder_1.ControllerHolder.CameraController.EnterCameraMode(
      1,
      this.Exr,
      0
    )
    ControllerHolder_1.ControllerHolder.CameraController.FightCamera
      ?.LogicComponent?.CameraCollision &&
      (ControllerHolder_1.ControllerHolder.CameraController.FightCamera.LogicComponent.CameraCollision.IsNpcDitherEnable =
        false)
    this.Dxr = true
  }

  SequenceCameraPlayerComponent.prototype.PlayCameraSequence = function (
    t,
    e,
    i,
    s,
    h,
    r,
    a,
    o,
    n,
    _ = false,
    l = true,
    m = true,
    E = false,
    C = false,
    c = void 0
  ) {
    if (!this.Hxr) {
      return false
    }
    if (this.Dxr) {
      if (!this.Jxr(this.Tae, s)) {
        return false
      }
      this.StopSequence()
    }
    this.ZPr.CineCamera.GetAttachParentActor() &&
      this.ZPr.CineCamera.K2_DetachFromActor()
    this.Fxr = n
    a
      ? this.kxr.FromUeVector(a)
      : this.kxr.Set(RELATIVE_LENGTH, RELATIVE_LENGTH, RELATIVE_LENGTH)
    this.Vxr = o
    this.bxr = this.Tae
    this.Tae = s
    this.Nxr = r
    this.g1t = h
    FNameUtil_1.FNameUtil.IsEmpty(this.g1t) ||
      (this.Oxr?.IsValid() ||
        ((this.Oxr = ActorSystem_1.ActorSystem.Get(
          UE.Actor.StaticClass(),
          MathUtils_1.MathUtils.DefaultTransformDouble
        )),
        this.Oxr.K2_GetRootComponent()) ||
        this.Oxr.D_AddComponentByClass(
          UE.SceneComponent.StaticClass(),
          false,
          this.Oxr.D_GetTransform(),
          false
        ),
      this.Oxr.K2_AttachToComponent(this.Tae.Mesh, this.g1t, 2, 2, 2, false))
    this.zxr(t, l, m, c)
    n = this.S9e(C, _)
    return (
      (this.Bxr = e),
      (this.wxr = i),
      n &&
        (this.GQe(t),
        EventSystem_1.EventSystem.Emit(
          EventDefine_1.EEventName.OnSequenceCameraStatus,
          true
        ),
        UE.KismetSystemLibrary.ExecuteConsoleCommand(
          GlobalData_1.GlobalData.World,
          'r.DelaySetNearClipPlane 1'
        ),
        Log_1.Log.CheckDebug() &&
          Log_1.Log.Debug('Camera', 38, '进入Sequence相机\uFF0C最小近裁面'),
        E) &&
        UE.KismetSystemLibrary.ExecuteConsoleCommand(
          GlobalData_1.GlobalData.World,
          'r.MotionBlur.Amount 0'
        ),
      EventSystem_1.EventSystem.Emit(
        EventDefine_1.EEventName.PlayCameraLevelSequence,
        t.CameraSequence,
        s,
        this.exr,
        CameraUtility_1.CameraUtility.GetRootTransform(s)
      ),
      n
    )
  }
}, 0)
