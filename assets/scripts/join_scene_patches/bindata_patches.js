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
  const { ConfigCommon } = require("../Core/Config/ConfigCommon");
  const {
    PhotographController,
  } = require("../Game/Module/Photograph/PhotographController.js");

  const PATCHED_IDS = new Set([2, 3, 4, 5, 6, 7, 8, 9, 10]);

  const build_patched_entry = (original) => {
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
    return b.asUint8Array();
  };

  const patched_cache = new Map();

  const get_or_build_patch = (original) => {
    const id = original.id();
    if (patched_cache.has(id)) return patched_cache.get(id);
    const buf = build_patched_entry(original);
    const entry = FilterSeniorSetting.getRootAsFilterSeniorSetting(
      new ByteBuffer(buf),
    );
    patched_cache.set(id, entry);
    return entry;
  };

  const filter_original_get_config =
    configFilterSeniorSettingById.GetConfig.bind(configFilterSeniorSettingById);
  configFilterSeniorSettingById.GetConfig = (id, ...args) => {
    const result = filter_original_get_config(id, ...args);
    if (!result || !PATCHED_IDS.has(id)) return result;
    return get_or_build_patch(result);
  };

  const filter_original_get_config_list =
    configFilterSeniorSettingAll.GetConfigList.bind(
      configFilterSeniorSettingAll,
    );
  configFilterSeniorSettingAll.GetConfigList = (...args) => {
    const list = filter_original_get_config_list(...args);
    if (!list) return list;
    return list.map((entry) =>
      PATCHED_IDS.has(entry.id()) ? get_or_build_patch(entry) : entry,
    );
  };

  const OPTIONS = ["PhotoSetup_2_Options_0", "PhotoSetup_2_Options_1"];
  const VALUE_RANGE = [0, 100, 50];

  const build_custom_entry = () => {
    const b = new Builder(256);
    const name_off = b.createString("PrefabTextItem_685566124_Text");
    const option_offs = OPTIONS.map((o) => b.createString(o));
    b.startVector(4, option_offs.length, 4);
    for (let i = option_offs.length - 1; i >= 0; i--)
      b.addOffset(option_offs[i]);
    const options_vec = b.endVector();
    b.startVector(4, VALUE_RANGE.length, 4);
    for (let i = VALUE_RANGE.length - 1; i >= 0; i--)
      b.addFloat32(VALUE_RANGE[i]);
    const vr_vec = b.endVector();
    b.startObject(10);
    b.addFieldInt32(0, 7, 0);
    b.addFieldInt32(1, 6, 0);
    b.addFieldOffset(2, name_off, 0);
    b.addFieldInt32(3, 0, 0);
    b.addFieldOffset(4, options_vec, 0);
    b.addFieldInt32(5, 0, 1);
    b.addFieldOffset(7, vr_vec, 0);
    b.addFieldInt8(8, 0, 0);
    b.addFieldFloat32(9, 0.1, 0.1);
    const root = b.endObject();
    b.finish(root);
    return b.asUint8Array();
  };

  const TOD_VALUE_TYPE = 8;
  const TOD_ID = 9;
  const TOD_MIN = 0;
  const TOD_MAX = 86400;

  const build_tod_entry = () => {
    const b = new Builder(256);
    const name_off = b.createString("CUSTOM_Time of Day");
    const opt_offs = [
      b.createString("TimeOfDay_Options_0"),
      b.createString("TimeOfDay_Options_1"),
    ];
    b.startVector(4, opt_offs.length, 4);
    for (let i = opt_offs.length - 1; i >= 0; i--) b.addOffset(opt_offs[i]);
    const options_vec = b.endVector();
    const value_range = [TOD_MIN, TOD_MAX, 0];
    b.startVector(4, value_range.length, 4);
    for (let i = value_range.length - 1; i >= 0; i--)
      b.addFloat32(value_range[i]);
    const vr_vec = b.endVector();
    b.startObject(10);
    b.addFieldInt32(0, TOD_ID, 0);
    b.addFieldInt32(1, TOD_VALUE_TYPE, 0);
    b.addFieldOffset(2, name_off, 0);
    b.addFieldInt32(3, 1, 0);
    b.addFieldOffset(4, options_vec, 0);
    b.addFieldInt32(5, 0, 1);
    b.addFieldOffset(7, vr_vec, 0);
    b.addFieldInt8(8, 0, 0);
    b.addFieldFloat32(9, 1, 0.1);
    const root = b.endObject();
    b.finish(root);
    return b.asUint8Array();
  };

  const build_effects_entry = () => {
    const b = new Builder(256);
    const name_off = b.createString("PrefabTextItem_4019340794_Text");
    const option_offs = OPTIONS.map((o) => b.createString(o));
    b.startVector(4, option_offs.length, 4);
    for (let i = option_offs.length - 1; i >= 0; i--)
      b.addOffset(option_offs[i]);
    const options_vec = b.endVector();
    b.startVector(4, VALUE_RANGE.length, 4);
    for (let i = VALUE_RANGE.length - 1; i >= 0; i--)
      b.addFloat32(VALUE_RANGE[i]);
    const vr_vec = b.endVector();
    b.startObject(10);
    b.addFieldInt32(0, 8, 0);
    b.addFieldInt32(1, 7, 0);
    b.addFieldOffset(2, name_off, 0);
    b.addFieldInt32(3, 0, 0);
    b.addFieldOffset(4, options_vec, 0);
    b.addFieldInt32(5, 1, 0);
    b.addFieldOffset(7, vr_vec, 0);
    b.addFieldInt8(8, 0, 0);
    b.addFieldFloat32(9, 0.1, 0.1);
    const root = b.endObject();
    b.finish(root);
    return b.asUint8Array();
  };

  const FREEZE_VALUE_TYPE = 9;
  const FREEZE_ID = 10;

  const build_freeze_toggle_entry = () => {
    const b = new Builder(512);

    const name_off = b.createString("CUSTOM_Freeze Time");
    const opt_off_0 = b.createString("FreezeTime_Options_0");
    const opt_off_1 = b.createString("FreezeTime_Options_1");

    b.startVector(4, 1, 4);
    b.addInt32(TD_VALUE_TYPE);
    const int_array_vec = b.endVector();

    b.startObject(1);
    b.addFieldOffset(0, int_array_vec, 0);
    const int_array_off = b.endObject();

    b.startObject(2);
    b.addFieldInt32(0, 1, 0);
    b.addFieldOffset(1, int_array_off, 0);
    const dic_entry_off = b.endObject();

    b.startVector(4, 1, 4);
    b.addOffset(dic_entry_off);
    const suboptions_vec = b.endVector();

    b.startVector(4, 2, 4);
    b.addOffset(opt_off_1);
    b.addOffset(opt_off_0);
    const options_vec = b.endVector();

    b.startVector(4, 3, 4);
    b.addFloat32(1);
    b.addFloat32(1);
    b.addFloat32(0);
    const vr_vec = b.endVector();

    b.startObject(10);
    b.addFieldInt32(0, FREEZE_ID, 0);
    b.addFieldInt32(1, FREEZE_VALUE_TYPE, 0);
    b.addFieldOffset(2, name_off, 0);
    b.addFieldInt32(3, 0, 0);
    b.addFieldOffset(4, options_vec, 0);
    b.addFieldInt32(5, 0, 1);
    b.addFieldOffset(6, suboptions_vec, 0);
    b.addFieldOffset(7, vr_vec, 0);
    b.addFieldInt8(8, 0, 0);
    b.addFieldFloat32(9, 1, 0.1);
    const root = b.endObject();
    b.finish(root);
    return b.asUint8Array();
  };

  const TD_VALUE_TYPE = 10;
  const TD_ID = 11;
  const TD_MIN = 0;
  const TD_MAX = 2;

  const build_time_dilation_entry = () => {
    const b = new Builder(256);
    const name_off = b.createString("CUSTOM_Time Dilation");
    const opt_offs = [
      b.createString("TimeDilation_Options_0"),
      b.createString("TimeDilation_Options_1"),
    ];
    b.startVector(4, opt_offs.length, 4);
    for (let i = opt_offs.length - 1; i >= 0; i--) b.addOffset(opt_offs[i]);
    const options_vec = b.endVector();
    const value_range = [TD_MIN, TD_MAX, 0];
    b.startVector(4, value_range.length, 4);
    for (let i = value_range.length - 1; i >= 0; i--)
      b.addFloat32(value_range[i]);
    const vr_vec = b.endVector();
    b.startObject(10);
    b.addFieldInt32(0, TD_ID, 0);
    b.addFieldInt32(1, TD_VALUE_TYPE, 0);
    b.addFieldOffset(2, name_off, 0);
    b.addFieldInt32(3, 1, 0);
    b.addFieldOffset(4, options_vec, 0);
    b.addFieldInt32(5, 0, 1);
    b.addFieldOffset(7, vr_vec, 0);
    b.addFieldInt8(8, 0, 0);
    b.addFieldFloat32(9, 0.01, 0.1);
    const root = b.endObject();
    b.finish(root);
    return b.asUint8Array();
  };

  const HS_VALUE_TYPE = 11;
  const HS_ID = 12;
  const SPEED_MIN = 0.1;
  const SPEED_MAX = 10;

  const build_hs_entry = () => {
    const b = new Builder(256);
    const name_off = b.createString("CUSTOM_Horizontal Speed");
    const opt_offs = [
      b.createString("HorizontalSpeed_Options_0"),
      b.createString("HorizontalSpeed_Options_1"),
    ];
    b.startVector(4, opt_offs.length, 4);
    for (let i = opt_offs.length - 1; i >= 0; i--) b.addOffset(opt_offs[i]);
    const options_vec = b.endVector();
    const value_range = [SPEED_MIN, SPEED_MAX, 1];
    b.startVector(4, value_range.length, 4);
    for (let i = value_range.length - 1; i >= 0; i--)
      b.addFloat32(value_range[i]);
    const vr_vec = b.endVector();
    b.startObject(10);
    b.addFieldInt32(0, HS_ID, 0);
    b.addFieldInt32(1, HS_VALUE_TYPE, 0);
    b.addFieldOffset(2, name_off, 0);
    b.addFieldInt32(3, 1, 0);
    b.addFieldOffset(4, options_vec, 0);
    b.addFieldInt32(5, 0, 1);
    b.addFieldOffset(7, vr_vec, 0);
    b.addFieldInt8(8, 0, 0);
    b.addFieldFloat32(9, 0.1, 0.1);
    const root = b.endObject();
    b.finish(root);
    return b.asUint8Array();
  };

  const VS_VALUE_TYPE = 12;
  const VS_ID = 13;

  const build_vs_entry = () => {
    const b = new Builder(256);
    const name_off = b.createString("CUSTOM_Vertical Speed");
    const opt_offs = [
      b.createString("VerticalSpeed_Options_0"),
      b.createString("VerticalSpeed_Options_1"),
    ];
    b.startVector(4, opt_offs.length, 4);
    for (let i = opt_offs.length - 1; i >= 0; i--) b.addOffset(opt_offs[i]);
    const options_vec = b.endVector();
    const value_range = [SPEED_MIN, SPEED_MAX, 1];
    b.startVector(4, value_range.length, 4);
    for (let i = value_range.length - 1; i >= 0; i--)
      b.addFloat32(value_range[i]);
    const vr_vec = b.endVector();
    b.startObject(10);
    b.addFieldInt32(0, VS_ID, 0);
    b.addFieldInt32(1, VS_VALUE_TYPE, 0);
    b.addFieldOffset(2, name_off, 0);
    b.addFieldInt32(3, 1, 0);
    b.addFieldOffset(4, options_vec, 0);
    b.addFieldInt32(5, 0, 1);
    b.addFieldOffset(7, vr_vec, 0);
    b.addFieldInt8(8, 0, 0);
    b.addFieldFloat32(9, 0.1, 0.1);
    const root = b.endObject();
    b.finish(root);
    return b.asUint8Array();
  };

  const LS_VALUE_TYPE = 13;
  const LS_ID = 14;

  const build_ls_entry = () => {
    const b = new Builder(256);
    const name_off = b.createString("CUSTOM_Longitudinal Speed");
    const opt_offs = [
      b.createString("LongitudinalSpeed_Options_0"),
      b.createString("LongitudinalSpeed_Options_1"),
    ];
    b.startVector(4, opt_offs.length, 4);
    for (let i = opt_offs.length - 1; i >= 0; i--) b.addOffset(opt_offs[i]);
    const options_vec = b.endVector();
    const value_range = [SPEED_MIN, SPEED_MAX, 1];
    b.startVector(4, value_range.length, 4);
    for (let i = value_range.length - 1; i >= 0; i--)
      b.addFloat32(value_range[i]);
    const vr_vec = b.endVector();
    b.startObject(10);
    b.addFieldInt32(0, LS_ID, 0);
    b.addFieldInt32(1, LS_VALUE_TYPE, 0);
    b.addFieldOffset(2, name_off, 0);
    b.addFieldInt32(3, 1, 0);
    b.addFieldOffset(4, options_vec, 0);
    b.addFieldInt32(5, 0, 1);
    b.addFieldOffset(7, vr_vec, 0);
    b.addFieldInt8(8, 0, 0);
    b.addFieldFloat32(9, 0.1, 0.1);
    const root = b.endObject();
    b.finish(root);
    return b.asUint8Array();
  };

  const custom_entry = PhotoSetup.getRootAsPhotoSetup(
    new ByteBuffer(build_custom_entry()),
  );
  const tod_entry = PhotoSetup.getRootAsPhotoSetup(
    new ByteBuffer(build_tod_entry()),
  );
  const effects_entry = PhotoSetup.getRootAsPhotoSetup(
    new ByteBuffer(build_effects_entry()),
  );
  const freeze_toggle_entry = PhotoSetup.getRootAsPhotoSetup(
    new ByteBuffer(build_freeze_toggle_entry()),
  );
  const time_dilation_entry = PhotoSetup.getRootAsPhotoSetup(
    new ByteBuffer(build_time_dilation_entry()),
  );
  const horizontal_speed_entry = PhotoSetup.getRootAsPhotoSetup(
    new ByteBuffer(build_hs_entry()),
  );
  const vertical_speed_entry = PhotoSetup.getRootAsPhotoSetup(
    new ByteBuffer(build_vs_entry()),
  );
  const longitudinal_speed_entry = PhotoSetup.getRootAsPhotoSetup(
    new ByteBuffer(build_ls_entry()),
  );

  const extra_entries = [
    custom_entry,
    effects_entry,
    tod_entry,
    freeze_toggle_entry,
    time_dilation_entry,
    horizontal_speed_entry,
    vertical_speed_entry,
    longitudinal_speed_entry,
  ];

  const photo_original_get_config = configPhotoSetupByValueType.GetConfig.bind(
    configPhotoSetupByValueType,
  );
  configPhotoSetupByValueType.GetConfig = (value_type, ...args) => {
    const result = photo_original_get_config(value_type, ...args);
    if (result !== undefined) return result;
    return extra_entries.find((e) => e.ValueType === value_type);
  };

  const photo_original_get_config_list =
    configPhotoSetupAll.GetConfigList.bind(configPhotoSetupAll);
  configPhotoSetupAll.GetConfigList = (...args) => {
    const list = photo_original_get_config_list(...args);
    if (!list) return list;
    const to_add = extra_entries.filter(
      (e) => !list.some((x) => x.ValueType === e.ValueType),
    );
    return to_add.length ? [...list, ...to_add] : list;
  };

  const photograph_config = ConfigManager?.PhotographConfig;
  const original_get_setup =
    photograph_config.GetPhotoSetupConfig.bind(photograph_config);
  photograph_config.GetPhotoSetupConfig = (value_type, ...args) => {
    const result = original_get_setup(value_type, ...args);
    if (result !== undefined) return result;
    return extra_entries.find((e) => e.ValueType === value_type);
  };
}, 0);
