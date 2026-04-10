setTimeout(() => {
  const UE = require("ue");
  const {
    FightPhotoOptionPanel,
  } = require("../Game/Module/Photograph/View/Item/FightPhotoOptionPanel.js");
  const {
    PhotographController,
  } = require("../Game/Module/Photograph/PhotographController.js");
  const {
    FilterSettingController,
  } = require("../Game/Module/Menu/FilterSettingController.js");
  const { RouletteModel } = require("../Game/Module/Roulette/RouletteModel.js");
  const {
    FightPhotographView,
  } = require("../Game/Module/Photograph/View/FightPhotographView.js");
  const {
    FilterSeniorParamSliderItem,
  } = require("../Game/Module/Menu/SubViews/FilterSetting/FilterSeniorParamSliderItem.js");
  const GenericScrollViewNew_1 = require("../Game/Module/Util/ScrollView/GenericScrollViewNew.js");
  const GenericLayout_1 = require("../Game/Module/Util/Layout/GenericLayout.js");
  const UiManager_1 = require("../Game/Ui/UiManager.js");
  const ModelManager_1 = require("../Game/Manager/ModelManager.js");
  const EventSystem_1 = require("../Game/Common/Event/EventSystem.js");
  const EventDefine_1 = require("../Game/Common/Event/EventDefine.js");
  const InputDistributeController_1 = require("../Game/Ui/InputDistribute/InputDistributeController.js");
  const InputMappingsDefine_1 = require("../Game/Ui/InputDistribute/InputMappingsDefine.js");
  const SpecialItemController_1 = require("../Game/Module/Item/SpecialItem/SpecialItemController.js");
  const SequenceController_1 = require("../Game/Module/Plot/Sequence/SequenceController.js");
  const Log_1 = require("../Core/Common/Log");
  const { ControllerManager } = require("../Game/Manager/ControllerManager.js");
  const {
    SpecialSkillAogusita,
  } = require("../Game/NewWorld/Character/Common/Component/Skill/SpecialSkill/SpecialSkillAogusita.js");

  SpecialSkillAogusita.prototype.OnStart = function () {
    var e,
      t = this.SpecialSkillComponent.Entity;
    ((this.Hte = t.GetComponent(3)),
      (this.cBe = t.GetComponent(42)),
      this.Hte?.IsRoleAndCtrlByMe &&
        ((this.Nce = t.GetComponent(67)),
        (e = t.GetComponent(218)),
        (this.SMd = e?.ListenForTagAddOrRemove(1519720150, this.IMd)),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.OnChangeRole,
          this.xie,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.CommonQteStart,
          this.qsm,
        ),
        EventSystem_1.EventSystem.AddWithTarget(
          t,
          EventDefine_1.EEventName.CharOnRoleDeadTargetSelf,
          this.Jze,
        )));
  };
  SpecialSkillAogusita.prototype.OnEnd = function () {
    (this.Hte?.IsRoleAndCtrlByMe && this.MMd && this.TMd(!0),
      this.SMd?.EndTask(),
      (this.SMd = void 0),
      EventSystem_1.EventSystem.Has(
        EventDefine_1.EEventName.OnChangeRole,
        this.xie,
      ) &&
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.OnChangeRole,
          this.xie,
        ),
      EventSystem_1.EventSystem.Has(
        EventDefine_1.EEventName.CommonQteStart,
        this.qsm,
      ) &&
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.CommonQteStart,
          this.qsm,
        ),
      EventSystem_1.EventSystem.HasWithTarget(
        this.SpecialSkillComponent.Entity,
        EventDefine_1.EEventName.CharOnRoleDeadTargetSelf,
        this.Jze,
      ) &&
        EventSystem_1.EventSystem.RemoveWithTarget(
          this.SpecialSkillComponent.Entity,
          EventDefine_1.EEventName.CharOnRoleDeadTargetSelf,
          this.Jze,
        ));
  };

  SpecialSkillAogusita.prototype.TMd = function (e) {};

  for (const teamItem of ModelManager_1.ModelManager.SceneTeamModel.aPr) {
    const entity = teamItem.Kpo?.Entity;
    if (!entity?.Valid) continue;

    const specialSkillComp = entity.GetComponent(284);
    if (!specialSkillComp) continue;

    const specialSkill = specialSkillComp.SpecialSkill;
    if (!(specialSkill instanceof SpecialSkillAogusita)) continue;

    EventSystem_1.EventSystem.RemoveWithTarget(
      entity,
      EventDefine_1.EEventName.CharBeforeSkillWithTarget,
      specialSkill.tTu,
    );
  }

  const ENTITYCAMERA = 70140001;

  PhotographController.FightPhotoLogReport = function () {
    return;
  };

  FilterSettingController.SetDefaultFilterSetting = function () {
    return;
  };

  FightPhotographView.prototype.GetGuideUiItemAndUiItemForShowEx = function (
    t,
  ) {
    return;
  };
  FightPhotoOptionPanel.prototype.GetGuideUiItemAndUiItemForShowEx = function (
    e,
  ) {
    return;
  };

  FightPhotographView.GetGuideUiItemAndUiItemForShowEx = function (t) {
    return;
  };
  FightPhotoOptionPanel.GetGuideUiItemAndUiItemForShowEx = function (e) {
    return;
  };

  FightPhotoOptionPanel.prototype.RefreshFinishSprite = function () {
    var e =
      ControllerHolder_1.ControllerHolder.PhotographController.CurrentBtNode;
    e &&
      e.InProgress &&
      (this.GetText(9)?.SetUIActive(!e.CheckRoleInCamera()),
      this.GetItem(6)?.SetUIActive(e.CheckPhotographCondition()));
    this.GetText(9).SetText("Private Server Freecam Tool");
  };

  RouletteModel.prototype.IsExploreRouletteOpen = function () {
    return true;
  };

  const ConfigManager_1 = require("../Game/Manager/ConfigManager.js");
  ConfigManager_1.ConfigManager.InstanceDungeonConfig.CheckViewShield =
    function () {
      return false;
    };

  const CONFIG_PATH =
    "/Game/Aki/Data/Camera/DA_PhotographCameraConfig.DA_PhotographCameraConfig";
  const MOBILE_CONFIG_PATH =
    "/Game/Aki/Data/Camera/DA_PhotographCameraConfig_Mobile.DA_PhotographCameraConfig_Mobile";
  const MIN_DITHER = 0.01;
  const HIDE_DISTANCE_OFFSET = 50;

  const {
    UiCameraPhotographerStructure,
  } = require("../Game/Module/UiCamera/UiCameraStructure/UiCameraPhotographerStructure.js");
  const MathUtils_1 = require("../Core/Utils/MathUtils.js");
  const GravityUtils_1 = require("../Game/Utils/GravityUtils.js");
  const Global_1 = require("../Game/Global.js");
  const Quat_1 = require("../Core/Utils/Math/Quat.js");
  const ControllerHolder_1 = require("../Game/Manager/ControllerHolder.js");
  const ActorSystem_1 = require("../Core/Actor/ActorSystem.js");
  const Vector_1 = require("../Core/Utils/Math/Vector.js");
  const CommonParamById_1 = require("../Core/Define/ConfigCommon/CommonParamById.js");
  const PhotographDefine_1 = require("../Game/Module/Photograph/PhotographDefine.js");
  const Info_1 = require("../Core/Common/Info.js");
  const ResourceSystem_1 = require("../Core/Resource/ResourceSystem.js");
  const FilterSettingViewModel_1 = require("../Game/Module/Menu/SubViews/FilterSetting/FilterSettingViewModel.js");
  const LguiUtil_1 = require("../Game/Module/Util/LguiUtil.js");

  FilterSeniorParamSliderItem.prototype.Refresh = function (t, i, e) {
    ((this.DNd = t),
      this.GetSprite(4)?.SetUIActive(t.IsNeedSpecialBg),
      this.GetSprite(3)?.SetUIActive(!t.IsNeedSpecialBg),
      this.GetItem(5)?.SetUIActive(!t.IsNeedSpecialBg),
      LguiUtil_1.LguiUtil.SetLocalTextNew(this.GetText(7), t.Name));
    var t = ModelManager_1.ModelManager.MenuModel.FilterSettingIdCache,
      t = ModelManager_1.ModelManager.MenuModel.FilterSettingValuesCache.get(t);
    t
      ? ((t = t[this.DNd.ParamIndex]),
        (t = parseFloat((t * this.DNd.Ratio).toFixed(this.DNd.DecimalPlaces))),
        this.GetText(0).SetText("" + t + this.DNd.Unit),
        (t = MathUtils_1.MathUtils.RangeClamp(
          t,
          this.DNd.RangeMin,
          this.DNd.RangeMax,
          0,
          1,
        )),
        this.GetSlider(1)?.SetValue(t, !1))
      : Log_1.Log.CheckError() &&
        Log_1.Log.Error("GameSettings", 71, "全局滤镜高级参数未找到默认值", [
          "param",
          this.DNd.ParamIndex,
        ]);
  };

  function detach_plot_camera() {
    const seq = SequenceController_1.SequenceController;
    if (seq.jio?.State !== 3) return;

    const seq_cine_camera =
      ModelManager_1.ModelManager.CameraModel.SequenceCamera?.DisplayComponent
        ?.CineCamera;

    if (seq_cine_camera) {
      const loc = seq_cine_camera.K2_GetActorLocation();
      const rot = seq_cine_camera.K2_GetActorRotation();

      seq.PauseSequence(false);
      seq.Yio?.AllStop();

      const structure =
        ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();
      const photographer = structure?.$Uo;

      photographer.K2_SetActorLocation(loc, false, void 0, false);
      photographer.K2_SetActorRotation(rot, false, void 0, false);
    }
  }

  FightPhotoOptionPanel.prototype.OnBeforeStartAsync = async function () {
    this.yEd = new GenericScrollViewNew_1.GenericScrollViewNew(
      this.GetScrollViewWithScrollbar(2),
      this.Bqe,
    );
    this.o8a = new GenericLayout_1.GenericLayout(
      this.GetVerticalLayout(0),
      this.n8a,
    );
    await this.yEd.RefreshByDataAsync([]);
    this.yEd.SelectGridProxy(0);
    this.RefreshCondition();
    this.GetItem(4)?.SetUIActive(false);
    this.GetSprite(7).SetUIActive(false);
    this.GetSprite(8).SetUIActive(false);
    detach_plot_camera();
  };

  // reattach
  UiCameraPhotographerStructure.prototype.OnDestroy = function () {
    this.YUo();
    const seq = SequenceController_1.SequenceController;
    seq.Yio?.PreAllPlay();
    seq.ResumeSequence(!1);
  };

  UiCameraPhotographerStructure.prototype.OnSpawnStructureActor = function () {
    var t = new UE.TransformDouble(
      new UE.Quat(0),
      new UE.VectorDouble(0),
      new UE.VectorDouble(1, 1, 1),
    );

    const photographer = ActorSystem_1.ActorSystem.Get(
      UE.TsPhotographer_C.StaticClass(),
      t,
      void 0,
    );

    // photographer.prototype.MoveUp = function () {
    //   return;
    // }
    // photographer.ReceiveDestroyed = function () {
    //   UiManager_1.UiManager.IsViewOpen("FilterSettingView") &&
    //     UiManager_1.UiManager.CloseView("FilterSettingView");
    // };
    photographer.ReceiveDestroyed = function () {
      ((this.Character = void 0),
        (this.IsLoadingConfigCompleted = !1),
        this.CameraNpcSphereTrace &&
          (this.CameraNpcSphereTrace.Dispose(),
          (this.CameraNpcSphereTrace = void 0)));
    };
    photographer.Initialize = function () {
      // UiManager_1.UiManager.OpenViewAsync("FilterSettingView");
      this.RelativeVectorCache = new UE.Vector();
      this.DefaultRotation = new UE.Rotator(0, 0, 0);
      this.CameraLocation = Vector_1.Vector.Create();
      this.PlayerLocation = Vector_1.Vector.Create();
      this.SourceMaxPitch =
        CommonParamById_1.configCommonParamById.GetIntConfig(
          "CameraSourceMaxPitch",
        );
      this.SourceMinPitch =
        CommonParamById_1.configCommonParamById.GetIntConfig(
          "CameraSourceMinPitch",
        );
      this.CameraUpAndDownSpeed = 1;
      this.CameraLeftAndRightSpeed = 1;
      this.MaxFov = PhotographDefine_1.MAX_FOV;
      this.MinFov = PhotographDefine_1.MIN_FOV;
      this.CameraUpAndDownSpeed = 1;
      this.CameraLeftAndRightSpeed = 1;
      this.CameraInitializeFov = -1;
      const s =
        ControllerHolder_1.ControllerHolder.PhotographController.CheckIfInFightPhotographCamera();
      this.CameraUpAndDownMaxDistance = 100000000;
      this.CameraLeftAndRightMaxDistance = 100000000;
      s &&
        ((this.MinFov =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "FightCameraMinFov",
          )),
        (this.MaxFov =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "FightCameraMaxFov",
          )),
        (this.CameraUpAndDownSpeed =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "FightCameraUpAndDownSpeed",
          )),
        (this.CameraLeftAndRightSpeed =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "FightCameraLeftAndRightSpeed",
          )));
      this.CurCameraUpAndDownDistance = 0;
      this.CurCameraLeftAndRightDistance = 0;
      this.CurrentDither = 0;
      this.Character = Global_1.Global.BaseCharacter;
      this.PlayerLocation.FromUeVector(this.Character.D_K2_GetActorLocation());
      GravityUtils_1.GravityUtils.GetBaseQuatInGravityForActor(
        this.Character.CharacterActorComponent,
        this.GravityQuat,
      );
      this.GravityQuat.Inverse(this.InverseGravityQuat);
      this.CurrentCameraDitherFov = 0;
      this.CameraCollisionRadius = 0;
      this.DitheredNpcSet = new Set();
      this.DitheredNpcDistanceMap = new Map();
      this.InitCameraNpcSphereTrace();
      this.IsLoadingConfigCompleted = false;
      var t = Info_1.Info.IsMobilePlatform() ? MOBILE_CONFIG_PATH : CONFIG_PATH;
      ResourceSystem_1.ResourceSystem.LoadAsync(
        t,
        UE.BP_PhotographCameraConfig_C,
        (t) => {
          var t = t.基础,
            i =
              ((this.StartHidePitch = s ? t.Get(15) : t.Get(10)),
              s ? t.Get(2) : t.Get(8)),
            h = s ? t.Get(3) : t.Get(9),
            i =
              ((this.StartHideDistance = Math.max(i, h) + HIDE_DISTANCE_OFFSET),
              (this.CompleteHideDistance =
                Math.min(i, h) + HIDE_DISTANCE_OFFSET),
              t.Get(5)),
            h = t.Get(6);
          this.NpcStartHideDistance = Math.max(i, h) + HIDE_DISTANCE_OFFSET;
          this.NpcCompleteHideDistance = Math.min(i, h) + HIDE_DISTANCE_OFFSET;
          this.NpcStartDitherValue = t.Get(7);
          this.CompleteHidePitch = s ? t.Get(1) : t.Get(11);
          this.StartHideSizeInFrame = t.Get(13);
          this.CompleteHideSizeInFrame = t.Get(14);
          this.StartDitherValue = s ? t.Get(4) : t.Get(12);
          this.IsLoadingConfigCompleted = true;
        },
        100,
        "Ui.PhotographUi",
      );
      this.CameraArm.bDoCollisionTest = false;
      this.CameraArm.bEnableCameraLag = false;
      this.CameraArm.bEnableCameraRotationLag = false;
    };

    photographer.MoveUp = function (t) {
      var move_amount = (t * this.CameraUpAndDownSpeed) / 1.5;
      var vec = this.CapsuleCollision.GetUpVector();
      vec = vec.op_Multiply(move_amount);

      this.K2_SetActorLocation(
        this.K2_GetActorLocation().op_Addition(vec),
        false,
        void 0,
        false,
      );
    };

    photographer.MoveForward = function (t) {
      var move_amount = t * this.CameraUpAndDownSpeed;
      var vec = this.CapsuleCollision.GetForwardVector();
      vec = vec.op_Multiply(move_amount);

      this.K2_SetActorLocation(
        this.K2_GetActorLocation().op_Addition(vec),
        false,
        void 0,
        false,
      );
    };

    photographer.MoveRight = function (t) {
      var move_amount = (t * this.CameraLeftAndRightSpeed) / 2;
      var vec = this.CapsuleCollision.GetRightVector();
      vec = vec.op_Multiply(move_amount);

      this.K2_SetActorLocation(
        this.K2_GetActorLocation().op_Addition(vec),
        false,
        void 0,
        false,
      );
    };

    photographer.SetTickableWhenPaused(true);
    photographer.SetActorTickEnabled(true);
    photographer.Initialize();
    photographer.CameraArm.SetTickableWhenPaused(true);

    this.$Uo = photographer;

    const CustomMoveForward = (t, e) => {
      if (e === 0) return;
      if (UiManager_1.UiManager.IsViewShow("PhotographSetupView")) return;
      if (UiManager_1.UiManager.IsViewShow("PhotoSaveView")) return;
      if (UiManager_1.UiManager.IsViewShow("FightPhotoSaveView")) return;

      if (
        photographer.CameraCaptureType === 1 &&
        UiManager_1.UiManager.IsViewShow("PhotoSaveView")
      ) {
        return;
      }

      if (photographer.CameraCaptureType === 1) {
        photographer.AddCameraArmPitchInput(e);
      } else {
        photographer.MoveForward(e);
      }
    };

    const CustomMoveUp = (t, e) => {
      if (e === 0) return;
      Log_1.Log.Info("Photo", 45, "CustomMoveUp.", ["t", t], ["e", e]);
      if (UiManager_1.UiManager.IsViewShow("PhotographSetupView")) return;
      if (UiManager_1.UiManager.IsViewShow("PhotoSaveView")) return;
      if (UiManager_1.UiManager.IsViewShow("FightPhotoSaveView")) return;

      if (
        photographer.CameraCaptureType === 1 &&
        UiManager_1.UiManager.IsViewShow("PhotoSaveView")
      ) {
        return;
      }

      if (photographer.CameraCaptureType === 1) {
        photographer.AddCameraArmPitchInput(e);
      } else {
        photographer.MoveUp(e);
      }
    };

    const FilterControl = async (_, state) => {
      if (state !== 1) return;

      const filter_is_open =
        UiManager_1.UiManager.IsViewOpen("FilterSettingView");

      if (filter_is_open) {
        this.FilterOpened = false;
        await UiManager_1.UiManager.NormalResetToViewAsync(
          "FightPhotographView",
        );
      } else {
        this.FilterOpened = true;
        this.SavedFov = photographer.GetFov();
        ControllerHolder_1.ControllerHolder.FilterSettingController.TryOpenExternalPreparedAsync();
      }
    };

    let move_up_held = false;
    let move_down_held = false;

    const move_up_action = (_, state) => {
      move_up_held = state === 0;
      Log_1.Log.Info(
        "Photo",
        45,
        "MoveUp should start now.",
        ["state", state],
        ["move_up_held:", move_up_held],
      );
    };
    const move_down_action = (_, state) => {
      move_down_held = state === 0;
      Log_1.Log.Info(
        "Photo",
        45,
        "MoveDown should start now.",
        ["state", state],
        ["move_down_held:", move_down_held],
      );
    };

    photographer.RefreshCameraArm = function () {
      if (move_up_held) CustomMoveUp(null, 1);
      if (move_down_held) CustomMoveUp(null, -1);
      if (this.PitchInput === 0 && this.YawInput === 0) return;

      this.TmpRotator.DeepCopy(this.CapsuleCollision.K2_GetComponentRotation());
      this.TmpRotator.Quaternion(this.TmpQuat);

      if (Math.abs(this.PitchInput) > MathUtils_1.MathUtils.SmallNumber) {
        this.TmpRotator2.Set(this.PitchInput, 0, 0);
        this.TmpRotator2.Quaternion(this.TmpQuat2);
        this.TmpQuat.Multiply(this.TmpQuat2, this.TmpQuat3);
        this.TmpQuat.DeepCopy(this.TmpQuat3);
      }
      if (Math.abs(this.YawInput) > MathUtils_1.MathUtils.SmallNumber) {
        this.TmpRotator2.Set(0, this.YawInput, 0);
        this.TmpRotator2.Quaternion(this.TmpQuat2);
        this.TmpQuat.Multiply(this.TmpQuat2, this.TmpQuat3);
        this.TmpQuat.DeepCopy(this.TmpQuat3);
      }

      this.TmpQuat.Rotator(this.TmpRotator);
      this.CapsuleCollision.K2_SetRelativeRotation(
        this.TmpRotator.ToUeRotator(),
        false,
        void 0,
        false,
      );

      this.PitchInput = 0;
      this.YawInput = 0;
    };

    FightPhotographView.prototype.ZQi = function () {
      const fov_slider = this.GetSlider(10);

      if (
        PhotographController.CheckIfInNormalCamera() ||
        PhotographController.CheckIfInFightPhotographCamera()
      ) {
        fov_slider.SetMinValue(this.BQd, false, false);
        fov_slider.SetMaxValue(this.kQd, false, false);
        this.SetCameraFov(photographer.GetFov(), true);
      } else if (PhotographController.CheckIfInTogetherCamera()) {
        fov_slider.SetMinValue(this.BQd, false, false);
        fov_slider.SetMaxValue(this.kQd, false, false);

        const together_fov = PhotographController.TogetherCameraFov;
        if (
          together_fov &&
          together_fov >= this.BQd &&
          together_fov <= this.kQd
        ) {
          this.SetCameraFov(PhotographController.TogetherCameraFov, true);
        } else {
          this.SetCameraFov();
        }
      } else {
        const max_fov = parseInt(PhotographController.MaxFov.Value);
        const min_fov = parseInt(PhotographController.MinFov.Value);
        const default_fov = (max_fov - min_fov) / 2 + min_fov;

        fov_slider.SetMinValue(min_fov, false, false);
        fov_slider.SetMaxValue(max_fov, false, false);
        fov_slider.SetValue(default_fov, true);
        this.BQi(default_fov);

        if (Log_1.Log.CheckInfo()) {
          Log_1.Log.Info(
            "Photo",
            45,
            "实体拍照RefreshFov：",
            ["MaxValue:", fov_slider.GetMaxValue()],
            ["MinValue:", fov_slider.GetMinValue()],
            ["NowValue:", fov_slider.GetValue()],
            ["max:", max_fov],
            ["min", min_fov],
          );
        }
      }
    };

    photographer.ReceiveTick = function (deltaTime) {
      this.RefreshCameraArm();
    };

    PhotographController.OnAddEvents = function () {
      (EventSystem_1.EventSystem.Add(
        EventDefine_1.EEventName.OnChangeRole,
        this.xie,
      ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.CharOnRoleDead,
          this.Jze,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.OnLogicTreeNodeStatusChange,
          this.$Ct,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.OnLogicTreeTrackUpdate,
          this.Gre,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.CurTrackQuestUnTrackedCheck,
          this.CWi,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.GeneralLogicTreeWakeUp,
          this.gWi,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.OnSpecialItemNotAllow,
          this.pWi,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.SpawnPlayer,
          this.QFa,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.WorldDone,
          this.nye,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.TeleportComplete,
          this.nye,
        ),
        EventSystem_1.EventSystem.Add(
          EventDefine_1.EEventName.RoleTriggerInit,
          this.Woh,
        ),
        InputDistributeController_1.InputDistributeController.BindAxis(
          InputMappingsDefine_1.axisMappings.UiMoveRight,
          this.MWi,
        ),
        InputDistributeController_1.InputDistributeController.BindAxis(
          InputMappingsDefine_1.axisMappings.UiLookUp,
          this.q8i,
        ),
        InputDistributeController_1.InputDistributeController.BindAxis(
          InputMappingsDefine_1.axisMappings.UiTurn,
          this.G8i,
        ),
        InputDistributeController_1.InputDistributeController.BindAxis(
          InputMappingsDefine_1.axisMappings.UiMoveForward,
          CustomMoveForward,
        ),
        InputDistributeController_1.InputDistributeController.BindAction(
          InputMappingsDefine_1.actionMappings.UI键盘E手柄RB,
          move_up_action,
        ),
        InputDistributeController_1.InputDistributeController.BindAction(
          InputMappingsDefine_1.actionMappings.UI键盘Q手柄LB,
          move_down_action,
        ),
        InputDistributeController_1.InputDistributeController.BindAction(
          InputMappingsDefine_1.actionMappings.UI键盘X手柄特左,
          FilterControl,
        ));
    };
    PhotographController.OnRemoveEvents();
    PhotographController.OnAddEvents();

    PhotographController.OnRemoveEvents = function () {
      (EventSystem_1.EventSystem.Remove(
        EventDefine_1.EEventName.OnChangeRole,
        this.xie,
      ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.CharOnRoleDead,
          this.Jze,
        ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.OnLogicTreeNodeStatusChange,
          this.$Ct,
        ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.CurTrackQuestUnTrackedCheck,
          this.CWi,
        ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.OnLogicTreeTrackUpdate,
          this.Gre,
        ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.GeneralLogicTreeWakeUp,
          this.gWi,
        ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.OnSpecialItemNotAllow,
          this.pWi,
        ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.SpawnPlayer,
          this.QFa,
        ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.WorldDone,
          this.nye,
        ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.TeleportComplete,
          this.nye,
        ),
        EventSystem_1.EventSystem.Remove(
          EventDefine_1.EEventName.RoleTriggerInit,
          this.Woh,
        ),
        InputDistributeController_1.InputDistributeController.UnBindAxis(
          InputMappingsDefine_1.axisMappings.UiMoveRight,
          this.MWi,
        ),
        InputDistributeController_1.InputDistributeController.UnBindAxis(
          InputMappingsDefine_1.axisMappings.UiLookUp,
          this.q8i,
        ),
        InputDistributeController_1.InputDistributeController.UnBindAxis(
          InputMappingsDefine_1.axisMappings.UiTurn,
          this.G8i,
        ),
        InputDistributeController_1.InputDistributeController.UnBindAxis(
          InputMappingsDefine_1.axisMappings.UiMoveForward,
          CustomMoveForward,
        ),
        InputDistributeController_1.InputDistributeController.UnBindAction(
          InputMappingsDefine_1.actionMappings.UI键盘E手柄RB,
          move_up_action,
        ),
        InputDistributeController_1.InputDistributeController.UnBindAction(
          InputMappingsDefine_1.actionMappings.UI键盘Q手柄LB,
          move_down_action,
        ),
        InputDistributeController_1.InputDistributeController.UnBindAction(
          InputMappingsDefine_1.actionMappings.UI键盘X手柄特左,
          FilterControl,
        ),
        this.m$e());
    };
    return this.$Uo;
  };

  const {
    FilterSettingView,
  } = require("../Game/Module/Menu/SubViews/FilterSetting/FilterSettingView.js");

  ControllerHolder_1.ControllerHolder.FilterSettingController.TryOpenExternalPreparedAsync =
    async function () {
      this.yil = this.$cu();
      if (!this.yil) return false;

      UiManager_1.UiManager.OpenView("FilterSettingView", this.yil);

      return true;
    };

  ControllerHolder_1.ControllerHolder.FilterSettingController.CloseViewAndReturnWorld =
    async function () {
      await ControllerHolder_1.ControllerHolder.PhotographController.ClosePhotograph();
    };

  const original_on_after_destroy = FilterSettingView.prototype.OnAfterDestroy;
  const original_on_before_destroy =
    FilterSettingView.prototype.OnBeforeDestroy;

  FilterSettingView.prototype.OnAfterDestroy = function () {
    const structure =
      ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();
    if (structure) structure.FilterOpened = false;
    original_on_after_destroy.call(this);
  };

  FilterSettingView.prototype.OnBeforeDestroy = function () {
    this.VmCache?.OnConfirmClick?.();
    original_on_before_destroy.call(this);
  };

  const original_on_before_start_async =
    FilterSettingView.prototype.OnBeforeStartAsync;
  FilterSettingView.prototype.OnBeforeStartAsync = async function () {
    await original_on_before_start_async.call(this);
    for (const item of this.UNd.CGo) {
      item.$tu = (t, i = 0) => {
        var e;
        item.ParentViewModel?.IsPropertyDirty(
          FilterSettingViewModel_1.FilterSettingViewModel.Flags
            .IsSeniorParamRefresh,
        ) ||
          ((e =
            (t = MathUtils_1.MathUtils.RangeClamp(
              t,
              0,
              1,
              item.DNd.RangeMin,
              item.DNd.RangeMax,
            )) / item.DNd.Ratio),
          item.ParentViewModel?.OnSeniorSliderChanged?.(item.DNd.ParamIndex, e),
          item
            .GetText(0)
            .SetText(
              "" +
                parseFloat(t.toFixed(item.DNd.DecimalPlaces)) +
                item.DNd.Unit,
            ));
      };
      item.GetSlider(1).OnValueChangeCb.Unbind();
      item.GetSlider(1).OnValueChangeCb.Bind(item.$tu);
    }
  };

  const CameraController_1 = require("../Game/Camera/CameraController.js");
  const InputDistributeDefine_1 = require("../Game/Ui/InputDistribute/InputDistributeDefine.js");

  // ModelManager_1.ModelManager.InputDistributeModel.RefreshInputDistributeTag =
  //   function () {
  //     this.SetInputDistributeTag(
  //       InputDistributeDefine_1.inputDistributeTagDefine.FightInputRootTag,
  //     );
  //     this.AddInputDistributeTag(
  //       InputDistributeDefine_1.inputDistributeTagDefine.UiInputRootTag,
  //     );
  //   };
  InputDistributeController_1.InputDistributeController.RefreshInputTag =
    function () {
      ModelManager_1.ModelManager.InputDistributeModel.RefreshInputDistributeTag();
    };

  ControllerHolder_1.ControllerHolder.PhotographController.$ha = function (t) {
    return !0;
  };
  ControllerHolder_1.ControllerHolder.PlotController.HandleSeqPlayerInput =
    function () {};
  ControllerHolder_1.ControllerHolder.CameraController.SetInputEnable =
    function (e, t) {
      this.FightCamera.LogicComponent.CameraInputController.SetInputEnable(
        !0,
        t,
      );
    };
  CameraController_1.CameraController.SetInputEnable = function (e, t) {
    this.FightCamera.LogicComponent.CameraInputController.SetInputEnable(!0, t);
  };

  const PlotController_1 = require("../Game/Module/Plot/PlotController.js");
  const PerfSightController_1 = require("../Game/PerfSight/PerfSightController.js");
  const cpp_1 = require("cpp");
  const Time_1 = require("../Core/Common/Time.js");

  const plot_view_manager = PlotController_1.PlotController.PlotViewManager;
  const old_wto = plot_view_manager.wto;

  plot_view_manager.wto = (view_name, is_show) => {
    old_wto.call(plot_view_manager, view_name, is_show);
    if (is_show && view_name === "PlotSubtitleView") {
      ControllerHolder_1.ControllerHolder.PlotController.TogglePlotProtect(!1);
      ControllerHolder_1.ControllerHolder.PlotController.EnableViewControl(!1);
      ModelManager_1.ModelManager.PlotModel.PlotConfig.DisableInput = !1;
      // InputDistributeController_1.InputDistributeController.RefreshInputTag();
      // CameraController_1.CameraController.ExitDialogMode();
      // plot_view_manager.Rto = false;
      UiManager_1.UiManager.CloseView("PlotSubtitleView");
    }
  };

  EventSystem_1.EventSystem.Remove(
    EventDefine_1.EEventName.PlotViewChange,
    old_wto,
  );
  EventSystem_1.EventSystem.Add(
    EventDefine_1.EEventName.PlotViewChange,
    plot_view_manager.wto,
  );
}, 0);
