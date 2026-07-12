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
  const LocalStorageDefine_1 = require("Game/Common/LocalStorageDefine.js");
  const LocalStorage_1 = require("Game/Common/LocalStorage.js");
  const MAX_ID = 9;
  const {
    PhotographValueSetup,
  } = require("Game/Module/Photograph/View/PhotographValueSetup.js");
  const {
    PhotographValueWithoutTitleSetup,
  } = require("Game/Module/Photograph/View/PhotographValueWithoutTitleSetup.js");
  const {
    PhotographOptionSetup,
  } = require("Game/Module/Photograph/View/PhotographOptionSetup.js");
  const ConfigManager_1 = require("../Game/Manager/ConfigManager.js");
  const LogReportDefine_1 = require("Game/Module/LogReport/LogReportDefine.js");
  const LogReportController_1 = require("Game/Module/LogReport/LogReportController.js");
  const GameSettingsDumpUtils_1 = require("Game/GameSettings/GameSettingsDumpUtils.js");
  const GameSettingsUtils_1 = require("Game/GameSettings/GameSettingsUtils.js");
  const {
    LevelSequencePlayer,
  } = require("../Game/Module/Common/LevelSequencePlayer.js");
  const {
    MovieModeController,
  } = require("../Game/Module/MovieMode/MovieModeController.js");
  const {
    MovieModeAspectView,
  } = require("../Game/Module/MovieMode/MovieModeAspectView.js");
  const {
    RouletteExploreSkillController,
  } = require("Game/Module/Roulette/RouletteExploreSkillController.js");

  RouletteExploreSkillController.tFm = () => {
    ControllerHolder_1.ControllerHolder.PhotographController.TryOpenPhotograph(
      0,
    );
  };

  RouletteExploreSkillController.XGm.set(
    700103,
    RouletteExploreSkillController.tFm,
  );

  const plot_view_manager = PlotController_1.PlotController.PlotViewManager;

  SpecialSkillAogusita.prototype.OnStart = function () {
    var e,
      t = this.SpecialSkillComponent.Entity;
    ((this.Hte = t.GetComponent(3)),
      (this.cBe = t.GetComponent(44)),
      this.Hte?.IsRoleAndCtrlByMe &&
        ((this.Nce = t.GetComponent(70)),
        (e = t.GetComponent(222)),
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

    const specialSkillComp = entity.GetComponent(286);
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

  PhotoSaveView.prototype.vNn = function () {};

  PhotoSaveView.prototype.gKi = function () {
    if (this.x4_) {
      const i = UE.WidgetLayoutLibrary.GetViewportSize(
        GlobalData_1.GlobalData.World,
      );
      return [0, 0, i.X, i.Y];
    }
    var e = this.GetItem(this.WWi ? 11 : 23);
    var t = this.GetItem(this.WWi ? 12 : 24);
    var e = e.GetPositionInViewPort(true);
    var t = t.GetPositionInViewPort(true);
    const i = UE.WidgetLayoutLibrary.GetViewportSize(
      GlobalData_1.GlobalData.World,
    );
    return [
      e.X < 0 ? 0 : e.X,
      e.Y < 0 ? 0 : e.Y,
      (t.X < i.X ? t : i).X,
      (t.Y < i.Y ? t : i).Y,
    ];
  };

  PhotoSaveView.prototype.D4_ = function (e) {
    const t = this.GetItem(14);

    t.SetUIActive(true);
    this.GetItem(15).SetUIActive(false);
    const i = this.GetItem(13);

    const h = UE.WidgetLayoutLibrary.GetViewportSize(
      GlobalData_1.GlobalData.World,
    );

    const r = UE.WidgetLayoutLibrary.GetViewportScale(
      GlobalData_1.GlobalData.World,
    );

    if (e) {
      i.SetWidth(h.X / r);
      i.SetHeight(h.Y / r);
      this.U4_ = t.K2_GetComponentScale();
      t.SetUIItemScale(new UE.Vector(1, 1, 1));
      const offset = t.RelativeLocation;
      offset.Y = offset.Y - 10;
      t.SetUIRelativeLocation(offset);

      EventSystem_1.EventSystem.Emit(
        EventDefine_1.EEventName.OnPreparePhotoScreenShot,
        false,
      );
    } else {
      i.SetWidth(h.X / (r * PhotographDefine_1.SCREEN_SHOT_TEXTURE_SCALE));
      i.SetHeight(h.Y / (r * PhotographDefine_1.SCREEN_SHOT_TEXTURE_SCALE));
      t.SetUIItemScale(this.U4_);
      t.SetUIRelativeLocation(new UE.Vector(0, 0, 0));

      EventSystem_1.EventSystem.Emit(
        EventDefine_1.EEventName.OnPreparePhotoScreenShot,
        true,
      );
    }
  };

  PhotoSaveView.prototype.zWi = function (e, t, i, h) {
    this.Hide();
    UE.LGUIBPLibrary.ResetGlobalBlurUIItem(
      GlobalData_1.GlobalData.GameInstance.GetWorld(),
    );
    if (UiManager_1.UiManager.IsViewOpen("FightPhotographView")) {
      UiManager_1.UiManager.GetViewByName("FightPhotographView").dSl(false);
    }
    if (UiManager_1.UiManager.IsViewOpen("PhotographView")) {
      UiManager_1.UiManager.GetViewByName("PhotographView").dSl(false);
    }
    var r = this.EJl();
    let o = this.gKi();
    this.KWi = this.fKi(r);
    var r = UE.BlueprintPathsLibrary.ProjectUserDir();
    var r = r + this.KWi;

    var r = ScreenShotManager_1.ScreenShotManager.PrepareTakeScreenshot(
      r,
      o[0],
      o[1],
      o[2],
      o[3],
      e,
    );

    if (r) {
      r.OnTakeScreenshotCapturedDelegate.Add(t);
      i && r.OnIOSPhotoLibraryAuthorizationCompletedDelegate.Add(i);
      h && r.OnTakeScreenshotCompressedDelegate.Add(h);

      Log_1.Log.CheckInfo() &&
        Log_1.Log.Info("Photo", 58, "开始截图", ["isSaveFile", e]);

      setTimeout(() => {
        o =
          (
            LocalStorage_1.LocalStorage.GetGlobal(
              LocalStorageDefine_1.ELocalStorageGlobalKey.PhotographSetupOption,
            ) ?? new Map()
          ).get(8) ?? 1;
        r.TakeScreenshotHighRes(o);

        setTimeout(() => {
          if (UiManager_1.UiManager.IsViewOpen("FightPhotographView")) {
            UiManager_1.UiManager.GetViewByName("FightPhotographView").dSl(
              true,
            );
          }
          if (UiManager_1.UiManager.IsViewOpen("PhotographView")) {
            UiManager_1.UiManager.GetViewByName("PhotographView").dSl(true);
          }
          this.Show();
        }, 500);
      }, 500);
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

  RouletteModel.prototype.IsExploreRouletteOpen = function () {
    return true;
  };

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

  const orig_play_sequence_purely =
    LevelSequencePlayer.prototype.PlaySequencePurely;
  const PAUSE_DILATION_THRESHOLD = 0.01;
  const dilate_time = (dilation) => {
    if (!Number.isFinite(dilation)) return;
    const should_pause = dilation < PAUSE_DILATION_THRESHOLD && dilation !== 1;
    if (should_pause) {
      TickSystem_1.TickSystem.IsPaused = true;
      UE.GameplayStatics.SetGamePaused(GlobalData_1.GlobalData.World, true);
    } else {
      TickSystem_1.TickSystem.IsPaused = false;
      UE.GameplayStatics.SetGamePaused(GlobalData_1.GlobalData.World, false);
    }
    if (dilation < 1) {
      LevelSequencePlayer.prototype.PlaySequencePurely = function (
        e,
        t = false,
        i = false,
        s = undefined,
        h = undefined,
        r = false,
      ) {
        const ctx = this.GetSequencePlayContext(e);
        if (ctx) {
          ctx.ExecutePlay();
          this.EndSequenceLastFrame(e);
        }
        s?.SetResult(true);
      };
    } else {
      LevelSequencePlayer.prototype.PlaySequencePurely =
        orig_play_sequence_purely;
    }
    ControllerHolder_1.ControllerHolder.GameModeController.SetTimeDilation(
      dilation,
      2,
    );
    UE.GameplayStatics.SetGlobalTimeDilation(
      GlobalData_1.GlobalData.World,
      dilation,
    );
  };

  const jump_to_end = (player, key) => {
    if (!player) return;
    const ctx = player.GetSequencePlayContext(key);
    if (!ctx) return;
    ctx.ExecutePlay();
    const seq = player.Zxt(key);
    if (seq?.IsValid()) {
      player.Qxt.SequenceJumpToSecondByKey(
        key,
        seq.SequencePlayer.GetDuration().Time,
      );
    }
  };

  PhotographOptionSetup.prototype.EUt = function (t, e = true) {
    t = (this.PKi = t) ? "ClickL" : "ClickR";
    jump_to_end(this.SPe, t);
  };

  PhotographOptionSetup.prototype.OnBeforeShow = function () {
    jump_to_end(this.MU_, "Start02");
  };

  PhotographController.ScreenShot = function (t) {
    UiManager_1.UiManager.CloseView("GenericPromptView");
    dilate_time(0);
    const e =
      Global_1.Global.BaseCharacter.CharacterActorComponent.ActorLocationProxy;

    const o = ModelManager_1.ModelManager.PhotographModel;
    var i = ModelManager_1.ModelManager.SceneTeamModel;
    const r = ModelManager_1.ModelManager.AreaModel;
    var i = i.GetCurrentEntity.Entity.GetComponent(0).GetRoleId();
    const a = o.GetPhotographOption(0);

    const n = LocalStorage_1.LocalStorage.GetGlobal(
      LocalStorageDefine_1.ELocalStorageGlobalKey.PhotoAndShareShowPlayerName,
      true,
    );

    const s = o.GetPhotographOption(3);
    const h = o.GetPhotographFilter();
    const _ = new LogReportDefine_1.PhotographerLogData();
    _.event_id = "1009";
    _.i_area_id = r.AreaInfo.AreaId;
    _.i_father_area_id = r.AreaInfo.Father;
    _.f_pos_x = e.X;
    _.f_pos_y = e.Y;
    _.f_pos_z = e.Z;
    _.i_motion = o.MontageId;
    _.i_expression = 0;
    _.i_role_id = i;
    _.i_shot_option = o.GetPhotographOption(2);
    _.i_self_option = a ? 0 : 1;
    _.i_info_option = n ? 0 : 1;
    _.i_dof_option = s ? 1 : 0;
    _.i_filter_id = h;
    LogReportController_1.LogReportController.LogReport(_);

    UiManager_1.UiManager.OpenView("PhotoSaveView", t, () => {
      dilate_time(PhotographModel.GetPhotographOption(MAX_ID + 4));
      EventSystem_1.EventSystem.Emit(EventDefine_1.EEventName.OnScreenShotDone);

      if (this.CameraCaptureType === 1) {
        if (this.IsLastChecked) {
          EventSystem_1.EventSystem.Emit(
            EventDefine_1.EEventName.OnEntityCameraFinished,
            true,
          );
        } else {
          EventSystem_1.EventSystem.Emit(
            EventDefine_1.EEventName.OnEntityCameraFinished,
            false,
          );
        }
      }
    });
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

  // ModelManager_1.ModelManager.PhotographModel.SetPhotographTimeDilation =
  //   function (t) {
  //     Log_1.Log.Info("Photograph", 57, "SetPhotographTimeDilation", [
  //       "timeDilation",
  //       t,
  //     ]);

  //     if (t !== 1) {
  //       AudioSystem_1.AudioSystem.SetState("game_sys_fightphoto", "slow");
  //       AudioSystem_1.AudioSystem.PostEvent("play_ui_battlephoto_timestop");
  //     }

  //     ControllerHolder_1.ControllerHolder.GameModeController.SetTimeDilation(
  //       t,
  //       4,
  //     );
  //   };

  // const _super_on_after_hide = FightPhotographView.prototype.OnAfterHide;
  // FightPhotographView.prototype.OnAfterHide = function () {
  //   _super_on_after_hide.call(this);
  // };

  const orig_close_fight_photograph_mode =
    ControllerHolder_1.ControllerHolder.PhotographController
      .CloseFightPhotographMode;
  ControllerHolder_1.ControllerHolder.PhotographController.CloseFightPhotographMode =
    function (...args) {
      dilate_time(1);
      LevelSequencePlayer.prototype.PlaySequencePurely =
        orig_play_sequence_purely;
      orig_close_fight_photograph_mode.apply(this, args);
    };

  const orig_close_photograph =
    ControllerHolder_1.ControllerHolder.PhotographController.ClosePhotograph;
  ControllerHolder_1.ControllerHolder.PhotographController.ClosePhotograph =
    function (...args) {
      dilate_time(1);
      LevelSequencePlayer.prototype.PlaySequencePurely =
        orig_play_sequence_purely;
      orig_close_photograph.apply(this, args);
    };

  ControllerHolder_1.ControllerHolder.PhotographController.OMa = function () {};

  const original_uicam_get = UiCameraManager_1.UiCameraManager.Get;
  UiCameraManager_1.UiCameraManager.Get = function () {
    const cam = original_uicam_get.call(this);
    cam.Enter = function (e = 0, t = 0, r = 0, o) {
      if (this.JRo) return;
      const in_photo = UiManager_1.UiManager.IsViewOpen("PhotographView");
      CameraController_1.CameraController.EnterCameraMode(
        2,
        in_photo ? 0 : e,
        t,
        r,
        o,
      );
      for (const i of this.$Ro.values()) i.Activate();
      this.JRo = true;
    };
    return cam;
  };

  const _superOnAfterShow =
    PhotographView_1.PhotographView.prototype.OnAfterShow;

  PhotographView_1.PhotographView.prototype.OnBeforeCreate = function () {
    PhotographController_1.PhotographController.InitPhotographRelativeContent();
    dilate_time(0);
    detach_plot_camera();
  };

  let last_recorded_style =
    ModelManager_1.ModelManager.PhotographModel.GetPhotographOption(MAX_ID + 8);

  const externally_hidden = new Set();

  const toggle_weapon_hidden = (hide) => {
    const entity =
      ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity?.Entity;
    if (!entity?.Valid) return;

    const weapon_comp = entity.GetComponent(89);
    if (!weapon_comp) return;

    for (const w of weapon_comp.QKr.CharacterWeapons) {
      if (hide) {
        weapon_comp.bQr(w, true, false, true, 0, "InstantHideNoEffect");
        externally_hidden.add(w);
      } else {
        if (externally_hidden.has(w)) {
          externally_hidden.delete(w);
          if (!w.WeaponHidden || externally_hidden.has(w)) continue;
          weapon_comp.bQr(w, false, false, true, 0, "InstantHideNoEffect");
        }
      }
    }
  };

  function get_owner_actor(entity) {
    const rendering_component =
      entity.GetComponent(3)?.Actor?.CharRenderingComponent;
    return rendering_component?.GetCachedOwner?.();
  }

  UiCameraPhotographerStructure.prototype.OnSpawnStructureActor = function () {
    externally_hidden.clear();
    // if (
    //   ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity.PbDataId ===
    //   1110
    // ) {
    //   const owner = get_owner_actor(
    //     ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity.Entity,
    //   );

    //   const cases = ["OtherCase1", "OtherCase2", "OtherCase3", "OtherCase6"];
    //   for (const c of cases) {
    //     const mat = owner[c].GetMaterial(4);
    //     mat.SetScalarParameterValue(new UE.FName("Base_bAddSecond"), 1);
    //     mat.SetVectorParameterValue(
    //       new UE.FName("Second_Contorl"),
    //       new UE.LinearColor(0, 1, 0.25, 0),
    //     );

    //     const mat2 = owner[c].GetMaterial(1);
    //     mat2.SetScalarParameterValue(new UE.FName("Base_bAddSecond"), 1);
    //     mat2.SetVectorParameterValue(
    //       new UE.FName("Second_Contorl"),
    //       new UE.LinearColor(0, 1, 0.25, 0),
    //     );
    //   }
    //   owner.OtherCase12.SetHiddenInGame(false, true);
    // }
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
      this.MaxFov = 180;
      this.MinFov = 0;
      this.CameraUpAndDownSpeed = 1;
      this.CameraLeftAndRightSpeed = 1;
      this.CameraForwardAndBackwardSpeed = 1;
      this.CameraForwardAndBackSpeed = 1;

      this.CameraInitializeFov = -1;
      const s =
        ControllerHolder_1.ControllerHolder.PhotographController.CheckIfInFightPhotographCamera();

      this.CameraUpAndDownMaxDistance = 100000000;
      this.CameraLeftAndRightMaxDistance = 100000000;
      this.CameraForwardAndBackMaxDistance = 100000000;
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

    last_recorded_style =
      ModelManager_1.ModelManager.PhotographModel.GetPhotographOption(
        MAX_ID + 8,
      );
    photographer.RefreshCameraArm = function () {
      if (move_up_held) CustomMoveUp(null, 1);
      if (move_down_held) CustomMoveUp(null, -1);
      if (this.PitchInput === 0 && this.YawInput === 0) return;

      const movement_style =
        ModelManager_1.ModelManager.PhotographModel.GetPhotographOption(
          MAX_ID + 8,
        );

      if (movement_style === 5) {
        this.TmpRotator.DeepCopy(
          this.CapsuleCollision.K2_GetComponentRotation(),
        );
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
      } else {
        let t;
        if (this.PitchInput !== 0 || this.YawInput !== 0) {
          this.TmpRotator.DeepCopy(
            this.CapsuleCollision.K2_GetComponentRotation(),
          );

          this.TmpRotator.Quaternion(this.TmpQuat);

          t = GravityUtils_1.GravityUtils.GetGravityUpForActor(
            Global_1.Global.BaseCharacter?.CharacterActorComponent,
          );

          Quat_1.Quat.ConstructorByAxisAngle(
            t,
            this.YawInput * MathUtils_1.MathUtils.DegToRad,
            this.TmpQuat2,
          );

          this.TmpQuat2.Multiply(this.TmpQuat, this.TmpQuat3);
          this.TmpQuat.DeepCopy(this.TmpQuat3);
          t = this.GetArmPitch();

          t =
            MathUtils_1.MathUtils.Clamp(
              this.PitchInput + t,
              this.SourceMinPitch,
              this.SourceMaxPitch,
            ) - t;

          Math.abs(t) > MathUtils_1.MathUtils.SmallNumber &&
            (this.TmpRotator2.Set(t, 0, 0),
            this.TmpRotator2.Quaternion(this.TmpQuat2),
            this.TmpQuat.Multiply(this.TmpQuat2, this.TmpQuat3),
            this.TmpQuat.DeepCopy(this.TmpQuat3));

          this.TmpQuat.Rotator(this.TmpRotator);

          this.CapsuleCollision.K2_SetRelativeRotation(
            this.TmpRotator.ToUeRotator(),
            false,
            undefined,
            false,
          );

          this.PitchInput = 0;
          this.YawInput = 0;
        }
      }
    };

    PhotographView_1.PhotographView.prototype.ZQi = function () {
      const fov_slider = this.GetSlider(10);

      if (
        PhotographController.CheckIfInNormalCamera() ||
        PhotographController.CheckIfInFightPhotographCamera()
      ) {
        this.kQd = 180;
        this.BQd = 0;
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
        const max_fov = parseInt(180);
        const min_fov = parseInt(0);
        const default_fov = 60;

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

  PhotographView_1.PhotographView.prototype.dSl = function (t) {
    let e;

    if (this.mSl !== t) {
      this.GetItem(11).SetUIActive(t);

      (e = UiManager_1.UiManager.GetViewByName("PhotographSetupView")) &&
        e.IsShowOrShowing &&
        e.SetPanelVisible(t);

      // this.SEd?.SetUiActive(t);
      this.mSl = t;
      ModelManager_1.ModelManager.LoadingModel.IsShowUidView = this.mSl;
    }
  };

  PhotographView_1.PhotographView.prototype.OnBeforeStartAsync =
    async function () {
      var t = [],
        e =
          ((this.IQi = new PhotographEntityPanel_1.PhotographEntityPanel()),
          t.push(this.IQi.CreateByActorAsync(this.GetItem(15).GetOwner())),
          // this.GetButton(14).RootUIComp.SetUIActive(false),
          // (e = this.GetItem(16)),
          await Promise.all(t),
          this.zQi(),
          this.IQi.SetActive(false),
          (this.yQi =
            CommonParamById_1.configCommonParamById.GetIntConfig(
              "ControlCameraRate",
            ) / CommonDefine_1.PERCENTAGE_FACTOR),
          UiLayer_1.UiLayer.SetLayerActive(UiLayerType_1.ELayerType.HUD, false),
          this.xQe(),
          CommonParamById_1.configCommonParamById.GetStringConfig(
            "PhotographDAPath",
          )),
        t =
          (0 !== e?.length &&
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
            ),
          GlobalData_1.GlobalData.World),
        e = CommonParamById_1.configCommonParamById.GetStringConfig(
          "PhotographPPVLevelPath",
        ),
        o = (0, puerts_1.$ref)(false);
      if (
        ((this.$2_ = UE.LevelStreamingDynamic.LoadLevelInstance(
          t,
          e,
          Vector_1.Vector.ZeroVector,
          Rotator_1.Rotator.ZeroRotator,
          o,
        )),
        (0, puerts_1.$unref)(o))
      ) {
        const i = new CustomPromise_1.CustomPromise();
        this.$2_.OnLevelShown.Add(() => {
          ModelManager_1.ModelManager.PhotographModel.InitFilterPostProcessVolume();
          PhotographController_1.PhotographController.InitPostProcessVolBlendWeight();
          i.SetResult(void 0);
        });
        await i.Promise;
      }
    };

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
    const t = ModelManager_1.ModelManager.PhotographModel;
    PhotographController.ResetPhotoMontage();
    t.DestroyUiCamera();
    t.ResetEntityEnable();
    t.ClearPhotographOption();
    PhotographController.m$e();
    PhotographController.DWi().SetIsDitherEffectEnable(true);
    const char = Global_1.Global.BaseCharacter;
    if (char !== undefined) {
      char?.SetDitherEffect(0, 1);
    }
    PhotographController.SetNpcFocusPhotograph(false);
    PhotographController.IsLastChecked = false;
    PhotographController.b$C = false;
    PhotographController.SetIsLineTraceBlock(false);
    PhotographController.PhotoTargets = undefined;
    PhotographController.TogetherCameraFov = undefined;
    PhotographController.v_m = undefined;
  };

  ControllerHolder_1.ControllerHolder.PhotographController.SetSingleFilterStrength =
    function () {};
  // ControllerHolder_1.ControllerHolder.PhotographController.InitPostProcessVolBlendWeight =
  //   function () {};
  ModelManager_1.ModelManager.PhotographModel.SetFilterStrength =
    function () {};

  ControllerHolder_1.ControllerHolder.PhotographController.InitializeDefaultPhotographOption =
    function () {
      var t =
        ConfigManager_1.ConfigManager.PhotographConfig.GetAllPhotoSetupConfig();

      const e =
        LocalStorage_1.LocalStorage.GetGlobal(
          LocalStorageDefine_1.ELocalStorageGlobalKey.PhotographSetupOption,
        ) ?? new Map();

      for (const i of t) {
        if (i.ValueType === MAX_ID + 2 || i.ValueType === MAX_ID + 12) {
          continue;
        }
        let t = -1;
        const i_Type = i.Type;

        if (i.IsLocalStorage && e.has(i.ValueType)) {
          t = e.get(i.ValueType);
        } else if (i_Type === 0) {
          t = i.DefaultOptionIndex;
        } else if (i_Type === 1 || i_Type === 3) {
          t = i.ValueRange[2];
        } else if (i_Type === 2) {
          t = i.DefaultDropDownIndex;
        }

        this.SetPhotographOption(i.ValueType, t, true);
      }

      if (this.CameraCaptureType === 2) {
        this.SetNpcFocusPhotograph(true);
      }
      this.SetPhotographOption(
        MAX_ID + 2,
        ModelManager_1.ModelManager.TimeOfDayModel?.GameTime?.Second,
      );
      this.SetPhotographOption(
        MAX_ID + 12,
        UE.KismetSystemLibrary.GetConsoleVariableFloatValue(
          "r.Kuro.KuroBloomEnable",
        ),
      );
    };

  function saveToLocalStorage(valueType, value) {
    const map =
      LocalStorage_1.LocalStorage.GetGlobal(
        LocalStorageDefine_1.ELocalStorageGlobalKey.PhotographSetupOption,
      ) ?? new Map();
    map.set(valueType, value);
    LocalStorage_1.LocalStorage.SetGlobal(
      LocalStorageDefine_1.ELocalStorageGlobalKey.PhotographSetupOption,
      map,
    );
  }

  const _original_ValueSetup_OnStart = PhotographValueSetup.prototype.OnStart;
  PhotographValueSetup.prototype.OnStart = function () {
    _original_ValueSetup_OnStart.call(this);
    this.pQi = (e, t = 0) => {
      let r;
      if (this.SetupConfig.IsReverseSet) {
        r = this.SetupConfig.ValueRange;
        r = MathUtils_1.MathUtils.RangeClamp(e, r[0], r[1], r[1], r[0]);
        PhotographController_1.PhotographController.SetPhotographOption(
          this.SetupConfig.ValueType,
          r,
        );
      } else {
        r = e;
        PhotographController_1.PhotographController.SetPhotographOption(
          this.SetupConfig.ValueType,
          e,
        );
      }
      if (this.SetupConfig.IsLocalStorage) {
        saveToLocalStorage(this.SetupValueType, r);
      }
    };
    this.GetSlider(1).OnValueChangeCb.Unbind();
    this.GetSlider(1).OnValueChangeCb.Bind(this.pQi);
  };

  PhotographValueWithoutTitleSetup.DeferredUpdateTypes = new Set([MAX_ID + 10]);

  PhotographValueWithoutTitleSetup.prototype.OnStart = function () {
    this.SPe = new LevelSequencePlayer(this.RootItem);
    this._pendingDeferredValue = undefined;
    this.pQi = (e, t = 0) => {
      let r;
      if (this.SetupConfig.IsReverseSet) {
        r = this.SetupConfig.ValueRange;
        r = MathUtils_1.MathUtils.RangeClamp(e, r[0], r[1], r[1], r[0]);
      } else {
        r = e;
      }
      this.Jkl(r);
      if (
        PhotographValueWithoutTitleSetup.DeferredUpdateTypes.has(
          this.SetupConfig.ValueType,
        )
      ) {
        this._pendingDeferredValue = r;
        return;
      }
      PhotographController_1.PhotographController.SetPhotographOption(
        this.SetupConfig.ValueType,
        r,
      );
      if (this.SetupConfig.IsLocalStorage) {
        saveToLocalStorage(this.SetupValueType, r);
      }
    };
    this.GetSlider(0).OnValueChangeCb.Bind(this.pQi);
    this.GetSlider(0).OnEndDragCb.Bind(() => {
      if (this._pendingDeferredValue !== undefined) {
        PhotographController_1.PhotographController.SetPhotographOption(
          this.SetupConfig.ValueType,
          this._pendingDeferredValue,
        );
        if (this.SetupConfig.IsLocalStorage) {
          saveToLocalStorage(this.SetupValueType, this._pendingDeferredValue);
        }
        this._pendingDeferredValue = undefined;
      }
    });
  };

  const _original_OptionSetup_OnStart = PhotographOptionSetup.prototype.OnStart;
  PhotographOptionSetup.prototype.OnStart = function () {
    _original_OptionSetup_OnStart.call(this);
    this.UFe = () => {
      this.EUt(!this.PKi);
      this.wKi(this.PKi);
      this.BKi();
      if (this.SetupConfig.IsLocalStorage) {
        saveToLocalStorage(this.SetupValueType, this.AKi);
      }
      if (this.xKi) {
        this.xKi(this.AKi);
      }
      this.MarkPhotoSetupRedDotAsRead(() => {
        this.GetItem(2)?.SetUIActive(false);
      });
    };
    this.GetButton(1).OnClickCallBack.Unbind();
    this.GetButton(1).OnClickCallBack.Bind(this.UFe);
  };

  PhotographSetupView.prototype.oQi = async function () {
    const t =
      ConfigManager_1.ConfigManager.PhotographConfig.GetAllPhotoSetupConfig();

    const i = this.GetItem(5);
    const e = this.GetItem(6);
    const s = this.GetItem(13);
    const h = this.GetItem(14);

    i.SetUIActive(true);
    e.SetUIActive(true);
    s.SetUIActive(true);
    h.SetUIActive(true);
    const o = [];

    const sorted = [...t].sort((a, b) => {
      const a_id = typeof a.id === "function" ? a.id() : a.Id;
      const b_id = typeof b.id === "function" ? b.id() : b.Id;
      return a_id - b_id;
    });

    for (const r of sorted) {
      if (r.ValueType !== 2 || this.Tfm === 0) {
        o.push(this.gQi(r.ValueType, r.Type));
      }
    }
    await Promise.all(o);
    i.SetUIActive(false);
    e.SetUIActive(false);
    s.SetUIActive(false);
    h.SetUIActive(false);
  };

  function original_cam_roll(t) {
    this.TmpRotator.DeepCopy(this.CapsuleCollision.K2_GetComponentRotation());
    this.TmpRotator.Roll = this.InitialCapsuleRoll + t;

    this.CapsuleCollision.K2_SetRelativeRotation(
      this.TmpRotator.ToUeRotator(),
      true,
      undefined,
      false,
    );
  }

  const orig_CreateAspectView = MovieModeController.CreateAspectView;

  MovieModeController.CreateAspectView = async function (e) {
    this._pendingAspectRatio = e.AspectRatio ?? null;
    await orig_CreateAspectView.call(this, e);
  };

  const orig_AspectView_OnStart = MovieModeAspectView.prototype.OnStart;
  MovieModeAspectView.prototype.OnStart = function () {
    orig_AspectView_OnStart.call(this);
    const override =
      ControllerHolder_1.ControllerHolder.MovieModeController
        ._pendingAspectRatio;
    if (override !== null && override !== undefined) {
      this.Lld = override;
      ControllerHolder_1.ControllerHolder.MovieModeController._pendingAspectRatio =
        null;
    }
  };

  const enemy_cache = [];
  const disabled_map = new Map();

  const toggle_enemies = (show) => {
    if (enemy_cache.length === 0) {
      const range = CommonParamById_1.configCommonParamById.GetIntConfig(
        "FightPhotoHideMonsterDistance",
      );
      ModelManager_1.ModelManager.CreatureModel.GetEntitiesInRange(
        range,
        192,
        enemy_cache,
      );
    }

    for (const o of enemy_cache) {
      if (!o.Valid || !o.Entity?.Valid || o.Entity.Active === show) continue;

      if (show) {
        const handle = disabled_map.get(o);
        if (handle) {
          o.Entity.Enable(handle, "toggle_enemies");
          disabled_map.delete(o);
        }
      } else {
        const handle = o.Entity.Disable("toggle_enemies: state=false");
        disabled_map.set(o, handle);
      }
    }
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
            break;
          }
          r = EntitySystem_1.EntitySystem.Get(a);
          if (!r?.Valid) {
            break;
          }
          if (this.GetRoleMainAnimInstanceType() !== 0) {
            break;
          }
          r.GetComponent(192).MainAnimInstance.设置头部转向状态(1);
          break;
        }

        case 6: {
          a =
            ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();
          if (!a) {
            break;
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
            break;
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
        case MAX_ID:
          toggle_enemies(e == true || e === 1 ? false : true);
          break;
        case MAX_ID + 1:
          const entity =
            ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity?.Entity;
          const comp = entity?.GetComponent(23);
          if (!comp) break;
          const list_of_actors = comp.Sau;

          for (const [key, value] of list_of_actors) {
            var actor = EffectSystem_1.EffectSystem.GetEffectActor(
              value.EffectViewHandle,
            );
            actor?.SetActorHiddenInGame(e == false || e === 0);
          }
          break;
        case MAX_ID + 2:
          TimeOfDayController_1.TimeOfDayController.AdjustTime(
            e,
            Protocol_1.Aki.Protocol.C4s.Proto_PlayerOperate,
          );
          break;
        case MAX_ID + 3:
          if (e == true || e === 1) {
            dilate_time(0);
          } else {
            dilate_time(i.GetPhotographOption(MAX_ID + 4));
          }
          break;
        case MAX_ID + 4:
          dilate_time(e);
          break;
        case MAX_ID + 5:
        case MAX_ID + 6:
        case MAX_ID + 7: {
          const structure =
            ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();
          const cam = structure?.$Uo;
          if (!cam) break;
          if (t === 14) cam.CameraLeftAndRightSpeed = e;
          else if (t === 15) cam.CameraUpAndDownSpeed = e;
          else cam.CameraForwardAndBackwardSpeed = e;
          break;
        }
        case MAX_ID + 9:
          {
            if (e == false || e === 0) {
              ControllerHolder_1.ControllerHolder.MovieModeController.ExitMovieMode(
                {
                  BlendTime: 0,
                },
              );
            } else {
              let e = i.GetPhotographOption(MAX_ID + 10) ?? 1.777;
              if (e === 0.0 || e < 0.1) {
                ControllerHolder_1.ControllerHolder.MovieModeController.ExitMovieMode(
                  {
                    BlendTime: 0,
                  },
                );
                break;
              }
              if (e === 1.8 || (e > 1.79 && e < 1.81)) {
                ControllerHolder_1.ControllerHolder.MovieModeController.ExitMovieMode(
                  {
                    BlendTime: 0,
                  },
                );
              } else {
                ControllerHolder_1.ControllerHolder.MovieModeController.ExitMovieMode(
                  {
                    BlendTime: 0,
                  },
                  (success) => {
                    MovieModeController.EnterMovieMode({
                      BlendTime: 0,
                      AspectRatio: e,
                    });
                  },
                );
              }
            }
          }
          break;
        case MAX_ID + 10: {
          const enabled = i.GetPhotographOption(MAX_ID + 9) ?? false;
          if (!enabled) {
            ControllerHolder_1.ControllerHolder.MovieModeController.ExitMovieMode(
              {
                BlendTime: 0,
              },
            );
            break;
          }
          if (e === 0.0 || e < 0.1) {
            ControllerHolder_1.ControllerHolder.MovieModeController.ExitMovieMode(
              {
                BlendTime: 0,
              },
            );
            break;
          }
          if (e === 1.8 || (e > 1.79 && e < 1.81)) {
            ControllerHolder_1.ControllerHolder.MovieModeController.ExitMovieMode(
              {
                BlendTime: 0,
              },
            );
          } else {
            ControllerHolder_1.ControllerHolder.MovieModeController.ExitMovieMode(
              {
                BlendTime: 0,
              },
              (success) => {
                MovieModeController.EnterMovieMode({
                  BlendTime: 0,
                  AspectRatio: e,
                });
              },
            );
          }
          break;
        }
        case MAX_ID + 11:
          toggle_weapon_hidden(e == true || e === 1);
          break;
        case MAX_ID + 12:
          GameSettingsUtils_1.GameSettingsUtils.ApplyBloomEnable(
            e == true || e === 1 ? 1 : 0,
          );
      }
    };

  ModelManager_1.ModelManager.PhotographModel.SetPhotographOption = function (
    t,
    e,
  ) {
    this.kWi.set(t, e);
    const movement_style =
      ModelManager_1.ModelManager.PhotographModel.GetPhotographOption(
        MAX_ID + 8,
      );
    if (last_recorded_style !== movement_style) {
      const structure =
        ModelManager_1.ModelManager.PhotographModel.GetPhotographerStructure();
      const cam = structure?.$Uo;
      if (!cam) return;
      if (movement_style === 5) {
        cam.SetCameraArmRoll = function (t) {};
      } else {
        cam.SetCameraArmRoll = original_cam_roll;
        cam.SetCameraArmRoll(
          ModelManager_1.ModelManager.PhotographModel.GetPhotographOption(7),
        );
      }
      last_recorded_style = movement_style;
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

  PhotographSetupView.prototype.lQi = function (t) {
    this.Ifm = t;
    this._Qi(t === 1);
    this.uQi(t === 0);
    this.cQi(t === 2);
    // this.w1_(t === 3);
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
    ControllerHolder_1.ControllerHolder.QtaController.StopCurrentQta();
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

  PhotographSetupView.prototype.uQi = function (t) {
    for (const i of this.qKi) {
      i.SetActive(t);
    }
    this.Xva?.PlayInEditor();
  };

  PhotographSetupView.prototype.w1_ = function (t) {
    this.E1_.SetActive(t);
    if (t) {
      this.Xva?.PlayInEditor();
    } else {
      this.b1_(false);
    }
  };

  // FightPhotographView.prototype.OnAfterHide = function () {
  //   InputDistributeController_1.InputDistributeController.UnBindTouches(
  //     [
  //       InputMappingsDefine_1.touchIdMappings.Touch1,
  //       InputMappingsDefine_1.touchIdMappings.Touch2,
  //     ],
  //     this.Eqt,
  //   );

  //   RedDotController_1.RedDotController.UnBindGivenUi(
  //     "FunctionPhotograph",
  //     this.GetItem(19),
  //   );

  //   this.gJC();

  //   if (
  //     !PhotographController_1.PhotographController.CheckIfInFightPhotographCamera()
  //   ) {
  //     UiTimeDilation_1.UiTimeDilation.DeleteWaitSetTimeDilationTag(
  //       this.Info.Name,
  //     );
  //   }
  // };
}, 0);
