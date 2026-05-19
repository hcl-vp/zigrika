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
  const GlobalData_1 = require("../Game/GlobalData.js");
  const { ControllerManager } = require("../Game/Manager/ControllerManager.js");
  const {
    SpecialSkillAogusita,
  } = require("../Game/NewWorld/Character/Common/Component/Skill/SpecialSkill/SpecialSkillAogusita.js");
  const {
    PhotoSaveView,
  } = require("../Game/Module/Photograph/View/PhotoSaveView.js");
  const {
    FightPhotoSaveView,
  } = require("../Game/Module/Photograph/View/FightPhotoSaveView.js");
  const PhotographDefine_1 = require("../Game/Module/Photograph/PhotographDefine.js");
  const ScreenShotManager_1 = require("../Game/Module/ScreenShot/ScreenShotManager.js");
  const BattleUiControl_1 = require("../Game/Module/BattleUi/BattleUiControl.js");
  const UiLayerType_1 = require("../Game/Ui/Define/UiLayerType.js");
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
  const Info_1 = require("../Core/Common/Info.js");
  const ResourceSystem_1 = require("../Core/Resource/ResourceSystem.js");
  const FilterSettingViewModel_1 = require("../Game/Module/Menu/SubViews/FilterSetting/FilterSettingViewModel.js");
  const LguiUtil_1 = require("../Game/Module/Util/LguiUtil.js");
  const PlotController_1 = require("../Game/Module/Plot/PlotController.js");
  const PerfSightController_1 = require("../Game/PerfSight/PerfSightController.js");
  const cpp_1 = require("cpp");
  const Time_1 = require("../Core/Common/Time.js");
  const RedDotController_1 = require("../Game/RedDot/RedDotController.js");
  const UiCameraManager_1 = require("../Game/Module/UiCamera/UiCameraManager.js");
  const UiLayer_1 = require("../Game/Ui/UiLayer.js");
  const LevelLoadingController_1 = require("../Game/Module/LevelLoading/LevelLoadingController.js");
  const UiModel_1 = require("../Game/Ui/UiModel.js");
  const EffectEnvironment_1 = require("../Core/Effect/EffectEnvironment.js");
  const CameraController_1 = require("../Game/Camera/CameraController.js");
  const InputDistributeDefine_1 = require("../Game/Ui/InputDistribute/InputDistributeDefine.js");
  const AudioSystem_1 = require("../Core/Audio/AudioSystem.js");
  const PhotographView_1 = require("../Game/Module/Photograph/View/PhotographView.js");
  const EffectSystem_1 = require("../Game/Effect/EffectSystem.js");
  const PopupCaptionItem_1 = require("../Game/Ui/Common/PopupCaptionItem.js");
  const MenuDefine_1 = require("../Game/Module/Menu/MenuDefine.js");
  const CircleAttachView_1 = require("../Game/Module/AutoAttach/CircleAttachView.js");
  const FilterSeniorSettingAll_1 = require("../Core/Define/ConfigQuery/FilterSeniorSettingAll.js");
  const PhotographEntityPanel_1 = require("../Game/Module/Photograph/View/PhotographEntityPanel.js");
  const FightPhotoOptionPanel_1 = require("../Game/Module/Photograph/View/Item/FightPhotoOptionPanel.js");
  const puerts_1 = require("puerts");
  const CommonDefine_1 = require("../Core/Define/CommonDefine.js");
  const Rotator_1 = require("../Core/Utils/Math/Rotator.js");
  const CustomPromise_1 = require("../Core/Common/CustomPromise.js");
  const PhotographController_1 = require("../Game/Module/Photograph/PhotographController.js");
  const EntitySystem_1 = require("../Core/Entity/EntitySystem.js");
  const TimeOfDayController_1 = require("../Game/Module/TimeOfDay/TimeOfDayController.js");
  const Protocol_1 = require("../Core/Define/Net/Protocol.js");
  const UiTimeDilation_1 = require("../Game/Ui/Base/UiTimeDilation.js");
  const EventCSharpBridge_1 = require("../Game/Common/Event/EventCSharpBridge.js");
  const TickSystem_1 = require("../Core/Tick/TickSystem.js");
  const {
    PhotographSetupView,
  } = require("Game/Module/Photograph/View/PhotographSetupView.js");
  const TimeUtil_1 = require("Game/Common/TimeUtil.js");
  const TimerSystem_1 = require("Core/Timer/TimerSystem.js");

  const plot_view_manager = PlotController_1.PlotController.PlotViewManager;

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

  PhotographController.PhotographFastScreenShot = function (t = 0) {
    if (ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity?.Valid) {
      this.CameraCaptureType = t;

      this.ScreenShot({
        ScreenShot: true,
        PrepareFullScreenShot: true,
        IsHiddenBattleView: true,
        HandBookPhotoData: undefined,
        GachaData: undefined,
        FragmentMemory: undefined,
        RoleSkinData: undefined,
      });
    }
  };

  // FilterSettingController.SetDefaultFilterSetting = function () {
  //   return;
  // };

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

  let photo_mode_active = false;

  const set_game_paused = (paused) => {
    if (paused) {
      TickSystem_1.TickSystem.IsPaused = true;
      EventCSharpBridge_1.EventCSharpBridge.Emit(
        EventDefine_1.EEventName.TsSyncTickPauseState,
        TickSystem_1.TickSystem.IsSetPaused,
      );
      cpp_1.FKuroGameBudgetAllocatorInterface.SetPauseFrame(
        UE.KismetSystemLibrary.GetFrameCount(),
      );
      ControllerHolder_1.ControllerHolder.GameModeController.SetTimeDilation(
        0,
        2,
      );
      Time_1.Time.LastPauseTimeFrame = Time_1.Time.Frame;
      EventSystem_1.EventSystem.Emit(
        EventDefine_1.EEventName.OnSetGamePaused,
        true,
      );
      UE.GameplayStatics.SetGamePaused(GlobalData_1.GlobalData.World, true);
    } else {
      TickSystem_1.TickSystem.IsPaused = false;
      EventCSharpBridge_1.EventCSharpBridge.Emit(
        EventDefine_1.EEventName.TsSyncTickPauseState,
        TickSystem_1.TickSystem.IsSetPaused,
      );
      ControllerHolder_1.ControllerHolder.GameModeController.SetTimeDilation(
        1,
        2,
      );
      Time_1.Time.LastResumeTimeFrame = Time_1.Time.Frame;
      EventSystem_1.EventSystem.Emit(
        EventDefine_1.EEventName.OnSetGamePaused,
        false,
      );
      UE.GameplayStatics.SetGamePaused(GlobalData_1.GlobalData.World, false);
    }
  };

  const PAUSE_DILATION_THRESHOLD = 0.01;
  const dilate_time = (dilation) => {
    const should_pause = dilation < PAUSE_DILATION_THRESHOLD && dilation !== 1;
    set_game_paused(should_pause);

    if (!should_pause) {
      ControllerHolder_1.ControllerHolder.GameModeController.SetTimeDilation(
        dilation,
        4,
      );
    }

    const actors = puerts.$ref(UE.NewArray(UE.Actor));
    UE.GameplayStatics.GetAllActorsOfClass(
      GlobalData_1.GlobalData.World,
      UE.Actor.StaticClass(),
      actors,
    );
    const actor_array = puerts.$unref(actors);
    const count = actor_array.Num();
    for (let i = 0; i < count; i++) {
      const niagara = actor_array
        .Get(i)
        .GetComponentByClass(UE.NiagaraComponent.StaticClass());
      if (niagara?.IsValid()) {
        niagara.SetTickTimeDilation(should_pause ? 0 : dilation);
      }
    }
  };

  FightPhotoOptionPanel.prototype.OnBeforeStartAsync = async function () {
    this.yEd = new GenericScrollViewNew_1.GenericScrollViewNew(
      this.GetScrollViewWithScrollbar(2),
      this.Bqe,
    );

    this.o8a = new GenericLayout_1.GenericLayout(
      this.GetVerticalLayout(0),
      this.n8a,
    );

    await this.yEd.RefreshByDataAsync(
      ConfigManager_1.ConfigManager.PhotographConfig.GetAllFightPhotoOptionConfig(),
    );

    this.yEd.SelectGridProxy(0);
    this.RefreshCondition();
    this.GetItem(4)?.SetUIActive(false);
    this.GetSprite(7).SetUIActive(false);
    this.GetSprite(8).SetUIActive(true);

    this.yEd.BindScrollValueChange((e) => {
      if (e) {
        this.GetSprite(7).SetUIActive(e.Y > 0);
        this.GetSprite(8).SetUIActive(e.Y < 1);
      }
    });
    1;
    detach_plot_camera();
  };

  // reattach
  UiCameraPhotographerStructure.prototype.OnDestroy = function () {
    this.YUo();
    const seq = SequenceController_1.SequenceController;
    seq.Yio?.PreAllPlay();
    seq.ResumeSequence(!1);
    photo_mode_active = false;
    if (seq.jio?.State === 3) {
      UiManager_1.UiManager.OpenView("PlotSubtitleView");
    }
  };

  const toggle_photo_mode = (_, state) => {
    const seq = SequenceController_1.SequenceController;
    if (seq.jio?.State !== 3) return;
    if (state !== 0) return;

    photo_mode_active = true;
    seq.PauseSequence(false);
    ControllerHolder_1.ControllerHolder.PhotographController.mEd(3);
    UiManager_1.UiManager.CloseView("PlotSubtitleView");
  };

  ModelManager_1.ModelManager.PhotographModel.SetPhotographTimeDilation =
    function (t) {
      Log_1.Log.Info("Photograph", 57, "SetPhotographTimeDilation", [
        "timeDilation",
        t,
      ]);

      if (t !== 1) {
        AudioSystem_1.AudioSystem.SetState("game_sys_fightphoto", "slow");
        AudioSystem_1.AudioSystem.PostEvent("play_ui_battlephoto_timestop");
      }

      ControllerHolder_1.ControllerHolder.GameModeController.SetTimeDilation(
        t,
        4,
      );
    };

  // const _super_on_after_hide = FightPhotographView.prototype.OnAfterHide;
  // FightPhotographView.prototype.OnAfterHide = function () {
  //   _super_on_after_hide.call(this);
  // };

  const _super_on_after_destroy = FightPhotographView.prototype.OnAfterDestroy;
  FightPhotographView.prototype.OnAfterDestroy = function () {
    dilate_time(1);
    _super_on_after_destroy.call(this);
  };

  const _superOnAfterShow =
    PhotographView_1.PhotographView.prototype.OnAfterShow;

  FightPhotographView.prototype.OnAfterShow = function () {
    _superOnAfterShow.call(this);
    // ModelManager_1.ModelManager.RenderModuleModel?.EnableForceTickCharRenderShell(
    //   "FightPhotographView OnAfterShow",
    // );
    AudioSystem_1.AudioSystem.SetState("game_sys_fightphoto", "pause");
    dilate_time(0);
    // UiTimeDilation_1.UiTimeDilation.Rur(true);
    this.NDc();
  };

  UiCameraPhotographerStructure.prototype.OnSpawnStructureActor = function () {
    photo_mode_active = true;
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
      this.Character = undefined;
      this.IsLoadingConfigCompleted = false;

      if (this.CameraNpcSphereTrace) {
        this.CameraNpcSphereTrace.Dispose();
        this.CameraNpcSphereTrace = undefined;
      }
    };
    photographer.Initialize = function () {
      this.RelativeVectorCache = new UE.Vector();
      this.DefaultRotation = new UE.Rotator(0, 0, 0);
      this.InitialCapsuleRoll =
        this.CapsuleCollision.K2_GetComponentRotation().Roll;
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

      this.MaxFov = PhotographDefine_1.MAX_FOV;
      this.MinFov = PhotographDefine_1.MIN_FOV;
      this.CameraUpAndDownSpeed = 1;
      this.CameraLeftAndRightSpeed = 1;
      this.CameraForwardAndBackwardSpeed = 1;

      this.CameraForwardAndBackSpeed =
        CommonParamById_1.configCommonParamById.GetIntConfig(
          "CameraForwardAndBackSpeed",
        ) ?? 1;

      this.CameraInitializeFov = -1;
      const s =
        ControllerHolder_1.ControllerHolder.PhotographController.CheckIfInFightPhotographCamera();

      this.CameraUpAndDownMaxDistance = 100000000;
      this.CameraLeftAndRightMaxDistance = 100000000;
      this.CameraForwardAndBackMaxDistance = 100000000;

      if (s) {
        this.MinFov =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "FightCameraMinFov",
          );

        this.MaxFov =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "FightCameraMaxFov",
          );

        this.CameraUpAndDownSpeed =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "FightCameraUpAndDownSpeed",
          );

        this.CameraLeftAndRightSpeed =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "FightCameraLeftAndRightSpeed",
          );
      } else {
        this.MinFov =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "CameraMinFov",
          ) ?? PhotographDefine_1.MAX_FOV;

        this.MaxFov =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "CameraMaxFov",
          ) ?? PhotographDefine_1.MIN_FOV;

        this.CameraUpAndDownSpeed =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "CameraUpAndDownSpeed",
          ) ?? 1;

        this.CameraLeftAndRightSpeed =
          CommonParamById_1.configCommonParamById.GetIntConfig(
            "CameraLeftAndRightSpeed",
          ) ?? 1;
      }

      this.CurCameraUpAndDownDistance = 0;
      this.CurCameraLeftAndRightDistance = 0;
      this.CurCameraForwardAndBackDistance = 0;
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
      const t = Info_1.Info.IsMobilePlatform()
        ? MOBILE_CONFIG_PATH
        : CONFIG_PATH;

      ResourceSystem_1.ResourceSystem.LoadAsync(
        t,
        UE.BP_PhotographCameraConfig_C,
        (t) => {
          var t_基础 = t_基础.基础;

          this.StartHidePitch = s ? t_基础.Get(15) : t_基础.Get(10);
          var i = s ? t_基础.Get(2) : t_基础.Get(8);

          var h = s ? t_基础.Get(3) : t_基础.Get(9);

          this.StartHideDistance = Math.max(i, h) + HIDE_DISTANCE_OFFSET;
          this.CompleteHideDistance = Math.min(i, h) + HIDE_DISTANCE_OFFSET;
          var i = t_基础.Get(5);

          var h = t_基础.Get(6);
          this.NpcStartHideDistance = Math.max(i, h) + HIDE_DISTANCE_OFFSET;
          this.NpcCompleteHideDistance = Math.min(i, h) + HIDE_DISTANCE_OFFSET;
          this.NpcStartDitherValue = t_基础.Get(7);
          this.CompleteHidePitch = s ? t_基础.Get(1) : t_基础.Get(11);
          this.StartHideSizeInFrame = t_基础.Get(13);
          this.CompleteHideSizeInFrame = t_基础.Get(14);
          this.StartDitherValue = s ? t_基础.Get(4) : t_基础.Get(12);
          this.IsLoadingConfigCompleted = true;
        },
        100,
        "Ui.PhotographUi",
      );
      this.CameraArm.bDoCollisionTest = false;
      this.CameraArm.bEnableCameraLag = false;
      this.CameraArm.bEnableCameraRotationLag = false;

      this.RefreshDitherEffect();
    };

    photographer.MoveUp = function (t) {
      var move_amount = t * this.CameraUpAndDownSpeed;
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
      var move_amount = t * this.CameraForwardAndBackwardSpeed;
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
      var move_amount = t * this.CameraLeftAndRightSpeed;
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

    const CustomMoveRight = (t, e) => {
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
        photographer.MoveRight(e);
      }
    };

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
        photographer.MoveForward(e * 2);
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
        await UiManager_1.UiManager.NormalResetToViewAsync("PhotographView");
      } else {
        this.FilterOpened = true;
        this.SavedFov = photographer.GetFov();
        ControllerHolder_1.ControllerHolder.FilterSettingController.TryOpenExternalPreparedAsync();
      }
    };

    const ChatOpen = async (_, state) => {
      if (state !== 1 || photo_mode_active === false) return;

      UiManager_1.UiManager.OpenView("ChatView");
    };

    let move_up_held = false;
    let move_down_held = false;

    const move_up_action = (_, state) => {
      move_up_held = state === 0;
    };
    const move_down_action = (_, state) => {
      move_down_held = state === 0;
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
          InputMappingsDefine_1.axisMappings.UiLookUp,
          this.q8i,
        ),
        InputDistributeController_1.InputDistributeController.BindAxis(
          InputMappingsDefine_1.axisMappings.UiTurn,
          this.G8i,
        ),
        InputDistributeController_1.InputDistributeController.BindAxis(
          InputMappingsDefine_1.axisMappings.UiMoveRight,
          CustomMoveRight,
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
        ),
        InputDistributeController_1.InputDistributeController.BindAction(
          InputMappingsDefine_1.actionMappings.UI键盘数字2手柄左,
          ChatOpen,
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
          InputMappingsDefine_1.axisMappings.UiLookUp,
          this.q8i,
        ),
        InputDistributeController_1.InputDistributeController.UnBindAxis(
          InputMappingsDefine_1.axisMappings.UiTurn,
          this.G8i,
        ),
        InputDistributeController_1.InputDistributeController.UnBindAxis(
          InputMappingsDefine_1.axisMappings.UiMoveRight,
          CustomMoveRight,
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
        InputDistributeController_1.InputDistributeController.UnBindAction(
          InputMappingsDefine_1.actionMappings.UI键盘数字2手柄左,
          ChatOpen,
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
      UiManager_1.UiManager.CloseView("FilterSettingView");
      UiManager_1.UiManager.CloseView("EyeProtectView");
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

  // ModelManager_1.ModelManager.InputDistributeModel.RefreshInputDistributeTag =
  //   function () {
  //     this.SetInputDistributeTag(
  //       InputDistributeDefine_1.inputDistributeTagDefine.FightInputRootTag,
  //     );
  //     this.AddInputDistributeTag(
  //       InputDistributeDefine_1.inputDistributeTagDefine.UiInputRootTag,
  //     );
  //   };

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

  const old_wto = plot_view_manager.wto;

  plot_view_manager.wto = (view_name, is_show) => {
    old_wto.call(plot_view_manager, view_name, is_show);
    if (is_show && view_name === "PlotSubtitleView") {
      ControllerHolder_1.ControllerHolder.PlotController.TogglePlotProtect(!1);
      ControllerHolder_1.ControllerHolder.PlotController.EnableViewControl(!1);
      ModelManager_1.ModelManager.PlotModel.PlotConfig.DisableInput = !1;
      InputDistributeController_1.InputDistributeController.BindAction(
        InputMappingsDefine_1.actionMappings.UI键盘T手柄Y,
        toggle_photo_mode,
      );
    }
  };

  const old_vj1 = plot_view_manager.vj1;

  plot_view_manager.vj1 = (view_name) => {
    if (photo_mode_active === false) {
      old_vj1.call(plot_view_manager, view_name);
    } else if (view_name === plot_view_manager.Lto) {
      plot_view_manager.Lto = undefined;
      plot_view_manager.ui = false;
      plot_view_manager.Rto = false;
      plot_view_manager.bto();
    }

    if (view_name === "PlotSubtitleView") {
      InputDistributeController_1.InputDistributeController.UnBindAction(
        InputMappingsDefine_1.actionMappings.UI键盘T手柄Y,
        toggle_photo_mode,
      );
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

  // filter adjustments and toggle handling is below
  FilterSettingView.OnBeforeStartAsync = async function () {
    var i;
    void 0 !== this.VmCache &&
      ((this.VmCache.UpLeftPos = this.GetItem(1)?.K2_GetComponentLocation()),
      (this.VmCache.UpRightPos = this.GetItem(2)?.K2_GetComponentLocation()),
      (this.VmCache.DownLeftPos = this.GetItem(3)?.K2_GetComponentLocation()),
      this.GetTexture(0)?.SetRaycastTarget(!0),
      (this.lqe = new PopupCaptionItem_1.PopupCaptionItem(this.GetItem(14))),
      this.lqe.SetHelpCallBack(this.XOe),
      this.lqe.SetCloseCallBack(this.lPe),
      this.lqe.SetTitleLocalText(MenuDefine_1.FILTER_SETTING_TITLE_TEXT_ID),
      await this.lqe.SetTitleIconByResourceId(
        MenuDefine_1.FILTER_SETTING_TITLE_ICON_RESOURCE_ID,
      ),
      this.lqe.SetCurrencyItemVisible(!1),
      (this.Vtu = new FilterSettingSliderItem()),
      (this.Vtu.OpenParam = this.OpenParam),
      await this.Vtu.CreateThenShowByActorAsync(this.GetItem(8).GetOwner()),
      (this.gpu = await this.Ykl()),
      (this.cpu = new CircleAttachView_1.CircleAttachView(
        this.GetItem(19).GetOwner(),
      )),
      this.cpu?.CreateItems(this.GetItem(11).GetOwner(), 0, this.Uye, 0),
      (i = this.VmCache.FilterList),
      this.cpu?.ReloadView(i.length, i, this.VmCache.InitFilterIndex),
      this.GetItem(11)?.SetUIActive(!1),
      (this.UNd = new GenericLayout_1.GenericLayout(
        this.GetVerticalLayout(24),
        this.xNd,
      )),
      (i = [
        ...FilterSeniorSettingAll_1.configFilterSeniorSettingAll.GetConfigList(),
      ].sort((i, t) => i.SortId - t.SortId)),
      await this.UNd.RefreshByDataAsync(i, !0));
  };

  FightPhotographView.prototype.NDc = function () {
    // UiTimeDilation_1.UiTimeDilation.NBn();
    var e = ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity;
    e?.Valid &&
      e.Entity?.Valid &&
      (e = e.Entity.GetComponent(213)) &&
      !e.HasTag(-561064175) &&
      e.AddTag(-561064175);
  };

  FightPhotographView.prototype.VDc = function () {
    // UiTimeDilation_1.UiTimeDilation.kBn();
    var e = ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity;
    e?.Valid &&
      e.Entity?.Valid &&
      (e = e.Entity.GetComponent(213)) &&
      e.HasTag(-561064175) &&
      e.RemoveTag(-561064175);
  };

  FightPhotographView.prototype.OnBeforeStartAsync = async function () {
    var t = [];

    this.IQi = new PhotographEntityPanel_1.PhotographEntityPanel();
    t.push(this.IQi.CreateByActorAsync(this.GetItem(15).GetOwner()));

    t.push(PhotographController_1.PhotographController.ChangeNpcFace());
    await Promise.all(t);
    this.zQi();
    this.IQi.SetActive(false);

    this.yQi =
      CommonParamById_1.configCommonParamById.GetIntConfig(
        "ControlCameraRate",
      ) / CommonDefine_1.PERCENTAGE_FACTOR;

    UiLayer_1.UiLayer.SetLayerActive(UiLayerType_1.ELayerType.HUD, false);
    this.xQe();

    var e =
      CommonParamById_1.configCommonParamById.GetStringConfig(
        "PhotographDAPath",
      );

    if (e?.length !== 0) {
      ResourceSystem_1.ResourceSystem.LoadAsync(
        e,
        UE.KuroSequenceConsoleCommandDataAsset,
        (t) => {
          UE.KuroSequencePerformanceManager.OpenKuroPerformanceModeInPhotographModel(
            t,
          );
        },
        100,
        this.MemoryTag,
      );
    }

    var t = GlobalData_1.GlobalData.World;

    var e = CommonParamById_1.configCommonParamById.GetStringConfig(
      "PhotographPPVLevelPath",
    );

    const o = $ref(false);

    this.$2_ = UE.LevelStreamingDynamic.LoadLevelInstance(
      t,
      e,
      Vector_1.Vector.ZeroVector,
      Rotator_1.Rotator.ZeroRotator,
      o,
    );

    if ($unref(o)) {
      const i = new CustomPromise_1.CustomPromise();

      this.$2_.OnLevelShown.Add(() => {
        ModelManager_1.ModelManager.PhotographModel.InitFilterPostProcessVolume();
        PhotographController_1.PhotographController.InitPostProcessVolBlendWeight();
        i.SetResult(undefined);
      });

      await i.Promise;
    }
    this.SEd.GetItem(4).GetParentAsUIItem().SetUIActive(false);
  };

  const MAX_ID = 9;
  ControllerHolder_1.ControllerHolder.PhotographController.U5_ = function () {
    ControllerHolder_1.ControllerHolder.PhotographController.SetPhotographOption(
      MAX_ID,
      0,
    );
    ControllerHolder_1.ControllerHolder.PhotographController.SetPhotographOption(
      MAX_ID + 1,
      1,
    );

    ModelManager_1.ModelManager.PhotographModel.IsOpenPhotograph = false;
    let t = ModelManager_1.ModelManager.PhotographModel;
    this.ResetPhotoMontage();
    t.DestroyUiCamera();
    t.ResetEntityEnable();
    t.ClearPhotographOption();
    this.m$e();
    this.DWi().SetIsDitherEffectEnable(true);
    t = Global_1.Global.BaseCharacter;

    if (
      t !== undefined &&
      !SeamlessTravelController_1.SeamlessTravelController.WasRoleEntityInSeamlessTraveling(
        t.CharacterActorComponent?.Entity,
      )
    ) {
      t?.SetDitherEffect(0, 1);
    }

    this.SetNpcFocusPhotograph(false);
    this.IsLastChecked = false;
    this.NzC = false;
    this.SetIsLineTraceBlock(false);
    this.PhotoTargets = undefined;
    this.TogetherCameraFov = undefined;
    this.v_m = undefined;
  };

  ControllerHolder_1.ControllerHolder.PhotographController.SetSingleFilterStrength =
    function () {};
  // ControllerHolder_1.ControllerHolder.PhotographController.InitPostProcessVolBlendWeight =
  //   function () {};
  ModelManager_1.ModelManager.PhotographModel.SetFilterStrength =
    function () {};

  ControllerHolder_1.ControllerHolder.PhotographController.InitializeDefaultPhotographOption =
    function () {
      for (const o of ConfigManager_1.ConfigManager.PhotographConfig.GetAllPhotoSetupConfig()) {
        if (o.ValueType === 8) continue;
        let t = -1;
        var e = o.Type;
        (0 === e
          ? (t = o.DefaultOptionIndex)
          : 1 === e && (t = o.ValueRange[2]),
          this.SetPhotographOption(o.ValueType, t, !0));
      }
      2 === this.CameraCaptureType && this.SetNpcFocusPhotograph(!0);
      this.SetPhotographOption(
        MAX_ID + 1,
        ModelManager_1.ModelManager.TimeOfDayModel?.GameTime?.Second,
      );
    };

  ControllerHolder_1.ControllerHolder.PhotographController.SetPhotographOption =
    function (t, e, o = !1) {
      var i = ModelManager_1.ModelManager.PhotographModel;
      switch ((i.SetPhotographOption(t, e), t)) {
        case 3:
          1 === e
            ? ((r = i.GetPhotographOption(4)),
              (a = i.GetPhotographOption(5)),
              (this.TWi.FocusSettings.ManualFocusDistance = r),
              (this.TWi.CurrentAperture = a))
            : ((this.TWi.FocusSettings.ManualFocusDistance =
                PhotographDefine_1.DEFAULT_FOCAL_LENTGH),
              (this.TWi.CurrentAperture = PhotographDefine_1.DEFAULT_APERTURE));
          break;
        case 4:
          1 === i.GetPhotographOption(3)
            ? (this.TWi.FocusSettings.ManualFocusDistance = e)
            : o ||
              (Log_1.Log.CheckError() &&
                Log_1.Log.Error(
                  "Photo",
                  71,
                  "焦距选项未打开，尝试设置焦距失败",
                ));
          break;
        case 5:
          1 === i.GetPhotographOption(3)
            ? (this.TWi.CurrentAperture = e)
            : o ||
              (Log_1.Log.CheckError() &&
                Log_1.Log.Error(
                  "Photo",
                  71,
                  "光圈选项未打开，尝试设置光圈失败",
                ));
          break;
        case 0: {
          var r = ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity;

          if (e === 1) {
            i.SetEntityEnable(r, true);
          } else {
            i.SetEntityEnable(r, false);
          }

          break;
        }
        case 2: {
          var a =
            ModelManager_1.ModelManager.SceneTeamModel?.GetCurrentEntity?.Id;
          if (!a) {
            return;
          }
          r = EntitySystem_1.EntitySystem.Get(a);
          if (!r?.Valid) {
            return;
          }
          if (this.GetRoleMainAnimInstanceType() !== 0) {
            return;
          }
          r.GetComponent(190).MainAnimInstance.设置头部转向状态(1);
          break;
        }

        case 6: {
          a =
            ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();
          if (!a) {
            return;
          }

          if (e === 1) {
            r = i.GetPhotographOption(7);
            a.SetCameraArmRoll(r);
          } else {
            a.SetCameraArmRoll(0);
          }

          break;
        }
        case 7: {
          r =
            ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();
          if (!r) {
            return;
          }

          if (i.GetPhotographOption(6) === 1) {
            r.SetCameraArmRoll(e < 0 ? e + 360 : e);
          } else if (!o) {
            if (Log_1.Log.CheckError()) {
              Log_1.Log.Error(
                "Photo",
                71,
                "倾斜角选项未打开，尝试设置倾斜角失败",
              );
            }
          }

          break;
        }
        case 8:
          const view = UiManager_1.UiManager.GetViewByName(
            "FightPhotographView",
          );
          if (view) {
            view.OnBackButtonClicked = () => {
              ControllerHolder_1.ControllerHolder.PhotographController.CloseFightPhotographMode();
            };
          }
          if (e == true || e === 1) {
            view?.SEd?.Jzd(false);
          } else {
            view?.SEd?.Jzd(true);
            const entity =
              ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity;
            if (entity?.Valid && entity.Entity?.Valid) {
              const comp = entity.Entity.GetComponent(213);
              comp?.HasTag(-561064175) && comp.RemoveTag(-561064175);
            }
          }
          break;
        case 10:
          const list_of_actors =
            ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity.Entity.GetComponent(
              23,
            ).Sau;

          for (const [key, value] of list_of_actors) {
            var actor = EffectSystem_1.EffectSystem.GetEffectActor(
              value.EffectViewHandle,
            );
            actor?.SetActorHiddenInGame(e == false || e === 0);
          }
          break;
        case 11:
          TimeOfDayController_1.TimeOfDayController.AdjustTime(
            e,
            Protocol_1.Aki.Protocol.C4s.Proto_PlayerOperate,
          );
          break;
        case 12:
          this.SetPhotographOption(12, 0);
          break;
        case 13:
          dilate_time(e);
          break;
        case 14:
        case 15:
        case 16: {
          const structure =
            ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();
          const cam = structure?.$Uo;
          if (!cam) break;
          if (t === 11) cam.CameraLeftAndRightSpeed = e;
          else if (t === 12) cam.CameraUpAndDownSpeed = e;
          else cam.CameraForwardAndBackwardSpeed = e;
        }
      }
    };

  const original_set_local_text_new = LguiUtil_1.LguiUtil.SetLocalTextNew.bind(
    LguiUtil_1.LguiUtil,
  );
  LguiUtil_1.LguiUtil.SetLocalTextNew = function (e, t, ...r) {
    if (typeof t === "string" && t.startsWith("CUSTOM_")) {
      e?.SetText(t.slice(7));
      return;
    }
    original_set_local_text_new(e, t, ...r);
  };

  PhotographSetupView.prototype.R1_ = function () {};
  PhotographSetupView.prototype.OnBeforeDestroy = function () {
    this.sQi();
    this.aQi();
    this.hQi();
    this.P1_();
    this.FKi.clear();
    this.FKi = undefined;
    this.c4_?.Destroy();
    this.E1_?.Destroy();
  };
  ModelManager_1.ModelManager.PhotographModel.SetPhotographFilter =
    function () {};
  // ModelManager_1.ModelManager.PhotographModel.InitFilterPostProcessVolume =
  //   function () {};

  PhotographView_1.PhotographView.prototype.OnBeforeShow = function () {
    let t;
    let e;
    let o;

    const i =
      ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();

    if (i) {
      this.gSl();

      (t = Global_1.Global.BaseCharacter) &&
        PhotographController_1.PhotographController.GetFightCameraActor() &&
        PhotographController_1.PhotographController.CheckIfInEntityCamera() &&
        ((t = new UE.VectorDouble(
          t?.D_K2_GetActorLocation().X,
          t?.D_K2_GetActorLocation().Y,
          PhotographController_1.PhotographController.GetFightCameraActor().D_K2_GetActorLocation()
            .Z,
        )),
        (e =
          PhotographController_1.PhotographController.GetFightCameraActor().K2_GetActorRotation()),
        (o =
          PhotographController_1.PhotographController.GetFightCameraActor().D_GetActorScale3D()),
        i.SetSpringArmLength(0),
        i.SetCameraInitializeTransform(new UE.TransformDouble(e, t, o)));

      InputDistributeController_1.InputDistributeController.BindTouches(
        [
          InputMappingsDefine_1.touchIdMappings.Touch1,
          InputMappingsDefine_1.touchIdMappings.Touch2,
        ],
        this.Eqt,
      );

      ControllerHolder_1.ControllerHolder.MenuController.OpenAllFilter();

      this.ZQi();
      this.JQi();

      RedDotController_1.RedDotController.BindRedDot(
        "FunctionPhotograph",
        this.GetItem(19),
      );
    }
  };

  FightPhotographView.prototype.OnBeforeShow = function () {
    let t;
    let e;
    let o;

    const i =
      ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();

    if (i) {
      this.gSl();

      (t = Global_1.Global.BaseCharacter) &&
        PhotographController_1.PhotographController.GetFightCameraActor() &&
        PhotographController_1.PhotographController.CheckIfInEntityCamera() &&
        ((t = new UE.VectorDouble(
          t?.D_K2_GetActorLocation().X,
          t?.D_K2_GetActorLocation().Y,
          PhotographController_1.PhotographController.GetFightCameraActor().D_K2_GetActorLocation()
            .Z,
        )),
        (e =
          PhotographController_1.PhotographController.GetFightCameraActor().K2_GetActorRotation()),
        (o =
          PhotographController_1.PhotographController.GetFightCameraActor().D_GetActorScale3D()),
        i.SetSpringArmLength(0),
        i.SetCameraInitializeTransform(new UE.TransformDouble(e, t, o)));

      InputDistributeController_1.InputDistributeController.BindTouches(
        [
          InputMappingsDefine_1.touchIdMappings.Touch1,
          InputMappingsDefine_1.touchIdMappings.Touch2,
        ],
        this.Eqt,
      );

      ControllerHolder_1.ControllerHolder.MenuController.OpenAllFilter();

      this.ZQi();
      this.JQi();

      RedDotController_1.RedDotController.BindRedDot(
        "FunctionPhotograph",
        this.GetItem(19),
      );
    }
  };
  FightPhotographView.prototype.OnAfterHide = function () {
    InputDistributeController_1.InputDistributeController.UnBindTouches(
      [
        InputMappingsDefine_1.touchIdMappings.Touch1,
        InputMappingsDefine_1.touchIdMappings.Touch2,
      ],
      this.Eqt,
    );

    RedDotController_1.RedDotController.UnBindGivenUi(
      "FunctionPhotograph",
      this.GetItem(19),
    );

    this.iWC();

    if (
      !PhotographController_1.PhotographController.CheckIfInFightPhotographCamera()
    ) {
      UiTimeDilation_1.UiTimeDilation.DeleteWaitSetTimeDilationTag(
        this.Info.Name,
      );
    }
  };
}, 0);
