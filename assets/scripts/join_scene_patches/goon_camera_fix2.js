setTimeout(() => {
  const {
    FilterSettingView,
  } = require("../Game/Module/Menu/SubViews/FilterSetting/FilterSettingView.js");
  const {
    FightPhotographView,
  } = require("../Game/Module/Photograph/View/FightPhotographView.js");
  const {
    PhotographModel,
  } = require("../Game/Module/Photograph/PhotographModel.js");
  const {
    PhotographController,
  } = require("../Game/Module/Photograph/PhotographController.js");
  const PopupCaptionItem_1 = require("../Game/Ui/Common/PopupCaptionItem.js");
  const MenuDefine_1 = require("../Game/Module/Menu/MenuDefine.js");
  const CircleAttachView_1 = require("../Game/Module/AutoAttach/CircleAttachView.js");
  const GenericLayout_1 = require("../Game/Module/Util/Layout/GenericLayout.js");
  const FilterSeniorSettingAll_1 = require("../Core/Define/ConfigQuery/FilterSeniorSettingAll.js");
  const PhotographEntityPanel_1 = require("../Game/Module/Photograph/View/PhotographEntityPanel.js");
  const ControllerHolder_1 = require("../Game/Manager/ControllerHolder.js");
  const FightPhotoOptionPanel_1 = require("../Game/Module/Photograph/View/Item/FightPhotoOptionPanel.js");
  const puerts_1 = require("puerts");
  const CommonParamById_1 = require("../Core/Define/ConfigCommon/CommonParamById.js");
  const CommonDefine_1 = require("../Core/Define/CommonDefine.js");
  const UiLayer_1 = require("../Game/Ui/UiLayer.js");
  const UiLayerType_1 = require("../Game/Ui/Define/UiLayerType.js");
  const ResourceSystem_1 = require("../Core/Resource/ResourceSystem.js");
  const GlobalData_1 = require("../Game/GlobalData.js");
  const Vector_1 = require("../Core/Utils/Math/Vector.js");
  const Rotator_1 = require("../Core/Utils/Math/Rotator.js");
  const CustomPromise_1 = require("../Core/Common/CustomPromise.js");
  const ModelManager_1 = require("../Game/Manager/ModelManager.js");
  const UiTimeDilation_1 = require("../Game/Ui/Base/UiTimeDilation.js");
  const PhotographController_1 = require("../Game/Module/Photograph/PhotographController.js");
  const AudioSystem_1 = require("../Core/Audio/AudioSystem.js");
  const PhotographView_1 = require("../Game/Module/Photograph/View/PhotographView.js");
  const PhotographDefine_1 = require("../Game/Module/Photograph/PhotographDefine.js");
  const EntitySystem_1 = require("../Core/Entity/EntitySystem.js");
  const Log_1 = require("../Core/Common/Log.js");
  const UiManager_1 = require("../Game/Ui/UiManager.js");
  const UE = require("ue");

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

  const _superOnAfterShow =
    PhotographView_1.PhotographView.prototype.OnAfterShow;

  FightPhotographView.prototype.OnAfterShow = function () {
    _superOnAfterShow.call(this);
    // ModelManager_1.ModelManager.RenderModuleModel?.EnableForceTickCharRenderShell(
    //   "FightPhotographView OnAfterShow",
    // );
    AudioSystem_1.AudioSystem.SetState("game_sys_fightphoto", "pause");
    // UiTimeDilation_1.UiTimeDilation.Rur(true);
    this.NDc();
  };

  FightPhotographView.prototype.OnBeforeStartAsync = async function () {
    var t = [],
      e =
        ((this.IQi = new PhotographEntityPanel_1.PhotographEntityPanel()),
        t.push(this.IQi.CreateByActorAsync(this.GetItem(15).GetOwner())),
        // this.GetButton(14).RootUIComp.SetUIActive(false),
        ((this.SEd = new FightPhotoOptionPanel_1.FightPhotoOptionPanel()),
        // (e = this.GetItem(16)),
        t.push(
          this.SEd.CreateThenShowByResourceIdAsync("UiItem_BattlePhoto", e),
        )),
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
    this.SEd.GetItem(4).GetParentAsUIItem().SetUIActive(false);
  };

  // FightPhotographView.prototype.OnRegisterComponent = function () {
  //   this.ComponentRegisterInfos = [
  //     [0, UE.UIButtonComponent],
  //     [1, UE.UIButtonComponent],
  //     [2, UE.UIButtonComponent],
  //     [3, UE.UIButtonComponent],
  //     [4, UE.UIButtonComponent],
  //     [5, UE.UIButtonComponent],
  //     [6, UE.UISprite],
  //     [7, UE.UIButtonComponent],
  //     [8, UE.UIButtonComponent],
  //     [9, UE.UIButtonComponent],
  //     [10, UE.UISliderComponent],
  //     [11, UE.UIItem],
  //     [12, UE.UIItem],
  //     [13, UE.UIDraggableComponent],
  //     [14, UE.UIButtonComponent],
  //     [15, UE.UIItem],
  //     [16, UE.UIItem],
  //     [17, UE.UIItem],
  //     [18, UE.UIButtonComponent],
  //     [19, UE.UIItem],
  //     [20, UE.UIItem],
  //   ];
  //   this.BtnBindInfo = [
  //     [4, this.HQi],
  //     [5, this.jQi],
  //     [7, this.Ixi],
  //     [8, this.KQi],
  //     [9, this.OnBackButtonClicked],
  //     [14, this.WQi],
  //     [18, this.CSl],
  //   ];
  // };

  const original_u5 =
    ControllerHolder_1.ControllerHolder.PhotographController.U5_.bind(
      PhotographController,
    );
  ControllerHolder_1.ControllerHolder.PhotographController.U5_ = function () {
    ControllerHolder_1.ControllerHolder.PhotographController.SetPhotographOption(
      6,
      0,
    );
    return original_u5();
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
        case 0:
          var r = ModelManager_1.ModelManager.SceneTeamModel.GetCurrentEntity;
          1 === e ? i.SetEntityEnable(r, !0) : i.SetEntityEnable(r, !1);
          break;
        case 6:
        case 6:
          const view = UiManager_1.UiManager.GetViewByName(
            "FightPhotographView",
          );
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
        case 2:
          var a =
            ModelManager_1.ModelManager.SceneTeamModel?.GetCurrentEntity?.Id;
          if (!a) break;
          r = EntitySystem_1.EntitySystem.Get(a);
          if (!r?.Valid) break;
          if (0 !== this.GetRoleMainAnimInstanceType()) break;
          var anim = r.GetComponent(184)?.MainAnimInstance;
          if (!anim) break;
          anim.设置头部转向状态(1);
      }
    };
  // ModelManager_1.ModelManager.PhotographModel.SetPhotographTimeDilation =
  //   function (t) {};

  // PhotographModel.prototype.SetPhotographTimeDilation = function (t) {};
}, 0);
