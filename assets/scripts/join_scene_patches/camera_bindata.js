setTimeout(() => {
  const { Builder } = require("../RunTimeLibs/FlatBuffers/builder");
  const { ByteBuffer } = require("../RunTimeLibs/FlatBuffers/byte-buffer");
  const {
    FilterSeniorSetting,
  } = require("../Core/Define/Config/FilterSeniorSetting");
  const {
    configFilterSeniorSettingAll,
  } = require("../Core/Define/ConfigQuery/FilterSeniorSettingAll");
  const {
    configFilterSeniorSettingById,
  } = require("../Core/Define/ConfigQuery/FilterSeniorSettingById");
  const { PhotoSetup } = require("../Core/Define/Config/PhotoSetup");
  const {
    configPhotoSetupAll,
  } = require("../Core/Define/ConfigQuery/PhotoSetupAll.js");
  const {
    configPhotoSetupByValueType,
  } = require("../Core/Define/ConfigQuery/PhotoSetupByValueType.js");
  const { ConfigManager } = require("../Game/Manager/ConfigManager.js");

  const PATCHED_IDS = new Set([2, 3, 4, 5, 6, 7, 8, 9, 10]);
  const patched_cache = new Map();

  const build_patched_filter_entry = (original) => {
    const b = new Builder(256);
    const name_off = b.createString(original.name());
    const unit_off = b.createString(original.unit());
    b.startObject(10);
    b.addFieldInt32(0, original.id(), 0);
    b.addFieldOffset(1, name_off, 0);
    b.addFieldInt32(2, original.paramindex(), 0);
    b.addFieldInt32(3, original.sortid(), 0);
    b.addFieldFloat32(4, -10, -1);
    b.addFieldFloat32(5, 10, 1);
    b.addFieldOffset(6, unit_off, 0);
    b.addFieldInt8(7, original.isneedspecialbg() ? 1 : 0, 0);
    b.addFieldInt32(8, 2, 0);
    b.addFieldInt32(9, 1, 0);
    const root = b.endObject();
    b.finish(root);
    return FilterSeniorSetting.getRootAsFilterSeniorSetting(
      new ByteBuffer(b.asUint8Array()),
    );
  };

  const get_or_build_filter_patch = (original) => {
    const id = original.id();
    if (!patched_cache.has(id))
      patched_cache.set(id, build_patched_filter_entry(original));
    return patched_cache.get(id);
  };

  configFilterSeniorSettingById.GetConfig = (
    (orig) =>
    (id, ...args) => {
      const result = orig(id, ...args);
      if (!result || !PATCHED_IDS.has(id)) return result;
      return get_or_build_filter_patch(result);
    }
  )(
    configFilterSeniorSettingById.GetConfig.bind(configFilterSeniorSettingById),
  );

  configFilterSeniorSettingAll.GetConfigList = (
    (orig) =>
    (...args) => {
      const list = orig(...args);
      return list?.map((e) =>
        PATCHED_IDS.has(e.id()) ? get_or_build_filter_patch(e) : e,
      );
    }
  )(
    configFilterSeniorSettingAll.GetConfigList.bind(
      configFilterSeniorSettingAll,
    ),
  );

  const MAX_ID = 9;

  const make_photo_setup = (buf) =>
    PhotoSetup.getRootAsPhotoSetup(new ByteBuffer(buf));

  const build_entry = ({
    id,
    value_type,
    name,
    type = 0,
    options = [],
    default_option_index = 0,
    default_dropdown_index = 0,
    sub_value_types = null,
    value_range = null,
    is_reverse_set = false,
    change_value = 0.1,
    is_show_red_dot = false,
    is_local_storage = false,
    digits = 0,
    unit = "",
  }) => {
    const b = new Builder(512);
    const name_off = b.createString(name);
    const unit_off = b.createString(unit);
    const opt_offs = options.map((o) => b.createString(o));
    let suboptions_vec = null;
    if (sub_value_types !== null) {
      const entries =
        sub_value_types instanceof Map
          ? [...sub_value_types.entries()]
          : Object.entries(sub_value_types).map(([k, v]) => [Number(k), v]);
      const dic_entry_offs = entries.map(([key, arr]) => {
        const values = Array.isArray(arr) ? arr : [arr];
        b.startVector(4, values.length, 4);
        for (let i = values.length - 1; i >= 0; i--) b.addInt32(values[i]);
        const int_array_vec = b.endVector();
        b.startObject(1);
        b.addFieldOffset(0, int_array_vec, 0);
        const int_array_off = b.endObject();
        b.startObject(2);
        b.addFieldInt32(0, key, 0);
        b.addFieldOffset(1, int_array_off, 0);
        return b.endObject();
      });
      b.startVector(4, dic_entry_offs.length, 4);
      for (let i = dic_entry_offs.length - 1; i >= 0; i--)
        b.addOffset(dic_entry_offs[i]);
      suboptions_vec = b.endVector();
    }
    let vr_vec = null;
    if (value_range !== null) {
      b.startVector(4, value_range.length, 4);
      for (let i = value_range.length - 1; i >= 0; i--)
        b.addFloat32(value_range[i]);
      vr_vec = b.endVector();
    }
    b.startVector(4, opt_offs.length, 4);
    for (let i = opt_offs.length - 1; i >= 0; i--) b.addOffset(opt_offs[i]);
    const options_vec = b.endVector();
    b.startObject(15);
    b.addFieldInt32(0, id, 0);
    b.addFieldInt32(1, value_type, 0);
    b.addFieldOffset(2, name_off, 0);
    b.addFieldInt32(3, type, 0);
    b.addFieldOffset(4, options_vec, 0);
    b.addFieldInt32(5, default_option_index, 1);
    b.addFieldInt32(6, default_dropdown_index, 0);
    if (suboptions_vec !== null) b.addFieldOffset(7, suboptions_vec, 0);
    if (vr_vec !== null) b.addFieldOffset(8, vr_vec, 0);
    b.addFieldInt8(9, is_reverse_set ? 1 : 0, 0);
    b.addFieldFloat32(10, change_value, 0.1);
    b.addFieldInt8(11, is_show_red_dot ? 1 : 0, 0);
    b.addFieldInt8(12, is_local_storage ? 1 : 0, 0);
    b.addFieldInt32(13, digits, 0);
    b.addFieldOffset(14, unit_off, 0);
    const root = b.endObject();
    b.finish(root);
    return make_photo_setup(b.asUint8Array());
  };

  const TOGGLE_OPTIONS = ["PhotoSetup_2_Options_0", "PhotoSetup_2_Options_1"];
  const SPEED_MIN = 0.1;
  const SPEED_MAX = 10;
  const TD_VALUE_TYPE = MAX_ID + 4;
  const TD_ID = MAX_ID + 5;

  const extra_entries = [
    build_entry({
      id: MAX_ID + 1,
      value_type: MAX_ID,
      name: "PrefabTextItem_685566124_Text",
      type: 0,
      options: TOGGLE_OPTIONS,
      default_option_index: 0,
      change_value: 0.1,
      is_local_storage: true,
    }),
    build_entry({
      id: MAX_ID + 2,
      value_type: MAX_ID + 1,
      name: "PrefabTextItem_4019340794_Text",
      type: 0,
      options: TOGGLE_OPTIONS,
      default_option_index: 1,
      change_value: 0.1,
    }),
    build_entry({
      id: MAX_ID + 3,
      value_type: MAX_ID + 2,
      name: "CUSTOM_Time of Day",
      type: 1,
      value_range: [0, 86400, 0],
      change_value: 1,
    }),
    build_entry({
      id: MAX_ID + 4,
      value_type: MAX_ID + 3,
      name: "CUSTOM_Freeze Time",
      type: 0,
      options: ["FreezeTime_Options_0", "FreezeTime_Options_1"],
      sub_value_types: { 1: [TD_VALUE_TYPE] },
      value_range: [1, 1, 0],
      default_option_index: 1,
      change_value: 1,
      is_local_storage: false,
    }),
    build_entry({
      id: TD_ID,
      value_type: TD_VALUE_TYPE,
      name: "CUSTOM_Time Dilation",
      type: 3,
      value_range: [0, 5, 0],
      change_value: 0.1,
      digits: 2,
    }),
    build_entry({
      id: MAX_ID + 6,
      value_type: MAX_ID + 5,
      name: "CUSTOM_Horizontal Speed",
      type: 1,
      value_range: [SPEED_MIN, SPEED_MAX, 1],
      change_value: 0.1,
      is_local_storage: false,
    }),
    build_entry({
      id: MAX_ID + 7,
      value_type: MAX_ID + 6,
      name: "CUSTOM_Vertical Speed",
      type: 1,
      value_range: [SPEED_MIN, SPEED_MAX, 1],
      change_value: 0.1,
      is_local_storage: false,
    }),
    build_entry({
      id: MAX_ID + 8,
      value_type: MAX_ID + 7,
      name: "CUSTOM_Longitudinal Speed",
      type: 1,
      value_range: [SPEED_MIN, SPEED_MAX, 1],
      change_value: 0.1,
      is_local_storage: false,
    }),
    build_entry({
      id: MAX_ID + 9,
      value_type: MAX_ID + 8,
      name: "CUSTOM_Movement Style",
      type: 2,
      value_range: [0, 50],
      change_value: 1,
      is_local_storage: true,
      default_dropdown_index: 4,
    }),
    build_entry({
      id: MAX_ID + 10,
      value_type: MAX_ID + 9,
      name: "CUSTOM_Windowbox",
      type: 0,
      options: ["WindowBox_Options_0", "WindowBox_Options_1"],
      sub_value_types: { 0: [MAX_ID + 10] },
      value_range: [1, 1, 0],
      default_option_index: 0,
      change_value: 1,
      is_local_storage: true,
    }),
    build_entry({
      id: MAX_ID + 11,
      value_type: MAX_ID + 10,
      name: "CUSTOM_Box Ratio",
      type: 3,
      value_range: [0.2, 4, 1.8],
      change_value: 0.01,
      is_local_storage: true,
      digits: 2,
    }),
    build_entry({
      id: 8,
      value_type: 7,
      name: "PhotoSetup_8_Name",
      type: 3,
      value_range: [-180, 180, 0],
      change_value: 1,
      digits: 2,
      unit: "°",
    }),
    build_entry({
      id: 4,
      value_type: 3,
      name: "PhotoSetup_4_Name",
      type: 0,
      options: ["PhotoSetup_4_Options_0", "PhotoSetup_4_Options_1"],
      default_option_index: 0,
      sub_value_types: { 0: [4, 5] },
      change_value: 0.1,
      is_local_storage: false,
    }),
    build_entry({
      id: 5,
      value_type: 4,
      name: "PhotoSetup_5_Name",
      type: 1,
      value_range: [0, 1000, 400],
      change_value: 5,
      is_local_storage: false,
    }),
    build_entry({
      id: 6,
      value_type: 5,
      name: "PhotoSetup_6_Name",
      type: 1,
      value_range: [0.1, 5, 0.1],
      is_reverse_set: true,
      change_value: 0.1,
      is_local_storage: false,
    }),
    build_entry({
      id: MAX_ID + 12,
      value_type: MAX_ID + 11,
      name: "CUSTOM_Hide Weapon",
      type: 0,
      options: TOGGLE_OPTIONS,
      default_option_index: 0,
      change_value: 0.1,
      is_local_storage: false,
    }),
    build_entry({
      id: MAX_ID + 13,
      value_type: MAX_ID + 12,
      name: "CUSTOM_Bloom",
      type: 0,
      options: TOGGLE_OPTIONS,
      default_option_index: 0,
      change_value: 0.1,
      is_local_storage: false,
    }),
  ];

  const get_vt = (e) =>
    typeof e.valueType === "function" ? e.valueType() : e.ValueType;

  configPhotoSetupByValueType.GetConfig = (
    (orig) =>
    (value_type, ...args) => {
      const result = orig(value_type, ...args);
      if (result !== undefined) return result;
      return extra_entries.find((e) => get_vt(e) === value_type);
    }
  )(configPhotoSetupByValueType.GetConfig.bind(configPhotoSetupByValueType));

  configPhotoSetupAll.GetConfigList = (
    (orig) =>
    (...args) => {
      const list = orig(...args);
      if (!list) return list;
      const override_vts = new Set(extra_entries.map(get_vt));
      return [
        ...list.filter((x) => !override_vts.has(get_vt(x))),
        ...extra_entries,
      ];
    }
  )(configPhotoSetupAll.GetConfigList.bind(configPhotoSetupAll));

  const photograph_config = ConfigManager?.PhotographConfig;

  photograph_config.GetPhotoSetupConfig = (
    (orig) =>
    (value_type, ...args) => {
      const override = extra_entries.find((e) => get_vt(e) === value_type);
      if (override !== undefined) return override;
      return orig(value_type, ...args);
    }
  )(photograph_config.GetPhotoSetupConfig.bind(photograph_config));

  photograph_config.GetAllPhotoSetupConfig = (
    (orig) =>
    (...args) => {
      const list = orig(...args);
      if (!list) return list;
      const override_vts = new Set(extra_entries.map(get_vt));
      return [
        ...list.filter((x) => !override_vts.has(get_vt(x))),
        ...extra_entries,
      ];
    }
  )(photograph_config.GetAllPhotoSetupConfig.bind(photograph_config));

  const { PhotoDropDown } = require("../Core/Define/Config/PhotoDropDown");

  const build_dropdown_entry = ({ id, setup_type, text_id, params = [] }) => {
    const b = new Builder(256);
    const text_off = b.createString(text_id);
    const param_offs = params.map((p) => b.createString(p));

    b.startVector(4, param_offs.length, 4);
    for (let i = param_offs.length - 1; i >= 0; i--) b.addOffset(param_offs[i]);
    const params_vec = b.endVector();

    b.startObject(3);
    b.addFieldInt32(0, id, 0);
    b.addFieldInt32(1, setup_type, 0);
    b.addFieldOffset(2, text_off, 0);
    b.addFieldOffset(3, params_vec, 0);
    const root = b.endObject();
    b.finish(root);
    return PhotoDropDown.getRootAsPhotoDropDown(
      new ByteBuffer(b.asUint8Array()),
    );
  };

  const MOVEMENT_STYLE_OPTIONS = [
    build_dropdown_entry({
      id: 4,
      setup_type: MAX_ID + 8,
      text_id: "CUSTOM_Kuro Style",
      params: ["4"],
    }),
    build_dropdown_entry({
      id: 5,
      setup_type: MAX_ID + 8,
      text_id: "CUSTOM_Rabby Style",
      params: ["5"],
    }),
  ];

  const RESOLUTION_OPTIONS = [
    build_dropdown_entry({
      id: 1,
      setup_type: MAX_ID - 1,
      text_id: "Default_Graphics_Quality_1",
      params: ["1"],
    }),
    build_dropdown_entry({
      id: 2,
      setup_type: MAX_ID - 1,
      text_id: "High_Definition_Quality_2",
      params: ["2"],
    }),
    build_dropdown_entry({
      id: 3,
      setup_type: MAX_ID - 1,
      text_id: "CUSTOM_Very High (3x)",
      params: ["3"],
    }),
  ];

  const DROPDOWN_OVERRIDES = new Map([
    [MAX_ID - 1, RESOLUTION_OPTIONS],
    [MAX_ID + 8, MOVEMENT_STYLE_OPTIONS],
  ]);

  photograph_config.GetPhotoDropDownDataList = (
    (orig) =>
    (value_type, ...args) => {
      if (DROPDOWN_OVERRIDES.has(value_type))
        return DROPDOWN_OVERRIDES.get(value_type);
      return orig(value_type, ...args);
    }
  )(photograph_config.GetPhotoDropDownDataList.bind(photograph_config));

  const {
    PhotographDropDownSetup,
  } = require("Game/Module/Photograph/View/PhotographDropDownSetup.js");
  const { ModelManager } = require("Game/Manager/ModelManager.js");

  PhotographDropDownSetup.prototype._bi = (function (orig) {
    return function () {
      const e = ConfigManager?.PhotographConfig?.GetPhotoDropDownDataList(
        this.SetupValueType,
      );
      if (!e || e.length === 0) return orig.apply(this, arguments);
      const t = ModelManager?.PhotographModel?.GetPhotographOption(
        this.SetupValueType,
      );
      const idx = e.findIndex((x) => x.Id === t);
      const safeIdx = idx < 0 ? 0 : Math.min(idx, e.length - 1);
      this.hbi.InitScroll(e, this.g8e, safeIdx);
    };
  })(PhotographDropDownSetup.prototype._bi);

  const orig_ELt_descriptor = Object.getOwnPropertyDescriptor(
    PhotographDropDownSetup.prototype,
    "ELt",
  );
  const orig_OnBeforeStartAsync =
    PhotographDropDownSetup.prototype.OnBeforeStartAsync;
  PhotographDropDownSetup.prototype.OnBeforeStartAsync = async function () {
    await orig_OnBeforeStartAsync.call(this);
    const orig_ELt = this.ELt;
    this.ELt = (e, t) => {
      orig_ELt(e, t);
      ModelManager?.PhotographModel?.SetPhotographOption(
        this.SetupValueType,
        t.Id,
      );
    };
    this.hbi.SetOnSelectCall(this.ELt);
  };
}, 0);
