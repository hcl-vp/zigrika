const std = @import("std");
pub fn MapEntry(comptime K: type, comptime V: type) type {
    return struct {
        pub const map_entry: void = {};
        pub const key_field_number: u32 = 1;
        pub const value_field_number: u32 = 2;

        pub const default: @This() = .{
            .key = switch (@typeInfo(K)) {
                .int => 0,
                .bool => false,
                else => if (K == []const u8) "" else .default,
            },
            .value = switch (@typeInfo(V)) {
                .int => 0,
                .bool => false,
                else => if (V == []const u8) "" else .default,
            },
        };

        key: K,
        value: V,
    };
}
pub const DangoAbyssActivityData = struct {
    pub const default: @This() = .{};
    RoleList: std.ArrayList(AbyssDangoRoleData) = .empty,
    AbyssPluginItemInfo: std.ArrayList(AbyssPluginItemInfo) = .empty,
    AbyssRewardInfo: std.ArrayList(AbyssRewardInfo) = .empty,
    UnlockChallengeIdList: std.ArrayList(i32) = .empty,
    LikeCount: i32 = 0,
    AbyssChallengeData: std.ArrayList(AbyssChallengeData) = .empty,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const AbyssChallengeData = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    CanUnlock: bool = false,
    CanChallenge: bool = false,
    UnlockTime: i64 = 0,
    ConditionFinishState: bool = false,
    MaxProgress: i32 = 0,
    MinPassTime: i32 = 0,
    IsPassed: bool = false,
};
pub const AbyssDangoRoleData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Level: i32 = 0,
    EquipItems: std.ArrayList(i32) = .empty,
};
pub const AbyssPluginItemInfo = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Count: i32 = 0,
    IncrId: i32 = 0,
    FuncValue: i32 = 0,
};
pub const AbyssRewardInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    CanGetReward: bool = false,
    CurrentProgress: i32 = 0,
    TargetProgress: i32 = 0,
    CanUnlock: bool = false,
};
pub const DoubleDropFrom = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    UnDefineDouble = 0,
    DoubleActivity = 1,
    FromRegress = 2,
};
pub const AddCountItemInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Count: i32 = 0,
    IncrId: i32 = 0,
};
pub const ItemLockRequest = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    IncrId: i32 = 0,
};
pub const ItemLockResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RewardItemInfo = struct {
    pub const default: @This() = .{};
    ShowPlanId: i32 = 0,
    ItemId: i32 = 0,
    Count: i32 = 0,
    IncrId: i32 = 0,
};
pub const ItemRewardNotify = struct {
    pub const default: @This() = .{};
    DropId: i32 = 0,
    Reason: i32 = 0,
    Magnification: i32 = 0,
    DropFrom: ?DoubleDropFrom = null,
    RewardItems: std.ArrayList(MapEntry(i32, RewardItemInfoList)) = .empty,
};
pub const RewardItemInfoList = struct {
    pub const default: @This() = .{};
    ItemList: std.ArrayList(RewardItemInfo) = .empty,
};
pub const NormalItemRequest = struct {
    pub const default: @This() = .{};
};
pub const NormalItemResponse = struct {
    pub const default: @This() = .{};
    NormalItemList: std.ArrayList(NormalItem) = .empty,
};
pub const NormalItemUpdateNotify = struct {
    pub const default: @This() = .{};
    NormalItemList: std.ArrayList(NormalItem) = .empty,
    NoTips: bool = false,
};
pub const NormalItemAddNotify = struct {
    pub const default: @This() = .{};
    NormalItemList: std.ArrayList(NormalItem) = .empty,
    NoTips: bool = false,
    Reason: i32 = 0,
};
pub const WeaponItemRequest = struct {
    pub const default: @This() = .{};
};
pub const WeaponItemResponse = struct {
    pub const default: @This() = .{};
    WeaponItemList: std.ArrayList(WeaponItem) = .empty,
};
pub const WeaponItemAddNotify = struct {
    pub const default: @This() = .{};
    WeaponItemList: std.ArrayList(WeaponItem) = .empty,
    AddFromRole: bool = false,
    Reason: i32 = 0,
};
pub const WeaponItemRemoveNotify = struct {
    pub const default: @This() = .{};
    WeaponItemIncrIdList: std.ArrayList(i32) = .empty,
};
pub const PhantomItemRequest = struct {
    pub const default: @This() = .{};
};
pub const RolePhantomEquipInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    PhantomItemIncrId: std.ArrayList(i32) = .empty,
};
pub const RolePhantomPropInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    BaseProp: std.ArrayList(ArrayIntInt) = .empty,
    AddProp: std.ArrayList(ArrayIntInt) = .empty,
};
pub const PhantomItemResponse = struct {
    pub const default: @This() = .{};
    PhantomItemList: std.ArrayList(PhantomItem) = .empty,
    EquipInfoList: std.ArrayList(RolePhantomEquipInfo) = .empty,
    PropInfo: std.ArrayList(RolePhantomPropInfo) = .empty,
    MaxCost: i32 = 0,
    PhantomSkinList: std.ArrayList(i32) = .empty,
    DirectRefineWeekTimes: i32 = 0,
};
pub const PhantomItemAddNotify = struct {
    pub const default: @This() = .{};
    PhantomItemList: std.ArrayList(PhantomItem) = .empty,
    Reason: i32 = 0,
};
pub const PhantomItemRemoveNotify = struct {
    pub const default: @This() = .{};
    PhantomItemIncrIdList: std.ArrayList(i32) = .empty,
};
pub const ItemFuncValueUpdateNotify = struct {
    pub const default: @This() = .{};
    IncrId: i32 = 0,
    FuncValue: i32 = 0,
};
pub const WeaponItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IncrId: i32 = 0,
    FuncValue: i32 = 0,
    WeaponLevel: i32 = 0,
    WeaponExp: i32 = 0,
    WeaponBreach: i32 = 0,
    WeaponResonLevel: i32 = 0,
    RoleId: i32 = 0,
};
pub const PhantomItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IncrId: i32 = 0,
    FuncValue: i32 = 0,
    PhantomLevel: i32 = 0,
    PhantomExp: i32 = 0,
    PhantomMainProp: std.ArrayList(PhantomPropInfo) = .empty,
    PhantomSubProp: std.ArrayList(PhantomPropInfo) = .empty,
    FetterGroupId: i32 = 0,
    SkinId: i32 = 0,
    UnAckSubProp: std.ArrayList(PhantomPropInfo) = .empty,
    LockPropIndex: std.ArrayList(i32) = .empty,
};
pub const NormalItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Count: i32 = 0,
    ExpireTime: i64 = 0,
};
pub const PhantomPropInfo = struct {
    pub const default: @This() = .{};
    PhantomPropId: i32 = 0,
    Value: i32 = 0,
};
pub const ItemPkgOpenNotify = struct {
    pub const default: @This() = .{};
    OpenPkg: std.ArrayList(i32) = .empty,
};
pub const ValidTimeItemRequest = struct {
    pub const default: @This() = .{};
};
pub const ValidTimeItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Count: i32 = 0,
    IncrId: i32 = 0,
    ExpireTime: i64 = 0,
};
pub const ValidTimeItemResponse = struct {
    pub const default: @This() = .{};
    ItemList: std.ArrayList(ValidTimeItem) = .empty,
};
pub const RobotRoleInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    BaseProp: std.ArrayList(ArrayIntInt) = .empty,
    AddProp: std.ArrayList(ArrayIntInt) = .empty,
    RoleEquipmentPropData: ?RolePhantomPropInfo = null,
};
pub const RobotRolePropRequest = struct {
    pub const default: @This() = .{};
    RoleIds: std.ArrayList(i32) = .empty,
};
pub const RobotRolePropResponse = struct {
    pub const default: @This() = .{};
    Error: ?ErrorCode = null,
    RobotRoleInfo: std.ArrayList(RobotRoleInfo) = .empty,
};
pub const ItemDeprecateRequest = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    IncrId: i32 = 0,
};
pub const ItemDeprecateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AccessPathTimeServerConfigRequest = struct {
    pub const default: @This() = .{};
};
pub const AccessPathTimeServerConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const AccessPathTimeServerConfigResponse = struct {
    pub const default: @This() = .{};
    AccessPathTimeServerConfig: std.ArrayList(AccessPathTimeServerConfig) = .empty,
};
pub const ErrorCode = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Success = 0,
    RequestParamError = 1,
    InternalError = 2,
    UnKnownError = 3,
    ServerNotReady = 4,
    ServerFullLoad = 5,
    InvalidUserId = 6,
    InvalidToken = 7,
    InvalidRequest = 8,
    GmFail = 9,
    GmParamError = 10,
    GmException = 11,
    NotEnableGm = 12,
    NotElegantName = 13,
    ContainsDirtyWord = 14,
    DirtyWordServerError = 15,
    DirtyWordServerReturnEmpty = 16,
    DirtyWordCheckException = 17,
    ComponentNotExist = 18,
    ServerFullLoadGame = 19,
    ServerFullLoadGate = 20,
    PlayerLoggingInFlag = 21,
    GateLoginException = 22,
    GateLoginSeverSelectErr = 23,
    GateTokenAccessErr = 24,
    GateTokenAccessException = 25,
    GateLoginUserIdErr = 26,
    GateLoginNodeIdErr = 27,
    GateLoginCreateCharacterErr = 28,
    GateCreateCharacterException = 29,
    GateEnterGameAddressNotFound = 30,
    GateEnterGameException = 31,
    GateEnterGameCreatePlayerErr = 32,
    GateEnterGameAddPlayerErr = 33,
    GameGateNodeNotFound = 34,
    GamePlayerAdminExist = 35,
    GameReloginGateNodeNotFound = 36,
    GameReloginPlayerNotFound = 37,
    ServerNotOpen = 38,
    ServerMaintenance = 39,
    InvalidLoginType = 40,
    InvalidGateway = 41,
    SDKServerError = 42,
    TokenNotAuthrized = 43,
    HadBan = 44,
    NotInUserIdWhiteList = 45,
    NoHealthyGamesvr = 46,
    NoHealthyGateway = 47,
    GarFailed = 48,
    GarSdkCheckFail = 49,
    GarNoneUserInfo = 50,
    GarQueryUserInfoError = 51,
    GarNoRegion = 52,
    InternalExceptionCode = 53,
    DecodeExceptionCode = 54,
    EncodeExceptionCode = 55,
    InvalidRequestExceptionCode = 56,
    MessageOutOfLimitExceptionCode = 57,
    MessageNoHandler = 58,
    EncryptionNoCreate = 59,
    DecryptFail = 60,
    PlayerNotInTheScene = 61,
    NonReentrantExceptionCode = 62,
    PlayerLoggedOut = 63,
    MsgFunctionClose = 64,
    SeqNoError = 65,
    InvalidMessageType = 66,
    InvalidMessageHeader = 67,
    InvalidSeqNo = 68,
    InvalidMessageId = 69,
    ProtobufDecodeFailed = 70,
    ErrProtoSeedCheck = 71,
    MessageCouldNotBeRouted = 72,
    ErrPlayerLogined = 73,
    ClosedRegister = 100000,
    RegisterOutOfLimit = 100001,
    HaveNoCharacter = 100002,
    InvalidCharacterName = 100003,
    CreateCharacterFailed = 100004,
    CreateCharacterDuplicateKey = 100005,
    PlayerAlreadyLogin = 100006,
    PlayerLoggingIn = 100007,
    ErrLoginGWReconnecting = 100008,
    LoginRetry = 100009,
    QueryPlayerDataFailed = 100010,
    CheckPlayerDataFailed = 100011,
    CheckPlayerDataFailedDebug = 100012,
    LogoutUnknownError = 100013,
    AccountLoggedInElsewhere = 100014,
    AccountIsBlocked = 100015,
    DataOverflow = 100016,
    AccountBeKick = 100017,
    AppVersionNotMatch = 100018,
    LauncherVersionIsTooLow = 100019,
    ResourceVersionIsTooLow = 100020,
    CloseConnection = 100021,
    ErrAcquirePlayerLockFailed = 100022,
    ErrPlayerLoggingOut = 100023,
    MessageChecksumFailed = 100024,
    LoginTimeout = 100025,
    ErrWeaponDefault = 200000,
    ErrWeaponLevelLimit = 200001,
    ErrWeaponBreachLimit = 200002,
    ErrWeaponConsumeInvalid = 200003,
    ErrWeaponPkgFull = 200004,
    ErrRoleNoConfig = 200005,
    ErrRoleIsActive = 200006,
    ErrRoleNotActive = 200007,
    ErrRoleOverNotEnough = 200008,
    ErrRoleLevelNotEnough = 200009,
    ErrRoleException = 200010,
    ErrRoleNotExchange = 200011,
    ErrRoleResonNotActive = 200012,
    ErrRoleResonIsActive = 200013,
    ErrRoleConfigNotRight = 200014,
    ErrRoleLevelMax = 200015,
    ErrRolePerResonNotActive = 200016,
    ErrRoleConditionNotFind = 200017,
    ErrRoleConditionNoEnough = 200018,
    ErrRoleInvalidNameLength = 200019,
    ErrRoleExpInvalid = 200020,
    ErrRoleActiveNeedNoEnough = 200021,
    ErrRoleResonMaxLevel = 200022,
    ErrRoleProtoError = 200023,
    ErrRoleItemListEmpty = 200024,
    ErrRoleItemListCountOutRange = 200025,
    ErrRoleItemExpError = 200026,
    ErrRolePhantPosError = 200027,
    ErrRolePhantSameError = 200028,
    ErrRolePhantEmptyError = 200029,
    ErrRoleItemListNoEnough = 200030,
    ErrRoleGetSkillByIdFailed = 200031,
    ErrRoleFavorLevelNotEnough = 200032,
    ErrRolSkillNodeType = 200033,
    ErrRolSkillNodeTypeActive = 200034,
    ErrRolSkillNodeTypeUlock = 200035,
    ErrRolSkillPointsNotEnough = 200036,
    ErrTrialRoleExist = 200037,
    ErrTrialRoleNotExist = 200038,
    ErrTrialRoleRegionDataExist = 200039,
    ErrTrialRoleBtObjDataExist = 200040,
    ErrTrialRoleRegionExist = 200041,
    ErrTrialRoleRegionNotExist = 200042,
    ErrLoadEquipDefault = 200043,
    ErrLoadEquipInvalidPos = 200044,
    ErrLoadEquipInvalidRole = 200045,
    ErrLoadEquipRoleConfig = 200046,
    ErrPhantomIdNotExist = 200047,
    ErrPhantomNotExist = 200048,
    ErrPhantomLvupMax = 200049,
    ErrPhantomLvupMismatchItemId = 200050,
    ErrPhantomLvupNoItem = 200051,
    ErrPhantomLvupLimit = 200052,
    ErrPhantomItemType = 200053,
    ErrPhantomInvalidPos = 200054,
    ErrPhantomConfigNotFound = 200055,
    ErrPhantomItemNotExist = 200056,
    ErrPhantomPropNotExist = 200057,
    ErrPhantomQaulityNotExist = 200058,
    ErrPhantomBreachNotExist = 200059,
    ErrPhantomLevelNotEnough = 200060,
    ErrPhantomExpItemNotExist = 200061,
    ErrPhantomSubPropRandomErr = 200062,
    ErrPhantomSubPropNotEnough = 200063,
    ErrPhantomSubPropGenDupicate = 200064,
    ErrPhantomSubStrengthenPropNotExist = 200065,
    ErrPhantomLevelConfigNotExist = 200066,
    ErrPhantomLevelUpConsumeItemNotEnough = 200067,
    ErrPhantomLevelUpMaterialLock = 200068,
    ErrPhantomLevelUpConsumeItemErr = 200069,
    ErrPhantomLevelUpRepeatItem = 200070,
    ErrPhantomMainPropNotExist = 200071,
    ErrPhantomGrowthNotExist = 200072,
    ErrPhantomBreachItemCount = 200073,
    ErrPhantomBreachRepeatItem = 200074,
    ErrPhantomDecomposeEquiped = 200075,
    ErrPhantomDecomposeFail = 200076,
    ErrPhantomBreachBindItem = 200077,
    ErrPhantomBreachErrItem = 200078,
    ErrPhantomRecommendNoData = 200079,
    ErrPhantomCannotTakeOff = 200080,
    ErrPhantomCannotReplace = 200081,
    ErrVisionSkillFavoriteTypeLimit = 200082,
    ErrVisionSkillFavoriteCountLimit = 200083,
    ErrVisionSkillCfgNotFound = 200084,
    ErrVisionSkillNotFound = 200085,
    ErrVisionSkillLevelUpMax = 200086,
    ErrVisionSkillLevelUpLimit = 200087,
    ErrVisionSkillSlotNotFound = 200088,
    ErrVisionSkillEquipTypeLimit = 200089,
    ErrVisionSkillUnEquipLimit = 200090,
    ErrVisionSkillGemCfgNotFound = 200091,
    ErrVisionSkillEquipLimit = 200092,
    ErrVisionSkillGemLimit = 200093,
    ErrVisionSkillOperFail = 200094,
    ErrVisionSkillSlotEquipLimit = 200095,
    ErrExploreSkillRouletteRepeat = 200096,
    ErrItemCfgNotFound = 200097,
    ErrItemNotFound = 200098,
    ErrItemNotEnough = 200099,
    ErrItemDecomposeLimit = 200100,
    ErrItemUseLevelLimit = 200101,
    ErrItemLockLimit = 200102,
    ErrItemInvalidParams = 200103,
    ErrItemDecomposeFail = 200104,
    ErrItemUseFail = 200105,
    ErrExchangeRewardCostItemNotEnough = 200106,
    ExchangeRewardSuccess = 200107,
    ErrPkgCapacityNotEnough = 200108,
    ErrGiftOptionalCount = 200109,
    ErrGiftOptionalNotExists = 200110,
    ErrGiftNotExists = 200111,
    ErrItemCount = 200112,
    ErrItemIdNotContain = 200113,
    ErrItemTypeNotContain = 200114,
    ErrCalabashMaxLevel = 200115,
    ErrCalabashConfig = 200116,
    ErrCalabashLevelUp = 200117,
    ErrCalabashExp = 200118,
    ErrCalabashDevelopNoReward = 200119,
    ErrCalabashMonsterNotFound = 200120,
    PropRewardTips = 200121,
    ErrEnergyMaxCharge = 200122,
    ErrStateCanotTeleport = 200123,
    ErrStateCannotEnterInst = 200124,
    ErrStateCannotOnline = 200125,
    ErrStateCannotChangeFormation = 200126,
    ErrReportPlayerCountLimit = 200127,
    ErrReportPlayerReasonNotFound = 200128,
    ErrReportMessageLengthLimit = 200129,
    ErrCookingToolFixed = 200130,
    ErrCookingFormulaNotFound = 200131,
    ErrCookingCount = 200132,
    ErrCookingProcessNotFound = 200133,
    ErrCookingLevelNotFound = 200134,
    ErrCookingLevelLimt = 200135,
    ErrCookingInteractiveNotFound = 200136,
    ErrCookingFuncNotOpen = 200137,
    ErrChallengeNotFound = 200138,
    ErrChallengeNoTeam = 200139,
    ErrChallengeTeamLimit = 200140,
    ErrChallengeTeamMemLimit = 200141,
    ErrChallengeChangeFormation = 200142,
    ErrChallengeFunNotOpen = 200143,
    ErrChallengeSeasonUpdate = 200144,
    ErrChallengeLockRoleLimit = 200145,
    ErrChallengeRoleLocked = 200146,
    ErrChallengeNoRoleAlive = 200147,
    ErrChallengeFormationEmpty = 200148,
    ErrCycleChallengeNoRoleAlive = 200149,
    ErrCycleChallengeFormationEmpty = 200150,
    ErrInfluenceLocked = 200151,
    ErrInfluenceRewardNotFound = 200152,
    ErrInfluenceConfigNotFound = 200153,
    ErrReputationLimit = 200154,
    ErrInfluenceRewardFailed = 200155,
    ErrInfluenceFunNotOpen = 200156,
    ErrForgeFuncNotOpen = 200157,
    ErrForgeCountLimit = 200158,
    ErrForgeLocked = 200159,
    ErrForgeConfigNotFound = 200160,
    ErrForgeUnlocked = 200161,
    ErrSynthesisFuncNotOpen = 200162,
    ErrSynthesisConfigNotFound = 200163,
    ErrSynthesisCountLimit = 200164,
    ErrSynthesisLocked = 200165,
    ErrSynthesisLevelNotFound = 200166,
    ErrSynthesisLevelLimit = 200167,
    ErrSynthesisCannotUnlock = 200168,
    ErrSynthesisUnlocked = 200169,
    ErrTrialRoleCannotMatch = 200170,
    ErrPhantomFormationTeleport = 200171,
    ErrPhantomFormationEnterInst = 200172,
    ErrPhantomFormationMultiPlay = 200173,
    ErrPhantomFormationAdvice = 200174,
    ErrPhantomFormationChangeFormation = 200175,
    ErrPhantomFormationRepeat = 200176,
    ErrPhantomFormationChangeFailed = 200177,
    ErrRoleChangeRoleCreateFailed = 200178,
    ErrRoleChangeRoleUpdateCreateFailed = 200179,
    ErrRoleChangeRoleNotUnlock = 200180,
    ErrRoleChangeMultiPlay = 200181,
    ErrRoleChangeInst = 200182,
    ErrRoleChangeElementFunc = 200183,
    ErrPhantomFormationCannotJoin = 200184,
    ErrPhantomFormationHost = 200185,
    ErrRoleChangeShowAllRole = 200186,
    ErrInteractBoardEntityNotFound = 200187,
    ErrInteractBoardRange = 200188,
    ErrInteractBoardSystemNotFound = 200189,
    ErrInteractBoardEntityConfig = 200190,
    ErrInteractEntranceNotFound = 200191,
    ErrInteractEntranceNotMatch = 200192,
    ErrItemMaxUseCount = 200193,
    ErrFuncNotExist = 200194,
    ErrPhantomChangeInBattle = 200195,
    ErrItemCanNotDestroy = 200196,
    ErrPhantomEquipSourceCost = 200197,
    ErrPhantomEquipTargetCost = 200198,
    ErrPhantomEquipDuplicate = 200199,
    ErrPhantomAutoEquipFromOther = 200200,
    ErrPhantomConsumeItemCount = 200201,
    ErrPhantomConsumeItemDuplicate = 200202,
    ErrPhantomConsumeItemIncrDuplicate = 200203,
    ErrPhantomConsumeItem = 200204,
    ErrPhantomConsumeNoExp = 200205,
    ErrPhantomBreachPos = 200206,
    ErrPhantomBreachSuspend = 200207,
    ErrPhantomBreachQuality = 200208,
    ErrPhantomBreachExp = 200209,
    ErrPhantomBreachConsumeItem = 200210,
    ErrPhantomBreachNoSuspend = 200211,
    ErrPhantomSpecialSkillRole = 200212,
    ErrPhantomNotEquip = 200213,
    ErrPhantomSpecilSkillPos = 200214,
    ErrPhantomSubPropPlanConfig = 200215,
    ErrPhantomMainPropGenFail = 200216,
    ErrLivenessFuncNotOpen = 200217,
    ErrLivenessTaskNotFound = 200218,
    ErrLivenessTaskDataNotFound = 200219,
    ErrLivenessTaskNotFinish = 200220,
    ErrLivenessTaskRewarded = 200221,
    ErrLivenessRewardNotFound = 200222,
    ErrLivenessGoalNotReach = 200223,
    ErrLivenessRewardParam = 200224,
    ErrLivenessTaskRewardParam = 200225,
    ErrWeaponLevelUpComsumeCount = 200226,
    ErrWeaponConsumeSelf = 200227,
    ErrWeaponConsumeItemNotFound = 200228,
    ErrWeaponConsumeItemIdNotFound = 200229,
    ErrWeaponLocked = 200230,
    ErrWeaponConsumeDuplicate = 200231,
    ErrWeaponEquiped = 200232,
    ErrWeaponLevelUpItemDuplicate = 200233,
    ErrWeaponLevelUpNoExp = 200234,
    ErrWeaponLevelUpLevel = 200235,
    ErrPhantomMainPropNotMatch = 200236,
    ErrPhantomSubPropNotMatch = 200237,
    ErrPhantomEquiped = 200238,
    ErrAdviceNotInit = 200239,
    ErrTowerChallengeNotOpen = 200240,
    ErrTowerNotInChallenge = 200241,
    ErrTowerConfigNotFound = 200242,
    ErrTowerChallengeNotInOpenTime = 200243,
    ErrTowerInChallenge = 200244,
    ErrTowerFormationCount = 200245,
    ErrTowerFormationRoleDuplicate = 200246,
    ErrTowerRoleCost = 200247,
    ErrTowerDifficultyNotClear = 200248,
    ErrTowerFloorNotClear = 200249,
    ErrTowerAreaNotClear = 200250,
    ErrTowerRecommendNotSettle = 200251,
    ErrTowerRewardNotFound = 200252,
    ErrTowerNoReward = 200253,
    ErrTowerRewarded = 200254,
    ErrTowerRewardTarget = 200255,
    ErrTowerSeasonUpdate = 200256,
    ErrLordGymConfigNotFound = 200257,
    ErrLordGymNotInPlay = 200258,
    ErrLordGymLock = 200259,
    ErrLordGymBtTreeNotFound = 200260,
    ErrRoleSexFuncNotOpen = 200261,
    ErrPhantomSubPropLocked = 200262,
    ErrPhantomIdentifyNoCost = 200263,
    ErrGiftPackType = 200264,
    ErrGiftPackUseLimit = 200265,
    ErrCdKeyNotEnable = 200266,
    ErrCdKeyRequestCount = 200267,
    ErrCdKeyRequestErr = 200268,
    ErrCdKeyRequestDataErr = 200269,
    ErrCdKeyException = 200270,
    ErrCdKeyProcessCount = 200271,
    ErrCdKeyNotFound = 200272,
    ErrCdKeyBatchNotFound = 200273,
    ErrCdKeyNotInValidTime = 200274,
    ErrCdKeyBatchMaxCount = 200275,
    ErrCdKeyEachPlayerMaxCount = 200276,
    ErrCdKeyGroupCount = 200277,
    ErrCdKeyCondition = 200278,
    ErrCdKeyAddCountFail = 200279,
    ErrCdKeyLength = 200280,
    ErrCdKeyCharacter = 200281,
    ErrGiftPackRandomErr = 200282,
    ErrReconnectUserWhiteList = 200283,
    ErrReconnectChannelWhiteList = 200284,
    ErrReconnectIpInvalid = 200285,
    ErrReconnectIpWhiteList = 200286,
    ErrCdKeyExpire = 200287,
    ErrWeaponResonLevelLimit = 200288,
    ErrWeaponConfigNotFound = 200289,
    ErrWeaponResonConfigNotFound = 200290,
    ErrWeaponResonConsumeItem = 200291,
    ErrWeaponResonConsumeGold = 200292,
    ErrDestroyItemDuplicate = 200293,
    ErrDestroyWeapon = 200294,
    ErrCannotDestroyItem = 200295,
    ErrCannotDestroyPhantom = 200296,
    ErrCannotDestroyWeaponForm = 200297,
    ErrCannotDestroyItemUnknown = 200298,
    ErrWeaponConsumeQuality = 200299,
    ErrPhantomSkinChangeCd = 200300,
    ErrPhantomSkinUnlock = 200301,
    ErrPhantomSkinMatch = 200302,
    ErrLoginGameTainted = 200303,
    ErrCookLimitCount = 200304,
    ErrCookLimitTime = 200305,
    ErrForgeLimitCount = 200306,
    ErrForgeLimitTime = 200307,
    ErrSynthesisLimitCount = 200308,
    ErrSynthesisLimitTime = 200309,
    ErrLoginIpBan = 200310,
    ErrLoginDeviceBan = 200311,
    ErrRoleNameEmpty = 200312,
    ErrAdviceLength = 200313,
    ErrPhantomRefiningCount = 200314,
    ErrPhantomRefiningScore = 200315,
    ErrPhantomRefiningTotalScore = 200316,
    ErrPhantomRefiningDeveloped = 200317,
    ErrPhotoMemoryCollectConfig = 200318,
    ErrPhotoMemoryFuncNotOpen = 200319,
    ErrPhotoMemoryCollectLock = 200320,
    ErrPhotoMemoryCollectRewarded = 200321,
    ErrRoleCount = 200322,
    ErrCookFormulaUnlocked = 200323,
    ErrForgeFormulaUnlocked = 200324,
    ErrSynthesisFormulaUnlocked = 200325,
    ErrCookFormulaBuyCount = 200326,
    ErrForgeFormulaBuyCount = 200327,
    ErrSynthesisFormulaBuyCount = 200328,
    ErrCdKeyDailyVerifyCount = 200329,
    ErrLongShanTaskNotFound = 200330,
    ErrLongShanActivityClosed = 200331,
    ErrLongShanTaskNotAccept = 200332,
    ErrLongShanTaskNotComplete = 200333,
    ErrLongShanTaskRewarded = 200334,
    ErrTowerDefenceRewardParamErr = 200335,
    ErrTowerDefenceInstanceNotFound = 200336,
    ErrTowerDefenceActivityNotOpen = 200337,
    ErrTowerDefenceActivityDataNotFound = 200338,
    ErrTowerDefenceInstDataNotFound = 200339,
    ErrTowerDefenceInstRewarded = 200340,
    ErrTowerDefenceInstScoreNotEnough = 200341,
    ErrTowerDefenceScoreRewarded = 200342,
    ErrTowerDefenceScoreRewardNotEnough = 200343,
    ErrTowerDefenceScoreRewardNotFound = 200344,
    ErrTowerDefenceInstBuffNotEnable = 200345,
    ErrTowerDefencePhantomDuplicate = 200346,
    ErrTowerDefencePhantomNotSelect = 200347,
    ErrorTowerDefenceInstNotOpen = 200348,
    ErrorTowerDefenceInstCondition = 200349,
    ErrNameModifyCd = 200350,
    ErrNameVerifying = 200351,
    ErrTimePointRewardActivityConfigNotFound = 200352,
    ErrTimePointRewardActivityNotOpen = 200353,
    ErrTimePointRewardActivityRewarded = 200354,
    ErrTimePointRewardActivityTime = 200355,
    ErrCDKeyVerifying = 200356,
    ErrorTowerDefenceInstLocked = 200357,
    ErrTrackMoonEntrustLocked = 200358,
    ErrTrackMoonRoleLocked = 200359,
    ErrTrackMoonBuildLocked = 200360,
    ErrTrackMoonBuildEntity = 200361,
    ErrCopyUserRequestErr = 200362,
    ErrCopyUserInserting = 200363,
    ErrCopyUserErr = 200364,
    ErrCopyUserDataErr = 200365,
    ErrCopyUserInsertErr = 200366,
    ErrCopyUserInsertFailed = 200367,
    ErrRiskHarvestBuffGroupNotFound = 200368,
    ErrRiskHarvestActivityClosePlay = 200369,
    ErrRiskHarvestModeChangeClosePlay = 200370,
    ErrRiskHarvestLeaveClosePlay = 200371,
    ErrRiskHarvestInstNotFound = 200372,
    ErrRiskHarvestActivityNotOpen = 200373,
    ErrRiskHarvestInstDataNotFound = 200374,
    ErrRiskHarvestInstRewarded = 200375,
    ErrRiskHarvestInstNotPass = 200376,
    ErrRiskHarvestScoreRewardNotFound = 200377,
    ErrRiskHarvestScoreRewarded = 200378,
    ErrRiskHarvestScoreNotEnough = 200379,
    ErrRiskHarvestRoleTrial = 200380,
    ErrRiskHarvestMatching = 200381,
    ErrRiskHarvestNotDefaultWorld = 200382,
    ErrRiskHarvestMultiMode = 200383,
    ErrRiskHarvestInstLocked = 200384,
    ErrRiskHarvestInstTeleportEntityNotFound = 200385,
    ErrRiskHarvestInstOpen = 200386,
    ErrRiskHarvestPlayOpenFailed = 200387,
    ErrRiskHarvestPlayDataNotFound = 200388,
    ErrRiskHarvestBuffNoReward = 200389,
    ErrRiskHarvestBuffRewarded = 200390,
    ErrRiskHarvestBuffLocked = 200391,
    ErrRiskHarvestBuffCountRewardNotFound = 200392,
    ErrRiskHarvestBuffCountRewarded = 200393,
    ErrRiskHarvestBuffCountNotEnough = 200394,
    ErrRiskHarvestInstScoreNotEnough = 200395,
    ErrItemDisuseLimit = 200396,
    ErrItemDisuseFunc = 200397,
    ErrPhantomRefiningMaxCount = 200398,
    ErrPhantomRefiningDulplicate = 200399,
    ErrPhantomNotNormal = 200400,
    ErrGetSelfPsnOnlineId = 200401,
    ErrGetPsnUserPlayerErr = 200402,
    ErrTowerDefenceHostLeave = 200403,
    ErrRiskHarvestNotInInst = 200404,
    ErrEnterInstTypeErr = 200405,
    ErrInputSettingCount = 200406,
    ErrInputSettingDeviceType = 200407,
    ErrInputSettingActionCount = 200408,
    ErrInputSettingAxisCount = 200409,
    ErrInputCombinationActionCount = 200410,
    ErrInputCombinationAxisCount = 200411,
    ErrInputSettingActionName = 200412,
    ErrInputSettingAxisName = 200413,
    ErrInputCombinationActionName = 200414,
    ErrInputCombinationAxisName = 200415,
    ErrInputActionKeyNameLength = 200416,
    ErrInputActionKeyLength = 200417,
    ErrInputAxisKeyNameLength = 200418,
    ErrInputAxisKeyLength = 200419,
    ErrInputCombinationActionKeyNameLength = 200420,
    ErrInputCombinationActionKeyLength = 200421,
    ErrInputCombinationActionKeyListLength = 200422,
    ErrInputCombinationAxisKeyNameLength = 200423,
    ErrInputCombinationAxisKeyLength = 200424,
    ErrInputCombinationAxisKeyListLength = 200425,
    ErrInputDeviceSubTypeLength = 200426,
    ErrPSNAccountBlocked = 200427,
    ErrRoleNameInvalid = 200428,
    ErrMailBindRewardNotBind = 200429,
    ErrMailBindRewarded = 200430,
    ErrInputSettingNull = 200431,
    ErrMultiInstExchangeCountErr = 200432,
    ErrMultiInstExchangeFirstPass = 200433,
    ErrMultiInstExchangeActivity = 200434,
    ErrMultiInstExchangeFuncNotOpen = 200435,
    ErrMultiInstExchangeTypeErr = 200436,
    ErrMultiInstExchangeLevelTypeErr = 200437,
    ErrRoleSkinLocked = 200438,
    ErrRoleSkinConfig = 200439,
    ErrRoleSkinNotMatch = 200440,
    ErrRoleSkinWeaponNotSuit = 200441,
    ErrSdkLoginResetByPeer = 200442,
    ErrSdkLoginHttpRequestException = 200443,
    ErrSdkLoginTaskTimeout = 200444,
    ErrSdkLoginTaskCanceled = 200445,
    ErrSexChangeCd = 200446,
    ErrSexChangeLogout = 200447,
    ErrSexChangeTrialActive = 200448,
    ErrLobbyListRequestLimit = 200449,
    ErrLobbyQueryPlayerRequestLimit = 200450,
    ErrPlayerBasicInfoRequestLimit = 200451,
    ErrBlockPlayerRequestLimit = 200452,
    ErrPsnPlayerInfoRequestLimit = 200453,
    ErrFishingPosInvalidX = 200454,
    ErrFishingPosInvalidY = 200455,
    ErrFishingPosOverlap = 200456,
    ErrFishingParamLengthCabinLeft = 200457,
    ErrFishingParamLengthCabinRight = 200458,
    ErrFishingCabinNotOpen = 200459,
    ErrFishingCabinNotFound = 200460,
    ErrFishingCountNotMatch = 200461,
    ErrFishingDuplicate = 200462,
    ErrFishingRemoveItemErr = 200463,
    ErrFishingItemNotFound = 200464,
    ErrFishingCountNotMatchRequest = 200465,
    ErrFishingCountNotMatchCabin = 200466,
    ErrFishingHandInNotMatch = 200467,
    ErrFishingQuickSellNoItem = 200468,
    ErrFishingNoQuickSell = 200469,
    ErrFishingQuickSellConfig = 200470,
    ErrFishingQuickSellNotFilled = 200471,
    ErrFishingQuickSellItemErr = 200472,
    ErrFishingNoSellItem = 200473,
    ErrFishingCanNotSell = 200474,
    ErrFishingItemConfigNotFound = 200475,
    ErrFishingSellItemDuplicate = 200476,
    ErrFishingPriceCalFailed = 200477,
    ErrFishingSellCount = 200478,
    ErrFishingPointNotOpen = 200479,
    ErrFishingPointConfig = 200480,
    ErrFishingPointCount = 200481,
    ErrFishingTempCabinMax = 200482,
    ErrFishingPointGenFail = 200483,
    ErrFishingTechLevel = 200484,
    ErrFishingPreNodeLock = 200485,
    ErrFishingTechLock = 200486,
    ErrFishingTechConfig = 200487,
    ErrFishingLevelMax = 200488,
    ErrFishingSkinConfig = 200489,
    ErrFishingPortConfig = 200490,
    ErrFishingEntrustConfig = 200491,
    ErrFishingEntrustNotAccepted = 200492,
    ErrFishingEntrustNotFound = 200493,
    ErrFishingEntrustDestination = 200494,
    ErrFishingEntrustItemNotEnough = 200495,
    ErrFishingEntrustItemTotalNotMatch = 200496,
    ErrFishingEntrustDumplicate = 200497,
    ErrFishingEntrustEmptyItem = 200498,
    ErrFishingEntrustItemNotMatch = 200499,
    ErrFishingEntrustRefreshInitial = 200500,
    ErrFishingEntrustRefreshPrice = 200501,
    ErrFishingEntrustNotAcceptable = 200502,
    ErrFishingNotInBigWorld = 200503,
    ErrFishingMultiMode = 200504,
    ErrFishingNotOwner = 200505,
    ErrFishingSkinLock = 200506,
    ErrFishingPortLock = 200507,
    ErrFishingCageLock = 200508,
    ErrFishingCageConfig = 200509,
    ErrFishingHandInConfig = 200510,
    ErrFishingHandInCountNotMatch = 200511,
    ErrFishingTempPointData = 200512,
    ErrFishingTempPointConfig = 200513,
    ErrFishingBombItem = 200514,
    ErrFishingBombNoPoint = 200515,
    ErrFishingBaitArea = 200516,
    ErrFishingNotSailing = 200517,
    ErrFishingInPort = 200518,
    ErrFishingInShip = 200519,
    ErrFishingIllustratedRewardNotFound = 200520,
    ErrFishingIllustratedRewarded = 200521,
    ErrFishingIllustratedCondition = 200522,
    ErrFishingTechOutputNotFound = 200523,
    ErrFishingShipNotFound = 200524,
    ErrFishingPortTech = 200525,
    ErrFishingRemoveFuncNotOpen = 200526,
    ErrFishingIllustratedFuncNotOpen = 200527,
    ErrFishingSellFuncNotOpen = 200528,
    ErrFishingTechFuncNotOpen = 200529,
    ErrFishingEntrustHandInQuickSell = 200530,
    ErrActivityPreOpenLock = 200531,
    ErrActivityShowLock = 200532,
    ErrShopGoodsVisibleCondition = 200533,
    ErrShopGoodsDisableCondition = 200534,
    ErrFishingEntrustRefreshFail = 200535,
    ErrPlayerDataVersion = 200536,
    ErrBrokenCircuitRejected = 200537,
    ErrRateLimiterRejected = 200538,
    ErrTimeoutRejected = 200539,
    ErrLoginEnvironment = 200540,
    ErrLoginUserEmpty = 200541,
    ErrOldGameNodeLogoutFail = 200542,
    ErrOldGameNodeLogoutOffline = 200543,
    ErrReloginBranchNameNotMatch = 200544,
    ErrReLoginFightDataInConsistent = 200545,
    ErrCreatePlayerData = 200546,
    ErrReLoginPlayerLoggingOut = 200547,
    ErrAccountLoggedInElsewhere = 200548,
    ErrTowerChallengeTeleportLocked = 200551,
    ErrTowerDefenceGroupConfig = 200552,
    ErrTowerDefencePreInstNotPass = 200553,
    ErrTowerDefenceRankCd = 200554,
    ErrFishingFixItemNotEnough = 200549,
    ErrFishingEntrustUpdateItemNotEnough = 200550,
    ErrTowerDefenceGroupActivityC = 200555,
    ErrTowerDefenceGroupActivity = 200556,
    ErrAbyssComNotFound = 200557,
    ErrAbyssInstConfig = 200558,
    ErrAbyssRoomConfig = 200559,
    ErrAbyssEnterCtx = 200560,
    ErrAbyssActivityNotOpen = 200561,
    ErrAbyssRewardConfig = 200562,
    ErrAbyssRewardNotOpen = 200563,
    ErrAbyssRewardClosed = 200564,
    ErrAbyssRewarded = 200565,
    ErrAbyssRewardCondition = 200566,
    ErrAbyssLastActionNotFinish = 200567,
    ErrAbyssNextRoomNotFound = 200568,
    ErrAbyssRoleNotEquip = 200569,
    ErrAbyssEquipRoleNotExist = 200570,
    ErrAbyssEquipRoleDuplicate = 200571,
    ErrAbyssRoomNoBox = 200572,
    ErrAbyssRewardPlayerCount = 200573,
    ErrAbyssRewardBoxEntityIncId = 200574,
    ErrAbyssBoxRewarded = 200575,
    ErrAbyssBoxNotBelong = 200576,
    ErrAbyssBoxConfigNotFound = 200577,
    ErrAbyssBoxDropFailed = 200578,
    ErrAbyssChallengeLocked = 200579,
    ErrAbyssChallengeNoConsume = 200580,
    ErrAbyssChallengeUnlockItem = 200581,
    ErrAbyssLikePlayerNotInScene = 200582,
    ErrAbyssLikeDuplicate = 200583,
    ErrAbyssRoleItemNotFound = 200584,
    ErrAbyssRoleConfig = 200585,
    ErrAbyssRoleLevelConfig = 200586,
    ErrAbyssRoleMaxPluginCount = 200587,
    ErrAbyssRoleLevelMaxPlugin = 200588,
    ErrAbyssPutOnDuplicate = 200589,
    ErrAbyssEquipOldRoleFailed = 200590,
    ErrAbyssSysthesisMaxCount = 200591,
    ErrAbyssSysthesisItemDuplicate = 200592,
    ErrAbyssPluginItemNotFound = 200593,
    ErrAbyssPluginItemLocked = 200594,
    ErrAbyssPluginConfigNotFound = 200595,
    ErrAbyssPluginEquipped = 200596,
    ErrAbyssQuialityConfig = 200597,
    ErrAbyssSysthesisConsumeItemDuplicate = 200598,
    ErrAbyssRankListCd = 200599,
    ErrAbyssRoleUpLevel = 200600,
    ErrAbyssRoleUpItem = 200601,
    ErrAbyssRoleUpNoComsume = 200602,
    ErrAbyssPreChallengeNotPass = 200603,
    ErrAbyssSlotConfig = 200604,
    ErrAbyssSlotNotMatch = 200605,
    ErrAbyssInstUnlockTime = 200606,
    ErrAbyssSettled = 200607,
    ErrFormationTrailGender = 200608,
    ErrLongShanStageLocked = 200609,
    ErrAbyssRewardIdRepeated = 200610,
    ErrAbyssRewardCount = 200611,
    ErrOtherPlayerCondition = 200612,
    ErrAbyssItemSkillBelongTo = 200613,
    ErrLongShanScoreRewardCount = 200614,
    ErrLongShanScoreRewardDuplicate = 200615,
    ErrLongShanScoreRewardConfig = 200616,
    ErrLongShanScoreRewardActivity = 200617,
    ErrLongShanScoreRewarded = 200618,
    ErrLongShanScoreNotEnough = 200619,
    ErrAbyssDuplicatePassive = 200620,
    ErrActivityLifePointChallengeNotFound = 200621,
    ErrActivityLifePointNotOpen = 200622,
    ErrActivityLifePointPreLocked = 200623,
    ErrPhantomSettingRuleDuplicate = 200624,
    ErrPhantomSettingRuleNotFound = 200625,
    ErrPhantomSettingEmpty = 200626,
    ErrPhantomSettingType = 200627,
    ErrPhantomSettingNameLength = 200628,
    ErrPhantomSettingNull = 200629,
    ErrPhantomSettingIndexRange = 200630,
    ErrPhantomRuleIndexRange = 200631,
    ErrPhantomRuleCount = 200632,
    ErrPhantomBathchOperCount = 200633,
    ErrPhantomBathchType = 200634,
    ErrMobileSettingRequestParam = 200635,
    ErrMobileSettingParamDuplicate = 200636,
    ErrCommonUiSettingRequestParam = 200637,
    ErrCommonUiSettingParamDuplicate = 200638,
    ErrCommonUiSettingConfig = 200639,
    ErrActivityNotOpenTip = 200640,
    ErrLineCrossChallengeNotFound = 200641,
    ErrActivitylineCrossNotOpen = 200642,
    ErrActivitylineCrossPreLocked = 200643,
    ErrPhantomSettingFuncNotOpen = 200644,
    ErrTowerSeasonConfig = 200645,
    ErrAccountDeactivation = 200646,
    ErrPlayerAccountDeactivation = 200647,
    ErrPlayerSkinChange = 200648,
    ErrTrapDefenseNotMulti = 200649,
    ErrNotInTrapDefenseInst = 200650,
    ErrBossRushTaskNoConfig = 200651,
    ErrBossRushRequestActivityNotMatch = 200652,
    ErrPhantomBatchPolishCount = 200653,
    ErrPhantomBatchPolishDuplicate = 200654,
    ErrPhantomBatchPolishPropNotMatch = 200655,
    ErrPhantomBatchPolishNoValidItem = 200656,
    ErrLoginEmptyToken = 200657,
    ErrPhantomVicePolishLimit = 200658,
    ErrPhantomVicePolishParam = 200659,
    ErrPhantomVicePolishItemPropLimit = 200660,
    ErrPhantomVicePolishItemLevelLimit = 200661,
    ErrPhantomVicePolishParamDuplicate = 200662,
    ErrPhantomVicePolishPropGen = 200663,
    ErrPhantomVicePolishNoneProp = 200664,
    ErrSkinRewardNotFound = 200665,
    ErrSkinRewardState = 200666,
    ErrTowerForbidRechallenge = 200667,
    ErrInputSettingActoinType = 200668,
    ErrCreateCharacterGender = 200669,
    ErrSkillBranchRoleValid = 200670,
    ErrSkillBranchNotValid = 200671,
    ErrTrailRoleSkillBranchNotValid = 200672,
    ErrRoleDevConfigVersion = 200673,
    ErrRoleDevConfigVersionTime = 200674,
    ErrRoleDevConfigNoUpdate = 200675,
    ErrMotorDevelopRequestParam = 200676,
    ErrMotorDevelopParamDuplicate = 200677,
    ErrMotorDevelopTaskNotFound = 200678,
    ErrMotorDevelopActivityNotOpen = 200679,
    ErrMotorDevelopTaskNotComplete = 200680,
    ErrPhantomVicePolishNoAck = 200681,
    ErrClientStorageSystemCount = 200682,
    ErrClientStorageSystemDuplicate = 200683,
    ErrClientStorageSystem = 200684,
    ErrClientStorageStringLength = 200685,
    ErrClientStorageType = 200686,
    ErrClientStorageCapacity = 200687,
    ErrClientStorageSystemTypeErr = 200688,
    ErrXboxRegionNotFound = 200689,
    ErrNotXboxChannelId = 200690,
    ErrXboxRegionSet = 200691,
    ErrXboxRegionSetException = 200692,
    ErrXboxRegionGetException = 200693,
    ErrXboxRegionGetFailed = 200694,
    ErrQuestBranchPageNotFound = 200695,
    ErrQuestBranchQuestState = 200696,
    ErrQuestBranchComplete = 200697,
    ErrQuestBranchNotComplete = 200698,
    ErrFightFormationNameChangeCd = 200699,
    ErrFightFormationNameLength = 200700,
    ErrRoleSkillLevel = 200701,
    ErrQuestBranchConfig = 200702,
    ErrConditionStateRequestParam = 200703,
    ErrConditionStateRequestModule = 200704,
    ErrMapDefault = 300000,
    ErrMapMarkNumLimit = 300001,
    ErrMapNoFogConfig = 300002,
    ErrMapFogAlreadyUnlock = 300003,
    ErrFormationEmpty = 300004,
    ErrFormationUnknown = 300005,
    ErrFormationDead = 300006,
    ErrFormationRoleRepeat = 300007,
    ErrFormationRoleNotActive = 300008,
    ErrFormationRoleIndexOut = 300009,
    ErrFormationRoleCountOut = 300010,
    ErrFightFormationRoleNotExist = 300011,
    ErrFightFormationRoleIdNotMatch = 300012,
    ErrFightFormationRoleCountNotMatch = 300013,
    ErrFightFormationRoleCareerNotMatch = 300014,
    ErrFightFormationRoleElementNotMatch = 300015,
    ErrFightFormationCannotTrial = 300016,
    ErrFightFormationTrialRoleNotMatch = 300017,
    ErrFormationOverSize = 300018,
    ErrSwitchRoleIsDead = 300019,
    ErrUpdateFormationCurRoleIsDead = 300020,
    ErrUpdateFormationRoleIdsIsNull = 300021,
    ErrFormationIdOutOfRange = 300022,
    ErrCanNotCancelCurFormation = 300023,
    ErrCurRoleNotInFormationRoleIds = 300024,
    ErrUpateFormationNotInSingleWorld = 300025,
    ErrSwitchRoleTypeSignleWorld = 300026,
    ErrSwitchRoleTypeMultiWorld = 300027,
    ErrSwitchRoleTypeFbInstance = 300028,
    ErrSwitchRoleTypeUndefine = 300029,
    ErrSingWorldCanNotUpdateFightRoles = 300030,
    ErrUpdateFightRolesIsNull = 300031,
    ErrUpdateFightRolesCurIdNotExist = 300032,
    ErrInStroyCharacterCanNotSwitchRole = 300033,
    ErrSwitchRoleNotInFightRoles = 300034,
    ErrCanNotSwitchRepeat = 300035,
    ErrSwitchRoleEntityIdNotExist = 300036,
    ErrSwitchRoleEntityNotExist = 300037,
    ErrSitchRoleEntityIsDead = 300038,
    ErrorTeamOperaFail = 300039,
    ErrorPlayerAlreadyHaveTeam = 300040,
    ErrorTeamInviteContentInvalid = 300041,
    ErrorPlayerInBanTime = 300042,
    ErrorPlayerInInviteCd = 300043,
    ErrorPlayerAlreadyInTeam = 300044,
    ErrorKickOutPermissionNotEnough = 300045,
    ErrorTeamIsFull = 300046,
    ErrorTeamServiceNotReady = 300047,
    ErrorTeamPlayerJoinRepeat = 300048,
    ErrorPlayerNotInTeam = 300049,
    ErrorInvitePlayerNotExist = 300050,
    ErrorKickPlayerNotInTeam = 300051,
    ErrorDismissPermissionNotEnough = 300052,
    ErrorTeamRoleIdNotActive = 300053,
    ErrorTeamRoleIdRepeat = 300054,
    ErrorJoinOtherWorldOtherNotExist = 300055,
    ErrorJoinOtherWorldOtherNotInScene = 300056,
    ErrorJoinOtherWorldSceneNotExist = 300057,
    ErrorTeamNotExist = 300058,
    ErrRewardCfgNotFound = 300059,
    ErrTeleportIdNotExist = 300060,
    ErrTeleportIdNotActivate = 300061,
    ErrTeleportCreatureIdNotExist = 300062,
    ErrTeleportIdAlreadyActivate = 300063,
    ErrTeleportGmGetPlayerFailed = 300064,
    ErrTeleportGmGetCreatureGenCfgFailed = 300065,
    ErrTgmNotExitst = 300066,
    ErrTgmNotPlayer = 300067,
    ErrTgmNotGenCfg = 300068,
    ErrTgmInsId = 300069,
    ErrTeleportEntityNotExist = 300070,
    ErrTeleportComponentNotExist = 300071,
    ErrTeleportComponentNotMatch = 300072,
    ErrAreaEnterRepeated = 300073,
    ErrAreaIdNotExist = 300074,
    ErrAreaIdNoNeedRecord = 300075,
    ErrPlayerIsNotDead = 300076,
    ErrPlayerCanNotRevive = 300077,
    ErrPlayerReviveCountReachMax = 300078,
    ErrPlayerReviveDelayNotReach = 300079,
    ErrAutoReviveNotRequest = 300080,
    ErrReviveRegionExisted = 300081,
    ErrReviveRegionNotExisted = 300082,
    ErrReviveRegionConfigNotExist = 300083,
    ErrCanNotUseItemRevive = 300084,
    ErrIsMatching = 300085,
    ErrNotInMatcing = 300086,
    ErrMatchPoolNotExist = 300087,
    ErrNotFindMatchResult = 300088,
    ErrConfirmResultRepeat = 300089,
    ErrAlreadyHaveFbTeam = 300090,
    ErrFbTeamNotExist = 300091,
    ErrPlayerNotInFbTeam = 300092,
    ErrHostCanNotReady = 300093,
    ErrChangeReadyRepeat = 300094,
    ErrFbTeamHaveSameRole = 300095,
    ErrReadyStateCanNotChangeRole = 300096,
    ErrChangeSameRole = 300097,
    ErrNotHaveKickPermission = 300098,
    ErrBeKickNotInFbTeam = 300099,
    ErrNotHaveFightPermission = 300100,
    ErrFbTeamNotAllReady = 300101,
    ErrFbInstIdNotExist = 300102,
    ErrFbMatchRoleNotMatch = 300103,
    ErrSingleInstCanNotMatch = 300104,
    ErrWaitOtherEnterSceneForbidMatch = 300105,
    ErrIsEnteringOtherSceneForbidMatch = 300106,
    InstPlayBtObjNotFound = 300107,
    InstPlayNotSuccess = 300108,
    InstPlayAlreadyGetReward = 300109,
    InstPlayExchangeRewardFail = 300110,
    InstPlaySetterRepeat = 300111,
    InstEntranceNotUnlock = 300112,
    InstEntranceNotOpen = 300113,
    EnterInstLevelNotEnough = 300114,
    EnterInstWorldLevelNotEnough = 300115,
    EnterInstQuestNotEnough = 300116,
    ErrForbidEnterInstInMatch = 300117,
    ErrForbidEnterInstInEnteringOtherWorld = 300118,
    ErrForbidEnterInstInWaitingOtherEnterWorld = 300119,
    ErrEnterInstTypeNotMatch = 300120,
    ErrNotHaveGetRewardCount = 300121,
    ErrInMatching = 300122,
    ErrNotInMatching = 300123,
    ErrNotFindValidMatchServer = 300124,
    ErrNotFindMatchServerPrx = 300125,
    ErrNotHaveMatchTeamInfo = 300126,
    ErrAlreadyConfirmMatchResult = 300127,
    ErrMatchTeamNotInReadyState = 300128,
    ErrMatchRoleNotActive = 300129,
    ErrMatchReadyRepeat = 300130,
    ErrMatchPlayerNotReady = 300131,
    ErrMatchNotHostCanNotKick = 300132,
    ErrMatchNotHostCanNotSetMatching = 300133,
    ErrSetMatchFlagRepeat = 300134,
    ErrPlayerNotInMatchTeam = 300135,
    ErrGetMatchPoolFail = 300136,
    ErrPlayerInMatchPool = 300137,
    ErrPlayerNotInMatchPool = 300138,
    ErrPlayerInMatchTeamCanNotCancel = 300139,
    ErrPlayerIsConfirmResult = 300140,
    ErrNotFindMatchTeam = 300141,
    ErrPlayerIsReadyCanNotChangeRole = 300142,
    ErrNotHostCanNotSetMultRoles = 300143,
    ErrCanNotSetRepeatRole = 300144,
    ErrPlayerNotReadyCanNotCancel = 300145,
    ErrRoleRepeatCanNotReady = 300146,
    ErrBeKickNotInMatchTeam = 300147,
    ErrNotHostCanNotKick = 300148,
    ErrNotHostCanNotSetTeamState = 300149,
    ErrTeamMatchingCanNotStartInst = 300150,
    ErrMatchTeamHavePlayerNotReady = 300151,
    ErrNotHostCanNotEnterInst = 300152,
    ErrMatchTeamIsNotEnterInstState = 300153,
    ErrMatchInstIdNotExist = 300154,
    ErrSingleInstanceCanNotMatch = 300155,
    ErrOnlineStateCanNotMatch = 300156,
    ErrTeamHaveSameRoleCanNotBegin = 300157,
    ErrNotJoinChatChannel = 300158,
    ErrChatChannelNotFound = 300159,
    ErrChatChannelTypeNotMatch = 300160,
    ErrChatContentTooLong = 300161,
    ErrFightRoleIsAllDied = 300162,
    ErrLoadingSceneIdNotMatch = 300163,
    ErrLoadingPlayerNotInScene = 300164,
    ErrPlayerIsSceneLoadingCanNotBeKick = 300165,
    ErrTeamPlayerIsSceneLoadingCanNotDissolve = 300166,
    ErrIsSceneLoadingCanNotDissolve = 300167,
    ErrSceneLoadingCanNotEnterInst = 300168,
    ErrActivateResetPointNotEntity = 300169,
    ErrHostIsLoadingScene = 300170,
    ErrHostIsLoadingSceneCanNotApply = 300171,
    ErrIsLoadingSceneCanNotAcceptApply = 300172,
    ErrNotFindHostWorldScene = 300173,
    ErrCanNotRepeatCreateNeedSaveScene = 300174,
    DeadStateCanNotAgreeOherEnter = 300175,
    HostIsDeadStateCanNotEnter = 300176,
    ErrSceneIsLoadingCanNotLeave = 300177,
    ErrInstCanNotReChallenge = 300178,
    ErrInstMemberNotEnoughCanNotReChallenge = 300179,
    ErrInstHavePlayerLeaveCanNotReChallenge = 300180,
    ErrInstHavePlayerNotDeadCanNotReChallenge = 300181,
    ErrInstNotSettleCanNotReChallenge = 300182,
    ErrInstCanNotRepetApplyRechallenge = 300183,
    ErrInstCanNotRepetReceiveRechallenge = 300184,
    ErrInstOwnerCanIniviteRechallenge = 300185,
    ErrInstOwnerCanNotReceiveRechallenge = 300186,
    ErrPlayerIsLogoutCanNotCreateScene = 300187,
    ErrPlayerIsCreatingScene = 300188,
    ErrPlayerCreateSceneFail = 300189,
    ErrBigWorldCanNotReset = 300190,
    ErrMultiGameModeCanNotReset = 300191,
    ErrIsEnterSceneApplyingCanNotDoRepeate = 300192,
    ErrIsQueryLobbyFriendDetailCanNotDoRepeate = 300193,
    ErrIsQueryLobbyPlayerDetailCanNotDoRepeate = 300194,
    ErrPlayerIsLoadingCanNotDoTeleport = 300195,
    ErrPlayerIsTeleportCanNotDoTeleport = 300196,
    ErrTeleportPositionIllegal = 300197,
    ErrPlayerIsLoadingCanNotRevive = 300198,
    ErrPlayerIsTeleportCanNotRevive = 300199,
    ErrPlayerIsInTeleportCanNotBeKick = 300200,
    ErrTeamPlayerIsInTeleportCanNotDissolve = 300201,
    ErrHostIsInTeleportCanNotApply = 300202,
    ErrIsInTeleportCanNotAcceptApply = 300203,
    ErrStrNotIllegal = 400000,
    ErrBasicInfoPhotoUnlocked = 400001,
    ErrBasicInfoFrameUnlocked = 400002,
    ErrCanNotGetSelfBasicInfo = 400003,
    ErrMailNotExist = 400004,
    ErrMailAlreadyRead = 400005,
    ErrNoMailCanGet = 400006,
    ErrMailNoAttachment = 400007,
    ErrMailAttachmentIsGet = 400008,
    ErrMailAttachmentNotGet = 400009,
    ErrMailNotRead = 400010,
    ErrNoMailCanDelete = 400011,
    ErrMailItemBagFull = 400012,
    ErrMailFuncNotOpen = 400013,
    ErrMailOverSize = 400014,
    ErrMailTakeLimit = 400015,
    ErrMailAttachmentItemInvalidCount = 400016,
    ErrMailAttachmentItemNoConf = 400017,
    ErrMailNoConf = 400018,
    ErrShopIdNotExit = 400019,
    ErrShopInfoExist = 400020,
    ErrShopTimeLimit = 400021,
    ErrShopMoneyId = 400022,
    ErrShopNumLimit = 400023,
    ErrShopCondLimit = 400024,
    ErrShopBankNoExit = 400025,
    ErrShopNoShow = 400026,
    ErrShopVersion = 400027,
    ErrShopIlligalParam = 400028,
    ErrDragonPoolConf = 400029,
    ErrFullLevel = 400030,
    ErrItemConf = 400031,
    ErrNotEnoughItem = 400032,
    NotMingSuTi = 400033,
    HadFinishMingSuTi = 400034,
    MingSuCallEntityFail = 400035,
    ErrDragonPoolFuncNotOpen = 400036,
    ErrWorldLevelHadDown = 400037,
    ErrWorldLevelNotDown = 400038,
    ErrWorldLevelMin = 400039,
    ErrWorldLevelCd = 400040,
    ErrIsBlockedPlayer = 400041,
    ErrIsNotBlockedPlayer = 400042,
    ErrBlockListCountMax = 400043,
    ErrYouAreBlocked = 400044,
    ErrAlreadyOnFriendList = 400045,
    ErrNotOnFriendList = 400046,
    ErrAlreadyOnFriendApplyList = 400047,
    ErrFriendApplyNotExists = 400048,
    ErrFriendListCountMax = 400049,
    ErrInitiatorFriendListCountMax = 400050,
    ErrReceiverApplyListCountMax = 400051,
    ErrCanNotFriendApplySendToSelf = 400052,
    ErrFriendApplySended = 400053,
    ErrFriendRemarkLengthLimit = 400054,
    ErrFriendApplyRequestLimit = 400055,
    ErrFriendRequestEmpty = 400056,
    ErrFriendRequestOverSize = 400057,
    ErrPayShopNotExists = 400058,
    ErrPayShopDisabled = 400059,
    ErrPayShopGoodsNotExists = 400060,
    ErrPayShopGoodsDisabled = 400061,
    ErrPayShopGoodsLocked = 400062,
    ErrPayShopGoodsOutSellTime = 400063,
    ErrPayShopGoodsBuyLimit = 400064,
    ErrPayShopDataChanged = 400065,
    ErrPayShopIllegalBuyCount = 400066,
    ErrPayShopIsDirect = 400067,
    ErrPayShopIsNotDirect = 400068,
    ErrPayShopTabDisabled = 400069,
    ErrMonthCardWithoutValidity = 400070,
    ErrMonthCardUpdateConfNotExist = 400071,
    ErrMonthCardDaysMax = 400072,
    ErrMonthCardRewardGot = 400073,
    ErrMonthCardConfNotExist = 400074,
    ErrIsNotSpecialItem = 400075,
    ErrNoEquipSpecialItem = 400076,
    ErrNoValidBattlePass = 400077,
    ErrBattlePassRewardNotFound = 400078,
    ErrBattlePassNotPaid = 400079,
    ErrBattlePassIsPaid = 400080,
    ErrBattlePassRewardLocked = 400081,
    ErrBattlePassRewardTaken = 400082,
    ErrBattlePassCanNotRepeatActive = 400083,
    BattlePassNoRecurringReward = 400084,
    ErrBattlePassIsAdvanced = 400085,
    ErrBattlePassTaskNotFound = 400086,
    ErrBattlePassTaskNotFinished = 400087,
    ErrBattlePassTaskTaken = 400088,
    ErrBattlePassExpIsFull = 400089,
    ErrAdviceNotFound = 400090,
    ErrConjunctionCanNotWord = 400091,
    ErrAdviceTextNotExists = 400092,
    ErrAdviceWordNotExists = 400093,
    ErrAdviceTemplateNotExists = 400094,
    ErrAdviceCellCalcException = 400095,
    ErrIsNotAdviceEntity = 400096,
    ErrAdviceCreateLimit = 400097,
    ErrAdviceContentCanNotEmpty = 400098,
    ErrAdviceEntityNotFount = 400099,
    ErrAdviceVoteLimit = 400100,
    ErrAdviceIsVoteUp = 400101,
    ErrAdviceIsVoteDown = 400102,
    ErrNoAdviceItem = 400103,
    ErrAdviceCreateNotOpen = 400104,
    ErrAdviceCanNotCreateByVisitor = 400105,
    ErrAdviceSetingIsShow = 400106,
    ErrAdviceSetingIsNoShow = 400107,
    ErrAdviceUpMaxValue = 400108,
    ErrAdviceDownMaxValue = 400109,
    ProtoVersionCheckFail = 400110,
    ProtoMd5CheckFail = 400111,
    ConfigVersionCheckFail = 400112,
    ConfigMd5CheckFail = 400113,
    ErrInvalidMonthCardDays = 400114,
    ErrMonthCardExtendedDaysMax = 400115,
    ErrMobileButtonNoCfg = 400116,
    ErrMoneyWrongPayCount = 400117,
    ErrMailTextSenderNotFound = 400118,
    ErrMailTextTitleNotFound = 400119,
    ErrMailTextContentNotFound = 400120,
    ErrAdviceIsNotVoteUp = 400121,
    ErrParkourChallengeNoConf = 400122,
    ErrParkourLocationNoConf = 400123,
    ErrParkourChallengeNotOpen = 400124,
    ErrParkourChallengeNoData = 400125,
    ErrParkourChallengeTaken = 400126,
    ErrParkourChallengeUnderscore = 400127,
    ErrParkourChallengeScoreNoConf = 400128,
    ErrParkourTakeFail = 400129,
    ErrShopIllegalBuyCount = 400130,
    ErrQuestErrTaskId = 500000,
    ErrQuestErrStepId = 500001,
    ErrQuestErrTaskBag = 500002,
    ErrQuestStepStatusNotCanAccept = 500003,
    ErrQuestStepStatusNotCanCommit = 500004,
    ErrQuestStepConf = 500005,
    ErrQuestStepData = 500006,
    ErrQuestCanNotAccept = 500007,
    ErrAreaQuestDelegationBoardRequest = 500008,
    ErrAreaQuestAreaIdErr = 500009,
    ErrAreaQuestExpired = 500010,
    ErrDevoteLevel = 500011,
    ErrDevoteRewardReceived = 500012,
    ErrQuestNotFinish = 500013,
    ErrDevoteId = 500014,
    ErrAreaQuestLimit = 500015,
    ErrQuestNodeNotActive = 500016,
    ErrQuestNotActiveId = 500017,
    ErrQuestNodeNotFound = 500018,
    ErrQuestComNotFound = 500019,
    ErrQuestTraceType = 500020,
    ErrQuestNotProgress = 500021,
    ErrQuestNoCombatState = 500022,
    ErrQuestNodeData = 500023,
    ErrQuestNotChildQuestNode = 500024,
    ErrQuestNotClientSubmit = 500025,
    ErrQuestAccepted = 500026,
    ErrResourceOccupation = 500027,
    ErrRequestOccupationType = 500028,
    ErrNotFoundOccupation = 500029,
    ErrNotOnlineQuestAccept = 500030,
    ErrQuestDestroy = 500031,
    ErrTreeNodeNotFind = 500032,
    ErrTreeNodeNotActive = 500033,
    ErrIsNotChildQuestNode = 500034,
    ErrChildQuestConditionCanNotSubmit = 500035,
    ErrNodeNotFindAction = 500036,
    ErrNodeActionIsFinish = 500037,
    ErrNodeActionGetItemIsNotQuestItem = 500038,
    ErrNodeActionGetItemHasNotFreeSize = 500039,
    ErrInvalidBtType = 500040,
    ErrTimerNotFind = 500041,
    ErrPreCondition = 500042,
    ErrHandIdItemData = 500043,
    ErrTreeNotFailedNode = 500044,
    ErrTreeNotFailConf = 500045,
    ErrTreeNotGiveUpConf = 500046,
    ErrTreeNotRollback = 500047,
    ErrNodeNotFindNpcId = 500048,
    ErrNotRollbackPermission = 500049,
    ErrNotRollbackRepeat = 500050,
    ErrTreeSuspend = 500051,
    ErrPlayerNotInQuestMap = 500052,
    ErrSaveNewNotRollback = 500053,
    ErrUiPlayType = 500054,
    ErrOccupationTime = 500055,
    ErrReleaseTime = 500056,
    ErrActionSetTime = 500057,
    ErrForcedOccupationResource = 500058,
    ErrAddPlayBubble = 500059,
    ErrDisableSwitchOccupation = 500060,
    ErrOpenSystemBoardResultFail = 500061,
    ErrEntityNoInhaledComponent = 500062,
    ErrEntityInhaledStrength = 500063,
    ErrDisableSwitchGender = 500064,
    ErrTapeDefault = 600000,
    ErrTapeInvalidPos = 600001,
    ErrTapeIsNotActiveRole = 600002,
    ErrTapeItemTypeFail = 600003,
    ErrTapeNotExistTapeItem = 600004,
    ErrTapeNotExistTapeConfig = 600005,
    ErrTapeNotExistTapeProps = 600006,
    ErrTapeHasTakeOnTape = 600007,
    ErrTapeHasNotTakeOnTape = 600008,
    ErrTapeNotExistTapeQualityConfig = 600009,
    ErrTapeNotExistLevelUpExpConfig = 600010,
    ErrTapeInvalidLevelUpExpValue = 600011,
    ErrTapeNotExistExpDecayRatioConfig = 600012,
    ErrTapeLevelUpEqualItem = 600013,
    ErrTapeLevelUpRepeatItem = 600014,
    ErrTapeLevelUpInvalidExpItemNum = 600015,
    ErrTapeLevelUpInvalidExpRate = 600016,
    ErrTapeLevelUpInvalidAddExp = 600017,
    ErrTapeLevelUpMaxLevel = 600018,
    ErrTapeLevelUpConsumeItemNotEnough = 600019,
    ErrTapeLevelUpMaterialLock = 600020,
    ErrTapeTransferEqualItem = 600021,
    ErrTapeTransferQualityNotEqual = 600022,
    ErrTapeTransferSuitNotEqual = 600023,
    ErrTapeTransferMaterialLock = 600024,
    ErrTapeTransferMaterialEquipped = 600025,
    ErrTapeNotExistTransferPropNumConfig = 600026,
    ErrTapeTransferPropNumIsMax = 600027,
    ErrTapeTransferRandomSubPropFail = 600028,
    ErrTapeResetTransferHasNotProp = 600029,
    ErrTapeResetTransferMaterialNotEnough = 600030,
    ErrTapeNotExistTapeExpItem = 600031,
    ErrTapeNotExistTapeExpItemConfig = 600032,
    ErrCollectEntityNotExist = 600033,
    ErrCollectInvalidEntityMainType = 600034,
    ErrRunningLevelPlayNotFind = 600035,
    ErrLevelPlayInteractionEntity = 600036,
    ErrLevelPlayNotExistByConfId = 600037,
    ErrLevelPlayNotCreate = 600038,
    ErrLevelPlayRewarded = 600039,
    ErrLevelPlayInteractionType = 600040,
    ErrLevelPlayNotPlayer = 600041,
    ErrLevelPlayNotComplete = 600042,
    ErrLevelPlayRewardFail = 600043,
    ErrLevelPlayNotWaitState = 600044,
    ErrLevelPlayAction = 600045,
    ErrLevelPlayGetRewardLimit = 600046,
    ErrFlowNotExist = 600047,
    ErrFlowHaveNotActionWait = 600048,
    ErrFlowHaveNotTalkWait = 600049,
    ErrFlowHaveNotOptionWait = 600050,
    ErrFlowInvalidOptionId = 600051,
    ErrInteractFlowCanNotPlay = 600052,
    ErrInteractInvalidFlowState = 600053,
    ErrInteractOptionOwnerIsNotFlowOwner = 600054,
    ErrInteractOptionOwnerIsNotActionOwner = 600055,
    ErrActionOwnerIsNotEntity = 600056,
    ErrActionOwnerNotFound = 600057,
    ErrActionSceneNotFound = 600058,
    ErrActionGroupNotFound = 600059,
    ErrFinishClientActionFail = 600060,
    ErrActionHostPlayerNotFound = 600061,
    ErrActionFail = 600062,
    ErrActionPlayerNotFound = 600063,
    ErrInteractMultiGameMode = 600064,
    ErrInteractAddFlowFail = 600065,
    ErrBehaviorTreeOwnerNotFound = 600066,
    ErrBehaviorTreeNotFound = 600067,
    ErrBehaviorTreePending = 600068,
    ErrBehaviorTreeTimerTypeNotFound = 600069,
    ErrBehaviorTreeStopTimerFail = 600070,
    ErrBehaviorTreeTimerCompNotFound = 600071,
    ErrInteractCd = 600072,
    ErrInteractRange = 600073,
    ErrDropPickRange = 600074,
    ErrBtTmpItemContextNotExist = 600075,
    ErrBtTmpItemBtObjNotExist = 600076,
    ErrPlayerBigWorldNotExist = 600077,
    ErrRoleEntityNotExist = 600078,
    ErrAddFlowFail = 600079,
    ErrInteracting = 600080,
    ErrInteractCollectBagFull = 600081,
    ErrBtObjIsNotInstPlay = 600082,
    ErrReviveConfigNotExist = 600083,
    ErrFinishFlowFail = 600084,
    ErrFlowActionFail = 600085,
    ErrGmSubmitChildQuestNodeMaxDepth = 600086,
    ErrGmSubmitChildQuestNodeIsNotProgress = 600087,
    ErrEntityPatrolComponentNotExist = 600088,
    ErrInteractIsNotParticipant = 600089,
    ErrVisionEntityInteractFail = 600090,
    ErrMaxDropTimes = 600091,
    ErrStateEntityMultiHang = 600092,
    ErrPlayerLoading = 600093,
    ErrPlayerTeleporting = 600094,
    ErrInteractBtPending = 600095,
    ErrInteractDead = 600096,
    ErrMultiHangEntity = 600097,
    ErrRenjuCanNotResetWhenComplete = 600098,
    ErrRenjuCanNotMove = 600099,
    ErrEntityNotFound = 600100,
    ErrSceneHostPlayerNotMatch = 600101,
    ErrVehicleComponentNotFound = 600102,
    ErrVehicleSeatNotFound = 600103,
    ErrVehicleGettingOn = 600104,
    ErrPortalEntityNotFound = 600105,
    ErrPortalCompNotFound = 600106,
    ErrPortalTeleportPosNotEqual = 600107,
    ErrPlayerNotInVehicle = 600108,
    ErrVehiclePassengerRoleExist = 600109,
    ErrCreateVehiclePassengerEntityFail = 600110,
    ErrVehiclePassengerNotFound = 600111,
    ErrCanNotMovePlacement = 600112,
    ErrGmSetLimitTeleportDungeon = 600113,
    ErrMaxSetTagIdDepth = 600114,
    ErrBeforeSetStateTagId = 600115,
    ErrSetStateTagIdLock = 600116,
    ErrDangoMonopolyActivityDataNotFound = 600117,
    ErrDangoMonopolyReqTaskRewardMax = 600118,
    ErrDangoMonopolyTaskConfigNotFound = 600119,
    ErrDangoMonopolyTaskNotCompleted = 600120,
    ErrDangoMonopolyTaskRewardHasGet = 600121,
    ErrDangoMonopolyBoardConfigNotFound = 600122,
    ErrDangoMonopolyGridRewardNotGet = 600123,
    ErrDangoMonopolyHasNotDiceItem = 600124,
    ErrDangoMonopolyHasNotGridReward = 600125,
    ErrDangoMonopolyGridConfigNotFound = 600126,
    ErrDangoMonopolyReqBoardRewardMax = 600127,
    ErrDangoMonopolyBoardNotCompleted = 600128,
    ErrDangoMonopolyBoardRewardHasGet = 600129,
    ErrDangoMonopolyActivityConfigNotFound = 600130,
    ErrDangoMonopolyBoardLock = 600131,
    ErrChangeEntityStateActionEntityNotFound = 600132,
    ErrDangoMonopolyDiceNumInvalid = 600133,
    ErrDangoMonopolyBoardCompleted = 600134,
    ErrLevelSequenceFrameEventCompNotFound = 600135,
    ErrLevelSequenceFrameEventDataNotFound = 600136,
    ErrLevelSequenceFrameEventSectionsNotFound = 600137,
    ErrActionCtxInvalid = 600138,
    ErrActionOwnerInvalid = 600139,
    ErrGlobalFixCfgNotFound = 600140,
    ErrActionGetItemIsNotQuestItem = 600141,
    ErrGlobalFixExecuteCountMax = 600142,
    ErrActionGroupCreateTooFrequently = 600143,
    ErrActionGroupParallelTooMuch = 600144,
    ErrCanNotRemoveLastTrialRole = 600145,
    ErrEntityIsNotActivateState = 600146,
    ErrRestoreTrialRoleNotInRegion = 600147,
    ErrRemoveTrialRoleNotExist = 600148,
    ErrRemoveLastTrialRole = 600149,
    ErrSaveNodeDeActiveTrialRoleEmpty = 600150,
    ErrNewHandInItemTypeInvalid = 600151,
    ErrIGameObjectHostIsNotIPlayer = 600152,
    ErrSceneWorldNotExist = 700000,
    ErrPlayerNotInScene = 700001,
    ErrDropEntityNotExist = 700002,
    ErrDropComponentNotExist = 700003,
    ErrDropOwnerError = 700004,
    ErrPlayerAlreadyInScene = 700005,
    ErrSceneIdParseError = 700006,
    ErrJoinSceneIdNotExist = 700007,
    ErrSceneInviteFail = 700008,
    ErrSceneInvitePlayerNotExist = 700009,
    ErrSceneInviteTokenInvalid = 700010,
    ErrSceneInviterNotExist = 700011,
    ErrSceneInviteeIdNotMatch = 700012,
    ErrSceneTeamIsFull = 700013,
    ErrScenePlayerIsInTeam = 700014,
    ErrSceneInviteerIsInPlayeInst = 700015,
    ErrBeKickerNotInScene = 700016,
    ErrorCanNotSceneKickSelf = 700017,
    ErrCanNotKickOtherInPlayInst = 700018,
    ErrCanNotKickOtherWhoIsInPlayInst = 700019,
    ErrNoSceneKickPermission = 700020,
    ErrInviterIsInOtherScene = 700021,
    ErrInOtherSceneCanNotInvite = 700022,
    ErrSceneBackSceneFlagError = 700023,
    ErrLeaveSceneIdNotMatch = 700024,
    ErrPrewarTeamAlreadyExist = 700025,
    ErrPrewarTeamNotExist = 700026,
    ErrCreatePrewarTeamPermissionNotEnough = 700027,
    ErrPrewarTeamInvitePermissionNotEnough = 700028,
    ErrPrewarBeInviterNotInScene = 700029,
    ErrPrewarBeInviterInInstance = 700030,
    ErrPlayerAlreadyInPrewarTeam = 700031,
    ErrPlayerNotInPrewarTeam = 700032,
    ErrPlayerSetPrewarReadyStateRepeat = 700033,
    ErrPrewarTeamBeKickerNotInScene = 700034,
    ErrPrewarTeamKickPermissionNotEnough = 700035,
    ErrPrewarIniviteTooFrequently = 700036,
    ErrPrewarJoinInstanceIdNotMatch = 700037,
    ErrPrewarCaptainCanNotLeave = 700038,
    ErrPrewarReadyStateCanNotChangeRole = 700039,
    ErrScenePrewarTeamHavePlayerNotReady = 700040,
    ErrAlreadyInMultiScene = 700041,
    ErrOnlyCaptainCanDissolvePrewarTeam = 700042,
    ErrMultiChangeRoleIndexInvalid = 700043,
    ErrMultiCanNotChangeOtherRole = 700044,
    ErrMultiChangeRoleEntityNorExist = 700045,
    ErrSceneCanNotUseThisFunc = 700046,
    ErrSceneCanNotUseThisItem = 700047,
    ErrSceneFightRoleIdRepeat = 700048,
    ErrShieldAddEntityNotExist = 700049,
    ErrShieldAddShieldIdExisted = 700050,
    ErrShieldChangeEntityNotExist = 700051,
    ErrShieldChangeShieldIdNotExist = 700052,
    ErrShieldRemoveEntityNotExist = 700053,
    ErrShieldRemoveShieldIdNotExist = 700054,
    ErrHardnessModeChangedEntityNotExist = 700055,
    ErrSceneEntityNotExist = 700056,
    ErrSceneEntityNotHavePartData = 700057,
    ErrsceneEntityNotHavePartId = 700058,
    ErrChangeControlRoleRepeat = 700059,
    ErrVisionSkillCallEntityFail = 700060,
    ErrSceneDataLoadError = 700061,
    ErrCreatureDataError = 700062,
    ErrCreatureGenIsExist = 700063,
    ErrCreatureGenIsNotExist = 700064,
    ErrCreatureGenIsControlByOther = 700065,
    ErrCreatureGenNotHaveControlPerm = 700066,
    ErrCreatureReachMaxCount = 700067,
    ErrCreatureConditionNotMatch = 700068,
    ErrCreatureTimeIntervalError = 700069,
    ErrCreatureCfgNotExist = 700070,
    ErrCreatureEntityIsNotValidity = 700071,
    ErrUniqueEntityCanNotCreateTwice = 700072,
    ErrRoleNotHaveVisionSkill = 700073,
    ErrHitGearEntityNotExist = 700074,
    ErrHitGearHaveNotEntityConfig = 700075,
    ErrHitGearHaveNotGearConfig = 700076,
    ErrHitGearHaveNotGameplayConfig = 700077,
    ErrHitGearHaveNotStepConfig = 700078,
    ErrHitGearHaveEntityCommonTag = 700079,
    ErrHitGearEntityFunctionTypeFail = 700080,
    ErrHitGearAcceptStepFail = 700081,
    ErrCreateInstanceNotContainEntrance = 700082,
    ErrCreateInstanceHaveNotEntranceConfig = 700083,
    ErrCreateInstanceEntranceLock = 700084,
    ErrCreateInstanceHaveNotConfig = 700085,
    ErrCreateInstanceEnterCountNotEnough = 700086,
    ErrCreateInstanceConditionNotMatch = 700087,
    ErrEnterCountRequestHaveNotConfig = 700088,
    ErrUnlockInstanceEntranceHaveNotConfig = 700089,
    ErrUnlockInstanceEntranceNotNeedUnlock = 700090,
    ErrUnlockInstanceEntranceUnlocked = 700091,
    ErrUnlockInstanceEntranceCondiitonNotMatch = 700092,
    ErrEnterSceneGameplayRequestHaveNotConfig = 700093,
    ErrEnterSceneGameplayRequestAccepted = 700094,
    ErrEnterSceneGameplayRequestAcceptFail = 700095,
    ErrStoryCharacterCreatFail = 700096,
    ErrStoryCharacterCreatRepeat = 700097,
    ErrStoryCharacterNotExist = 700098,
    ErrCheckGearEntityNotExist = 700099,
    ErrCheckGearType = 700100,
    ErrCheckGearNotEntityConfig = 700101,
    ErrCheckGearActive = 700102,
    ErrCheckGearInactive = 700103,
    ErrTargetGearGroupEntityNotExist = 700104,
    ErrTargetGearGroupConfigNotExist = 700105,
    ErrTargetGearEntityNotExist = 700106,
    ErrTargetGearConfigNotExist = 700107,
    ErrTargetGearStartTypeIsNotHit = 700108,
    ErrTargetGearStartTypeIsNotAction = 700109,
    ErrTargetGearStarted = 700110,
    ErrTargetGearFinished = 700111,
    ErrTargetGearIsNotInCreatedConsole = 700112,
    ErrTargetGearGroupEntityIsNotAllInit = 700113,
    ErrLanternCatNotExit = 700114,
    ErrLanternCatConfNotExit = 700115,
    ErrLanternCatType = 700116,
    ErrLanternActived = 700117,
    ErrLanternTargetNotExit = 700118,
    ErrCaptureFail = 700119,
    ErrDyingFail = 700120,
    ErrThrowDamageEntityNotExit = 700121,
    ErrThrowDamageCalculateId = 700122,
    ErrThrowDamageIdNotExit = 700123,
    ErrThrowDamageRoleIdConf = 700124,
    ErrThrowDamageTypeNotExit = 700125,
    InstIdNotExist = 700126,
    ErrControlObjectEntityNotExist = 700127,
    ErrControlObjectConfigNotExist = 700128,
    ErrControlGroupConfigNotExist = 700129,
    ErrControlObjectLocked = 700130,
    ErrControlGroupLocked = 700131,
    ErrControlCanNotPutTarget = 700132,
    ErrControlTargetOccupied = 700133,
    ErrControlObjectCatching = 700134,
    ErrControlObjectNotCatching = 700135,
    ErrControlObjectOtherCatching = 700136,
    ErrEntityPositionIllegal = 700137,
    ErrTreasureBoxNot = 700138,
    ErrTreasureBoxNotInit = 700139,
    ErrTreasureBoxNotConfig = 700140,
    ErrTreasureBoxHadReward = 700141,
    ErrTreasureBoxNotInteraction = 700142,
    ErrTreasureBoxNotDropId = 700143,
    ErrTreasureBoxDropErr = 700144,
    ErrTreasureBoxNotExist = 700145,
    ErrTreasureBoxInvalidTag = 700146,
    ErrTreasureBoxHadTag = 700147,
    ErrTreasureBoxNotTag = 700148,
    ErrSneakGameNotOpen = 700149,
    ErrSneakFinishRepeat = 700150,
    ErrClientControlDamage = 700151,
    ErrSceneDataSaveFail = 700152,
    NotInFbInstance = 700153,
    GMErrCanNotCreateWorldInst = 700154,
    GMErrPlayerAlreadyInFbInst = 700155,
    GMErrTagetInstanceIsNotMulti = 700156,
    GMErrPlayerNotFound = 700157,
    ErrEntityFlowTooMuch = 700158,
    GmErrIsWalkable = 700159,
    GmErrIsNotWalkable = 700160,
    GmErrNoNavmesh = 700161,
    ErrBigWorldInstIdNotExist = 700162,
    ErrInstIdNotBigWorld = 700163,
    ErrInInstanceNotSwitchBigWorld = 700164,
    ErrAlreadyInThisBigWorld = 700165,
    ErrNoPermissionGetTreasureBox = 700166,
    ErrCreateBigWorldRepeat = 700167,
    DebugErrInstIdNotExist = 700168,
    ErrSceneAiStopped = 700169,
    ErrGlobalEntityConfigNotExist = 700170,
    ErrSceneFixedConfigNotExist = 700171,
    ErrSceneFixedEntityNotFound = 700172,
    ErrSceneGlobalEntityNotFount = 700173,
    ErrEntityNotHaveVarComponent = 700174,
    ErrEntityVarNameNotExist = 700175,
    ErrEntityVarTypeError = 700176,
    ErrEntityConfigNotOffer = 700177,
    ErrConfigTypeNotGloabl = 700178,
    ErrConfigTypeNotSceneFixed = 700179,
    ErrConfigTypeNotCharacter = 700180,
    ErrEntityPosNotOffer = 700181,
    ErrSceneCellPosNotFount = 700182,
    ErrEntityCongigNotInSleep = 700183,
    ErrSummonCfgNotFound = 700184,
    ErrSummonAddEntityFail = 700185,
    ErrSummonMaxCount = 700186,
    ErrSummonMaxGenerations = 700187,
    ErrSummonEntityIdAlreadyExist = 700188,
    ErrSummonerEntityType = 700189,
    ErrEntityStatusIsNotDead = 700190,
    ErrEntityNotHaveAttributeComp = 700191,
    ErrEntityDbData = 700192,
    ErrSceneFixedEntityCreated = 700193,
    ErrInvalidAwakeEntityContext = 700194,
    ErrTriggerComponentNotExist = 700195,
    ErrTriggerComponentMaxCount = 700196,
    ErrNotSelfRole = 700197,
    ErrNoControlRights = 700198,
    ErrEntityHaveNotEntityOwner = 700199,
    ErrEntityOwnerNotMatch = 700200,
    ErrCreateSceneFixedEntitiesEmpty = 700201,
    ErrInteractComponentNotExist = 700202,
    ErrInteractOptionIndexInvalid = 700203,
    ErrOnlineInteractNoPermission = 700204,
    ErrOnlineInteractNotOpen = 700205,
    ErrAwakeEntityNoPermission = 700206,
    ErrCannotUseSkillStatus = 700207,
    ErrInteractOptionGuidInvalid = 700208,
    ErrAddInteractOptionFail = 700209,
    ErrRemoveInteractOptionFail = 700210,
    ErrInteractOptionOwnerNotFound = 700211,
    ErrSummonPlayerId = 700212,
    ErrSummonTemplateCfgNotFound = 700213,
    ErrAttributeComponent = 700214,
    ErrAnimFsmComponent = 700215,
    ErrStateComponent = 700216,
    ErrBattleComponent = 700217,
    ErrPartComponent = 700218,
    ErrAiControlComponent = 700219,
    ErrSummonsComponent = 700220,
    ErrAiBlackboardComponent = 700221,
    ErrSetVarInvalidContext = 700222,
    ErrSetVarInvalidVarRefPb = 700223,
    ErrSetVarGetRightVarDefineFail = 700224,
    ErrSetVarSetLeftVarDefineFail = 700225,
    ErrCalcVarInvalidContext = 700226,
    ErrCalcVarInvalidVarRef = 700227,
    ErrCalcVarGetVarDefineFail = 700228,
    ErrCalcVarInvalidVarType = 700229,
    ErrCalcVarInvalidOp = 700230,
    ErrCalcVarSetResultFail = 700231,
    ErrActionEntityNoExist = 700232,
    ErrActionNoInteractConfig = 700233,
    ErrActionIdNoExist = 700234,
    ErrActionBtObjNoExist = 700235,
    ErrActionNodeNoExist = 700236,
    ErrActionNoChildQuest = 700237,
    ErrActionParams = 700238,
    ErrActionNotEntityContext = 700239,
    ErrActionExecutorNotFind = 700240,
    ErrActionSessionNotFind = 700241,
    ErrActionCreateSessionIdFail = 700242,
    ErrActionPathConvertFail = 700243,
    ErrActionConfigNotFind = 700244,
    ErrActionHaveNotHandler = 700245,
    ErrActionInternalError = 700246,
    ErrActionInvalidIndex = 700247,
    ErrActionIsNotServer = 700248,
    ErrActionRemainActionNotFinish = 700249,
    ErrActionExecutorIsNotBlackbard = 700250,
    ErrContinuityActionNotFinish = 700251,
    ErrActionIsNotContinuity = 700252,
    ErrResetLocationEntityNotExist = 700253,
    ErrEntityPosAbnormalNotExists = 700254,
    ErrGmRemoveEntityNotExists = 700255,
    ErrDrownEntityNotExists = 700256,
    ErrTargetGearNotExists = 700257,
    ErrOutofBattleEntityNotExists = 700258,
    ErrOrderAddBuffEntityNotExists = 700259,
    ErrOrderRemoveBuffEntityNotExists = 700260,
    ErrActivateBuffEntityNotExists = 700261,
    ErrToughCalcExtraRatioChangeEntityNotExists = 700262,
    ErrAdsorbEntityNotExist = 700263,
    ErrAdsorbCondNotMeet = 700264,
    ErrTimelineTrackMultiGameForbid = 700265,
    ErrTimelineTraceEntityNotExists = 700266,
    ErrTimelineTraceComponentNotExists = 700267,
    ErrTimelineTraceGroupIndex = 700268,
    ErrTimelineTraceFinish = 700269,
    ErrTimelineTraceCondition = 700270,
    ErrTimelineTraceTargetEmpty = 700271,
    ErrTimelineTraceControl = 700272,
    ErrTimelineTraceFinishCondition = 700273,
    ErrTimelineTraceNotInControl = 700274,
    ErrForbidEnterInstance = 700275,
    ErrForbitEnterBigWorld = 700276,
    ErrPrefabIncIdExist = 700277,
    ErrPrefabIdExist = 700278,
    ErrPrefabNumberIsZero = 700279,
    ErrPrefabEntityIsExist = 700280,
    ErrPrefabTreasureBox = 700281,
    ErrPrefabActionCreate = 700282,
    ErrPrefabVarNoExist = 700283,
    ErrClientOnlyEntityCantCreate = 700284,
    ErrTimelineTraceActionRun = 700285,
    ErrGmActivateTeleportSceneNotExist = 700286,
    ErrGmCreateInstSceneHasExist = 700287,
    ErrVfxNpcNotExist = 700288,
    ErrVfxNpcIsNotVfxNpc = 700289,
    ErrBlackboardLimit = 700290,
    ErrBlackboardArrayLimit = 700291,
    ErrBlackboardStringLimit = 700292,
    ErrReconnectGWGetGatePlayerFailed = 800000,
    ErrGWReconnectGWInvalidPlayerState = 800001,
    ErrGWReconnectGWVerifyTokenFailed = 800002,
    ErrGWReconnectGWBackOnlineAsyncFailed = 800003,
    ErrGWReconnectGWBackOnlineAsyncException = 800004,
    ErrReconnectGwclientLatestSeqNoNotHit = 800005,
    ErrGWReconnectConfirmGetPlayerFailed = 800006,
    ErrAttrChangeHandleInvalidClientAction = 800007,
    ErrThrowDamageReqGetStateComponentFailed = 800008,
    ErrThrowDamageReqEntityIsAlreadyDead = 800009,
    ErrAnimalDieRequestForceSetDieError = 800010,
    ErrCollectEntityForceSetEntityDieError = 800011,
    ErrMonsterBoomForceSetDieError = 800012,
    ErrAttrChangeReqReplaceAttrListFailed = 800013,
    ErrReconnectInvalidOperation = 800014,
    ErrReconnectGwNodeTainted = 800015,
    ErrFavorRoleNotFound = 900000,
    ErrFavorConfNotFound = 900001,
    ErrFavorQuestNotFound = 900002,
    ErrFavorLevelRewardLimit = 900003,
    ErrFavorQuestAcceptLimit = 900004,
    ErrFavorItemLocked = 900005,
    ErrFavorItemHasUnLocked = 900006,
    ErrElevatorEntityNotExit = 900007,
    ErrElevatorConfigNotExit = 900008,
    ErrElevatorLocked = 900009,
    ErrElevatorIsNotReverse = 900010,
    ErrElevatorIsNotForward = 900011,
    ErrElevatorIsNotStart = 900012,
    ErrElevatorIsNotEnd = 900013,
    ErrElevatorFloorError = 900014,
    ErrHostRefuse = 900015,
    ErrHostOffline = 900016,
    ErrHostHasOnline = 900017,
    ErrHostPlayerMax = 900018,
    ErrHostRefuseStrangers = 900019,
    ErrHostForbidJoin = 900020,
    ErrHostTemporarilyForbidJoin = 900021,
    ErrSlaveInBlockList = 900022,
    ErrExceedJoinLevelDiff = 900023,
    ErrHostNotOpenOnlineFunc = 900024,
    ErrHostInOtherPlayer = 900025,
    ErrHostInForbidOnlineQuest = 900026,
    ErrSlaveHasOnline = 900027,
    ErrSlaveInForbidOnlineQuest = 900028,
    ErrSlaveNotOpenOnlineFunc = 900029,
    ErrSlaveApplyRepeated = 900030,
    ErrSlaveTryApplySelf = 900031,
    ErrLobbyTryQuerySelf = 900032,
    ErrSlaveRequestExpired = 900033,
    ErrEnterringOtherScene = 900034,
    ErrWaitingOtherJoin = 900035,
    ErrWaitListFull = 900036,
    ErrAlreayInWaitEnterList = 900037,
    ErrHostNotInBigWorld = 900038,
    ErrPlayerNotInBigWorld = 900039,
    ErrPlayerNotInWaitList = 900040,
    ErrForbidOperaInMatching = 900041,
    ErrLobbyNotFoundPlayer = 900042,
    ErrRoleTrailCannotOnline = 900043,
    ErrHostRoleTrail = 900044,
    ErrInMatchingCanNotJoinOther = 900045,
    ErrInMatchCanNotBeApply = 900046,
    ErrInMatchCanNotAcceptApply = 900047,
    ErrSlaveInFlow = 900048,
    ErrHostInFlow = 900049,
    ErrAchievementNotClinet = 900050,
    ErrTriggerConditionNotMet = 900051,
    ErrNpcTraceNotConf = 900052,
    ErrBuffProducerConfNotFound = 900053,
    ErrBuffProducerHasDone = 900054,
    ErrBuffConsumerConfNotFound = 900055,
    ErrBuffConsumerBuffNotFound = 900056,
    ErrBuffConsumerEntityNotFound = 900057,
    ErrItemPosInvaild = 900058,
    ErrItemIdInvaild = 900059,
    ErrRouletteFuncIdInvaild = 900060,
    ErrStateIsRunning = 900061,
    ErrSceneEntityNotFind = 900062,
    ErrActionPlayersIsEmpty = 900063,
    ErrFireBulletNoLauncher = 900064,
    ErrFireBulletNoTarget = 900065,
    ErrTurntableConfigNotFound = 900066,
    ErrTurntableActivityNotOpen = 900067,
    ErrTurntableActivityIsFinish = 900068,
    ErrTurntableActivityQuestNotFinish = 900069,
    ErrTurntableActivityRoundConfigNotFound = 900070,
    ErrEnrichmentAreaIsEmpty = 900071,
    ErrEnrichmentAreaNotFind = 900072,
    ErrEnrichmentAreaInCD = 900073,
    ErrEnrichmentAreaInFog = 900074,
    ErrEntityWalkingPoint = 900075,
    ErrServerConfigReload = 900076,
    ErrAreaCheckFailed = 900077,
    ErrHostSceneBlockSplitFail = 900078,
    ErrSlaveSceneBlockSplitFail = 900079,
    ErrHookLockBatchCollectMaxCount = 900080,
    ErrHookLockBatchCollectFail = 900081,
    ErrEntityPackIdErr = 900082,
    ErrEntityInQuickHackSkill = 900083,
    ErrEntityQuickHackSkillNoAction = 900084,
    ErrVehicleInPhantomFormation = 900085,
    ErrBuffItemConfig = 1000000,
    ErrBuffItemNotShare = 1000001,
    ErrBuffItemShareRoleId = 1000002,
    ErrBuffItemRoleIdNotExist = 1000003,
    ErrBuffItemNotEnough = 1000004,
    ErrBuffItemMultiUse = 1000005,
    ErrBuffItemCdLimit = 1000006,
    ErrBuffItemNumZero = 1000007,
    ErrBuffItemNotPlayer = 1000008,
    ErrSceneItemNotExit = 1000009,
    ErrSceneItemType = 1000010,
    ErrSceneItemOperate = 1000011,
    ErrSceneItemState = 1000012,
    ErrStateEntityNoExit = 1000013,
    ErrStateEntityNotTagComp = 1000014,
    ErrStateEntityTypeNotExit = 1000015,
    ErrStateEntityStateNotExit = 1000016,
    ErrStateEntityNotConfig = 1000017,
    ErrStateEntityStateType = 1000018,
    ErrStateEntityStateNoChange = 1000019,
    ErrStateEntitySilent = 1000020,
    ErrStateEntityComplete = 1000021,
    ErrStateEntityLock = 1000022,
    ErrStateEntityNotBorn = 1000023,
    ErrStateNameNoExit = 1000024,
    ErrStateInBorn = 1000025,
    ErrStateCondition = 1000026,
    ErrStateNotOwner = 1000027,
    ErrChangeSelfStateObjNotEntity = 1000028,
    ErrFoundationNotExists = 1000029,
    ErrTeleControlNotExists = 1000030,
    ErrFoundationNotComponent = 1000031,
    ErrFoundationActived = 1000032,
    ErrFoundationUnActived = 1000033,
    ErrFoundationNotMatch = 1000034,
    ErrFoundationNotInRange = 1000035,
    ErrFoundationNotStateId = 1000036,
    ErrGravityGearNotExists = 1000037,
    ErrGravityGearNotConfig = 1000038,
    ErrGravityGearForbidReset = 1000039,
    ErrFollowTrackEntityNoExist = 1000040,
    ErrFollowTrackNotComp = 1000041,
    ErrFollowTrackNotFoundationId = 1000042,
    ErrFollowTrackNotFoundation = 1000043,
    ErrFollowTrackActiveed = 1000044,
    ErrThrowPlayerNotExit = 1000045,
    ErrAnimalEntityNotExist = 1000046,
    ErrNotAnimalEntity = 1000047,
    ErrSneakBtObjNotExist = 1000048,
    ErrSneakNodeIdNotExist = 1000049,
    ErrSneakNotFailedNode = 1000050,
    ErrSneakNotTime = 1000051,
    ErrSneakTime = 1000052,
    ErrInSneak = 1000053,
    ErrNotInSneak = 1000054,
    ErrBeControlledEntityNotExist = 1000055,
    ErrNotBeControlledEntity = 1000056,
    ErrNotBeControlledPlayer = 1000057,
    ErrNotBeControlledNotPlayer = 1000058,
    ErrBeControlledShowEntityNotExist = 1000059,
    ErrNotBeControlledShowEntity = 1000060,
    ErrNotBeControlledShowPlayer = 1000061,
    ErrBeControlledShowNoChange = 1000062,
    ErrGravityGearCondition = 1000063,
    ErrChairEntityNoExist = 1000064,
    ErrChairSitDownErr = 1000065,
    ErrChairEntity = 1000066,
    ErrPlayerAlreadySit = 1000067,
    ErrChairNotStateConfig = 1000068,
    ErrSneakBtObjIncId = 1000069,
    ErrTimelineMove = 1000070,
    ErrBeControlledConfig = 1000071,
    ErrBeControlledThrow = 1000072,
    ErrBeControlledTimeNull = 1000073,
    ErrTriggerEnterActionEffective = 1000074,
    ErrTriggerLeaveActionEffective = 1000075,
    ErrTriggerLastActionStateError = 1000076,
    GuideGroupInfoIsNull = 1100000,
    GuideStateError = 1100001,
    GuideConfigNotFind = 1100002,
    GuideNoEnough = 1100003,
    GuideIsFinish = 1100004,
    GuidePerIsNotFinish = 1100005,
    GuideNoCondition = 1100006,
    GuideNoCurGroup = 1100007,
    GuideIsServerMonitor = 1100008,
    GuideNoPending = 1100009,
    GuideStepRepeat = 1100010,
    GuideGroupNoClient = 1100011,
    GuideGroupDoing = 1100012,
    GuideGroupIsNotRepeat = 1100013,
    GuideTutorialConfigNotFind = 1100014,
    GuideTutorialIsUnlock = 1100015,
    GuideTutorialNotUnlock = 1100016,
    GuideTutorialIsReceive = 1100017,
    GuideTutorialAwardConfigNotFind = 1100018,
    GuideTutorialAwardError = 1100019,
    GuideGroupIdNoMatch = 1100020,
    ErrRequestTypeNotExist = 1100021,
    ErrIllustratedEntryLock = 1100022,
    ErrIllustratedEntryBanUnlock = 1100023,
    ErrRequestTypeMax = 1100024,
    AchievementEntryNotExist = 1100025,
    AchievementEntryNotFinish = 1100026,
    AchievementEntryIsReceive = 1100027,
    AchievementEntryNoConfig = 1100028,
    AchievementEntryNotOpen = 1100029,
    AchievementGroupEntryNotExist = 1100030,
    AchievementGroupEntryNotFinish = 1100031,
    AchievementGroupEntryIsReceive = 1100032,
    AchievementGroupEntryNoConfig = 1100033,
    AchievementGroupEntryNotOpen = 1100034,
    SilentAreaNotConfig = 1100035,
    SilentAreaNotUnlock = 1100036,
    SilentAreaNotFinish = 1100037,
    SilentAreaReceive = 1100038,
    AchievementEntryIsFinish = 1100039,
    AchievementEntryNeedCondition = 1100040,
    AchievementSceneNotFind = 1100041,
    BirthdayIsSetting = 1100042,
    BirthdayInValid = 1100043,
    RoleShowListMaxCount = 1100044,
    RoleShowListHasRepeatId = 1100045,
    RoleShowListHasInValidId = 1100046,
    CardShowListMaxCount = 1100047,
    CardShowListHasRepeatId = 1100048,
    CardShowListHasInValidId = 1100049,
    CardRepeatSet = 1100050,
    CardIsInValidId = 1100051,
    CardIsRead = 1100052,
    RoleShowListEmpty = 1100053,
    SettingNotFind = 1100054,
    RogueRoadConfigNotFind = 1100055,
    RollRogueRoomError = 1100056,
    RollRogueBuffError = 1100057,
    GetRogueRoomIdsError = 1100058,
    GetRoguePortalEntityNotFind = 1100059,
    GetRoguePortalLocationNotFind = 1100060,
    HttpTimeout = 1100061,
    HttpResultUndefine = 1100062,
    ConvGateTimeout = 1100063,
    ProtoKeyTimeout = 1100064,
    LoginReqTimeout = 1100065,
    EnterGameTimeout = 1100066,
    ReReconvReqTimeout = 1100067,
    RecvSeqNoNotHit = 1100068,
    AchievementFuncNotOpen = 1100069,
    RoguelikeInstComponentNotFind = 1100070,
    RogueCurRoomDataIsNull = 1100071,
    LevelPlayComponentNotFind = 1100072,
    OpenLevelPlayFail = 1100073,
    CloseLevelPlayFail = 1100074,
    RogueRoomConfigNotFind = 1100075,
    RogueRoomTypeNotRight = 1100076,
    RogueRoomTypeNotConfig = 1100077,
    RogueRoomSubLevelNotFind = 1100078,
    SelectNextRoomIsValid = 1100079,
    RogueGainPackageFail = 1100080,
    RogueGainListIsNull = 1100081,
    RogueGainIdValid = 1100082,
    QulityListCountNotRight = 1100083,
    RandomResultCountNotRight = 1100084,
    GuaranteeRogueBuffInValid = 1100085,
    RoleBuffPoolNotFind = 1100086,
    NotValidBuff = 1100087,
    NotValidPhantom = 1100088,
    RandomPhantomFail = 1100089,
    NotValidRole = 1100090,
    RandomRoleFail = 1100091,
    RogueRoadNotFind = 1100092,
    ResultCountNotMatch = 1100093,
    InValidRoomCountNotMatch = 1100094,
    GuaranteeRogueRoomInValid = 1100095,
    InstIdNotMatchLevelPlayId = 1100096,
    GetRoomBornPositionFail = 1100097,
    RoguePortalDataNotClean = 1100098,
    RoguePortalRoomDataNotFind = 1100099,
    RogueSelectRoomFail = 1100100,
    RogueProgressDataIsEmpty = 1100101,
    RogueGainTypeIsValid = 1100102,
    RougeNotOpen = 1100103,
    RougeInstIdIsValid = 1100104,
    RogueRoleListCountNotRight = 1100105,
    RogueMainRoleConfigNotFind = 1100106,
    RogueGainDataDictError = 1100107,
    RogueDiscountedBuffConfigNotFind = 1100108,
    RogueDiscountedRoomTypeConfigNotFind = 1100109,
    RogueDiscountedShopConfigNotFind = 1100110,
    RogueDiscountedCalculateFail = 1100111,
    RogueMoneyNotEnough = 1100112,
    RougeShopRefreshTimeEmpyt = 1100113,
    RougeCurRoomNotFinish = 1100114,
    PlayerDataRepairErrorDebug = 1100115,
    PlayerDataRepairError = 1100116,
    CreateCharacterReqTimeout = 1100117,
    SignActivityNotOpen = 1100118,
    SignActivityNoConfig = 1100119,
    SignActivityIndexValid = 1100120,
    SignActivityNoData = 1100121,
    SignActivityStateNotRight = 1100122,
    RogueSeasonDataNull = 1100123,
    RogueSeasonConfigNotFind = 1100124,
    RogueTokenConfigNotFind = 1100125,
    RogueTokenStatusVaild = 1100126,
    RogueSeasonRewardConfigNotFind = 1100127,
    RogueSeasonRewardIsReceive = 1100128,
    RougeSeasonPointNotEnough = 1100129,
    RougeRoomDataError = 1100130,
    RogueGainDataError = 1100131,
    RogueRoleIdsError = 1100132,
    RogueRogueRoomRouteError = 1100133,
    RogueGetCurRoomLevelPlayError = 1100134,
    RogueTalentTreeConfigNotFind = 1100135,
    RogueTalentTreeConditionNotMet = 1100136,
    RogueTalentTreePerNodeLock = 1100137,
    RogueTalentTreeNodeMaxLevel = 1100138,
    RogueTalentTreeConsumeNoEnough = 1100139,
    RogueRoadRandomRoleBuffError = 1100140,
    ActivityFuncNotOpen = 1100141,
    RogueGuideInstNotSupport = 1100142,
    ErrPayReceiptCannotRefundClose = 1100143,
    ErrPayReceiptRefundCloseFail = 1100144,
    PayRefundOverdueBan = 1100145,
    UnknowChannelId = 1100146,
    LoginServerNotFind = 1100147,
    OldGameNodeLogoutFail = 1100148,
    LoginHandleSwitchError = 1100149,
    NoAvailableLoginService = 1100150,
    ServerIsClosing = 1100151,
    AddPlayerRecordFail = 1100152,
    FindGatewayFail = 1100153,
    CommonFightRolesInfoError = 1100154,
    CurRoleEntityNotFind = 1100155,
    ScenePlayerInfoNotFind = 1100156,
    IncrAdviceVoteError = 1100157,
    InsertAdviceError = 1100158,
    UpdateAdviceError = 1100159,
    DeleteAdviceError = 1100160,
    EntityNoInWater = 1100161,
    AttributeComponentNotFind = 1100162,
    TryAddItemDataFail = 1100163,
    ItemConfigTypeNotRight = 1100164,
    ItemLogicNotFind = 1100165,
    RemoveItemLogicNotFind = 1100166,
    AddItemLogicNotFind = 1100167,
    AddItemFail = 1100168,
    UpdatePlayerARemarkFail = 1100169,
    DeleteFriendApplyFail = 1100170,
    DeleteFriendshipFail = 1100171,
    WorldTeamIsNull = 1100172,
    TeamCountNotRight = 1100173,
    AddCalabashExpFail = 1100174,
    SendRequestToSdkFail = 1100175,
    DirtyWordErrorCode = 1100176,
    HarvestActivityNotOpen = 1100177,
    HarvestActivityPointReceived = 1100178,
    HarvestActivityPointNotConfig = 1100179,
    HarvestActivityPointNotEnough = 1100180,
    HarvestActivityLevelNoData = 1100181,
    HarvestActivityLevelReceived = 1100182,
    HarvestActivityLevelNotConfig = 1100183,
    HarvestActivityLevelNotEnough = 1100184,
    HarvestActivityLevelDiffNotConfig = 1100185,
    RoguelikeEventConfigNotFind = 1100186,
    RoguelikeEventIndexError = 1100187,
    RoguelikeInstConfigNotFind = 1100188,
    RoguelikeMainRoleError = 1100189,
    RoguelikeEventIsEmpty = 1100190,
    RoguelikeEventRandomError = 1100191,
    RoguelikeEventRandomEmpty = 1100192,
    PhantomCollectActivityNotOpen = 1100193,
    PhantomCollectActivitynNotConfig = 1100194,
    PhantomCollectActivitynNoData = 1100195,
    PhantomCollectActivityReceived = 1100196,
    HarvestInstIdInValid = 1100197,
    HarvestVarNotExist = 1100198,
    HarvestResultCacheNotExist = 1100199,
    HarvestInstNotOpen = 1100200,
    HarvestActivityLimitDataNotFind = 1100201,
    HarvestDiffConfigNotFind = 1100202,
    HarvestActivityDiffConfigNotFind = 1100203,
    ErrIllustratedConfigNotFind = 1100204,
    CharacterAlreadyCreated = 1100205,
    SdkHelperInternalError = 1100206,
    GameServiceControllerInternalError = 1100207,
    DoGetCacheInfoInternalError = 1100208,
    DoGetCacheInfosInternalError = 1100209,
    DeleteFriendLoadedInternalError = 1100210,
    UpdateFriendRemarkInternalError = 1100211,
    CheckApplyRequestInternalError = 1100212,
    OnReLoginInternalError = 1100213,
    CreateCharacterRequestInternalError = 1100214,
    LoginRequestInternalError = 1100215,
    LoginRequestInternalError2 = 1100216,
    EnterGameRequestInternalError = 1100217,
    ReconnectRequestInternalError = 1100218,
    ReconnectRequestInternalError2 = 1100219,
    SwitchNodeInternalError = 1100220,
    InnerLoginInternalError = 1100221,
    AccessTokenInternalError = 1100222,
    CreateCharacterInternalError = 1100223,
    RogueSeasonNotValid = 1100224,
    RogueCurRoleNotFind = 1100225,
    RogueSeasonNotMatch = 1100226,
    RogueGainLogicNotFind = 1100227,
    RogueBuffConfigNotFind = 1100228,
    RoguePhantomNotConfig = 1100229,
    RogueRoleNotConfig = 1100230,
    RoguePopularSlotConfigNotFind = 1100231,
    RoguePopularCountIsMax = 1100232,
    RoguePopularConfigNotFind = 1100233,
    RogueRoleNotOpen = 1100234,
    RogueGuideInstError = 1100235,
    RogueMainRoleChange = 1100236,
    RogueShopConfigNull = 1100237,
    RogueGainIsSelect = 1100238,
    RogueGainNoRefresh = 1100239,
    RogueRefreshCostNotFind = 1100240,
    RogueNotMaxLayer = 1100241,
    RogueRoomSubLevelNotFind2 = 1100242,
    RoguePopularSlotArgConfigNotFind = 1100243,
    RogueInstSeasonNotMatch = 1100244,
    RogueSeasonTalentTreeNotFind = 1100245,
    RogueGainOptionsNotFind = 1100246,
    RogueGainIsSell = 1100247,
    RogueMiracleCreationConfNotFind = 1100248,
    RogueGainPackageError = 1100249,
    RogueTrialRoleIdsCountNotRight = 1100250,
    RogueVarNotExist = 1100251,
    RougeWhiteCatConfigNotFind = 1100252,
    RougeWhiteCatNotOpen = 1100253,
    RougeWhiteCatLimitedTime = 1100254,
    RougeWhiteCatRewardLock = 1100255,
    RougeWhiteCatRewardIsReceive = 1100256,
    RougeWhiteCatRewardIndexErr = 1100257,
    RougeWhiteCatInstIndexErr = 1100258,
    RougeWhiteCatInstLock = 1100259,
    RougeWhiteCatBossRewardIndexErr = 1100260,
    RougeWhiteCatBossRewardLock = 1100261,
    RougeWhiteCatBossRewardIsReceive = 1100262,
    RougeWhiteCatLevelPlayIndexErr = 1100263,
    RougeWhiteCatLevelPlayLock = 1100264,
    RougeWhiteCatLevelPlayIsReceive = 1100265,
    ResourceVersionTooLow = 1100266,
    RogueLimitTimeRewardConfigNotFind = 1100267,
    RogueWhiteCatLimitedTimeOut = 1100268,
    RougeWhiteCatLimitedRewardLock = 1100269,
    RougeWhiteCatLimitedRewardIsReceive = 1100270,
    RougeWhiteCatBlackFlowerNoCount = 1100271,
    RogueInstCountNotRight = 1100272,
    RogueInstFightFormationNotConfig = 1100273,
    RogueTrialRoleNotValid = 1100274,
    RogueRoleNotValid = 1100275,
    ErrorBlackFlowerEntityNotRight = 1100276,
    ErrorBlackFlowerStatus = 1100277,
    ErrorBlackFlowerCanNotReward = 1100278,
    ErrorBlackFlowerRewardFail = 1100279,
    ErrorPhantomUnlockError = 1100280,
    ErrorPhantomSwitchError = 1100281,
    ActivityConfigNotFind = 1100282,
    ActivityNotOpen = 1100283,
    DirectTrainActivityConfigNotFind = 1100284,
    ActivityTypeNotFind = 1100285,
    SetGlobalVarFail = 1100286,
    ErrMultigame = 1100287,
    RogueWeeklyCycleNoFind = 1100288,
    RogueWeeklyCycleIdNotMatch = 1100289,
    RogueWeeklyCycleInstIdNotMatch = 1100290,
    RogueWeeklyCycleSexNotMatch = 1100291,
    RogueWeeklyCycleActivityIdNotMatch = 1100292,
    RogueWeeklyCycleAwardNotFind = 1100293,
    RogueWeeklyCycleAwardStateNotMatch = 1100294,
    RogueWeeklyInstResultFail = 1100295,
    RogueWeeklyGoldNoEnough = 1100296,
    HasRogueProgressCanNotChangeSex = 1100297,
    RogueWeeklyWorldLevelNotMatch = 1100298,
    ResourceVersionIsTooLowWithTips = 1100299,
    RogueResInstIdNotMatch = 1100300,
    RogueResInstGridConfigNotFind = 1100301,
    RogueResInBossInst = 1100302,
    RogueResCurGridIsNull = 1100303,
    RogueResPathCountFail = 1100304,
    RogueResPathRepeat = 1100305,
    RogueResPathGridNoNear = 1100306,
    RogueResPathGridNoValid = 1100307,
    RogueResPathGridNoVision = 1100308,
    RogueResPathGridBlock = 1100309,
    RogueResPlayerBanMove = 1100310,
    RogueResHasOp = 1100311,
    RogueResTrialRoleNotFind = 1100312,
    RogueResTrialRoleNoValid = 1100313,
    RogueResThemeConfNotFind = 1100314,
    RogueResCrossInstDataIsNull = 1100315,
    RogueResOpEmpty = 1100316,
    RogueResOpNotMatch = 1100317,
    RogueResCollectionConfNotFind = 1100318,
    RogueResCollectionStateErr = 1100319,
    RogueResEndingAwardConfNotFind = 1100320,
    RogueResEndingAwardIsReceived = 1100321,
    RogueResEndingAwardNotFinish = 1100322,
    RogueResTalentConfNotFind = 1100323,
    RogueResTaskConfNotFind = 1100324,
    RogueResTaskDatanotFind = 1100325,
    RogueResTaskAwardIsReceived = 1100326,
    RogueResTaskAwardNotFinish = 1100327,
    RogueResEffectConfNoFind = 1100328,
    RogueResOptionNoRestCount = 1100329,
    RogueResOptionCantMulti = 1100330,
    RogueResOptionRepeat = 1100331,
    RogueResOptionCantGiveUp = 1100332,
    RogueResOptionCantRefresh = 1100333,
    RogueResOptionIndexNoValid = 1100334,
    RogueResOptionTypeError = 1100335,
    RogueResOptionIsSelect = 1100336,
    RogueResCollectionIndexMax = 1100337,
    RogueResCollectionDropConfigNoFind = 1100338,
    RogueResNoBaseGainLogic = 1100339,
    RogueResGridAwardNoConf = 1100340,
    RogueResBornPositionNoConf = 1100341,
    RogueResEffectExecFail = 1100342,
    RogueResOptionFinish = 1100343,
    RogueResOpTypeErr = 1100344,
    RogueResGridEventNoConf = 1100345,
    RogueResGridEventStepNoConf = 1100346,
    RogueResStepOptionNoValid = 1100347,
    RogueResGridEventNoData = 1100348,
    RogueResSelectIndexNoValid = 1100349,
    RogueResGotoNextRoomNoData = 1100350,
    RogueResSelectOpNoData = 1100351,
    RogueResBranchTaskNoConf = 1100352,
    RogueResBranchTaskNoData = 1100353,
    RogueResBranchTaskIsReceive = 1100354,
    RogueResBranchTaskNoFinish = 1100355,
    RogueResTokenShopPriceErr = 1100356,
    RogueResTaskTypeErr = 1100357,
    RogueRandomNoPoolName = 1100358,
    RogueRandomNoHit = 1100359,
    RogueRandomNoValidResult = 1100360,
    RogueResFormationIdNoValid = 1100361,
    RogueResFormationRoleCountErr = 1100362,
    RogueResRandomNoShopGoods = 1100363,
    RogueResRandomShopGoodsNoEnough = 1100364,
    RogueResFormationRoleNoValid = 1100365,
    RogueResFormationNoData = 1100366,
    RogueResGainRoleNoFind = 1100367,
    RogueResGainRoleLvNoConf = 1100368,
    RogueResGainRoleLvNoLv = 1100369,
    RogueResGainRoleNoBuffPool = 1100370,
    RogueResGainRoleNoMaxlv = 1100371,
    RogueResGainRoleRollEffectNoValid = 1100372,
    RogueResGainRoleRollRetNoMatch = 1100373,
    RogueResGainRoleShopNoConf = 1100374,
    RogueResGainRoleRollEmpty = 1100375,
    RogueResGainRoleBondNoValid = 1100376,
    RogueResRoleBuffGuaranteeFail = 1100377,
    RogueResRoleBuffNoMore = 1100378,
    RogueResRoleBuffRandomFail = 1100379,
    RogueRoleShopRollFail = 1100380,
    RogueResGridRangeTrigger = 1100381,
    RogueResCurGridTrigger = 1100382,
    RogueResEventTypeErr = 1100383,
    RogueResEventOpNoData = 1100384,
    RogueResGridNoConf = 1100385,
    RogueResEffectExceFail = 1100386,
    RogueResNoInBattle = 1100387,
    RogueResStepCondLock = 1100388,
    RogueResGridEventOpNotFind = 1100389,
    RogueNoLastInstData = 1100390,
    RogueNoRollBuffBondLinkOp = 1100391,
    RogueTokenCantRepeat = 1100392,
    RogueFailCountMax = 1100393,
    RogueResRoleMaxLv = 1100394,
    RogueResPerInstNoPass = 1100395,
    RogueResCreateInstCacheErr = 1100396,
    LordGymRepeatChallenge = 1100397,
    NewbieCarnivalNoLicense = 1100398,
    NewbieCarnivalParamNoConf = 1100399,
    NewbieCarnivalNoRoleId = 1100400,
    NewbieCarnivalNoData = 1100401,
    NewbieCarnivalTaskNoConf = 1100402,
    NewbieCarnivalTaskTaken = 1100403,
    NewbieCarnivalTaskRunning = 1100404,
    ErrShopFixeNotExist = 1100405,
    ErrShopBankNoExist = 1100406,
    ErrShopBankNoMatch = 1100407,
    ErrPayShopBuyCountOverFlow = 1100408,
    ErrShopBuyCountOverFlow = 1100409,
    EnergyOverFlow = 1100410,
    EnergyNotEnough = 1100411,
    StoreEnergyNotEnough = 1100412,
    ErrPayShopBuyLimitCondition = 1100413,
    ErrPayShopEchoItemOver2 = 1100414,
    ErrPayShopEchoItemOver3 = 1100415,
    ErrPayShopEchoItemOver4 = 1100416,
    CreateReceiptCoreParamError = 1100417,
    ReceiptsDealCloseCoreParamError = 1100418,
    ReceiptsRefundCloseCoreParamError = 1100419,
    CreateReceiptCoreException = 1100420,
    ReceiptsDealCloseCoreException = 1100421,
    ReceiptsRefundCloseCoreFail = 1100422,
    ReceiptsRefundCloseCoreException = 1100423,
    ErrPayConfigClientCantBuy = 1100424,
    RecyclePersonalGiftNoData = 1100425,
    ErrPersonalGiftBuyLimit = 1100426,
    CreateReceiptNoConf = 1100427,
    CreateReceiptFail = 1100428,
    ReceiptDealCloseNoData = 1100429,
    ReceiptDealClosePlayerIdUnMatch = 1100430,
    ReceiptCannotDealClose = 1100431,
    ReceiptDealCloseFail = 1100432,
    ReceiptRefundCloseNoData = 1100433,
    ReceiptRefundClosePlayerIdUnMatch = 1100434,
    ReceiptCannotRefundClose = 1100435,
    ReceiptRefundCloseFail = 1100436,
    ReceiptRefundNoData = 1100437,
    CreateReceiptParamError = 1100438,
    CreateReceiptException = 1100439,
    ReceiptsDealCloseParamError = 1100440,
    ReceiptsDealCloseException = 1100441,
    ReceiptRefundCloseParamError = 1100442,
    ReceiptRefundCloseException = 1100443,
    ReceiptRefundParamError = 1100444,
    UpdateRogueWeeklyArtifactsFail = 1100445,
    RogueWeeklyArtifactsEmpty = 1100446,
    RogueWeeklyArtifactsIndexErr = 1100447,
    RogueResSkipBattleLvNoEnough = 1100448,
    RogueResCanNotSkipBattle = 1100449,
    RogueResRandomGridNoConf = 1100450,
    StrangerHostCount = 1100451,
    SurvivorsNotInitOp = 1100452,
    SurvivorsNotSelectOp = 1100453,
    SurvivorsNoRoleAndWeapon = 1100454,
    SurvivorsRandomEmpty = 1100455,
    SurvivorsOptionEmpty = 1100456,
    SurvivorsSelectEmpty = 1100457,
    SurvivorsRandomGuaranteedEmpty = 1100458,
    SurvivorsLevelNoConf = 1100459,
    SurvivorsWeaponPoolEmpty = 1100460,
    SurvivorsWeaponEmpty = 1100461,
    SurvivorsGoldNoEnough = 1100462,
    SurvivorsWeaponMax = 1100463,
    SurvivorsNoSupportGiveUp = 1100464,
    SurvivorsNoRestSelectCount = 1100465,
    SurvivorsNoSupportMultiSelect = 1100466,
    SurvivorsRepeatSelect = 1100467,
    SurvivorsComponentNoFind = 1100468,
    SurvivorsOpNotFind = 1100469,
    SurvivorsSelectErr = 1100470,
    SurvivorsNoVar = 1100471,
    SurvivorsInstIdErr = 1100472,
    SurvivorsInstLock = 1100473,
    SurvivorsInstNotTime = 1100474,
    SurvivorsInstNoEndlessMode = 1100475,
    SurvivorsNeedContinue = 1100476,
    SurvivorsLevelCantUseRole = 1100477,
    SurvivorsLevelCantUseWeapon = 1100478,
    SurvivorsRoleNoMatch = 1100479,
    SurvivorsStepErr1 = 1100480,
    SurvivorsStepErr2 = 1100481,
    SurvivorsStepErr3 = 1100482,
    SurvivorsCantBuy = 1100483,
    SurvivorsRoleLvNoConf = 1100484,
    SurvivorsWeaponLvNoConf = 1100485,
    SurvivorsRoleNoFind = 1100486,
    SurvivorsWaponNoFind = 1100487,
    SurvivorsItemNoFind = 1100488,
    SurvivorsRoleLvMax = 1100489,
    SurvivorsWeaponLvMax = 1100490,
    SurvivorsRefreshOpFail = 1100491,
    SurvivorsWeightEmpty = 1100492,
    SurvivorsActivityNoData = 1100493,
    SurvivorsRefreshCostFail = 1100494,
    SurvivorsNoLastInstData = 1100495,
    SurvivorsActivityNoConf = 1100496,
    SurvivorsTalentNoConf = 1100497,
    SurvivorsTaskCountMax = 1100498,
    SurvivorsTaskNoConf = 1100499,
    SurvivorsTaskCantReward = 1100500,
    SurvivorsTaskRepeat = 1100501,
    SurvivorsTaskEmpty = 1100502,
    SurvivorsAllLock = 1100503,
    RogueResNoGlobalConf = 1100504,
    RogueResLimitedRoles = 1100505,
    SurvivorsNeedPassNormalMode = 1100506,
    SurvivorsOptionIsSelect = 1100507,
    SurvivorsTalentTreeConditionNotMet = 1100508,
    SurvivorsTalentTreePerNodeLock = 1100509,
    SurvivorsTalentTreeNodeMaxLevel = 1100510,
    SurvivorsTalentTreeConsumeNoEnough = 1100511,
    ShortMessageNoConf = 1100512,
    ShortMessageOptionNoConf = 1100513,
    ShortMessageNoData = 1100514,
    ShortMessageNoData2 = 1100515,
    ShortMessageIsRead = 1100516,
    ShortMessageNoMatch = 1100517,
    ShortMessageNoReply = 1100518,
    ShortMessageIsReply = 1100519,
    ShortMessageNoReward = 1100520,
    ShortMessageIsReward = 1100521,
    ShortMessageNoFinish = 1100522,
    ErrorPhantomCollectMax = 1100523,
    ErrorPhantomCollectRepeated = 1100524,
    ErrorPhantomCollectLock = 1100525,
    ErrorNoSceneComp = 1100526,
    ErrorNewTowerIsInChallenge = 1100527,
    ErrorNewTowerIsNoChallenge = 1100528,
    ErrorNewTowerLevelIdNotMatch = 1100529,
    ErrorNewTowerLevelNoConf = 1100530,
    ErrorNewTowerCycleNoConf = 1100531,
    ErrorNewTowerLevelNoData = 1100532,
    ErrorNewTowerNoTeamCache = 1100533,
    ErrorNewTowerNoIndexTeamCache = 1100534,
    ErrorNewTowerScoreRewardMax = 1100535,
    ErrorNewTowerScoreNoConf = 1100536,
    ErrorNewTowerScoreRepeat = 1100537,
    ErrorNewTowerScoreEmpty = 1100538,
    ErrorNewTowerCycleNoInTime = 1100539,
    ErrorNewTowerCurCycleNoConf = 1100540,
    ErrorNewTowerCycleNoLevel = 1100541,
    ErrorNewTowerTeamIndexErr = 1100542,
    ErrorNewTowerTeamMax = 1100543,
    ErrorNewTowerBuffMax = 1100544,
    ErrorNewTowerBuffRepeat = 1100545,
    ErrorNewTowerRoleRepeat = 1100546,
    ErrorNewTowerRoleEmpty = 1100547,
    ErrorNewTowerRoleNoMatch = 1100548,
    ErrorNewTowerRoleMax = 1100549,
    ErrorNewTowerBuffNoMatch = 1100550,
    ErrorNewTowerRoleNoEnergy = 1100551,
    ErrorNewTowerWaveNoInfo = 1100552,
    ErrorNewTowerWaveFinish = 1100553,
    ErrorShortMessageNoOpen = 1100554,
    ErrorShortMessageOptionMax = 1100555,
    ErrorShortMessageBubbleNoData = 1100556,
    ErrorShortMessageBubbleNoConf = 1100557,
    ErrorShortMessageChatBgNoData = 1100558,
    ErrorShortMessageChatBgNoConf = 1100559,
    ErrorNewTowerInstStateErr = 1100560,
    ErrorNewTowerRoleWeaponPhantom = 1100561,
    ErrorNewTowerNoTeamData = 1100562,
    ErrorNewTowerNoCacheSet = 1100563,
    ErrorNewTowerRoleWeaponNoMatch = 1100564,
    ErrorNewTowerRolePhantomNoMatch = 1100565,
    ShortMessageOptionNoConf2 = 1100566,
    ShortMessageOptionNoConf3 = 1100567,
    ErrorNewTowerEntityNoFind = 1100568,
    ErrorNewTowerSeasonAwardNoConf = 1100569,
    ErrorNewTowerSeasonNoConf = 1100570,
    ErrorNewTowerSeasonNotOpen = 1100571,
    ErrorNewTowerSeasonAwardRepeat = 1100572,
    ErrorNewTowerSeasonAwardEmpty = 1100573,
    NewTowerNoLastCycleIdReview = 1100574,
    NewTowerNoActivityData = 1100575,
    NewTowerNoHistoryData = 1100576,
    ErrorNewTowerSeasonAwardTimeout = 1100577,
    RogueInstConfNoFind = 1100578,
    RoguePhantomLock = 1100579,
    RogueRoleLock = 1100580,
    RogueHotEntryLock = 1100581,
    KurotatoNoActivityData = 1100582,
    KurotatoNoActivityConf = 1100583,
    KurotatoTaskLenghMax = 1100584,
    KurotatoTaskNoConf = 1100585,
    KurotatoTaskNoFinish = 1100586,
    KurotatoTaskIsAward = 1100587,
    KurotatoTaskRepeat = 1100588,
    KurotatoTaskZero = 1100589,
    KurotatoCanNotSaveRole = 1100590,
    KurotatoIsSaveRole = 1100591,
    KurotatoIsInInst = 1100592,
    KurotatoNoLevelData = 1100593,
    KurotatoNoRoleData = 1100594,
    KurotatoNoRecord = 1100595,
    KurotatoHasRecord = 1100596,
    KurotatoRoleNoRecord = 1100597,
    KurotatoRecordLevelNotMatch = 1100598,
    KurotatoRoleNotMatch = 1100599,
    HasRoguelikeProgressCanNotChangeSex = 1100600,
    WeeklyFrameNoData = 1100601,
    WeeklyFrameScoreAwardMax = 1100602,
    WeeklyFrameNotInTime = 1100603,
    WeeklyFrameNoConf = 1100604,
    WeeklyFrameScoreAwardNoConf = 1100605,
    WeeklyFrameScoreAwardGroupNotMatch = 1100606,
    WeeklyFrameScoreAwardNotFinish = 1100607,
    WeeklyFrameScoreAwardTaken = 1100608,
    WeeklyFrameScoreAwardRepeat = 1100609,
    WeeklyFrameScoreAwardZero = 1100610,
    KurotatoItemLock = 1100611,
    KurotatoWeaponLock = 1100612,
    KurotatoLevelNotOpen = 1100613,
    HasTempRogueArchive = 1100614,
    NoTempRogueArchive = 1100615,
    RogueArchiveSlotErr = 1100616,
    NoRogueTowerTrial = 1100617,
    RogueTowerTrialInstNoConf = 1100618,
    RogueTowerTrialNoConf = 1100619,
    RogueTowerTrialInstNoData = 1100620,
    RogueTowerTrialInstInChallenge = 1100621,
    RogueTowerTrialInstBossErr = 1100622,
    NoRogueArchive = 1100623,
    RogueArchiveInvalid = 1100624,
    KurotatoStepErr1 = 1100625,
    KurotatoStepErr2 = 1100626,
    ErrorNewTowerAwardCantGet = 1100627,
    KurotatoShopProductIsBought = 1100628,
    KurotatoShopProductAllLock = 1100629,
    ErrChatNotFriendNorOnline = 1200000,
    ErrChatContentFilterFailed = 1200001,
    ErrChatLockState = 1200002,
    ErrChatEmojiNotValid = 1200003,
    ErrChatSendTooFast = 1200004,
    ErrChatMuteNotValidId = 1200005,
    ErrBanChatDefault = 1200006,
    ErrRoleQuestFuncNotOpen = 1200007,
    ErrRoleQuestMaxCount = 1200008,
    ErrRoleQuestUnlockPointNotEnough = 1200009,
    ErrDailyQuestNotFoundArea = 1200010,
    ErrDailyQuestNotFoundInfluence = 1200011,
    ErrDailyQuestRewardAlreadyGet = 1200012,
    ErrDailyQuestDataError = 1200013,
    ErrDailyQuestCantGetReward = 1200014,
    ErrEntityBuffProducerStateError = 1200015,
    ErrEntityBuffProducerNotFound = 1200016,
    ErrVoiceRemainChangeRoleNotInFormation = 1200017,
    ErrVoiceRemainChangeRoleNotAlive = 1200018,
    ErrApplyEffectFail = 1300000,
    ErrOutofBattleTargetNotMonster = 1300001,
    ErrMonsterBoomEntityNotExists = 1300002,
    ErrMonsterBoomNotMonster = 1300003,
    ErrMonsterBoomIsDead = 1300004,
    ErrAnimationStateSpecialFuncException = 1300005,
    ErrPayConfigNotFound = 1400000,
    ErrPayCreateReceiptFail = 1400001,
    ErrPayReceiptNotFound = 1400002,
    ErrPayReceiptPlayerIdUnMatch = 1400003,
    ErrPayReceiptCannotDealClose = 1400004,
    ErrPayReceiptDealCloseFail = 1400005,
    ErrPayNotEnable = 1400006,
    ErrPayDataChanged = 1400007,
    ErrPayUpdateReceiptFail = 1400008,
    ErrGachaConfigNotFound = 1400009,
    ErrGachaRuleGroupConfigNotFound = 1400010,
    ErrGachaRulesNotFound = 1400011,
    ErrGachaTypeKnowns = 1400012,
    ErrGachaDailyTimesLimit = 1400013,
    ErrGachaTotalTimesLimit = 1400014,
    ErrGachaDailyTotalTimesLimit = 1400015,
    ErrGachaIsNotOpen = 1400016,
    ErrGachaIsNotInOpenTime = 1400017,
    ErrGachaFuncIsNotOpen = 1400018,
    ErrItemExchageConfigNotFound = 1400019,
    ErrItemExchageDailyTimesLimit = 1400020,
    ErrItemExchangeTotalTimesLimit = 1400021,
    ErrGachaLimitNotFound = 1400022,
    ErrGachaLimitsEmpty = 1400023,
    ErrTextServerTimeout = 1400024,
    ErrTextServerResFail = 1400025,
    ErrTextServerResEmpty = 1400026,
    ErrTextServerResException = 1400027,
    ErrItemExchageParamError = 1400028,
    ErrBattlePassFuncIsNotOpen = 1400029,
    ErrPayShopFuncIsNotOpen = 1400030,
    ErrGachaPoolConfigNotFound = 1400031,
    ErrGachaPoolIsNotOpen = 1400032,
    ErrGachaPoolIsNotInOpenTime = 1400033,
    ErrGachaPoolLimitNotFound = 1400034,
    ErrGachaPoolNotBelongToGacha = 1400035,
    ErrGachaUsePoolIdNotSet = 1400036,
    ErrGachaTimesNonsupport = 1400037,
    ErrGachaFrontRuleGroupNotFinish = 1400038,
    ErrGachaRuleGroupFinish = 1400039,
    ErrPayGiftBuyLimit = 1400040,
    ErrPayGiftTypeUnknown = 1400041,
    ErrPayGiftNotInSellTime = 1400042,
    ErrBattlePassBuyLevelLimit = 1400043,
    ErrBattlePassBuyLevelError = 1400044,
    ErrJsFileNotFound = 1400045,
    ErrPayReceiptIsRefunded = 1400046,
    ErrPayReceiptIsNotPay = 1400047,
    ErrPayReceiptRefundFail = 1400048,
    ErrPayGiftLocked = 1400049,
    ErrPayGiftBuyConditionLimit = 1400050,
    ErrMapMarkConfigIdNotExist = 1400051,
    ErrTreasureSlotMarkNotExist = 1400052,
    ErrTreasureBoxMarkNotExist = 1400053,
    ErrTreasureSlotMarkExist = 1400054,
    ErrMapMarkTypeNotCustom = 1400055,
    ErrPayShopIsNotOpen = 1400056,
    ErrConsumptiveActivityNotOpen = 1400057,
    ErrConsumptiveTaskNotFound = 1400058,
    ErrConsumptiveTaskNotFinish = 1400059,
    ErrConsumptiveTaskRewarded = 1400060,
    ErrConsumptiveActivityNotFound = 1400061,
    ErrPayGiftPersonalNoPermission = 1400062,
    ErrPayGiftPersonalPermissionExpired = 1400063,
    ErrPayGiftNotPersonal = 1400064,
    ErrPayGiftPersonalPermissionExist = 1400065,
    ErrCouponId = 1400066,
    ErrCouponConfigNotFound = 1400067,
    ErrCouponNotEnough = 1400068,
    ErrCouponTargetItemNotFound = 1400069,
    ErrCouponTargetItemCount = 1400070,
    ErrGachaTypeNotPersonal = 1400071,
    ErrGachaPersonalPermissionExist = 1400072,
    ErrGachaPersonalNoPermission = 1400073,
    ErrGachaPersonalPermissionExpired = 1400074,
    ErrPayGiftVersionConfigNotFound = 1400075,
    ErrPayGiftSelfDefineVersionError = 1400076,
    ErrInfoDisplayId = 1500000,
    ErrItemAlreadyInCd = 1500001,
    ErrCantFinAdventureConfig = 1500002,
    ErrAdventureRewardReceived = 1500003,
    ErrAdventureTaskCache = 1500004,
    ErrAdventureState = 1500005,
    ErrAdventureRewardOrder = 1500006,
    ErrAdventureChapterState = 1500007,
    ErrCantDetectRepeat = 1500008,
    ErrNotInCurrentFollowList = 1500009,
    ErrCantDetectOtherDetectionType = 1500010,
    ErrNotSelectCurrentDetectionId = 1500011,
    ErrDetectionConfigNotFound = 1500012,
    ErrDetectionListCantBeEmpty = 1500013,
    ErrCantFindAnyDetectionTarget = 1500014,
    ErrCantFindTurntableComponentEntity = 1500015,
    ErrHaveNoTurntableControlComponent = 1500016,
    ErrCantFindLevitationMagnetComponentEntity = 1500017,
    ErrHaveNoLevitaionMagnetComponent = 1500018,
    ErrCantFindBoardEntity = 1500019,
    ErrCantFindPlacementEntity = 1500020,
    ErrHaveNoPlacementComponent = 1500021,
    ErrCantFindBoardEntityComponent = 1500022,
    ErrBoardHaveNoAnyPlacement = 1500023,
    ErrBoardNotActiveAllGrid = 1500024,
    ErrNeedBeControlledBefore = 1500025,
    ErrPlaceFailOfAlreadyOnBoard = 1500026,
    ErrInvalidBoardPosition = 1500027,
    ErrNeedRemoveControlRelation = 1500028,
    ErrNotOccupyOnBoard = 1500029,
    ErrHaveNoFillRule = 1500030,
    ErrGridPosAlreadyOccupied = 1500031,
    ErrHaveNoJigsawFoundationConfig = 1500032,
    ErrInvalidGridPos = 1500033,
    ErrGridPosAlreadyActive = 1500034,
    ErrCantPlaceItemOnBoard = 1500035,
    ErrNeedJigsawFoundationComponentWhenBeControlled = 1500036,
    ErrHaveNoBoardComponentConfig = 1500037,
    ErrNeedJigsawItemComponentWhenBeControlled = 1500038,
    ErrCantFindOriginBoardEntity = 1500039,
    ErrDistanceNotInRangeBetweenEntity = 1500040,
    ErrJigsawFoundationIsAlreadySilent = 1500041,
    ErrCrystalEntityNotFound = 1500042,
    ErrGachaBoardEntityNotFound = 1500043,
    ErrNotCrystalEntity = 1500044,
    ErrNotGachaFoundationEntity = 1500045,
    ErrGachaHoleIsFull = 1500046,
    ErrJigsawItemSilent = 1500047,
    ErrThrowDamageConfigNotExists = 1500048,
    ErrThrowDamageComponetNotExists = 1500049,
    ErrEggNotMatchEggFoundation = 1500050,
    ProgressBarEntityNotFound = 1500051,
    NotProgressBarEntity = 1500052,
    ProgressBarIsSilent = 1500053,
    ScenePlayerInfoNotFound = 1500054,
    PlayerNotInAnyScene = 1500055,
    TeleportNotInValidDistance = 1500056,
    AddMapMarkInfoLackOfTeleportParam = 1500057,
    TemporaryTeleportNotExists = 1500058,
    ErrNotHostPlayer = 1500059,
    ErrMarkIdNotExists = 1500060,
    ErrCantUpdateTemporaryTeleportMarkInfo = 1500061,
    NotHostCantAddTemporaty = 1500062,
    TemporaryTeleportPosIsNotWalkable = 1500063,
    BadTemporaryTeleportConfig = 1500064,
    HaveNoTemporaryTeleportComponent = 1500065,
    ErrCantDetectAtInvalidPoint = 1500066,
    ErrNotDetectionTreasureBoxBefore = 1500067,
    ErrJigsawFoundationIsCompleteCantModifyGridState = 1500068,
    GridIsActiveCantSwitchState = 1500069,
    GridIsOccupiedCantSwitchState = 1500070,
    ErrHaveNoBaseInfoComponent = 1500071,
    ErrHaveNoParentEntity = 1500072,
    NotRelationEntity = 1500073,
    ErrLevelPlayNotRunning = 1500074,
    ErrStateCantChangeWhenLifeCycleDestroy = 1500075,
    ErrRangeEntityIdNotFoundWhenForbidTempTeleport = 1500076,
    TemporaryTeleportIsForbidden = 1500077,
    ErrGravityGearIsComplete = 1500078,
    ErrInvalidRoleWhenUpdatePassiveSkill = 1500079,
    ErrInvalidRolePassiveSkillId = 1500080,
    ErrPassiveSkillNotAddBuff = 1500081,
    ErrPassiveSkillCantSpecifyBuff = 1500082,
    ErrPassiveSkillAddBuffFail = 1500083,
    ErrPassiveSkillAddBulletFail = 1500084,
    ErrBuffCreatePassiveSkillFail = 1500085,
    ErrInvalidPreContext = 1500086,
    ErrBadPassiveSkillId = 1500087,
    ErrPassiveSkillComponentNotFound = 1500088,
    ErrRepeatePassiveSkill = 1500089,
    ErrBadPassiveSkillTriggerType = 1500090,
    ErrAddPassiveSkillFailOfEntityNotFound = 1500091,
    ErrEntityNotClientControlWhenAddPassiveSkill = 1500092,
    ErrEntityNotClientControlWhenRemovePassiveSkill = 1500093,
    ErrPassiveSkillNotFoundWhenRemovePassiveSkill = 1500094,
    ErrRepeatedBattleContext = 1500095,
    ErrPassiveSkillAddSkillFail = 1500096,
    ErrCombatSendPackAbnormal = 1500097,
    ErrContextCheckFail = 1500098,
    ErrFsmComponentNotFound = 1500099,
    ErrFsmCreateContextFail = 1500100,
    ErrFsmStateBehaviorPreMessageCantBeZero = 1500101,
    ErrFsmBehaviorCheckBattleContextFail = 1500102,
    ErrFsmPlayMontageLackPreMessage = 1500103,
    ErrFsmPlayMontageCheckContextFail = 1500104,
    ErrFsmPlayMontageConfigCheckFail = 1500105,
    ErrSkillFlowNotExist = 1500106,
    ErrGetReportDataOverLimit = 1500107,
    ErrGetReportDataTooFast = 1500108,
    ErrNotInAnyScene = 1500109,
    ErrAceLogDataNotFound = 1500110,
    ErrAceLogDataRepeatReport = 1500111,
    ErrAceInvalidLogId = 1500112,
    ErrAceSceneGlobalObjNotFound = 1500113,
    ErrAceBadParam = 1500114,
    ErrS2CConfirmIdNotExists = 1500115,
    ErrPassiveSkillConfigNotFound = 1500116,
    ErrNotBehaviorController = 1500117,
    ErrPlayMontageFail = 1500118,
    ErrFightDataInConsistent = 1500119,
    ErrNotInAoiSight = 1500120,
    ErrPassiveSkillNotOwner = 1500121,
    ErrReportStartFirstly = 1500122,
    ErrBattleEntityNotFound = 1500123,
    ErrBattleCampNotDefined = 1500124,
    ErrOtherInternalError = 1500125,
    ErrHaventBattleComponent = 1500126,
    ErrLackCombinePartInfoParam = 1500127,
    ErrCombinerEntityNotExists = 1500128,
    ErrTargetEntityNotExists = 1500129,
    ErrTargetPartNotExists = 1500130,
    ErrCombineComponentNotExists = 1500131,
    ErrAlreadyCombineToOtherEntity = 1500132,
    ErrLackCombinerOffsetPos = 1500133,
    ErrLackCombinerOffsetRotate = 1500134,
    ErrCombineEntityNotFound = 1500135,
    ErrDissolveCheckBattleContextFail = 1500136,
    ErrRepeatedRole = 1500137,
    ErrNotStateMachineBehavior = 1500138,
    ErrDiscardMsgWhenChangeSceneMultiMode = 1500140,
    ErrMayOccurDbAbnormal = 1500139,
    ErrEntityLivingStatusNotifyCheckFsmPlayMontageOfFsmGroupConfigNotExists = 1500141,
    ErrEntityLivingStatusNotifyCheckFsmPlayMontageOfConfigNotExists = 1500142,
    ErrEntityLivingStatusNotifyCheckFsmPlayMontageFail = 1500143,
    ErrFsmActionCheckFsmPlayMontageFail = 1500144,
    ErrFsmActionCheckSkillFail = 1500145,
    ErrFsmActionCheckBufflFail = 1500146,
    ErrFsmPlayMontageCheckAnParamError = 1500147,
    ErrFsmPlayMontageCheckAnMontageConfigNotFound = 1500148,
    ErrFsmPlayMontageCheckAnMontageFail = 1500149,
    ErrMontageConfigNotFound = 1500150,
    ErrANConfigNotFound = 1500151,
    ErrBulletConfigNotFound = 1500152,
    ErrFsmVersion = 1500153,
    ErrUpdateFightRoleRepeated = 1500154,
    TrialRoleEntityOverLimit = 1500155,
    ErrHaveNoRoleInfos = 1500156,
    ErrTeamHaveNoAnyRoles = 1500157,
    ErrSkillMontageNotNormalMontage = 1500158,
    ErrMontageContextConfigNotFound = 1500159,
    ErrMontageContextCheckAnFail = 1500160,
    ErrLivingStatusContextCheckPlayMontageContextFail = 1500161,
    ErrContextHaveNoFsmGroupConfig = 1500162,
    ErrLivingStatusContextFsmGroupConfigNotFound = 1500163,
    ErrFsmActionCheckPlayEntityMontageFail = 1500164,
    ErrMontageContext1CheckPlayEntityMontageFail = 1500165,
    ErrSkillGAHaveNoModifyCommonEnemyPro = 1500166,
    ErrCombatSkillGAHandleGetEntityFailed = 1600000,
    ErrCombatMaterialHandleGetEntityFailed = 1600001,
    ErrCombatParticleHandleGetEntityFailed = 1600002,
    ErrCombatPartLifeChangeEntityNotExisted = 1600003,
    ErrCombatCreateBulletTargetNotExisted = 1600004,
    ErrCombatDeleteBulletTargetNotExisted = 1600005,
    ErrCombatDeleteBulletGetEntityFailed = 1600006,
    ErrCombatBulletTargetNoExist = 1600007,
    ErrPartEntityNotExisted = 1600008,
    ErrNoAiControlRights = 1600009,
    ErrAiHateComponent = 1600010,
    ErrSummonerPlayerControl = 1600011,
    ErrConfDamageNotFound = 1600012,
    ErrProcessDamageFailed = 1600013,
    ErrInjuryFreeLandingTag = 1600014,
    ErrNotFindActiveGameplayEffect = 1600015,
    NotClientControlBuff = 1600016,
    ErrBuffNoEffectConf = 1600017,
    ErrBuffCannotCreateBullet = 1600018,
    ErrBuffCannotCreateBuff = 1600019,
    ErrNoBuffConf = 1600020,
    ErrStoppedAi = 1600021,
    ErrEntityIsNotAlive = 1600022,
    ErrSummonCannotSwitchAiControl = 1600023,
    ErrAiControlNotChange = 1600024,
    ErrPlayerCannotControlEntity = 1600025,
    ErrNotFoundBuffEffect = 1600026,
    ErrBuffEffectAuthority = 1600027,
    ErrConcomitantDestroy = 1600028,
    ErrPlayerFollowersComponent = 1600029,
    ErrBuffComponentNotExist = 1600030,
    ErrOrderApplyBuffFailed = 1600031,
    ErrPlayerBuff = 1600032,
    ErrFindPathNoEndPos = 1600033,
    ErrNotGetCurRole = 1600034,
    ErrFindPathFailed = 1600035,
    ErrEntityFsmMachineNotExist = 1700000,
    ErrEntityFsmStateIncorrect = 1700001,
    ErrIsNotAiControler = 1700002,
    ErrIEntityFsmCantTransit = 1700003,
    ErrIEntityFsmTransitCondition = 1700004,
    ErrIEntityFsmTransitToState = 1700005,
    ErrIEntityFsmConfirmNotExist = 1700006,
    ErrIEntityFsmConfirmNotWait = 1700007,
    ErrITest = 1700008,
    ErrITest1 = 1700009,
    ErrITest2 = 1700010,
    ErrIEntityFsmCondCantPass = 1700011,
    ErrIEntityFsmActionParamType = 1700012,
    ErrIEntityFsmActionParam = 1700013,
    ErrIEntityFsmActionExecuted = 1700014,
    ErrIEntityFsmActionNotMatchState = 1700015,
    ErrSkillNotExecuting = 1700016,
    ErrExecuteSkillNotMatch = 1700017,
    ErrBlueprintPinNotSupport = 1700018,
    ErrBlueprintPinNotMontage = 1700019,
    ErrBlueprintPinMontageIndex = 1700020,
    ErrConfSkillNotExist = 1700021,
    ErrSkillGANotExist = 1700022,
    ErrSkillGAHaveNoBuff = 1700023,
    ErrSkillGAHaveNoBuffId = 1700024,
    ErrSkillGAHaveNoBullet = 1700025,
    ErrSkillGAHaveNoBulletId = 1700026,
    ErrMontageNotMatchSkill = 1700027,
    ErrMontageIndexError = 1700028,
    ErrVisiionSkillNotEquip = 1700029,
    ErrSkillCD = 1700030,
    ErrHaveNoBattleContext = 1700031,
    ErrContextFsmActionOnce = 1700032,
    ErrPlayMontageButNoSkill = 1700033,
    ErrMontageNotExist = 1700034,
    ErrMontageNotContainBuff = 1700035,
    ErrMontageNotContainBullet = 1700036,
    ErrMontageCantBring = 1700037,
    ErrSkillInfoParamError = 1700038,
    ErrNoWorldTeam = 1800000,
    ErrWorldTeamNoMember = 1800001,
    ErrNoHostIs = 1800002,
    ErrNoInstId = 1800003,
    ErrNoTeamInfo = 1800004,
    ErrHostNoTeamInfo = 1800005,
    ErrHasInMatchTeam = 1800006,
    ErrNotInMatchTeam = 1800007,
    ErrHostIsParam = 1800008,
    ErrMatchModeIParam = 1800009,
    ErrMatchTeamFull = 1800010,
    ErrLocalTeamCanNotOpt = 1800011,
    ErrHostInLocalTeam = 1800012,
    ErrNoMatchNodeId = 1800013,
    ErrPlayerSceneIsNull = 1800014,
    ErrPlayerSceneRolesNull = 1800015,
    ErrInvalidMatchState = 1800016,
    ErrRepeatedMatchState = 1800017,
    ErrApplyrPlayerInMatchNotEnterMatchTeam = 1800018,
    ErrOtherVersionLowNoOperate = 1800019,
    ErrPlayerVersionLowNeedUpdate = 1800020,
    ErrMultiGameModeNoWorldLevelDown = 1800021,
    ErrMultiGameModeNoWorldLevelRegain = 1800022,
    ErrOtherHasOnline = 1800023,
    SwitchRoleNotInCurrentFormation = 1800024,
    ErrNoChangeRoles = 1800025,
    ErrExploreSkillPullGiantMultiGame = 1800026,
    ErrExploreSkillPullGiantNotExist = 1800027,
    ErrHttpRpcParam = 1800028,
    ErrPlayerNotInGameNode = 1800029,
    ErrApplyJoinPlayerCurRoleIsDead = 1800030,
    ErrPlayerCurRoleIsDeadNoJoin = 1800031,
    ErrPlayerCurRoleIsDead = 1800032,
    ErrSwitchMultiverse = 1800033,
    ErrSwitchNode = 1800034,
    ErrMatchConfirmPlayerDead = 1800035,
    ErrCheckPublicResourceVersionLower = 1800036,
    ErrCheckPublicResourceVersionHigher = 1800037,
    ErrCheckPublicResourceClientVersionErr = 1800038,
    ErrCheckPublicResourceServerVersionErr = 1800039,
    ErrCheckPublicResourceClientVersionParamErr = 1800040,
    ErrCheckClientVersionNeedUpdate = 1800041,
    ErrBranchNameNotMatch = 1800042,
    ErrMatchRpcAlready = 1800043,
    ErrOtherPlayerEnterHost = 1800044,
    ErrPlayerEnterHost = 1800045,
    ErrLevelPlayChangeSprotModeInMutile = 1800046,
    ErrMatchingNotInvite = 1800047,
    ErrEnableFunctionFB = 1800048,
    ErrMatchSelectTrialRole = 1800049,
    ErrNoFindLastBigScene = 1800050,
    ErrExploreSkillCustomMultiGame = 1800051,
    ErrExploreSkillCustomNotExist = 1800052,
    ErrMatchInviteMemberDead = 1800053,
    ErrMatchAcceptInviteMemberDead = 1800054,
    ErrNoFishBoat = 1800055,
    ErrTemplateNotExists = 1800056,
    ErrDisableSubLevels = 1800058,
    ErrSubLevelsClientNoPermission = 1800059,
    ErrExploreSkillCustomNoActions = 1800057,
    ErrMatchClientVersion = 1800060,
    ErrCurNodeIsTainted = 1800061,
    ErrTeamMateNodeIsTainted = 1800062,
    ErrMapFuctionNotOpen = 1800063,
    ErrNotSceneOwner = 1800064,
    ErrLevelPlayUiListIsNull = 1800065,
    ErrOpenLevelPlayNotClientUi = 1800066,
    ErrOpenLevelPlayFailed = 1800067,
    ErrBlackSwordChallengeId = 1800068,
    ErrCalabashLevelRequest = 1900000,
    ErrCalabashLevelRewardDone = 1900001,
    ErrCalabashLevelConfig = 1900002,
    ErrSkillTreeActiveConsume = 1900003,
    ErrLoadFriendData = 1900004,
    ErrNoLoadPrivateChatData = 1900005,
    ErrNotInWolrd = 1900006,
    ErrNotInGround = 1900007,
    ErrInFighting = 1900008,
    ErrNotHaveCountryAccess = 1900009,
    ErrSkillIsEffect = 1900010,
    ErrNoSoundBox = 1900011,
    ErrConsumeNotEnough = 1900012,
    ErrExploreSkillCountLimit = 1900013,
    ErrLegalAreaNoTreasureBox = 1900014,
    ErrTreasureBoxAllActive = 1900015,
    ExploreProgressNoCountry = 1900016,
    ExploreProgressNoScoreCfg = 1900017,
    ExploreProgressLackProgress = 1900018,
    ExploreProgressRewardDone = 1900019,
    ExploreProgressNoArea = 1900020,
    ExploreToolNotConfirm = 1900021,
    ExploreToolNotOpen = 1900022,
    ErrTreasureBoxPlaceFail = 1900023,
    ErrTreasureBoxData = 1900024,
    ErrPayShopBuyCondition = 1900025,
    ErrGatherActivityData = 1900026,
    ErrGatherTaskNoFinish = 1900027,
    ErrHadGatherReward = 1900028,
    ErrHadGetSharedReward = 1900029,
    ErrSharedPlat = 1900030,
    ErrTowerTargetComplete = 1900031,
    ErrTowerGuideRewardHad = 1900032,
    ErrTowerGuideNoOpen = 1900033,
    ErrTowerGuideConfig = 1900034,
    ErrNewBieCourseConfig = 1900035,
    ErrNewBieCourseRewardHad = 1900036,
    ErrNewBieCourseLevel = 1900037,
    ErrDetectionTargetSilence = 1900038,
    ErrRoleTrialNotInit = 1900039,
    ErrRoleTrialNoFinish = 1900040,
    ErrRoleTrialReward = 1900041,
    ErrRoleTrialRewardDone = 1900042,
    ErrAdventureTaskReward = 1900043,
    ErrChapterReward = 1900044,
    ErrSilentFirstPassStatus = 1900045,
    ErrSilentFirstPassReward = 1900046,
    ErrPayShopEchoRole = 1900047,
    ErrPayShopEchoItemOver = 1900048,
    ErrDailyAdventureActivityInit = 1900049,
    ErrDailyAdventureActivityPtEnough = 1900050,
    ErrDailyAdventureActivityRewardDone = 1900051,
    ErrDailyAdventureActivityRewardTake = 1900052,
    ErrDailyAdventureActivityTaskDone = 1900053,
    ErrRoleTrialTimeOut = 1900054,
    ErrFriendRemarkNull = 1900055,
    ErrTrackMoonRoleUnLock = 1900056,
    ErrTrackMoonTrigger = 1900057,
    ErrTrackMoonBuildingUnLock = 1900058,
    ErrTrackMoonBuildingCurve = 1900059,
    ErrTrackMoonBuildingLock = 1900060,
    ErrMoonEntrustCfg = 1900061,
    ErrMoonRoleCfg = 1900062,
    ErrMoonRoleTrailCurve = 1900063,
    ErrMoonBuildingCfg = 1900064,
    ErrMoonItemConsume = 1900065,
    ErrDirtyWordDeserialize = 1900066,
    ErrMoonTargetNoFinish = 1900067,
    ErrMoonActivityReward = 1900068,
    ErrMoonActivityOpen = 1900069,
    ErrCircumDoReward = 1900070,
    ErrRetrunRewardCfg = 1900071,
    ErrRetrunRewardLevel = 1900072,
    ErrRetrunHaddone = 1900073,
    ErrSignRewardCfg = 1900074,
    ErrCircumSignHadRwd = 1900075,
    ErrCircumNoSign = 1900076,
    ErrScoreRewardCfg = 1900077,
    ErrCircumScoreHadRwd = 1900078,
    ErrCircumScoreLack = 1900079,
    ErrCircumTaskNoFinish = 1900080,
    LoginServiceInvalidToken = 1900081,
    LoginFusing = 1900082,
    LoginRateLimiterRejected = 1900083,
    LoginTimeoutRejected = 1900084,
    AccountInputErr = 1900085,
    DevInvalidLoginType = 1900086,
    GARInvalidLoginType = 1900087,
    GARDevInvalidLoginType = 1900088,
    SdkserverTimeOut = 1900089,
    ReconnectInvalidOperation = 1900090,
    PbMessageAppVersionNotMatch = 1900091,
    ErrPluginReconnectIpWhiteList = 1900092,
    NotInUserIdWhiteListWithChannel = 1900093,
    ErrPluginReconnectChannelWhiteList = 1900094,
    PluginPlayerLoggingIn = 1900095,
    LoginFusing2 = 1900096,
    SoundBoxExploreFull = 1900097,
    ErrMoonEntrustNoData = 1900098,
    ErrMoonMoneyNotEnough = 1900099,
    ErrCircumFluenceTimeIn = 1900100,
    DragonPoolRewardWayErr = 1900101,
    DragonPoolNoHandIn = 1900102,
    WeaponSkinNoEquiped = 1900103,
    WeaponSkinDataErr = 1900104,
    WeaponSkinUnLockErr = 1900105,
    WeaponSkinEquipDone = 1900106,
    WeaponSkinTypeErr = 1900107,
    FriendOfflineMsgErr = 1900108,
    FindSpringSignConfigErr = 1900109,
    SpringSignDataErr = 1900110,
    SpringSignRewardDone = 1900111,
    SpringSignRewardGetErr = 1900112,
    SpringSignNoOpen = 1900113,
    SpringSignNoTask = 1900114,
    SpringSignInviteNum = 1900115,
    SpringSignRolePool = 1900116,
    SpringSignDrawPoolNull = 1900117,
    FarmGoldActivityNotOpen = 1900118,
    FarmGoldActivityPointReceived = 1900119,
    FarmGoldActivityPointNotConfig = 1900120,
    FarmGoldActivityPointNotEnough = 1900121,
    FarmGoldActivityLevelNoData = 1900122,
    FarmGoldActivityLevelReceived = 1900123,
    FarmGoldActivityLevelNotConfig = 1900124,
    FarmGoldActivityLevelDiffNotConfig = 1900125,
    FarmGoldInstIdInValid = 1900126,
    FarmGoldVarNotExist = 1900127,
    FarmGoldResultCacheNotExist = 1900128,
    FarmGoldInstNotOpen = 1900129,
    FarmGoldActivityLimitDataNotFind = 1900130,
    MapTravelDataErr = 1900131,
    MapTravelConfigErr = 1900132,
    MapTravelCannotReward = 1900133,
    MapTravelRewardGet = 1900134,
    MapTravelMaxLevel = 1900135,
    MapTravelLackExp = 1900136,
    FarmGoldLevelNotOpen = 1900137,
    MapTravelAreaLock = 1900138,
    MapTravelAreaConfigErr = 1900139,
    SlashAndTowerCacheErr = 1900142,
    SlashAndTowerConfigErr = 1900143,
    SlashAndTowerDataErr = 1900144,
    SlashAndTowerReceivedLevelAward = 1900145,
    SlashAndTowerNotReward = 1900146,
    SlashAndTowerRoleNum = 1900147,
    SlashAndTowerBuffNum = 1900148,
    SlashAndTowerBuffConfig = 1900149,
    SlashAndTowerBuffAccess = 1900150,
    SlashAndTowerRoleSame = 1900151,
    SlashAndTowerSeasonErr = 1900152,
    SlashAndTowerBuffLack = 1900153,
    MapTravelLevelUpCfgErr = 1900140,
    MapTravelLevelCfgErr = 1900141,
    TeamParkOurTaskCfgErr = 1900154,
    TeamParkOurDataErr = 1900155,
    TeamParkOurCfgNoMatch = 1900156,
    TeamParkOurTaskDoing = 1900157,
    TeamParkOurTaskTaken = 1900158,
    TeamParkOurLevelLock = 1900159,
    TeamParkOurFindNoLevel = 1900160,
    SlashAndTowerRewardErr = 1900161,
    SlashAndTowerBuffSeasonErr = 1900162,
    SlashAndTowerNotOpen = 1900163,
    SlashAndTowerSeasonToCfgErr = 1900164,
    SlashAndTowerSeasonNoUpdate = 1900165,
    SlashAndTowerFirstNoPass = 1900166,
    SlashAndTowerLevelErr = 1900167,
    TeamParkMemberErr = 1900168,
    AvignonNotOpen = 1900172,
    AvignonNotConfig = 1900173,
    AvignonTaskNotFinish = 1900174,
    AvignonTaskNotData = 1900175,
    AvignonHadReward = 1900176,
    SlashAndTowerTeamErr = 1900169,
    SlashAndTowerBuffErr = 1900170,
    SeasonTowerNoMatch = 1900171,
    TeamParkOurMemberErr = 1900177,
    BattlePassRewardDone = 1900178,
    SlashAndTowerAwardCfgErr = 1900179,
    NoFlySkinItem = 1900180,
    FlySkinHadWear = 1900181,
    NoOldFlySkinItem = 1900182,
    OldFlySkinNoWear = 1900183,
    RoleWearNoFlySkin = 1900184,
    FlySkinParaGliderNoOpen = 1900185,
    FlySkinSoaringWingNoOpen = 1900186,
    NoRoleWearFlySkinSucc = 1900187,
    FlySkinItemNoConfig = 1900188,
    SlashAndTowerLevelSettle = 1900189,
    FlySkinTypeErr = 1900190,
    FlySkinTrialRole = 1900191,
    RegreeNotOpen = 1900192,
    RegressNoConfig = 1900193,
    RegressWrongId = 1900194,
    NoRegressRoundData = 1900195,
    NotInRegress = 1900196,
    AskRewardNoFinish = 1900197,
    BirthdayNotArrived = 1900198,
    BirthdayRoleInvalid = 1900199,
    BirthdayNoCfg = 1900200,
    HadBirthDayReward = 1900201,
    BirthdayNoReset = 1900202,
    BirthDayRewardTimeInvalid = 1900203,
    BirthdayMustNowYear = 1900204,
    BirthDayNotOpen = 1900205,
    BirthDayRewardNotFinish = 1900206,
    BirthdayRoleDone = 1900207,
    MoraleNoRewardGet = 1900208,
    FloroNoRanchData = 1900209,
    FloroNoRanchTech = 1900210,
    FloroTechUnLock = 1900211,
    FloroPreNodeLock = 1900212,
    FloroTechPoint = 1900213,
    FloroNoFindActivityTask = 1900214,
    FloroNoFindTaskCfg = 1900215,
    FloroTaskIsRunning = 1900216,
    FloroTaskInValidTime = 1900217,
    FloroRewardDone = 1900218,
    FloroMilestoneNoFind = 1900219,
    FloroDropNoFind = 1900220,
    FloroNoReward = 1900221,
    FloroActivityParamErr = 1900222,
    ConditionTimeOut = 1900223,
    ConditionModuleErr = 1900224,
    ConditionGroupIdErr = 1900225,
    ConditionRegisterFail = 1900226,
    FloroRanchSetAgain = 1900227,
    MoonPhaseNoOpen = 1900228,
    MoonPhaseNoCount = 1900229,
    ErrRandomDone = 1900230,
    PhaseMoonRandomErr = 1900231,
    PhaseMoonCfgErr = 1900232,
    MoonLabelErr = 1900233,
    MoonPhaseRewardErr = 1900234,
    MoonPhaseRewardDone = 1900235,
    PhaseMoonItemErr = 1900236,
    MoonPhaseBuffFail = 1900237,
    CoopRoleMaxLevelErr = 1900238,
    CoopRoleNoUnLock = 1900239,
    CoopRoleSpRewradErr = 1900240,
    CoopRoleRewardErr = 1900241,
    NoRewardCanGain = 1900242,
    CoopRoleDataErr = 1900243,
    CoopIdErr = 1900244,
    MotorcycleMotorIpErr = 1900245,
    MotorcycleRewardEmpty = 1900246,
    RoadBookNotData = 1900247,
    RoadBookNotInOpen = 1900248,
    RoadBookTaskCannotReward = 1900249,
    RoadBookRewardHad = 1900250,
    RoadBookOverMaxLevel = 1900251,
    RoadBookCfgErr = 1900252,
    RoadBookTaskLock = 1900253,
    RoadBookChallengeScoreErr = 1900254,
    RoadBookDuplicateReward = 1900255,
    RoadBookNoRewardGet = 1900256,
    GuessJokerLevelErr = 1900257,
    GuessJokerNotInScene = 1900258,
    GuessJokerNotGameObj = 1900259,
    GuessJokerPlayCardErr = 1900260,
    GuessJokerActionPhaseErr = 1900261,
    GuessJokerDeckErr = 1900262,
    GuessJokerNoHandCard = 1900263,
    GuessJokerBanCard = 1900264,
    GuessJokerOnlyPair = 1900265,
    GuessJokerPairAll = 1900266,
    GuessJokerCardRefuse = 1900267,
    GuessJokerDrawCardErr = 1900268,
    JokerSkillTriggerFail = 1900269,
    JokerSkillNoConfig = 1900270,
    JokerSkillOwnerErr = 1900271,
    GuessJokerPlayCardOver = 1900272,
    GuessJokerPlayCardAgain = 1900273,
    JokerGuessLevelLock = 1900274,
    JokerGuessPreLevelLock = 1900275,
    GuessJokerInitErr = 1900276,
    NoDrinkRequireListConfig = 1900277,
    DrinkBaseCountError = 1900278,
    DrinkBaseNoConfig = 1900279,
    DrinkBatchingCountErr = 1900280,
    DrinkBatchingConfigErr = 1900281,
    DrinkOrnaNoConfig = 1900282,
    DrinkRoleLikeNoConfig = 1900283,
    DrinkLikePointErr = 1900284,
    GuessJokerScriptPlayErr = 1900285,
    GuessJokerScriptDrawErr = 1900286,
    GuessJokerNoPlayerWait = 1900287,
    GuessJokerSkillUseOver = 1900288,
    DrinkBatchingRepeate = 1900289,
    SpringFestivalNoReward = 1900290,
    SpringFestivalDropNoFind = 1900291,
    SpringFestivalTaskRunning = 1900292,
    SpringFestivalHadReward = 1900293,
    SpringFestivalActivityIdErr = 1900294,
    SpringFestivalTaskFindErr = 1900295,
    SpringFestivalNoActivityCfg = 1900296,
    SpringFestivalParamCountErr = 1900297,
    SpringFestivalParamAgainErr = 1900298,
    PayShopGoodsIdRepeatErr = 1900299,
    PayShopBindActivityErr = 1900300,
    PayShopActivityFromErr = 1900301,
    PayShopFromErr = 1900302,
    ErrPayShopGoodsTypeCountOverFlow = 1900303,
    ErrPayShopTotalCountOverFlow = 1900304,
    ErrRegressDevelopTask = 1900305,
    ErrRegressVersion = 1900306,
    DrinksLevelLock = 1900307,
    DrinksRoleInviteErr = 1900308,
    DrinksNoRoleData = 1900309,
    GuessJokerTraceOver = 1900310,
    GuessJokerDataErr = 1900311,
    GuessJokerTaskRunning = 1900312,
    GuessJokerTaskDone = 1900313,
    DrinksRewardTaskRunning = 1900314,
    DrinksRewardTaskDone = 1900315,
    CoopReqLenthOver = 1900316,
    CoopRewardIdErr = 1900317,
    CoopRewardConfigNotFind = 1900318,
    CoopRewardDiff = 1900319,
    CoopActivityDataErr = 1900320,
    CoopRewardDone = 1900321,
    CoopRewardNoFinish = 1900322,
    CoopItemDropErr = 1900323,
    CoopItemDropErr2 = 1900324,
    PinballParamLimitOver = 1900325,
    PinballTaskConfigLoss = 1900326,
    PinballActivityErr = 1900327,
    PinballActivityHadReward = 1900328,
    PinballActivityTaskRunning = 1900329,
    PinballActivityTaskDropNoFind = 1900330,
    PinballActivityTaskParamAgainErr = 1900331,
    PinballActivityTaskNoReward = 1900332,
    PinballRoleAddLevelErr = 1900333,
    PinballRoleConfigLoss = 1900334,
    PinballRoleDataLoss = 1900335,
    PinballRoleDataMaxLvLoss = 1900336,
    PinballRoleMaxLvErr = 1900337,
    PinballActivityConfigLoss = 1900338,
    PinballRoleExpItemLack = 1900339,
    PinballWeaponIsTrail = 1900340,
    PinballWeaponNoExist = 1900341,
    PinballWeaponConfigNoExist = 1900342,
    PinballRoleNoExist = 1900343,
    PinballRoleConfigNoExist = 1900344,
    PinballWeaponRoleMismatch = 1900345,
    PinballPersonWeaponChangeErr = 1900346,
    PinballWearRepeat = 1900347,
    PinballWeaponOverLimit = 1900348,
    PinballWeaponRepeat = 1900349,
    PinballWeaponLock = 1900350,
    PinballWeaponIsEquip = 1900351,
    PinballWeaponNoDel = 1900352,
    ActivityRewardParamOver = 1900353,
    ActivityNotSame = 1900354,
    ActivityRewardDropErr = 1900355,
    ActivityNoRewardCanGet = 1900356,
    ActivityTaskTimeErr = 1900357,
    ActivityTaskRewardRepeat = 1900358,
    ActivityDataNotFind = 1900359,
    PinballWeaponInitErr = 1900360,
    PinballNoFriend = 1900361,
    PinballTowerRankCd = 1900362,
    PinballRankDataEmpty = 1900363,
    PinballLevelLock = 1900364,
    PinballDailyInstErr = 1900365,
    PinballRoleNotOpen = 1900366,
    PinballDailyNotOpen = 1900367,
    PinballWeaponPersonMismatch = 1900368,
    NoRoleVoiceDataSet = 1900369,
    RoleVoiceSettingParamOver = 1900370,
    RoleVoiceParamRepeat = 1900371,
    PlayerUsingSkill = 1900372,
    PlayerClimbing = 1900373,
    PlayerInWater = 1900374,
    PlayerInAir = 1900375,
    OnlineMotorLevelLock = 1900376,
    OnlineMotorMemberErr = 1900377,
    OnlineMotorMemberActivityClose = 1900378,
    RealmBetweenOverMaxLevel = 1900379,
    ActivityTaskLock = 1900380,
    ErrRecallItemBagItemTypeNotSupport = 1900381,
    ErrRecallItemBagFull = 1900382,
    ActivityPlayingCanNotDissolve = 1900383,
    ErrRecallActionNotSupport = 1900384,
    ErrAdventureSilentCtxNull = 1900385,
    ErrAdventureSilentId = 1900386,
    RoverRogueTalentAlreadyUnlock = 1900387,
    RoverRoguePreTalentNotUnlock = 1900388,
    RoverRogueTalentConditionNotFinish = 1900389,
    ErrMailFavoriteCannotDelete = 1900390,
    ErrMailFavoriteNeedRead = 1900391,
    ErrMailFavoriteNeedTake = 1900392,
    ErrMailFavoriteFull = 1900393,
    ErrPhantomItemUse = 1900394,
    ErrRoleTrailItemUse = 1900395,
    ErrInFlowItemUse = 1900396,
    ErrInVehicleItemUse = 1900397,
    ErrZitherNoMainRoleInFormation = 1900398,
    ErrTrialFollowShooterItemUse = 1900399,
    ErrDoCommonRewardConfigError = 2000000,
    InstPlayNotSettle = 2000001,
    InstPlayNotFinishExecute = 2000002,
    ErrResetItemEntityNotContain = 2000003,
    InstPlayExchangeRewardNotExist = 2000004,
    MapConfigNull = 2000005,
    MapConfigError = 2000006,
    InstPlayComponentNotExist = 2000007,
    InstTeleportResetPlayerDead = 2000008,
    DrownEndTeleportInBigWorld = 2000009,
    ErrFightTrialRoleRoldIdsError = 2000010,
    ErrFightTrialRoleFromationError = 2000011,
    ErrInstSaveFail = 2000012,
    ErrActiveFoundationControlPlayerError = 2000013,
    ErrActiveFoundationOccupation = 2000014,
    ErrSingleInstanceCanNotOnline = 2000015,
    ErrInstanceRechallengeLimit = 2000016,
    ErrTargetSame = 2000017,
    ErrAttachTargetType = 2000018,
    ErrAttachInfoNull = 2000019,
    ErrLevelPlayChallengeFail = 2000020,
    ErrGMTip = 2000021,
    ErrPosSenderEntityNoExist = 2000022,
    ErrPosSenderComponentNoExist = 2000023,
    ErrPosSenderParamError = 2000024,
    ErrPosSenderRemoveSenderNotSame = 2000025,
    ErrConnectorEntityNoExist = 2000026,
    ErrConnectorCompNoExist = 2000027,
    ErrConnectorPreIdError = 2000028,
    ErrConnectorCompleteState = 2000029,
    ErrConnectorActiveStateError = 2000030,
    ErrConnectorMatchErro = 2000031,
    ErrActiveControlOccupation = 2000032,
    ErrPortalCreatorActive = 2000033,
    ErrComponentNull = 2000034,
    ErrPortalCreatorConfigError = 2000035,
    ErrPortalCreatorCreateFail = 2000036,
    ErrTrialRoleEnterInst = 2000037,
    ErrNpcInVehicle = 2000038,
    ErrSceneItemBBNotChange = 2000039,
    ErrInitMatchNotSuccess = 2000040,
    ErrFightFormationSameRoleError = 2000041,
    ErrFightMainRoleConflict = 2000042,
    ErrVehicleItemConfigError = 2000043,
    ErrVehicleCreateError = 2000044,
    ErrVehicleEntityTypeError = 2000045,
    ErrInstanceActivityExpire = 2000046,
    ErrSlashAndTowerLevelUnlock = 2000047,
    ErrInstLevelUnlock = 2000048,
    ErrEnterInstConfigError = 2000049,
    ErrMoveWithSplineConfigError = 2000050,
    ErrMoveWithSplineIdError = 2000051,
    ErrMoveWithSplineStop = 2000052,
    ErrMoveWithSplineEntityConfigError = 2000053,
    ErrMoveWithSplineControlPlayerError = 2000054,
    ErrLeaveSceneStarted = 2000055,
    ErrInstTeleportInstLimit = 2000056,
    ErrGetOnVehicleNotInAoiSight = 2000057,
    ErrHoldHandCharacterNotCurrent = 2000058,
    ErrEnterInstPreInstNotComplete = 2000059,
    ErrSetSystemVarError = 2000060,
    ErrSetVarPermission = 2000061,
    ErrSetVarCtxError = 2000062,
    ErrSetVarGameCtxSceneError = 2000063,
    ErrSetVarNotPublic = 2000064,
    ErrSetVarComponent = 2000065,
    ErrSetVarTargetNull = 2000066,
    ErrVehicleNotMotor = 2000067,
    ErrVehicleFormationError = 2000068,
    ErrShareRideConflict = 2000069,
    ErrShareRideNotExist = 2000070,
    ErrNotInShareRide = 2000071,
    ErrNotInVehicle = 2000072,
    ErrSceneRoadGraphNotExist = 2000073,
    ErrVehicleFlowRewardMax = 2000074,
    ErrGetOnVehicleFailInFlow = 2000075,
    ErrGetOnPlayerVechielGravityDifferent = 2000076,
    ErrChangeFightState = 2100000,
    ErrAddFragileFail = 2100001,
    ErrStoreEnergyClose = 2100002,
    ErrAttrOverMax = 2100003,
    ErrBattleVersion = 2100004,
    ErrGmkillEntityNotValid = 2200000,
    ErrSplineConfigNotExist = 2200001,
    BossRushActivityNotOpen = 2200002,
    BossRushActivityScoreRewardNotExist = 2200003,
    BossRushActivityLevelRewardNotExist = 2200004,
    BossRushActivityScoreNotEnough = 2200005,
    BossRushActivityLevelNotPass = 2200006,
    BossRushActivityRewardClaimed = 2200007,
    BossRushActivityBuffSelectionNotValid = 2200008,
    BossRushActivityConfigNotExist = 2200009,
    BossRushActivityCharacterSelectionNotValid = 2200010,
    BossRushActivityComponentNotExist = 2200011,
    BossRushActivityCharacterSelectionEmpty = 2200012,
    BossRushActivityBuffSelectionEmpty = 2200013,
    BossRushActivityLevelNotOpen = 2200014,
    InRangeEntityDuplicate = 2200015,
    InRangeEntityNotExist = 2200016,
    NpcPerformComponentNotExist = 2200017,
    NpcPerformStateNotInit = 2200018,
    NpcPerformActionTargetEntityNotExist = 2200019,
    ActionQueueTypeNotExist = 2200020,
    ActionQueueCtxTypeNotExist = 2200021,
    ExecuteQueueOwnerHasAction = 2200022,
    ActionQueueExceedMaxCount = 2200023,
    ActionQueueStartActionGroupFail = 2200024,
    ActionQueueComponentNotExist = 2200025,
    ActionQueueNotInit = 2200026,
    ChangeBatchEntitiesStateError = 2200027,
    EnableNearbyTrackingTargetEntityNotExist = 2200028,
    EnableNearbyTrackingSelfNotEntity = 2200029,
    EnableNearbyTrackingSelfComponentNotExist = 2200030,
    SetTeleControlEntityNotExist = 2200031,
    SetTeleControlTypeNotExist = 2200032,
    SetTeleControlComponentNotExist = 2200033,
    SetTeleControlCoordEntityNotExist = 2200034,
    SceneItemAttributeIdNotInType = 2200035,
    SceneItemAttributeIdNotExist = 2200036,
    ModifySceneItemAttributeEntityNotExist = 2200037,
    AddSceneItemAttributeTagDuplicate = 2200038,
    RemoveSceneItemAttributeTagNotExist = 2200039,
    AttributeEntityLock = 2200040,
    AttributeEntitySilent = 2200041,
    ModifySceneItemAttributeTagNotExist = 2200042,
    ErrEnterInstCtx = 2200043,
    ErrEnterInstBlackboardValueNotExist = 2200044,
    TriggerLocked = 2200045,
    TriggerIgnore = 2200046,
    TriggerEntityNull = 2200047,
    TriggerEntityNotMatch = 2200048,
    TriggerMatchCountNotMet = 2200049,
    TriggerActionEmpty = 2200050,
    ExceedMaxTriggerCount = 2200051,
    TriggerAlreadyLeaveWhenEnterCondFail = 2200052,
    TriggerLeaveConfigEmpty = 2200053,
    TriggerConditionNotMet = 2200054,
    TriggerRangeRationalityFail = 2200055,
    TrampleEntityNotMatch = 2200056,
    TrampleConditionNotMet = 2200057,
    TrampleMatchCountNotMet = 2200058,
    HasDestroySelfActionInQueue = 2200059,
    EntityWillDestroy = 2200060,
    AddInRangePlayerDuplicate = 2200061,
    AddInRangeEntityDuplicate = 2200062,
    RemoveInRangePlayerNotExist = 2200063,
    RemoveInRangeEntityNotExist = 2200064,
    GravityDirectionNoChange = 2200072,
    HookExitWayNotExist = 2200065,
    HookLockPointLocked = 2200066,
    HookLockAddPlayerDuplicate = 2200067,
    HookLockRemovePlayerNotExist = 2200068,
    KiteHookLockPointOnlyOnePlayer = 2200069,
    EffectAreaAddBuffFail = 2200073,
    ErrGravityInteractNoPermission = 2200074,
    PlayerNotInAnyGravityRegion = 2200075,
    ErrSceneEntityAlreadyExist = 2200070,
    PlayerLeaveGravityRegionInAbnormalGravity = 2200076,
    HookLockPointConditionNotMet = 2200071,
    PlayerInAbnormalGravity = 2200077,
    GravityFlipIndexNoChange = 2200078,
    GravityFlipIndexNotExist = 2200079,
    GravityFlipTypeNoChange = 2200080,
    GravityFlipTypeNotExist = 2200081,
    GravityFlipNotUpdateToTargetDirection = 2200082,
    ReliablePosNotInGravityRegion = 2200083,
    TargetPosNotInGravityRegion = 2200084,
    PlayerCurGravityDirectionNotInOptions = 2200085,
    WaterfallClimbingParticipatorCountErr = 2200086,
    WaterfallClimbingParticipatorNoVehicle = 2200087,
    WaterfallClimbingVehicleNoPassenger = 2200088,
    WaterfallClimbingPlayerNotInPassenger = 2200089,
    ErrVehicleEntityNotExist = 2200090,
    GravityFlipLocked = 2200091,
    ClientActionSkipped = 2200092,
    AbnormalGravityCannotAddTemporary = 2200093,
    ErrReliablePosEntityNotExist = 2200094,
    UpdateReliablePosGravityDirNotMatch = 2200095,
    UpdateReliablePosNotWalkable = 2200096,
    UpdateReliablePosSelfNotEntity = 2200097,
    GravityDirectionHasNaN = 2200098,
    ErrHostInAbnormalGravity = 2200099,
    MultiModeCannotTeleport = 2200100,
    NotTrapDefenseInst = 2200101,
    GridCellCreateFuncNotFound = 2200102,
    GridSystemNotExist = 2200103,
    ErrGridCellType = 2200104,
    GridCellDirectionNotSpecified = 2200105,
    NotGridObjectEntity = 2200106,
    GridNotExist = 2200107,
    GridCellNotExist = 2200108,
    GridCellAlreadyOccupied = 2200109,
    GridCellDisabled = 2200110,
    GridCellPositionNotValid = 2200111,
    SimpleCombatEntityNotMonster = 2200112,
    GridObjectEntityNotFound = 2200113,
    NotLowMemoryPlatform = 2200114,
    ErrLowMemorySwitchingScene = 2200115,
    SimpleCombatEntityBuffNotExist = 2200116,
    SimpleCombatEntityBuffDuplicate = 2200117,
    TrapDefenseRandomBdFail = 2200118,
    TrapDefenseBdConfigNotExist = 2200119,
    TrapDefenseBdGroupConfigOfBdNotExist = 2200120,
    TrapDefenseRandomQualityFail = 2200121,
    TrapDefenseRandomBdGroupFail = 2200122,
    TrapDefenseBdGroupPoolEmpty = 2200123,
    TrapDefenseNoAvailableBd = 2200124,
    TrapDefenseNoAvailableQuality = 2200125,
    TrapDefenseDrawActionConfigNotExist = 2200126,
    TrapDefenseInstConfigNotExist = 2200127,
    TrapDefenseWaveConfigNotExist = 2200128,
    TrapDefenseSpawnMonsterWaveConfigNotExist = 2200129,
    TrapDefenseMonsterConfigNotExist = 2200130,
    TrapDefenseMonsterDataDuplicate = 2200131,
    TrapDefenseTrapConfigNotExist = 2200132,
    TrapDefenseTrapEntityNotFound = 2200133,
    TrapDefenseNotPreviewStep = 2200134,
    TrapDefenseBdGroupConfigNotExist = 2200135,
    TrapDefenseBdPoolEmpty = 2200136,
    TrapDefenseQualityPoolEmpty = 2200137,
    ErrTrapDefenseRequestParam = 2200138,
    ErrTrapDefenseRequestParamDuplicate = 2200139,
    ErrTrapDefenseRewardConfig = 2200140,
    ErrTrapDefenseRewardTime = 2200141,
    ErrTrapDefenseRewardReceived = 2200142,
    ErrTrapDefenseRewardNotComplete = 2200143,
    ErrTrapDefenseSceneErr = 2200144,
    ErrTrapDefenseContextEmpty = 2200145,
    ErrTrapDefenseChallengeConfig = 2200146,
    ErrTrapDefenseChallengeNotOpen = 2200147,
    ErrTrapDefenseBuildingLock = 2200148,
    ErrTrapDefenseAuxiliaryLock = 2200149,
    ErrTrapDefenseSlotCount = 2200150,
    ErrTrapDefenseSlotBuildingDuplicate = 2200151,
    ErrTrapDefenseSlotDuplicate = 2200152,
    ErrTrapDefenseBuildingConfig = 2200153,
    ErrTrapDefenseAuxiliaryConfig = 2200154,
    ErrTrapDefenseSlotAuxiliaryDuplicate = 2200155,
    ErrTrapDefenseForceBuilding = 2200156,
    ErrTrapDefenseForceAuxiliary = 2200157,
    ErrTrapDefenseBuildingLevelConfig = 2200158,
    ErrTrapDefenseBuildingMaxLevel = 2200159,
    ErrTrapDefenseActivityConfig = 2200160,
    ErrTrapDefenseAuxiliaryLevelConfig = 2200161,
    ErrTrapDefenseAuxiliaryMaxLevel = 2200162,
    ErrTrapDefenseAuxiliaryBranch = 2200163,
    ErrTrapDefenseBuildingBranch = 2200164,
    ErrTrapDefenseAuxiliaryReset = 2200165,
    ErrTrapDefenseBuildingReset = 2200166,
    ErrTrapDefenseTechConfig = 2200167,
    ErrTrapDefenseTechUnlock = 2200168,
    ErrTrapDefenseTechPreNodeConfig = 2200169,
    ErrTrapDefenseTechPreNodeLock = 2200170,
    ErrTrapDefenseTechCostNotEnough = 2200171,
    TrapDefenseItemConfigNotExist = 2200172,
    TrapDefenseItemExceedCarryLimit = 2200173,
    TrapDefenseItemNotEnough = 2200174,
    TrapDefenseBuyShopBdGroupNotExist = 2200175,
    TrapDefenseBuyShopItemNotExist = 2200176,
    TrapDefenseGoldNotEnough = 2200177,
    TrapDefensePayGoldFail = 2200178,
    TrapDefenseBuyShopItemNotEnough = 2200179,
    TrapDefenseShopDataNotExist = 2200180,
    TrapDefenseShopConfigNotExist = 2200181,
    TrapDefenseShopRefreshCountNotEnough = 2200182,
    TrapDefenseGoldenCoinConfigNotExist = 2200183,
    TrapDefenseNotGoldenCoinEntity = 2200184,
    TrapDefenseNotMonsterEntity = 2200185,
    TrapDefenseNotBuildingEntity = 2200186,
    TrapDefenseVarCannotUnderZero = 2200187,
    TrapDefenseVarTypeNotExist = 2200188,
    TrapDefenseBuyShopBdGroupSold = 2200189,
    TrapDefenseTrapAmountExceedLimit = 2200190,
    TrapDefenseNotRewardStep = 2200191,
    TrapDefenseBdDrawDataNotExist = 2200192,
    TrapDefenseBdDrawRefreshCountNotEnough = 2200193,
    TrapDefenseSpecialCellConfigNotExist = 2200194,
    TrapDefenseSpecialCellCertainLevelConfigNotExist = 2200195,
    ErrActionTargetEntityNotExist = 2200196,
    TrapDefenseCleanerNotEnough = 2200197,
    TrapDefenseItemConfigError = 2200198,
    TrapDefenseSpecialCellTypeNotSame = 2200199,
    TrapDefenseCellNotSpecialCell = 2200200,
    TrapDefenseExceedMaxTrapCount = 2200201,
    GridSystemCannotGetWorldGridPos = 2200202,
    TrapDefenseTrapCannotSelfDestruct = 2200203,
    TrapDefenseBdDrawResultEmpty = 2200204,
    TrapDefenseBdGroupMaxLevel = 2200205,
    TrapDefenseCannotDeductHealth = 2200206,
    SimpleCombatBuffConfigNotExist = 2200207,
    SimpleCombatSubTypeNotExist = 2200208,
    TrapDefenseBdGroupDisabled = 2200209,
    TrapDefenseMonsterDisabled = 2200210,
    TrapDefenseGainExceedLimit = 2200211,
    OnlyOneRollBlockCanBeActivated = 2200212,
    RollBlockGroupConfigNotExist = 2200213,
    RollBlockDifficultyConfigNotExist = 2200214,
    RollBlockNextDifficultyConfigNotExist = 2200215,
    RollBlockGamePlayIdNotExist = 2200216,
    RollBlockGamePlayNotExist = 2200217,
    RollBlockMovementEntityNotExist = 2200218,
    RollBlockMovementEntityNotBlock = 2200219,
    RollBlockMainControlPlayerNotExist = 2200220,
    RollBlockEntityNotMoving = 2200221,
    RollBlockNoGridAfterRoll = 2200222,
    RollBlockTemplateConfigNotExist = 2200223,
    RollBlockNotMainControlPlayer = 2200224,
    RollBlockEntityNotExist = 2200225,
    RollBlockBlockWillChangeState = 2200226,
    RollBlockBlockStateNoChange = 2200227,
    RollBlockMainControlBlockNotExist = 2200228,
    RollBlockDifficultyDataNotExist = 2200229,
    RollBlockPositionNoFloor = 2200230,
    RollBlockPositionItemCannotPass = 2200231,
    RollBlockPositionBlockCannotPass = 2200232,
    RollBlockInputCannotMove = 2200233,
    RollBlockPositionFloorCannotPass = 2200234,
    RollBlockHintAlreadyActive = 2200235,
    RollBlockHintBlockNotExist = 2200236,
    RollBlockHintEmpty = 2200237,
    RollBlockAlreadyRewarded = 2200238,
    RollBlockDifficultyNotPassed = 2200239,
    RollBlockHintStepNotExecuting = 2200240,
    RollBlockCurDifficultyConfigNotExist = 2200241,
    RollBlockHintStepExecuting = 2200242,
    RollBlockChildQuestGamePlayActived = 2200243,
    RollBlockOnlyOneControllableBlock = 2200244,
    RollBlockGamePlayStateNoChange = 2200245,
    RollBlockGamePlayCannotReady = 2200246,
    RollBlockGamePlayNotReady = 2200247,
    RollBlockSendResetTooFrequently = 2200248,
    EasterEggIdNotExist = 2200249,
    TargetSceneNotBigWorldInst = 2200250,
    EnterBigWorldInstCtxNotImplemented = 2200251,
    EasterEggOwnerTypeNotImplemented = 2200252,
    RollBlockCannotReset = 2200253,
    CurSceneNotBigWorld = 2200254,
    KurotatoCharacterConfigNotExist = 2200255,
    KurotatoLevelInfoNotExist = 2200256,
    KurotatoUpgradeRewardStepNotActive = 2200257,
    KurotatoUpgradeRewardItemNotFound = 2200258,
    KurotatoUpgradeRewardDataNotExist = 2200259,
    KurotatoActivityConfigNotExist = 2200260,
    KurotatoWeaponConfigNotExist = 2200261,
    KurotatoWeaponNotExist = 2200262,
    KurotatoItemConfigNotExist = 2200263,
    KurotatoItemNotExist = 2200264,
    KurotatoChestRewardStepNotActive = 2200265,
    KurotatoChestRewardItemNotExist = 2200266,
    KurotatoEffectConfigNotExist = 2200267,
    KurotatoEffectNotExist = 2200268,
    KurotatoDrawConfigNotExist = 2200269,
    KurotatoPropertyConfigNotExist = 2200270,
    KurotatoPropertyNotInSimpleCombatDefine = 2200271,
    KurotatoShopStepNotActive = 2200272,
    KurotatoShopProductNotFound = 2200273,
    KurotatoShopGoldNotEnough = 2200274,
    KurotatoVarNameNotExist = 2200275,
    KurotatoVarNotExist = 2200276,
    KurotatoRoleLevelConfigNotExist = 2200277,
    KurotatoCharacterEntityNotExist = 2200278,
    KurotatoGoldNotEnough = 2200279,
    KurotatoMonsterConfigNotExist = 2200280,
    KurotatoMultiModeNotSupported = 2200281,
    KurotatoLevelConfigNotExist = 2200282,
    KurotatoDropInfoNotExist = 2200283,
    KurotatoDropConfigNotExist = 2200284,
    KurotatoWaveConfigNotExist = 2200285,
    KurotatoWeaponCountReachLimit = 2200286,
    KurotatoWeaponRefineNotEnoughSameQuality = 2200287,
    KurotatoItemStackFull = 2200288,
    KurotatoCharacterUpgradeConfigNotExist = 2200289,
    KurotatoUpgradeRewardDrawIdNotExist = 2200290,
    KurotatoDrawResultEmpty = 2200291,
    KurotatoLuckPropertyNotExist = 2200292,
    KurotatoGoldGainPropertyNotExist = 2200293,
    KurotatoCharacterAlreadyExist = 2200294,
    KurotatoCombatStepNotActive = 2200295,
    KurotatoNotInSpecialWave = 2200296,
    KurotatoWeaponCountReachMin = 2200297,
    KurotatoNotSupportedProductType = 2200298,
    KurotatoStructureConfigNotExist = 2200299,
    KurotatoStructureCannotCreate = 2200300,
    NotQaAccountWithHIddenServer = 2300000,
    DisabledFuncInHIddenServer = 2300001,
    ErrActionExecutorFinishConditionNotSport = 2400000,
    ErrAlreadyInSwitchNode = 2400001,
    ErrCornActivityId = 2500000,
    ErrCornActivityNoOpen = 2500001,
    ErrCornNoActivityData = 2500002,
    NoPlayIdCorniceReward = 2500003,
    ActivityNoOpenCorniceReward = 2500004,
    ScoreLimitCorniceReward = 2500005,
    RewardedCorniceReward = 2500006,
    NoUnlockCorniceReward = 2500007,
    NoScoreCorniceReward = 2500008,
    TrackMoonPhaseNoConfig = 2500009,
    TrackMoonPhaseActivityNoOpen = 2500010,
    TrackMoonPhaseNoPolulary = 2500011,
    TrackMoonPhaseNoData = 2500012,
    TrackMoonPhaseRewarded = 2500013,
    TrackMoonPhaseDataNoConfig = 2500014,
    TrackMoonPhaseDataNoOpen = 2500015,
    TrackMoonPhaseDataNoData = 2500016,
    BCTRewardNoTConfig = 2500017,
    BCTRewardNoOpenActivity = 2500018,
    BCTRewardNoData = 2500019,
    BCTRewardNoUnlock = 2500020,
    BCTRewardNoComplete = 2500021,
    BCARewardNoRConfig = 2500022,
    BCARewardNoOpenActivity = 2500023,
    BCARewardNoData = 2500024,
    BCARewardNoActive = 2500025,
    BCARewarded = 2500026,
    BCARewardNoActiveReward = 2500027,
    CornTranNoPlayConfig = 2500028,
    CornTranNoOpenPlay = 2500029,
    CornTranNoOpenActivity = 2500030,
    CornTranNoEntityConfig = 2500031,
    BCARewardRepeatRewardId = 2500032,
    BCARewardDifferActivityId = 2500033,
    BCTRewardNoActivity = 2500034,
    BCTRewardIllegalRewardNum = 2500035,
    BCTRewardNoUnlockStage = 2500036,
    PreheatSignNodeNoConfig = 2500037,
    PreheatSignNodeNoData = 2500038,
    PreheatSignActivityOnOpen = 2500039,
    PreheatSignNodeNoUnlock = 2500040,
    PreheatSignNodeNoRewardStatus = 2500041,
    PreheatSignNodeNoAnswer = 2500042,
    ScratchCardNoRoundConfig = 2500043,
    ScratchCardNoActivityConfig = 2500044,
    ScratchCardNoDbData = 2500045,
    ScratchCardIllegalIndex = 2500046,
    ScratchCardIndexRewarded = 2500047,
    ScratchCardNoTime = 2500048,
    ScratchCardNoRandomReward = 2500049,
    ScratchCardRoundNoUnlock = 2500050,
    BossRushPlayerNoSceneData = 2500051,
    BossRushPlayerCanNoChooseBuff = 2500052,
    BossRushPlayerIllegalIndex = 2500053,
    BossRushHadSameBuffId = 2500054,
    BossRushBuffCountLimit = 2500055,
    BossRushBuffIllegal = 2500056,
    BossRushBuffNoConfig = 2500057,
    ScratchCardActivityNoOpen = 2500058,
    MowToweNoLevelConfig = 2500059,
    MowTowerActivityNoOpen = 2500060,
    MowToweNoCacheData = 2500061,
    MowTowerNoPassFirstInst = 2500062,
    MowTowerLevelsIdError = 2500063,
    MowTowerRoleIdError = 2500064,
    MowTowerBuffIdError = 2500065,
    MowTowerNoComponent = 2500066,
    MowTowerHadSameRole = 2500067,
    MowTowerBuffCountError = 2500068,
    MowTowerNoFirstInst = 2500069,
    MowTowerNoActivityData = 2500070,
    MowTowerScoreLimit = 2500071,
    MowTowerScoreRewarded = 2500072,
    MowTowerScoreRewardConfig = 2500073,
    MowTowerNoInScene = 2500074,
    MowTowerNoRewardConfig = 2500075,
    MaterialReplaceNoTargetConfig = 2500076,
    MaterialReplaceNoConsumeConfig = 2500077,
    MaterialReplaceNoSameGroup = 2500078,
    MaterialReplaceErrConsumeNum = 2500079,
    ErrRoleSkinTrialNotInit = 2500080,
    ErrRoleSkinTrialNoFinish = 2500081,
    ErrRoleSkinTrialReward = 2500082,
    ErrRoleSkinTrialRewardDone = 2500083,
    ErrRoleSkinTrialTimeOut = 2500084,
    PhantomEquipGroupNoEquipPhantom = 2500085,
    PhantomEquipGroupCountLimit = 2500086,
    PhantomEquipGroupHadInTop = 2500087,
    PhantomEquipGroupNameEmpty = 2500088,
    PhantomEquipGroupNameCountLimiy = 2500089,
    PhantomRecommendFuncNoOpen = 2500090,
    BossRushTaskNoFinish = 2500091,
    PhantomGroupUseSame = 2500092,
    PhantomGroupFunNoOpen = 2500093,
    NoFishingActivityConfig = 2500094,
    NoInFishingActivityTime = 2500095,
    FishingActivityCanNoReward = 2500096,
    NoFishingActivityMileConfig = 2500097,
    FishingActivitySameMileId = 2500098,
    FishingActivityRewarded = 2500099,
    PlayerTitleFuncNoOpen = 2500100,
    PlayerTitleHadUndress = 2500101,
    PlayerTitleHadDress = 2500102,
    PlayerTitleNoUnlock = 2500103,
    BabelTowerActivityNoOpen = 2500104,
    BabelTowerLevelNoOpen = 2500105,
    BabelTowerDeEffectNoFind = 2500106,
    BabelTowerDeEffectCanNoChoose = 2500107,
    BabelTowerDeEffectMutex = 2500108,
    BabelTowerNoDailyTask = 2500109,
    BabelTowerTaskNoComplete = 2500110,
    BabelTowerTaskRewarded = 2500111,
    BabelTowerRoleLimit = 2500112,
    BabelTowerNoBuffConfig = 2500113,
    BabelTowerBuffCanNoChoose = 2500114,
    BabelTowerBuffNumIllegal = 2500115,
    BabelTowerBuffChooseCountLimit = 2500116,
    NoBabelTowerInsComponent = 2500117,
    BabelTowerNoSelectBuff = 2500118,
    PhantomPolishFuncNoOpen = 2500119,
    PhantomPolishHadLevelUp = 2500120,
    PhantomPolishQualityLimit = 2500121,
    PhantomPolishSamePro = 2500122,
    ExploreActivityNoOpen = 2500123,
    ExploreActivityTaskNoFinish = 2500124,
    ExploreActivityTaskRewarded = 2500125,
    BabelTowerDeTermNoUnlock = 2500126,
    BabelTowerBuffNoUnlock = 2500127,
    BabelTowerIsNoDifficult = 2500128,
    PlayerTitleNoConfig = 2500129,
    PlayerFixIndexIllegal = 2500130,
    PlayerFixHadFlag = 2500131,
    PlayerFixFrontNoFlag = 2500132,
    BabelTowerNoSelectRoles = 2500133,
    PhBaErrSelectNum = 2500134,
    PhBaErrSelectTarget = 2500135,
    PhBaNoFighterLogic = 2500136,
    PhBaNoChallengeConf = 2500137,
    PhBaSlotIllegal = 2500138,
    PhBaNoEvolveNum = 2500139,
    PhBaNoFighter = 2500140,
    PhBaNoHandCard = 2500141,
    PhBaNoCardConf = 2500142,
    PhBaNoCardEvolveCountInValid = 2500143,
    PhBaErrCostNoMatch = 2500144,
    PhBaNoCardRoleConf = 2500145,
    PhBaNoContainSkill = 2500146,
    PhBaNoSkillConf = 2500147,
    PhBaNoCardCanNoUse = 2500148,
    PhBaIsWaitClient = 2500149,
    PhBaNoDeployRound = 2500150,
    PhBaNoClientParam = 2500151,
    PhBaNoClientParamMatch = 2500152,
    PhBaErrSelectCardNum = 2500153,
    PhBaErrSelectReplace = 2500154,
    PhBaErrPreStep = 2500155,
    PhBaCanNoSelect = 2500156,
    PhBaConditionLimit = 2500157,
    PhBaNoOwnerFighter = 2500158,
    PhBaNoTriggerFighter = 2500159,
    PhBaSelectParamNull = 2500160,
    PhBaNoBuffData = 2500161,
    PhBaNoBuffConf = 2500162,
    PhBaErrCardGroupIndex = 2500163,
    PhBaCardRoleUnlock = 2500164,
    PhBaNoCardGroupConf = 2500165,
    PhBaSloFull = 2500166,
    PhBaHandCardEmpty = 2500167,
    PbSelectCardNotFound = 2500168,
    PbSelectCardCount = 2500169,
    PbNoNpcFighter = 2500170,
    PbNoPlayerFighter = 2500171,
    PbBTEventDataIllegal = 2500172,
    PbNoCardFighter = 2500173,
    PbNoHandCardVarData = 2500174,
    PbNoPosVarData = 2500175,
    PbNoHandCard = 2500176,
    PbNoCardFighterVarData = 2500177,
    PbNoNpcConfig = 2500178,
    PbNoCostPoint = 2500179,
    PbNoActiveSkill = 2500180,
    PbErrSelectTargets = 2500181,
    PbErrHadFighter = 2500182,
    PbErrCardUnmovable = 2500183,
    PbNoCanSelectTarget = 2500184,
    PbCanNotOpOtherUnit = 2500185,
    PbCanNoBeEvolve = 2500186,
    PbKeyCostCanNotOp = 2500187,
    PbNoReChallenge = 2500188,
    PbFuncNoOpen = 2500189,
    PbNoRequestReChallenge = 2500190,
    PbNoSameSlotIndex = 2500191,
    PhBaHaCardEmpty = 2500192,
    PhBaPassedChallenge = 2500193,
    FunPlayNoConfig = 2500194,
    FunPlayNoFinish = 2500195,
    FunPlayHadRewarded = 2500196,
    PbCardSkillCountLimit = 2500197,
    BabelRoleIsSelected = 2500248,
    BabelNoTalentConfig = 2500249,
    BabelInnerCanNoOpe = 2500250,
    BabelTalentIsLearned = 2500251,
    BabelTalentNoFinish = 2500252,
    BabelNoActivityConfig = 2500253,
    BabelRankListInCd = 2500254,
    FunPlayDayNoOpen = 2500255,
    CheckShopConditionFail = 2500262,
    HonamiStoryBagUpdateRepeat = 2500263,
    HonamiStoryBagNoConfig = 2500264,
    HonamiStoryNormalAddItemErr = 2500265,
    HonamiStoryNoBagDb = 2500266,
    HonamiStoryUpdateItemSizeIllegal = 2500267,
    HonamiStoryItemUpdateRepeat = 2500268,
    HonamiStoryBagHadItem = 2500269,
    HonamiStoryBagPosIllegal = 2500270,
    HonamiStoryItemUpdateTypeErr = 2500271,
    HonamiStoryBagNoHadItem = 2500272,
    HonamiStoryDropItemNoEntityId = 2500273,
    HonamiStoryDropItemNoEntity = 2500274,
    HonamiStoryNoDropEntity = 2500275,
    HonamiStoryDropNoItemDb = 2500276,
    HonamiStoryItemNoBalance = 2500277,
    HonamiStoryNoUpdateItem = 2500278,
    HonamiStoryCheckMarkNoItemConfig = 2500279,
    HonamiStoryCheckMarkOverSize = 2500280,
    HonamiStoryCheckWideOverSize = 2500281,
    HonamiStoryCheckMarkRepeat = 2500282,
    HonamiStoryActivityNoSame = 2500283,
    HonamiStoryNoEquipRackData = 2500284,
    HonamiStoryNoEquipType = 2500285,
    HonamiStoryNoEquipConfig = 2500286,
    HonamiStoryNoEquipTypeNoMatch = 2500287,
    HonamiStoryActivityIdErr = 2500288,
    HonamiStoryInnerCanNoModifyRole = 2500289,
    HonamiStoryRoleNoValid = 2500290,
    HonamiStoryNoChallengeConfig = 2500291,
    NoHonamiStoryInstType = 2500292,
    HonamiStoryNoItemConfig = 2500293,
    HonamiStoryPickDistanceErr = 2500294,
    HonamiStoryNoDressWeapon = 2500295,
    HonamiStoryNoWeaponConfig = 2500296,
    HonamiStoryWeaponPluginPosErr = 2500297,
    HonamiStoryWeaponPluginTypeNoMatch = 2500298,
    HonamiStoryWareHouseOverSize = 2500299,
    HonamiStoryNoOpenSafeBag = 2500300,
    HonamiStoryNoOpenSafeBagItem = 2500301,
    HonamiStoryBagTypeNoMatch = 2500302,
    HonamiStoryWeaponPluginNoUnDress = 2500303,
    HonamiStoryChangeItemPosSame = 2500304,
    HonamiStoryEquipPosError = 2500305,
    HonamiStoryEquipPosRepeat = 2500306,
    HonamiStoryOriPosErr = 2500307,
    HonamiStoryInstCanNoOpe = 2500308,
    HonamiStoryIsRewarded = 2500309,
    HonamiStoryNoFinish = 2500310,
    HonamiStoryNoConfig = 2500311,
    HonamiStoryHadActivateTalent = 2500312,
    HonamiStoryIsUnlocked = 2500313,
    HonamiStoryItemCanNoSell = 2500314,
    HonamiStoryRewardRepeat = 2500315,
    HonamiStoryInstHadFinish = 2500316,
    HonamiStoryLifeSupportFullLevel = 2500317,
    HonamiStoryDangerLevelIllegal = 2500318,
    HonamiStoryWeaponHadDress = 2500319,
    HonamiStoryItemIsLock = 2500320,
    HonamiStoryFunNoOpen = 2500321,
    HonamiStoryHadSafeLeave = 2500322,
    HonamiStoryInTop = 2500323,
    HonamiStoryAreaNoUnlock = 2500324,
    HonamiStoryPreSlotUnlock = 2500325,
    TotalTopUpNoActivityConfig = 2500326,
    TotalTopUpNoFinish = 2500327,
    TotalTopUpRewarded = 2500328,
    TotalTopUpRoleFullChain = 2500329,
    WeekCardUseRepeat = 2500330,
    WeekCardNoConfig = 2500331,
    WeekCardNoActive = 2500332,
    WeekCardCanNoReward = 2500333,
    WeekCardRewarded = 2500334,
    WeekCardNoEffect = 2500335,
    FlagChallengeTaskNoFinish = 2500336,
    FlagChallengeNoConfig = 2500337,
    FlagChallengeTaskRewarded = 2500338,
    FlagChallengeRewardRepeat = 2500339,
    FlagChallengeNoUnlock = 2500340,
    FeiXuePreheatNoFinish = 2500341,
    FeiXuePreheatNoConfig = 2500342,
    FeiXuePreheatRewarded = 2500343,
    FeiXuePreheatRewardRepeat = 2500344,
    ErrOrnamentConfig = 2500345,
    ErrOrnamentLocked = 2500346,
    ErrOrnamentDressed = 2500347,
    ErrOrnamentCanNoDress = 2500348,
    ErrOrnamentNoDress = 2500349,
    BossPilingTaskNoFinish = 2500350,
    BossPilingNoConfig = 2500351,
    BossPilingTaskRewarded = 2500352,
    BossPilingRewardRepeat = 2500353,
    BossPilingNoUnlock = 2500354,
    FlagChallengePassed = 2500355,
    BossPilingFirstNoFinish = 2500356,
    BossPilingRoleErr = 2500357,
    GachaAccumulateNoConfig = 2500358,
    GachaAccumulateNoInTime = 2500359,
    GachaAccumulateRewarded = 2500360,
    GachaAccumulateNoFinish = 2500361,
    GachaAccumulateErrSelectParam = 2500362,
    RequestParamRepeat = 2500363,
    BossPilingActivityNoOpen = 2500364,
    BossPilingErrMultiGame = 2500365,
    SheriffNoConfig = 2500366,
    SheriffActivityNoOpen = 2500367,
    SheriffFuncNotOpen = 2500368,
    SheriffClueNotUnlock = 2500369,
    SheriffEndingAlreadyFinish = 2500370,
    ErrGiftResonantChainOptionalLimit = 2500371,
    ErrAlertAreaId = 2600000,
    ErrAlertAreaEnable = 2600001,
    ErrAlertAreaDisable = 2600002,
    ErrAlertUiEnable = 2600003,
    ErrAlertUiDisable = 2600004,
    ErrAlertUiVisible = 2600005,
    ErrAlertUiInvisible = 2600006,
    ErrAlertValueError = 2600007,
    ErrAlertSetAlertValueType = 2600008,
    LevelPlayReportConfigNotExist = 2600009,
    LevelPlayReportTypeError = 2600010,
    LevelPlayReportVarsEmpty = 2600011,
    LevelPlayReportPlayVarsError = 2600012,
    CameraAlertHasAlert = 2600013,
    CameraAlertHasNotAlert = 2600014,
    CameraAlertTagIdNotExist = 2600015,
    LevelPlayConfigNotExist = 2600016,
    LevelPlayRepeateInstId = 2600017,
    LevelPlayNotBelongInst = 2600018,
    LevelPlayIdsNotExist = 2600019,
    LevelPlayInstCountError = 2600020,
    LevelPlayCountError = 2600021,
    TimerHasPause = 2600022,
    TimerHasNotPause = 2600023,
    TimerHasFinish = 2600024,
    CanNotContinueInst = 2600025,
    ChapterNotExist = 2600026,
    ChapterResultHasFinish = 2600027,
    ChapterResultNotFinish = 2600028,
    ChapterResultRewardCanNotTake = 2600029,
    ChoiceHasUnlock = 2600030,
    ChoiceNotUnlock = 2600031,
    ChapterResultNotExist = 2600032,
    ChapterResultRewardHasTake = 2600033,
    ChoiceNotExist = 2600034,
    InspirationNotEnough = 2600035,
    ActivityRewardCanNotTake = 2600036,
    ActivityResultNotExist = 2600037,
    ScheduleRewardNotExist = 2600038,
    ScheduleRewardHasTake = 2600039,
    ScheduleRewardCanNotTake = 2600040,
    ActivityRewardHasTake = 2600041,
    QuestWaitConfirmResource = 2600042,
    HasGuest = 2600043,
    QuestConfigNotExist = 2600044,
    QuestDataNotExist = 2600045,
    ErrorQuestState = 2600046,
    QuestCanNotSetFocus = 2600047,
    ErrorQuestNotFocus = 2600048,
    QuestIncDicNotExist = 2600049,
    QuestFocusWaitAccept = 2600050,
    ErrQuestResourceState = 2600051,
    NoNeedDownloadQuestResource = 2600052,
    HasFinishQuestResource = 2600053,
    ErrInteracTreeSuspend = 2600054,
    InQuestFocusMode = 2600055,
    MultiModeCannotSetQuestFocus = 2600056,
    MultiModeCannotCancelQuestFocus = 2600057,
    InstanceCannotSetQuestFocus = 2600058,
    InstanceCannotCancelQuestFocus = 2600059,
    QuestFocusModeCannotAcceptQuest = 2600060,
    ErrorNotFocusWaitQuest = 2600061,
    ErrorBanInteractEntity = 2600062,
    DisabledFocusMode = 2600063,
    ErrorNotVaildGlobalSetting = 2600064,
    ErrorSameGlobalSetting = 2600065,
    ErrorNotVaildBtObjSetting = 2600066,
    ErrorSameBtObjSetting = 2600067,
    CopyUserLoginInvalidToken = 2600068,
    LoginInvalidToken = 2600069,
    AccessInvalidToken = 2600070,
    ErrNotAtomicProcessChildQuest = 2600071,
    ErrNotAtomicProcessStoveCoreFall = 2600072,
    ErrSplineEntityIdNotExist = 2600073,
    ErrSplineEntityNotExist = 2600074,
    MotorFightInstNotLevelConfig = 2600075,
    MotorFightSubLevelNotFind = 2600076,
    MotorFightNextSubLevelNotExist = 2600077,
    MotorFightErrorSubLevel = 2600078,
    MotorFightHasEnterSubLevel = 2600079,
    MotorFightCurSubLevelNotKillFinish = 2600080,
    MotorFightHasNotEnterSubLevel = 2600081,
    MotorFightCusSubLevelHasNotKillFinish = 2600082,
    MotorFightCurWaveNotFound = 2600083,
    MotorFightErrorKillParams = 2600084,
    MotorFighttExceedRefreshMonster = 2600085,
    MotorFighttExceedRefreshBoss = 2600086,
    MotorFightNotKillBoss = 2600087,
    MotorFightBossDropCollectionHasSelect = 2600088,
    MotorFightSelectPosCollectionNotExist = 2600089,
    MotorFightCollectionConfigNotExist = 2600090,
    MotorFightWaveGroupNotExist = 2600091,
    MotorFightBossMustKilled = 2600092,
    MotorFightBossNotExist = 2600093,
    MotorFightSelectBuffGateNotExist = 2600094,
    MotorFightCurSubLevelCollectionNoSelectFinish = 2600095,
    MotorFightSubLevelConfigNotFind = 2600096,
    MotorFightSubLevelIndexError = 2600097,
    MotorFightBossHasKilled = 2600098,
    MotorFightBossHasNotRefreshTimes = 2600099,
    MotorFightBossDropCollectionError = 2600100,
    MotorFightHasNotKillBossInfo = 2600101,
    MotorFightIsLastBoss = 2600102,
    MotorFightBuffGateHasSelect = 2600103,
    MotorFightSubLevelStateError = 2600104,
    MotorFightSubLevelNotFound = 2600105,
    MotorFightHasGameOver = 2600106,
    MotorFightCurWaveNotExist = 2600107,
    MotorFightCurWaveNotKillFinish = 2600108,
    SpecificInstDbDataLoading = 2600109,
    SpecificInstDbDataLoadError = 2600110,
    RecallConfigNotExist = 2600111,
    QuestNotFinish = 2600112,
    HasInRecallScene = 2600113,
    EntityConfigNotFound = 2600114,
    InstConfigNotFound = 2600115,
    FastReturnPosTypeNotSupport = 2600116,
    FastReturnPosConfigError = 2600117,
    TrackCustomBoardIsNull = 2600118,
    BtNodeConfigNotExist = 2600119,
    BtNodeObjNotExist = 2600120,
    LevelPlayNotExist = 2600121,
    LevelPlayDbDataNotExist = 2600122,
    NotInRecallInst = 2600123,
    SpecificRecallInfoNotExist = 2600124,
    ErrorCodeIdCreateRuleChange2 = 2700001,
    RacingBetsActivityIdErr = 2700002,
    RacingBetsActivityDataErr = 2700003,
    RacingBetsRewardConfErr = 2700004,
    RacingBetsTaskIdNotExist = 2700005,
    RacingBetsTaskRewarded = 2700006,
    RacingBetsTaskUndone = 2700007,
    RacingBetsTaskRewardFail = 2700008,
    RacingBetsSeasonConfErr = 2700009,
    RacingBetsLegMatchIdNotExist = 2700010,
    RacingBetsOddsTimesErr = 2700011,
    RacingBetsOddsVersionErr = 2700012,
    RacingBetsOddsVersionCodeErr = 2700013,
    RacingBetsOddsConfErr = 2700014,
    RacingBetsOddsDangoErr = 2700015,
    RacingBetsOddsDangoConfErr = 2700016,
    RacingBetsOddsTimeErr = 2700017,
    RacingBetsOddsRetry = 2700018,
    RacingBetsCostFundsErr = 2700019,
    RacingBetsGearTimesLimit = 2700020,
    RacingBetsGearInfoErr = 2700021,
    RacingBetsGearRefundParamErr = 2700022,
    RacingBetsGearRefundFail = 2700023,
    RacingBetsGearNotRefund = 2700024,
    RacingBetsActivityConfErr = 2700025,
    RacingBetsOddsFundsLack = 2700026,
    RacingBetsOddsLack = 2700027,
    RacingBetsGroupNotExist = 2700028,
    RacingBetsGroupConfNotExist = 2700029,
    RacingBetsGroupConfError = 2700030,
    RacingBetsNotInInst = 2700031,
    RacingBetsFundsNotEnough = 2700032,
    RacingBetsFundsCalcErr = 2700033,
    RacingBetsLegMatchNotOpen = 2700034,
    RacingBetsDangoActionTypeErr = 2700035,
    RacingBetsDangoMatchParamErr = 2700036,
    RacingBetsInstSubTypeErr = 2700037,
    RacingBetsEntityErr = 2700038,
    RacingBetsLegMatchIdErr = 2700039,
    RacingBetsBulletScreenTableNotExist = 2700040,
    RacingBetsBulletScreenIdErr = 2700041,
    RacingBetsBulletActionIndexNotExist = 2700042,
    RacingBetsBulletScreenLegMatchNotExist = 2700043,
    RacingBetsBulletNotFundOpenRankCurTime = 2700044,
    RacingBetsBulletGetRankErr = 2700045,
    RacingBetsBulletCD = 2700046,
    ActivityLinkageActivityIdConfErr = 2700047,
    ActivityLinkageConfErr = 2700048,
    ActivityLinkageRewardErr = 2700049,
    ActivityLinkageDataErr = 2700050,
    ActivityLinkageConfIndexErr = 2700051,
    ActivityLinkageRewardStatusErr = 2700052,
    ActivityLinkagePageTimeErr = 2700053,
    RacingBetsdynamicOddsConfErr = 2700054,
    RacingBetsdynamicOddsProportionErr = 2700055,
    RacingBetsDangoDataNotExist = 2700056,
    RacingBetsMatchDataErr = 2700057,
    RacingBetsMatchRoundTimeErr = 2700058,
    RacingBetsNotGear = 2700059,
    RacingBetsLegSettle = 2700060,
    RacingBetsRankNotOpen = 2700061,
    RacingBetsActionIndexErr = 2700062,
    RacingBetsMatchRoundNotFund = 2700063,
    RacingBetsDangoConfNotExist = 2700064,
    RacingBetsDangoTemplateConfNotExist = 2700065,
    RacingBetsDangoEntityCreateFail = 2700066,
    RacingBetsLegMatchConfNotExist = 2700067,
    PhantomBattleCardUnlocked = 2700068,
    PhantomBattleActDataNotExist = 2700069,
    RacingBetsLegNextOddsErr = 2700070,
    RacingBetsRankNotExist = 2700071,
    RacingBetsPlayerNotExistInRank = 2700072,
    PhantomBattleCardTableNotExist = 2700073,
    PhantomBattleCardNumLimit = 2700074,
    PhantomBattleActTableNotExist = 2700075,
    PhantomBattleCardGroupLimit = 2700076,
    PhantomBattleGroupLimit = 2700077,
    PhantomBattleMainCostLimit = 2700078,
    PhantomBattleCardLocked = 2700079,
    PhantomBattleGroupNameLimit = 2700080,
    PhantomBattleGroupNotExist = 2700081,
    PhantomBattleRomoveReason = 2700082,
    RacingBetsBulletIdErr = 2700083,
    RacingBetsPlayerDataNotExist = 2700084,
    RacingBetsTaskDataNotExist = 2700085,
    PhantomBattleGroupElementLimit = 2700086,
    PhantomBattleOutLookUped = 2700087,
    PhantomBattleTaskConfNotExist = 2700088,
    PhantomBattleConditionDataErr = 2700089,
    PhantomBattleConditionConfNotExist = 2700090,
    PhantomBattleConditionGroupConfNotExist = 2700091,
    PhantomBattleTaskStutas = 2700092,
    PhantomBattleTaskReward = 2700093,
    PhantomBattleTaskNotFinish = 2700094,
    PhantomBattleTaskProgressErr = 2700095,
    PhantomBattleBadgeUnlocked = 2700096,
    PhantomBattleLevelConfNotExist = 2700097,
    PhantomBattBadgeRewardConfNotExist = 2700098,
    PhantomBattCardRewardConfNotExist = 2700099,
    PhantomBattBadgeUnlockNotEnough = 2700100,
    PhantomBattBadgeConfErr = 2700101,
    PhantomBattBadgeRewardErr = 2700102,
    PhantomBattleLevelRewardConfNotExist = 2700103,
    PhantomBattCardUnlockNotEnough = 2700104,
    PhantomBattCardRewardConfErr = 2700105,
    PhantomBattLvNotEnough = 2700106,
    PhantomBattLvRewardConfErr = 2700107,
    PhantomBattCardRewardErr = 2700108,
    PhantomBattLvRewardErr = 2700109,
    PhantomBattLvRewardConfNotExist = 2700110,
    PhantomBattRoleLock = 2700111,
    PhantomBattRoleReward = 2700112,
    PhantomBattRoleRewardErr = 2700113,
    PhantomBattPassRewardErr = 2700114,
    PhantomBattFirstPassRewardErr = 2700115,
    PhantomBattleChallengeConfNotFind = 2700116,
    PhantomBattleChallengeOpenLimit = 2700117,
    PhantomBattleParamLimit = 2700118,
    PhantomBattleParamRepeat = 2700119,
    PhantomBattleFuncOpenChallengeRepeat = 2700120,
    PhantomBattleFuncOpenCardGroup = 2700121,
    PhantomBattleFuncOpenCard = 2700122,
    PhantomBattleFuncOpenCardOutlookUp = 2700123,
    PhantomBattleCardNotAllowBuy = 2700124,
    FloroRanchHasUnSettleIns = 2700125,
    FloroRanchSubInsConfNotExist = 2700126,
    FloroRanchRacesLimit = 2700127,
    FloroRanchBaseTerrainLimit = 2700128,
    FloroRanchBaseCardLimit = 2700129,
    FloroRanchRaceRepeat = 2700130,
    FloroRanchGamePlayNotExist = 2700131,
    FloroRanchGamePlayGachaNotExist = 2700132,
    FloroRanchCardNotExistInGacha = 2700133,
    FloroRanchPhantomCreateFail = 2700134,
    FloroRanchTributeCoinLimit = 2700135,
    FloroRanchRaceNotEnough = 2700136,
    FloroRanchStageNotSettle = 2700137,
    FloroRanchActivitysNotFind = 2700138,
    FloroRanchGamePlayShopNotExist = 2700139,
    FloroRanchGamePlayShopItemNotExist = 2700140,
    FloroRanchDiamondNotEnough = 2700141,
    FloroRanchCardTableNotExist = 2700142,
    FloroRanchToyTableNotExist = 2700143,
    FloroRanchTerrainTableNotExist = 2700144,
    FloroRanchToyNumLimit = 2700145,
    FloroRanchNotEnoughToyIndex = 2700146,
    FloroRanchToyCreateFail = 2700147,
    FloroRanchCardGroupTableNotExist = 2700148,
    FloroRanchCardGroupNotExist = 2700149,
    FloroRanchBuffTableNotExist = 2700150,
    FloroRanchRemoveUnitNotExist = 2700151,
    PhantomBattleCardMaxLimit = 2700152,
    FloroRanchRefreshTableNotExist = 2700153,
    FloroRanchPlayTaskNotExist = 2700154,
    FloroRanchSkillTableNotExist = 2700155,
    FloroRanchSkillUseTimesLimit = 2700156,
    FloroRanchSkillLogicNotExist = 2700157,
    FloroRanchSkillLogicErr = 2700158,
    FloroRanchSkillLogicFail = 2700159,
    PhantomBattleNameLimitConfErr = 2700160,
    FloroRanchNotEnableUnlimitedMode = 2700161,
    PhantomBattleLimitTime = 2700162,
    FloroRanchToyWeightConfErr = 2700163,
    FloroRanchAnimalNumLimit = 2700164,
    FloroRanchRaceTableNotFind = 2700165,
    FloroRanchRaceLock = 2700166,
    FloroRanchSkillLock = 2700167,
    FloroRanchSubInsLock = 2700168,
    RoleSelfBgmUnableOperate = 2700169,
    RoleSelfBgmFlyTableNotExist = 2700170,
    RoleSelfBgmUnableOp = 2700171,
    FloroRanchInsLock = 2700172,
    FloroRanchInsConfNotFind = 2700173,
    FloroRanchInsIdNotFind = 2700174,
    FloroRanchInsRaceNotInReq = 2700175,
    FloroRanchUnEnableTribute = 2700176,
    FloroRanchIsMulti = 2700177,
    ButtonLockParamLimit = 2700178,
    ButtonLockParamRepeat = 2700179,
    PhantomBattlePlayerCardGroupBuildErr = 2700180,
    PhantomBattleNpcCardGroupBuildErr = 2700181,
    PhantomBattleNpcRecordLoadFail = 2700182,
    PhantomBattleCardTypeErr = 2700183,
    PhantomBattleActTypeErr = 2700184,
    PhantomNoDurableSkill = 2700185,
    PhantomBattleAreaCardNumLimit = 2700186,
    PhantomBattleItemCardNumLimit = 2700187,
    PhantomBattleCallTaskNumErr = 2700188,
    PhantomBattleNotCanSoltIndex = 2700189,
    PhantomBattleSoltMaxLimit = 2700190,
    PhantomBattleTaskIdErr = 2700191,
    PhantomBattleActIdErr = 2700192,
    PhantomBattleConditionParamErr = 2700193,
    PhantomBattleAreaCardConfigErr = 2700194,
    PhantomBattleAreaLock = 2700195,
    PhantomBattleGuideActTableNotExist = 2700196,
    NewPlayerSupportTaskConfNotExist = 2700197,
    NewPlayerSupportTaskRewardIndex = 2700198,
    NewPlayerSupportTaskParamLimit = 2700199,
    NewPlayerSupportTaskParamRepeat = 2700200,
    NewPlayerSupportTaskReward = 2700201,
    NewPlayerSupportTaskNotFinish = 2700202,
    NewPlayerSupportDataNotEixst = 2700203,
    NewPlayerSupportNotFindTrialRole = 2700204,
    NewPlayerSupportRoleLock = 2700205,
    NewPlayerSupportWorldLvErr = 2700206,
    NewPlayerSupportRolePageErr = 2700207,
    NewTrialRoleActivityRoleCheckErr = 2700208,
    NewTrialRoleActivityInsNotFind = 2700209,
    NewTrialRoleActivityInsUnableUse = 2700210,
    NewTrialRoleActivityLogicNotFind = 2700211,
    NewTrialRoleActivityDelegateNotFind = 2700212,
    RegressNotFindTrialRole = 2700213,
    RegressNotFindActivityTrialRole = 2700214,
    RegressDisposableReward = 2700215,
    RegressDisposableRewardConfigNotFind = 2700216,
    RegressPayBonusLimit = 2700217,
    GachaRoleDevelopInsNotOpen = 2700218,
    PhantomBattleNoComponent = 2700219,
    PhantomBattleUnableSkip = 2700220,
    RegressMaxBonusItemNum = 2700221,
    RegressBonusRewardNoConfig = 2700222,
    RegressBonusBuyLvLimit = 2700223,
    PhantomBattleCallCardLimt = 2700224,
    PhantomBattleCallItemLimt = 2700225,
    GachaRoleDevelopInsLimit = 2700226,
    GachaRolesilentAreaIdNotFind = 2700227,
    GachaRolesilentAreaUnlock = 2700228,
    NewTrialRoleActivityNotFindTrialRoleConf = 2700229,
    PhantomBattleSkipErr = 2700230,
    NewTrialRoleGachaRoleDevelopNotFind = 2700231,
    RegressTrialRoleLock = 2700232,
    NewPlayerSupportTrialRoleLock = 2700233,
    PhantomBattleCopyCardLimit = 2700234,
    RegressTrialNoCanRewardTask = 2700235,
    NewPlayerSupportNoCanRewardTask = 2700236,
    FarmGoldPointReqLimit = 2700237,
    FarmGoldPointReqErr = 2700238,
    FarmGoldPointReqRe = 2700239,
    FarmGoldLevelReqLimit = 2700240,
    FarmGoldLevelReqErr = 2700241,
    FarmGoldLevelReqRe = 2700242,
    FarmGoldPointRewardDropErr = 2700243,
    FarmGoldLevelRewardDropErr = 2700244,
    NewTrialRoleInCurTeam = 2700245,
    RegressEndTimeErr = 2700246,
    NewTrialRoleMatchingUnableTrial = 2700247,
    PhBaFindCd = 2700248,
    PhBaTargetPlanNotExist = 2700249,
    PhBaPlanUploadErr = 2700250,
    PhBaPlanErr = 2700251,
    PhBaSaveCd = 2700252,
    PhBaAttrNotInCost = 2700253,
    PhBaCostMainPropNotExist = 2700254,
    PhBaFetterGroupLimit = 2700255,
    PhBaAttrTypeLimit = 2700256,
    PhBaCostTypeNumLimit = 2700257,
    PhBaCodeLimit = 2700258,
    PhBaCodeIllegal = 2700259,
    PhBaCurUsePlanNotExist = 2700260,
    PhBaTargetSuitNotExist = 2700261,
    PhBaPlanFuncNotOpen = 2700262,
    InsUnableMultiEnter = 2700263,
    PhBaPlanSuitCountErr = 2700264,
    PhBaPlanTargetSuitNotExist = 2700265,
    NewTrialRoleNumLimit = 2700266,
    PhBaPlanCostTypeRepeat = 2700267,
    PhBaPlanSuitIdRepeat = 2700268,
    RacingBetsNotFindOrderListDango = 2700269,
    PhBaPlanBatchOperEnumErr = 2700270,
    PhBaPlanRemotePlanNotExist = 2700271,
    H5ViewActivityNotFindDb = 2700272,
    ForoRanchWeekInsNotFind = 2700273,
    PhBaPlanCodeCreateErr = 2700274,
    RacingBetsOddsDangoIllegal = 2700275,
    ForoRanchNotCurEvent = 2700276,
    ForoRanchEventIncIdErr = 2700277,
    ForoRanchEventChoiceErr = 2700278,
    ForoRanchEventSubChoicesConfNotExist = 2700279,
    ForoRanchEventChoicesConfNotExist = 2700280,
    ForoRanchSubInsIdNoActivityId = 2700281,
    ForoRanchGetSubWeekInsErr = 2700282,
    ForoRanchSubInsNotOpen = 2700283,
    ForoRanchVoidToyNotEnough = 2700284,
    ForoRanchToyNotEnough = 2700285,
    RoverRogueInsNotExist = 2700286,
    RoverRogueCompCreateFail = 2700287,
    RoverRogueNotFindRoomConf = 2700288,
    RoverRogueNotFindBornEntityId = 2700289,
    RoverRogueLootLock = 2700290,
    RoverRogueComponentNotFind = 2700291,
    RoverRogueGetNextRoomFail = 2700292,
    RoverRogueExitNumLess = 2700293,
    RoverRogueExitEntityConfNotFind = 2700294,
    RoverRogueCreateExitEntityFail = 2700295,
    RoverRogueNotFindRoomTypeConf = 2700296,
    RoverRoguePortalEntityNotFind = 2700297,
    RoverRogueNotFindEntityLogic = 2700298,
    RoverRogueInsCtxNotExist = 2700299,
    RoverRogueRoleConfNotExist = 2700300,
    RoverRogueGainDataTypeErr = 2700301,
    RoverRogueGainActiveErr = 2700302,
    RoverRogueRewardDbNotExist = 2700303,
    RoverRogueGainSelectNotExist = 2700304,
    RoverRogueGainTagChangeErr = 2700305,
    RoverRogueGainLogicNotFind = 2700306,
    RoverRogueGainLogicErr = 2700307,
    ForoRanchWeeklyCanNotMilestone = 2700308,
    RoverRogueRewardDbToken = 2700309,
    RoverRogueRoleTypeConfNotExist = 2700310,
    RoverRogueRoomRewardNotInit = 2700311,
    RoverRogueRoomTaskNotExist = 2700312,
    RoverRogueRoomBlessGroupTaskNotExist = 2700313,
    RoverRogueRoomTaskTypeErr = 2700314,
    RoverRogueRoomTaskParamErr = 2700315,
    RoverRogueRoomTaskIsToken = 2700316,
    RoverRogueNotCompletedInsErr = 2700317,
    RoverRogueNotFindRoomRewardConf = 2700318,
    RoverRogueRoomNotFinish = 2700319,
    RoverRogueRoomRewardNotActivate = 2700320,
    RoverRogueRoomRewardCache = 2700321,
    RoverRogueRoleListErr = 2700322,
    RoverRogueRoleTypeErr = 2700323,
    RoverRogueNotFindActConf = 2700324,
    RoverRogueLootNumLimit = 2700325,
    RoverRogueNotFindBlessRoleConf = 2700326,
    RoverRogueNotFindBollToPortal = 2700327,
    RoverRogueNotFindBollNotExist = 2700328,
    RoverRogueNotFindRoomRoadConf = 2700329,
    RoverRogueNotFindChaosConf = 2700330,
    RoverRogueChaosExitNotEnough = 2700331,
    RoverRoguePosNotFind = 2700332,
    RoverRogueChangeSameLoot = 2700333,
    GateUdpPortNotExist = 2800000,
    GateKcpGetConvFail = 2800001,
    ErrScreenActionExecutorNotFind = 2900000,
    ErrScreenActionInfoNotFind = 2900001,
    ErrScreenActionTypeNotMatch = 2900002,
    ErrScreenActionNotFadeInScreen = 2900003,
    ErrScreenActionNotFadeOutScreen = 2900004,
    ErrSceneItemSequenceFrameRegister = 2900005,
    ErrSceneItemSequenceFrameComponentConfig = 2900006,
    ErrSceneItemSequenceFrameComponent = 2900007,
    ErrSceneItemSequenceFrame = 2900008,
    ErrSceneItemSequenceFrameMatchEventCbType = 2900009,
    ErrSceneItemSequenceFrameNeedServerAction = 2900010,
    ErrSceneItemSequenceFrameUnAnsEvent = 2900011,
    ErrSceneBlockSplitNotBlock = 2900027,
    ErrSunSpiritCollectOverNum = 2900012,
    ErrSunSpiritInteractAction = 2900013,
    ErrSunSpiritGetComponentConfig = 2900014,
    ErrSunSpiritEntityRemove = 2900015,
    ErrSunSpiritRepeateAdd = 2900016,
    ErrSunSpiritNumUnEnough = 2900017,
    ErrSunSpiritEnableEntityHistoryUse = 2900018,
    ErrSunSpiritGetPlayerTempOccupySunSpiritInfo = 2900019,
    ErrSunSpiritActionExecutorNotFind = 2900020,
    ErrSunSpiritActionInfoNotFind = 2900021,
    ErrSunSpiritActionIndexNotMatch = 2900022,
    ErrSunSpiritActionTypeNotMatch = 2900023,
    ErrSunSpiritActionParamOperationType = 2900024,
    ErrSunSpiritAreaConfig = 2900025,
    ErrSunSpiritNotHostPlayer = 2900026,
    ErrResourcePackageSdkCheck = 2900028,
    ErrResourcePackageFuncClose = 2900029,
    ErrResourcePackageRedisWrite = 2900030,
    ErrResourcePackageInvalidToken = 2900031,
    ErrResourcePackageRateLimiterCircuit = 2900032,
    ErrResourcePackageRateLimiterRejected = 2900033,
    ErrResourcePackageException = 2900034,
    ErrResourcePackageTimeoutRejected = 2900035,
    ErrAvoidBlockGetInstComponent = 2900036,
    ErrLoadCalabashDefault = 3000000,
    CalabashSkinUnLockErr = 3000001,
    RepeqtedRequest = 3000002,
    ErrSynthesisBatchItemNotSupport = 3000003,
    ErrSynthesisBatchItemDeadLoop = 3000004,
    ErrSynthesisBatchItemCntNotMatch = 3000005,
    ErrSynthesisBatchItemReapeat = 3000006,
    ErrBatchSynthesisCoinOverflow = 3000007,
    ErrPhantomSkinNotExist = 3000008,
    ErrPhantomSkinNotUnlock = 3000009,
    ErrPhantomInteractionNotUnlock = 3000010,
    ErrIllustratedNotUnlock = 3000011,
    ErrPhantomInteractionEquipCountNotMatch = 3000012,
    ErrPhantomInteractionConfigNotFind = 3000013,
    ErrPhantomSkinRepeatOperation = 3000044,
    ErrPhantomInteractionNotShowable = 3000045,
    ErrArtemisNodeNoConfig = 3000014,
    ErrArtemisActivityNotOpen = 3000015,
    ErrArtemisNodeNoData = 3000016,
    ErrArtemisNodeNoUnlock = 3000017,
    ErrArtemisNodeNotRewardStatus = 3000018,
    ErrArtemisNodeAlreadyFixed = 3000019,
    ErrArtemisNodeAlreadyFinished = 3000020,
    ErrArtemisState = 3000021,
    ErrArtemisInvalidUpdate = 3000022,
    ErrIndexOutOfRange = 3000023,
    ErrArtemisActivityNotExist = 3000024,
    MotorParkourLevelNoOpen = 3000025,
    MotorParkourNoConfig = 3000026,
    MotorParkourInstComponentNotExist = 3000027,
    MotorParkourGetTimeRecordFailed = 3000028,
    ErrMotorParkourLevelRewardIndexLengthError = 3000029,
    ErrMotorParkourActivityDataNotExist = 3000030,
    ErrMotorParkourLevelRewardIndexInvalid = 3000031,
    ErrMotorParkourRecordCfgNotExist = 3000032,
    ErrMotorParkourGetRewardStatusFail = 3000033,
    ErrMotorParkourRewardNotAvailable = 3000034,
    ErrMotorParkourLevelRewardIndexDuplicate = 3000035,
    ErrMotorParkourRewardCfgNotExist = 3000043,
    ErrMotorParkourLevelInfoFailed = 3000046,
    ErrMotorParkourPreLevelNotComplete = 3000073,
    ErrAreaTerminalPinFull = 3000036,
    ErrAreaTerminalPinExist = 3000037,
    ErrAreaTerminalPinNotExist = 3000038,
    ErrAreaTerminalParamError = 3000039,
    ErrActivityLock = 3000040,
    ErrFuncLock = 3000041,
    ErrNoAreaTerminalCfg = 3000042,
    ErrSpringFestivalActivityConfigNotFound = 3000068,
    ErrSpringFestivalActivityDataNotFound = 3000069,
    ErrSpringFestivalComponentNotFound = 3000070,
    ErrSpringFestivalRuntimeInfoNotFound = 3000071,
    ErrMultiModeCanNotRequest = 3000083,
    ErrSpringFestivalActivityNotOpen = 3000084,
    ErrSpringFestivalFuncNotExist = 3000100,
    ErrSpringFestivalFuncLock = 3000101,
    ErrSpringFestivalActivityIdNotMatch = 3000103,
    ErrFurnitureDiyActivityConfigNotFound = 3000047,
    ErrFurnitureAreaIdNotExistInActivity = 3000048,
    ErrFurnitureAreaConfigNotFound = 3000049,
    ErrFurnitureDiyActivityDataNotFound = 3000050,
    ErrFurnitureSlotConfigNotExist = 3000051,
    ErrFurnitureConfigNotExist = 3000052,
    ErrFurnitureNotAvailable = 3000053,
    ErrFurnitureAreaDataNotFound = 3000054,
    ErrSpecificFurnitureCount = 3000055,
    ErrFurnitureSlotNotSupportChildTag = 3000056,
    ErrFurnitureSlotNotSupportFurniture = 3000057,
    ErrFurnitureDiyComponentNotFound = 3000058,
    ErrNotFurnitureSlotConfig = 3000059,
    ErrFurnitureSlotConfigSlotCountError = 3000060,
    ErrFurnitureSlotSubFurnitureCount = 3000061,
    ErrFurnitureEntityConfigNotFound = 3000062,
    ErrEntityCreateFailed = 3000063,
    ErrFurnitureUnloadSubFurnitureNotEmpty = 3000064,
    ErrEntitiesNull = 3000065,
    ErrConvertShortIdToFurnitureIdFailed = 3000066,
    ErrFurnitureSlotDuplicateInRequest = 3000067,
    ErrFurnitureSlotNotBelongToArea = 3000106,
    ErrSpringFestivalFurnitureHadUnlock = 3000117,
    ErrExploreDegreeTypeNotFound = 3000072,
    ErrActivityBrochureCfgNotFound = 3000074,
    ErrBrochureRewardRequestEmptyBookItems = 3000075,
    ErrBrochureCfgNotFound = 3000076,
    ErrBrochureNotBelongToActivity = 3000077,
    ErrBrochureNotUnlock = 3000078,
    ErrBrochureRewardRequestDuplicateBookItem = 3000079,
    ErrBookItemCfgNotFound = 3000080,
    ErrBookItemNotFinish = 3000081,
    ErrBookItemAlreadyRewarded = 3000082,
    ErrBrochureRewardTimeInvalid = 3000091,
    ErrBookItemNotBelongToBrochure = 3000104,
    ErrExhibitionComponentCfgNotExist = 3000085,
    ErrItemTypeNotMatchExhibitType = 3000086,
    ErrExhibitConfigTypeInvalid = 3000087,
    ErrExhibitionComponentNotExist = 3000088,
    ErrExhibitionPhantomNotExist = 3000089,
    ErrRepeatedEntity = 3000092,
    ErrPhonographMusicNotExist = 3000093,
    ErrMusicNotUnlocked = 3000102,
    ErrInstanceConfigNotFound = 3000090,
    ErrInvalidEnterContextCase = 3000094,
    ErrTetrisLevelInfoDuplicate = 3000095,
    ErrTetrisActivityDataNotFound = 3000096,
    ErrTetrisLevelConfigNotExist = 3000097,
    ErrTetrisLevelRewardDuplicate = 3000098,
    ErrTetrisLevelStateInvalid = 3000099,
    ErrActivityNotMatchTetrisLevel = 3000118,
    ErrTetrisTargetScoreIdNotExist = 3000119,
    ErrTetrisLevelHasRewarded = 3000120,
    ErrTetrisLevelNotFinished = 3000121,
    ErrTetrisLevelDifficultyIndexInvalid = 3000126,
    ErrTetrisTargetScoreCountNotMatch = 3000127,
    ErrTetrisScoreInvalid = 3000128,
    ErrGetVarDefine = 3000129,
    ErrDataPersistenceTetrisBoardGame = 3000130,
    ErrTetrisTargetScoreNotEnough = 3000131,
    ErrTetrisConfigInvalid = 3000132,
    ErrTetrisPreLevelNotFinished = 3000137,
    wlf_test = 3000105,
    DropCatchNoConfig = 3000107,
    DropCatchLevelNotOpen = 3000108,
    ErrDropCatchLevelRewardIndexLengthError = 3000109,
    ErrDropCatchActivityDataNotExist = 3000110,
    ErrDropCatchLevelRewardIndexDuplicate = 3000111,
    ErrDropCatchLevelRewardIndexInvalid = 3000112,
    ErrDropCatchRewardCfgNotExist = 3000113,
    ErrDropCatchRewardNotAvailable = 3000114,
    ErrDropCatchLevelInfoFailed = 3000115,
    ErrDropCatchLevelScoreInvalid = 3000116,
    ErrDropCatchEntityComponentNotExist = 3000122,
    ErrDropCatchComponentNotExist = 3000123,
    ErrDropCatchRewardCfgNotActivity = 3000124,
    ErrDropCatchDataNotExist = 3000125,
    ErrGetSelfXboxOnlineId = 3000133,
    ErrXboxPlayerInfoRequestLimit = 3000134,
    ErrGetXboxUserPlayerErr = 3000135,
    ErrXboxAccountBlocked = 3000136,
    InfrV2LevelCfgNotFound = 3000138,
    InfrV2ShopPhaseCfgNotFound = 3000139,
    InfrV2ShopGoodsCfgNotFound = 3000140,
    InfrV2FireAddExpNegative = 3000141,
    InfrV2FireAlreadyMaxLevel = 3000142,
    InfrV2FireConditionNotMet = 3000143,
    InfrV2FireExpNotEnough = 3000144,
    InfrV2TreeNotInProgress = 3000145,
    InfrV2FireLevelNotInProgress = 3000146,
    InfrV2TreeConditionNotMet = 3000147,
    InfrV2NotOpen = 3000148,
    InfrV2TreeBuildCfgNotFound = 3000149,
    InfrV2TreeCannotTrace = 3000150,
    InfrV2TreeSwitchTraceInMulti = 3000151,
    InfrV2TaskFindErr = 3000152,
    InfrV2HadReward = 3000153,
    InfrV2TaskRunning = 3000154,
    InfrV2DropNoFind = 3000155,
    InfrV2ParamAgainErr = 3000156,
    InfrV2NoReward = 3000157,
    InfrV2ParamCountErr = 3000158,
    SlashAndTowerParamErr = 3000159,
    RogueWeeklyParamErr = 3000160,
    ErrMatchRoleChangeSkillBranchCountNotEqualRoleCount = 3000161,
    ErrActivityPreQuestNotFinished = 3000162,
    ErrInstNotEdgeRunnerLordGym = 3000163,
    ErrEdgeRunnerLordGymConfigNotExist = 3000164,
    ErrEdgeRunnerDbDataNotExist = 3000165,
    ErrEdgeRunnerPreLordGymNotPassed = 3000166,
    EdgeRunnerParamCountErr = 3000167,
    EdgeRunnerDropNoFind = 3000168,
    EdgeRunnerNoReward = 3000169,
    EdgeRunnerTaskFindErr = 3000170,
    EdgeRunnerActivityIdErr = 3000171,
    EdgeRunnerHadReward = 3000172,
    EdgeRunnerTaskRunning = 3000173,
    EdgeRunnerParamAgainErr = 3000174,
    ErrEdgeRunnerActivityConfigNotFound = 3000175,
    ErrEdgeRunnerActivityFuncUnlockConfigNotFound = 3000176,
    ErrEdgeRunnerActivityFuncAlreadyUnlock = 3000177,
    ErrEdgeRunnerActivityFuncUnlockConditionNotReached = 3000178,
    ErrEdgeRunnerActivityFuncUnlockFailed = 3000179,
    ErrEdgeRunnerLordGymLevelVarNotExist = 3000187,
    EdgeRunnerLordGymRepeatChallenge = 3000188,
    ErrEdgeRunnerLordGymBtTreeNotFound = 3000189,
    ErrEdgeRunnerLordGymNotInPlay = 3000190,
    ErrGolemCrackLevelConfigNotExist = 3000180,
    ErrActivityNotMatchGolemCrackLevel = 3000181,
    ErrGolemCrackActivityDataNotFound = 3000182,
    ErrGolemCrackPreLevelNotFinished = 3000183,
    ErrGolemCrackLevelRewardDuplicate = 3000184,
    ErrGolemCrackPreLevelLocked = 3000186,
    ErrPhantomRecommendConfigNotFound = 3000185,
    ErrXboxGiftNotEnable = 3000191,
    ErrXboxGiftDbError = 3000192,
    ErrXboxGiftAlreadyClaimed = 3000193,
    ErrXboxGiftNotXboxUser = 3000194,
    ErrXboxGiftRequestErr = 3000195,
    ErrXboxGiftRequestDataErr = 3000196,
    ErrXboxGiftNotFound = 3000197,
    ErrXboxGiftException = 3000198,
    ErrXboxGiftHttpError = 3000199,
    ErrXboxGiftXstsTokenInvalid = 3000201,
    ErrXboxGiftXstsTokenMismatch = 3000202,
    QingXiaoParamCountErr = 3000203,
    QingXiaoTaskFindErr = 3000204,
    QingXiaoActivityIdErr = 3000205,
    QingXiaoHadReward = 3000206,
    QingXiaoTaskRunning = 3000207,
    QingXiaoDropNoFind = 3000208,
    QingXiaoParamAgainErr = 3000209,
    QingXiaoNoReward = 3000210,
    PhotoFightLevelNotFound = 3100000,
    PhotoFightActivityNotOpen = 3100001,
    PhotoFightSceneComponentInfoLost = 3100002,
    PhotoFightGroupNotFound = 3100003,
    PhotoFightLevelNotOpen = 3100004,
    PhotoFightPreInstNotCleared = 3100005,
    PhotoFightSceneComponentLost = 3100006,
    PhotoFightTargetStatusHigher = 3100007,
    PhotoFightNoTargetRole = 3100008,
    PhotoFightRoleInvalid = 3100009,
    PhotoFightRewardCfgNotFound = 3100010,
    PhotoFightRewardInvalidInput = 3100011,
    PhotoFightAlreadyRewarded = 3100012,
    PhotoFightCannotRewarded = 3100081,
    PhotoFightInvalidInstType = 3100306,
    WuWuKujiQuestNotFound = 3100013,
    WuWuKujiQuestNotOpenDay = 3100014,
    WuWuKujiQuestAllFinished = 3100015,
    WuWuKujiActivityNotOpen = 3100016,
    WuWuKujiPreGuideNotFinished = 3100017,
    WuWuKujiPreQuestNotFinished = 3100018,
    WuWuKujiActivityConfigNotFound = 3100019,
    WuWuKujiTrickTypeInvalid = 3100020,
    WuWuKujiNoAvailableTrick = 3100021,
    WuWuKujiAwardGroupCfgNotFound = 3100022,
    WuWuKujiNoAvailableGroup = 3100023,
    WuWuKujiGroupRewardTimesExceededMax = 3100024,
    WuWuKujiGroupRemainTimesError = 3100025,
    WeatherCtlInvalidInMulti = 3100026,
    WeatherCtlMapDataNotFound = 3100027,
    WeatherCtlSwitchCfgNotFound = 3100028,
    WeatherCtlSwitchLocked = 3100029,
    WeatherCtlAreaWeatherLocked = 3100030,
    WeatherCtlAreaDateLocked = 3100031,
    WeatherCtlAddHourNoNegative = 3100032,
    WeatherCtlInMulti = 3100052,
    WeatherCtlInBattle = 3100053,
    WeatherCtlInQuest = 3100054,
    WeatherCtlNotInBigWorld = 3100082,
    WeatherCtlNotOpen = 3100162,
    InfrArchiveTaskCfgNotFound = 3100033,
    InfrLevelCfgNotFound = 3100034,
    InfrShopPhaseCfgNotFound = 3100035,
    InfrShopGoodsCfgNotFound = 3100036,
    InfrFireAddExpNegative = 3100037,
    InfrFireAlreadyMaxLevel = 3100038,
    InfrFireConditionNotMet = 3100039,
    InfrRoadBuildCfgNotFound = 3100040,
    InfrRoadCannotTrace = 3100041,
    InfrFireShopGoodsNotFound = 3100042,
    InfrFireShopPhaseNotUnlocked = 3100043,
    InfrFireShopBuyLimitExceeded = 3100044,
    InfrFireShopBuyTimesInvalid = 3100045,
    InfrArchiveTaskInvalidInput = 3100046,
    InfrArchiveTaskCannotRewarded = 3100047,
    InfrFireExpNotEnough = 3100048,
    InfrRoadNotInProgress = 3100049,
    InfrFireLevelNotInProgress = 3100050,
    InfrRoadConditionNotMet = 3100051,
    InfrNotOpen = 3100073,
    InfrPhoneTaskInvalidInput = 3100083,
    InfrPhoneTaskCannotRewarded = 3100084,
    InfrPhoneTaskCfgNotFound = 3100085,
    InfrRoadSwitchTraceInMulti = 3100173,
    InfrThemeActivityTaskNotFound = 3100074,
    InfrThemeActivityTaskRewarded = 3100075,
    InfrThemeActivityTaskNotComplete = 3100076,
    InfrThemeActivityInputInvalid = 3100077,
    InfrThemeActivityIdMisMatch = 3100094,
    InfrThemeActivityTaskCannotRewarded = 3100078,
    MotorTechPreNodeLock = 3100055,
    MotorTechPreNotUpgraded = 3100056,
    MotorTechLevelLower = 3100057,
    MotorTechNotUnlocked = 3100058,
    MotorTechLevelMax = 3100059,
    MotorTechCfgNotFound = 3100060,
    MotorLvlConfigNotFound = 3100061,
    MotorFuncNotOpen = 3100062,
    MotorTaskCannotRewarded = 3100063,
    MotorTaskInvalidParam = 3100064,
    MotorTaskCfgNotFound = 3100065,
    MotorTechTreeCfgNotFound = 3100066,
    MotorTechTreeLocked = 3100067,
    MotorPlayerUsingSkill = 3100068,
    MotorPlayerClimbing = 3100069,
    MotorPlayerInWater = 3100070,
    MotorPlayerInAir = 3100071,
    MotorPlayerOnMotor = 3100072,
    MotorTaskNotInOneTree = 3100079,
    MotorExpInvalid = 3100080,
    MotorOutlookLocked = 3100086,
    MotorFrameCfgNotFound = 3100087,
    MotorStickerCfgNotFound = 3100088,
    MotorOutlookBanInRegion = 3100089,
    MotorOutlookConflict = 3100090,
    MotorStickerPartCountError = 3100091,
    MotorStickerPartIdError = 3100092,
    MotorOutlookNotOwned = 3100093,
    MotorLevelRewardAllClaimed = 3100159,
    PlayerNotInMotorArea = 3100160,
    MotorDecorationsCfgNotFound = 3100164,
    MotorDecorationsPartCountError = 3100165,
    MotorDecorationsPartIdError = 3100166,
    MotorTechTreeInCd = 3100175,
    ArrowSwordLevelCfgNotFound = 3100095,
    ArrowSwordTalentCfgNotFound = 3100096,
    ArrowSwordTaskCfgNotFound = 3100097,
    ArrowSwordItemCfgNotFound = 3100098,
    ArrowSwordRoleCfgNotFound = 3100099,
    ArrowSwordPreNotCleared = 3100100,
    ArrowSwordActivityTypeNotMatch = 3100101,
    ArrowSwordTaskStatusHigher = 3100102,
    ArrowSwordInvalidInput = 3100103,
    ArrowSwordDataOwnerErr = 3100104,
    ArrowSwordActivityIdMisMatch = 3100105,
    ArrowSwordTalentLocked = 3100106,
    ArrowSwordTalentAlreadyInUse = 3100107,
    ArrowSwordTalentPreNodeNotInUse = 3100108,
    ArrowSwordActivityCfgNotFound = 3100109,
    ArrowSwordTalentNotInUse = 3100110,
    ArrowSwordActivityNotOpen = 3100111,
    ArrowSwordActivityEnd = 3100112,
    ArrowSwordComponentNoFind = 3100113,
    ArrowSwordSaveDataLost = 3100114,
    ArrowSwordRoleNotUnlock = 3100115,
    ArrowSwordRankListCd = 3100116,
    ArrowSwordComponentInstLost = 3100117,
    ArrowSwordInstNotInProgress = 3100118,
    ArrowSwordInstNotInitialized = 3100119,
    ArrowSwordHaveUnfinishedInst = 3100120,
    MotorFightLevelCfgNotFound = 3100121,
    MotorFightTalentCfgNotFound = 3100122,
    MotorFightTaskCfgNotFound = 3100123,
    MotorFightItemCfgNotFound = 3100124,
    MotorFightRoleCfgNotFound = 3100125,
    MotorFightPreNotCleared = 3100126,
    MotorFightActivityTypeNotMatch = 3100127,
    MotorFightTaskStatusHigher = 3100128,
    MotorFightInvalidInput = 3100129,
    MotorFightDataOwnerErr = 3100130,
    MotorFightActivityIdMisMatch = 3100131,
    MotorFightTalentLocked = 3100132,
    MotorFightTalentAlreadyInUse = 3100133,
    MotorFightTalentPreNodeNotInUse = 3100134,
    MotorFightActivityCfgNotFound = 3100135,
    MotorFightTalentNotInUse = 3100136,
    MotorFightActivityNotOpen = 3100137,
    MotorFightActivityEnd = 3100138,
    MotorFightComponentNoFind = 3100139,
    MotorFightSaveDataLost = 3100140,
    MotorFightRoleNotUnlock = 3100141,
    MotorFightRankListCd = 3100142,
    MotorFightComponentInstLost = 3100143,
    MotorFightInstNotInProgress = 3100144,
    MotorFightInstNotInitialized = 3100145,
    MotorFightHaveUnfinishedInst = 3100146,
    MotorFightAlreadySettle = 3100147,
    MotorFightNoInfiniteLevel = 3100161,
    MotorFightNoRoundData = 3100163,
    MotorFightLevelNotOpen = 3100170,
    MotorFightFirstClearRewardFail = 3100171,
    MotorFightSettleResultNull = 3100172,
    EncircleChallengeCfgNotFound = 3100148,
    EncircleChallengeNotOpen = 3100149,
    EncirclePreChallengeNotPass = 3100150,
    EncircleChallengeStepErr = 3100151,
    EncircleActivityTypeNotMatch = 3100174,
    EncircleChallengeNotStart = 3100177,
    EncircleMultiGame = 3100179,
    EncircleActivityNotOpen = 3100206,
    FetterGroupNotExist = 3100152,
    DirectRefiningQualityErr = 3100153,
    FetterGroupConfigErr = 3100154,
    FetterGroupDirectRefineLocked = 3100155,
    PhantomDirectRefiningFetterNotFound = 3100156,
    PhantomDirectRefiningWeekTimesLimit = 3100157,
    PhantomMonsterConfNotFound = 3100158,
    GivebackScoreCannotReward = 3100167,
    GivebackScoreCfgNotFound = 3100168,
    GivebackNotOpen = 3100169,
    GivebackInvalidInput = 3100176,
    GivebackParseDataError = 3100178,
    RhythmNotInLimitTime = 3100180,
    RhythmTaskCfgNotFound = 3100181,
    RhythmActivityCfgNotFound = 3100182,
    RhythmPlanetCfgNotFound = 3100183,
    RhythmLevelCfgNotFound = 3100184,
    RhythmSubLevelCfgNotFound = 3100185,
    RhythmRoleCfgNotFound = 3100190,
    RhythmInputInvalid = 3100186,
    RhythmActivityDataNotExist = 3100187,
    RhythmTaskCannotReward = 3100188,
    RhythmInMulti = 3100189,
    RhythmSubLevelNotOpen = 3100191,
    RhythmPreSubLevelNotCompleted = 3100192,
    RhythmLevelNotOpen = 3100193,
    RhythmPlanetNotOpen = 3100194,
    RhythmRoleLock = 3100195,
    RhythmActivityIdMisMatch = 3100196,
    RhythmInvalidPayload = 3100197,
    RhythmActivityTypeNotMatch = 3100198,
    RhythmNoPartnerRoleId = 3100199,
    RhythmGetRankInCd = 3100200,
    RhythmInstNotMatch = 3100201,
    RhythmActivityEnd = 3100202,
    RhythmPartnerNotSet = 3100203,
    RhythmStartInfoLost = 3100204,
    RhythmSubLevelNotMatch = 3100205,
    PinballLevelCfgNotFound = 3100207,
    PinballActivityNotOpen = 3100208,
    PinballTrialLevelNotUseRole = 3100209,
    PinballRoleCountInvalid = 3100210,
    PinballRoleNotOwn = 3100211,
    PinballSceneNotExists = 3100212,
    PinballComponentNotExists = 3100213,
    PinballEnterCtxInvalid = 3100214,
    PinballCompStateInvalid = 3100215,
    PinballGameAlreadySettled = 3100216,
    PinballBonusScoreNotFull = 3100217,
    PinballLevelTypeInvalid = 3100218,
    PinballAlreadySettled = 3100219,
    PinballNoReviveTimesLeft = 3100220,
    PinballCompStateChangeReasonInvalid = 3100221,
    PinballSettlePayloadInvalid = 3100222,
    PinballRoleCfgNotFound = 3100223,
    PinballTemplateEntityConfigNotFound = 3100224,
    PinballLevelNotBonus = 3100225,
    PinballLevelTargetCondTypeNotSupport = 3100226,
    PinballEffectCfgNotFound = 3100227,
    PinballEffectHandlerNotFound = 3100228,
    PinballTrialLevelEnterWithRoles = 3100229,
    PinballBtObjNotExists = 3100230,
    PinballLevelEnterWithNoRole = 3100231,
    PinballRoleLevelCfgNotFound = 3100238,
    PinballDailyConfigInvalid = 3100239,
    MotorOutlookPresetNameInvalid = 3100232,
    MotorOutlookPresetNotOwn = 3100233,
    MotorOutlookPresetMax = 3100234,
    MotorOutlookPresetNotExist = 3100235,
    MotorOutlookPresetInputInvalid = 3100236,
    MotorOutlookPresetIdInvalid = 3100237,
    MotorSkinCfgNotFound = 3100243,
    MotorSkinNotEditable = 3100244,
    MotorSceneCfgNotFound = 3100289,
    CdkGiftCdkBatchAlreadyGot = 3100240,
    CdkGiftCdkPayGiftAlreadyBought = 3100241,
    CdkGiftCdkPayGiftTypeErr = 3100242,
    CdkGiftCdkPayGiftOldVersion = 3100287,
    NewBieMainlineActivityNotOpen = 3100245,
    NewBieMainlineActivityEnd = 3100246,
    NewBieMainlineInvalidInput = 3100247,
    NewBieMainlineRewardActivityMismatch = 3100248,
    NewBieMainlineTabTaskCfgNotFound = 3100249,
    NewBieMainlineTabRewardCfgNotFound = 3100250,
    NewBieMainlineRewardAlreadyTaken = 3100251,
    NewBieMainlineScoreNotEnough = 3100252,
    NewBieMainlineRewardDropFail = 3100253,
    NewBieAdventureActivityNotOpen = 3100254,
    NewBieAdventureActivityCfgNotFound = 3100255,
    NewBieAdventureActivityEnd = 3100256,
    NewBieAdventureInvalidInput = 3100257,
    NewBieAdventureChapterV2CfgNotFound = 3100258,
    NewBieAdventureTaskV2CfgNotFound = 3100259,
    NewBieAdventureV2RewardAlreadyTaken = 3100260,
    NewBieAdventureV2RewardDropFail = 3100261,
    NewBieAdventureV2ChapterLocked = 3100262,
    NewBieAdventureV2ChapterRewardNotReady = 3100263,
    NewBieAdventureV2NoTaskConfig = 3100264,
    NewBieAdventureV2RoleNotSet = 3100265,
    NewBieAdventureV2RoleInvalid = 3100266,
    NewBieAdventureV2TasksCrossChapter = 3100267,
    NewBieAdventureV2TaskNotComplete = 3100268,
    GeneralDailyResetCronNotFound = 3100269,
    ActivitySignConfigNotFound = 3100270,
    SignActivityFreeDropNoConfig = 3100271,
    SignActivityFreeDropAlreadyTaken = 3100272,
    NewBieV2NoLicense = 3100273,
    NewBieV1NoLicense = 3100274,
    WeekCardPersonalNoPermission = 3100275,
    WeekCardPersonalPermissionExpired = 3100276,
    WeekCardNotPersonal = 3100277,
    WeekCardInputErr = 3100286,
    WeekCardRecycleNoPermission = 3100278,
    NewBieCourseV2ActivityNotOpen = 3100279,
    NewBieCourseV2ActivityCfgNotFound = 3100280,
    NewBieCourseV2ActivityEnd = 3100281,
    NewBieCourseV2InvalidInput = 3100282,
    NewBieCourseV2CfgNotFound = 3100283,
    NewBieCourseV2LevelNotEnough = 3100284,
    NewBieCourseV2RewardAlreadyTaken = 3100285,
    ErrNotGetFightInfoDtType = 3200000,
    ErrFightInfoDtType = 3200001,
    ErrSetFightInfoDtType = 3200002,
    ErrChangeDtTypeParamError = 3200003,
    ErrCurSceneNotMatch = 3300000,
    ErrTargetNotForDeadEye = 3300001,
    ErrDeadEyeCount = 3300002,
    ErrNoMoveEvent = 3300003,
    ErrEntityTypeNotSupport = 3300004,
    ErrExploreSkillNoActions = 3300005,
    ErrExploreSkillActionMultiGame = 3300006,
    ErrExploreSkillActionNotExist = 3300007,
    ErrMonsterNotGameplayTagComp = 3300008,
    ErrDecalEffectNotFound = 3300009,
    ErrEntityNotInCurMap = 3300010,
    ErrEntityNotInCurScene = 3300011,
    ErrEntityNotForNpcTimeSchedule = 3300012,
    ErrEntityNotInAnySchedule = 3300013,
    ErrSplineConfigNotFound = 3300014,
    ErrSplineIdxOutofBound = 3300015,
    ErrPositionConfig = 3300016,
    ErrSplineNotForTimeSchedule = 3300017,
    ErrHostPlayerNotSame = 3300018,
    ErrInteractType = 3300019,
    ErrEntityAlreadyDie = 3300020,
    ErrEntityAlreadyDestroyed = 3300021,
    ErrRequestLimitExceeded = 3300022,
    ErrOptionOutofBound = 3300023,
    ErrHoldHandInvalidActionType = 3300024,
    ErrBlackScreenIllegalSource = 3400000,
    ErrBeamReceiveEntityNotConfig = 3400001,
    ErrBeamReceiveCondition = 3400002,
    ErrBeamReceiveEntityNotConfig2 = 3400003,
    ErrFlowerPollutionNotConfig = 3400004,
    ErrorFlowerPollutionState = 3400005,
    ErrDollGarbTimeOut = 3400006,
    ErrGrabMachineEntityNotConfig = 3400007,
    ErrGrabItemNotInConfig = 3400008,
    ErrItemHasBeenClipped = 3400009,
    ErrDollGrabNoCsvConfig = 3400010,
    ErrPlayerNotStartedPlaying = 3400011,
    ErrGrabShowcaseEntityNotConfig = 3400012,
    ErrPlayerBagNotDoll = 3400013,
    ErrDollIsDelivered = 3400014,
    ErrPlayerAlreadyPlaying = 3400015,
    ErrGrabItemTypeMismatch = 3400016,
    ErrDollGrabAlreadyPaused = 3400017,
    ErrDollGrabNotPaused = 3400018,
    ErrDollMachineDropReward = 3400019,
};
pub const DErrorResult = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
};
pub const PbGetRoleListNotify = struct {
    pub const default: @This() = .{};
    RoleList: std.ArrayList(RoleInfo) = .empty,
};
pub const PbUpLevelRoleRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    ItemList: std.ArrayList(ArrayIntInt) = .empty,
};
pub const PbUpLevelRoleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    Exp: i32 = 0,
    Level: i32 = 0,
    ItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const PbOverRoleRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const PbOverRoleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    Breakthrough: i32 = 0,
};
pub const PbUpLevelSkillRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillId: i32 = 0,
    UseBox: bool = false,
};
pub const PbUpLevelSkillResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    SkillInfo: ?ArrayIntInt = null,
};
pub const PbRolePropsNotify = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    BaseProp: std.ArrayList(ArrayIntInt) = .empty,
    AddProp: std.ArrayList(ArrayIntInt) = .empty,
};
pub const ArrayIntInt = struct {
    pub const default: @This() = .{};
    Key: i32 = 0,
    Value: i32 = 0,
};
pub const ArrayIntDouble = struct {
    pub const default: @This() = .{};
    Key: i32 = 0,
    Value: f64 = 0,
};
pub const ArraySkillNode = struct {
    pub const default: @This() = .{};
    SkillNodeId: i32 = 0,
    IsActive: bool = false,
    SkillId: i32 = 0,
};
pub const ResonInfo = struct {
    pub const default: @This() = .{};
    ResonId: i32 = 0,
    IsOpen: bool = false,
    Increase: i32 = 0,
};
pub const RoleInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Name: []const u8 = "",
    Level: i32 = 0,
    Exp: i32 = 0,
    Breakthrough: i32 = 0,
    Skills: std.ArrayList(ArrayIntInt) = .empty,
    Phantom: std.ArrayList(ArrayIntInt) = .empty,
    Star: i32 = 0,
    Favor: i32 = 0,
    Reson: std.ArrayList(ResonInfo) = .empty,
    CurModel: i32 = 0,
    Models: std.ArrayList(i32) = .empty,
    BaseProp: std.ArrayList(ArrayIntInt) = .empty,
    AddProp: std.ArrayList(ArrayIntInt) = .empty,
    CreateTime: u32 = 0,
    SkillNodeState: std.ArrayList(ArraySkillNode) = .empty,
    ResonantChainGroupIndex: i32 = 0,
    SkinId: i32 = 0,
    EnableSelfBgm: bool = false,
};
pub const PbRoleSkillLevelNotify = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillInfo: ?ArrayIntInt = null,
};
pub const SkillEffect = struct {
    pub const default: @This() = .{};
    Level: i32 = 0,
    EffectDescList: std.ArrayList(OneSkillEffect) = .empty,
};
pub const OneSkillEffect = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Desc: std.ArrayList([]const u8) = .empty,
};
pub const RoleLevelUpViewRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    MaxItemId: i32 = 0,
    ItemList: std.ArrayList(ArrayIntInt) = .empty,
};
pub const RoleLevelUpViewResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Level: i32 = 0,
    LevelExpInfo: std.ArrayList(ArrayIntInt) = .empty,
    Exp: i32 = 0,
    AddExp: i32 = 0,
    FinalProp: std.ArrayList(ArrayIntDouble) = .empty,
    CostList: std.ArrayList(ArrayIntInt) = .empty,
    OverflowList: std.ArrayList(ArrayIntInt) = .empty,
    ItemList: std.ArrayList(ArrayIntInt) = .empty,
};
pub const RoleBreakThroughViewRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const RoleBreakThroughViewResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    LevelLimit: i32 = 0,
    UnLockSkillId: i32 = 0,
    CostList: std.ArrayList(ArrayIntInt) = .empty,
    RewardList: std.ArrayList(ArrayIntInt) = .empty,
    FinalProp: std.ArrayList(ArrayIntDouble) = .empty,
    IsConditionFinish: bool = false,
};
pub const RoleSkillLevelUpViewRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillId: i32 = 0,
};
pub const RoleSkillLevelUpViewResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SkillEffectList: std.ArrayList(SkillEffect) = .empty,
    CostList: std.ArrayList(ArrayIntInt) = .empty,
};
pub const RoleSkillViewRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillId: i32 = 0,
};
pub const RoleSkillViewResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SkillEffectList: std.ArrayList(SkillEffect) = .empty,
    PreSkillEffectList: std.ArrayList(SkillEffect) = .empty,
    IsConditionFinish: bool = false,
};
pub const RoleActivateSkillRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillNodeId: i32 = 0,
};
pub const RoleActivateSkillResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    SkillInfo: ?ArrayIntInt = null,
};
pub const RoleSkillNodeNotify = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillNodeState: std.ArrayList(ArraySkillNode) = .empty,
};
pub const ResonantChainUnlockRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const ResonantChainUnlockResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    ResonantChainGroupIndex: i32 = 0,
};
pub const RoleSexChangeRequest = struct {
    pub const default: @This() = .{};
    Sex: i32 = 0,
};
pub const RoleSexChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Sex: i32 = 0,
};
pub const RoleElementChangeRequest = struct {
    pub const default: @This() = .{};
    ElementType: i32 = 0,
};
pub const RoleElementChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RoleChangeNotify = struct {
    pub const default: @This() = .{};
    SourceRoleId: i32 = 0,
    RoleInfo: ?RoleInfo = null,
};
pub const RoleChangeUnlockNotify = struct {
    pub const default: @This() = .{};
    UnlockRoleIds: std.ArrayList(i32) = .empty,
    NextAllowChangeTime: i64 = 0,
};
pub const RoleSkinChangeRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkinId: i32 = 0,
    IsWearWeaponSkin: bool = false,
};
pub const RoleSkinChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const UnlockRoleSkinListRequest = struct {
    pub const default: @This() = .{};
};
pub const UnlockRoleSkinListResponse = struct {
    pub const default: @This() = .{};
    RoleSkinList: std.ArrayList(i32) = .empty,
};
pub const UnlockRoleSkinListNofity = struct {
    pub const default: @This() = .{};
    RoleSkinList: std.ArrayList(i32) = .empty,
};
pub const RoleOperateSelfBgmRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    IsOpen: bool = false,
};
pub const RoleOperateSelfBgmResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    IsOpen: bool = false,
};
pub const RoleDevelopConfigRequest = struct {
    pub const default: @This() = .{};
    aVersion: ?union(enum) {
        Version: []const u8,
    } = null,
};
pub const RoleDevelopConfigResponse = struct {
    pub const default: @This() = .{};
    Configs: ?RoleDevelopConfigs = null,
    ErrorCode: ?ErrorCode = null,
};
pub const RoleDevelopConfigs = struct {
    pub const default: @This() = .{};
    DevPropsList: std.ArrayList(RoleDevPropsConfig) = .empty,
    DevTargetRole: i32 = 0,
    DevPropsProjectList: std.ArrayList(RoleDevPropsProjectConfig) = .empty,
    Version: []const u8 = "",
    DevTargetPlanId: i32 = 0,
    DevTargetFirstPhantomId: i32 = 0,
};
pub const RoleDevPropsProjectConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    ElementId: i32 = 0,
    RoleName: []const u8 = "",
    RoleExperience: i32 = 0,
    RoleGoalLevel: i32 = 0,
    WeaponGoalLevel: i32 = 0,
    WeaponExperience: i32 = 0,
    RoleItemGroup: std.ArrayList(i32) = .empty,
    WeaponBreachItemGroup: std.ArrayList(i32) = .empty,
    WeaponType: i32 = 0,
    SkillItemGroup: std.ArrayList(i32) = .empty,
    PrefectSkillLevel: std.ArrayList(i32) = .empty,
    RoleHeadIcon: []const u8 = "",
    RoleHeadIconSmall: []const u8 = "",
    FormationRoleCard: []const u8 = "",
};
pub const RoleDevPropsConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    ProspectBeginTime: i64 = 0,
    ProspectEndTime: i64 = 0,
    TypeId: i32 = 0,
    GachaId: i32 = 0,
    SpecialGachaPair: std.ArrayList(SpecialGachaPair) = .empty,
    SortId: i32 = 0,
};
pub const SpecialGachaPair = struct {
    pub const default: @This() = .{};
    TypeId: i32 = 0,
    GachaId: i32 = 0,
};
pub const RoleConfigInfoNotify = struct {
    pub const default: @This() = .{};
    RoleConfigs: std.ArrayList(RoleConfigInfo) = .empty,
};
pub const RoleConfigInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillBranch: i32 = 0,
};
pub const RoleSkillBranchModifyRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillBranch: i32 = 0,
};
pub const RoleSkillBranchModifyResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RoleConfigInfoUpdateNotify = struct {
    pub const default: @This() = .{};
    RoleConfigs: std.ArrayList(RoleConfigInfo) = .empty,
};
pub const RoleSkillQuickLevelUpRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillId: i32 = 0,
    TargetLevel: i32 = 0,
    UseBox: bool = false,
};
pub const RoleSkillQuickLevelUpResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleInfo: ?RoleInfo = null,
};
pub const SecGetReportData2FlowRequest = struct {
    pub const default: @This() = .{};
    ReportData: []const u8 = "",
};
pub const SecGetReportData2FlowResponse = struct {
    pub const default: @This() = .{};
    Error: ?DErrorResult = null,
};
pub const Vector = struct {
    pub const default: @This() = .{};
    X: f32 = 0,
    Y: f32 = 0,
    Z: f32 = 0,
};
pub const Rotator = struct {
    pub const default: @This() = .{};
    Pitch: f32 = 0,
    Yaw: f32 = 0,
    Roll: f32 = 0,
};
pub const Transform = struct {
    pub const default: @This() = .{};
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
};
pub const EEntityType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Player = 0,
    Npc = 1,
    Monster = 2,
    SceneItem = 5,
    Custom = 6,
    Vision = 7,
    Animal = 8,
    ClientOnly = 9,
    Vehicle = 10,
    PlayerEntity = 11,
    SceneEntity = 12,
};
pub const EAttributeType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    None = 0,
    Lv = 1,
    LifeMax = 2,
    Life = 3,
    Sheild = 4,
    SheildDamageChange = 5,
    SheildDamageReduce = 6,
    Atk = 7,
    Crit = 8,
    CritDamage = 9,
    Def = 10,
    EnergyEfficiency = 11,
    CdReduse = 12,
    ElementEfficiency = 13,
    DamageChangeNormalSkill = 14,
    DamageChange = 15,
    DamageReduce = 16,
    DamageChangeAuto = 17,
    DamageChangeCast = 18,
    DamageChangeUltra = 19,
    DamageChangeQte = 20,
    DamageChangePhys = 21,
    DamageChangeElement1 = 22,
    DamageChangeElement2 = 23,
    DamageChangeElement3 = 24,
    DamageChangeElement4 = 25,
    DamageChangeElement5 = 26,
    DamageChangeElement6 = 27,
    DamageResistancePhys = 28,
    DamageResistanceElement1 = 29,
    DamageResistanceElement2 = 30,
    DamageResistanceElement3 = 31,
    DamageResistanceElement4 = 32,
    DamageResistanceElement5 = 33,
    DamageResistanceElement6 = 34,
    HealChange = 35,
    HealedChange = 36,
    DamageReducePhys = 37,
    DamageReduceElement1 = 38,
    DamageReduceElement2 = 39,
    DamageReduceElement3 = 40,
    DamageReduceElement4 = 41,
    DamageReduceElement5 = 42,
    DamageReduceElement6 = 43,
    SpecialEnergy5Max = 44,
    SpecialEnergy5 = 45,
    ReactionChange3 = 46,
    ReactionChange4 = 47,
    ReactionChange5 = 48,
    ReactionChange6 = 49,
    ReactionChange7 = 50,
    ReactionChange8 = 51,
    ReactionChange9 = 52,
    ReactionChange10 = 53,
    ReactionChange11 = 54,
    ReactionChange12 = 55,
    ReactionChange13 = 56,
    ReactionChange14 = 57,
    ReactionChange15 = 58,
    EnergyMax = 59,
    Energy = 60,
    SpecialEnergy1Max = 61,
    SpecialEnergy1 = 62,
    SpecialEnergy2Max = 63,
    SpecialEnergy2 = 64,
    SpecialEnergy3Max = 65,
    SpecialEnergy3 = 66,
    SpecialEnergy4Max = 67,
    SpecialEnergy4 = 68,
    StrengthMax = 69,
    Strength = 70,
    StrengthRecover = 71,
    StrengthPunishTime = 72,
    StrengthRun = 73,
    StrengthSwim = 74,
    StrengthFastSwim = 75,
    ElementEnergyMax = 76,
    ElementEnergy = 77,
    HardnessMax = 78,
    Hardness = 79,
    HardnessRecover = 80,
    HardnessPunishTime = 81,
    HardnessChange = 82,
    HardnessReduce = 83,
    ToughMax = 84,
    Tough = 85,
    ToughRecover = 86,
    ToughChange = 87,
    ToughReduce = 88,
    ElementPower1 = 89,
    ElementPower2 = 90,
    ElementPower3 = 91,
    ElementPower4 = 92,
    ElementPower5 = 93,
    ElementPower6 = 94,
    SpecialDamageChange = 95,
    StrengthFastClimbCost = 96,
    ElementPropertyType = 97,
    WeakTime = 98,
    IgnoreDefRate = 99,
    IgnoreDamageResistancePhys = 100,
    IgnoreDamageResistanceElement1 = 101,
    IgnoreDamageResistanceElement2 = 102,
    IgnoreDamageResistanceElement3 = 103,
    IgnoreDamageResistanceElement4 = 104,
    IgnoreDamageResistanceElement5 = 105,
    IgnoreDamageResistanceElement6 = 106,
    SkillToughRatio = 107,
    StrengthClimbJump = 108,
    StrengthGliding = 109,
    Mass = 110,
    BrakingFrictionFactor = 111,
    GravityScale = 112,
    SpeedRatio = 113,
    DamageChangePhantom = 114,
    AutoAttackSpeed = 115,
    CastAttackSpeed = 116,
    StatusBuildUp1Max = 117,
    StatusBuildUp1 = 118,
    StatusBuildUp2Max = 119,
    StatusBuildUp2 = 120,
    StatusBuildUp3Max = 121,
    StatusBuildUp3 = 122,
    StatusBuildUp4Max = 123,
    StatusBuildUp4 = 124,
    StatusBuildUp5Max = 125,
    StatusBuildUp5 = 126,
    RageMax = 127,
    Rage = 128,
    RageRecover = 129,
    RagePunishTime = 130,
    RageChange = 131,
    RageReduce = 132,
    ToughRecoverDelayTime = 133,
    Jump = 134,
    ParalysisTimeMax = 135,
    ParalysisTime = 136,
    ParalysisTimeRecover = 137,
    WeaknessBuildUp = 138,
    WeaknessBuildUpMax = 139,
    WeaknessTotalBonus = 140,
    BreakWeaknessRatio = 141,
    WeaknessMastery = 142,
    MAX = 143,
};
pub const GameplayAttributeData = struct {
    pub const default: @This() = .{};
    CurrentValue: i32 = 0,
    ValueIncrement: i32 = 0,
    AttributeType: ?EAttributeType = null,
};
pub const AttrData = struct {
    pub const default: @This() = .{};
    AttributeType: ?EAttributeType = null,
    CurrentValue: i32 = 0,
    ValueIncrement: i32 = 0,
};
pub const GameplayTagData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    TagCount: i32 = 0,
};
pub const CommonTagData = struct {
    pub const default: @This() = .{};
    TagId: i32 = 0,
    RemoveTagIds: bool = false,
};
pub const MovementInformation = struct {
    pub const default: @This() = .{};
    LinearVelocity: ?Vector = null,
    AngularVelocity: ?Vector = null,
    Location: ?Vector = null,
    Rotation: ?Rotator = null,
    bSimulatedPhysicSleep: bool = false,
    bRepPhysics: bool = false,
    MovementMode: i32 = 0,
    TimeStamp: f32 = 0,
    InputDirection: i32 = 0,
    ResetMeshOffset: bool = false,
    IsJump: bool = false,
    HorizontalJumpSpeed: f32 = 0,
};
pub const RelativeMoveReplaySample = struct {
    pub const default: @This() = .{};
    BaseMovementEntityId: i64 = 0,
    RelativeLocation: ?Vector = null,
    RelativeRotation: ?Rotator = null,
};
pub const MoveReplaySample = struct {
    pub const default: @This() = .{};
    LinearVelocity: ?Vector = null,
    Location: ?Vector = null,
    Rotation: ?Rotator = null,
    MovementMode: i32 = 0,
    TimeStamp: f32 = 0,
    InputDirection: i32 = 0,
    Tags: std.ArrayList(GameplayTagData) = .empty,
    RelativeMoveReplaySample: ?RelativeMoveReplaySample = null,
    ControllerPitch: f32 = 0,
    TimeScale: f32 = 0,
    ServerTimeStamp: i64 = 0,
    RTT: i32 = 0,
    SlideForward: ?Vector = null,
    MoveState: i32 = 0,
    SkillId: i64 = 0,
    ElapsedLogicTickTime: i32 = 0,
};
pub const PrivateTag = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    Tags: std.ArrayList([]const u8) = .empty,
};
pub const CombatCommon = struct {
    pub const default: @This() = .{};
    PreMessageId: i64 = 0,
    MessageId: i64 = 0,
    Originator: i64 = 0,
    TimeStamp: f32 = 0,
    EntityId: i64 = 0,
    IsServerRequest: bool = false,
};
pub const EntityRemoveInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Type: i32 = 0,
};
pub const RoleShowEntry = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Level: i32 = 0,
};
pub const PlayerDetails = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    Name: []const u8 = "",
    Level: i32 = 0,
    OriginWorldLevel: i32 = 0,
    CurWorldLevel: i32 = 0,
    HeadId: i32 = 0,
    HeadFrameId: i32 = 0,
    Signature: []const u8 = "",
    IsOnline: bool = false,
    IsCanLobbyOnline: bool = false,
    LastOfflineTime: i64 = 0,
    TeamMemberCount: i32 = 0,
    LevelGap: i32 = 0,
    Birthday: i32 = 0,
    RoleShowList: std.ArrayList(RoleShowEntry) = .empty,
    CardShowList: std.ArrayList(i32) = .empty,
    CurCard: i32 = 0,
    DisplayBirthday: bool = false,
    LastEnterMultiWillTime: i64 = 0,
    SdkUserId: []const u8 = "",
    SdkOnlineId: []const u8 = "",
    SdkAccountId: []const u8 = "",
    CrossPlayEnabled: bool = false,
    LimitState: i32 = 0,
    PlayerTitleId: i32 = 0,
    CurPlayerTitleId: i32 = 0,
    Sex: i32 = 0,
    Deactivation: bool = false,
    XboxUserId: []const u8 = "",
    XboxOnlineId: []const u8 = "",
    XboxAccountId: []const u8 = "",
    MatchXboxUser: bool = false,
    XboxSocialState: i32 = 0,
};
pub const EntitySimplyMoveInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Location: ?Vector = null,
    Rotation: ?Rotator = null,
};
pub const BlockState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BStateAll = 0,
    BStateSimple = 1,
    BStateComplete = 2,
};
pub const AchievementProgress = struct {
    pub const default: @This() = .{};
    CurProgress: i32 = 0,
    TotalProgress: i32 = 0,
};
pub const AchievementEntry = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    FinishTime: u32 = 0,
    IsReceive: bool = false,
    Progress: ?AchievementProgress = null,
};
pub const AchievementGroupEntry = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    FinishTime: u32 = 0,
    IsReceive: bool = false,
};
pub const AchievementGroupInfo = struct {
    pub const default: @This() = .{};
    AchievementGroupEntry: ?AchievementGroupEntry = null,
    AchievementEntryList: std.ArrayList(AchievementEntry) = .empty,
};
pub const AchievementInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const AchievementInfoResponse = struct {
    pub const default: @This() = .{};
    AchievementGroupInfoList: std.ArrayList(AchievementGroupInfo) = .empty,
    AchievementFinishedStar: i32 = 0,
    FinishedAchievementNum: i32 = 0,
};
pub const UpdateAchievementInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const UpdateAchievementInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    AchievementEntryList: std.ArrayList(AchievementEntry) = .empty,
};
pub const LevelEventNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    IncId: i32 = 0,
    GameCtx: ?GameCtxPb = null,
    TotalCount: i32 = 0,
    StartIndex: i32 = 0,
    EndIndex: i32 = 0,
    NeedFinishReq: bool = false,
};
pub const GameCtxType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BehaviorTree = 0,
    Entity = 1,
    NormalInteract = 2,
    DynamicInteract = 3,
    RandomInteract = 4,
    EntityStateChangeAction = 5,
    EntityGroupAction = 6,
    EntityTrigger = 7,
    EntityLeaveTrigger = 8,
    EntityDestructible = 9,
    EntityTimelineTrack = 10,
    LevelPlayOpenAction = 11,
    LevelPlayRewardAction = 12,
    QuestActiveAction = 13,
    QuestAcceptAction = 14,
    QuestFinishAction = 15,
    ChildQuestNodeEnterAction = 16,
    ChildQuestNodeFinishAction = 17,
    SuccessNodeAction = 18,
    FailedNodeAction = 19,
    CompositionEnterAction = 20,
    EntityConditionListeningAction = 21,
    PlayFlowChildQuestNode = 22,
    HandInItemChildQuestNode = 23,
    DoInteractChildQuestNode = 24,
    ActionGroupNodeAction = 25,
    ExploreSkillPullGiantAction = 26,
    LevelPlay = 27,
    GmLevelAction = 28,
    GmPlayFlow = 29,
    SceneItemLifeCycleComponentCreate = 30,
    SceneItemLifeCycleComponentDetroy = 31,
    GameCtxGm = 32,
    FlowActionCtx = 33,
    DailyQuestTerminateAction = 34,
    ChildQuestNodeFixAction = 35,
    ConditionNodeFixAction = 36,
    EntityFixAction = 37,
    ConditionNode = 38,
    EntityBeamReceiveAction = 39,
    EntityGroupFailureAction = 40,
    ChildQuestNodeCondition = 41,
    EntityStateChangeConditionAction = 42,
    RequestPlayerGameCurrStateBt = 43,
    RequestEntityCurrState = 44,
    TriggerConditionListeningAction = 45,
    FlowStartTeleport = 46,
    EntityVisibleCondition = 47,
    FailedNodeTeleport = 48,
    LeaveInstEscActionCtx = 49,
    TrampleActiveActionCtx = 50,
    TrampleDeActiveActionCtx = 51,
    DefaultGameCtx = 52,
    LevelPlayExploratoryCtx = 53,
    RenjuCompleteActionCtx = 54,
    JigsawFoundationMatchedActionCtx = 55,
    CompositionFixAction = 56,
    JigsawFoundationUnMatchedActionCtx = 57,
    HookLockPointActionCtx = 58,
    ClientTriggerActionCtx = 59,
    ExploreSkillCustomAction = 60,
    LevelSequenceFrameEventAction = 61,
    JigsawFoundationMatchedConditionActionCtx = 62,
    CameraAlertComponentCreate = 63,
    RenjuExitMatchedAction = 64,
    RenjuExitUnMatchedAction = 65,
    LevelPlayDestroyAction = 66,
    EffectAreaConditionListeningAction = 67,
    OccupationInfoAction = 68,
    EntityHeadInfoCondition = 69,
    TemplateSpawnerConditionListen = 70,
    TemplateSpawnerAction = 71,
    BatchRefresherConditionListen = 72,
    QuestDestroyAction = 73,
    RequestGameCurrState = 74,
    TemplateSpawnerStateConditionListen = 75,
    CompositionConditionEnterAction = 76,
    TrapDefenseSystem = 77,
    SceneItemSequenceFrameEventActionCtx = 78,
    TargetGearHitPart = 79,
    GlobalFixCtx = 80,
    ChildQuestNodeStuckCheckAction = 81,
    GameCurrFetchVar = 82,
    EntityAfterConditionActionCtx = 83,
    ChildQuestNodePreCondition = 84,
    BtNodePreCondition = 85,
    DynamicSpawnMonsterRefresherConditionListen = 86,
    BeamCastHitPlayerActionCtx = 87,
    MotorSliderCtx = 88,
    RollBlockGamePlayActionCtx = 89,
    MotorParkourSystem = 90,
    TransferCtx = 91,
    SystemModuleDataSyncComponent = 92,
    DynamicEntityRewardCtx = 93,
    ExploreSkillAction = 94,
    MotorFightActivity = 95,
    PasserByNpcSpawnerConditionListenCtx = 96,
    EffectAreaListeningAction = 97,
    SurvivorsSystem = 98,
    TimeScheduleConditionCtx = 99,
    EntityBeamReceiveConditionCtx = 100,
    FlowerPollutionActionCtx = 101,
    KurotatoSystem = 102,
    EntityQuickHackSkill = 103,
    RecallQuestActiveAction = 104,
    RecallQuestAcceptAction = 105,
    RecallQuestFinishAction = 106,
    RecallQuestDestroyAction = 107,
    EdDebugEnterAction = 3401,
    SetClientGlobalVarAction = 3402,
};
pub const GameCtxPb = struct {
    pub const default: @This() = .{};
    CtxInfo: ?union(enum) {
        BehaviorTree: ?BehaviorTreeCtxPb,
        Entity: ?EntityCtxPb,
        NormalInteract: ?NormalInteractCtxPb,
        DynamicInteract: ?*DynamicInteractCtxPb,
        RandomInteract: ?RandomInteractCtxPb,
        StateChangeAction: ?StateChangeActionCtxPb,
        EntityGroupAction: ?EntityGroupActionCtxPb,
        EntityTrigger: ?EntityTriggerCtxPb,
        EntityLeaveTriggerCtx: ?EntityLeaveTriggerCtxPb,
        EntityDestructible: ?EntityDestructibleCtxPb,
        EntityTimelineTrack: ?EntityTimelineTrackCtxPb,
        LevelPlayOpenAction: ?LevelPlayOpenActionCtxPb,
        LevelPlayRewardAction: ?LevelPlayRewardActionCtxPb,
        QuestActiveAction: ?QuestActiveActionCtxPb,
        QuestAcceptAction: ?QuestAcceptActionCtxPb,
        QuestFinishAction: ?QuestFinishActionCtxPb,
        ChildQuestNodeEnterAction: ?ChildQuestNodeEnterActionCtxPb,
        ChildQuestNodeFinishAction: ?ChildQuestNodeFinishActionCtxPb,
        SuccessNodeAction: ?SuccessNodeActionCtxPb,
        FailedNodeAction: ?FailedNodeActionCtxPb,
        CompositionEnterAction: ?CompositionEnterActionCtxPb,
        EntityConditionListeningAction: ?EntityConditionListeningActionCtxPb,
        PlayFlowChildQuestNode: ?PlayFlowChildQuestNodeCtxPb,
        HandInItemChildQuestNode: ?HandInItemChildQuestNodeCtxPb,
        DoInteractChildQuestNode: ?DoInteractChildQuestNodeCtxPb,
        ActionGroupNodeAction: ?ActionGroupNodeActionCtxPb,
        ExploreSkillPullGiantAction: ?ExploreSkillPullGiantCtxPb,
        LevelPlay: ?LevelPlayCtxPb,
        GmLevelAction: ?GmLevelActionCtxPb,
        LifeCycleCreateAction: ?SceneItemLifeCycleComponentCreateCtxPb,
        LifeCycleDestroyAction: ?SceneItemLifeCycleComponentDestroyCtxPb,
        FlowAction: ?FlowActionCtxPb,
        DailyQuestTerminateAction: ?DailyQuestTerminateActionCtxPb,
        EntityBeamReceiveAction: ?BeamReceiveAction,
        EntityGroupFailureAction: ?EntityGroupFailureCtxPb,
        EntityStateChangeConditionAction: ?SceneItemStateChangeConditionAction,
        FlowStartTeleport: ?FlowStartTeleportCtxPb,
        LeaveInstEscActionCtx: ?LeaveInstEscActionCtxPb,
        TrampleActiveAction: ?TrampleActivateCtxPb,
        TrampleDeActiveAction: ?TrampleDeActiveCtxPb,
        RenjuCompleteAction: ?RenjuCompleteActionCtxPb,
        JigsawFoundationMatchedAction: ?JigsawFoundationMatchedActionCtxPb,
        JigsawFoundationUnMatchedAction: ?JigsawFoundationUnMatchedActionCtxPb,
        HookLockPointAction: ?HookLockPointActionCtxPb,
        ClientTriggerAction: ?ClientTriggerActionCtxPb,
        ExploreSkillCustomAction: ?ExploreSkillCustomCtxPb,
        JigsawFoundationMatchedConditionAction: ?JigsawFoundationMatchedConditionActionCtxPb,
        LevelPlayDestroyAction: ?LevelPlayDestroyActionCtxPb,
        TemplateSpawnerAction: ?TemplateSpawnerActionCtxPb,
        QuestDestroyAction: ?QuestDestroyActionCtxPb,
        CompositionConditionEnterAction: ?CompositionConditionEnterActionCtxPb,
        TargetGearHitPartAction: ?TargetGearHitPartCtxPb,
        GlobalFix: ?GlobalFixCtxPb,
        StuckCheckAction: ?StuckCheckCtxPb,
        AfterConditionAction: ?EntityAfterConditionActionCtxPb,
        MotorSlider: ?MotorSliderCtxPb,
        RollBlockGamePlayAction: ?RollBlockGamePlayActionCtxPb,
        Transfer: ?TransferCtxPb,
        DynamicEntityReward: ?DynamicEntityRewardCtxPb,
        BeamCastHitPlayerActionCtxPb: ?BeamCastHitPlayerActionCtxPb,
        ExploreSkillAction: ?ExploreSkillActionCtxPb,
        PollutionRangeAction: ?PlayEnterOrExitPollutionRangeCtxPb,
        EntityQuickHackSkillAction: ?EntityQuickHackSkillCtxPb,
        RecallQuestActiveAction: ?RecallQuestActiveActionCtxPb,
        RecallQuestAcceptAction: ?RecallQuestAcceptActionCtxPb,
        RecallQuestFinishAction: ?RecallQuestFinishActionCtxPb,
        RecallQuestDestroyAction: ?RecallQuestDestroyActionCtxPb,
        EdDebugEnterAction: ?EdDebugEnterActionCtxPb,
    } = null,
    CtxType: ?GameCtxType = null,
};
pub const EntityCtxPb = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    IncId: i64 = 0,
};
pub const NormalInteractCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    OptionIndex: i32 = 0,
};
pub const DynamicInteractCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    OptionGuid: []const u8 = "",
    finalOptionCtx: ?GameCtxPb = null,
};
pub const MotorSliderCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    IsEnter: bool = false,
};
pub const RandomInteractCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    OptionIndex: i32 = 0,
};
pub const StateChangeActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    StateIndex: i32 = 0,
};
pub const SceneItemStateChangeConditionAction = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    StateIndex: i32 = 0,
    ConditionIndex: i32 = 0,
};
pub const EntityGroupActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    TriggerIndex: i32 = 0,
    IsMatch: bool = false,
};
pub const EntityGroupFailureCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const EntityTriggerCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    TriggerEntityIncId: i64 = 0,
};
pub const ClientTriggerActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    IsEnter: bool = false,
};
pub const EntityLeaveTriggerCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    TriggerEntityIncId: i64 = 0,
};
pub const EntityDestructibleCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const EntityTimelineEventType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    LeftIn = 0,
    LeftOut = 1,
    RightIn = 2,
    RightOut = 3,
};
pub const EntityTimelineTrackCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    GroupIndex: i32 = 0,
    ControlPoint: i32 = 0,
    EventType: ?EntityTimelineEventType = null,
};
pub const EntityConditionListeningActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    EntityConditionListeningIndex: i32 = 0,
};
pub const EntityAfterConditionActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    PreCondtionListeningIndex: i32 = 0,
    AfterCondtionListeningIndex: i32 = 0,
};
pub const BeamCastHitPlayerActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const ExploreSkillPullGiantCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const ExploreSkillCustomCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const GmLevelActionCtxPb = struct {
    pub const default: @This() = .{};
    JsonStr: []const u8 = "",
};
pub const SceneItemLifeCycleComponentCreateCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const SceneItemLifeCycleComponentDestroyCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const TrampleActivateCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const TrampleDeActiveCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const RenjuCompleteActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    Controller: i32 = 0,
};
pub const JigsawFoundationMatchedActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    MatchedIndex: i32 = 0,
};
pub const JigsawFoundationUnMatchedActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    MatchedIndex: i32 = 0,
};
pub const JigsawFoundationMatchedConditionActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    MatchedIndex: i32 = 0,
    ConditionIndex: i32 = 0,
};
pub const DynamicEntityRewardCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const ExploreSkillActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const BehaviorTreeCtxPb = struct {
    pub const default: @This() = .{};
    IncId: i64 = 0,
    BtType: ?BtType = null,
    BtId: i32 = 0,
    NodeId: i32 = 0,
};
pub const LevelPlayCtxPb = struct {
    pub const default: @This() = .{};
    LevelPlayId: i32 = 0,
};
pub const LevelPlayOpenActionCtxPb = struct {
    pub const default: @This() = .{};
    LevelPlayId: i32 = 0,
};
pub const LevelPlayDestroyActionCtxPb = struct {
    pub const default: @This() = .{};
    LevelPlayId: i32 = 0,
};
pub const LevelPlayRewardActionCtxPb = struct {
    pub const default: @This() = .{};
    LevelPlayId: i32 = 0,
};
pub const QuestActiveActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const QuestAcceptActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const QuestFinishActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const DailyQuestTerminateActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const QuestDestroyActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const LeaveInstEscActionCtxPb = struct {
    pub const default: @This() = .{};
    InstanceId: i32 = 0,
};
pub const ChildQuestNodeEnterActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const ChildQuestNodeFinishActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const SuccessNodeActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const FailedNodeActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const CompositionEnterActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const CompositionConditionEnterActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
    ConditionIndex: i32 = 0,
};
pub const TargetGearHitPartCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    HitPartIndex: i32 = 0,
};
pub const PlayFlowChildQuestNodeCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const HandInItemChildQuestNodeCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const DoInteractChildQuestNodeCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const ActionGroupNodeActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const FlowActionCtxPb = struct {
    pub const default: @This() = .{};
    FlowListName: []const u8 = "",
    FlowId: i32 = 0,
    StateId: i32 = 0,
    ActionId: i32 = 0,
};
pub const BeamReceiveActionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BeginAction = 0,
    CompleteAction = 1,
    StopAction = 2,
};
pub const BeamReceiveAction = struct {
    pub const default: @This() = .{};
    ReceiveType: ?BeamReceiveActionType = null,
    EntityCtx: ?EntityCtxPb = null,
};
pub const PlayEnterOrExitPollutionRangeType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    EnterAction = 0,
    ExitAction = 1,
};
pub const PlayEnterOrExitPollutionRangeCtxPb = struct {
    pub const default: @This() = .{};
    RangeType: ?PlayEnterOrExitPollutionRangeType = null,
    EntityCtx: ?EntityCtxPb = null,
};
pub const FlowStartTeleportCtxPb = struct {
    pub const default: @This() = .{};
    FlowListName: []const u8 = "",
    FlowId: i32 = 0,
    StateId: i32 = 0,
};
pub const HookInteractActionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Hooked = 0,
    ExitMidway = 1,
    ExitEndpoint = 2,
};
pub const HookLockPointActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    InteractionType: ?HookInteractActionType = null,
};
pub const TemplateSpawnerActionCtxPb = struct {
    pub const default: @This() = .{};
    Type: ?union(enum) {
        DestroyType: ?DestroyType,
    } = null,
    EntityCtx: ?EntityCtxPb = null,
};
pub const GlobalFixCtxPb = struct {
    pub const default: @This() = .{};
    FixId: i32 = 0,
};
pub const StuckCheckCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
    Index: i32 = 0,
};
pub const RollBlockGamePlayActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
    ParamType: i32 = 0,
};
pub const TransferCtxPb = struct {
    pub const default: @This() = .{};
    TeleportId: i32 = 0,
};
pub const EntityQuickHackSkillCtxPb = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
    EntityState: i32 = 0,
    EntityCtx: ?EntityCtxPb = null,
};
pub const RecallQuestActiveActionCtxPb = struct {
    pub const default: @This() = .{};
    RecallQuestId: i32 = 0,
};
pub const EdDebugEnterActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const RecallQuestAcceptActionCtxPb = struct {
    pub const default: @This() = .{};
    RecallQuestId: i32 = 0,
};
pub const RecallQuestFinishActionCtxPb = struct {
    pub const default: @This() = .{};
    RecallQuestId: i32 = 0,
};
pub const RecallQuestDestroyActionCtxPb = struct {
    pub const default: @This() = .{};
    RecallQuestId: i32 = 0,
};
pub const TeleportUpdateNotify = struct {
    pub const default: @This() = .{};
    Ids: std.ArrayList(i32) = .empty,
};
pub const TeleportDataRequest = struct {
    pub const default: @This() = .{};
};
pub const TeleportDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Ids: std.ArrayList(i32) = .empty,
};
pub const TeleportTransferRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
};
pub const TeleportTransferResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MapId: i32 = 0,
    PosX: f32 = 0,
    PosY: f32 = 0,
    PosZ: f32 = 0,
    Pitch: f32 = 0,
    Yaw: f32 = 0,
    Roll: f32 = 0,
};
pub const TeleportReason = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Transfer = 0,
    ApiTeleport = 1,
    BtRollbackFailed = 2,
    ParkourTrans = 3,
    Gm = 4,
    Rouge = 5,
    Fall = 6,
    Action = 7,
    UnOpenedAreaPullback = 8,
    TemporaryTransfer = 9,
    FlowAction = 10,
    Drown = 11,
    FlowStart = 12,
    CorniceTrans = 13,
    TeleportVehicle = 14,
    GetOff = 15,
    LeaveGravityRegion = 16,
    TeleportToBoat = 17,
    GravityFlip = 18,
    RogueRes = 19,
    AbyssTeleport = 20,
    GmForce = 21,
    CharacterMoveToPoint = 22,
    InstEntity = 23,
    InstRequestTeleportResetPoint = 24,
    StrongWindField = 25,
    FastReturn = 26,
    RoverRogueRoomInChaos = 27,
};
pub const TeleportNotify = struct {
    pub const default: @This() = .{};
    v70: ?union(enum) {
        TransferEffectId: i32,
    } = null,
    MapId: i32 = 0,
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
    Gravity: ?Vector = null,
    Reason: ?TeleportReason = null,
    GameCtx: ?GameCtxPb = null,
    TransitionOption: ?TransitionOptionPb = null,
    DisableAutoFade: bool = false,
};
pub const TransitionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Empty = 0,
    PlayEffect = 1,
    PlayMp4 = 2,
    CenterText = 3,
    FadeInScreen = 4,
    Seamless = 5,
    WithCharacterDisplay = 6,
    WithCustomLoading = 7,
    WithSpine = 8,
    WithSpecialCustomLoading = 9,
    PlayFlow = 10,
};
pub const TransitionOptionPb = struct {
    pub const default: @This() = .{};
    Option: ?union(enum) {
        TransitionMp4: ?TransitionMp4Pb,
        TransitionFlow: ?TransitionFlowPb,
        TransitionInSeamless: ?TransitionInSeamlessPb,
        FadeInScreenShowTime: i32,
        TransitionWithCharacterDisplay: ?TransitionWithCharacterDisplayPb,
        TransitionWithCustomLoading: ?TransitionWithCustomLoadingPb,
        TransitionWithSpineLoadingPb: ?TransitionWithSpineLoadingPb,
        TransitionWithSpecialCustomLoadingPb: ?TransitionWithSpecialCustomLoadingPb,
        PlayFlowPb: ?TransitionPlayFlowPb,
    } = null,
    TransitionType: ?TransitionType = null,
};
pub const Mp4BackgroundColor = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Mp4BackgroundColorBlack = 0,
    Mp4BackgroundColorWhite = 1,
};
pub const AfterTeleportScreenColor = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    AfterTeleportScreenColorBlack = 0,
    AfterTeleportScreenColorWhite = 1,
};
pub const Mp4BackgroundColorPb = struct {
    pub const default: @This() = .{};
    FadeIn: ?Mp4BackgroundColor = null,
    FadeOut: ?Mp4BackgroundColor = null,
};
pub const TransitionMp4Pb = struct {
    pub const default: @This() = .{};
    ScreenColor: ?union(enum) {
        AfterTeleportScreenColor: ?AfterTeleportScreenColor,
    } = null,
    ResourePath: []const u8 = "",
    ReplayWhenReLogin: bool = false,
    IsFadeInScreenAfterTeleport: bool = false,
    Mp4BackgroundColor: ?Mp4BackgroundColorPb = null,
};
pub const TransitionFlowPb = struct {
    pub const default: @This() = .{};
    FlowListName: []const u8 = "",
    FlowId: i32 = 0,
    StateId: i32 = 0,
};
pub const KeepMovementState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    KeepMovementStateInvalid = 0,
    Kite = 1,
    Soar = 2,
};
pub const TransitionInSeamlessPb = struct {
    pub const default: @This() = .{};
    WeatherDaPath: ?union(enum) {
        TransitionWeatherDaPath: []const u8,
    } = null,
    EffectDaPath: ?union(enum) {
        SceneEffectDaPath: []const u8,
    } = null,
    Config: ?union(enum) {
        SeamlessTeleportFinishConfig: ?SeamlessTeleportFinishConfigPb,
    } = null,
    EffectPath: []const u8 = "",
    LeastTime: f32 = 0,
    EffectExpandTime: f32 = 0,
    EffectCollapseTime: f32 = 0,
    HasFloorParams: bool = false,
    FloorParams: ?FloorParams = null,
    IsTeleportInPlace: bool = false,
    KeepStates: std.ArrayList(KeepMovementState) = .empty,
};
pub const TransitionWithCharacterDisplayPb = struct {
    pub const default: @This() = .{};
    StyllId: i32 = 0,
};
pub const TransitionWithCustomLoadingPb = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const FloorParams = struct {
    pub const default: @This() = .{};
    FloorMeshPath: []const u8 = "",
    FloorMaterialPath: []const u8 = "",
    PosX: f32 = 0,
    PosY: f32 = 0,
    FloorAppearTime: f32 = 0,
    FloorDisappearTime: f32 = 0,
};
pub const SeamlessTeleportFinishConfigPb = struct {
    pub const default: @This() = .{};
    IsnotStopScreenEffect: bool = false,
    EffectExtraState: i32 = 0,
};
pub const TeleportFinishRequest = struct {
    pub const default: @This() = .{};
};
pub const TeleportFinishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const TransitionWithSpineLoadingPb = struct {
    pub const default: @This() = .{};
    BackgroundFadeInEffectPb: ?union(enum) {
        FadeBackgroundFadeInEffectPb: ?FadeBackgroundFadeInEffectPb,
    } = null,
    BackgroundFadeOutEffectPb: ?union(enum) {
        FadeBackgroundFadeOutEffectPb: ?FadeBackgroundFadeOutEffectPb,
    } = null,
    Time: ?union(enum) {
        KeepTime: f32,
    } = null,
    CustomShowUiPb: ?union(enum) {
        ICustomShowUiPb: ?ICustomShowUiPb,
    } = null,
    AkEvent: ?union(enum) {
        StartAkEvent: []const u8,
    } = null,
    ICustomScreenTypeBasePb: ?ICustomScreenTypeBasePb = null,
};
pub const TransitionPlayFlowPb = struct {
    pub const default: @This() = .{};
    ActionParamPb: ?TransitionPlayFlowActionParamPb = null,
    FadeBackgroundFadeInEffectPb: ?FadeBackgroundFadeInEffectPb = null,
    FadeBackgroundFadeOutEffectPb: ?FadeBackgroundFadeOutEffectPb = null,
};
pub const TransitionPlayFlowActionParamPb = struct {
    pub const default: @This() = .{};
    FlowListName: []const u8 = "",
    FlowId: i32 = 0,
    StateId: i32 = 0,
    FlowGuid: []const u8 = "",
};
pub const TransitionWithSpecialCustomLoadingPb = struct {
    pub const default: @This() = .{};
    LoadingType: ?union(enum) {
        HonamiStoryCustomLoadingPb: ?HonamiStoryCustomLoadingPb,
    } = null,
};
pub const HonamiStoryCustomLoadingPb = struct {
    pub const default: @This() = .{};
    LoadingId: i32 = 0,
};
pub const ICustomScreenTypeBasePb = struct {
    pub const default: @This() = .{};
    ScreenPb: ?union(enum) {
        ICustomScreenSpinePb: ?ICustomScreenSpinePb,
        ICustomScreenBackgroundImagePb: ?ICustomScreenBackgroundImagePb,
        ICustomScreenLoadingPb: ?ICustomScreenLoadingPb,
    } = null,
};
pub const ICustomScreenSpinePb = struct {
    pub const default: @This() = .{};
    SpineId: i32 = 0,
};
pub const ICustomScreenBackgroundImagePb = struct {
    pub const default: @This() = .{};
    BgPath: []const u8 = "",
};
pub const ICustomScreenLoadingPb = struct {
    pub const default: @This() = .{};
    LoadingType: ?union(enum) {
        ICustomScreenLoadingCyberpunkPb: ?ICustomScreenLoadingCyberpunkPb,
    } = null,
};
pub const ICustomScreenLoadingCyberpunkPb = struct {
    pub const default: @This() = .{};
};
pub const ICustomShowUiPb = struct {
    pub const default: @This() = .{};
    CustomScreenTextSettingPb: ?union(enum) {
        ICustomScreenTextSettingPb: ?ICustomScreenTextSettingPb,
    } = null,
    HideCircle: ?union(enum) {
        IsHideCircle: bool,
    } = null,
};
pub const ICustomScreenTextSettingPb = struct {
    pub const default: @This() = .{};
    ShowTextInfo: ?union(enum) {
        IsShowTextInfo: bool,
    } = null,
    TextContent: ?union(enum) {
        TidTextContent: []const u8,
    } = null,
    EdTextContent: ?union(enum) {
        EdTidTextContent: []const u8,
    } = null,
};
pub const FadeBackgroundFadeInEffectPb = struct {
    pub const default: @This() = .{};
    FadeInEffectPb: ?union(enum) {
        FadeBackgroundFadeInEffectBlackPb: ?FadeBackgroundFadeInEffectBlackPb,
        FadeBackgroundFadeInEffectScreenPb: ?FadeBackgroundFadeInEffectScreenPb,
    } = null,
};
pub const FadeBackgroundFadeInEffectBlackPb = struct {
    pub const default: @This() = .{};
    FadeIn: ?union(enum) {
        FadeInTime: f32,
    } = null,
    FadeOut: ?union(enum) {
        FadeOutTime: f32,
    } = null,
    FadeColor: i32 = 0,
};
pub const FadeBackgroundFadeInEffectScreenPb = struct {
    pub const default: @This() = .{};
    ScreenEffect: []const u8 = "",
};
pub const FadeBackgroundFadeOutEffectPb = struct {
    pub const default: @This() = .{};
    FadeOutEffectPb: ?union(enum) {
        FadeBackgroundFadeOutEffectBlackPb: ?FadeBackgroundFadeOutEffectBlackPb,
        FadeBackgroundFadeOutEffectSceenPb: ?FadeBackgroundFadeOutEffectSceenPb,
    } = null,
};
pub const FadeBackgroundFadeOutEffectBlackPb = struct {
    pub const default: @This() = .{};
    FadeIn: ?union(enum) {
        FadeInTime: f32,
    } = null,
    FadeOut: ?union(enum) {
        FadeOutTime: f32,
    } = null,
    FadeColor: i32 = 0,
};
pub const FadeBackgroundFadeOutEffectSceenPb = struct {
    pub const default: @This() = .{};
    ScreenEffect: []const u8 = "",
};
pub const CircumFluenceTaskData = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(ActivityTask) = .empty,
    ClaimedReward: std.ArrayList(ActivityTask) = .empty,
    TaskScoreRewardId: std.ArrayList(i32) = .empty,
    NowOpen: bool = false,
    EndTime: i64 = 0,
    NextRefreshTime: i64 = 0,
};
pub const ActivityType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Parkour = 0,
    GatherActivity = 1,
    Sign = 2,
    TowerGuide = 3,
    NewBieCourse = 4,
    WorldNewJourney = 5,
    RougeActivity = 6,
    DoubleInstanceRewardActivity = 7,
    RoleTrialActivity = 8,
    Harvest = 9,
    NewRoleGuideActivity = 10,
    PhantomCollect = 11,
    DailyAdventureActivity = 12,
    LongShanMainActivity = 13,
    BossRushActivity = 14,
    TurnTableActivity = 15,
    PhotoMemoryActivity = 16,
    TrackMoonActivity = 17,
    CircumFluence = 18,
    TowerDefenceActivity = 19,
    TimePointRewardActivity = 20,
    TowerGuideNew = 21,
    TrackMoonPhase = 22,
    RiskHarvest = 23,
    CorniceMeeting = 24,
    BlackCoastTheme = 25,
    RogueWhiteCat = 26,
    ScratchCard = 27,
    PreheatSign = 28,
    MowTower = 29,
    ThroughTrain = 30,
    SprintSign = 31,
    MapTravelActivity = 32,
    FarmGold = 33,
    NewLordGym = 34,
    RoleSkinTrialActivity = 35,
    RogueWeekly = 36,
    FishingActivity = 37,
    TeamParkOurActivity = 38,
    SlashAndTowerLevelPlay = 39,
    BabelTower = 40,
    Avignon = 41,
    BetHorses = 42,
    Explore = 43,
    Abyss = 44,
    RogueRes = 45,
    H5CircumFluence = 46,
    DangoMonopoly = 47,
    CiacconaActivity = 48,
    ActivityLinkage = 49,
    RegressActivity = 50,
    ConsumptiveActivity = 51,
    PhantomBattle = 52,
    NewbieCarnival = 53,
    MoraleActivity = 54,
    FloroRanchActivity = 55,
    LifePointChallenge = 56,
    TrapDefense = 57,
    JinzhouFlyActivity = 58,
    FunPlay = 59,
    MoonPhase = 60,
    LineCross = 61,
    HonamiStory = 62,
    Survivors = 63,
    PhotoFight = 64,
    WuWuKuji = 65,
    FirstPersonParkour = 66,
    PreHeatTaskActivity = 67,
    InfrTheme = 68,
    AdvanceNoticeActivity = 69,
    PhantomBattleRecord = 70,
    CoopActivity = 71,
    PhantomBattleRecordGuide = 72,
    ArtemisActivity = 73,
    MotorcycleIpLink = 74,
    SkinRewardActivity = 75,
    RoadBookActivity = 76,
    NewTowerClimbing = 77,
    MotorFight = 78,
    Encircle = 79,
    NewPlayerSupportActivity = 80,
    SpringFestivalActivity = 81,
    MotorParkourActivity = 82,
    TotalTopUp = 83,
    H5View = 84,
    MotorDevelop = 85,
    FlagChallenge = 86,
    Rhythm = 87,
    FeiXue = 89,
    DropCatchActivity = 90,
    TetrisActivity = 91,
    InfrThemeV2 = 92,
    Kurotato = 93,
    PinballActivity = 94,
    WuWuWeekSign = 96,
    AnniversaryTheme = 97,
    BossPiling = 98,
    GolemCrackActivity = 99,
    EdgeRunnerActivity = 100,
    MotorDecalActivity = 101,
    MotorParkour = 102,
    LinkageCheckIn = 103,
    RoleGiftActivity = 104,
    RealmBetween = 105,
    SheriffActivity = 106,
    ThroughTrainSummary = 107,
    NewPlayerSupportActivityV2 = 108,
    NewbieAdventureV2 = 109,
    NewbieCourseV2 = 110,
    NewbieMain = 111,
    RoverRogue = 112,
    QingXiaoPlayThePiano = 114,
    PurePreviewActivity = 115,
    PureUIActivity = 200,
};
pub const ParkourActivityChallenge = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const ParkourActivity = struct {
    pub const default: @This() = .{};
    Challenges: std.ArrayList(ParkourActivityChallenge) = .empty,
};
pub const DoubleInstActivityReward = struct {
    pub const default: @This() = .{};
    GetDoubleInstRwdCount: i32 = 0,
};
pub const GatherActivityTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    GatherLock = 0,
    GatherRunning = 1,
    GatherInComplete = 2,
    GatherDone = 3,
    GatherTakeReward = 4,
};
pub const GatherTaskDoneInfo = struct {
    pub const default: @This() = .{};
    TaskId: i32 = 0,
    State: ?GatherActivityTaskState = null,
};
pub const GatherActivityInfo = struct {
    pub const default: @This() = .{};
    GatherTaskDoneInfo: std.ArrayList(GatherTaskDoneInfo) = .empty,
};
pub const SignState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Lock = 0,
    Unlock = 1,
    IsReceive = 2,
};
pub const SignActivity = struct {
    pub const default: @This() = .{};
    SignStateList: std.ArrayList(i32) = .empty,
    RewardFree: bool = false,
};
pub const HarvestPointReward = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    State: i32 = 0,
};
pub const HarvestLevelReward = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    StartTime: i32 = 0,
    IsOpen: bool = false,
    Points: i32 = 0,
    Diff: i32 = 0,
    State: i32 = 0,
};
pub const HarvestActivity = struct {
    pub const default: @This() = .{};
    HarvestPointRewards: std.ArrayList(HarvestPointReward) = .empty,
    HarvestLevelRewards: std.ArrayList(HarvestLevelReward) = .empty,
};
pub const NewBieCourseActivity = struct {
    pub const default: @This() = .{};
    HadTakeReward: std.ArrayList(i32) = .empty,
};
pub const RoleTrialTask = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    ChallengeState: i32 = 0,
    BeginOpenTime: i64 = 0,
    EndOpenTime: i64 = 0,
};
pub const RoleTrialInfoActivity = struct {
    pub const default: @This() = .{};
    RoleTrialTask: std.ArrayList(RoleTrialTask) = .empty,
};
pub const PhantomCollectReward = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        Progress: ?PhantomCollectProgress,
    } = null,
    Type: i32 = 0,
    State: i32 = 0,
};
pub const PhantomCollectProgress = struct {
    pub const default: @This() = .{};
    Phantoms: std.ArrayList(i32) = .empty,
};
pub const PhantomCollectActivity = struct {
    pub const default: @This() = .{};
    PhantomCollectRewards: std.ArrayList(PhantomCollectReward) = .empty,
};
pub const ActivityRogueData = struct {
    pub const default: @This() = .{};
    BeginOpenTime: i64 = 0,
    EndOpenTime: i64 = 0,
    RoguelikeSeason: ?RoguelikeSeason = null,
};
pub const RoguelikeTokenList = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IsReceive: bool = false,
};
pub const RogueSeasonReward = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IsReceive: bool = false,
};
pub const RoguelikeSeason = struct {
    pub const default: @This() = .{};
    SeasonId: i32 = 0,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
    RoguelikeTokenList: std.ArrayList(RoguelikeTokenList) = .empty,
    SeasonRewardList: std.ArrayList(RogueSeasonReward) = .empty,
    TokenItemCount: i32 = 0,
    BlackFlowerUseCount: i32 = 0,
    BlackFlowerMaxCount: i32 = 0,
    TowerTrialBestClearCount: i32 = 0,
};
pub const ActivityRoleGiveData = struct {
    pub const default: @This() = .{};
    IsGetReward: bool = false,
};
pub const ActivityCorniceMeetingData = struct {
    pub const default: @This() = .{};
    UnlockTime: i64 = 0,
    LevelEntryData: std.ArrayList(MapEntry(i32, ActivityCorniceMeetingLevelEntryData)) = .empty,
};
pub const AdvertisingPageData = struct {
    pub const default: @This() = .{};
    Show: bool = false,
    PointTime: i64 = 0,
};
pub const ActivityData = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        ParkourActivity: ?ParkourActivity,
        SignActivity: ?SignActivity,
        NewBieCourseActivity: ?NewBieCourseActivity,
        DoubleInstActivityReward: ?DoubleInstActivityReward,
        HarvestActivity: ?HarvestActivity,
        RoleTrialInfoActivity: ?RoleTrialInfoActivity,
        PhantomCollectActivity: ?PhantomCollectActivity,
        GatherActivityInfo: ?GatherActivityInfo,
        DailyAdventureActivityData: ?DailyAdventureActivityData,
        ActivityRogueData: ?ActivityRogueData,
        ActivityLongShanMain: ?ActivityLongShanMain,
        ActivityTurnTableData: ?ActivityTurnTableData,
        BossRushActivityData: ?BossRushActivityData,
        TrackMoonActivityTaskData: ?ActivityTaskData,
        ActivityTimePointRewarData: ?ActivityTimePointRewarData,
        TowerDefenseActivityInfo: ?TowerDefenseActivityInfo,
        CircumFluenceTaskData: ?CircumFluenceTaskData,
        ActivityRoleGiveData: ?ActivityRoleGiveData,
        ActivityCorniceMeetingData: ?ActivityCorniceMeetingData,
        RiskHarvestActivityData: ?RiskHarvestActivityData,
        ActivityBlackCoastData: ?ActivityBlackCoastData,
        DreamLinkActivityData: ?DreamLinkActivityData,
        ActivityScratchTicketData: ?ActivityScratchTicketData,
        PreheatSignActivityData: ?PreheatSignActivityData,
        MowTowerActivityData: ?MowTowerActivityData,
        FarmGoldData: ?FarmGoldData,
        SpringSignData: ?SpringSignData,
        MapTravelActivityData: ?MapTravelActivityData,
        RoleSkinTrialActivity: ?RoleSkinTrialActivity,
        ActivityFishingData: ?ActivityFishingData,
        ActivityWeeklyRogueData: ?ActivityWeeklyRogueData,
        SolarisSpeedActivity: ?SolarisSpeedActivity,
        BabelTowerActivity: ?BabelTowerActivity,
        ActivityBetHorsesData: ?ActivityBetHorsesData,
        ActivityMapExploreData: ?ActivityMapExploreData,
        ActivityPermanentRogueData: ?ActivityPermanentRogueData,
        ActivityAvignon: ?ActivityAvignon,
        DangoAbyssActivityData: ?DangoAbyssActivityData,
        ActivityInviteNewbie: ?ActivityInviteNewbie,
        ActivityDangoMonopolyData: ?ActivityDangoMonopolyData,
        ActivityCiacconaGalData: ?ActivityCiacconaGalData,
        ActivityLinkageData: ?ActivityLinkageData,
        ActivityRegressData: ?ActivityRegressData,
        CumulativeShopData: ?CumulativeShopData,
        PhantomArenaActivityData: ?PhantomArenaActivityData,
        BeginnerCarnivalData: ?BeginnerCarnivalData,
        ActivityMoraleData: ?ActivityMoraleData,
        FloroRanchActivityData: ?FloroRanchActivityData,
        LifePointDrawActivityData: ?LifePointDrawActivityData,
        ActivityTrapDefenseData: ?ActivityTrapDefenseData,
        ActivityFunPlayData: ?ActivityFunPlayData,
        ActivitySoarData: ?ActivitySoarData,
        ActivityLineCrossData: ?ActivityLineCrossData,
        ActivityMoonSignInData: ?ActivityMoonSignInData,
        HonamiStoryActivityData: ?HonamiStoryActivityData,
        FightPhotoActivityData: ?FightPhotoActivityData,
        SurvivorsActivityData: ?SurvivorsActivityData,
        ActivityPrizeDrawingData: ?ActivityPrizeDrawingData,
        AdvertisingPageData: ?AdvertisingPageData,
        AdvertisingPageInfo: ?AdvertisingPageInfo,
        RoleCoopActivityData: ?RoleCoopActivityData,
        MotorCycleIpActivityData: ?MotorCycleIpActivityData,
        PhantomBattleRecordActivityInfo: ?PhantomArenaActivityData,
        InfrThemeActivityPb: ?InfrThemeActivityPb,
        RoadBookActivityInfo: ?RoadBookActivityInfo,
        PhantomBattleGuideActivity: ?PhantomBattleGuideActivity,
        NewTowerClimbingActivityData: ?NewTowerClimbingActivityData,
        NewPlayerSupportActivityData: ?NewPlayerSupportActivityData,
        MotorParkourActivityInfo: ?MotorParkourActivityInfo,
        SpringFestivalActivityInfo: ?SpringFestivalActivityInfo,
        TotalTopUpActivityInfo: ?TotalTopUpActivityInfo,
        MotorFightActivityPb: ?MotorFightActivityPb,
        H5ViewActivityData: ?H5ViewActivityData,
        SkinRewardActivityData: ?SkinRewardActivityData,
        EncircleActivityPb: ?EncircleActivityPb,
        MotorDevelopActivityData: ?MotorDevelopActivityData,
        FlagChallengeActivityInfo: ?FlagChallengeActivityInfo,
        FeiXuePreheatActivityInfo: ?FeiXuePreheatActivityInfo,
        RhythmActivityPb: ?RhythmActivityPb,
        DropCatchActivityInfo: ?DropCatchActivityInfo,
        TetrisActivityInfo: ?TetrisActivityInfo,
        PinballActivityData: ?PinballActivityData,
        BossPilingActivityInfo: ?BossPilingActivityInfo,
        ThemeCelebration: ?ThemeCelebration,
        WuWuWeekActivity: ?WuWuWeekActivity,
        MotorDecalActivityData: ?MotorDecalActivityData,
        LinkageCheckInActivityData: ?LinkageCheckInActivityData,
        RoleGiftActivityData: ?RoleGiftActivityData,
        KurotatoActivityData: ?KurotatoActivityData,
        GolemCrackActivityInfo: ?GolemCrackActivityInfo,
        EdgeRunnerActivityInfo: ?EdgeRunnerActivityInfo,
        OnlineMotorActivityData: ?OnlineMotorActivityData,
        RealmBetweenActivityInfo: ?RealmBetweenActivityInfo,
        ThroughTrainSummaryActivityData: ?ThroughTrainSummaryActivityData,
        NewbieMainActivityPb: ?NewbieMainActivityPb,
        NewbieCourseV2ActivityPb: ?NewbieCourseV2ActivityPb,
        NewbieAdventureV2Pb: ?NewbieAdventureV2Pb,
        NewPlayerSupportActivityV2Pb: ?NewPlayerSupportActivityV2Pb,
        ThroughTrainActivityData: ?ThroughTrainActivityData,
        RoverRogueActivityData: ?RoverRogueActivityData,
        QingXiaoActivityInfo: ?QingXiaoActivityInfo,
    } = null,
    Id: i32 = 0,
    Type: ?ActivityType = null,
    BeginShowTime: i64 = 0,
    EndShowTime: i64 = 0,
    BeginOpenTime: i64 = 0,
    EndOpenTime: i64 = 0,
    IsUnlock: bool = false,
    CompletePreQuests: std.ArrayList(i32) = .empty,
    IsFirstOpen: bool = false,
    FinishConditions: std.ArrayList(i32) = .empty,
    ActivityOpenType: ?ActivityOpenType = null,
    IsPreOpen: bool = false,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
    BeginRewardTimeInternal: i64 = 0,
    EndRewardTimeInternal: i64 = 0,
};
pub const ActivityRequest = struct {
    pub const default: @This() = .{};
};
pub const ActivityResponse = struct {
    pub const default: @This() = .{};
    Activities: std.ArrayList(ActivityData) = .empty,
    ErrorCode: ?ErrorCode = null,
};
pub const ActivityTurnTableData = struct {
    pub const default: @This() = .{};
    IsAllFinish: bool = false,
    GroupId: i32 = 0,
    Rewards: std.ArrayList(i32) = .empty,
    TurntableTasks: std.ArrayList(ActivityTask) = .empty,
};
pub const ActivityCorniceMeetingLevelEntryData = struct {
    pub const default: @This() = .{};
    MaxScore: i32 = 0,
    RemainTime: i32 = 0,
    UnlockTime: i64 = 0,
    RewardedMap: std.ArrayList(i32) = .empty,
};
pub const BlackCoastThemeStageInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Tasks: std.ArrayList(ActivityTask) = .empty,
};
pub const ActivityBlackCoastData = struct {
    pub const default: @This() = .{};
    StageData: std.ArrayList(BlackCoastThemeStageInfo) = .empty,
    RewardIds: std.ArrayList(i32) = .empty,
};
pub const DreamLinkActivityData = struct {
    pub const default: @This() = .{};
    MaxEnergy: i32 = 0,
    SignStateList: std.ArrayList(i32) = .empty,
    RoleInstanceList: std.ArrayList(RoleInstanceList) = .empty,
    LevelPlayList: std.ArrayList(LevelPlayList) = .empty,
    BossRewardIds: std.ArrayList(i32) = .empty,
    AllLimitTimeReward: std.ArrayList(AllLimitTimeReward) = .empty,
    ScoreMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
    LimitTimeReward: i64 = 0,
    LimitTimeEnd: i64 = 0,
    RogueBossInstData: std.ArrayList(RogueBossInstData) = .empty,
    PlayTime: i32 = 0,
    UnlockButtons: std.ArrayList(i32) = .empty,
};
pub const AllLimitTimeReward = struct {
    pub const default: @This() = .{};
    SignState: ?SignState = null,
    CurProgress: i32 = 0,
    Target: i32 = 0,
    ConfigId: i32 = 0,
};
pub const RoleInstanceList = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    IsUnlock: bool = false,
    CanUnlock: bool = false,
};
pub const RogueBossInstData = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    IsUnlock: bool = false,
    CanUnlock: bool = false,
    UnlockTime: i64 = 0,
};
pub const LevelPlayList = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
    LevelPlayId: i32 = 0,
    State: i32 = 0,
    IsUnlock: bool = false,
    UnlockTime: i64 = 0,
    PlayTime: i32 = 0,
};
pub const ScratchTicketRoundData = struct {
    pub const default: @This() = .{};
    RoundId: i32 = 0,
    UnlockTime: i64 = 0,
    AreaStageRewardDataList: std.ArrayList(MapEntry(i32, ScratchCardRewardData)) = .empty,
    LeftRewardItem: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const ScratchCardRewardData = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Count: i32 = 0,
};
pub const ScratchTicketConditionData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Progress: i32 = 0,
    FinishedAchievementNum: i32 = 0,
};
pub const ActivityScratchTicketData = struct {
    pub const default: @This() = .{};
    RoundData: std.ArrayList(ScratchTicketRoundData) = .empty,
    ConditionData: std.ArrayList(ScratchTicketConditionData) = .empty,
};
pub const PreheatSignNodeInfo = struct {
    pub const default: @This() = .{};
    PreheatNodeId: i32 = 0,
    UnlockTime: i64 = 0,
    Rewarded: bool = false,
};
pub const PreheatSignActivityData = struct {
    pub const default: @This() = .{};
    PreheatSignNodeInfos: std.ArrayList(PreheatSignNodeInfo) = .empty,
};
pub const SpringSignData = struct {
    pub const default: @This() = .{};
    SpringSignActivityTasks: std.ArrayList(ActivityTask) = .empty,
    CanInvite: bool = false,
    DrawRoles: std.ArrayList(i32) = .empty,
    SkinReward: bool = false,
};
pub const MowTowerRewardStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    CanNoReward = 0,
    CanReward = 1,
    Rewarded = 2,
};
pub const MowTowerLevelsInfo = struct {
    pub const default: @This() = .{};
    BabelTowerLevelId: i32 = 0,
    UnlockTime: i64 = 0,
    IsUnlock: bool = false,
    FirstScore: i32 = 0,
    SecondScore: i32 = 0,
    LevelRewardStatus: std.ArrayList(MapEntry(i32, MowTowerRewardStatus)) = .empty,
    HardLevelBuffs: std.ArrayList(i32) = .empty,
    FirstRoleSelection: std.ArrayList(i32) = .empty,
    SecondRoleSelection: std.ArrayList(i32) = .empty,
};
pub const MowTowerActivityData = struct {
    pub const default: @This() = .{};
    MowTowerLevelsInfo: std.ArrayList(MowTowerLevelsInfo) = .empty,
};
pub const ThroughTrainActivityData = struct {
    pub const default: @This() = .{};
    IsFinish: bool = false,
};
pub const ThroughTrainSummaryActivityData = struct {
    pub const default: @This() = .{};
    ActivityIds: std.ArrayList(i32) = .empty,
    CompletedActivityIds: std.ArrayList(i32) = .empty,
};
pub const RoleSkinTrialContentData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    ChallengeState: i32 = 0,
};
pub const RoleSkinTrialActivity = struct {
    pub const default: @This() = .{};
    RoleSkinTrialContentData: std.ArrayList(RoleSkinTrialContentData) = .empty,
};
pub const ActivityWeeklyRogueData = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        RogueWeeklyLastInfo: ?RogueWeeklyLastInfo,
    } = null,
    CycleId: i32 = 0,
    Score: i32 = 0,
    RogueWeeklyAward: std.ArrayList(RogueWeeklyAward) = .empty,
    MaxScore: i32 = 0,
    CurWorldLevel: i32 = 0,
    UseFreeCount: i32 = 0,
    MaxFreeCount: i32 = 0,
};
pub const RogueWeeklyAward = struct {
    pub const default: @This() = .{};
    SignState: ?SignState = null,
    CurProgress: i32 = 0,
    MaxProgress: i32 = 0,
    ConfigId: i32 = 0,
};
pub const RogueWeeklyLastInfo = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    CurLayer: i32 = 0,
    MaxLayer: i32 = 0,
    WorldLevel: i32 = 0,
};
pub const ActivityPermanentRogueData = struct {
    pub const default: @This() = .{};
    PermanentSeasonData: std.ArrayList(PermanentSeasonData) = .empty,
    RogueResTaskData: ?RogueResTaskData = null,
};
pub const PermanentSeasonData = struct {
    pub const default: @This() = .{};
    PermanentSeasonDataId: i32 = 0,
    SkillDict: std.ArrayList(MapEntry(i32, i32)) = .empty,
    RogueResEndId: std.ArrayList(i32) = .empty,
    RogueResEndAward: std.ArrayList(ActivityTask) = .empty,
    TrialRoleIds: std.ArrayList(i32) = .empty,
    RoleIds: std.ArrayList(i32) = .empty,
    EndTime: i64 = 0,
    ShopItemCount: i32 = 0,
};
pub const RogueResTaskData = struct {
    pub const default: @This() = .{};
    PermanentRogueData: ?PermanentRogueData = null,
    RogueResCollectionState: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const PermanentRogueData = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        RogueResTaskThemeData: ?RogueResTaskThemeData,
    } = null,
};
pub const RogueResTaskThemeData = struct {
    pub const default: @This() = .{};
    RogueSignReward: std.ArrayList(ActivityTask) = .empty,
    RogueResThemeId: i32 = 0,
    EndTime: i64 = 0,
};
pub const ActivityFishingData = struct {
    pub const default: @This() = .{};
    ActivityTaskData: std.ArrayList(ActivityTask) = .empty,
    MilestoneReward: std.ArrayList(MapEntry(i32, i32)) = .empty,
    LimitTimeReward: i64 = 0,
    LimitTimeEnd: i64 = 0,
    MilestoneRewardItemAccumulate: i32 = 0,
};
pub const BabelTowerData = struct {
    pub const default: @This() = .{};
    BabelTowerLevelId: i32 = 0,
    UnlockTime: i64 = 0,
    NormalLevelBuffs: std.ArrayList(i32) = .empty,
    RoleIds: std.ArrayList(i32) = .empty,
    HardLevelBuffs: std.ArrayList(i32) = .empty,
    HardLevelItems: std.ArrayList(i32) = .empty,
    HardLevelStar: i32 = 0,
    HasPassed: bool = false,
    MaxPassRoleSelection: std.ArrayList(i32) = .empty,
    MaxPassBuffSelection: std.ArrayList(i32) = .empty,
    MaxPassStar: i32 = 0,
    SkillBranchId: std.ArrayList(i32) = .empty,
    MaxPassUseTime: i32 = 0,
};
pub const BabelDebuff = struct {
    pub const default: @This() = .{};
    BuffId: i32 = 0,
    Unlocked: bool = false,
};
pub const BabelBuff = struct {
    pub const default: @This() = .{};
    BuffId: i32 = 0,
    Unlocked: bool = false,
};
pub const BabelTowerActivity = struct {
    pub const default: @This() = .{};
    BabelTowerDataList: std.ArrayList(BabelTowerData) = .empty,
    BabelDebuffUnlocks: std.ArrayList(BabelDebuff) = .empty,
    BabelBuffUnlocks: std.ArrayList(BabelBuff) = .empty,
    NormalQuest: std.ArrayList(ActivityTask) = .empty,
    DailyQuest: std.ArrayList(ActivityTask) = .empty,
    CurrentItemCount: i32 = 0,
    ShowName: bool = false,
};
pub const ActivityMapExploreData = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(MapEntry(i32, ActivityTaskState)) = .empty,
};
pub const ActivityInviteNewbie = struct {
    pub const default: @This() = .{};
    InviteCode: []const u8 = "",
    Score: i32 = 0,
    RedDot: bool = false,
};
pub const ActivityDangoMonopolyData = struct {
    pub const default: @This() = .{};
    CurrentBoardId: i32 = 0,
    CurrentGridId: i32 = 0,
    RewardGridId: i32 = 0,
    BoardRewards: std.ArrayList(i32) = .empty,
    DangoTaskConfig: std.ArrayList(DangoMonopolyConfig) = .empty,
    TaskEndTimeMap: std.ArrayList(MapEntry(i32, i64)) = .empty,
    UnlockTime: i64 = 0,
    BoardMap: std.ArrayList(MapEntry(i32, DangoMonopolyBoardData)) = .empty,
};
pub const DangoMonopolyBoardData = struct {
    pub const default: @This() = .{};
    PropertyIds: std.ArrayList(i32) = .empty,
    RecordDiceRollTimes: i32 = 0,
    RecordTriggerMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const DangoMonopolyTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NotCompleted = 0,
    Completed = 1,
    HasGet = 2,
};
pub const DangoMonopolyConfig = struct {
    pub const default: @This() = .{};
    TaskId: i32 = 0,
    ActivityTaskState: ?DangoMonopolyTaskState = null,
    Progress: i32 = 0,
    TargetProgress: i32 = 0,
};
pub const ActivityCiacconaGalData = struct {
    pub const default: @This() = .{};
    ChapterData: std.ArrayList(CiacconaGalChapterData) = .empty,
    ProgressRewardData: std.ArrayList(CiacconaGalRewardData) = .empty,
    EndingData: std.ArrayList(CiacconaGalEndingData) = .empty,
    CiacconaGalInspirationData: ?CiacconaGalInspirationData = null,
    State2Unlock: bool = false,
    State3Unlock: bool = false,
    RewardStartTime: i64 = 0,
    RewardEndTime: i64 = 0,
};
pub const CiacconaGalChapterData = struct {
    pub const default: @This() = .{};
    ChapterDataId: i32 = 0,
    CanUnlock: bool = false,
    CiacconaGalSubEndingData: std.ArrayList(CiacconaGalSubEndingData) = .empty,
    CiacconaGalChoiceData: std.ArrayList(CiacconaGalChoiceData) = .empty,
};
pub const CiacconaGalChoiceData = struct {
    pub const default: @This() = .{};
    ChoiceDataId: i32 = 0,
    SecondState: bool = false,
    FirstState: bool = false,
};
pub const CiacconaGalSubEndingData = struct {
    pub const default: @This() = .{};
    SubEndingDataId: i32 = 0,
    IsFinished: bool = false,
    IsRewarded: bool = false,
};
pub const CiacconaGalRewardData = struct {
    pub const default: @This() = .{};
    RewardDataId: i32 = 0,
    CanReceive: bool = false,
    IsRewarded: bool = false,
};
pub const CiacconaGalInspirationData = struct {
    pub const default: @This() = .{};
    InspirationCount: i32 = 0,
    RefreshTime: i64 = 0,
};
pub const CiacconaGalEndingData = struct {
    pub const default: @This() = .{};
    SubEndingDataId: i32 = 0,
    IsRewarded: bool = false,
};
pub const PhantomArenaActivityData = struct {
    pub const default: @This() = .{};
    PhantomArenaChallengeInfoList: std.ArrayList(PhantomArenaChallengeInfo) = .empty,
    ActivityTasks: std.ArrayList(ActivityTask) = .empty,
    PhantomArenaMasterInfo: ?PhantomArenaMasterInfo = null,
    BadgeInfo: std.ArrayList(PhantomArenaBadge) = .empty,
    BadgeReward: std.ArrayList(PhantomArenaBadgeReward) = .empty,
    CardList: std.ArrayList(PhantomArenaCardInfo) = .empty,
    CardReward: std.ArrayList(PhantomArenaCardReward) = .empty,
    RoleInfo: std.ArrayList(PhantomArenaRoleInfo) = .empty,
    DeckInfo: std.ArrayList(PhantomArenaDeckInfo) = .empty,
    TimeLimitShopEndTime: i64 = 0,
};
pub const PhantomArenaChallengeInfo = struct {
    pub const default: @This() = .{};
    ChallengeInfoId: i32 = 0,
    IsUnlock: bool = false,
    CanReChallenge: bool = false,
    LastCardRoleId: i32 = 0,
    LastCardGroupIndex: i32 = 0,
    FinishConditions: std.ArrayList(i32) = .empty,
    IsUncover: bool = false,
    IsShow: bool = false,
};
pub const PhantomArenaMasterInfo = struct {
    pub const default: @This() = .{};
    MasterLevel: i32 = 0,
    MasterExp: i32 = 0,
    RewardTaken: std.ArrayList(i32) = .empty,
    MasterWeeklyExp: i32 = 0,
    LastUsedDeckServerId: i32 = 0,
    LastUsedCardRoleId: i32 = 0,
};
pub const PhantomArenaBadge = struct {
    pub const default: @This() = .{};
    BadgeId: i32 = 0,
    IsUnlock: bool = false,
};
pub const PhantomArenaBadgeReward = struct {
    pub const default: @This() = .{};
    BadgeRewardId: i32 = 0,
    NeedCount: i32 = 0,
    IsTaken: bool = false,
};
pub const PhantomArenaCardInfo = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
    IsUnlock: bool = false,
    IsCardOutlookUnlock: bool = false,
};
pub const PhantomArenaCardReward = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
    NeedCount: i32 = 0,
    IsTaken: bool = false,
};
pub const PhantomArenaRoleInfo = struct {
    pub const default: @This() = .{};
    RoleInfoId: i32 = 0,
    IsUnlock: bool = false,
    IsTaken: bool = false,
};
pub const PhantomArenaDeckInfo = struct {
    pub const default: @This() = .{};
    Name: []const u8 = "",
    BattleCardIds: std.ArrayList(i32) = .empty,
    CanUse: bool = false,
    LastUseChallengeId: std.ArrayList(i32) = .empty,
    Index: i32 = 0,
    SkillUnlockInfos: std.ArrayList(PhantomBattleCardSkillUnlockInfo) = .empty,
};
pub const PhantomBattleGuideActivity = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
    DropId: i32 = 0,
    RewardTotalNum: i32 = 0,
    SendReward: bool = false,
    RecordActId: i32 = 0,
};
pub const BeginnerCarnivalData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    ActivityTaskData: ?ActivityTaskData = null,
    JumpTaskIds: std.ArrayList(i32) = .empty,
    JumpTaskCondInfos: std.ArrayList(JumpTaskCondInfo) = .empty,
};
pub const JumpTaskCondInfo = struct {
    pub const default: @This() = .{};
    JumpId: i32 = 0,
    ConditionGroupIds: std.ArrayList(i32) = .empty,
};
pub const FunPlayChallengeRewardStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    FunPlayCanNoReward = 0,
    FunPlayCanReward = 1,
    FunPlayRewarded = 2,
};
pub const ActivityFunPlayChallengeData = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    UnlockTime: i64 = 0,
    RewardStatus: ?FunPlayChallengeRewardStatus = null,
    FunPlaySharpComment: std.ArrayList(i32) = .empty,
    FinishTime: i64 = 0,
};
pub const ActivityFunPlayData = struct {
    pub const default: @This() = .{};
    ActivityFunPlayChallengeData: std.ArrayList(ActivityFunPlayChallengeData) = .empty,
};
pub const ActivitySoarData = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const InitHonamiActivityRequest = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
};
pub const InitHonamiActivityResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    HonamiStoryActivityData: ?HonamiStoryActivityData = null,
};
pub const HonamiStoryActivityData = struct {
    pub const default: @This() = .{};
    PlayerBagInfo: ?HonamiStoryPlayerBagInfo = null,
    ActivatedTalentId: std.ArrayList(i32) = .empty,
    ItemCollectionList: std.ArrayList(HonamiStoryItemCollectionConfig) = .empty,
    MascotConfigList: std.ArrayList(HonamiStoryMascotConfig) = .empty,
    AreaConfigList: std.ArrayList(HonamiStoryAreaConfig) = .empty,
    PermanentTaskData: std.ArrayList(ConditionTask) = .empty,
    LimitTaskData: std.ArrayList(ConditionTask) = .empty,
    ScoreRewardInfo: std.ArrayList(HonamiStoryScoreRewardInfo) = .empty,
    LifeSupportLevel: i32 = 0,
    LimitShopConsumeItemNum: i32 = 0,
    PbTowerInfos: std.ArrayList(TowerInfoData) = .empty,
    TalentInfos: std.ArrayList(TalentInfoData) = .empty,
    ItemCollectionInfos: std.ArrayList(ConditionTask) = .empty,
    TotalRevenue: i32 = 0,
};
pub const InfrThemeActivityPb = struct {
    pub const default: @This() = .{};
    ActivityTaskData: ?ActivityTaskData = null,
};
pub const FlagChallengeActivityInfo = struct {
    pub const default: @This() = .{};
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
    FlagChallengeLevelInfos: std.ArrayList(FlagChallengeLevelInfo) = .empty,
    FlagStrongholdInfos: std.ArrayList(FlagStrongholdInfo) = .empty,
    FlagChallengeRoleLevelInfo: ?FlagChallengeRoleLevelInfo = null,
    UnlockTeleporterId: std.ArrayList(i32) = .empty,
};
pub const BossPilingActivityInfo = struct {
    pub const default: @This() = .{};
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
    BossPilingLevelInfos: std.ArrayList(BossPilingLevelInfo) = .empty,
};
pub const ChallengeState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Running = 0,
    WaitTakeReward = 1,
    Finish = 2,
};
pub const DailyAdventureTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    DailyAdventureTaskRunning = 0,
    DailyAdventureTaskFinish = 1,
    DailyAdventureTaskTaken = 2,
};
pub const DailyAdventureActivityTask = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Current: i32 = 0,
    Target: i32 = 0,
    Status: ?DailyAdventureTaskState = null,
};
pub const DailyAdventureActivityData = struct {
    pub const default: @This() = .{};
    DailyAdventureActivityTasks: std.ArrayList(DailyAdventureActivityTask) = .empty,
    PtRewardTaken: std.ArrayList(i32) = .empty,
};
pub const LongShanMainData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Tasks: std.ArrayList(LongShanMainTaskData) = .empty,
    CanUnlock: bool = false,
    BeginOpenTime: i64 = 0,
    EndOpenTime: i64 = 0,
};
pub const LongShanMainTaskData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Current: i32 = 0,
    Target: i32 = 0,
    IsFinished: bool = false,
    IsTaken: bool = false,
    Unlock: bool = false,
    FinishConditions: std.ArrayList(i32) = .empty,
    ConditionId: i32 = 0,
    ConditionGroupId: i32 = 0,
    UnlockConditionFinish: bool = false,
};
pub const ActivityLongShanMain = struct {
    pub const default: @This() = .{};
    StageData: std.ArrayList(LongShanMainData) = .empty,
    ScoreRewardedId: std.ArrayList(i32) = .empty,
};
pub const BossRushRewardClaimStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Incomplete = 0,
    Claimable = 1,
    Claimed = 2,
};
pub const BossRushBuffSelectionStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BuffEmpty = 0,
    BuffSelected = 1,
    BuffLocked = 2,
    BuffInactive = 3,
};
pub const BossRushActivityData = struct {
    pub const default: @This() = .{};
    LevelDetailInfo: std.ArrayList(LevelInfo) = .empty,
    RewardInfo: std.ArrayList(BossRushScoreRewardData) = .empty,
    UnlockedBuffIndices: std.ArrayList(i32) = .empty,
    TaskProgressReward: std.ArrayList(ActivityTask) = .empty,
};
pub const LevelInfo = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    StartTime: i32 = 0,
    IsOpen: bool = false,
    Score: i32 = 0,
    RoleInfo: std.ArrayList(i32) = .empty,
    BuffInfo: std.ArrayList(HardLevelBuffs) = .empty,
    LevelRewardClaimStatus: ?BossRushRewardClaimStatus = null,
    SelectScoreBuffs: std.ArrayList(i32) = .empty,
    LevelScoreRewardStatus: std.ArrayList(BossRushRewardClaimStatus) = .empty,
};
pub const BossRushScoreRewardData = struct {
    pub const default: @This() = .{};
    RewardDataId: i32 = 0,
    State: ?BossRushRewardClaimStatus = null,
};
pub const HardLevelBuffs = struct {
    pub const default: @This() = .{};
    BuffId: i32 = 0,
    Slot: i32 = 0,
    State: ?BossRushBuffSelectionStatus = null,
};
pub const ActivityTask = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Current: i32 = 0,
    Target: i32 = 0,
    Status: ?ActivityTaskState = null,
    PreItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const ActivityTaskData = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(ActivityTask) = .empty,
};
pub const ActivityTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ActivityTaskRunning = 0,
    ActivityTaskFinish = 1,
    ActivityTaskTaken = 2,
};
pub const ActivityOpenType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    TimeLimited = 0,
    Permanent = 1,
    LimitToPermanent = 2,
};
pub const ConditionTask = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Current: i32 = 0,
    Target: i32 = 0,
    Status: ?ConditionTaskState = null,
};
pub const ConditionTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ConditionTaskRunning = 0,
    ConditionTaskFinish = 1,
    ConditionTaskTaken = 2,
};
pub const ActivityTimePointRewarData = struct {
    pub const default: @This() = .{};
    Rewards: std.ArrayList(TimePointRewardData) = .empty,
};
pub const TimePointRewardData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    RewardTime: i64 = 0,
    Rewarded: bool = false,
    CanGetReward: bool = false,
};
pub const TowerDefenseActivityInfo = struct {
    pub const default: @This() = .{};
    InstanceInfos: std.ArrayList(TowerDefenceInstanceInfo) = .empty,
    RewardedScoreIds: std.ArrayList(i32) = .empty,
    TotalScore: i32 = 0,
    ShowName: bool = false,
};
pub const TowerDefenceInstanceInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Score: i32 = 0,
    Rewarded: bool = false,
    IsPassed: bool = false,
    UnlockTime: i64 = 0,
    MaxScore: i32 = 0,
    PassTime: i32 = 0,
};
pub const StarRewardState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    RiskHarvestCanNoReward = 0,
    RiskHarvestCanReward = 1,
    RiskHarvestRewarded = 2,
};
pub const RiskHarvestStarRewardInfo = struct {
    pub const default: @This() = .{};
    TargetScore: i32 = 0,
    State: ?StarRewardState = null,
};
pub const RiskHarvestInstInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    UnlockTime: i64 = 0,
    IsUnlock: bool = false,
    Score: i32 = 0,
    Rewarded: bool = false,
    IsFinished: bool = false,
    StarRewardInfos: std.ArrayList(RiskHarvestStarRewardInfo) = .empty,
};
pub const RiskHarvestActivityData = struct {
    pub const default: @This() = .{};
    InstInfos: std.ArrayList(RiskHarvestInstInfo) = .empty,
    RewardedScores: std.ArrayList(i32) = .empty,
    RewardedBuffGroups: std.ArrayList(i32) = .empty,
    UnlockBuffGroups: std.ArrayList(i32) = .empty,
    RewardedBuffTypeIds: std.ArrayList(i32) = .empty,
};
pub const FarmGoldLevelPlayInfo = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    StartTime: i32 = 0,
    Challenges: bool = false,
    Points: i32 = 0,
    LevelRewardGet: bool = false,
    Difficulty: i32 = 0,
};
pub const FarmGoldData = struct {
    pub const default: @This() = .{};
    PointRewardGet: std.ArrayList(i32) = .empty,
    LevelPlayTasks: std.ArrayList(FarmGoldLevelPlayInfo) = .empty,
};
pub const MapTravelActivityData = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(ActivityTask) = .empty,
    MonsterGain: std.ArrayList(i32) = .empty,
    GetFullReward: bool = false,
    MapTravelLevel: i32 = 0,
    UnlockAreas: std.ArrayList(i32) = .empty,
    SoarLevels: std.ArrayList(SoarLevelPlayInfo) = .empty,
};
pub const SoarLevelPlayInfo = struct {
    pub const default: @This() = .{};
    SoarLevelPlatId: i32 = 0,
    HistorySoarScore: i32 = 0,
    ReceiveIds: std.ArrayList(i32) = .empty,
};
pub const SolarSpeedContext = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    Score: i32 = 0,
    Ranking: i32 = 0,
    StartTime: i32 = 0,
    LapRecord: i32 = 0,
};
pub const SolarisSpeedActivity = struct {
    pub const default: @This() = .{};
    SolarSpeedContext: std.ArrayList(SolarSpeedContext) = .empty,
    ActivityTaskDatas: ?ActivityTaskData = null,
};
pub const RacingBetsLegMatchData = struct {
    pub const default: @This() = .{};
    LegMatchesId: i32 = 0,
    DangoId: i32 = 0,
    BettingGearId: i32 = 0,
    BettingGearCash: i32 = 0,
    Odds: i32 = 0,
    OddsVersion: []const u8 = "",
    LeaveCancelNum: i32 = 0,
    OddsReward: i32 = 0,
};
pub const DangoActorData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Record: i32 = 0,
    Odds: i32 = 0,
};
pub const RacingBetsOrganInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Point: i32 = 0,
};
pub const RacingBetsTimeTuple = struct {
    pub const default: @This() = .{};
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const RacingBetsLegMatch = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    DangoActorData: std.ArrayList(DangoActorData) = .empty,
    MatchStartEndTime: ?RacingBetsTimeTuple = null,
    GearStartEndTime: ?RacingBetsTimeTuple = null,
    BetDangoRank: std.ArrayList(i32) = .empty,
    OddsRateRefreshTime: i64 = 0,
    OddsVersion: []const u8 = "",
    MasterLevel: ?RacingBetsTimeTuple = null,
    OrganInfo: std.ArrayList(RacingBetsOrganInfo) = .empty,
};
pub const RacingBetsGroupMatchInfo = struct {
    pub const default: @This() = .{};
    MatchId: i32 = 0,
    GroupMatchTime: ?RacingBetsTimeTuple = null,
    LegMatch: std.ArrayList(RacingBetsLegMatch) = .empty,
    PromoteDangoList: std.ArrayList(i32) = .empty,
    Dangos: std.ArrayList(i32) = .empty,
};
pub const RacingBetsSeasonData = struct {
    pub const default: @This() = .{};
    CurCash: i32 = 0,
    TotalCash: i32 = 0,
    RacingBetsLegMatchData: std.ArrayList(RacingBetsLegMatchData) = .empty,
    HitNum: i32 = 0,
};
pub const ConditionTaskStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Undone = 0,
    TaskFinish = 1,
    Received = 2,
};
pub const RacingBetsRewardData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: ?ConditionTaskStatus = null,
    Progress: i32 = 0,
    TargetProgress: i32 = 0,
    ConditionFinishState: bool = false,
};
pub const ActivityBetHorsesData = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    StartAndEndTime: ?RacingBetsTimeTuple = null,
    MatchInfo: std.ArrayList(RacingBetsGroupMatchInfo) = .empty,
    RacingBetsSeasonData: ?RacingBetsSeasonData = null,
    BetsRewardData: std.ArrayList(RacingBetsRewardData) = .empty,
    LegMatchTimeList: std.ArrayList(i64) = .empty,
    CloseSettleMenuLegMatchList: std.ArrayList(i32) = .empty,
};
pub const ActivityAvignon = struct {
    pub const default: @This() = .{};
    RewardData: ?ActivityTaskData = null,
    StageId: std.ArrayList(i32) = .empty,
};
pub const ActivityLinkageRewardData = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Count: i32 = 0,
};
pub const ActivityLinkageTabData = struct {
    pub const default: @This() = .{};
    TabDataId: i32 = 0,
    EndTime: i64 = 0,
    RewardData: std.ArrayList(ActivityLinkageRewardData) = .empty,
    IsReceive: bool = false,
    StartTime: i64 = 0,
};
pub const ActivityLinkageData = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    Data: std.ArrayList(ActivityLinkageTabData) = .empty,
};
pub const QuestionaireRewardState = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: ?ActivityTaskState = null,
};
pub const ActivityRegressData = struct {
    pub const default: @This() = .{};
    TaskProgressReward: std.ArrayList(ActivityTask) = .empty,
    ClaimedReward: std.ArrayList(ActivityTask) = .empty,
    TaskScoreRewardId: std.ArrayList(i32) = .empty,
    Grade: i32 = 0,
    EndTime: i64 = 0,
    RefreshTime: i64 = 0,
    BossDoubleDropCount: i32 = 0,
    WeekDoubleDropCount: i32 = 0,
    Questionnaire: std.ArrayList(i32) = .empty,
    QuestionaireRewardState: std.ArrayList(QuestionaireRewardState) = .empty,
    BossDoubleDropUnlock: bool = false,
    WeekDoubleDropUnlock: bool = false,
    PayScoreRewards: std.ArrayList(i32) = .empty,
    DisposableReward: bool = false,
    RoleInfo: std.ArrayList(NewTrialRoleInfo) = .empty,
    PayRewardUnlock: bool = false,
    CurUseTrialRoleId: i32 = 0,
    CurUseRoleInfo: ?RoleInfo = null,
};
pub const NewPlayerSupportActivityData = struct {
    pub const default: @This() = .{};
    TrialRoleInfoList: std.ArrayList(NewTrialRoleInfo) = .empty,
    TaskDataList: std.ArrayList(ConditionTask) = .empty,
    CurUseTrialRoleId: i32 = 0,
    CurUseRoleInfo: ?RoleInfo = null,
    NewPlayerPoolFinalGachaRoleId: i32 = 0,
};
pub const NewTrialRoleInfo = struct {
    pub const default: @This() = .{};
    TrialRoleId: i32 = 0,
    WorldLv: i32 = 0,
};
pub const ConsumptiveTaskType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Unknown = 0,
    Single = 1,
    Cycle = 2,
};
pub const CumulativeShopTaskData = struct {
    pub const default: @This() = .{};
    Current: i32 = 0,
    TargetProgress: i32 = 0,
};
pub const CumulativeShopSubTaskData = struct {
    pub const default: @This() = .{};
    CanGetReward: i32 = 0,
    ProgressCount: i32 = 0,
    TotalProgressCount: i32 = 0,
};
pub const CumulativeShopTaskConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Type: ?ConsumptiveTaskType = null,
    CumulativeShopTaskData: ?CumulativeShopTaskData = null,
    CumulativeShopSubTaskData: ?CumulativeShopSubTaskData = null,
};
pub const CumulativeShopData = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    TaskData: std.ArrayList(CumulativeShopTaskConfig) = .empty,
    TotalScore: i32 = 0,
};
pub const MoraleFlag = struct {
    pub const default: @This() = .{};
    FlagId: i32 = 0,
    BoxReceivedCount: i32 = 0,
    BoxTotalCount: i32 = 0,
};
pub const MoraleAreaData = struct {
    pub const default: @This() = .{};
    AreaDataId: i32 = 0,
    ExploreBoxReceivedCount: i32 = 0,
};
pub const ActivityMoraleData = struct {
    pub const default: @This() = .{};
    AreaData: std.ArrayList(MoraleAreaData) = .empty,
    MoraleProgressReward: std.ArrayList(i32) = .empty,
    MoraleFlags: std.ArrayList(MoraleFlag) = .empty,
};
pub const FloroRanchActivityData = struct {
    pub const default: @This() = .{};
    FloroRangeData: ?FloroRangeData = null,
    UnFinishedSubIns: i32 = 0,
    SavedStage: i32 = 0,
    CurWeeklyInsId: i32 = 0,
};
pub const FloroRanchCommonData = struct {
    pub const default: @This() = .{};
    DataId: i32 = 0,
    ConditionId: i32 = 0,
    IsLocked: bool = false,
};
pub const FloroRanchSubDungeonData = struct {
    pub const default: @This() = .{};
    DataId: i32 = 0,
    ConditionId: i32 = 0,
    IsLocked: bool = false,
    IsFinished: bool = false,
};
pub const FloroRangeData = struct {
    pub const default: @This() = .{};
    FloroRanchCardData: std.ArrayList(FloroRanchCommonData) = .empty,
    FloroRanchUnlockedTechDataIds: std.ArrayList(i32) = .empty,
    FloroRanchToyData: std.ArrayList(FloroRanchCommonData) = .empty,
    FloroRanchSkillData: std.ArrayList(FloroRanchCommonData) = .empty,
    FloroRanchMilestoneData: std.ArrayList(i32) = .empty,
    FloroRanchRaceData: std.ArrayList(FloroRanchCommonData) = .empty,
    FloroRanchSubDungeonData: std.ArrayList(FloroRanchSubDungeonData) = .empty,
    ConditionTask: std.ArrayList(ConditionTask) = .empty,
    FloroRanchSubDungeonHistoryData: std.ArrayList(FloroRanchSubDungeonHistoryData) = .empty,
    FloroRanchSubDungeonIdsRedDot: std.ArrayList(i32) = .empty,
    IsReadComic: bool = false,
    FloroRangeUnlockTime: i64 = 0,
    FloroRangeEndTime: i64 = 0,
    InsUnLockCondition: std.ArrayList(FloroRanchCommonData) = .empty,
};
pub const FloroRanchSubDungeonHistoryData = struct {
    pub const default: @This() = .{};
    DataId: i32 = 0,
    MaxDays: i32 = 0,
    MaxCoins: i32 = 0,
};
pub const LifePointChallengeData = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    CanGetReward: bool = false,
    OpenTime: i64 = 0,
    RewardId: i32 = 0,
    EntityConfigId: i32 = 0,
    IsPreChallengeState: bool = false,
};
pub const LifePointDrawActivityData = struct {
    pub const default: @This() = .{};
    LifePointChallengeData: std.ArrayList(LifePointChallengeData) = .empty,
};
pub const ActivityTrapDefenseData = struct {
    pub const default: @This() = .{};
    TrapDefenseTalentNodeIds: std.ArrayList(i32) = .empty,
    SpecialReward: std.ArrayList(TrapDefenseRewardData) = .empty,
    Rewards: std.ArrayList(TrapDefenseRewardData) = .empty,
    Auxiliaries: std.ArrayList(TrapDefenseAuxiliaryData) = .empty,
    Buildings: std.ArrayList(TrapDefenseBuildingData) = .empty,
    Challenges: std.ArrayList(TrapDefenseLevelData) = .empty,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
    TrapDefenseBdDataIdUnlocks: std.ArrayList(i32) = .empty,
    TrapDefenseTalentTreeMaxPoints: i32 = 0,
    TrapDefenseTalentTreePoints: i32 = 0,
    TrapDefenseRemainPoints: i32 = 0,
    TrapDefenseTotalPoints: i32 = 0,
    TrapDefenseBdBuffIdUnlocks: std.ArrayList(i32) = .empty,
};
pub const TrapDefenseRewardData = struct {
    pub const default: @This() = .{};
    ActivityServerRewardItemData: ?ConditionTask = null,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const TrapDefenseLevelData = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    CanUnlock: bool = false,
    TargetProgress: std.ArrayList(i32) = .empty,
    IsPassed: bool = false,
    CanGetReward: bool = false,
    UnlockTime: i64 = 0,
    IsLeaved: bool = false,
    MaxFinishWaveTimes: i32 = 0,
};
pub const TrapDefenseBuildingData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Level: i32 = 0,
    Branch: i32 = 0,
    MaxLevel: i32 = 0,
    CellPrice: i32 = 0,
    OriginalConstructPrice: i32 = 0,
    DiscountConstructPrice: i32 = 0,
    DeconstructReturn: i32 = 0,
};
pub const TrapDefenseAuxiliaryData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Level: i32 = 0,
    Branch: i32 = 0,
    MaxLevel: i32 = 0,
};
pub const LineCrossChallengeData = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    CanGetReward: bool = false,
    OpenTime: i64 = 0,
    RewardDataId: i32 = 0,
    EntityConfigId: i32 = 0,
    IsPreChallengeState: bool = false,
};
pub const ActivityLineCrossData = struct {
    pub const default: @This() = .{};
    Challenges: std.ArrayList(LineCrossChallengeData) = .empty,
};
pub const MoonSignInConfigData = struct {
    pub const default: @This() = .{};
    MoonId: i32 = 0,
    MoonLabelTopId: i32 = 0,
    MoonLabelBottomId: i32 = 0,
};
pub const ActivityMoonSignInData = struct {
    pub const default: @This() = .{};
    MoonPhaseSelectList: std.ArrayList(MoonSignInConfigData) = .empty,
    IsGrandReward: bool = false,
    CurrentMoonId: i32 = 0,
};
pub const FightPhotoActivityData = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    LevelGroups: std.ArrayList(LevelGroupData) = .empty,
    Tasks: std.ArrayList(TaskData) = .empty,
};
pub const LevelGroupData = struct {
    pub const default: @This() = .{};
    GroupId: i32 = 0,
    OpenTime: i64 = 0,
    EndTime: i64 = 0,
    levels: std.ArrayList(LevelData) = .empty,
};
pub const LevelData = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    InstId: i32 = 0,
    Roles: std.ArrayList(i32) = .empty,
    GroupId: i32 = 0,
    IsUnlocked: bool = false,
};
pub const FightPhotoLevelDataUpdateNotify = struct {
    pub const default: @This() = .{};
    levels: std.ArrayList(LevelData) = .empty,
};
pub const TaskData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: i32 = 0,
    Progress: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const SurvivorsLevelData = struct {
    pub const default: @This() = .{};
    ModeInfo: ?union(enum) {
        EndlessInfo: ?SurvivorsLevelInfo,
    } = null,
    LevelId: i32 = 0,
    OpenTime: i64 = 0,
    NormalInfo: ?SurvivorsLevelInfo = null,
};
pub const SurvivorsLevelInfo = struct {
    pub const default: @This() = .{};
    IsUnlocked: bool = false,
    ConditionGroupId: i32 = 0,
    WaveId: i32 = 0,
    KillMonsterCount: i32 = 0,
    IsFinished: bool = false,
};
pub const SurvivorsActivityData = struct {
    pub const default: @This() = .{};
    NormalTaskData: ?ActivityTaskData = null,
    ScoreTaskDatas: std.ArrayList(i32) = .empty,
    UnlockedWeapons: std.ArrayList(i32) = .empty,
    UnlockedRoles: std.ArrayList(i32) = .empty,
    UnlockedItems: std.ArrayList(i32) = .empty,
    TalentTreeNodes: std.ArrayList(MapEntry(i32, i32)) = .empty,
    SurvivorsChallengeInfos: std.ArrayList(SurvivorsLevelData) = .empty,
};
pub const ActivityPrizeDrawingData = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    KujiId: i32 = 0,
    AwardGroups: std.ArrayList(AwardGroupData) = .empty,
    CostItemId: i32 = 0,
    CostItemCount: i32 = 0,
    QuestFinishedCount: i32 = 0,
    QuestTotalCount: i32 = 0,
    QuestId: i32 = 0,
};
pub const AwardGroupData = struct {
    pub const default: @This() = .{};
    GroupId: i32 = 0,
    GroupRank: i32 = 0,
    CurrentAmount: i32 = 0,
    AllAmount: i32 = 0,
    RewardItems: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const HonamiStoryItemInfo = struct {
    pub const default: @This() = .{};
    ItemInfo: ?union(enum) {
        HonamiStoryNormalItemInfo: ?HonamiStoryNormalItemInfo,
        EquipItemInfo: ?HonamiStoryEquipItemInfo,
    } = null,
    IncrId: i32 = 0,
    ItemId: i32 = 0,
    FuncValue: i32 = 0,
};
pub const HonamiStoryNormalItemInfo = struct {
    pub const default: @This() = .{};
};
pub const HonamiStoryEquipItemInfo = struct {
    pub const default: @This() = .{};
    MainPropLibraryId: i32 = 0,
    OriBuffTempId: std.ArrayList(i32) = .empty,
    ChildBuffTempId: std.ArrayList(i32) = .empty,
};
pub const HonamiStoryPosInfo = struct {
    pub const default: @This() = .{};
    IsCross: bool = false,
    Posotion: i32 = 0,
};
pub const TowerInfoData = struct {
    pub const default: @This() = .{};
    DangerLevel: i32 = 0,
    MaxFloor: i32 = 0,
};
pub const HonamiStoryBackpackEntry = struct {
    pub const default: @This() = .{};
    Item: ?HonamiStoryItemInfo = null,
    State: ?HonamiStoryPosInfo = null,
};
pub const HonamiStoryBackpack = struct {
    pub const default: @This() = .{};
    BackpackId: i32 = 0,
    Width: i32 = 0,
    Capacity: i32 = 0,
    Items: std.ArrayList(HonamiStoryBackpackEntry) = .empty,
};
pub const HonamiStoryPlayerBagInfo = struct {
    pub const default: @This() = .{};
    Warehouse: ?HonamiStoryBackpack = null,
    EquipRack: ?HonamiStoryBackpack = null,
    RoleEquipList: std.ArrayList(HonamiStoryRoleData) = .empty,
    UnlockedWeaponIds: std.ArrayList(i32) = .empty,
};
pub const HonamiStoryRoleData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    RoleSlots: std.ArrayList(HonamiStoryRoleSlot) = .empty,
    DressWeapon: i32 = 0,
};
pub const HonamiStoryRoleSlot = struct {
    pub const default: @This() = .{};
    SlotId: i32 = 0,
    IsUnlocked: bool = false,
};
pub const HonamiStoryItemCollectionConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: i32 = 0,
};
pub const HonamiStoryMascotConfig = struct {
    pub const default: @This() = .{};
    MascotId: i32 = 0,
    State: i32 = 0,
};
pub const HonamiStoryAreaConfig = struct {
    pub const default: @This() = .{};
    AreaId: i32 = 0,
    Status: i32 = 0,
    SecreteStatus: i32 = 0,
};
pub const HonamiStoryScoreRewardInfo = struct {
    pub const default: @This() = .{};
    ScoreRewardId: i32 = 0,
    Status: i32 = 0,
};
pub const TalentInfoData = struct {
    pub const default: @This() = .{};
    TalentId: i32 = 0,
    State: i32 = 0,
};
pub const RoleCoopActivityData = struct {
    pub const default: @This() = .{};
    CoopRoleInfos: std.ArrayList(CoopRoleInfo) = .empty,
    RewardGetList: std.ArrayList(i32) = .empty,
    CoopTaskCompleteInfos: std.ArrayList(CoopTaskCompleteInfo) = .empty,
    PreCompleteIds: std.ArrayList(i32) = .empty,
};
pub const CoopTaskCompleteInfo = struct {
    pub const default: @This() = .{};
    CoopTaskId: i32 = 0,
    Task: ?ConditionTask = null,
    UnLockTime: i64 = 0,
    LevelPlay1Done: bool = false,
    LevelPlay2Done: bool = false,
};
pub const CoopRoleInfo = struct {
    pub const default: @This() = .{};
    CoopRoleId: i32 = 0,
    RoleLevel: i32 = 0,
    RewardLevel: i32 = 0,
    FinishTime: i64 = 0,
};
pub const AdvertisingPageInfo = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    UnlockIndex: i32 = 0,
    RewardedIndex: i32 = 0,
};
pub const MotorCycleIpActivityData = struct {
    pub const default: @This() = .{};
    TaskDataList: std.ArrayList(ConditionTask) = .empty,
};
pub const PhantomBattleCardSkillUnlockInfo = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
    Unlock: bool = false,
    TargetNum: i32 = 0,
    CurNum: i32 = 0,
};
pub const MotorParkourActivityInfo = struct {
    pub const default: @This() = .{};
    MotorParkourLevelInfos: std.ArrayList(MotorParkourLevelInfo) = .empty,
};
pub const MotorParkourRewardState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    MotorParkourRewardLocked = 0,
    MotorParkourRewardAvailable = 1,
    MotorParkourRewardRewarded = 2,
};
pub const MotorParkourLevelInfo = struct {
    pub const default: @This() = .{};
    MotorParkourId: i32 = 0,
    RewardStates: std.ArrayList(MotorParkourRewardState) = .empty,
    UnlockTime: i64 = 0,
    BestPassTime: i32 = 0,
};
pub const RoadBookActivityInfo = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(ConditionTask) = .empty,
    MonsterGain: std.ArrayList(i32) = .empty,
    GetFullReward: bool = false,
    RoadBookLevel: i32 = 0,
    UnLockAreas: std.ArrayList(i32) = .empty,
    SoarLevels: std.ArrayList(RoadBookMotorcycleInfo) = .empty,
};
pub const RoadBookMotorcycleInfo = struct {
    pub const default: @This() = .{};
    MotorcyclePlayId: i32 = 0,
    HistorySoarScore: i32 = 0,
    ReceiveIds: std.ArrayList(i32) = .empty,
};
pub const MotorFightActivityPb = struct {
    pub const default: @This() = .{};
    MotorFightLevelPb: std.ArrayList(MotorFightLevelPb) = .empty,
    Task: std.ArrayList(ConditionTask) = .empty,
    TalentTree: ?MotorFightTalentTreePb = null,
    UnlockedItem: std.ArrayList(i32) = .empty,
    UnlockedRole: std.ArrayList(i32) = .empty,
};
pub const MotorFightTalentTreePb = struct {
    pub const default: @This() = .{};
    Talent: std.ArrayList(MotorFightTalentPb) = .empty,
};
pub const MotorFightLevelPb = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    OpenTime: i64 = 0,
    Cleared: bool = false,
    BestScore: i32 = 0,
    LastRoleId: i32 = 0,
};
pub const MotorFightTalentPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Unlock: bool = false,
    InUse: bool = false,
};
pub const EncircleChallengePb = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    OpenTime: i64 = 0,
    Pass: bool = false,
    MinStep: i32 = 0,
};
pub const EncircleActivityPb = struct {
    pub const default: @This() = .{};
    Challenges: std.ArrayList(EncircleChallengePb) = .empty,
};
pub const NewTowerClimbingActivityData = struct {
    pub const default: @This() = .{};
    CycleId: i32 = 0,
    Records: std.ArrayList(NewTowerClimbingLevelRecord) = .empty,
    ScoreTasks: std.ArrayList(i32) = .empty,
    ActivityTasks: std.ArrayList(ActivityTask) = .empty,
    CycleBeginTime: i64 = 0,
    CycleCloseTime: i64 = 0,
    SeasonId: i32 = 0,
    SeasonBeginTime: i64 = 0,
    SeasonCloseTime: i64 = 0,
    SeasonTasks: std.ArrayList(ActivityTask) = .empty,
};
pub const NewTowerClimbingLevelRecord = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    WaveConfigIds: std.ArrayList(i32) = .empty,
    NextMonsterInfoPreview: ?MonsterInfoPreview = null,
    TeamChallengeInfos: std.ArrayList(TeamChallengeInfo) = .empty,
    Score: i32 = 0,
    IsUnlock: bool = false,
    RoleEnergyDict: std.ArrayList(MapEntry(i32, i32)) = .empty,
    HistoryScore: i32 = 0,
};
pub const MonsterInfoPreview = struct {
    pub const default: @This() = .{};
    WaveConfigId: i32 = 0,
    HpPpb: i32 = 0,
    Damage: i64 = 0,
    Round: i32 = 0,
    IsDead: bool = false,
};
pub const RoleSaveInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    WeaponIncId: i32 = 0,
    PhantomIncId: std.ArrayList(i32) = .empty,
    SkillBranchId: i32 = 0,
};
pub const TeamChallengeInfo = struct {
    pub const default: @This() = .{};
    RoleSaveInfos: std.ArrayList(RoleSaveInfo) = .empty,
    BuffIds: std.ArrayList(i32) = .empty,
    LastMonsterInfoPreview: ?MonsterInfoPreview = null,
    TeamScore: i32 = 0,
};
pub const NewPlayerSupportActivityV2Pb = struct {
    pub const default: @This() = .{};
    TrialRoleInfoList: std.ArrayList(NewTrialRoleInfo) = .empty,
    CurUseTrialRoleId: i32 = 0,
    CurUseRoleInfo: ?RoleInfo = null,
    DeduplicateGachaRoleIds: std.ArrayList(i32) = .empty,
    NbWeekCardEndShowTime: i64 = 0,
    NbGiftPackEndShowTime: i64 = 0,
    NbGachaEndShowTime: i64 = 0,
    NbLivenessEndShowTime: i64 = 0,
    NewPlayerPoolFinalGachaRoleId: i32 = 0,
};
pub const SpringFestivalActivityInfo = struct {
    pub const default: @This() = .{};
    AreaInfos: std.ArrayList(AreaInfo) = .empty,
    UnlockFurnitures: std.ArrayList(i32) = .empty,
    DrinkMixData: ?DrinkMixData = null,
    OneBrochureInfos: std.ArrayList(OneBrochureInfo) = .empty,
    JokerLevelInfos: std.ArrayList(GuessJokerLevelInfo) = .empty,
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
    SpringFunctionIds: std.ArrayList(i32) = .empty,
    RewardScoreIds: std.ArrayList(i32) = .empty,
    RewardLevelIds: std.ArrayList(i32) = .empty,
    Atmosphere: i32 = 0,
    AtmosphereLevel: i32 = 0,
    SpringSkipEntries: std.ArrayList(SpringSkipEntry) = .empty,
};
pub const SpringSkipEntry = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    UnLock: bool = false,
    Finish: bool = false,
};
pub const DrinkMixData = struct {
    pub const default: @This() = .{};
    RoleLevelInfo: std.ArrayList(DrinkMixRole) = .empty,
};
pub const DrinkMixRole = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    FirstPass: bool = false,
    MaxLike: bool = false,
    RewardGet: bool = false,
};
pub const GuessJokerLevelInfo = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    LevelPass: bool = false,
    UnLock: bool = false,
    RewardGet: bool = false,
    PlayerWin: bool = false,
};
pub const AreaInfo = struct {
    pub const default: @This() = .{};
    AreaId: i32 = 0,
    Atmosphere: i32 = 0,
    FurnitureDiySlotInfos: std.ArrayList(FurnitureDiySlotInfo) = .empty,
};
pub const FurnitureDiySlotInfo = struct {
    pub const default: @This() = .{};
    SlotEntityCfgId: i32 = 0,
    RootFurnitureId: i32 = 0,
    SubFurnitureIds: std.ArrayList(i32) = .empty,
};
pub const BookItemState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BookItemLock = 0,
    BookItemUnlock = 1,
    BookItemRewarded = 2,
};
pub const OneBrochureInfo = struct {
    pub const default: @This() = .{};
    BrochureId: i32 = 0,
    BookItemInfos: std.ArrayList(BookItemInfo) = .empty,
};
pub const BookItemInfo = struct {
    pub const default: @This() = .{};
    BookItemId: i32 = 0,
    BookItemState: ?BookItemState = null,
};
pub const TotalTopUpRewardInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Score: i32 = 0,
    RewardContent: std.ArrayList(MapEntry(i32, i32)) = .empty,
    Status: i32 = 0,
};
pub const TotalTopUpActivityInfo = struct {
    pub const default: @This() = .{};
    Score: i32 = 0,
    TotalTopUpRewardInfos: std.ArrayList(TotalTopUpRewardInfo) = .empty,
};
pub const H5ViewActivityData = struct {
    pub const default: @This() = .{};
    RedDot: bool = false,
    AllRewardClaimed: bool = false,
};
pub const SkinRewardActivityData = struct {
    pub const default: @This() = .{};
    RewardInfos: std.ArrayList(SkinRewardActivityRewardInfo) = .empty,
};
pub const SkinRewardActivityRewardState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    InitState = 0,
    TaskComplete = 1,
    TaskRewarded = 2,
};
pub const SkinRewardActivityRewardInfo = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    State: ?SkinRewardActivityRewardState = null,
};
pub const MotorDevelopActivityData = struct {
    pub const default: @This() = .{};
    Task: std.ArrayList(ConditionTask) = .empty,
};
pub const FlagChallengeLevelInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    UnlockTime: i64 = 0,
    State: i32 = 0,
};
pub const FlagStrongholdInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IsPass: bool = false,
};
pub const FlagChallengeRoleLevelInfo = struct {
    pub const default: @This() = .{};
    PerLevel: i32 = 0,
    PerExp: i32 = 0,
};
pub const FeiXuePreheatInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    State: i32 = 0,
    QuestUnlockTime: i64 = 0,
};
pub const FeiXuePreheatActivityInfo = struct {
    pub const default: @This() = .{};
    FeiXuePreheatInfos: std.ArrayList(FeiXuePreheatInfo) = .empty,
};
pub const RhythmShipRank = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Undefined = 0,
    SSS = 1,
    SS = 2,
    S = 3,
    A = 4,
    B = 5,
};
pub const RhythmTaskTypePb = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Resident = 0,
    Limit = 1,
};
pub const RhythmActivityPb = struct {
    pub const default: @This() = .{};
    RhythmShipPlanetPb: std.ArrayList(RhythmShipPlanetPb) = .empty,
    RhythmRoleId: i32 = 0,
    RhythmTask: std.ArrayList(RhythmTaskPb) = .empty,
    UnlockedRole: std.ArrayList(i32) = .empty,
    RedDot: ?RhythmRedDotPb = null,
};
pub const RhythmShipPlanetPb = struct {
    pub const default: @This() = .{};
    PlanetId: i32 = 0,
    OpenTime: i64 = 0,
    RhythmShipLevelPb: std.ArrayList(RhythmShipLevelPb) = .empty,
};
pub const RhythmShipLevelPb = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    RhythmSubLevelPb: std.ArrayList(RhythmSubLevelPb) = .empty,
};
pub const RhythmSubLevelPb = struct {
    pub const default: @This() = .{};
    SubLevelId: i32 = 0,
    Cleared: bool = false,
    BestScore: i32 = 0,
    BestAccuracy: i32 = 0,
    BestRank: ?RhythmShipRank = null,
};
pub const RhythmTaskPb = struct {
    pub const default: @This() = .{};
    TaskType: ?RhythmTaskTypePb = null,
    Task: std.ArrayList(ConditionTask) = .empty,
};
pub const RhythmRedDotPb = struct {
    pub const default: @This() = .{};
    ReadPlanet: std.ArrayList(i32) = .empty,
    ReadSubLevel: std.ArrayList(i32) = .empty,
    ReadRole: std.ArrayList(i32) = .empty,
};
pub const DropCatchActivityInfo = struct {
    pub const default: @This() = .{};
    DropCatchLevelInfos: std.ArrayList(DropCatchLevelInfo) = .empty,
};
pub const DropCatchLevelInfo = struct {
    pub const default: @This() = .{};
    DropCatchId: i32 = 0,
    RewardStates: std.ArrayList(i32) = .empty,
    UnlockTime: i64 = 0,
    Score: i32 = 0,
};
pub const TetrisActivityInfo = struct {
    pub const default: @This() = .{};
    TetrisLevelInfos: std.ArrayList(TetrisLevelInfo) = .empty,
};
pub const TetrisLevelInfo = struct {
    pub const default: @This() = .{};
    vdC: ?union(enum) {
        DifficultyIdx: i32,
    } = null,
    ehC: ?union(enum) {
        State: ?TetrisState,
    } = null,
    thC: ?union(enum) {
        UnlockTime: i64,
    } = null,
    Id: i32 = 0,
    Results: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const TetrisState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    TetrisLocked = 0,
    TetrisUnlocked = 1,
    TetrisFinished = 2,
};
pub const PinballActivityData = struct {
    pub const default: @This() = .{};
    Chapters: std.ArrayList(PinballChapterData) = .empty,
    Levels: std.ArrayList(PinballLevelData) = .empty,
    Weapons: ?PinballWeapons = null,
    Roles: ?PinballRoles = null,
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
    GroupFormations: std.ArrayList(PinballGroupFormation) = .empty,
};
pub const PinballGroupFormation = struct {
    pub const default: @This() = .{};
    LevelGroup: i32 = 0,
    RoleIds: std.ArrayList(i32) = .empty,
};
pub const PinballChapterData = struct {
    pub const default: @This() = .{};
    ChapterId: i32 = 0,
    UnLockTime: i64 = 0,
};
pub const PinballLevelData = struct {
    pub const default: @This() = .{};
    data: ?union(enum) {
        NormalLevel: ?NormalLevel,
        CowLevel: ?CowLevel,
        TowerLevel: ?TowerLevel,
        DailyLevel: ?DailyLevel,
    } = null,
    ConfigId: i32 = 0,
};
pub const NormalLevel = struct {
    pub const default: @This() = .{};
    StarByte: i32 = 0,
};
pub const CowLevel = struct {
    pub const default: @This() = .{};
    LevelScore: i32 = 0,
};
pub const TowerLevel = struct {
    pub const default: @This() = .{};
    StarByte: i32 = 0,
    CostTime: i32 = 0,
};
pub const DailyLevel = struct {
    pub const default: @This() = .{};
    RandomLevelId: i32 = 0,
    reward: bool = false,
};
pub const PinballWeapon = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    IncrId: i32 = 0,
    FuncValue: i32 = 0,
    roleId: i32 = 0,
    SubEntryId: i32 = 0,
};
pub const PinballWeapons = struct {
    pub const default: @This() = .{};
    PinballWeaponList: std.ArrayList(PinballWeapon) = .empty,
};
pub const PinballRoles = struct {
    pub const default: @This() = .{};
    Roles: std.ArrayList(PinballRoleData) = .empty,
};
pub const PinballRoleData = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    RoleLevel: i32 = 0,
};
pub const BossPilingLevelInfo = struct {
    pub const default: @This() = .{};
    id: i32 = 0,
    UnlockTime: i64 = 0,
    BossHpNum: i32 = 0,
    SelectRoleIds: std.ArrayList(i32) = .empty,
    SkillBranchId: std.ArrayList(i32) = .empty,
};
pub const ThemeCelebration = struct {
    pub const default: @This() = .{};
    PersonalRewardIds: std.ArrayList(i32) = .empty,
    WorldRewardIds: std.ArrayList(i32) = .empty,
    SubActivityTimes: std.ArrayList(SubActivityBeginTime) = .empty,
};
pub const WuWuWeekActivity = struct {
    pub const default: @This() = .{};
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
    TaskPack: std.ArrayList(WuWuTaskPack) = .empty,
};
pub const WuWuTaskPack = struct {
    pub const default: @This() = .{};
    WuWuPackageId: i32 = 0,
    UnLockTime: i64 = 0,
    HadReward: bool = false,
};
pub const SubActivityBeginTime = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    BeginTime: i64 = 0,
};
pub const MotorDecalActivityData = struct {
    pub const default: @This() = .{};
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
};
pub const LinkageCheckInActivityData = struct {
    pub const default: @This() = .{};
    CheckInDay: i32 = 0,
    NormalReward: std.ArrayList(i32) = .empty,
    KeepReward: std.ArrayList(i32) = .empty,
};
pub const GolemCrackActivityInfo = struct {
    pub const default: @This() = .{};
    GolemCrackLevelInfos: std.ArrayList(GolemCrackLevelInfo) = .empty,
};
pub const GolemCrackLevelInfo = struct {
    pub const default: @This() = .{};
    NlC: ?union(enum) {
        state: i32,
    } = null,
    VlC: ?union(enum) {
        UnlockTime: i64,
    } = null,
    id: i32 = 0,
};
pub const EdgeRunnerActivityInfo = struct {
    pub const default: @This() = .{};
    EdgeRunnerFunctionIds: std.ArrayList(i32) = .empty,
    RewardScoreId: i32 = 0,
    EdgeRunnerLordGymPassRecords: std.ArrayList(EdgeRunnerLordGymPassRecord) = .empty,
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
    PreUnlockIds: std.ArrayList(i32) = .empty,
};
pub const EdgeRunnerLordGymPassRecord = struct {
    pub const default: @This() = .{};
    LoadGymId: i32 = 0,
    PassTime: i32 = 0,
};
pub const LordGymInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const LordGymInfoResponse = struct {
    pub const default: @This() = .{};
    UnlockLoadGymIds: std.ArrayList(i32) = .empty,
    ReadLoadGymIds: std.ArrayList(i32) = .empty,
    LordGymPassRecords: std.ArrayList(LordGymPassRecord) = .empty,
    LordGymEntranceInfos: std.ArrayList(LordGymEntranceInfo) = .empty,
    LordGymGroupInfos: std.ArrayList(LordGymGroupInfo) = .empty,
};
pub const LordGymEntranceInfo = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    EffectBeginTime: i64 = 0,
    EffectEndTime: i64 = 0,
};
pub const LordGymGroupInfo = struct {
    pub const default: @This() = .{};
    GroupId: i32 = 0,
    PassDiff: i32 = 0,
};
pub const RoleBrief = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Level: i32 = 0,
};
pub const LordGymPassRecord = struct {
    pub const default: @This() = .{};
    LoadGymId: i32 = 0,
    PassTime: i32 = 0,
    RoleIds: std.ArrayList(RoleBrief) = .empty,
};
pub const RoleGiftActivityData = struct {
    pub const default: @This() = .{};
    RewardHadGet: bool = false,
};
pub const KurotatoItemPanelPbData = struct {
    pub const default: @This() = .{};
    ItemPbDatas: std.ArrayList(KurotatoItemPbData) = .empty,
};
pub const KurotatoItemPbData = struct {
    pub const default: @This() = .{};
    itemId: i32 = 0,
    count: i32 = 0,
    PreWaveDealtDamage: i32 = 0,
};
pub const KurotatoWeaponPanelPbData = struct {
    pub const default: @This() = .{};
    WeaponPbDatas: std.ArrayList(KurotatoWeaponPbData) = .empty,
};
pub const KurotatoWeaponPbData = struct {
    pub const default: @This() = .{};
    WeaponId: i32 = 0,
    IncId: i32 = 0,
    PreWaveDealtDamage: i32 = 0,
    SellPrice: i32 = 0,
};
pub const KurotatoActivityData = struct {
    pub const default: @This() = .{};
    KurotatoLevelInfos: std.ArrayList(KurotatoLevelInfo) = .empty,
    KurotatoRoleInfos: std.ArrayList(KurotatoRoleInfo) = .empty,
    UnlockWeapons: std.ArrayList(i32) = .empty,
    UnlockItems: std.ArrayList(i32) = .empty,
    ScoreTasks: std.ArrayList(i32) = .empty,
    ResTasks: std.ArrayList(ConditionTask) = .empty,
    LimitTasks: std.ArrayList(ConditionTask) = .empty,
};
pub const KurotatoLevelInfo = struct {
    pub const default: @This() = .{};
    jSp: ?union(enum) {
        EndlessLevelInfo: ?KurotatoEndlessLevelInfo,
    } = null,
    DOLLARSp: ?union(enum) {
        InstData: ?KurotatoInstInfo,
    } = null,
    LevelId: i32 = 0,
    IsUnlock: bool = false,
    UnlockTime: i64 = 0,
    IsFinished: bool = false,
};
pub const KurotatoEndlessLevelInfo = struct {
    pub const default: @This() = .{};
    FinishWave: i32 = 0,
    TotalKillCount: i32 = 0,
    PassRoleIds: std.ArrayList(i32) = .empty,
};
pub const KurotatoRoleInfo = struct {
    pub const default: @This() = .{};
    DOLLARSp: ?union(enum) {
        InstData: ?KurotatoInstInfo,
    } = null,
    roleId: i32 = 0,
    IsUnlock: bool = false,
    MaxFinishWave: i32 = 0,
    KillCount: i32 = 0,
};
pub const KurotatoInstInfo = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    CurWave: i32 = 0,
    roleId: i32 = 0,
    RoleLevel: i32 = 0,
    RoleExp: i32 = 0,
    ItemPanelPbData: ?KurotatoItemPanelPbData = null,
    WeaponPanelPbData: ?KurotatoWeaponPanelPbData = null,
    PropertyMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
    SaveTimestamp: i64 = 0,
    WaveType: i32 = 0,
};
pub const OnlineMotorLevelInfo = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    Ranking: i32 = 0,
    TimeCost: i32 = 0,
};
pub const OnlineMotorLevelUnLockTime = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    UnLockTime: i64 = 0,
};
pub const OnlineMotorActivityData = struct {
    pub const default: @This() = .{};
    OnlineMotorLevelInfos: std.ArrayList(OnlineMotorLevelInfo) = .empty,
    LevelTasks: std.ArrayList(OnlineMotorTask) = .empty,
    GlobalTasks: std.ArrayList(OnlineMotorTask) = .empty,
    UnLocks: std.ArrayList(OnlineMotorLevelUnLockTime) = .empty,
};
pub const OnlineMotorTask = struct {
    pub const default: @This() = .{};
    taskId: i32 = 0,
    state: i32 = 0,
    PlayCount: i32 = 0,
    Champion: i32 = 0,
    SpeedLap: i32 = 0,
    FirstRunner: i32 = 0,
};
pub const RealmBetweenActivityInfo = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(ConditionTask) = .empty,
    MonsterGain: std.ArrayList(i32) = .empty,
    GetFullReward: bool = false,
    RealmBetweenLevel: i32 = 0,
    UnLockAreas: std.ArrayList(i32) = .empty,
    SoarLevels: std.ArrayList(RealmBetweenMotorcycleInfo) = .empty,
};
pub const RealmBetweenMotorcycleInfo = struct {
    pub const default: @This() = .{};
    MotorcyclePlayId: i32 = 0,
    HistorySoarScore: i32 = 0,
    ReceiveIds: std.ArrayList(i32) = .empty,
};
pub const NewbieMainActivityPb = struct {
    pub const default: @This() = .{};
    NewbieMainTabs: std.ArrayList(NewbieMainTabPb) = .empty,
    TakenScoreRewardIds: std.ArrayList(i32) = .empty,
    ProgressScore: i32 = 0,
};
pub const NewbieMainTabPb = struct {
    pub const default: @This() = .{};
    TabId: i32 = 0,
    CompletedTaskIds: std.ArrayList(i32) = .empty,
};
pub const NewbieCourseV2ActivityPb = struct {
    pub const default: @This() = .{};
    HadTakeReward: std.ArrayList(i32) = .empty,
    BeginOpenTime: i64 = 0,
};
pub const NewbieAdventureV2Pb = struct {
    pub const default: @This() = .{};
    Chapter: std.ArrayList(NewbieAdventureV2ChapterPb) = .empty,
};
pub const NewbieAdventureV2ChapterPb = struct {
    pub const default: @This() = .{};
    id: i32 = 0,
    Task: std.ArrayList(ConditionTask) = .empty,
    RewardRoleId: bool = false,
    RewardedRoleId: i32 = 0,
    RewardDrop: bool = false,
};
pub const RoverRogueInsEntry = struct {
    pub const default: @This() = .{};
    instId: i32 = 0,
    DifficultyName: []const u8 = "",
    Level: i32 = 0,
    ExpectedTimeMinSec: i32 = 0,
    ExpectedTimeMaxSec: i32 = 0,
    Unlocked: bool = false,
    BestGrade: i32 = 0,
};
pub const RoverRogueActivityData = struct {
    pub const default: @This() = .{};
    activityId: i32 = 0,
    HistoryInsInfo: ?RoverRogueHistoryInsInfo = null,
    UnlockRoleIdList: std.ArrayList(i32) = .empty,
    UnlockBlessRoleIdList: std.ArrayList(i32) = .empty,
    UnlockBlessIdList: std.ArrayList(i32) = .empty,
    UnlockTalentIdList: std.ArrayList(i32) = .empty,
    UnlockItemIdList: std.ArrayList(i32) = .empty,
    UnlockLootIdList: std.ArrayList(i32) = .empty,
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
    ActiveTalentIdList: std.ArrayList(i32) = .empty,
    TokenItem: i32 = 0,
    TalentItem: i32 = 0,
    UnlockRoleType: std.ArrayList(i32) = .empty,
    EquippedLoot: i32 = 0,
    InsInfoList: std.ArrayList(RoverRogueInsEntry) = .empty,
};
pub const RoverRogueHistoryInsInfo = struct {
    pub const default: @This() = .{};
    CurInsId: i32 = 0,
    CurLayer: i32 = 0,
    TotalLayer: i32 = 0,
    LootId: i32 = 0,
};
pub const QingXiaoActivityInfo = struct {
    pub const default: @This() = .{};
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
};
pub const AdventreTask = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    State: ?AdventreTaskState = null,
    AdventreProgress: i32 = 0,
};
pub const AdventreTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    UnFinish = 0,
    Finish = 1,
    Received = 2,
};
pub const AdventureManualData = struct {
    pub const default: @This() = .{};
    AdventreTask: std.ArrayList(AdventreTask) = .empty,
    NowChapter: i32 = 0,
    ReceivedChapter: i32 = 0,
    UnlockChapters: std.ArrayList(i32) = .empty,
    RewardChapters: std.ArrayList(i32) = .empty,
};
pub const AdventureItemData = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    ItemNum: i32 = 0,
};
pub const AdventureRewardData = struct {
    pub const default: @This() = .{};
    DropId: i32 = 0,
    Items: std.ArrayList(AdventureItemData) = .empty,
};
pub const DetectionTarget = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Type: i32 = 0,
    UnlockState: bool = false,
    RefresherTime: i64 = 0,
    DetectionId: i32 = 0,
    IsTrace: i32 = 0,
};
pub const DetectionUnlock = struct {
    pub const default: @This() = .{};
    MonsterDetectionIds: std.ArrayList(i32) = .empty,
    DungeonDetectionIds: std.ArrayList(i32) = .empty,
    SilentAreaDetectionIds: std.ArrayList(i32) = .empty,
};
pub const SelectDetectionTarget = struct {
    pub const default: @This() = .{};
    DetectionId: i32 = 0,
    Type: i32 = 0,
    Id: i32 = 0,
    IsTrace: i32 = 0,
};
pub const AdventureManualDataRequest = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
};
pub const AdventureManualDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    AdventureManualData: ?AdventureManualData = null,
};
pub const AdventureUpdateNotify = struct {
    pub const default: @This() = .{};
    AdventureManualData: std.ArrayList(AdventureManualData) = .empty,
};
pub const AdventureManualRequest = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
};
pub const SlientFirstAwardState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NotUnlock = 0,
    NotFinish = 1,
    IsFinish = 2,
    IsReceive = 3,
};
pub const AdventureManualResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    AdventureManualData: ?AdventureManualData = null,
    DetectionTarget: std.ArrayList(DetectionTarget) = .empty,
    AdventureRewardData: std.ArrayList(AdventureRewardData) = .empty,
    DetectionUnlocks: ?DetectionUnlock = null,
    NowSelectDetectionTarget: ?SelectDetectionTarget = null,
    SlientFirstAwardMap: std.ArrayList(MapEntry(i32, SlientFirstAwardState)) = .empty,
    SilenceAreaConfigs: std.ArrayList(AdventureDetectionConfig) = .empty,
    DungeonDetections: std.ArrayList(AdventureDetectionConfig) = .empty,
    PreOpeDungeonDetections: std.ArrayList(PreOpenDetections) = .empty,
    PreOpenSilenceAreaDetections: std.ArrayList(PreOpenDetections) = .empty,
};
pub const PreOpenDetections = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    PreOpenId: i32 = 0,
    PreOpenBeginTime: i64 = 0,
    PreOpenEndTIme: i64 = 0,
};
pub const AdventureDetectionConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    EffectBeginTime: i64 = 0,
    EffectEndTime: i64 = 0,
};
pub const UnlockDetectionLabelInfo = struct {
    pub const default: @This() = .{};
    UnlockedGuideIds: std.ArrayList(i32) = .empty,
    UnlockedDetectionTextIds: std.ArrayList(i32) = .empty,
};
pub const GetDetectionLabelInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const GetDetectionLabelInfoResponse = struct {
    pub const default: @This() = .{};
    UnlockLabelInfo: ?UnlockDetectionLabelInfo = null,
};
pub const AdviceSettingNotify = struct {
    pub const default: @This() = .{};
    IsShow: bool = false,
};
pub const AdviceSetRequest = struct {
    pub const default: @This() = .{};
    IsShow: bool = false,
};
pub const AdviceSetResponse = struct {
    pub const default: @This() = .{};
    IsShow: bool = false,
    ErrorCode: ?ErrorCode = null,
};
pub const PbAdvice = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    AreaId: i32 = 0,
    Contents: std.ArrayList(PbAdviceContent) = .empty,
    UpVote: i32 = 0,
};
pub const AdviceComponentPb = struct {
    pub const default: @This() = .{};
    Advice: ?PbAdvice = null,
    PlayerId: i32 = 0,
    PlayerName: []const u8 = "",
};
pub const PbAdviceContentType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Sentence = 0,
    Conjunction = 1,
    Expression = 2,
    Motion = 3,
};
pub const PbAdviceContent = struct {
    pub const default: @This() = .{};
    Type: ?PbAdviceContentType = null,
    Id: i32 = 0,
    Word: i32 = 0,
};
pub const AdviceRequest = struct {
    pub const default: @This() = .{};
};
pub const AdviceResponse = struct {
    pub const default: @This() = .{};
    Advices: std.ArrayList(PbAdvice) = .empty,
    UpVoteIds: std.ArrayList(i64) = .empty,
    ErrorCode: ?ErrorCode = null,
};
pub const AiHateEntity = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    HatredValue: i32 = 0,
};
pub const Int2Long = struct {
    pub const default: @This() = .{};
    First: i32 = 0,
    Second: i64 = 0,
};
pub const Int2Bool = struct {
    pub const default: @This() = .{};
    First: i32 = 0,
    Second: bool = false,
};
pub const AiInformation = struct {
    pub const default: @This() = .{};
    AiBlackboards: std.ArrayList(BlackboardParam) = .empty,
    HateList: std.ArrayList(AiHateEntity) = .empty,
    AiBlackboardCd: std.ArrayList(Int2Long) = .empty,
};
pub const AiInformationRequest = struct {
    pub const default: @This() = .{};
    AiInfo: ?AiInformation = null,
};
pub const AiInformationPush = struct {
    pub const default: @This() = .{};
    AiInfo: ?AiInformation = null,
};
pub const AiInformationResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AiInformationNotify = struct {
    pub const default: @This() = .{};
    AiBlackboardCd: std.ArrayList(Int2Long) = .empty,
};
pub const AiBlackboardsRequest = struct {
    pub const default: @This() = .{};
    AiBlackboards: std.ArrayList(BlackboardParam) = .empty,
};
pub const AiBlackboardsPush = struct {
    pub const default: @This() = .{};
    AiBlackboards: std.ArrayList(BlackboardParam) = .empty,
};
pub const AiBlackboardsResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AiBlackboardCdRequest = struct {
    pub const default: @This() = .{};
    AiBlackboardCdModify: std.ArrayList(Int2Long) = .empty,
    AiBlackboardCdComplete: std.ArrayList(Int2Bool) = .empty,
};
pub const AiBlackboardCdPush = struct {
    pub const default: @This() = .{};
    AiBlackboardCdModify: std.ArrayList(Int2Long) = .empty,
    AiBlackboardCdComplete: std.ArrayList(Int2Bool) = .empty,
};
pub const AiBlackboardCdResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AiBlackboardCdNotify = struct {
    pub const default: @This() = .{};
    AiBlackboardCdDel: std.ArrayList(i32) = .empty,
    AiBlackboardCdModify: std.ArrayList(Int2Long) = .empty,
    AiBlackboardCdComplete: std.ArrayList(Int2Bool) = .empty,
};
pub const AiHateRequest = struct {
    pub const default: @This() = .{};
    HateList: std.ArrayList(AiHateEntity) = .empty,
};
pub const AiHatePush = struct {
    pub const default: @This() = .{};
    HateList: std.ArrayList(AiHateEntity) = .empty,
};
pub const AiHateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AiHateNotify = struct {
    pub const default: @This() = .{};
    HateList: std.ArrayList(AiHateEntity) = .empty,
};
pub const BlackboardParamType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    None = 0,
    Int = 1,
    IntArray = 2,
    Long = 3,
    LongArray = 4,
    Boolean = 5,
    String = 6,
    StringArray = 7,
    Float = 8,
    FloatArray = 9,
    Vector = 10,
    VectorArray = 11,
    Rotator = 12,
    RotatorArray = 13,
    Entity = 14,
    EntityArray = 15,
};
pub const IntArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(i32) = .empty,
};
pub const LongArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(i64) = .empty,
};
pub const StringArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList([]const u8) = .empty,
};
pub const FloatArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(f32) = .empty,
};
pub const VectorArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(Vector) = .empty,
};
pub const RotatorArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(Rotator) = .empty,
};
pub const BlackboardParam = struct {
    pub const default: @This() = .{};
    Value: ?union(enum) {
        IntValue: i32,
        IntValues: ?IntArrayBlackboard,
        LongValue: i64,
        LongValues: ?LongArrayBlackboard,
        BooleanValue: bool,
        StringValue: []const u8,
        StringValues: ?StringArrayBlackboard,
        FloatValue: f32,
        FloatValues: ?FloatArrayBlackboard,
        VectorValue: ?Vector,
        VectorValues: ?VectorArrayBlackboard,
        RotatorValue: ?Rotator,
        RotatorValues: ?RotatorArrayBlackboard,
    } = null,
    Key: []const u8 = "",
    Type: ?BlackboardParamType = null,
};
pub const EnterAreaRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    LeaveId: i32 = 0,
};
pub const EnterAreaResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Id: i32 = 0,
};
pub const AudioState = struct {
    pub const default: @This() = .{};
    TreeOwnerId: i32 = 0,
    TreeIncId: i64 = 0,
    GroupType: []const u8 = "",
    State: []const u8 = "",
};
pub const BanLogoutInfo = struct {
    pub const default: @This() = .{};
    Reason: i32 = 0,
    BanEndTime: i64 = 0,
};
pub const CardShowEntry = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
    IsRead: bool = false,
};
pub const BasicInfoNotify = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Attributes: std.ArrayList(PlayerAttr) = .empty,
    MingSuGenInfos: std.ArrayList(MingSuGenInfo) = .empty,
    DragonPoolInfos: std.ArrayList(DragonPoolInfo) = .empty,
    RoleShowList: std.ArrayList(RoleShowEntry) = .empty,
    CurCardId: i32 = 0,
    Birthday: i32 = 0,
    CardUnlockList: std.ArrayList(CardShowEntry) = .empty,
    RandomSeed: i32 = 0,
    DisplayBirthDay: bool = false,
    LastModifyNameTime: i64 = 0,
    ModifyNameTime: []const u8 = "",
    BusinessCompliance: bool = false,
    NewbieGuideV2: bool = false,
};
pub const ModifyNameRequest = struct {
    pub const default: @This() = .{};
    Name: []const u8 = "",
};
pub const ModifyNameResponse = struct {
    pub const default: @This() = .{};
    Name: []const u8 = "",
    ErrorCode: ?ErrorCode = null,
    LastModifyNameTime: i64 = 0,
    ModifyNameTime: []const u8 = "",
};
pub const ModifySignatureRequest = struct {
    pub const default: @This() = .{};
    Signature: []const u8 = "",
};
pub const ModifySignatureResponse = struct {
    pub const default: @This() = .{};
    Signature: []const u8 = "",
    ErrorCode: ?ErrorCode = null,
};
pub const ChangeHeadPhotoRequest = struct {
    pub const default: @This() = .{};
    HeadPhotoId: i32 = 0,
};
pub const ChangeHeadPhotoResponse = struct {
    pub const default: @This() = .{};
    HeadPhotoId: i32 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const NetStatusType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Wifi = 0,
    Stream = 1,
    Wired = 2,
    Other = 3,
};
pub const ClientDeviceLevel = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Low = 0,
    Medium = 1,
    High = 2,
};
pub const ClientBasicInfo = struct {
    pub const default: @This() = .{};
    Platform: []const u8 = "",
    DeviceId: []const u8 = "",
    NetStatus: ?NetStatusType = null,
    Model: []const u8 = "",
    CPU: []const u8 = "",
    DeviceLevel: ?ClientDeviceLevel = null,
    Language: i32 = 0,
    DistinctId: []const u8 = "",
    MacAddress: []const u8 = "",
    PkgId: []const u8 = "",
    ServerTag: []const u8 = "",
    SystemLanguage: []const u8 = "",
    OS: []const u8 = "",
    DeviceId2ShuShu: []const u8 = "",
    ScreenHeight: i32 = 0,
    ScreenWidth: i32 = 0,
    DeviceInfo: []const u8 = "",
    DriverDate: []const u8 = "",
    ClientVersion: []const u8 = "",
    OSVersion: []const u8 = "",
};
pub const PlayerBasicInfoGetRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
};
pub const PlayerBasicInfoGetResponse = struct {
    pub const default: @This() = .{};
    Info: ?PlayerDetails = null,
    ErrorCode: ?ErrorCode = null,
};
pub const BirthdayInitRequest = struct {
    pub const default: @This() = .{};
    Birthday: i32 = 0,
};
pub const BirthdayInitResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RoleShowListUpdateRequest = struct {
    pub const default: @This() = .{};
    RoleList: std.ArrayList(i32) = .empty,
};
pub const RoleShowListUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ChangeCardRequest = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
};
pub const ChangeCardResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ReadCardRequest = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
};
pub const ReadCardResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const BirthdayShowSetRequest = struct {
    pub const default: @This() = .{};
    DisPlay: bool = false,
};
pub const BirthdayShowSetResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PlayerNameUpdateNotify = struct {
    pub const default: @This() = .{};
    Name: []const u8 = "",
    LastModifyNameTime: i64 = 0,
};
pub const UpdatePlayStationBlockAccountRequest = struct {
    pub const default: @This() = .{};
    BlockedIds: std.ArrayList([]const u8) = .empty,
};
pub const UpdatePlayStationBlockAccountResponse = struct {
    pub const default: @This() = .{};
};
pub const PlayerHeadDataRequest = struct {
    pub const default: @This() = .{};
};
pub const PlayerHeadDataResponse = struct {
    pub const default: @This() = .{};
    PlayerHeadDataIds: std.ArrayList(i32) = .empty,
};
pub const WebSignRequest = struct {
    pub const default: @This() = .{};
};
pub const WebSignResponse = struct {
    pub const default: @This() = .{};
    NoticeSign: []const u8 = "",
};
pub const StorageInfoNotify = struct {
    pub const default: @This() = .{};
    Infos: std.ArrayList(ClientStorageInfo) = .empty,
};
pub const StorageInfoUpdateNotify = struct {
    pub const default: @This() = .{};
    Adds: std.ArrayList(ClientStorageInfo) = .empty,
    Updates: std.ArrayList(ClientStorageInfo) = .empty,
    Removes: std.ArrayList(i32) = .empty,
};
pub const StorageInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const StorageInfoResponse = struct {
    pub const default: @This() = .{};
    Infos: std.ArrayList(ClientStorageInfo) = .empty,
};
pub const StorageInfoUpdateRequest = struct {
    pub const default: @This() = .{};
    Infos: std.ArrayList(ClientStorageInfo) = .empty,
};
pub const StorageInfoUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ClientStorageInfo = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        MapMapData: ?ClientStorageMapMapData,
        MapListData: ?ClientStorageMapListData,
        MapData: ?ClientStorageMapData,
        ListData: ?ClientStorageListData,
        SetData: ?ClientStorageSetData,
        BoolData: ?ClientStorageBoolData,
        IntData: ?ClientStorageIntData,
        LongData: ?ClientStorageLongData,
        StringData: ?ClientStorageStringData,
    } = null,
    SystemId: i32 = 0,
};
pub const ClientStorageMapData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const ClientStorageMapMapData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(MapEntry(i32, ClientStorageMapData)) = .empty,
};
pub const ClientStorageMapListData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(MapEntry(i32, ClientStorageListData)) = .empty,
};
pub const ClientStorageListData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(i32) = .empty,
};
pub const ClientStorageSetData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(i32) = .empty,
};
pub const ClientStorageBoolData = struct {
    pub const default: @This() = .{};
    Data: bool = false,
};
pub const ClientStorageIntData = struct {
    pub const default: @This() = .{};
    Data: i32 = 0,
};
pub const ClientStorageLongData = struct {
    pub const default: @This() = .{};
    Data: i64 = 0,
};
pub const ClientStorageStringData = struct {
    pub const default: @This() = .{};
    Data: []const u8 = "",
};
pub const EClientStorageSystemIdType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Default = 0,
    Activity = 1,
    VisionSkin = 2,
    LoopTowerIsClickSeason = 3,
    LoopTowerIsClickShop = 4,
    TowerOverLockArea = 5,
    WeaponSkinRedDot = 6,
    FlySkinRedDot = 7,
    CalabashSkinRedDot = 8,
    MailBindNextShowRedDotTime = 9,
    RedDotAdventureNewSoundAreaTabLastUpdateTime = 10,
    SuitWeaponFirstWearRecord = 11,
    RoleSkinRedDot = 12,
    FirstOpenVisionGroup = 13,
    ShipTowerSeason = 14,
    AdventrueShipTowerSeason = 15,
    AdventrueWeeklyRogue = 16,
    AdventrueTower = 17,
    IntroductionVersion = 18,
    DetectionRedDotRecord = 19,
    ExploreActivityFirstUnlock = 20,
    FilterRedPoint = 21,
    VisionRecoveryBatchTip = 22,
    VisionRecoveryBatchAimTip = 23,
    MotorDiyNewUnlockId = 24,
    MotorDevelopNewUnlockTree = 25,
    PhantomBattleConfigApplyPlanWhenSaved = 26,
    FeiXuePreheatSubViewRedDot = 27,
    DropCatchRoleClickDetail = 28,
    FlagChallengeNewlyUnlockedLevelIds = 29,
    FlagChallengeNewlyUnlockedBuff = 30,
    PeriodicActivityRedLogReport = 31,
    CoopRolePhotoRedDot = 32,
    CoopRoleNewLevelRedDot = 33,
    FlagChallengeNewlyUnlockedBuffIds = 34,
    RoguelikeNewPhantomUnlock = 35,
    RoguelikeNewCharacterUnlock = 36,
    RoguelikeNewEntriesGroupUnlock = 37,
    AnniversaryActivityFirstClick = 38,
    VisionRefineTip = 39,
    Ornament = 40,
    GetOrnament = 41,
    ItemBackpackFirstCheck = 42,
    QuestBranchSystem = 43,
    GachaAccumulateFirstOpen = 44,
    Photography = 45,
    PhoneMsgChatShowRedDot = 46,
    GolemCrack = 47,
    FirstSheriffInference = 48,
    ThroughTrainFirstCheck = 49,
    FightPhotoTab = 50,
    VersionPayGiftRedDot = 51,
    NormalPayGiftRedDot = 52,
    FirstOpenDailyActivityTab = 53,
    RoleLangCustomRecord = 54,
    ActivityRecommend = 55,
    WheelTowerSeasonReview = 56,
    MotorSceneHadCheck = 57,
    RoleLangCustomFuncClicked = 58,
};
pub const PlayerXboxBlockListRequest = struct {
    pub const default: @This() = .{};
    XboxAccountIds: std.ArrayList([]const u8) = .empty,
};
pub const PlayerXboxBlockListResponse = struct {
    pub const default: @This() = .{};
};
pub const RoleVoice = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    VoiceId: i32 = 0,
};
pub const PlayerVoiceLanguageRequest = struct {
    pub const default: @This() = .{};
};
pub const PlayerVoiceLanguageResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleVoices: std.ArrayList(RoleVoice) = .empty,
};
pub const RoleVoiceSetting = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    VoiceLanguage: i32 = 0,
};
pub const PlayerRoleVoiceSetRequest = struct {
    pub const default: @This() = .{};
    RoleVoices: std.ArrayList(RoleVoiceSetting) = .empty,
};
pub const PlayerRoleVoiceSetResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PlayerAttrType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Int32 = 0,
    String = 1,
};
pub const PlayerAttrKey = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Level = 0,
    Exp = 1,
    Coin = 2,
    RareCoin = 3,
    HeadPhoto = 4,
    HeadFrame = 5,
    AreaId = 6,
    Name = 7,
    Sign = 8,
    Sex = 9,
    OriginWorldLevel = 10,
    CurWorldLevel = 11,
    WorldLevelTimeStamp = 12,
    CashCoin = 13,
    WorldPermission = 14,
    PlayerTitle = 15,
};
pub const PlayerAttr = struct {
    pub const default: @This() = .{};
    Value: ?union(enum) {
        Int32Value: i32,
        StringValue: []const u8,
    } = null,
    Key: ?PlayerAttrKey = null,
    ValueType: ?PlayerAttrType = null,
};
pub const PlayerAttrNotify = struct {
    pub const default: @This() = .{};
    Attributes: std.ArrayList(PlayerAttr) = .empty,
};
pub const MingSuGenInfo = struct {
    pub const default: @This() = .{};
    CreatureGenId: i64 = 0,
};
pub const DragonPoolInfo = struct {
    pub const default: @This() = .{};
    DragonPoolId: i32 = 0,
    ActiveStatus: i32 = 0,
    Level: i32 = 0,
    InjectedCoreItemCount: i32 = 0,
};
pub const ItemEntry = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    ItemCount: i32 = 0,
};
pub const ItemDict = struct {
    pub const default: @This() = .{};
    Items: std.ArrayList(ItemEntry) = .empty,
};
pub const DragonPoolDropItems = struct {
    pub const default: @This() = .{};
    DragonPoolId: i32 = 0,
    DropIds: std.ArrayList(i32) = .empty,
    DropItems: std.ArrayList(ItemDict) = .empty,
};
pub const DarkCoastDeliveryRequest = struct {
    pub const default: @This() = .{};
    DragonPoolId: i32 = 0,
};
pub const DarkCoastDeliveryResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    DragonPoolDropItems: ?DragonPoolDropItems = null,
    DefeatedGuard: std.ArrayList(i32) = .empty,
    ReceivedGuardReward: std.ArrayList(i32) = .empty,
    LevelGain: i32 = 0,
};
pub const TransferContextId = struct {
    pub const default: @This() = .{};
    BulletContextId: i64 = 0,
};
pub const BattlePassType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Free = 0,
    Pay = 1,
};
pub const PbBattlePassReward = struct {
    pub const default: @This() = .{};
    Level: i32 = 0,
    ItemId: i32 = 0,
    Type: i32 = 0,
};
pub const PbBattlePassRecurringReward = struct {
    pub const default: @This() = .{};
    Type: ?BattlePassType = null,
    ItemId: i32 = 0,
    Count: i32 = 0,
};
pub const PbBattlePass = struct {
    pub const default: @This() = .{};
    InTimeRange: bool = false,
    Id: i32 = 0,
    Level: i32 = 0,
    Exp: i32 = 0,
    WeeklyTotalExp: i32 = 0,
    PayStatus: i32 = 0,
    TakenRewards: std.ArrayList(PbBattlePassReward) = .empty,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
    RecurringRewards: std.ArrayList(PbBattlePassRecurringReward) = .empty,
    HadEnter: bool = false,
};
pub const BattlePassRequest = struct {
    pub const default: @This() = .{};
};
pub const BattlePassResponse = struct {
    pub const default: @This() = .{};
    BattlePass: ?PbBattlePass = null,
    ErrorCode: ?ErrorCode = null,
};
pub const BtType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BtTypeInvalid = 0,
    BtTypeQuest = 1,
    BtTypeLevelPlay = 2,
    BtTypeInst = 3,
    BtTypeInstDecision = 4,
    BtTypeRecall = 5,
};
pub const NodeStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NotActive = 0,
    BeforeActivate = 1,
    Activate = 2,
    Completing = 3,
    CompletedSuccess = 4,
    CompletedFailed = 5,
    Suspend = 6,
    Destroy = 7,
};
pub const NodeInfo = struct {
    pub const default: @This() = .{};
    ExtraInfo: ?union(enum) {
        ChildQuestNodeInfo: ?ChildQuestNodeInfo,
    } = null,
    Status: i32 = 0,
};
pub const TreeInfo = struct {
    pub const default: @This() = .{};
    TreeOwnerId: i32 = 0,
    TreeIncId: i64 = 0,
    BtType: ?BtType = null,
    BlackboardId: i32 = 0,
    Nodes: std.ArrayList(MapEntry(i32, NodeInfo)) = .empty,
    Vars: std.ArrayList(MapEntry([]const u8, VarDefinePb)) = .empty,
    TimerInfos: std.ArrayList(TimerInfoPb) = .empty,
    SuspendType: i32 = 0,
    OccupationInfo: std.ArrayList(OccupationPbInfo) = .empty,
    AudioState: std.ArrayList(MapEntry([]const u8, []const u8)) = .empty,
    IsScreenOccupy: bool = false,
    CharacterLookAtInfos: std.ArrayList(CharacterLookAtInfo) = .empty,
    SuspendNodeId: i32 = 0,
};
pub const BehaviorTreeInfoNotify = struct {
    pub const default: @This() = .{};
    TreeInfos: std.ArrayList(TreeInfo) = .empty,
};
pub const BehaviorTreeDeleteNotify = struct {
    pub const default: @This() = .{};
    TreeIncIds: std.ArrayList(i64) = .empty,
};
pub const ChildQuestNodeStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NotActive = 0,
    Enter = 1,
    EnterAction = 2,
    Progress = 3,
    Finished = 4,
    FinishAction = 5,
    Fail = 6,
};
pub const ChildQuestNodeProgress = struct {
    pub const default: @This() = .{};
    Progress: ?union(enum) {
        Kill: ?KillProgress,
        GetItem: ?GetItemProgress,
        MonsterCreator: ?MonsterCreatorProgress,
        UseItem: ?UseItemProgress,
        levelPlayCount: i32,
        Interact: ?InteractProgress,
        CompleteInst: ?CompleteInstProgress,
        EntityStateList: ?EntityStateProgress,
        GpuMonster: ?GpuMonsterProgress,
    } = null,
};
pub const GpuMonsterProgress = struct {
    pub const default: @This() = .{};
    CurKillNum: i32 = 0,
};
pub const EntityStateProgress = struct {
    pub const default: @This() = .{};
    EntityId: std.ArrayList(i32) = .empty,
};
pub const ChildQuestNodeInfo = struct {
    pub const default: @This() = .{};
    Status: ?ChildQuestNodeStatus = null,
    Progress: ?ChildQuestNodeProgress = null,
};
pub const KillProgress = struct {
    pub const default: @This() = .{};
    MonId: std.ArrayList(i32) = .empty,
    PrefabNum: i32 = 0,
    CurrNum: i32 = 0,
    TotalNum: i32 = 0,
};
pub const InteractProgress = struct {
    pub const default: @This() = .{};
    NpcId: std.ArrayList(i32) = .empty,
};
pub const GetItemProgress = struct {
    pub const default: @This() = .{};
    Info: std.ArrayList(GetItemCount) = .empty,
};
pub const GetItemCount = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Count: i32 = 0,
};
pub const SceneMonsterCreatedMonsterInfo = struct {
    pub const default: @This() = .{};
    PrefabId: i32 = 0,
    MapId: i32 = 0,
    BaseLife: i64 = 0,
    State: i32 = 0,
};
pub const MonsterCreatorProgress = struct {
    pub const default: @This() = .{};
    Slots: std.ArrayList(MonsterCreatorProgressSlot) = .empty,
    TotalNum: i32 = 0,
};
pub const MonsterCreatorProgressSlot = struct {
    pub const default: @This() = .{};
    WaveId: i32 = 0,
    KillMonIds: std.ArrayList(i32) = .empty,
    CurrentWaveEndTime: i32 = 0,
    SpawnStepType: i32 = 0,
    CreatorEntityConfigId: i32 = 0,
    MonsterInfo: std.ArrayList(SceneMonsterCreatedMonsterInfo) = .empty,
};
pub const UseItemProgress = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Count: i32 = 0,
};
pub const CompleteInstProgress = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    Count: i32 = 0,
};
pub const UpdateNodeProgressNotify = struct {
    pub const default: @This() = .{};
    TreeOwnerId: i32 = 0,
    TreeIncId: i64 = 0,
    NodeId: i32 = 0,
    Progress: ?ChildQuestNodeProgress = null,
};
pub const UpdateChildQuestNodeStatusNotify = struct {
    pub const default: @This() = .{};
    TreeOwnerId: i32 = 0,
    TreeIncId: i64 = 0,
    NodeId: i32 = 0,
    Status: ?ChildQuestNodeStatus = null,
};
pub const UpdateNodeStatusNotify = struct {
    pub const default: @This() = .{};
    TreeOwnerId: i32 = 0,
    TreeIncId: i64 = 0,
    NodeId: i32 = 0,
    Status: ?NodeStatus = null,
};
pub const ActionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    GetItem = 0,
    SendNpcMail = 1,
};
pub const OccupationPbInfo = struct {
    pub const default: @This() = .{};
    ResourceName: []const u8 = "",
    NodeId: i32 = 0,
    IncId: i64 = 0,
};
pub const SuspendType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Occupation = 0,
    Online = 1,
    ScreenOccupation = 2,
};
pub const TimerInfoPb = struct {
    pub const default: @This() = .{};
    TimerType: []const u8 = "",
    NodeId: i32 = 0,
    EndTime: i64 = 0,
    PauseTime: i64 = 0,
};
pub const CharacterLookAtInfo = struct {
    pub const default: @This() = .{};
    TargetId: ?union(enum) {
        TargetEntityId: i32,
    } = null,
    TargetPossition: ?union(enum) {
        TargetPos: ?Vector,
    } = null,
    EntityId: i32 = 0,
    TargetType: i32 = 0,
};
pub const SourceType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    UnDefine = 0,
    SourceEntity = 3,
    SourceQuest = 4,
};
pub const EntityConfigType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    OldEntity = 0,
    Level = 1,
    Global = 2,
    Character = 3,
    Template = 4,
    Prefab = 5,
};
pub const FightBuffInformation = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    BuffId: i64 = 0,
    Level: i32 = 0,
    StackCount: i32 = 0,
    InstigatorId: i64 = 0,
    EntityId: i64 = 0,
    ApplyType: ?ApplyGEType = null,
    Duration: f32 = 0,
    LeftDuration: f32 = 0,
    Context: std.ArrayList(FightBuffEffectContext) = .empty,
    IsActive: bool = false,
    ServerId: i32 = 0,
    MessageId: i64 = 0,
    ConfBuffId: i64 = 0,
};
pub const EntityPb = struct {
    pub const default: @This() = .{};
    d3s: ?union(enum) {
        Camp: i32,
    } = null,
    Id: i64 = 0,
    ConfigId: i32 = 0,
    ConfigType: ?EntityConfigType = null,
    EntityType: ?EEntityType = null,
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
    InitPos: ?Vector = null,
    LivingStatus: ?LivingStatus = null,
    IsVisible: bool = false,
    PlayerId: i32 = 0,
    ComponentPbs: std.ArrayList(EntityComponentPb) = .empty,
    DurabilityValue: i32 = 0,
    EntityState: ?EntityState = null,
    InitLinearVelocity: ?Vector = null,
    IsPosAbnormal: bool = false,
    PrefabId: i32 = 0,
    PrefabIncId: i64 = 0,
    SubEntityType: i32 = 0,
    OwnerIncId: i64 = 0,
    Gravity: ?Vector = null,
    RoleSkinId: i32 = 0,
    IsActorVisible: bool = false,
    SoarWingSkinId: i32 = 0,
    ParaglidingSkinId: i32 = 0,
    IsSnapLocation: bool = false,
    ClientHiddenFlag: bool = false,
};
pub const EntityComponentPb = struct {
    pub const default: @This() = .{};
    ComponentPb: ?union(enum) {
        AttributeComponent: ?AttributeComponentPb,
        TagComponent: ?TagComponentPb,
        TriggerComponent: ?TriggerComponentPb,
        SummonerComponent: ?SummonerComponentPb,
        PartComponent: ?PartComponentPb,
        VisionSkillComponent: ?VisionSkillComponentPb,
        AnimationStateComponent: ?AnimationStateComponentPb,
        BlackboardParamComponent: ?BlackboardParamComponentPb,
        SysBuffComponent: ?SysBuffComponentPb,
        ClientDataComponent: ?ClientDataComponentPb,
        MonsterWeaponComponentPb: ?MonsterWeaponComponentPb,
        MonsterAiComponentPb: ?MonsterAiComponentPb,
        FightBuffComponent: ?FightBuffComponentPb,
        NearbyTrackingComponentPb: ?NearbyTrackingComponentPb,
        DropComponentPb: ?DropComponentPb,
        MonsterCaptureComponent: ?MonsterCaptureComponentPb,
        LogicStateComponentPb: ?LogicStateComponentPb,
        AdviceComponentPb: ?AdviceComponentPb,
        LiftComponentPb: ?LiftComponentPb,
        InteractComponent: ?InteractComponentPb,
        EquipComponent: ?EquipComponentPb,
        BeControlledComponentPb: ?BeControlledComponentPb,
        ConcomitantsComponentPb: ?ConcomitantsComponentPb,
        TimelineTrackComponentPb: ?TimelineTrackComponentPb,
        SummonsComponentPb: ?SummonsComponentPb,
        EntityFsmComponentPb: ?EntityFsmComponentPb,
        BoardPb: ?BoardPb,
        PlacementItemPb: ?PlacementItemPb,
        StateTagComponentPb: ?StateTagComponentPb,
        MonsterGachaDataPb: ?MonsterGachaDataPb,
        FanComponentPb: ?FanComponentPb,
        NpcPb: ?NpcPb,
        BubbleComponent: ?BubbleComponentPb,
        PatrolComponent: ?PatrolComponentPb,
        RangeComponent: ?RangeComponentPb,
        PassiveSkillComponentPb: ?PassiveSkillComponentPb,
        PassiveGaSkillComponentPb: ?PassiveGaSkillComponentPb,
        DynAttachComponentPb: ?DynAttachComponentPb,
        EntityVarComponentPb: ?EntityVarComponentPb,
        FollowShooterComponentPb: ?FollowShooterComponentPb,
        StateComponentPb: ?StateComponentPb,
        BulletComponentPb: ?BulletComponentPb,
        BuffProducerComponentPb: ?BuffProducerComponentPb,
        BuffConsumerComponentPb: ?BuffConsumerComponentPb,
        SceneItemComponentPb: ?SceneItemComponentPb,
        ShieldComponentPb: ?ShieldComponentPb,
        NPCPerformGroupComponentPb: ?NPCPerformGroupComponentPb,
        PlayerSceneComponentPb: ?PlayerSceneComponentPb,
        JigsawBaseComponentPb: ?JigsawBaseComponentPb,
        RoleRecordComponentPb: ?RoleRecordComponentPb,
        FollowerComponentPb: ?FollowerComponentPb,
        AttributesIdsComponentPb: ?AttributesIdsComponentPb,
        PullingFoundationComponentPb: ?PullingFoundationComponentPb,
        BatchBulletCastComponentPb: ?BatchBulletCastComponentPb,
        WeaponSkinComponentPb: ?WeaponSkinComponentPb,
        CharacterAttachComponentPb: ?CharacterAttachComponentPb,
        PatrolInfoComponentPb: ?PatrolInfoComponentPb,
        AnimalPerformComponentPb: ?AnimalPerformComponentPb,
        NpcDriveVehicleComponentPb: ?NpcDriveVehicleComponentPb,
        GrapplingHookPointComponentPb: ?GrapplingHookPointComponentPb,
        HackingComponentPb: ?HackingComponentPb,
        HackTargetComponentPb: ?HackTargetComponentPb,
        GravityFlipComponent: ?GravityFlipComponent,
        EntityMoveSplineComponentPb: ?EntityMoveSplineComponentPb,
        EntityRewardItemPb: ?EntityRewardItemPb,
        TemplateEntitySpawnerComponentPb: ?TemplateEntitySpawnerComponentPb,
        GridObjectComponentPb: ?GridObjectComponentPb,
        SimpleCombatComponentPb: ?SimpleCombatComponentPb,
        TrapDefenseComponentPb: ?TrapDefenseComponentPb,
        HoldHandComponentPb: ?HoldHandComponentPb,
        SceneItemEventListenerComponentPb: ?SceneItemEventListenerComponentPb,
        ActivityComponentPb: ?ActivityComponentPb,
        CalabashSkinComponentPb: ?CalabashSkinComponentPb,
        HonamiStoryDropItemComponentPb: ?HonamiStoryDropItemComponentPb,
        HonamiStoryEnhanceLevelComponentPb: ?HonamiStoryEnhanceLevelComponentPb,
        MoveToPointComponentPb: ?MoveToPointComponentPb,
        RbBlockComponentPb: ?RbBlockComponentPb,
        SpiritGearComponentPb: ?SunSpiritGearComponentPb,
        VehiclePb: ?VehiclePb,
        RbFloorComponentPb: ?RbFloorComponentPb,
        RbItemComponentPb: ?RbItemComponentPb,
        RoadNetworkComponentPb: ?RoadNetworkComponentPb,
        FollowEntityComponentPb: ?FollowEntityComponentPb,
        MotorOutlookComponentPb: ?MotorDiyEquippedPb,
        MotorDaCtxComponentPb: ?MotorDaCtxComponentPb,
        ExhibitionComponentPb: ?ExhibitionComponentPb,
        FurnitureComponentPb: ?FurnitureComponentPb,
        OrnamentComponentPb: ?OrnamentComponentPb,
        FlowerPollutionComponentPb: ?FlowerPollutionComponentPb,
        DollGrabMachineComponentPb: ?DollGrabMachineComponentPb,
        DollGrabShowcaseComponentPb: ?DollGrabShowcaseComponentPb,
        GpuEntityComponentPb: ?GpuEntityComponentPb,
        RoverRoguePortalComponentPb: ?RoverRoguePortalComponentPb,
    } = null,
};
pub const RoverRoguePortalComponentPb = struct {
    pub const default: @This() = .{};
    RewardType: i32 = 0,
    BlessRoleId: i32 = 0,
};
pub const MotorDaCtxComponentPb = struct {
    pub const default: @This() = .{};
    MotorDaCtxId: i64 = 0,
};
pub const MonsterAiComponentPb = struct {
    pub const default: @This() = .{};
    WeaponId: i32 = 0,
    HatredGroupId: i64 = 0,
    AiTeamInitId: i32 = 0,
    CombatMessageId: i64 = 0,
    BasicPerceptionIds: std.ArrayList(i32) = .empty,
    HatredId: i64 = 0,
};
pub const MonsterWeaponComponentPb = struct {
    pub const default: @This() = .{};
    WeaponId: i32 = 0,
};
pub const BatchBulletCastComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const RangeComponentPb = struct {
    pub const default: @This() = .{};
    InRangePlayers: std.ArrayList(i32) = .empty,
    InRangeEntities: std.ArrayList(i64) = .empty,
};
pub const ClientDataComponentPb = struct {
    pub const default: @This() = .{};
    IsStaticInit: bool = false,
    OwnerId: i64 = 0,
    GroupId: i32 = 0,
};
pub const AttributeComponentPb = struct {
    pub const default: @This() = .{};
    HardnessModeId: i32 = 0,
    RageModeId: i32 = 0,
    AttrData: std.ArrayList(AttrData) = .empty,
};
pub const TagComponentPb = struct {
    pub const default: @This() = .{};
    GameplayTags: std.ArrayList(GameplayTagData) = .empty,
    EntityCommonTags: std.ArrayList(i32) = .empty,
    InitGameplayTag: bool = false,
};
pub const TriggerComponentPb = struct {
    pub const default: @This() = .{};
    TriggerCount: i32 = 0,
    ExitTriggerCount: i32 = 0,
    ConstateId: i64 = 0,
};
pub const StateTagComponentPb = struct {
    pub const default: @This() = .{};
    StateTagId: i32 = 0,
};
pub const VisionSkillComponentPb = struct {
    pub const default: @This() = .{};
    VisionSkillInfos: std.ArrayList(VisionSkillInformation) = .empty,
    PhantomSkillInfo: ?VisionSkillInformation = null,
};
pub const EntityVarComponentPb = struct {
    pub const default: @This() = .{};
    Vars: std.ArrayList(MapEntry([]const u8, VarDefinePb)) = .empty,
};
pub const BoneVisibleData = struct {
    pub const default: @This() = .{};
    BoneName: []const u8 = "",
    HideBone: bool = false,
};
pub const AnimationStateComponentPb = struct {
    pub const default: @This() = .{};
    AnimationStates: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    BoneVisibleDatas: std.ArrayList(BoneVisibleData) = .empty,
    AnimationTags: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const LogicStateComponentPb = struct {
    pub const default: @This() = .{};
    PositionState: i32 = 0,
    MoveState: i32 = 0,
    DirectionState: i32 = 0,
    PositionSubState: i32 = 0,
};
pub const LiftComponentPb = struct {
    pub const default: @This() = .{};
    Location: i32 = 0,
};
pub const BlackboardParamComponentPb = struct {
    pub const default: @This() = .{};
    BlackboardParams: std.ArrayList(BlackboardParam) = .empty,
};
pub const SysBuffComponentPb = struct {
    pub const default: @This() = .{};
    SysBuffInfos: std.ArrayList(SysBuffInformation) = .empty,
};
pub const SysBuffInformation = struct {
    pub const default: @This() = .{};
    ServerId: i32 = 0,
    BuffId: i64 = 0,
    Level: i32 = 0,
    MessageId: i64 = 0,
    InstigatorId: i64 = 0,
    Duration: f32 = 0,
    StackCount: i32 = 0,
    ApplyType: i32 = 0,
    IsIterable: bool = false,
};
pub const FightBuffComponentPb = struct {
    pub const default: @This() = .{};
    FightBuffInfos: std.ArrayList(FightBuffInformation) = .empty,
    ListBuffEffectCd: std.ArrayList(BuffEffectCd) = .empty,
    ClientBornBuffIds: std.ArrayList(i64) = .empty,
    ClientBornMessageId: i64 = 0,
};
pub const NearbyTrackingComponentPb = struct {
    pub const default: @This() = .{};
    IsEnable: bool = false,
};
pub const DropComponentPb = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    ShowPlanId: i32 = 0,
    ItemCount: i32 = 0,
    EntityConfigId: i32 = 0,
};
pub const MonsterCaptureComponentPb = struct {
    pub const default: @This() = .{};
    TemplateId: i32 = 0,
    EntityId: i32 = 0,
    MonsterId: i32 = 0,
};
pub const BubbleInfo = struct {
    pub const default: @This() = .{};
    ActionGuid: []const u8 = "",
    GameCtx: ?GameCtxPb = null,
};
pub const BubbleComponentPb = struct {
    pub const default: @This() = .{};
    BubbleInfos: std.ArrayList(BubbleInfo) = .empty,
};
pub const RoleRecordComponentPb = struct {
    pub const default: @This() = .{};
    IsAutoRole: bool = false,
    ConstateId: i64 = 0,
};
pub const DynamicInteractInfo = struct {
    pub const default: @This() = .{};
    OptionGuid: []const u8 = "",
    GameCtx: ?GameCtxPb = null,
    Text: []const u8 = "",
    DelayRemove: bool = false,
};
pub const InteractComponentPb = struct {
    pub const default: @This() = .{};
    DynamicInteractInfos: std.ArrayList(DynamicInteractInfo) = .empty,
    RandomInteractIndex: std.ArrayList(i32) = .empty,
    Interacting: bool = false,
};
pub const SceneItemComponentPb = struct {
    pub const default: @This() = .{};
    PosSender: i32 = 0,
    BlackBoards: std.ArrayList(SceneItemBlackboardParam) = .empty,
};
pub const BeControlledComponentPb = struct {
    pub const default: @This() = .{};
    PlayerEntityId: i64 = 0,
    RelationId: i32 = 0,
    IsShow: bool = false,
    MatchIndex: i32 = 0,
    ConstateId: i64 = 0,
};
pub const PullingFoundationComponentPb = struct {
    pub const default: @This() = .{};
    RelationId: i32 = 0,
    MatchIndex: i32 = 0,
};
pub const DynAttachComponentPb = struct {
    pub const default: @This() = .{};
    PbDynAttachEntityConfigId: i32 = 0,
    PbDynAttachEntityActorKey: []const u8 = "",
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
    PbDynAttachRefActorKey: []const u8 = "",
};
pub const ConcomitantsComponentPb = struct {
    pub const default: @This() = .{};
    VisionEntityId: std.ArrayList(i64) = .empty,
    CustomEntityIds: std.ArrayList(i64) = .empty,
    PhantomRoleId: i64 = 0,
    BossRushId: i64 = 0,
};
pub const FollowEntityComponentPb = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const TimelineTrackControlDataPb = struct {
    pub const default: @This() = .{};
    ControlPoint: i32 = 0,
};
pub const TimelineTrackComponentPb = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
    ControlDatas: std.ArrayList(TimelineTrackControlDataPb) = .empty,
};
pub const BoardPb = struct {
    pub const default: @This() = .{};
    OccupiedGridList: std.ArrayList(OccupiedBoardGridInfo) = .empty,
    DynamicGridConfigs: std.ArrayList(BoardGridDynamicConfig) = .empty,
    CanMove: bool = false,
};
pub const CrystalMonsterSlotInfo = struct {
    pub const default: @This() = .{};
    EntityIds: std.ArrayList(i32) = .empty,
    MonsterType: i32 = 0,
};
pub const CrystalMonsterInfoPb = struct {
    pub const default: @This() = .{};
    SlotInfoList: std.ArrayList(CrystalMonsterSlotInfo) = .empty,
};
pub const MonsterGachaDataPb = struct {
    pub const default: @This() = .{};
    MonsterCrystalInfoList: std.ArrayList(CrystalMonsterInfoPb) = .empty,
};
pub const FanComponentPb = struct {
    pub const default: @This() = .{};
    NumOfTurns: i32 = 0,
};
pub const PassiveSkillItemPb = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    SkillId: i64 = 0,
};
pub const PassiveSkillComponentPb = struct {
    pub const default: @This() = .{};
    PassiveSkillItemPbList: std.ArrayList(PassiveSkillItemPb) = .empty,
};
pub const CharacterSkillComponentPb = struct {
    pub const default: @This() = .{};
    UseSkillInfo: ?UseSkillInformation = null,
    MontageIndex: i32 = 0,
    MontagePlayTime: i32 = 0,
    Section: []const u8 = "",
    SpeedRatio: f32 = 0,
    MessageId: i64 = 0,
    MontageContext: i64 = 0,
};
pub const SkillComponentPb = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
    ConstateId: i64 = 0,
};
pub const PassiveGaSkillComponentPb = struct {
    pub const default: @This() = .{};
    SkillInfoList: std.ArrayList(CharacterSkillComponentPb) = .empty,
    SkillComponentPb: std.ArrayList(SkillComponentPb) = .empty,
};
pub const UseSkillInformation = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    SkillId: i64 = 0,
    MovementInformation: ?MovementInformation = null,
    Location: ?Vector = null,
    TargetId: i64 = 0,
    TimeStamp: f32 = 0,
    IsSpecialSkill: bool = false,
    Duration: i32 = 0,
    SkillInterruptLevel: i32 = 0,
    FightState: i32 = 0,
};
pub const StateComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const BuffProducerComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const BuffConsumerComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const SceneItemEventListenerComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const BulletComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const EntityAddNotify = struct {
    pub const default: @This() = .{};
    EntityPbs: std.ArrayList(EntityPb) = .empty,
    RemoveTagIds: bool = false,
};
pub const EntityRemoveNotify = struct {
    pub const default: @This() = .{};
    RemoveInfos: std.ArrayList(EntityRemoveInfo) = .empty,
    IsRemove: bool = false,
};
pub const DestroyType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NotDelay = 0,
    Delay = 1,
};
pub const VarDefinePb = struct {
    pub const default: @This() = .{};
    Value: ?union(enum) {
        Boolean: bool,
        Int: i64,
        String: []const u8,
        Float: f32,
        Entity: i32,
        Quest: i32,
        QuestState: ?QuestState,
        Transform: ?Transform,
        Prefab: i64,
    } = null,
    VarType: i32 = 0,
};
pub const NpcPb = struct {
    pub const default: @This() = .{};
    SplineEntityId: i32 = 0,
    SpawnEntityId: i32 = 0,
};
pub const LivingStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Alive = 0,
    Dead = 1,
    Init = 2,
};
pub const EntityState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Default = 0,
    Sleep = 1,
    Born = 2,
    Other = 3,
};
pub const LogicStateInitRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    EntityId: i64 = 0,
    InitData: ?LogicStateComponentPb = null,
    ClientEntityId: i64 = 0,
};
pub const LogicStateInitPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    EntityId: i64 = 0,
    InitData: ?LogicStateComponentPb = null,
    ClientEntityId: i64 = 0,
};
pub const LogicStateInitResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const LogicStateInitNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    EntityId: i64 = 0,
    InitData: ?LogicStateComponentPb = null,
};
pub const SwitchLogicStateRequest = struct {
    pub const default: @This() = .{};
    States: ?LogicStateComponentPb = null,
    ClientEntityId: i64 = 0,
};
pub const SwitchLogicStatePush = struct {
    pub const default: @This() = .{};
    States: ?LogicStateComponentPb = null,
    ClientEntityId: i64 = 0,
};
pub const SwitchLogicStateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SwitchLogicStateNotify = struct {
    pub const default: @This() = .{};
    States: ?LogicStateComponentPb = null,
};
pub const EntityActiveRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const EntityActiveResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ComponentPbs: std.ArrayList(EntityComponentPb) = .empty,
    IsVisible: bool = false,
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
    AiControlPlayerId: i32 = 0,
};
pub const AnimationGameplayTagRequest = struct {
    pub const default: @This() = .{};
    AddTagIds: i32 = 0,
    RemoveTagIds: bool = false,
};
pub const AnimationGameplayTagPush = struct {
    pub const default: @This() = .{};
    AddTagIds: i32 = 0,
    RemoveTagIds: bool = false,
};
pub const AnimationGameplayTagResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AnimationGameplayTagNotify = struct {
    pub const default: @This() = .{};
    AddTagIds: i32 = 0,
    RemoveTagIds: bool = false,
};
pub const AnimalDieRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Pos: ?Vector = null,
};
pub const AnimalDieResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AnimalDestroyRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const AnimalDestroyResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AnimalDropRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const AnimalDropResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const EntityStateReadyNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    TagId: i32 = 0,
    Ready: bool = false,
};
pub const EntityInteractRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    OptionIndex: i32 = 0,
    VisionEntityId: i64 = 0,
};
pub const EntityInteractResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Interacting: bool = false,
};
pub const EntityDynamicInteractRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    OptionGuid: []const u8 = "",
};
pub const EntityDynamicInteractResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Interacting: bool = false,
};
pub const BoneVisibleChangeRequest = struct {
    pub const default: @This() = .{};
    BoneVisibleData: ?BoneVisibleData = null,
};
pub const BoneVisibleChangePush = struct {
    pub const default: @This() = .{};
    BoneVisibleData: ?BoneVisibleData = null,
};
pub const BoneVisibleChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const BoneVisibleChangeNotify = struct {
    pub const default: @This() = .{};
    BoneVisibleData: ?BoneVisibleData = null,
};
pub const EquipComponentPb = struct {
    pub const default: @This() = .{};
    WeaponId: i32 = 0,
    WeaponBreachLevel: i32 = 0,
};
pub const WeaponSkinComponentPb = struct {
    pub const default: @This() = .{};
    WeaponSkinId: i32 = 0,
};
pub const OrnamentComponentPb = struct {
    pub const default: @This() = .{};
    OrnamentIds: std.ArrayList(i32) = .empty,
};
pub const CharacterAttachComponentPb = struct {
    pub const default: @This() = .{};
    PbCombinePartInfoList: std.ArrayList(CharacterAttachInfo) = .empty,
    PbCombineTargetServerId: i64 = 0,
};
pub const EntityEquipChangeNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    EquipComponent: ?EquipComponentPb = null,
};
pub const EntityEquipSkinChangeNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    WeaponSkinComponentPb: ?WeaponSkinComponentPb = null,
};
pub const EntityDressOrnamentChangeNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    OrnamentComponentPb: ?OrnamentComponentPb = null,
};
pub const StaticHookMoveType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Hook = 0,
    Pull = 1,
};
pub const EntityStaticHookMoveRequest = struct {
    pub const default: @This() = .{};
    Target: ?union(enum) {
        TargetEntityId: i64,
        TargetPos: ?Vector,
    } = null,
    EntityId: i64 = 0,
    HookMoveType: ?StaticHookMoveType = null,
};
pub const EntityStaticHookMovePush = struct {
    pub const default: @This() = .{};
    Target: ?union(enum) {
        TargetEntityId: i64,
        TargetPos: ?Vector,
    } = null,
    EntityId: i64 = 0,
    HookMoveType: ?StaticHookMoveType = null,
};
pub const EntityStaticHookMoveResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const EntityStaticHookMoveNotify = struct {
    pub const default: @This() = .{};
    Target: ?union(enum) {
        TargetEntityId: i64,
        TargetPos: ?Vector,
    } = null,
    EntityId: i64 = 0,
    HookMoveType: ?StaticHookMoveType = null,
};
pub const SilenceNpcNotify = struct {
    pub const default: @This() = .{};
    vTs: std.ArrayList(MapEntry(i32, bool)) = .empty,
};
pub const EntityPatrolStopRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const EntityPatrolStopResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PatrolComponentPb = struct {
    pub const default: @This() = .{};
    Dir: bool = false,
};
pub const FlowerPollutionComponentPb = struct {
    pub const default: @This() = .{};
    UnPollutionSpline: std.ArrayList(i32) = .empty,
};
pub const DollGrabMachineComponentPb = struct {
    pub const default: @This() = .{};
    CanCapturedItems: std.ArrayList(i32) = .empty,
    HighScore: i32 = 0,
    AccumulatedScore: i32 = 0,
};
pub const DollGrabShowcaseComponentPb = struct {
    pub const default: @This() = .{};
    DollItems: std.ArrayList(i32) = .empty,
};
pub const DollSmallMapInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const DollSmallMapInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SceneUnlimitedScoreInfos: std.ArrayList(SceneUnlimitedScoreInfo) = .empty,
    SceneDollDeliveryInfos: std.ArrayList(SceneDollDeliveryInfo) = .empty,
};
pub const SceneUnlimitedScoreInfo = struct {
    pub const default: @This() = .{};
    instId: i32 = 0,
    UnlimitedScoreInfos: std.ArrayList(UnlimitedScoreInfo) = .empty,
};
pub const UnlimitedScoreInfo = struct {
    pub const default: @This() = .{};
    entityId: i32 = 0,
    HighestScore: i32 = 0,
    AccumulatedScore: i32 = 0,
};
pub const SceneDollDeliveryInfo = struct {
    pub const default: @This() = .{};
    instId: i32 = 0,
    DollDeliveryInfos: std.ArrayList(DollDeliveryInfo) = .empty,
};
pub const DollDeliveryInfo = struct {
    pub const default: @This() = .{};
    ShowcaseEntityId: i32 = 0,
    DeliveredDolls: std.ArrayList(i32) = .empty,
};
pub const EntityPositionRequest = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    DungeonInstanceId: i32 = 0,
};
pub const EntityPositionResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Pos: ?Vector = null,
};
pub const ShieldInfoPb = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    ConfigId: i32 = 0,
    ShieldValue: i32 = 0,
    Priority: i32 = 0,
    BuffHandle: i32 = 0,
    IsValid: bool = false,
};
pub const ShieldComponentPb = struct {
    pub const default: @This() = .{};
    ShieldInfoPbList: std.ArrayList(ShieldInfoPb) = .empty,
    ShieldValueTotal: i32 = 0,
};
pub const NPCPerformGroupComponentPb = struct {
    pub const default: @This() = .{};
    Type: []const u8 = "",
    State: []const u8 = "",
};
pub const PlayerSceneComponentPb = struct {
    pub const default: @This() = .{};
    EntityIds: std.ArrayList(i64) = .empty,
};
pub const AttributesIdsComponentPb = struct {
    pub const default: @This() = .{};
    PbSceneItemAttributeIds: std.ArrayList(i32) = .empty,
};
pub const VehicleManipulateRequest = struct {
    pub const default: @This() = .{};
    Exit: ?union(enum) {
        ExitType: ?ExitVehicleType,
    } = null,
    EntityId: i64 = 0,
    HostPlayerId: i32 = 0,
    IsEntering: bool = false,
    Seat: i32 = 0,
    ClientPredicted: bool = false,
    ReasonMsg: []const u8 = "",
};
pub const VehicleManipulateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const VehicleFinishRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const VehicleFinishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const EntityEnterVehicleRequest = struct {
    pub const default: @This() = .{};
    Exit: ?union(enum) {
        ExitType: ?ExitVehicleType,
    } = null,
    EntityId: i64 = 0,
    VehicleCreatureId: i64 = 0,
    HostPlayerId: i32 = 0,
    IsEntering: bool = false,
    Seat: i32 = 0,
    ClientPredicted: bool = false,
    ReasonMsg: []const u8 = "",
};
pub const EntityEnterVehicleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const VehicleUpdateEntityNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    VehicleCreatureId: i64 = 0,
    Seat: i32 = 0,
    IsEntering: bool = false,
    ExitType: ?ExitVehicleType = null,
    ClientPredicted: bool = false,
};
pub const ExitVehicleType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ExitVehicleTypeLaunch = 0,
    ExitVehicleTypeNormal = 1,
    ExitVehicleTypeDelayShow = 2,
    ExitVehicleTypeSeatStandUp = 3,
    ExitVehicleTypeAllRole = 4,
};
pub const VehiclePlayerData = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Seat: i32 = 0,
};
pub const ChangeVehicleRideSharingRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Seat: i32 = 0,
};
pub const ChangeVehicleRideSharingResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RemoveRideSharingPassengerRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const RemoveRideSharingPassengerResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const UpdateVehicleRideSharingNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    RoleId: i32 = 0,
    Seat: i32 = 0,
    EntityId: i64 = 0,
};
pub const SendMovieModeRideSharingRequest = struct {
    pub const default: @This() = .{};
    IsInMovieRideSharingMode: bool = false,
    ShareRideMode: ?RideMode = null,
};
pub const SendMovieModeRideSharingResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const VehicleShareNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    ShareRideMode: ?RideMode = null,
    IsInMovieRideSharingMode: bool = false,
    Reason: ?VehicleShareReason = null,
};
pub const VehicleShareReason = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ClientRequest = 0,
    ChangeFormation = 1,
    GetOff = 2,
    RebackScene = 3,
    CharacterDie = 4,
    Command = 5,
};
pub const RideMode = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ShareRideMode_MovieMotor = 0,
};
pub const PatrolInfoComponentPb = struct {
    pub const default: @This() = .{};
    SceneAiEnabled: bool = false,
    PatrolInfo: ?PatrolInfoPb = null,
};
pub const PatrolInfoPb = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        SmartObjectComponent: ?SmartObjectComponent,
    } = null,
};
pub const SmartObjectComponent = struct {
    pub const default: @This() = .{};
    LastPassIndex: i32 = 0,
};
pub const AnimalPerformComponentPb = struct {
    pub const default: @This() = .{};
    AnimalInitialPartIds: std.ArrayList(i32) = .empty,
};
pub const NpcDriveVehicleComponentPb = struct {
    pub const default: @This() = .{};
    VehicleCreatureId: i64 = 0,
    Seat: i32 = 0,
};
pub const GrapplingHookPointComponentPb = struct {
    pub const default: @This() = .{};
    HookLockPointDisabled: bool = false,
};
pub const MoveToPointComponentPb = struct {
    pub const default: @This() = .{};
    PbMoveToPointConfig: ?PbMoveToPointConfig = null,
};
pub const PbMoveToPointConfig = struct {
    pub const default: @This() = .{};
    TargetPos: ?Vector = null,
    MoveType: i32 = 0,
    IsExact: bool = false,
};
pub const EntityMoveSplineComponentPb = struct {
    pub const default: @This() = .{};
    RuntimeData: ?union(enum) {
        SceneItemSplineRuntimeData: ?SceneItemSplineRuntimeData,
    } = null,
    SplineEntityId: i32 = 0,
    MoveSplineConfig: ?MoveSplineConfig = null,
};
pub const MoveSplineConfig = struct {
    pub const default: @This() = .{};
    StartPoint: ?union(enum) {
        StartPointIndex: i32,
    } = null,
    EndPoint: ?union(enum) {
        EndPointIndex: i32,
    } = null,
    LookDir: ?union(enum) {
        IsLookDir: bool,
    } = null,
    Cycle: ?union(enum) {
        CycleCount: i32,
    } = null,
    Circle: ?union(enum) {
        IsCircle: bool,
    } = null,
};
pub const SceneItemSplineRuntimeData = struct {
    pub const default: @This() = .{};
    Distance: ?union(enum) {
        DistanceAlongPath: f32,
    } = null,
    Rot: ?union(enum) {
        CurRot: ?Rotator,
    } = null,
    CurPos: ?Vector = null,
};
pub const TemplateSpawnerType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    TemplateDefault = 0,
    TemplateMatrix = 1,
};
pub const TemplateEntitySpawnerComponentPb = struct {
    pub const default: @This() = .{};
    SpawnerType: ?TemplateSpawnerType = null,
    CreateEntityInfos: std.ArrayList(SpawnerEntityInfo) = .empty,
};
pub const GroupTypesWrapper = struct {
    pub const default: @This() = .{};
    GroupTypes: std.ArrayList(i32) = .empty,
};
pub const SpawnerEntityInfo = struct {
    pub const default: @This() = .{};
    Group: ?union(enum) {
        GroupTypes: ?GroupTypesWrapper,
    } = null,
    SpawnerSubType: ?union(enum) {
        MatrixInfo: ?MatrixInfo,
    } = null,
    IncId: i64 = 0,
};
pub const MatrixInfo = struct {
    pub const default: @This() = .{};
    X: i32 = 0,
    Y: i32 = 0,
};
pub const GridObjectComponentPb = struct {
    pub const default: @This() = .{};
    InitGridPlacementPbInfo: ?GridPlacementPbInfo = null,
};
pub const GridPlacementPbInfo = struct {
    pub const default: @This() = .{};
    GridPb: ?union(enum) {
        Direction: ?GridPbDirection,
    } = null,
    ActorGuide: []const u8 = "",
    X: i32 = 0,
    Y: i32 = 0,
};
pub const GridPbDirection = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    GridForward = 0,
    GridBackward = 1,
    GridLeft = 2,
    GridRight = 3,
};
pub const SimpleCombatComponentPb = struct {
    pub const default: @This() = .{};
    SplineConfig: ?union(enum) {
        SplineConfigId: i32,
    } = null,
    SplineMove: ?union(enum) {
        SplineMoveType: ?SimpleCombatSplineMovePbType,
    } = null,
    SubTypeId: i32 = 0,
    BuffLayers: std.ArrayList(MapEntry(i32, i32)) = .empty,
    SimpleCombatEntityAttributePbInfo: std.ArrayList(MapEntry(i32, i32)) = .empty,
    LockedAttributeMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const SimpleCombatSplineMovePbType = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const TrapDefenseComponentPb = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        BuildingPbData: ?TrapDefenseBuildingPbData,
        AuxiliaryPbData: ?TrapDefenseAuxiliaryPbData,
        MonsterPbData: ?TrapDefenseMonsterPbData,
        GoldenCointPbData: ?TrapDefenseGoldenCoinPbData,
        SpecialCellPbdata: ?TrapDefenseSpecialCellPbData,
    } = null,
};
pub const TrapDefenseBuildingPbData = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    battleLevel: i32 = 0,
    ConstructCost: i32 = 0,
    DeconstructReturn: i32 = 0,
};
pub const TrapDefenseAuxiliaryPbData = struct {
    pub const default: @This() = .{};
    ConfigId: std.ArrayList(i32) = .empty,
};
pub const TrapDefenseMonsterPbData = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const TrapDefenseGoldenCoinPbData = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const TrapDefenseSpecialCellPbData = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const HoldHandComponentPb = struct {
    pub const default: @This() = .{};
    TargetEntityId: i64 = 0,
    HandType: i32 = 0,
    IsFollow: bool = false,
    ActionType: i32 = 0,
};
pub const ActivityComponentPb = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        SurvivorsMonsterPbData: ?SurvivorsMonsterPbData,
        SurvivorsWeaponPbData: ?SurvivorsWeaponPbData,
        SurvivorsPlayerCharacterPbData: ?SurvivorsPlayerCharacterPbData,
        SurvivorsGoldenCoinPbData: ?SurvivorsGoldenCoinPbData,
        PinballKSCRolePbData: ?PinballKSCRolePbData,
        KurotatoCharacterEntityPbData: ?KurotatoCharacterEntityPbData,
        KurotatoDropEntityPbData: ?KurotatoDropEntityPbData,
        KurotatoWeaponEntityPbData: ?KurotatoWeaponEntityPbData,
        KurotatoMonsterEntityPbData: ?KurotatoMonsterEntityPbData,
        KurotatoStructureEntityPbData: ?KurotatoStructureEntityPbData,
    } = null,
    ConfigId: i32 = 0,
};
pub const SurvivorsMonsterPbData = struct {
    pub const default: @This() = .{};
    SpawnPointEntityId: i32 = 0,
};
pub const SurvivorsWeaponPbData = struct {
    pub const default: @This() = .{};
};
pub const SurvivorsPlayerCharacterPbData = struct {
    pub const default: @This() = .{};
};
pub const SurvivorsGoldenCoinPbData = struct {
    pub const default: @This() = .{};
};
pub const KurotatoMonsterEntityPbData = struct {
    pub const default: @This() = .{};
    jl0: ?union(enum) {
        SpawnConfigId: i32,
    } = null,
    Tv0: ?union(enum) {
        SpawnConfigGroupIndex: i32,
    } = null,
};
pub const KurotatoWeaponEntityPbData = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
};
pub const KurotatoCharacterEntityPbData = struct {
    pub const default: @This() = .{};
};
pub const KurotatoDropEntityPbData = struct {
    pub const default: @This() = .{};
};
pub const KurotatoStructureEntityPbData = struct {
    pub const default: @This() = .{};
};
pub const GpuEntityComponentPb = struct {
    pub const default: @This() = .{};
    data: ?union(enum) {
        GpuMonsterEntityPbData: ?GpuMonsterEntityPbData,
        GpuRolePbEntityData: ?GpuRoleEntityPbData,
    } = null,
    ConfigId: i32 = 0,
};
pub const GpuMonsterEntityPbData = struct {
    pub const default: @This() = .{};
};
pub const GpuRoleEntityPbData = struct {
    pub const default: @This() = .{};
    IncId: i64 = 0,
};
pub const CalabashSkinComponentPb = struct {
    pub const default: @This() = .{};
    CalabashSkinId: i32 = 0,
};
pub const EntityCalabashSkinChangeNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    CalabashSkinCoponent: ?CalabashSkinComponentPb = null,
};
pub const HonamiStoryDropItemComponentPb = struct {
    pub const default: @This() = .{};
    Item: ?HonamiStoryItemInfo = null,
};
pub const HonamiStoryEnhanceLevelComponentPb = struct {
    pub const default: @This() = .{};
    Level: i32 = 0,
};
pub const RbGridPosition = struct {
    pub const default: @This() = .{};
    X: i32 = 0,
    Y: i32 = 0,
};
pub const RbBlockComponentPb = struct {
    pub const default: @This() = .{};
    Type: ?union(enum) {
        DefaultBlockType: ?RbDefaultBlockPbType,
        VisionBlockType: ?RbVisionBlockPbType,
    } = null,
    CenterPosition: ?Vector = null,
    SizeX: i32 = 0,
    SizeY: i32 = 0,
    SizeZ: i32 = 0,
    Forward: ?Vector = null,
    Right: ?Vector = null,
    State: ?RbBlockPbState = null,
    GamePlayIncId: i32 = 0,
    OccupiedCellPositions: std.ArrayList(RbGridPosition) = .empty,
};
pub const RbDefaultBlockPbType = struct {
    pub const default: @This() = .{};
    IsMainControl: bool = false,
};
pub const RbVisionBlockPbType = struct {
    pub const default: @This() = .{};
};
pub const RbFloorComponentPb = struct {
    pub const default: @This() = .{};
    GamePlayIncId: i32 = 0,
    Type: i32 = 0,
    OccupiedCellPositions: std.ArrayList(RbGridPosition) = .empty,
};
pub const RbItemComponentPb = struct {
    pub const default: @This() = .{};
    Type: ?union(enum) {
        BreakableObstacleType: ?RbBreakableObstaclePbType,
        RbLaserEmitterType: ?RbLaserEmitterPbType,
    } = null,
    GamePlayIncId: i32 = 0,
    OccupiedCellPositions: std.ArrayList(RbGridPosition) = .empty,
};
pub const RbBreakableObstaclePbType = struct {
    pub const default: @This() = .{};
    LinkPoints: std.ArrayList(Vector) = .empty,
};
pub const RbLaserEmitterPbType = struct {
    pub const default: @This() = .{};
    LaserPoints: std.ArrayList(Vector) = .empty,
};
pub const SunSpiritTakeUpPb = struct {
    pub const default: @This() = .{};
    TrapEntityConfigId: i32 = 0,
    Index: i32 = 0,
};
pub const SunSpiritPb = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    EntityConfigId: i32 = 0,
    TakeUpData: ?SunSpiritTakeUpPb = null,
};
pub const SunSpiritGearComponentPb = struct {
    pub const default: @This() = .{};
    TakeUpInfo: std.ArrayList(SunSpiritPb) = .empty,
};
pub const VehicleSource = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    VehicleSourceNone = 0,
    VehicleSourceFishingShip = 1,
    VehicleSourceGongduolaSummon = 2,
};
pub const VehiclePb = struct {
    pub const default: @This() = .{};
    Source: ?VehicleSource = null,
};
pub const RoadNavMoveData = struct {
    pub const default: @This() = .{};
    DestRoadId: i32 = 0,
    DestIndex: i32 = 0,
    GenRoadId: i32 = 0,
    GenRoadIndex: i32 = 0,
};
pub const RoadNetworkComponentPb = struct {
    pub const default: @This() = .{};
    MoveData: ?union(enum) {
        NavMoveData: ?RoadNavMoveData,
    } = null,
    DestRoadId: i32 = 0,
    DestIndex: i32 = 0,
    GenRoadId: i32 = 0,
    GenRoadIndex: i32 = 0,
};
pub const ExhibitionComponentPb = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
};
pub const FurnitureComponentPb = struct {
    pub const default: @This() = .{};
    SlotId: i32 = 0,
    FurnitureId: i32 = 0,
};
pub const PinballKSCRolePbData = struct {
    pub const default: @This() = .{};
};
pub const VisionSkillInformation = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
    Level: i32 = 0,
    Quality: i32 = 0,
    VisionEntityId: i64 = 0,
    Index: i32 = 0,
};
pub const VisionSkillChangeNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    VisionSkillInfos: std.ArrayList(VisionSkillInformation) = .empty,
    PhantomSkillInfo: ?VisionSkillInformation = null,
};
pub const PartComponentPb = struct {
    pub const default: @This() = .{};
    PartLifeInfos: std.ArrayList(PartInformation) = .empty,
};
pub const PartComponentInitNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PartComponent: ?PartComponentPb = null,
};
pub const PartInformation = struct {
    pub const default: @This() = .{};
    PartIndex: i32 = 0,
    LifeValue: f32 = 0,
    LifeMax: f32 = 0,
    Activated: bool = false,
    PartTag: i32 = 0,
};
pub const PartUpdateInfo = struct {
    pub const default: @This() = .{};
    PartIndex: i32 = 0,
    Activated: bool = false,
    Reset: bool = false,
};
pub const PartUpdateRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PartUpdateInfos: std.ArrayList(PartUpdateInfo) = .empty,
};
pub const PartUpdatePush = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PartUpdateInfos: std.ArrayList(PartUpdateInfo) = .empty,
};
pub const PartUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PartUpdateNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PartInfos: std.ArrayList(PartInformation) = .empty,
};
pub const ApplyGEType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Common = 0,
    UseExtraTime = 1,
};
pub const ApplyGameplayEffectRequest = struct {
    pub const default: @This() = .{};
    Time: ?union(enum) {
        Duration: f32,
    } = null,
    Handle: i32 = 0,
    Id: i64 = 0,
    Level: i32 = 0,
    InstigatorId: i64 = 0,
    ApplyType: i32 = 0,
    ServerId: i32 = 0,
    StackCount: i32 = 0,
    IsActive: bool = false,
};
pub const ApplyGameplayEffectPush = struct {
    pub const default: @This() = .{};
    Time: ?union(enum) {
        Duration: f32,
    } = null,
    Handle: i32 = 0,
    Id: i64 = 0,
    Level: i32 = 0,
    InstigatorId: i64 = 0,
    ApplyType: i32 = 0,
    ServerId: i32 = 0,
    StackCount: i32 = 0,
    IsActive: bool = false,
    Reason: []const u8 = "",
    ConfBuffId: i64 = 0,
};
pub const ApplyGameplayEffectResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ApplyGameplayEffectNotify = struct {
    pub const default: @This() = .{};
    CRoundAction: ?union(enum) {
        Duration: f32,
    } = null,
    Time: ?union(enum) {
        LeftDuration: f32,
    } = null,
    Handle: i32 = 0,
    Id: i64 = 0,
    Level: i32 = 0,
    EntityId: i64 = 0,
    InstigatorId: i64 = 0,
    ApplyType: i32 = 0,
    IsActive: bool = false,
    ServerId: i32 = 0,
    StackCount: i32 = 0,
    ConfBuffId: i64 = 0,
};
pub const RemoveGameplayEffectRequest = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    EntityId: i64 = 0,
    IsPrematureRemoval: bool = false,
};
pub const RemoveGameplayEffectPush = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    EntityId: i64 = 0,
    IsPrematureRemoval: bool = false,
    Reason: []const u8 = "",
    InstigatorId: i64 = 0,
};
pub const RemoveGameplayEffectResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Handle: i32 = 0,
};
pub const RemoveGameplayEffectNotify = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    EntityId: i64 = 0,
    InstigatorId: i64 = 0,
};
pub const OrderApplyBuffRequest = struct {
    pub const default: @This() = .{};
    Time: ?union(enum) {
        Duration: f32,
    } = null,
    Id: i64 = 0,
    Level: i32 = 0,
    InstigatorId: i64 = 0,
    ApplyType: i32 = 0,
    ServerId: i32 = 0,
    StackCount: i32 = 0,
    IsIterable: bool = false,
    TransferContextId: ?TransferContextId = null,
    Reason: []const u8 = "",
};
pub const OrderApplyBuffResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const OrderRemoveBuffRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    StackCount: i32 = 0,
    Reason: []const u8 = "",
    InstigatorId: i64 = 0,
};
pub const OrderRemoveBuffResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const OrderApplyBuffNotify = struct {
    pub const default: @This() = .{};
    Time: ?union(enum) {
        Duration: f32,
    } = null,
    Id: i64 = 0,
    Level: i32 = 0,
    InstigatorId: i64 = 0,
    ApplyType: i32 = 0,
    ServerId: i32 = 0,
    StackCount: i32 = 0,
    IsIterable: bool = false,
};
pub const OrderRemoveBuffNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    StackCount: i32 = 0,
};
pub const ApplyBuffS2cRequestNotify = struct {
    pub const default: @This() = .{};
    Time: ?union(enum) {
        Duration: f32,
    } = null,
    Id: i64 = 0,
    Level: i32 = 0,
    InstigatorId: i64 = 0,
    ApplyType: i32 = 0,
    ServerId: i32 = 0,
    StackCount: i32 = 0,
    IsIterable: bool = false,
    Reason: i32 = 0,
};
pub const ApplyBuffS2cResponsePush = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Handle: i32 = 0,
    IsActive: bool = false,
};
pub const RemoveBuffS2cRequestNotify = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    StackCount: i32 = 0,
    Reason: i32 = 0,
    InstigatorId: i64 = 0,
};
pub const RemoveBuffS2cResponsePush = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RemoveBuffByIdS2cRequestNotify = struct {
    pub const default: @This() = .{};
    BuffId: i64 = 0,
    StackCount: i32 = 0,
    Reason: i32 = 0,
    InstigatorId: i64 = 0,
};
pub const RemoveBuffByIdS2cResponsePush = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const BroadcastAddBuffFailedNotify = struct {
    pub const default: @This() = .{};
    BuffId: i64 = 0,
    StackCount: i32 = 0,
    InstigatorId: i64 = 0,
    TransferContextId: ?TransferContextId = null,
};
pub const ActivateBuffRequest = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    On: bool = false,
};
pub const ActiveBuffPush = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    On: bool = false,
};
pub const ActivateBuffResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ActivateBuffNotify = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    On: bool = false,
};
pub const OrderRemoveBuffByTagsRequest = struct {
    pub const default: @This() = .{};
    TagIds: std.ArrayList(i32) = .empty,
    InstigatorId: i64 = 0,
};
pub const OrderRemoveBuffByTagsResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const OrderRemoveBuffByTagsNotify = struct {
    pub const default: @This() = .{};
    TagIds: std.ArrayList(i32) = .empty,
    InstigatorId: i64 = 0,
};
pub const AttributeEventEffectData = struct {
    pub const default: @This() = .{};
    TriggeredActiveHandles: std.ArrayList(i32) = .empty,
};
pub const FightBuffEffectContext = struct {
    pub const default: @This() = .{};
    dRoundAction: ?union(enum) {
        LeftCooldown: f32,
    } = null,
    Effect: ?union(enum) {
        AttributeEventEffectData: ?AttributeEventEffectData,
    } = null,
};
pub const BuffStackCountRequest = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    NewStackCount: i32 = 0,
    IsPrematureRemoval: bool = false,
    InstigatorId: i64 = 0,
};
pub const BuffStackCountPush = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    NewStackCount: i32 = 0,
    IsPrematureRemoval: bool = false,
    InstigatorId: i64 = 0,
    NotRefreshDuration: bool = false,
    NotRefreshPeriod: bool = false,
    Duration: f32 = 0,
    Reason: []const u8 = "",
};
pub const BuffStackCountResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const BuffStackCountNotify = struct {
    pub const default: @This() = .{};
    Time: ?union(enum) {
        Duration: f32,
    } = null,
    gFs: ?union(enum) {
        LeftDuration: f32,
    } = null,
    HandleId: i32 = 0,
    NewStackCount: i32 = 0,
    InstigatorId: i64 = 0,
    NotRefreshDuration: bool = false,
    NotRefreshPeriod: bool = false,
};
pub const BuffEffectCd = struct {
    pub const default: @This() = .{};
    BuffId: i64 = 0,
    ListCdRemaining: std.ArrayList(i32) = .empty,
};
pub const BuffEffectRequest = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    Index: i32 = 0,
};
pub const BuffEffectPush = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    Index: i32 = 0,
};
pub const BuffEffectResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const BuffDurationNotify = struct {
    pub const default: @This() = .{};
    Time: ?union(enum) {
        Duration: f32,
    } = null,
    gFs: ?union(enum) {
        LeftDuration: f32,
    } = null,
    HandleId: i32 = 0,
};
pub const RefreshBuffDurationPush = struct {
    pub const default: @This() = .{};
    BuffIds: std.ArrayList(i64) = .empty,
};
pub const BuffEffectExecutePush = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    Index: i32 = 0,
};
pub const RemoveBuffByServerIdS2cRequestNotify = struct {
    pub const default: @This() = .{};
    ServerId: i32 = 0,
    StackCount: i32 = 0,
    Reason: i32 = 0,
    InstigatorId: i64 = 0,
};
pub const ChangeStateRequest = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    FromState: i32 = 0,
    ToState: i32 = 0,
};
pub const ChangeStateResponse = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    Error: ?DErrorResult = null,
    CurrentState: i32 = 0,
};
pub const ChangeStateNotify = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    FromState: i32 = 0,
    ToState: i32 = 0,
};
pub const ChangeStateConfirmRequest = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
};
pub const ChangeStateConfirmPush = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
};
pub const ChangeStateConfirmResponse = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
    Error: ?DErrorResult = null,
};
pub const ChangeStateConfirmNotify = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
};
pub const DFsm = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    CurrentState: i32 = 0,
    Flag: i32 = 0,
    StateElapseTime: i32 = 0,
};
pub const EntityFsmComponentPb = struct {
    pub const default: @This() = .{};
    Fsms: std.ArrayList(DFsm) = .empty,
    HashCode: i32 = 0,
    CommonHashCode: i32 = 0,
    BlackBoard: std.ArrayList(DFsmBlackBoard) = .empty,
    FsmCustomBlackboardDatas: ?FsmCustomBlackboardDatas = null,
};
pub const FsmConditionPassRequest = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    FromState: i32 = 0,
    ToState: i32 = 0,
    ConditionIndex: i32 = 0,
    Value: bool = false,
};
pub const FsmConditionPassResponse = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    Error: ?DErrorResult = null,
};
pub const FsmConditionPassPush = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    FromState: i32 = 0,
    ToState: i32 = 0,
    ConditionIndex: i32 = 0,
    Value: bool = false,
};
pub const FsmResetNotify = struct {
    pub const default: @This() = .{};
    EntityFsmComponentPb: ?EntityFsmComponentPb = null,
};
pub const FsmBlackboardNotify = struct {
    pub const default: @This() = .{};
    FsmBlackBoards: std.ArrayList(DFsmBlackBoard) = .empty,
};
pub const FsmCustomBlackboardDatas = struct {
    pub const default: @This() = .{};
    BlackboardIntValues: std.ArrayList(DFsmBlackboardCustom) = .empty,
};
pub const FsmCustomBlackboardNotify = struct {
    pub const default: @This() = .{};
    FsmCustomBlackboardDatas: ?FsmCustomBlackboardDatas = null,
};
pub const DFsmBlackBoard = struct {
    pub const default: @This() = .{};
    Key: i32 = 0,
    Value: i32 = 0,
};
pub const DFsmBlackboardCustom = struct {
    pub const default: @This() = .{};
    Key: []const u8 = "",
    Value: i32 = 0,
};
pub const FsmStateBehaviorType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Enter = 0,
    Exit = 1,
    BindStart = 2,
    BindEnd = 3,
    Task = 4,
};
pub const FsmStateBehaviorRequest = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
    Index: i32 = 0,
    Type: ?FsmStateBehaviorType = null,
};
pub const FsmStateBehaviorResponse = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const FsmPlayMontageRequest = struct {
    pub const default: @This() = .{};
    MontageName: []const u8 = "",
    MontagePathHash: i32 = 0,
    SpeedRatio: f32 = 0,
    StartSection: []const u8 = "",
    StartTimeSeconds: f32 = 0,
};
pub const FsmPlayMontagePush = struct {
    pub const default: @This() = .{};
    MontageName: []const u8 = "",
    MontagePathHash: i32 = 0,
    SpeedRatio: f32 = 0,
    StartSection: []const u8 = "",
    StartTimeSeconds: f32 = 0,
};
pub const FsmPlayMontageResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FsmMontageDurationNotify = struct {
    pub const default: @This() = .{};
    MontageHashCode: i32 = 0,
    DurationTime: i32 = 0,
};
pub const BoardGridDynamicConfig = struct {
    pub const default: @This() = .{};
    RowIndex: i32 = 0,
    ColumnIndex: i32 = 0,
    Flags: i64 = 0,
};
pub const PlacementItemPb = struct {
    pub const default: @This() = .{};
    LocatedBoardEntityConfigId: i32 = 0,
};
pub const BoardGridPositionInfo = struct {
    pub const default: @This() = .{};
    Row: i32 = 0,
    Column: i32 = 0,
    RotAngle: i32 = 0,
};
pub const OccupiedBoardGridInfo = struct {
    pub const default: @This() = .{};
    Pos: ?BoardGridPositionInfo = null,
    OccupyingEntityConfigId: i32 = 0,
    EntityConfigType: i32 = 0,
};
pub const JigsawBaseComponentPb = struct {
    pub const default: @This() = .{};
    MoveCount: i32 = 0,
    EntityId: i32 = 0,
    Winner: i32 = 0,
};
pub const ESummonType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ESummonTypeDefault = 0,
    ESummonTypeConcomitantVision = 1,
    ESummonTypeConcomitantCustom = 2,
    ESummonTypeConcomitantPhantomRole = 3,
    ESummonTypeConcomitantWeakVision = 4,
    ESummonTypeConcomitantMotorcycle = 5,
};
pub const SummonerComponentPb = struct {
    pub const default: @This() = .{};
    SummonerId: i64 = 0,
    SummonCfgId: i32 = 0,
    SummonSkillId: i32 = 0,
    PlayerId: i32 = 0,
    Type: ?ESummonType = null,
};
pub const SummonsComponentPb = struct {
    pub const default: @This() = .{};
    Version: i32 = 0,
};
pub const FollowerType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    EPlayerFollowerDefault = 0,
    EPlayerFollowerExploreSkill = 1,
    EPlayerFollowerAuxiliary = 2,
    EPlayerFollowerSpecialItem = 3,
    EPlayerFollowerMotor = 4,
    EPlayerFollowerMax = 5,
};
pub const FollowerList = struct {
    pub const default: @This() = .{};
    Type: ?FollowerType = null,
    EntityId: i64 = 0,
};
pub const FollowerComponentPb = struct {
    pub const default: @This() = .{};
    FollowerList: std.ArrayList(FollowerList) = .empty,
};
pub const FollowShooterComponentPb = struct {
    pub const default: @This() = .{};
    PlayerEntityId: i64 = 0,
    SummonConfigId: i32 = 0,
};
pub const CharacterAttachInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
    PartIndex: i32 = 0,
};
pub const SceneItemBBKey = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ManipulatableState = 0,
};
pub const SceneItemBlackboardParam = struct {
    pub const default: @This() = .{};
    Value: ?union(enum) {
        IntValue: i32,
        IntValues: ?IntArrayBlackboard,
        LongValue: i64,
        LongValues: ?LongArrayBlackboard,
        BooleanValue: bool,
        StringValue: []const u8,
        FloatValue: f32,
        FloatValues: ?FloatArrayBlackboard,
        VectorValue: ?Vector,
        RotatorValue: ?Rotator,
    } = null,
    Key: ?SceneItemBBKey = null,
};
pub const HackingComponentPb = struct {
    pub const default: @This() = .{};
    EntityIds: std.ArrayList(i64) = .empty,
};
pub const HackTargetComponentPb = struct {
    pub const default: @This() = .{};
    HackTargetEntityId: i64 = 0,
};
pub const GravityFlipComponent = struct {
    pub const default: @This() = .{};
    Direction: ?DirectionType = null,
};
pub const DirectionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    GravityUp = 0,
    GravityDown = 1,
    GravityLeft = 2,
    GravityRight = 3,
};
pub const EntityRewardItemPb = struct {
    pub const default: @This() = .{};
    HasCount: i32 = 0,
    NextResetTime: i64 = 0,
};
pub const RbBlockPbState = struct {
    pub const default: @This() = .{};
    State: ?union(enum) {
        MovingState: ?RbBlockMovingPbState,
        IdleState: ?RbBlockIdlePbState,
    } = null,
};
pub const RbBlockMovingPbState = struct {
    pub const default: @This() = .{};
    Action: ?RbBlockMovementPbAction = null,
};
pub const RbBlockIdlePbState = struct {
    pub const default: @This() = .{};
    Position: ?Vector = null,
    Rotation: ?Vector = null,
};
pub const RbBlockMovementPbAction = struct {
    pub const default: @This() = .{};
    Type: ?union(enum) {
        Roll: ?RbRollMovement,
        Jump: ?RbJumpMovement,
    } = null,
};
pub const RbGridDirection = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    RbForward = 0,
    RbBackward = 1,
    RbRight = 2,
    RbLeft = 3,
};
pub const RbRollMovement = struct {
    pub const default: @This() = .{};
    Direction: ?RbGridDirection = null,
};
pub const RbJumpMovement = struct {
    pub const default: @This() = .{};
    Direction: ?RbGridDirection = null,
};
pub const MotorDiyInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const MotorDiyInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MotorDiy: ?MotorDiyPb = null,
};
pub const MotorUseSkinRequest = struct {
    pub const default: @This() = .{};
    SkinId: i32 = 0,
};
pub const MotorUseSkinResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MotorChangeOutlookRequest = struct {
    pub const default: @This() = .{};
    StickerEquipped: std.ArrayList(i32) = .empty,
    DecorationsEquipped: std.ArrayList(i32) = .empty,
    FrameEquipped: i32 = 0,
};
pub const MotorChangeOutlookResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MotorOutlookCreatePresetRequest = struct {
    pub const default: @This() = .{};
    Preset: ?MotorDiyEquippedPb = null,
    name: []const u8 = "",
};
pub const MotorOutlookCreatePresetResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: i32 = 0,
    MotorOutlookPreset: ?MotorOutlookPlayerPresetPb = null,
};
pub const MotorOutlookDeletePresetRequest = struct {
    pub const default: @This() = .{};
    id: i32 = 0,
};
pub const MotorOutlookDeletePresetResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: i32 = 0,
    MotorOutlookPreset: ?MotorOutlookPlayerPresetPb = null,
};
pub const MotorOutlookEditPresetRequest = struct {
    pub const default: @This() = .{};
    PresetPlan: ?MotorOutlookPresetPlanPb = null,
};
pub const MotorOutlookEditPresetResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: i32 = 0,
    MotorOutlookPreset: ?MotorOutlookPlayerPresetPb = null,
};
pub const MotorOutlookEquippedChangeNotify = struct {
    pub const default: @This() = .{};
    MotorDiyEquipped: ?MotorDiyEquippedPb = null,
    LatestMotorSkinSuit: std.ArrayList(MotorDiyEquippedPb) = .empty,
};
pub const EntityMotorOutlookChangeNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    MotorDiyEquipped: ?MotorDiyEquippedPb = null,
};
pub const MotorOutlookRegionInfoNotify = struct {
    pub const default: @This() = .{};
    MotorOutlookRegion: ?MotorOutlookRegionPb = null,
};
pub const MotorDiyEquippedPb = struct {
    pub const default: @This() = .{};
    SkinEquipped: i32 = 0,
    StickerEquipped: std.ArrayList(i32) = .empty,
    DecorationsEquipped: std.ArrayList(i32) = .empty,
    FrameEquipped: i32 = 0,
};
pub const MotorDiyOnwedPb = struct {
    pub const default: @This() = .{};
    SkinOwned: std.ArrayList(i32) = .empty,
    StickerOnwed: std.ArrayList(i32) = .empty,
    DecorationsOwned: std.ArrayList(i32) = .empty,
    FrameOwned: std.ArrayList(i32) = .empty,
};
pub const MotorOutlookRegionPb = struct {
    pub const default: @This() = .{};
    MotorSticker: std.ArrayList(MotorOutlookIdTimePairPb) = .empty,
    MotorDecoration: std.ArrayList(MotorOutlookIdTimePairPb) = .empty,
    MotorFrame: std.ArrayList(MotorOutlookIdTimePairPb) = .empty,
    MotorStickerId: std.ArrayList(i32) = .empty,
    MotorDecorationId: std.ArrayList(i32) = .empty,
    MotorFrameId: std.ArrayList(i32) = .empty,
};
pub const MotorOutlookIdTimePairPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    OpenTime: i64 = 0,
};
pub const MotorOutlookPlayerPresetPb = struct {
    pub const default: @This() = .{};
    Plan: std.ArrayList(MotorOutlookPresetPlanPb) = .empty,
};
pub const MotorOutlookPresetPlanPb = struct {
    pub const default: @This() = .{};
    Preset: ?MotorDiyEquippedPb = null,
    Mame: []const u8 = "",
    Id: i32 = 0,
};
pub const MotorDiyPb = struct {
    pub const default: @This() = .{};
    MotorDiyOnwer: ?MotorDiyOnwedPb = null,
    MotorDiyEquipped: ?MotorDiyEquippedPb = null,
    MotorOutlookPreset: ?MotorOutlookPlayerPresetPb = null,
    LatestMotorSkinSuit: std.ArrayList(MotorDiyEquippedPb) = .empty,
    SceneInUse: i32 = 0,
};
pub const BirthRoleSelect = struct {
    pub const default: @This() = .{};
    Year: i32 = 0,
    Role: i32 = 0,
};
pub const BirthdayInfoUpdateNotify = struct {
    pub const default: @This() = .{};
    BirthDayReset: bool = false,
    RecentRewardTime: i32 = 0,
    Roles: std.ArrayList(BirthRoleSelect) = .empty,
};
pub const BuffItem = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    CdTime: i64 = 0,
};
pub const EquipBuffItem = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Equiped: bool = false,
};
pub const BuffItemNotify = struct {
    pub const default: @This() = .{};
    ItemBuffList: std.ArrayList(BuffItem) = .empty,
    EquipItemList: std.ArrayList(EquipBuffItem) = .empty,
};
pub const ButtonType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Home = 0,
};
pub const ButtonEnableResult = struct {
    pub const default: @This() = .{};
    Type: ?ButtonType = null,
    Enabled: bool = false,
};
pub const BtnStateRequest = struct {
    pub const default: @This() = .{};
    Type: ?ButtonType = null,
    Types: std.ArrayList(ButtonType) = .empty,
};
pub const BtnStateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Type: ?ButtonType = null,
    Enabled: bool = false,
    Result: std.ArrayList(ButtonEnableResult) = .empty,
};
pub const CalabashDevelopConditionState = struct {
    pub const default: @This() = .{};
    ConditionId: i32 = 0,
    Rewarded: bool = false,
};
pub const CalabashDevelopInfo = struct {
    pub const default: @This() = .{};
    MonsterId: i32 = 0,
    UnlockConditions: std.ArrayList(CalabashDevelopConditionState) = .empty,
};
pub const CalabashMsg = struct {
    pub const default: @This() = .{};
    Level: i32 = 0,
    Exp: i32 = 0,
    UnlockedLevels: std.ArrayList(i32) = .empty,
    UnlockedDevelopRewards: std.ArrayList(CalabashDevelopInfo) = .empty,
    IdentifyGuaranteeCount: i32 = 0,
    LowCostGuaranteeCount: i32 = 0,
};
pub const CalabashCfg = struct {
    pub const default: @This() = .{};
    LevelUpExp: i32 = 0,
    LevelUpCondition: i32 = 0,
    CatchGain: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const CalabashMsgNotify = struct {
    pub const default: @This() = .{};
    CalabashMsg: ?CalabashMsg = null,
    CalabashCfg: ?CalabashCfg = null,
};
pub const CalabashLevelsRewardNotify = struct {
    pub const default: @This() = .{};
    RewardedLevels: std.ArrayList(i32) = .empty,
};
pub const CalabashLevelRewardRequest = struct {
    pub const default: @This() = .{};
    Level: i32 = 0,
};
pub const CalabashLevelRewardResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CalabashSkinDataRequest = struct {
    pub const default: @This() = .{};
};
pub const CalabashSkinDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipedSkinId: i32 = 0,
    SkinIdList: std.ArrayList(i32) = .empty,
};
pub const CalabashSkinTakeOnRequest = struct {
    pub const default: @This() = .{};
    SkinId: i32 = 0,
};
pub const CalabashSkinTakeOnResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SkinId: i32 = 0,
};
pub const ChatContentType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Text = 0,
    Emoji = 1,
};
pub const PrivateChatRequest = struct {
    pub const default: @This() = .{};
    TargetUid: i32 = 0,
    ChatContentType: ?ChatContentType = null,
    Content: []const u8 = "",
    XboxBlockedPlayerIds: std.ArrayList(i32) = .empty,
};
pub const PrivateChatResponse = struct {
    pub const default: @This() = .{};
    TargetUid: i32 = 0,
    ErrorCode: ?ErrorCode = null,
    MsgId: []const u8 = "",
    FilterMsg: []const u8 = "",
    BanEndTime: i64 = 0,
};
pub const ChatContentProto = struct {
    pub const default: @This() = .{};
    SenderUid: i32 = 0,
    ChatContentType: ?ChatContentType = null,
    Content: []const u8 = "",
    OfflineMsg: bool = false,
    UtcTime: i64 = 0,
    MsgId: []const u8 = "",
    PsAccountId: []const u8 = "",
    XboxAccountId: []const u8 = "",
};
pub const PrivateMessageNotify = struct {
    pub const default: @This() = .{};
    ChatContent: ?ChatContentProto = null,
};
pub const PrivateChatHistoryRequest = struct {
    pub const default: @This() = .{};
    TargetUid: i32 = 0,
    StartIndex: i32 = 0,
};
pub const PrivateChatHistoryResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Data: ?PrivateChatHistoryContentProto = null,
};
pub const PrivateChatHistoryContentProto = struct {
    pub const default: @This() = .{};
    TargetUid: i32 = 0,
    Chats: std.ArrayList(ChatContentProto) = .empty,
    HistoryIsEnd: bool = false,
    TotalNums: i32 = 0,
};
pub const PrivateChatHistoryNotify = struct {
    pub const default: @This() = .{};
    AllChats: std.ArrayList(PrivateChatHistoryContentProto) = .empty,
};
pub const PrivateChatDataRequest = struct {
    pub const default: @This() = .{};
};
pub const PrivateChatDataResponse = struct {
    pub const default: @This() = .{};
    LoadSucc: bool = false,
};
pub const PrivateChatOperateType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    CloseChat = 0,
    OpenChat = 1,
    ReadMsg = 2,
};
pub const PrivateChatOperateRequest = struct {
    pub const default: @This() = .{};
    OperateType: ?PrivateChatOperateType = null,
    TargetPlayerId: i32 = 0,
};
pub const PrivateChatOperateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RewardType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    TaskReward = 0,
    SignReward = 2,
    ScoreReward = 3,
};
pub const CombatPushData = struct {
    pub const default: @This() = .{};
    Message: ?union(enum) {
        ApplyBuffS2cResponsePush: ?ApplyBuffS2cResponsePush,
        RemoveBuffS2cResponsePush: ?RemoveBuffS2cResponsePush,
        RemoveBuffByIdS2cResponsePush: ?RemoveBuffByIdS2cResponsePush,
        CreateBulletResponsePush: ?CreateBulletResponsePush,
        DestroyBulletResponsePush: ?DestroyBulletResponsePush,
        ApplyGameplayEffectPush: ?ApplyGameplayEffectPush,
        RemoveGameplayEffectPush: ?RemoveGameplayEffectPush,
        HitEndPush: ?HitEndPush,
        EndSkillPush: ?EndSkillPush,
        PartUpdatePush: ?PartUpdatePush,
        MaterialPush: ?MaterialPush,
        GameplayCuePush: ?GameplayCuePush,
        EntityIsVisiblePush: ?EntityIsVisiblePush,
        SwitchCharacterStatePush: ?SwitchCharacterStatePush,
        LogicStateInitPush: ?LogicStateInitPush,
        SwitchLogicStatePush: ?SwitchLogicStatePush,
        AnimationStateChangedPush: ?AnimationStateChangedPush,
        AnimationStateInitPush: ?AnimationStateInitPush,
        ModifyBulletParamsPush: ?ModifyBulletParamsPush,
        DrownPush: ?DrownPush,
        ActiveBuffPush: ?ActiveBuffPush,
        AiInformationPush: ?AiInformationPush,
        ToughCalcExtraRatioChangePush: ?ToughCalcExtraRatioChangePush,
        BattleStateChangePush: ?BattleStateChangePush,
        AnimationGameplayTagPush: ?AnimationGameplayTagPush,
        BoneVisibleChangePush: ?BoneVisibleChangePush,
        AiBlackboardsPush: ?AiBlackboardsPush,
        AiBlackboardCdPush: ?AiBlackboardCdPush,
        AiHatePush: ?AiHatePush,
        MonsterBoomPush: ?MonsterBoomPush,
        CaughtPush: ?CaughtPush,
        EntityStaticHookMovePush: ?EntityStaticHookMovePush,
        ChangeStateConfirmPush: ?ChangeStateConfirmPush,
        BuffStackCountPush: ?BuffStackCountPush,
        ANStartPush: ?ANStartPush,
        UseSkillFailPush: ?UseSkillFailPush,
        EnterViewDirectionPush: ?EnterViewDirectionPush,
        ExitViewDirectionPush: ?ExitViewDirectionPush,
        PassiveSkillAddPush: ?PassiveSkillAddPush,
        InterruptSkillInDelayPush: ?InterruptSkillInDelayPush,
        TriggerExitSkillPush: ?TriggerExitSkillPush,
        ActorVisiblePush: ?ActorVisiblePush,
        BuffEffectPush: ?BuffEffectPush,
        RTimeStopPush: ?RTimeStopPush,
        DrownEndTeleportPush: ?DrownEndTeleportPush,
        MonsterDrownPush: ?MonsterDrownPush,
        PassiveSkillRemovePush: ?PassiveSkillRemovePush,
        RTimeStopInstPush: ?RTimeStopInstPush,
        FsmPlayMontagePush: ?FsmPlayMontagePush,
        TsAnimNotifyStateAbsoluteTimeStopPush: ?TsAnimNotifyStateAbsoluteTimeStopPush,
        RoleTagChangePush: ?RoleTagChangePush,
        ExecuteQtePush: ?ExecuteQtePush,
        ClientCurrentRoleReportPush: ?ClientCurrentRoleReportPush,
        MontagePlayPush: ?MontagePlayPush,
        CounterAttackPush: ?CounterAttackPush,
        NewLinkBurstPush: ?NewLinkBurstPush,
        RefreshBuffDurationPush: ?RefreshBuffDurationPush,
        RoleGoDownPush: ?RoleGoDownPush,
        FsmConditionPassPush: ?FsmConditionPassPush,
        BuffEffectExecutePush: ?BuffEffectExecutePush,
        VisionTriggerPush: ?VisionTriggerPush,
        MotorIsEnablePush: ?MotorIsEnablePush,
        MotorSummonAndRidePush: ?MotorSummonAndRidePush,
        BulletPatternPush: ?BulletPatternPush,
        QuickHackRamVerifyPush: ?QuickHackRamVerifyPush,
        QuickHackOpenPush: ?QuickHackOpenPush,
        DodgeInfoPush: ?DodgeInfoPush,
    } = null,
    CombatCommon: ?CombatCommon = null,
};
pub const CombatNotifyData = struct {
    pub const default: @This() = .{};
    Message: ?union(enum) {
        CreateBulletNotify: ?CreateBulletNotify,
        DestroyBulletNotify: ?DestroyBulletNotify,
        DamageExecuteNotify: ?DamageExecuteNotify,
        ApplyGameplayEffectNotify: ?ApplyGameplayEffectNotify,
        RemoveGameplayEffectNotify: ?RemoveGameplayEffectNotify,
        HitNotify: ?HitNotify,
        SkillNotify: ?SkillNotify,
        UseSkillNotify: ?UseSkillNotify,
        EndSkillNotify: ?EndSkillNotify,
        EntityLoadCompleteNotify: ?EntityLoadCompleteNotify,
        PartUpdateNotify: ?PartUpdateNotify,
        PartComponentInitNotify: ?PartComponentInitNotify,
        MaterialNotify: ?MaterialNotify,
        GameplayCueNotify: ?GameplayCueNotify,
        EntityIsVisibleNotify: ?EntityIsVisibleNotify,
        SwitchCharacterStateNotify: ?SwitchCharacterStateNotify,
        PlayerRebackSceneNotify: ?PlayerRebackSceneNotify,
        LogicStateInitNotify: ?LogicStateInitNotify,
        SwitchLogicStateNotify: ?SwitchLogicStateNotify,
        AttributeChangedNotify: ?AttributeChangedNotify,
        AnimationStateChangedNotify: ?AnimationStateChangedNotify,
        AnimationStateInitNotify: ?AnimationStateInitNotify,
        ModifyBulletParamsNotify: ?ModifyBulletParamsNotify,
        DrownNotify: ?DrownNotify,
        OrderApplyBuffNotify: ?OrderApplyBuffNotify,
        OrderRemoveBuffNotify: ?OrderRemoveBuffNotify,
        ActivateBuffNotify: ?ActivateBuffNotify,
        OrderRemoveBuffByTagsNotify: ?OrderRemoveBuffByTagsNotify,
        AiInformationNotify: ?AiInformationNotify,
        BattleStateChangeNotify: ?BattleStateChangeNotify,
        AnimationGameplayTagNotify: ?AnimationGameplayTagNotify,
        BoneVisibleChangeNotify: ?BoneVisibleChangeNotify,
        AiBlackboardCdNotify: ?AiBlackboardCdNotify,
        CaughtNotify: ?CaughtNotify,
        EntityStaticHookMoveNotify: ?EntityStaticHookMoveNotify,
        ChangeStateNotify: ?ChangeStateNotify,
        ChangeStateConfirmNotify: ?ChangeStateConfirmNotify,
        BuffStackCountNotify: ?BuffStackCountNotify,
        MontagePlayNotify: ?MontagePlayNotify,
        ANStartNotify: ?ANStartNotify,
        FsmResetNotify: ?FsmResetNotify,
        DamageRecordNotify: ?DamageRecordNotify,
        AiHateNotify: ?AiHateNotify,
        FsmBlackboardNotify: ?FsmBlackboardNotify,
        CharacterBattleStateChangeNotify: ?CharacterBattleStateChangeNotify,
        ApplyBuffS2cRequestNotify: ?ApplyBuffS2cRequestNotify,
        RemoveBuffS2cRequestNotify: ?RemoveBuffS2cRequestNotify,
        ActorVisibleNotify: ?ActorVisibleNotify,
        RecoverPropChangedNotify: ?RecoverPropChangedNotify,
        RemoveBuffByIdS2cRequestNotify: ?RemoveBuffByIdS2cRequestNotify,
        ShieldUpdateNotify: ?ShieldUpdateNotify,
        PlayerBattleStateChangeNotify: ?PlayerBattleStateChangeNotify,
        FsmCustomBlackboardNotify: ?FsmCustomBlackboardNotify,
        PassiveSkillAddNotify: ?PassiveSkillAddNotify,
        PassiveSkillRemoveNotify: ?PassiveSkillRemoveNotify,
        ExecuteQteNotify: ?ExecuteQteNotify,
        ModifyEntityCampNotify: ?ModifyEntityCampNotify,
        AddCombineEntitiesRelationNotify: ?AddCombineEntitiesRelationNotify,
        RemoveCombineRelationNotify: ?RemoveCombineRelationNotify,
        TestDamageRecordNotify: ?TestDamageRecordNotify,
        BuffDurationNotify: ?BuffDurationNotify,
        EntityLivingStatusNotify: ?EntityLivingStatusNotify,
        NewLinkStateNotify: ?NewLinkStateNotify,
        BroadcastAddBuffFailedNotify: ?BroadcastAddBuffFailedNotify,
        PackAnimChangedNotify: ?PackAnimChangedNotify,
        VisionTriggerNotify: ?VisionTriggerNotify,
        RemoveBuffByServerIdS2cRequestNotify: ?RemoveBuffByServerIdS2cRequestNotify,
        TransformBuffStackNotify: ?TransformBuffStackNotify,
        MotorSummonAndRideNotify: ?MotorSummonAndRideNotify,
        BulletPatternNotify: ?BulletPatternNotify,
        FsmMontageDurationNotify: ?FsmMontageDurationNotify,
        CombatDataMaxNotify: ?CombatDataMaxNotify,
    } = null,
    CombatCommon: ?CombatCommon = null,
};
pub const CombatDataMaxNotify = struct {
    pub const default: @This() = .{};
};
pub const CombatRequestData = struct {
    pub const default: @This() = .{};
    Message: ?union(enum) {
        CreateBulletRequest: ?CreateBulletRequest,
        DestroyBulletRequest: ?DestroyBulletRequest,
        DamageExecuteRequest: ?DamageExecuteRequest,
        ApplyGameplayEffectRequest: ?ApplyGameplayEffectRequest,
        RemoveGameplayEffectRequest: ?RemoveGameplayEffectRequest,
        HitRequest: ?HitRequest,
        HitEndRequest: ?HitEndRequest,
        SkillRequest: ?SkillRequest,
        UseSkillRequest: ?UseSkillRequest,
        EndSkillRequest: ?EndSkillRequest,
        PartUpdateRequest: ?PartUpdateRequest,
        MaterialRequest: ?MaterialRequest,
        GameplayCueRequest: ?GameplayCueRequest,
        EntityIsVisibleRequest: ?EntityIsVisibleRequest,
        SwitchCharacterStateRequest: ?SwitchCharacterStateRequest,
        LogicStateInitRequest: ?LogicStateInitRequest,
        SwitchLogicStateRequest: ?SwitchLogicStateRequest,
        AnimationStateChangedRequest: ?AnimationStateChangedRequest,
        AnimationStateInitRequest: ?AnimationStateInitRequest,
        ModifyBulletParamsRequest: ?ModifyBulletParamsRequest,
        DrownRequest: ?DrownRequest,
        OrderApplyBuffRequest: ?OrderApplyBuffRequest,
        OrderRemoveBuffRequest: ?OrderRemoveBuffRequest,
        ActivateBuffRequest: ?ActivateBuffRequest,
        OrderRemoveBuffByTagsRequest: ?OrderRemoveBuffByTagsRequest,
        AiInformationRequest: ?AiInformationRequest,
        ToughCalcExtraRatioChangeRequest: ?ToughCalcExtraRatioChangeRequest,
        BattleStateChangeRequest: ?BattleStateChangeRequest,
        AnimationGameplayTagRequest: ?AnimationGameplayTagRequest,
        BoneVisibleChangeRequest: ?BoneVisibleChangeRequest,
        AiBlackboardsRequest: ?AiBlackboardsRequest,
        AiBlackboardCdRequest: ?AiBlackboardCdRequest,
        AiHateRequest: ?AiHateRequest,
        MonsterBoomRequest: ?MonsterBoomRequest,
        CaughtRequest: ?CaughtRequest,
        EntityStaticHookMoveRequest: ?EntityStaticHookMoveRequest,
        ChangeStateRequest: ?ChangeStateRequest,
        ChangeStateConfirmRequest: ?ChangeStateConfirmRequest,
        FsmConditionPassRequest: ?FsmConditionPassRequest,
        BuffStackCountRequest: ?BuffStackCountRequest,
        ANStartRequest: ?ANStartRequest,
        UseSkillFailRequest: ?UseSkillFailRequest,
        EnterViewDirectionRequest: ?EnterViewDirectionRequest,
        ExitViewDirectionRequest: ?ExitViewDirectionRequest,
        PassiveSkillAddRequest: ?PassiveSkillAddRequest,
        InterruptSkillInDelayRequest: ?InterruptSkillInDelayRequest,
        TriggerExitSkillRequest: ?TriggerExitSkillRequest,
        ActorVisibleRequest: ?ActorVisibleRequest,
        BuffEffectRequest: ?BuffEffectRequest,
        FragileChangeRequest: ?FragileChangeRequest,
        RTimeStopRequest: ?RTimeStopRequest,
        DrownEndTeleportRequest: ?DrownEndTeleportRequest,
        MonsterDrownRequest: ?MonsterDrownRequest,
        PassiveSkillRemoveRequest: ?PassiveSkillRemoveRequest,
        RTimeStopInstRequest: ?RTimeStopInstRequest,
        FsmStateBehaviorRequest: ?FsmStateBehaviorRequest,
        FsmPlayMontageRequest: ?FsmPlayMontageRequest,
        TsAnimNotifyStateAbsoluteTimeStopRequest: ?TsAnimNotifyStateAbsoluteTimeStopRequest,
        SwitchRoleRequest: ?SwitchRoleRequest,
        RoleTagChangeRequest: ?RoleTagChangeRequest,
        ExecuteQteRequest: ?ExecuteQteRequest,
        CharacterAttachRequest: ?CharacterAttachRequest,
        CharacterDetachRequest: ?CharacterDetachRequest,
        ClientCurrentRoleReportRequest: ?ClientCurrentRoleReportRequest,
        GaSwitchCommonEnemyProCampRequest: ?GaSwitchCommonEnemyProCampRequest,
        CombatMaxCaseMessageRequest: ?CombatMaxCaseMessageRequest,
    } = null,
    CombatCommon: ?CombatCommon = null,
    RequestId: i32 = 0,
};
pub const CombatResponseData = struct {
    pub const default: @This() = .{};
    Message: ?union(enum) {
        CreateBulletResponse: ?CreateBulletResponse,
        DestroyBulletResponse: ?DestroyBulletResponse,
        DamageExecuteResponse: ?DamageExecuteResponse,
        ApplyGameplayEffectResponse: ?ApplyGameplayEffectResponse,
        RemoveGameplayEffectResponse: ?RemoveGameplayEffectResponse,
        HitResponse: ?HitResponse,
        HitEndResponse: ?HitEndResponse,
        SkillResponse: ?SkillResponse,
        UseSkillResponse: ?UseSkillResponse,
        EndSkillResponse: ?EndSkillResponse,
        PartUpdateResponse: ?PartUpdateResponse,
        MaterialResponse: ?MaterialResponse,
        GameplayCueResponse: ?GameplayCueResponse,
        EntityIsVisibleResponse: ?EntityIsVisibleResponse,
        SwitchCharacterStateResponse: ?SwitchCharacterStateResponse,
        LogicStateInitResponse: ?LogicStateInitResponse,
        SwitchLogicStateResponse: ?SwitchLogicStateResponse,
        AnimationStateChangedResponse: ?AnimationStateChangedResponse,
        AnimationStateInitResponse: ?AnimationStateInitResponse,
        ModifyBulletParamsResponse: ?ModifyBulletParamsResponse,
        DrownResponse: ?DrownResponse,
        OrderApplyBuffResponse: ?OrderApplyBuffResponse,
        OrderRemoveBuffResponse: ?OrderRemoveBuffResponse,
        ActivateBuffResponse: ?ActivateBuffResponse,
        OrderRemoveBuffByTagsResponse: ?OrderRemoveBuffByTagsResponse,
        AiInformationResponse: ?AiInformationResponse,
        ToughCalcExtraRatioChangeResponse: ?ToughCalcExtraRatioChangeResponse,
        BattleStateChangeResponse: ?BattleStateChangeResponse,
        AnimationGameplayTagResponse: ?AnimationGameplayTagResponse,
        BoneVisibleChangeResponse: ?BoneVisibleChangeResponse,
        AiBlackboardsResponse: ?AiBlackboardsResponse,
        AiBlackboardCdResponse: ?AiBlackboardCdResponse,
        AiHateResponse: ?AiHateResponse,
        MonsterBoomResponse: ?MonsterBoomResponse,
        CaughtResponse: ?CaughtResponse,
        EntityStaticHookMoveResponse: ?EntityStaticHookMoveResponse,
        ChangeStateResponse: ?ChangeStateResponse,
        ChangeStateConfirmResponse: ?ChangeStateConfirmResponse,
        FsmConditionPassResponse: ?FsmConditionPassResponse,
        BuffStackCountResponse: ?BuffStackCountResponse,
        ANStartResponse: ?ANStartResponse,
        UseSkillFailResponse: ?UseSkillFailResponse,
        EnterViewDirectionResponse: ?EnterViewDirectionResponse,
        ExitViewDirectionResponse: ?ExitViewDirectionResponse,
        PassiveSkillAddResponse: ?PassiveSkillAddResponse,
        InterruptSkillInDelayResponse: ?InterruptSkillInDelayResponse,
        TriggerExitSkillResponse: ?TriggerExitSkillResponse,
        ActorVisibleResponse: ?ActorVisibleResponse,
        BuffEffectResponse: ?BuffEffectResponse,
        FragileChangeResponse: ?FragileChangeResponse,
        RTimeStopResponse: ?RTimeStopResponse,
        DrownEndTeleportResponse: ?DrownEndTeleportResponse,
        MonsterDrownResponse: ?MonsterDrownResponse,
        PassiveSkillRemoveResponse: ?PassiveSkillRemoveResponse,
        RTimeStopInstResponse: ?RTimeStopInstResponse,
        FsmStateBehaviorResponse: ?FsmStateBehaviorResponse,
        FsmPlayMontageResponse: ?FsmPlayMontageResponse,
        TsAnimNotifyStateAbsoluteTimeStopResponse: ?TsAnimNotifyStateAbsoluteTimeStopResponse,
        SwitchRoleResponse: ?SwitchRoleResponse,
        RoleTagChangeResponse: ?RoleTagChangeResponse,
        ExecuteQteResponse: ?ExecuteQteResponse,
        CharacterAttachResponse: ?CharacterAttachResponse,
        CharacterDetachResponse: ?CharacterDetachResponse,
        ClientCurrentRoleReportResponse: ?ClientCurrentRoleReportResponse,
        GaSwitchCommonEnemyProCampResponse: ?GaSwitchCommonEnemyProCampResponse,
        CombatDataMaxResponse: ?CombatDataMaxResponse,
    } = null,
    CombatCommon: ?CombatCommon = null,
    RequestId: i32 = 0,
};
pub const CombatDataMaxResponse = struct {
    pub const default: @This() = .{};
};
pub const CombatSendData = struct {
    pub const default: @This() = .{};
    Message: ?union(enum) {
        Push: ?CombatPushData,
        Request: ?CombatRequestData,
    } = null,
};
pub const CombatReceiveData = struct {
    pub const default: @This() = .{};
    Message: ?union(enum) {
        CombatNotifyData: ?CombatNotifyData,
        CombatResponseData: ?CombatResponseData,
    } = null,
};
pub const CombatSendPackRequest = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(CombatSendData) = .empty,
    HostPlayerId: i32 = 0,
};
pub const CombatSendPackResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ReceivePackNotify: ?CombatReceivePackNotify = null,
};
pub const CombatReceivePackNotify = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(CombatReceiveData) = .empty,
};
pub const CombatMaxCaseMessageRequest = struct {
    pub const default: @This() = .{};
};
pub const EntityLoadCompleteNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    EntityIds: std.ArrayList(i64) = .empty,
    EntityIdsUnload: std.ArrayList(i64) = .empty,
};
pub const MaterialRequest = struct {
    pub const default: @This() = .{};
    MaterialInfo: ?MaterialInfo = null,
    CombatCommon: ?CombatCommon = null,
};
pub const MaterialPush = struct {
    pub const default: @This() = .{};
    MaterialInfo: ?MaterialInfo = null,
    CombatCommon: ?CombatCommon = null,
};
pub const MaterialInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    AssetName: []const u8 = "",
    IsGroup: bool = false,
};
pub const MaterialResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MaterialNotify = struct {
    pub const default: @This() = .{};
    MaterialInfo: ?MaterialInfo = null,
    CombatCommon: ?CombatCommon = null,
};
pub const DynamicEntityInformation = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    EntityType: ?EEntityType = null,
    ConfigId: i32 = 0,
    PlayerId: i32 = 0,
    OwnerId: i64 = 0,
    MovementInformation: ?MovementInformation = null,
    GameAttributes: std.ArrayList(GameplayAttributeData) = .empty,
    InitAttribute: bool = false,
    IsVisible: bool = false,
    AnimationStates: std.ArrayList(i32) = .empty,
    InitGameplayTag: bool = false,
    GameplayTags: std.ArrayList(GameplayTagData) = .empty,
    Level: i32 = 0,
    BlackboardParams: std.ArrayList(BlackboardParam) = .empty,
    Tags: std.ArrayList([]const u8) = .empty,
    PrivateTags: std.ArrayList(PrivateTag) = .empty,
    DeathStatus: bool = false,
    HardnessModeId: i32 = 0,
    PartLifeInfos: std.ArrayList(PartInformation) = .empty,
    VisionSkillInfos: std.ArrayList(VisionSkillInformation) = .empty,
    FightBuffInfos: std.ArrayList(FightBuffInformation) = .empty,
    CreatureGroup: i32 = 0,
    ListenInformation: ?ListenInformation = null,
    SysBuffInfos: std.ArrayList(SysBuffInformation) = .empty,
    LivingStatus: ?LivingStatus = null,
    EntityCommonTags: std.ArrayList(i32) = .empty,
    WeaponConfId: i32 = 0,
    DurabilityValue: i32 = 0,
    InitLocation: ?Vector = null,
    SummonInfo: ?SummonInfo = null,
    ComponentPbs: std.ArrayList(EntityComponentPb) = .empty,
};
pub const EntityLivingStatusNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    LivingStatus: ?LivingStatus = null,
    DropVisionItem: std.ArrayList(DropVisionItemResult) = .empty,
};
pub const DropVisionItemResult = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    Drop: bool = false,
};
pub const ListenInformation = struct {
    pub const default: @This() = .{};
    Id: std.ArrayList(i32) = .empty,
    Range: f32 = 0,
};
pub const ScenePlayerInformation = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    PlayerName: []const u8 = "",
    PlayerIcon: i32 = 0,
    Level: i32 = 0,
    GuildName: []const u8 = "",
    GuildIntro: []const u8 = "",
    Location: ?Vector = null,
    IsOffline: bool = false,
    PlayerPrefix: i32 = 0,
    PlayerGEIncHandle: i32 = 0,
    FightRoleInfos: std.ArrayList(FightRoleInfos) = .empty,
    Rotation: ?Rotator = null,
    GroupType: i32 = 0,
    CurRole: i32 = 0,
    VehiclePlayerData: ?VehiclePlayerData = null,
    Gravity: ?Vector = null,
    AreaId: i32 = 0,
};
pub const GroupFormation = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    FightRoleInfos: std.ArrayList(FightRoleInfos) = .empty,
    CurrentGroupType: i32 = 0,
};
pub const FightRoleInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    EntityId: i64 = 0,
    OnStageWithoutControl: bool = false,
};
pub const FightRoleInfos = struct {
    pub const default: @This() = .{};
    GroupType: i32 = 0,
    FightRoleInfos: std.ArrayList(FightRoleInfo) = .empty,
    CurRole: i32 = 0,
    LivingStatus: ?LivingStatus = null,
    IsFixedLocation: bool = false,
};
pub const UpdateGroupFormationNotify = struct {
    pub const default: @This() = .{};
    GroupFormation: std.ArrayList(GroupFormation) = .empty,
};
pub const SceneInformation = struct {
    pub const default: @This() = .{};
    SceneId: []const u8 = "",
    InstanceId: i32 = 0,
    OwnerId: i32 = 0,
    PlayerInfos: std.ArrayList(ScenePlayerInformation) = .empty,
    DynamicEntityList: std.ArrayList(DynamicEntityInformation) = .empty,
    BlackboardParams: std.ArrayList(BlackboardParam) = .empty,
    EndTime: i64 = 0,
    AoiData: ?PlayerSceneAoiData = null,
    OwnerFinishMingSuGens: std.ArrayList(i64) = .empty,
    Mode: ?SceneMode = null,
    TimeInfo: ?SceneTimeInfo = null,
    HostFogIds: std.ArrayList(i32) = .empty,
    LoadedSubLevels: std.ArrayList([]const u8) = .empty,
    AreaStates: std.ArrayList(SceneAreaState) = .empty,
    ResetPointEntityId: i32 = 0,
    DataLayers: std.ArrayList(i32) = .empty,
    AreaMpc: std.ArrayList(MapEntry(i32, i32)) = .empty,
    CurContextId: i64 = 0,
    AudioState: std.ArrayList(AudioState) = .empty,
    SceneBulletOwnerId: i64 = 0,
    SceneTraceId: i64 = 0,
    HideSubLevels: std.ArrayList([]const u8) = .empty,
    LastHighLevelArea: i32 = 0,
    EnableRoads: std.ArrayList(i32) = .empty,
};
pub const SceneAreaState = struct {
    pub const default: @This() = .{};
    AreaId: i32 = 0,
    State: bool = false,
};
pub const HostTeleportUnlockNotify = struct {
    pub const default: @This() = .{};
    HostPlayerId: i32 = 0,
    HostTeleportId: i32 = 0,
};
pub const SceneTimeInfo = struct {
    pub const default: @This() = .{};
    Hour: i32 = 0,
    Minute: i32 = 0,
    OwnerTimeClockTimeSpan: i64 = 0,
};
pub const SceneMode = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Single = 0,
    Multi = 1,
};
pub const JoinSceneNotify = struct {
    pub const default: @This() = .{};
    SceneInfo: ?SceneInformation = null,
    MaxEntityId: i64 = 0,
    TransitionOption: ?TransitionOptionPb = null,
};
pub const SceneTraceRequest = struct {
    pub const default: @This() = .{};
    SceneTraceId: i64 = 0,
};
pub const SceneTraceResponse = struct {
    pub const default: @This() = .{};
};
pub const AfterJoinSceneNotify = struct {
    pub const default: @This() = .{};
};
pub const LeaveSceneNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    SceneId: []const u8 = "",
    TransitionOption: ?TransitionOptionPb = null,
};
pub const MovingEntityData = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Originator: i64 = 0,
    MoveInfos: std.ArrayList(MoveReplaySample) = .empty,
    ForcePush: bool = false,
};
pub const MovePackagePush = struct {
    pub const default: @This() = .{};
    MovingEntities: std.ArrayList(MovingEntityData) = .empty,
    SceneOwnerId: i32 = 0,
};
pub const MovePackageNotify = struct {
    pub const default: @This() = .{};
    MovingEntities: std.ArrayList(MovingEntityData) = .empty,
};
pub const EntitySimplyMoveInfoPackagePush = struct {
    pub const default: @This() = .{};
    MoveInfos: std.ArrayList(EntitySimplyMoveInfo) = .empty,
    SceneOwnerId: i32 = 0,
};
pub const RemoveSummonEntityRequest = struct {
    pub const default: @This() = .{};
    SummonerId: i64 = 0,
    SkillId: i32 = 0,
    RemoveType: i32 = 0,
    RemoveENtityIds: std.ArrayList(i64) = .empty,
};
pub const RemoveSummonEntityResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const EntityOnLandedRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const EntityOnLandedResponse = struct {
    pub const default: @This() = .{};
};
pub const AttributeChangedRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    Attributes: std.ArrayList(GameplayAttributeData) = .empty,
};
pub const AttributeChangedResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AttributeChangedNotify = struct {
    pub const default: @This() = .{};
    Attributes: std.ArrayList(GameplayAttributeData) = .empty,
};
pub const AnimationStateInitRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const AnimationStateInitPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const AnimationStateInitResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AnimationStateInitNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    TimeStamp: f32 = 0,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const AnimationStateChangedRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const AnimationStateChangedPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const AnimationStateChangedResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AnimationStateChangedNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    TimeStamp: f32 = 0,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const AnimStateChangeInfo = struct {
    pub const default: @This() = .{};
    AnimationStates: std.ArrayList(i32) = .empty,
    SpecialAnimationStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const AnimStateChangeInfoList = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    AnimStateChangeInfo: std.ArrayList(AnimStateChangeInfo) = .empty,
};
pub const PackAnimChangedNotify = struct {
    pub const default: @This() = .{};
    EntityAnimState: std.ArrayList(AnimStateChangeInfoList) = .empty,
};
pub const EntityCommonTagNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    Tags: std.ArrayList(CommonTagData) = .empty,
};
pub const SummonRequestInfo = struct {
    pub const default: @This() = .{};
    SummonEntityId: i64 = 0,
    SkillId: i32 = 0,
    SummonConfigId: i32 = 0,
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
    IsVisible: bool = false,
};
pub const SummonRequest = struct {
    pub const default: @This() = .{};
    SummonerEntityId: i64 = 0,
    SummonInfo: ?SummonRequestInfo = null,
};
pub const SummonResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const Summon3Request = struct {
    pub const default: @This() = .{};
    SummonerEntityId: i64 = 0,
    SummonInfo: ?SummonRequestInfo = null,
};
pub const Summon3Response = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SummonEntityNotify = struct {
    pub const default: @This() = .{};
    SummonerId: i64 = 0,
    SummonIds: std.ArrayList(i64) = .empty,
};
pub const SceneDateUpdateReason = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    TimeFlowAuto = 0,
    LevelPlayAuto = 1,
    PlayerOperate = 2,
};
pub const UpdateSceneDateRequest = struct {
    pub const default: @This() = .{};
    AddDays: u32 = 0,
    Hour: i32 = 0,
    Minute: i32 = 0,
    Reason: ?SceneDateUpdateReason = null,
};
pub const UpdateSceneDateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    CurrDate: u32 = 0,
};
pub const PlayerSceneAoiData = struct {
    pub const default: @This() = .{};
    DynamicEntityList: std.ArrayList(DynamicEntityInformation) = .empty,
    GenIds: std.ArrayList(i64) = .empty,
    Entities: std.ArrayList(EntityPb) = .empty,
};
pub const SummonInfo = struct {
    pub const default: @This() = .{};
    SummonCfgId: i32 = 0,
    SummonerId: i64 = 0,
    SummonSkillId: i32 = 0,
};
pub const WeatherControlInfoWithoutCheckAsyncRequest = struct {
    pub const default: @This() = .{};
};
pub const WeatherControlInfoWithoutCheckAsyncResponse = struct {
    pub const default: @This() = .{};
    UnlockedWeatherSwitchConfigIdList: std.ArrayList(i32) = .empty,
};
pub const EntityFollowTrackRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const EntityFollowTrackResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PlayerRebackSceneNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const DrownRequest = struct {
    pub const default: @This() = .{};
};
pub const DrownPush = struct {
    pub const default: @This() = .{};
};
pub const DrownResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const DrownNotify = struct {
    pub const default: @This() = .{};
};
pub const DrownEndTeleportRequest = struct {
    pub const default: @This() = .{};
};
pub const DrownEndTeleportPush = struct {
    pub const default: @This() = .{};
    ycu: ?union(enum) {
        TeleportPos: ?Vector,
    } = null,
};
pub const DrownEndTeleportResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MonsterDrownRequest = struct {
    pub const default: @This() = .{};
    Pos: ?Vector = null,
};
pub const MonsterDrownPush = struct {
    pub const default: @This() = .{};
    Pos: ?Vector = null,
};
pub const MonsterDrownResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SceneLoadingFinishRequest = struct {
    pub const default: @This() = .{};
    SceneId: []const u8 = "",
};
pub const SceneLoadingFinishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const UpdateVoxelEnvRequest = struct {
    pub const default: @This() = .{};
    ServerCaveMode: i32 = 0,
};
pub const UpdateVoxelEnvResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ServerCaveMode: i32 = 0,
};
pub const SceneRoadSyncNotify = struct {
    pub const default: @This() = .{};
    SceneId: []const u8 = "",
    InstanceId: i32 = 0,
    EnabledRoads: std.ArrayList(i32) = .empty,
};
pub const EBulletCreateSource = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NormalSource = 0,
    ReboundSource = 1,
    CollisionSpawnSource = 2,
};
pub const ENewLinkStage = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NewLinkStageNone = 0,
    NewLinkStageLock = 1,
    Accumulate = 2,
    Ready = 3,
    Burst = 4,
};
pub const MontageContext = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
    ConstateId: i64 = 0,
};
pub const HitInformation = struct {
    pub const default: @This() = .{};
    Originator: i64 = 0,
    Id: i64 = 0,
    TargetId: i64 = 0,
    BulletId: i64 = 0,
    HasBeHitData: bool = false,
    HitEffectPos: ?Vector = null,
    HitEffectRotate: ?Rotator = null,
    IsShake: bool = false,
    HitPos: ?Vector = null,
    EnterFk: bool = false,
    IsHitWeakness: bool = false,
    IsTriggerCounterattack: bool = false,
    VictimRotation: ?Rotator = null,
    IsChangeVictimRotation: bool = false,
    HitPart: []const u8 = "",
    IsTriggerVisionCounterAttack: bool = false,
    SkillId: i64 = 0,
    FightState: i32 = 0,
    BeHitAnim: i32 = 0,
    Source: ?EBulletCreateSource = null,
    PhantomSkillIdentify: i32 = 0,
};
pub const CounterAttackInfo = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    FightState: i32 = 0,
    TriggerCounterType: i32 = 0,
    CounterAnIndex: i32 = 0,
};
pub const SkillNodeInfo = struct {
    pub const default: @This() = .{};
    SubProtocol: i32 = 0,
    MontageIndex: i32 = 0,
    SpeedRatio: f32 = 0,
    SkillSingleId: i32 = 0,
    SkillIndex: i32 = 0,
    StartSection: []const u8 = "",
    StartTimeSeconds: f32 = 0,
};
pub const SkillRequest = struct {
    pub const default: @This() = .{};
    UseSkillInfo: ?UseSkillInformation = null,
    SkillNodeInfos: ?SkillNodeInfo = null,
};
pub const SkillResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SkillNotify = struct {
    pub const default: @This() = .{};
    UseSkillInfo: ?UseSkillInformation = null,
    SkillNodeInfos: ?SkillNodeInfo = null,
};
pub const UseSkillRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    BattleFlags: std.ArrayList(i32) = .empty,
};
pub const UseSkillResponse = struct {
    pub const default: @This() = .{};
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const UseSkillNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
};
pub const EEndSkillReason = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Default = 0,
    BeginOtherSkill = 1,
    BeHit = 2,
    BeCounter = 3,
};
pub const InterruptSkillInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    SkillId: i32 = 0,
    BulletId: i64 = 0,
};
pub const EndSkillRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    Reason: ?EEndSkillReason = null,
    InterruptSkillInfo: ?InterruptSkillInfo = null,
};
pub const EndSkillPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    Reason: ?EEndSkillReason = null,
    InterruptSkillInfo: ?InterruptSkillInfo = null,
};
pub const EndSkillResponse = struct {
    pub const default: @This() = .{};
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const EndSkillNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
};
pub const InterruptSkillInDelayRequest = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
};
pub const InterruptSkillInDelayPush = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
};
pub const InterruptSkillInDelayResponse = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const UseSkillFailRequest = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
};
pub const UseSkillFailPush = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
};
pub const UseSkillFailResponse = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    Error: ?DErrorResult = null,
};
pub const CounterAttackPush = struct {
    pub const default: @This() = .{};
    CounterAttackInfo: ?CounterAttackInfo = null,
};
pub const HitRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    HitInfo: ?HitInformation = null,
    SkillMessageId: i64 = 0,
};
pub const HitResponse = struct {
    pub const default: @This() = .{};
    HitInfo: ?HitInformation = null,
    ErrorCode: ?ErrorCode = null,
};
pub const HitNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    HitInfo: ?HitInformation = null,
};
pub const HitEndRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    TargetId: i64 = 0,
};
pub const HitEndPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    TargetId: i64 = 0,
};
pub const HitEndResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CaughtInfo = struct {
    pub const default: @This() = .{};
    Attacker: i64 = 0,
    CaughtInfoId: i64 = 0,
    IsEnd: bool = false,
    FightState: i32 = 0,
};
pub const CaughtRequest = struct {
    pub const default: @This() = .{};
    Info: ?CaughtInfo = null,
};
pub const CaughtPush = struct {
    pub const default: @This() = .{};
    Info: ?CaughtInfo = null,
};
pub const CaughtResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CaughtNotify = struct {
    pub const default: @This() = .{};
    Info: ?CaughtInfo = null,
};
pub const ActiveBulletHandle = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    HandleId: i32 = 0,
};
pub const CreateBulletRequest = struct {
    pub const default: @This() = .{};
    ParentHandle: ?union(enum) {
        BulletHandle: ?ActiveBulletHandle,
    } = null,
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
    OwnerEntityId: i64 = 0,
    BulletId: i64 = 0,
    SkillId: i64 = 0,
    Location: ?Vector = null,
    Rotation: ?Rotator = null,
    TargetId: i64 = 0,
    SpawnEntityId: i64 = 0,
    SpawnVelocityEntityId: i64 = 0,
    IsLocal: bool = false,
    DtType: i32 = 0,
    RandomPosOffset: ?Vector = null,
    RandomInitSpeedOffset: ?Vector = null,
};
pub const CreateBulletResponsePush = struct {
    pub const default: @This() = .{};
    ParentHandle: ?union(enum) {
        BulletHandle: ?ActiveBulletHandle,
    } = null,
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
    OwnerEntityId: i64 = 0,
    BulletId: i64 = 0,
    SkillId: i64 = 0,
    Location: ?Vector = null,
    Rotation: ?Rotator = null,
    TargetId: i64 = 0,
    SpawnEntityId: i64 = 0,
    SpawnVelocityEntityId: i64 = 0,
    IsLocal: bool = false,
    DtType: i32 = 0,
    RandomPosOffset: ?Vector = null,
    RandomInitSpeedOffset: ?Vector = null,
};
pub const CreateBulletResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CreateBulletNotify = struct {
    pub const default: @This() = .{};
    ParentHandle: ?union(enum) {
        BulletHandle: ?ActiveBulletHandle,
    } = null,
    LocationId: ?union(enum) {
        LocationEntityId: i64,
    } = null,
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
    OwnerEntityId: i64 = 0,
    BulletId: i64 = 0,
    SkillId: i64 = 0,
    Location: ?Vector = null,
    Rotation: ?Rotator = null,
    TargetId: i64 = 0,
    SpawnEntityId: i64 = 0,
    SpawnVelocityEntityId: i64 = 0,
    TarLocation: ?Vector = null,
    DtType: i32 = 0,
    Size: ?Vector = null,
    RandomPosOffset: ?Vector = null,
    RandomInitSpeedOffset: ?Vector = null,
    HitCase: []const u8 = "",
};
pub const DestroyBulletRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
};
pub const DestroyBulletResponsePush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
};
pub const DestroyBulletResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const DestroyBulletNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
    IsCreateSubBullet: bool = false,
};
pub const ModifyBulletParams = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
    TargetId: i64 = 0,
};
pub const ModifyBulletParamsRequest = struct {
    pub const default: @This() = .{};
    ModifyBulletParams: ?ModifyBulletParams = null,
};
pub const ModifyBulletParamsPush = struct {
    pub const default: @This() = .{};
    ModifyBulletParams: ?ModifyBulletParams = null,
};
pub const ModifyBulletParamsResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ModifyBulletParamsNotify = struct {
    pub const default: @This() = .{};
    ModifyBulletParams: ?ModifyBulletParams = null,
};
pub const DamageSourceType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    FromBullet = 0,
    FromEffect = 1,
};
pub const DamageContext = struct {
    pub const default: @This() = .{};
    Source: ?union(enum) {
        SourceType: i32,
    } = null,
    Bullet: ?union(enum) {
        BulletId: i64,
    } = null,
    Skill: ?union(enum) {
        SkillId: i64,
    } = null,
    SkillMessage: ?union(enum) {
        SkillMessageId: i64,
    } = null,
    BulletTags: std.ArrayList(i32) = .empty,
};
pub const DamageExecuteRequest = struct {
    pub const default: @This() = .{};
    DamageId: i64 = 0,
    SkillLevel: i32 = 0,
    AttackerEntityId: i64 = 0,
    TargetEntityId: i64 = 0,
    IsAddEnergy: bool = false,
    IsCounterAttack: bool = false,
    ForceCritical: bool = false,
    IsBlocked: bool = false,
    PartIndex: i32 = 0,
    CounterSkillMessageId: i64 = 0,
    DamageContext: ?DamageContext = null,
    RandomSeed: i32 = 0,
    IsBreakWeakness: bool = false,
};
pub const DamageExecuteResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    AttackerEntityId: i64 = 0,
    TargetEntityId: i64 = 0,
    Damage: i32 = 0,
    PartIndex: i32 = 0,
    IsCrit: bool = false,
    KilledTarget: bool = false,
    ShieldCoverDamage: i32 = 0,
    ImmuneType: ?EDamageImmune = null,
    ElementType: i32 = 0,
    ChangeLife: i32 = 0,
    ChangeWeakness: i32 = 0,
};
pub const DamageExecuteNotify = struct {
    pub const default: @This() = .{};
    DamageId: i64 = 0,
    AttackerEntityId: i64 = 0,
    TargetEntityId: i64 = 0,
    Damage: i32 = 0,
    PartIndex: i32 = 0,
    IsCrit: bool = false,
    KilledTarget: bool = false,
    ShieldCoverDamage: i32 = 0,
    SkillLevel: i32 = 0,
    DamageContext: ?DamageContext = null,
    ImmuneType: i32 = 0,
    ElementType: i32 = 0,
    ChangeLife: i32 = 0,
    ChangeWeakness: i32 = 0,
    Bop: i64 = 0,
};
pub const PassiveSkillAddRequest = struct {
    pub const default: @This() = .{};
    PassiveSkillId: i64 = 0,
    TargetEntityId: i64 = 0,
};
pub const PassiveSkillAddPush = struct {
    pub const default: @This() = .{};
    PassiveSkillId: i64 = 0,
    TargetEntityId: i64 = 0,
};
pub const PassiveSkillAddResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PassiveSkillRemoveRequest = struct {
    pub const default: @This() = .{};
    PassiveSkillId: i64 = 0,
    TargetEntityId: i64 = 0,
};
pub const PassiveSkillRemovePush = struct {
    pub const default: @This() = .{};
    PassiveSkillId: i64 = 0,
    TargetEntityId: i64 = 0,
};
pub const PassiveSkillRemoveResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PassiveSkillAddNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PassiveSkillItemPbList: std.ArrayList(PassiveSkillItemPb) = .empty,
};
pub const PassiveSkillRemoveNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    SkillIdList: std.ArrayList(i64) = .empty,
};
pub const EnterViewDirectionRequest = struct {
    pub const default: @This() = .{};
};
pub const EnterViewDirectionPush = struct {
    pub const default: @This() = .{};
};
pub const EnterViewDirectionResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ExitViewDirectionRequest = struct {
    pub const default: @This() = .{};
};
pub const ExitViewDirectionPush = struct {
    pub const default: @This() = .{};
};
pub const ExitViewDirectionResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const TriggerExitSkillRequest = struct {
    pub const default: @This() = .{};
    EnterEntityId: i64 = 0,
    LeaveEntityId: i64 = 0,
};
pub const TriggerExitSkillPush = struct {
    pub const default: @This() = .{};
    EnterEntityId: i64 = 0,
    LeaveEntityId: i64 = 0,
};
pub const TriggerExitSkillResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MonsterInfo = struct {
    pub const default: @This() = .{};
    MonsterId: i32 = 0,
    Count: i32 = 0,
    GenId: i64 = 0,
};
pub const BattleModule = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Damage = 0,
    GameplayEffect = 1,
    Log = 2,
};
pub const SwitchBattleModeNotify = struct {
    pub const default: @This() = .{};
    ServerControllerModules: std.ArrayList(BattleModule) = .empty,
    ClientControllerModules: std.ArrayList(BattleModule) = .empty,
};
pub const EntityIsVisibleRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsVisible: bool = false,
    CombatCommon: ?CombatCommon = null,
};
pub const EntityIsVisiblePush = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsVisible: bool = false,
    CombatCommon: ?CombatCommon = null,
};
pub const EntityIsVisibleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const EntityIsVisibleNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsVisible: bool = false,
    CombatCommon: ?CombatCommon = null,
};
pub const MotorIsEnablePush = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsEnable: bool = false,
    CombatCommon: ?CombatCommon = null,
};
pub const ActorVisibleRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsActorVisible: bool = false,
};
pub const ActorVisiblePush = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsActorVisible: bool = false,
};
pub const ActorVisibleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ActorVisibleNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsActorVisible: bool = false,
};
pub const SwitchCharacterStateRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    OldState: i32 = 0,
    NewState: i32 = 0,
};
pub const SwitchCharacterStatePush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    OldState: i32 = 0,
    NewState: i32 = 0,
};
pub const SwitchCharacterStateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SwitchCharacterStateNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    OldState: i32 = 0,
    NewState: i32 = 0,
};
pub const BattleStateChangeRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    InBattle: bool = false,
};
pub const BattleStateChangePush = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    InBattle: bool = false,
};
pub const BattleStateChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const BattleStateChangeNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    InBattle: bool = false,
};
pub const ToughCalcExtraRatioChangeRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    Duration: i32 = 0,
};
pub const ToughCalcExtraRatioChangePush = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    Duration: i32 = 0,
};
pub const ToughCalcExtraRatioChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MonsterBoomRequest = struct {
    pub const default: @This() = .{};
    Delay: i32 = 0,
};
pub const MonsterBoomPush = struct {
    pub const default: @This() = .{};
    Delay: i32 = 0,
};
pub const MonsterBoomResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MontagePlayNotify = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
};
pub const ANStartRequest = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
    AnIndex: i32 = 0,
};
pub const ANStartPush = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
    AnIndex: i32 = 0,
};
pub const ANStartResponse = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
    AnIndex: i32 = 0,
    Error: ?DErrorResult = null,
};
pub const ANStartNotify = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
    AnIndex: i32 = 0,
};
pub const EDamageImmune = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Default = 0,
    Invincible = 1,
    BuffEffectElement = 2,
    BulletCurNoCtrl = 3,
    VehiclePassenger = 4,
    FishBoat = 5,
    Revive = 6,
};
pub const CharacterBattleStateInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    InBattle: bool = false,
};
pub const PushContextIdNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
};
pub const CharacterBattleStateChangeNotify = struct {
    pub const default: @This() = .{};
    CharacterBattleStateInfo: std.ArrayList(CharacterBattleStateInfo) = .empty,
};
pub const PlayerBattleStateChangeNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    InBattle: bool = false,
};
pub const EShieldUpdateType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    EShieldUpdateTypeAdd = 0,
    EShieldUpdateTypeDel = 1,
    EShieldUpdateTypeModify = 2,
};
pub const ShieldUpdateInfo = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    ConfigId: i32 = 0,
    ShieldValue: i32 = 0,
    UpdateType: ?EShieldUpdateType = null,
};
pub const ShieldUpdateNotify = struct {
    pub const default: @This() = .{};
    Shields: std.ArrayList(ShieldUpdateInfo) = .empty,
};
pub const RoleTagChangeRequest = struct {
    pub const default: @This() = .{};
    TagId: i32 = 0,
    TagCount: i32 = 0,
};
pub const RoleTagChangePush = struct {
    pub const default: @This() = .{};
    TagId: i32 = 0,
    TagCount: i32 = 0,
};
pub const RoleTagChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const GameplayCueRequest = struct {
    pub const default: @This() = .{};
    GameplayCueId: i64 = 0,
};
pub const GameplayCuePush = struct {
    pub const default: @This() = .{};
    GameplayCueId: i64 = 0,
};
pub const GameplayCueResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const GameplayCueNotify = struct {
    pub const default: @This() = .{};
    GameplayCueId: i64 = 0,
};
pub const ExecuteQteNotify = struct {
    pub const default: @This() = .{};
    DownEntityId: i64 = 0,
    UpEntityId: i64 = 0,
    FnvHash: i32 = 0,
};
pub const ExecuteQteRequest = struct {
    pub const default: @This() = .{};
    DownEntityId: i64 = 0,
    UpEntityId: i64 = 0,
    FnvHash: i32 = 0,
};
pub const ExecuteQtePush = struct {
    pub const default: @This() = .{};
    DownEntityId: i64 = 0,
    UpEntityId: i64 = 0,
    FnvHash: i32 = 0,
};
pub const ExecuteQteResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const NewLinkStateNotify = struct {
    pub const default: @This() = .{};
    LinkConfigId: i32 = 0,
    Current: ?ENewLinkStage = null,
    PlayerId: i32 = 0,
};
pub const NewLinkBurstPush = struct {
    pub const default: @This() = .{};
};
pub const CharacterAttachRequest = struct {
    pub const default: @This() = .{};
    CharacterAttachInfo: ?CharacterAttachInfo = null,
    TargetEntity: i64 = 0,
};
pub const AddCombineEntitiesRelationNotify = struct {
    pub const default: @This() = .{};
    CharacterAttachInfo: ?CharacterAttachInfo = null,
    TargetEntity: i64 = 0,
};
pub const RemoveCombineRelationNotify = struct {
    pub const default: @This() = .{};
    CombineEntity: i64 = 0,
    TargetEntity: i64 = 0,
};
pub const CharacterAttachResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CharacterDetachRequest = struct {
    pub const default: @This() = .{};
    EntityA: i64 = 0,
    EntityB: i64 = 0,
};
pub const CharacterDetachResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ModifyEntityCampNotify = struct {
    pub const default: @This() = .{};
    TargetEntityId: i64 = 0,
    Camp: i32 = 0,
};
pub const MontagePlayPush = struct {
    pub const default: @This() = .{};
    Name: []const u8 = "",
    Path: i32 = 0,
    SpeedRatio: f32 = 0,
    StartSection: []const u8 = "",
    StartTimeSeconds: f32 = 0,
};
pub const VisionTriggerPush = struct {
    pub const default: @This() = .{};
    VisionId: i32 = 0,
};
pub const VisionTriggerNotify = struct {
    pub const default: @This() = .{};
    VisionId: i32 = 0,
};
pub const TransformBuffStackNotify = struct {
    pub const default: @This() = .{};
    BuffHandle: i64 = 0,
    BuffId: i64 = 0,
    BuffStackModifier: i32 = 0,
};
pub const MotorSummonAndRidePush = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    VehicleIncId: i64 = 0,
    Transform: ?Transform = null,
};
pub const MotorSummonAndRideNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    EntityId: i64 = 0,
    VehicleIncId: i64 = 0,
    Transform: ?Transform = null,
};
pub const GaSwitchCommonEnemyProCampRequest = struct {
    pub const default: @This() = .{};
};
pub const GaSwitchCommonEnemyProCampResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const BulletPatternPush = struct {
    pub const default: @This() = .{};
    BulletPatternHandleId: i64 = 0,
    BulletPatternId: i32 = 0,
};
pub const BulletPatternNotify = struct {
    pub const default: @This() = .{};
    BulletPatternHandleId: i64 = 0,
    BulletPatternId: i32 = 0,
};
pub const QuickHackOpenPush = struct {
    pub const default: @This() = .{};
    DeviceId: i32 = 0,
    OwnerEntityId: i64 = 0,
};
pub const QuickHackRamVerifyPush = struct {
    pub const default: @This() = .{};
    DeviceId: i32 = 0,
    QuickHackSkillIdList: std.ArrayList(i32) = .empty,
    OpenQuickHackPreMessageId: i64 = 0,
};
pub const DodgeInfoPush = struct {
    pub const default: @This() = .{};
    BulletOwnerId: i64 = 0,
    BulletId: i64 = 0,
};
pub const FormationAttr = struct {
    pub const default: @This() = .{};
    AttrId: i32 = 0,
    Ratio: i32 = 0,
    BaseMaxValue: i32 = 0,
    MaxValue: i32 = 0,
    CurrentValue: i32 = 0,
};
pub const FormationAttrNotify = struct {
    pub const default: @This() = .{};
    Duration: i64 = 0,
    FormationAttrs: std.ArrayList(FormationAttr) = .empty,
};
pub const FormationAttrRequest = struct {
    pub const default: @This() = .{};
    Duration: i64 = 0,
    FormationAttrs: std.ArrayList(FormationAttr) = .empty,
};
pub const FormationAttrResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RecoverPropFromServer = struct {
    pub const default: @This() = .{};
    AttrId: i32 = 0,
    Ratio: i32 = 0,
    MaxValue: i32 = 0,
    ValueIncrement: i32 = 0,
};
pub const RecoverPropChangedNotify = struct {
    pub const default: @This() = .{};
    Attributes: std.ArrayList(RecoverPropFromServer) = .empty,
    Duration: i64 = 0,
};
pub const FragileChangeRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Flag: bool = false,
};
pub const FragileChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const DamageRecordEntity = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    BuffIds: std.ArrayList(i64) = .empty,
    Attr: std.ArrayList(GameplayAttributeData) = .empty,
    AttrSnapshot: std.ArrayList(GameplayAttributeData) = .empty,
};
pub const DamageCalculationDetails = struct {
    pub const default: @This() = .{};
    ABaseAttackValue: i64 = 0,
    VEffectiveDefense: f32 = 0,
    ADamageFactor: f32 = 0,
    ADamageBonusRate: f32 = 0,
    ACritChance: i64 = 0,
    AWeaknessMasteryCoefficient: f32 = 0,
    VMonsterTypeRate: f32 = 0,
    ARate: f32 = 0,
    VDefFactor: f32 = 0,
    VResistanceFactor: f32 = 0,
    VbDamageReduce: f32 = 0,
    VbElementReduce: f32 = 0,
    AEnergyChange: i64 = 0,
    WeaknessLvValue: f32 = 0,
    VWeaknessBuffStack: i32 = 0,
    HitDamageBonusRate: f32 = 0,
    WeakDamageBonusRate: f32 = 0,
    ExceptedDamageValue: f32 = 0,
};
pub const DamageRecordNotify = struct {
    pub const default: @This() = .{};
    TimestampMs: i64 = 0,
    DamageConfId: i64 = 0,
    DamageValue: i32 = 0,
    SkillId: i64 = 0,
    SkillLevel: i32 = 0,
    BulletId: i64 = 0,
    DamageSourceType: ?DamageSourceType = null,
    IsCritical: bool = false,
    Attacker: ?DamageRecordEntity = null,
    Victim: ?DamageRecordEntity = null,
    DamageCalculationDetails: ?DamageCalculationDetails = null,
    IsWeakness: bool = false,
};
pub const TestDamageRecordEntity = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    ConfigId: i32 = 0,
    BuffIds: std.ArrayList(i64) = .empty,
    Attr: std.ArrayList(GameplayAttributeData) = .empty,
};
pub const TestDamageRecordNotify = struct {
    pub const default: @This() = .{};
    TimestampMs: i64 = 0,
    Entities: std.ArrayList(TestDamageRecordEntity) = .empty,
};
pub const TimeStopPush = struct {
    pub const default: @This() = .{};
    TimeDilation: f32 = 0,
};
pub const TsAnimNotifyStateAbsoluteTimeStopRequest = struct {
    pub const default: @This() = .{};
    Duration: i32 = 0,
    Dilation: i32 = 0,
};
pub const TsAnimNotifyStateAbsoluteTimeStopPush = struct {
    pub const default: @This() = .{};
    Duration: i32 = 0,
    Dilation: i32 = 0,
};
pub const TsAnimNotifyStateAbsoluteTimeStopResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RTimeStopRequest = struct {
    pub const default: @This() = .{};
    IsStopCharacter: bool = false,
    Duration: i32 = 0,
};
pub const RTimeStopPush = struct {
    pub const default: @This() = .{};
    IsStopCharacter: bool = false,
    Duration: i32 = 0,
    Dilation: i32 = 0,
};
pub const RTimeStopResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const EntityTimeDilationPush = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    TimeDilation: f32 = 0,
};
pub const RTimeStopInstRequest = struct {
    pub const default: @This() = .{};
    Flag: bool = false,
    Duration: i32 = 0,
};
pub const RTimeStopInstPush = struct {
    pub const default: @This() = .{};
    Flag: bool = false,
    Duration: i32 = 0,
};
pub const RTimeStopInstResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const TimeCheckRequest = struct {
    pub const default: @This() = .{};
    ClientTime: i64 = 0,
    TimeDilation: f32 = 0,
    FlowTimeDilation: f32 = 0,
};
pub const TimeCheckNotify = struct {
    pub const default: @This() = .{};
    ClientTime: i64 = 0,
    ServerTime: i64 = 0,
    ServerCombatTime: i64 = 0,
    ServerStopTime: i64 = 0,
    ServerFlowTimestamp: i64 = 0,
};
pub const TimeCheckResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ClientTime: i64 = 0,
    ServerTime: i64 = 0,
    ServerCombatTime: i64 = 0,
    ServerStopTime: i64 = 0,
    ServerFlowTimestamp: i64 = 0,
};
pub const SwitchRoleType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    SignleWorld = 0,
    MultiWorld = 1,
    FbInstance = 2,
};
pub const FormationRoleInfo = struct {
    pub const default: @This() = .{};
    roleId: i32 = 0,
    MaxHp: i32 = 0,
    CurHp: i32 = 0,
    Level: i32 = 0,
    RoleSkinId: i32 = 0,
    SkillBranchId: i32 = 0,
    WeaponId: i32 = 0,
    WeaponBreachLevel: i32 = 0,
    WeaponSkinId: i32 = 0,
    DressList: std.ArrayList(i32) = .empty,
};
pub const FightFormationNotifyInfo = struct {
    pub const default: @This() = .{};
    FormationId: i32 = 0,
    CurRole: i32 = 0,
    RoleInfos: std.ArrayList(FormationRoleInfo) = .empty,
    IsCurrent: bool = false,
};
pub const FightFormation = struct {
    pub const default: @This() = .{};
    FormationId: i32 = 0,
    CurRole: i32 = 0,
    RoleIds: std.ArrayList(i32) = .empty,
    IsCurrent: bool = false,
};
pub const SwitchRoleRequest = struct {
    pub const default: @This() = .{};
    transform: ?union(enum) {
        Transform: ?Transform,
    } = null,
    RoleId: i32 = 0,
    SwitchType: ?SwitchRoleType = null,
    OnStageWithoutControl: bool = false,
};
pub const SwitchRoleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
};
pub const RoleGoDownPush = struct {
    pub const default: @This() = .{};
};
pub const UpdateFormationRequest = struct {
    pub const default: @This() = .{};
    Formations: std.ArrayList(FightFormation) = .empty,
};
pub const UpdateFormationResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Formation: ?FightFormation = null,
};
pub const PlayerFightFormations = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    Formations: std.ArrayList(FightFormationNotifyInfo) = .empty,
};
pub const UpdateFormationNotify = struct {
    pub const default: @This() = .{};
    PlayersFormations: std.ArrayList(PlayerFightFormations) = .empty,
};
pub const GetFormationDataRequest = struct {
    pub const default: @This() = .{};
};
pub const GetFormationDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Formations: std.ArrayList(FightFormation) = .empty,
};
pub const ClientCurrentRoleReportRequest = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    CurrentRoleId: i32 = 0,
    CurrentEntityId: i64 = 0,
};
pub const ClientCurrentRoleReportPush = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    CurrentRoleId: i32 = 0,
    CurrentEntityId: i64 = 0,
};
pub const ClientCurrentRoleReportResponse = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    CurrentEntityId: i64 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const ControlType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Unknown = 0,
    TemporaryTeleportCtrl = 1,
};
pub const ControlTemporaryTeleportParam = struct {
    pub const default: @This() = .{};
    TemporaryTeleportIds: std.ArrayList(i64) = .empty,
};
pub const ControlParam = struct {
    pub const default: @This() = .{};
    Param: ?union(enum) {
        TemporaryTeleportParam: ?ControlTemporaryTeleportParam,
    } = null,
    ControlType: i32 = 0,
};
pub const ControlInfoNotify = struct {
    pub const default: @This() = .{};
    ForbidList: std.ArrayList(ControlParam) = .empty,
};
pub const DirectTrainGetPlayerIdRequest = struct {
    pub const default: @This() = .{};
};
pub const DirectTrainGetPlayerIdResponse = struct {
    pub const default: @This() = .{};
    MU1: ?union(enum) {
        Activities: ?ActivityData,
    } = null,
    Activitys: std.ArrayList(ActivityData) = .empty,
};
pub const EnergyInfo = struct {
    pub const default: @This() = .{};
    EnergyCount: i32 = 0,
    LastRenewEnergyTime: i32 = 0,
    EnergyType: i32 = 0,
};
pub const EnergyUpdateNotify = struct {
    pub const default: @This() = .{};
    UpdateInfo: std.ArrayList(EnergyInfo) = .empty,
};
pub const EnergySyncRequest = struct {
    pub const default: @This() = .{};
    EnergyTypes: std.ArrayList(i32) = .empty,
};
pub const EnergySyncResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SyncInfo: std.ArrayList(EnergyInfo) = .empty,
};
pub const ExploreProgressRequest = struct {
    pub const default: @This() = .{};
    AreaIds: std.ArrayList(i32) = .empty,
};
pub const AreaExploreInfo = struct {
    pub const default: @This() = .{};
    AreaId: i32 = 0,
    ExploreProgress: std.ArrayList(OneExploreItem) = .empty,
    ExplorePercent: i32 = 0,
};
pub const OneExploreItem = struct {
    pub const default: @This() = .{};
    ExploreProgressId: i32 = 0,
    ExplorePercent: i32 = 0,
    CurCount: i32 = 0,
    TotalCount: i32 = 0,
    IsLocked: bool = false,
};
pub const ExploreProgressResponse = struct {
    pub const default: @This() = .{};
    AreaProgress: std.ArrayList(AreaExploreInfo) = .empty,
};
pub const MultiExploreScoreRewardRequest = struct {
    pub const default: @This() = .{};
    nBs: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const MultiExploreScoreRewardResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CountryExploreScoreInfoRequest = struct {
    pub const default: @This() = .{};
    CountryId: i32 = 0,
};
pub const CountryExploreScoreInfoResponse = struct {
    pub const default: @This() = .{};
    ExploreScore: i32 = 0,
    CountryExploreScoreReceived: std.ArrayList(CountryExploreScoreReceived) = .empty,
};
pub const CountryExploreScoreReceived = struct {
    pub const default: @This() = .{};
    AreaId: i32 = 0,
    ExploreProgress: std.ArrayList(i32) = .empty,
};
pub const CountryExploreLevel = struct {
    pub const default: @This() = .{};
    CountryId: i32 = 0,
    ExploreLevel: i32 = 0,
};
pub const ExploreLevelNotify = struct {
    pub const default: @This() = .{};
    CountryExploreLevel: std.ArrayList(CountryExploreLevel) = .empty,
};
pub const ReceiveAreaStageRewardAsyncRequest = struct {
    pub const default: @This() = .{};
    AreaStageRewardDataList: std.ArrayList(i32) = .empty,
};
pub const ReceiveAreaStageRewardAsyncResponse = struct {
    pub const default: @This() = .{};
    AreaStageRewardDataList: std.ArrayList(i32) = .empty,
};
pub const ExploreProgressRewardIdsNotify = struct {
    pub const default: @This() = .{};
    AreaStageRewardDataList: std.ArrayList(i32) = .empty,
};
pub const ExploreToolAllNotify = struct {
    pub const default: @This() = .{};
    SkillList: std.ArrayList(i32) = .empty,
    ExploreSkill: i32 = 0,
    NewUnlock: std.ArrayList(i32) = .empty,
};
pub const RouletteType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Explore = 0,
    Function = 1,
    TrapDefense = 2,
    Motorcycle = 3,
};
pub const ExploreSkillRouletteUpdateNotify = struct {
    pub const default: @This() = .{};
    RouletteInfo: std.ArrayList(ExploreSkillRoulette) = .empty,
};
pub const VisionExploreSkillSetRequest = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
    IsAutoChange: bool = false,
    RouletteType: ?RouletteType = null,
};
pub const VisionExploreSkillSetResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SkillId: i32 = 0,
};
pub const VisionExploreSkillNotify = struct {
    pub const default: @This() = .{};
    ExploreSkill: i32 = 0,
};
pub const ExploreSkillRoulette = struct {
    pub const default: @This() = .{};
    SkillIds: std.ArrayList(i32) = .empty,
    ExtraItemId: i32 = 0,
    ExploreSkill: i32 = 0,
};
pub const ExploreSkillRouletteSetRequest = struct {
    pub const default: @This() = .{};
    SkillRoulette: ?ExploreSkillRoulette = null,
    RouletteType: ?RouletteType = null,
    SkillRoulettes: std.ArrayList(ExploreSkillRoulette) = .empty,
};
pub const ExploreSkillRouletteSetResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SkillRoulette: ?ExploreSkillRoulette = null,
    RouletteType: ?RouletteType = null,
    SkillRoulettes: std.ArrayList(ExploreSkillRoulette) = .empty,
};
pub const UnlockIllustratedPhantom = struct {
    pub const default: @This() = .{};
    MonsterId: i32 = 0,
    SkinIds: std.ArrayList(i32) = .empty,
    EqupiedSkin: i32 = 0,
    IsSpecial: bool = false,
};
pub const PhantomInteractionUnlockNotify = struct {
    pub const default: @This() = .{};
    UnlockIllustratedPhantoms: std.ArrayList(UnlockIllustratedPhantom) = .empty,
    EquipedMonsterIds: std.ArrayList(i32) = .empty,
};
pub const PhantomInteractionInfoUpdateNotify = struct {
    pub const default: @This() = .{};
    UnlockIllustratedPhantom: ?UnlockIllustratedPhantom = null,
};
pub const PhantomInteractionEquipRequest = struct {
    pub const default: @This() = .{};
    EquipedMonsterIds: std.ArrayList(i32) = .empty,
};
pub const PhantomInteractionEquipResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SkinChangeInfo = struct {
    pub const default: @This() = .{};
    MonsterId: i32 = 0,
    SkinId: i32 = 0,
};
pub const PhantomInteractionSkinChangeRequest = struct {
    pub const default: @This() = .{};
    SkinChangeInfos: std.ArrayList(SkinChangeInfo) = .empty,
};
pub const PhantomInteractionSkinChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FavorQuest = struct {
    pub const default: @This() = .{};
    Chapter: i32 = 0,
    Status: ?FavorQuestStatus = null,
};
pub const FavorQuestStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Locked = 0,
    CanAccept = 1,
    Accepted = 2,
    Completed = 3,
};
pub const FavorItemStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ItemLocked = 0,
    ItemCanUnLock = 1,
    ItemUnLocked = 2,
};
pub const FavorItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: ?FavorItemStatus = null,
};
pub const RoleFavor = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Level: i32 = 0,
    Exp: i32 = 0,
    WordIds: std.ArrayList(FavorItem) = .empty,
    StoryIds: std.ArrayList(FavorItem) = .empty,
    GoodsIds: std.ArrayList(FavorItem) = .empty,
    FavorQuest: ?FavorQuest = null,
};
pub const RoleFavorListRequest = struct {
    pub const default: @This() = .{};
};
pub const RoleFavorListResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    FavorList: std.ArrayList(RoleFavor) = .empty,
};
pub const RoleFavorListNotify = struct {
    pub const default: @This() = .{};
    FavorList: std.ArrayList(RoleFavor) = .empty,
    RoleConditionInfoMap: std.ArrayList(MapEntry(i32, ConditionInfo)) = .empty,
};
pub const ItemFinishList = struct {
    pub const default: @This() = .{};
    ConditionIdList: std.ArrayList(i32) = .empty,
};
pub const ConditionItem = struct {
    pub const default: @This() = .{};
    ItemFinishMap: std.ArrayList(MapEntry(i32, ItemFinishList)) = .empty,
};
pub const ConditionInfo = struct {
    pub const default: @This() = .{};
    FinishConditionMap: std.ArrayList(MapEntry(i32, ConditionItem)) = .empty,
};
pub const RoleMotion = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    MotionIds: std.ArrayList(FavorItem) = .empty,
};
pub const RoleMotionListNotify = struct {
    pub const default: @This() = .{};
    MotionList: std.ArrayList(RoleMotion) = .empty,
    RoleConditionInfoMap: std.ArrayList(MapEntry(i32, ConditionInfo)) = .empty,
};
pub const FishingDataRequest = struct {
    pub const default: @This() = .{};
};
pub const FishingDataResponse = struct {
    pub const default: @This() = .{};
    FishingData: ?FishingData = null,
};
pub const FishingData = struct {
    pub const default: @This() = .{};
    Entrusts: std.ArrayList(MapEntry(i32, FishingEntrustStatus)) = .empty,
    TraceEntrusts: i32 = 0,
    FishingTech: std.ArrayList(FishingTechInfo) = .empty,
    ShipInfo: ?FishingShipInfo = null,
    IllustratedInfo: ?FishingIllustratedInfo = null,
    SceneCages: std.ArrayList(MapEntry(i32, SceneFishCageInfo)) = .empty,
    SceneFishPoints: std.ArrayList(MapEntry(i32, SceneFishPointInfo)) = .empty,
    NoticeIds: std.ArrayList(i32) = .empty,
    HandInInfo: std.ArrayList(HandInInfo) = .empty,
    UnlockPortId: std.ArrayList(i32) = .empty,
    PhantomSkinList: std.ArrayList(i32) = .empty,
    EntrustRefreshRatio: i32 = 0,
};
pub const FishingEntrustStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Created = 0,
    Acceptable = 1,
    Accepted = 2,
};
pub const FishingTechInfo = struct {
    pub const default: @This() = .{};
    NodeId: i32 = 0,
    Level: i32 = 0,
    CanUnlock: bool = false,
};
pub const FishingShipInfo = struct {
    pub const default: @This() = .{};
    SkinId: i32 = 0,
    SailingTime: i64 = 0,
    IsSailing: bool = false,
    CabinInfo: ?CabinInfo = null,
    EntityId: i64 = 0,
    IsInPort: bool = false,
    PortId: i32 = 0,
    LastPortId: i32 = 0,
};
pub const FishingIllustratedInfo = struct {
    pub const default: @This() = .{};
    IllustratedList: std.ArrayList(OneFishingIllustratedData) = .empty,
    RewardedId: std.ArrayList(FishingIllustratedRewardInfo) = .empty,
    UnlockDetections: std.ArrayList(i32) = .empty,
};
pub const OneFishingIllustratedData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    MaxSize: i32 = 0,
    MinSize: i32 = 0,
};
pub const FishingItemRotate = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    No = 0,
    DirectionDown = 1,
    DirectionLeft = 2,
    DirectionUp = 3,
};
pub const FishCup = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    SilverCup = 0,
    NormalCup = 1,
    GoldCup = 2,
};
pub const FishingItemInfo = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    IncrId: i32 = 0,
    Rotate: ?FishingItemRotate = null,
    Pos: ?IntVector2D = null,
    Size: i32 = 0,
    Cup: ?FishCup = null,
    Quality: i32 = 0,
    Price: i32 = 0,
};
pub const IntVector2D = struct {
    pub const default: @This() = .{};
    X: i32 = 0,
    Y: i32 = 0,
};
pub const CabinInfo = struct {
    pub const default: @This() = .{};
    FishingItem: std.ArrayList(FishingItemInfo) = .empty,
    CabinShape: i32 = 0,
    QuickSellShape: i32 = 0,
    NetCabinItems: std.ArrayList(FishingItemInfo) = .empty,
    TempCabinItems: std.ArrayList(FishingItemInfo) = .empty,
    QuickSellRatio: i32 = 0,
};
pub const SceneFishCageInfo = struct {
    pub const default: @This() = .{};
    Cages: std.ArrayList(SceneFishCageData) = .empty,
};
pub const SceneFishCageData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    EntityConfigId: i32 = 0,
    MaxCount: i32 = 0,
    Items: std.ArrayList(FishingItemInfo) = .empty,
    LastUpdateTime: i64 = 0,
    NextUpdateTime: i64 = 0,
    RefreshTime: i32 = 0,
};
pub const SceneFishPointInfo = struct {
    pub const default: @This() = .{};
    FishPoints: std.ArrayList(SceneFishPointData) = .empty,
    TempFishPoints: std.ArrayList(TempFishPointInfo) = .empty,
};
pub const SceneFishPointData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    EntityConfigId: i32 = 0,
    CurCount: i32 = 0,
    MaxCount: i32 = 0,
    LastUpdateTime: i64 = 0,
    NextUpdateTime: i64 = 0,
    RefreshTime: i32 = 0,
    GamePlayId: i32 = 0,
    Interacted: bool = false,
};
pub const TempFishPointInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    CurCount: i32 = 0,
    MaxCount: i32 = 0,
    ConfigId: i32 = 0,
    GamePlayId: i32 = 0,
};
pub const FishingIllustratedRewardInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    CurrentProgress: i32 = 0,
    TargetProgress: i32 = 0,
    HasPassed: bool = false,
    IsTaken: bool = false,
};
pub const HandInInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    FishingItem: std.ArrayList(FishingItemInfo) = .empty,
};
pub const FlowStartNotify = struct {
    pub const default: @This() = .{};
    FlowIncId: i64 = 0,
    FlowListName: []const u8 = "",
    FlowId: i32 = 0,
    StateId: i32 = 0,
    GameCtx: ?GameCtxPb = null,
    PlotMode: []const u8 = "",
    aAsync: bool = false,
    IsSkip: bool = false,
    HasPlotPos: bool = false,
    PlotCoordinates: ?Vector = null,
};
pub const FlowEndRequest = struct {
    pub const default: @This() = .{};
    FlowIncId: i64 = 0,
    IsSkip: bool = false,
    OptionInfos: std.ArrayList(MapEntry(i32, FlowOptionInfoList)) = .empty,
};
pub const FlowOptionInfoList = struct {
    pub const default: @This() = .{};
    OptionIndexList: std.ArrayList(FlowOptionInfo) = .empty,
};
pub const FlowOptionInfo = struct {
    pub const default: @This() = .{};
    TalkId: i32 = 0,
    OptionIndex: i32 = 0,
};
pub const FlowEndResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FlySkinEquipData = struct {
    pub const default: @This() = .{};
    SkinId: i32 = 0,
    RoleIds: std.ArrayList(i32) = .empty,
};
pub const RoleFlyEquipNotify = struct {
    pub const default: @This() = .{};
    FlySkinEquipData: std.ArrayList(FlySkinEquipData) = .empty,
};
pub const FlySkinWearRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkinId: i32 = 0,
};
pub const FlySkinWearResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const EquipFlySkinData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkinId: i32 = 0,
};
pub const FlySkinWearAllRoleRequest = struct {
    pub const default: @This() = .{};
    SkinId: i32 = 0,
};
pub const FlySkinWearAllRoleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    FlySkinData: std.ArrayList(EquipFlySkinData) = .empty,
};
pub const RoleFlyEquipChangeNotify = struct {
    pub const default: @This() = .{};
    FlySkinData: std.ArrayList(EquipFlySkinData) = .empty,
};
pub const FlySkinConfigData = struct {
    pub const default: @This() = .{};
    SkinId: i32 = 0,
    FlySkinId: i32 = 0,
};
pub const EntityFlySkinChangeData = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    FlySkinConfigData: std.ArrayList(FlySkinConfigData) = .empty,
};
pub const SoarWingOrParaglidingSkinChangeNotify = struct {
    pub const default: @This() = .{};
    FlySkinData: std.ArrayList(EntityFlySkinChangeData) = .empty,
};
pub const FlyEquipAddNotify = struct {
    pub const default: @This() = .{};
    UnlockFlySkinIds: std.ArrayList(i32) = .empty,
};
pub const ForgeInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const ForgeInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ForgeInfoList: std.ArrayList(OneForgeInfo) = .empty,
    ForgeConfigs: std.ArrayList(OneForgeConfig) = .empty,
    LimitRefreshTime: i64 = 0,
};
pub const OneForgeInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    LastRoleId: i32 = 0,
    LimitTotalCount: i32 = 0,
    LimitForgeCount: i32 = 0,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const OneForgeConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const Formation = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    RoleIndex: i32 = 0,
    Role: std.ArrayList(i32) = .empty,
    IsCurrent: bool = false,
};
pub const FriendInfo = struct {
    pub const default: @This() = .{};
    Info: ?PlayerDetails = null,
    Remark: []const u8 = "",
};
pub const FriendApply = struct {
    pub const default: @This() = .{};
    Info: ?PlayerDetails = null,
    CreatedTime: i64 = 0,
};
pub const FriendAllRequest = struct {
    pub const default: @This() = .{};
};
pub const FriendAllResponse = struct {
    pub const default: @This() = .{};
    FriendInfoList: std.ArrayList(FriendInfo) = .empty,
    FriendApplyList: std.ArrayList(FriendApply) = .empty,
    ErrorCode: ?ErrorCode = null,
};
pub const Function = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Flag: i32 = 0,
};
pub const FuncOpenNotify = struct {
    pub const default: @This() = .{};
    Func: std.ArrayList(Function) = .empty,
};
pub const GachaConsume = struct {
    pub const default: @This() = .{};
    Times: i32 = 0,
    Consume: i32 = 0,
};
pub const GachaDiscountInfo = struct {
    pub const default: @This() = .{};
    Times: i32 = 0,
    LimitTimes: i32 = 0,
    DiscountConsume: i32 = 0,
    UsedTimes: i32 = 0,
};
pub const GachaPoolInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
    Title: []const u8 = "",
    Description: []const u8 = "",
    UiType: i32 = 0,
    ThemeColor: []const u8 = "",
    ShowIdList: std.ArrayList(i32) = .empty,
    UpList: std.ArrayList(i32) = .empty,
    PreviewIdList: std.ArrayList(i32) = .empty,
    ComplianceDetail: []const u8 = "",
};
pub const GachaInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    TodayTimes: i32 = 0,
    TotalTimes: i32 = 0,
    ItemId: i32 = 0,
    GachaConsumes: std.ArrayList(GachaConsume) = .empty,
    UsePoolId: i32 = 0,
    Pools: std.ArrayList(GachaPoolInfo) = .empty,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
    DailyLimitTimes: i32 = 0,
    TotalLimitTimes: i32 = 0,
    ResourcesId: []const u8 = "",
    GachaAccumulateId: i32 = 0,
    GachaDiscountInfos: std.ArrayList(GachaDiscountInfo) = .empty,
    OnlyViewDiscount: bool = false,
    IsShowProgress: bool = false,
    DiscountTagDetails: std.ArrayList(MapEntry(i32, []const u8)) = .empty,
};
pub const GachaReward = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    ItemCount: i32 = 0,
};
pub const GachaResult = struct {
    pub const default: @This() = .{};
    Bottom: ?union(enum) {
        BottomExtraReward: ?GachaReward,
    } = null,
    GachaReward: ?GachaReward = null,
    ExtraRewards: std.ArrayList(GachaReward) = .empty,
    TransformRewards: std.ArrayList(GachaReward) = .empty,
};
pub const GachaInfoRequest = struct {
    pub const default: @This() = .{};
    Language: i32 = 0,
};
pub const GachaInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    GachaInfos: std.ArrayList(GachaInfo) = .empty,
    DailyTotalLeftTimes: i32 = 0,
    RecordId: []const u8 = "",
};
pub const GachaRequest = struct {
    pub const default: @This() = .{};
    GachaId: i32 = 0,
    GachaTimes: i32 = 0,
};
pub const GachaResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    GachaResults: std.ArrayList(GachaResult) = .empty,
};
pub const GachaUsePoolRequest = struct {
    pub const default: @This() = .{};
    GachaId: i32 = 0,
    PoolId: i32 = 0,
};
pub const GachaUsePoolResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const GachaItem = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    IsUp: bool = false,
};
pub const GachaPoolDetail = struct {
    pub const default: @This() = .{};
    Text: []const u8 = "",
    FiveStarRoles: std.ArrayList(GachaItem) = .empty,
    FiveStarWeapons: std.ArrayList(GachaItem) = .empty,
    FourStarRoles: std.ArrayList(GachaItem) = .empty,
    FourStarWeapons: std.ArrayList(GachaItem) = .empty,
    ThreeStarRoles: std.ArrayList(GachaItem) = .empty,
    FiveStarTitle: []const u8 = "",
    FileStarDetail: []const u8 = "",
    FourStarTitle: []const u8 = "",
    FourStarDetail: []const u8 = "",
    ThreeStarTitle: []const u8 = "",
    ThreeStarDetail: []const u8 = "",
};
pub const GachaPoolDetailRequest = struct {
    pub const default: @This() = .{};
    PoolId: i32 = 0,
};
pub const GachaPoolDetailResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    GachaPoolDetail: ?GachaPoolDetail = null,
};
pub const GivebackInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const GivebackInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const GuideInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const GuideInfoResponse = struct {
    pub const default: @This() = .{};
    GuideGroupFinishList: std.ArrayList(i32) = .empty,
};
pub const GuideTriggerRequest = struct {
    pub const default: @This() = .{};
    GroupId: i32 = 0,
};
pub const GuideTriggerResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
};
pub const GuideFinishRequest = struct {
    pub const default: @This() = .{};
    GroupId: i32 = 0,
};
pub const GuideFinishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
};
pub const HeartbeatRequest = struct {
    pub const default: @This() = .{};
    AntiData: []const u8 = "",
};
pub const HeartbeatResponse = struct {
    pub const default: @This() = .{};
};
pub const IllustratedType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Monster = 0,
    VocalCorpse = 1,
    ViewPoint = 2,
    Weapon = 3,
    Animal = 4,
    Item = 5,
    Chip = 6,
    Photograph = 7,
    Noun = 8,
};
pub const PhotographSubType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    None = 0,
    PhotographSub = 7,
    Role = 8,
    Quest = 9,
};
pub const IllustratedEntry = struct {
    pub const default: @This() = .{};
    SubType: ?union(enum) {
        PhotographSubType: ?PhotographSubType,
    } = null,
    Id: i32 = 0,
    CreateTime: u32 = 0,
    Num: i32 = 0,
    IsRead: bool = false,
};
pub const IllustratedClass = struct {
    pub const default: @This() = .{};
    Type: ?IllustratedType = null,
    IllustratedEntryList: std.ArrayList(IllustratedEntry) = .empty,
};
pub const IllustratedInfoRequest = struct {
    pub const default: @This() = .{};
    TypeList: std.ArrayList(IllustratedType) = .empty,
};
pub const IllustratedInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
    IllustratedClassList: std.ArrayList(IllustratedClass) = .empty,
};
pub const RoleIllustratedInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const RoleIllustratedInfoResponse = struct {
    pub const default: @This() = .{};
    Roles: std.ArrayList(RoleHandbookInfo) = .empty,
    Weapons: std.ArrayList(WeaponHandbookInfo) = .empty,
};
pub const RoleHandbookInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    UnlockTime: i64 = 0,
};
pub const WeaponHandbookInfo = struct {
    pub const default: @This() = .{};
    WeaponId: i32 = 0,
    UnlockTime: i64 = 0,
};
pub const InfluenceInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const InfluenceInfoResponse = struct {
    pub const default: @This() = .{};
    InfluenceInfos: std.ArrayList(InfluenceInfo) = .empty,
};
pub const InfluenceInfo = struct {
    pub const default: @This() = .{};
    InfluenceId: i32 = 0,
    RewardIndex: i32 = 0,
    Relation: i32 = 0,
};
pub const InfrInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const InfrInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    InfrInfo: ?InfrPb = null,
};
pub const InfrRoadUpdateNotify = struct {
    pub const default: @This() = .{};
    RoadInfo: ?InfrRoadPb = null,
};
pub const InfrPb = struct {
    pub const default: @This() = .{};
    FireInfo: ?InfrFirePb = null,
    RoadInfo: ?InfrRoadPb = null,
    LibraryInfo: ?InfrLibraryPb = null,
};
pub const InfrLibraryPb = struct {
    pub const default: @This() = .{};
    ArchiveTasks: std.ArrayList(InfrTaskPb) = .empty,
    PhoneTasks: std.ArrayList(InfrTaskPb) = .empty,
    UnreadArchives: std.ArrayList(i32) = .empty,
};
pub const InfrTaskPb = struct {
    pub const default: @This() = .{};
    TaskId: i32 = 0,
    Target: i32 = 0,
    status: ?InfrTaskStatusPb = null,
};
pub const InfrTaskStatusPb = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    InfrTaskRunning = 0,
    InfrTaskFinish = 1,
    InfrTaskTaken = 2,
};
pub const InfrFirePb = struct {
    pub const default: @This() = .{};
    FireExp: i64 = 0,
    FireLevel: i32 = 0,
    FireLevelReachTime: i64 = 0,
    FireStatus: ?InfrStatusPb = null,
};
pub const InfrRoadPb = struct {
    pub const default: @This() = .{};
    Roads: std.ArrayList(InfrOneRoad) = .empty,
    Notices: std.ArrayList(InfrNotice) = .empty,
    ManualTraceRoad: i32 = 0,
    RecommendRoad: i32 = 0,
};
pub const InfrOneRoad = struct {
    pub const default: @This() = .{};
    RoadId: i32 = 0,
    status: ?InfrStatusPb = null,
    CompleteTime: i64 = 0,
    TotalGiftCount: i64 = 0,
    LastGiftTime: i64 = 0,
};
pub const InfrStatusPb = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    InfrStatusLock = 0,
    InfrStatusProgress = 1,
    InfrStatusComplete = 2,
};
pub const InfrNotice = struct {
    pub const default: @This() = .{};
    RoadId: i32 = 0,
    PasserId: i32 = 0,
    GiftCount: i32 = 0,
    CreateTime: i64 = 0,
};
pub const InfrV2Pb = struct {
    pub const default: @This() = .{};
    FireInfo: ?InfrV2FirePb = null,
    TreeInfo: ?InfrV2TreePb = null,
    RewardScoreIds: std.ArrayList(i32) = .empty,
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
    TreeFinishCond: std.ArrayList(i32) = .empty,
};
pub const InfrV2InfoRequest = struct {
    pub const default: @This() = .{};
};
pub const InfrV2InfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    InfrInfo: ?InfrV2Pb = null,
};
pub const InfrV2FirePb = struct {
    pub const default: @This() = .{};
    FireExp: i64 = 0,
    FireLevel: i32 = 0,
    FireLevelReachTime: i64 = 0,
    FireStatus: i32 = 0,
};
pub const InfrV2TreePb = struct {
    pub const default: @This() = .{};
    Trees: std.ArrayList(InfrV2OneTree) = .empty,
    ManualTraceTree: i32 = 0,
};
pub const InfrV2OneTree = struct {
    pub const default: @This() = .{};
    TreeId: i32 = 0,
    status: i32 = 0,
    CompleteTime: i64 = 0,
    TotalGiftCount: i64 = 0,
    LastGiftTime: i64 = 0,
};
pub const InstDataNotify = struct {
    pub const default: @This() = .{};
    EnterInfos: std.ArrayList(InstEnterInfoPb) = .empty,
};
pub const InstEnterInfoPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    ChallengedTimes: i32 = 0,
};
pub const CreateInstanceDungeonNotify = struct {
    pub const default: @This() = .{};
    LevelPlayId: i32 = 0,
};
pub const ExchangeRewardRequest = struct {
    pub const default: @This() = .{};
};
pub const ExchangeRewardResponse = struct {
    pub const default: @This() = .{};
    ExchangeShareData: std.ArrayList(MapEntry(i32, i32)) = .empty,
    ExchangeRewardData: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const ItemExchangeInfo = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    TodayTimes: i32 = 0,
    TotalTimes: i32 = 0,
    DailyLimit: i32 = 0,
    TotalLimit: i32 = 0,
};
pub const ItemExchangeInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const ItemExchangeInfoResponse = struct {
    pub const default: @This() = .{};
    ItemExchangeInfos: std.ArrayList(ItemExchangeInfo) = .empty,
};
pub const SimpleCombatEntityAttributePbInfo = struct {
    pub const default: @This() = .{};
    AttributeMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
    LockedAttributeMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const LevelPlayInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IsFirst: bool = false,
    State: i32 = 0,
    UpdateTime: i64 = 0,
    GetRewardCount: i32 = 0,
};
pub const LevelPlayInfoNotify = struct {
    pub const default: @This() = .{};
    LevelPlayInfo: std.ArrayList(LevelPlayInfo) = .empty,
};
pub const SimpleTrackReportAsyncRequest = struct {
    pub const default: @This() = .{};
};
pub const SimpleTrackReportAsyncResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SimpleTrackReportMsgs: std.ArrayList(SimpleTrackReportMsg) = .empty,
};
pub const SimpleTrackReportMsg = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    LevelPlayId: i32 = 0,
    GainTreasureCount: i32 = 0,
};
pub const LevelPlayVarAsyncRequest = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    LevelPlayId: i32 = 0,
};
pub const LevelPlayVarAsyncResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Vars: std.ArrayList(MapEntry([]const u8, VarDefinePb)) = .empty,
};
pub const PlayPointStateAsyncRequest = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    ArenaId: i32 = 0,
};
pub const PlayPointStateAsyncResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    LevelPlayStateDict: std.ArrayList(MapEntry(i32, LevelPlayStateMsg)) = .empty,
};
pub const LevelPlayStateMsg = struct {
    pub const default: @This() = .{};
    LevelPlayEntityId: i32 = 0,
    ExploratoryType: i32 = 0,
    StateType: i32 = 0,
    CompleteNumber: i32 = 0,
    IsHide: bool = false,
    HideGroupInfo: []const u8 = "",
    IsUnlocked: bool = false,
    LevelPlayMarkUnlock: bool = false,
};
pub const LivenessInfo = struct {
    pub const default: @This() = .{};
    LivenessCount: i32 = 0,
    RewardedLiveness: std.ArrayList(i32) = .empty,
    Tasks: std.ArrayList(LivenessTask) = .empty,
    DayEnd: i64 = 0,
    AreaId: i32 = 0,
};
pub const LivenessTask = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Current: i32 = 0,
    Target: i32 = 0,
    IsFinished: bool = false,
    IsTaken: bool = false,
    ConditionFinishState: bool = false,
};
pub const LivenessRequest = struct {
    pub const default: @This() = .{};
};
pub const LivenessResponse = struct {
    pub const default: @This() = .{};
    LivenessInfo: ?LivenessInfo = null,
};
pub const LivenessTakeRequest = struct {
    pub const default: @This() = .{};
    Ids: std.ArrayList(i32) = .empty,
};
pub const LivenessTakeResponse = struct {
    pub const default: @This() = .{};
    Ids: std.ArrayList(i32) = .empty,
    ErrorCode: ?ErrorCode = null,
};
pub const RoleLoadEquipData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Pos: ?EquipPos = null,
    EquipIncId: i32 = 0,
};
pub const LoadEquipData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkinId: i32 = 0,
};
pub const EquipPos = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Weapon = 0,
    WeaponSkin = 1,
    End = 2,
};
pub const WeaponSkinRequest = struct {
    pub const default: @This() = .{};
};
pub const WeaponSkinResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipList: std.ArrayList(LoadEquipData) = .empty,
};
pub const EquipTakeOnRequest = struct {
    pub const default: @This() = .{};
    Data: ?RoleLoadEquipData = null,
};
pub const EquipTakeOnResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    DataList: std.ArrayList(RoleLoadEquipData) = .empty,
};
pub const EquipTakeOnNotify = struct {
    pub const default: @This() = .{};
    DataList: std.ArrayList(RoleLoadEquipData) = .empty,
};
pub const UnlockSkinDataNotify = struct {
    pub const default: @This() = .{};
    PhantomSkinList: std.ArrayList(i32) = .empty,
    IsLogin: bool = false,
};
pub const WeaponSkinDeleteNotify = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkinId: i32 = 0,
};
pub const EquipWeaponSkinRequest = struct {
    pub const default: @This() = .{};
    Data: ?LoadEquipData = null,
};
pub const EquipWeaponSkinResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    DataList: std.ArrayList(LoadEquipData) = .empty,
};
pub const SendEquipSkinRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const SendEquipSkinResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AceBlackProductAccountInfo = struct {
    pub const default: @This() = .{};
    TdmDeviceId: []const u8 = "",
    IsRoot: bool = false,
    IsSimulator: bool = false,
};
pub const DevLoginCheckData = struct {
    pub const default: @This() = .{};
    ProtoVersion: i32 = 0,
    ProtoMD5: []const u8 = "",
    ConfigVersion: i32 = 0,
    ConfigMD5: []const u8 = "",
    BranchName: []const u8 = "",
    ProtoSeedMD5: []const u8 = "",
};
pub const LoginRequest = struct {
    pub const default: @This() = .{};
    DevLoginCheck: ?union(enum) {
        DevLoginCheckData: ?DevLoginCheckData,
    } = null,
    Id: i32 = 0,
    Account: []const u8 = "",
    LoginTraceId: []const u8 = "",
    Token: []const u8 = "",
    AppVersion: []const u8 = "",
    LauncherVersion: []const u8 = "",
    ResourceVersion: []const u8 = "",
    ClientBasicInfo: ?ClientBasicInfo = null,
    PublicResourceVersionInfo: ?PublicResourceVersionInfo = null,
    AceBlackProductAccountInfo: ?AceBlackProductAccountInfo = null,
    PushNotificationsEnabled: bool = false,
    ClientId: []const u8 = "",
    SdkUserId: []const u8 = "",
    SdkOnlineId: []const u8 = "",
    SdkAccountId: []const u8 = "",
    PackageClientFightConfig: []const u8 = "",
    LimitState: i32 = 0,
    FsmVersion: i32 = 0,
    ConfirmQuestResource: bool = false,
    QuestReourceState: i32 = 0,
    IsLowMemorePlatform: bool = false,
    BlockState: ?BlockState = null,
    downloadResourceQuestId: std.ArrayList(i32) = .empty,
    XboxUserId: []const u8 = "",
    XboxOnlineId: []const u8 = "",
    XboxAccountId: []const u8 = "",
    XboxSocialState: i32 = 0,
    XstsToken: []const u8 = "",
};
pub const LoginResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ReconnectToken: []const u8 = "",
    Timestamp: i64 = 0,
    Platform: []const u8 = "",
    ClientWaitingMode: i32 = 0,
    ClientWaitingTime: i32 = 0,
    ClientAutoInInterval: i32 = 0,
    ClientDisplayTime: i32 = 0,
};
pub const EnterGameRequest = struct {
    pub const default: @This() = .{};
    SingleInstanceId: i32 = 0,
    MultiInstanceId: i32 = 0,
    Mode: i32 = 0,
    Pos: ?Vector = null,
};
pub const EnterGameResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ClientWaitingMode: i32 = 0,
    ClientWaitingTime: i32 = 0,
    ClientAutoInInterval: i32 = 0,
};
pub const ReconnectRequest = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    LastSvrSeqNo: i32 = 0,
    ReconnectToken: []const u8 = "",
    ReconnectTraceId: []const u8 = "",
};
pub const ReconnectResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    LastRecvSeqNo: i32 = 0,
    Timestamp: i64 = 0,
    IsPermittedSilentLogin: bool = false,
};
pub const LogoutNotify = struct {
    pub const default: @This() = .{};
    Ban: ?union(enum) {
        BanInfo: ?BanLogoutInfo,
    } = null,
    ErrorCode: ?ErrorCode = null,
    logoutReason: i32 = 0,
};
pub const ProtoKeyRequest = struct {
    pub const default: @This() = .{};
    IsLogin: bool = false,
    TraceId: []const u8 = "",
};
pub const ProtoKeyResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Type: i32 = 0,
    Key: []const u8 = "",
};
pub const PushDataCompleteNotify = struct {
    pub const default: @This() = .{};
};
pub const VersionInfoPush = struct {
    pub const default: @This() = .{};
    AppVersion: []const u8 = "",
    LauncherVersion: []const u8 = "",
    ResourceVersion: []const u8 = "",
};
pub const LoadingConfigRequest = struct {
    pub const default: @This() = .{};
};
pub const LoadingConfigResponse = struct {
    pub const default: @This() = .{};
    LoadingConfig: std.ArrayList(LoadingConfig) = .empty,
};
pub const LoadingConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const PublicResourceVersionInfo = struct {
    pub const default: @This() = .{};
    PublicJsonVersion: i32 = 0,
    PublicMiscVersion: i32 = 0,
    PublicUniverseEditorVersion: i32 = 0,
};
pub const MailLevel = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    None = 0,
    General = 1,
    Important = 2,
    Administration = 3,
};
pub const PbMailAttachment = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Count: i32 = 0,
};
pub const PbMailInfo = struct {
    pub const default: @This() = .{};
    Id: []const u8 = "",
    ReceivedTime: i64 = 0,
    ReadTime: i64 = 0,
    State: i32 = 0,
    Level: ?MailLevel = null,
    Title: []const u8 = "",
    Content: []const u8 = "",
    Sender: []const u8 = "",
    ValidTime: i32 = 0,
    ReadValidTime: i32 = 0,
    Attachments: std.ArrayList(PbMailAttachment) = .empty,
    ConfigId: i32 = 0,
    ExpiryTime: i64 = 0,
    IsIntervalMail: bool = false,
};
pub const MailInfosNotify = struct {
    pub const default: @This() = .{};
    MailInfos: std.ArrayList(PbMailInfo) = .empty,
};
pub const MailBindInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const MailBindInfoResponse = struct {
    pub const default: @This() = .{};
    MailBind: ?MailBind = null,
};
pub const MailBind = struct {
    pub const default: @This() = .{};
    IsBind: bool = false,
    IsReward: bool = false,
    CloseTime: i64 = 0,
};
pub const MarkPointState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    MarkNormal = 0,
    MarkDisable = 1,
    MarkComplete = 2,
};
pub const MarkPointInfo = struct {
    pub const default: @This() = .{};
    PosX: f32 = 0,
    PosY: f32 = 0,
    PosZ: f32 = 0,
    ConfigId: i32 = 0,
    MarkId: i32 = 0,
    IsTrace: i32 = 0,
    MarkType: i32 = 0,
    MapId: i32 = 0,
    IsServerDisable: bool = false,
    MarkPointState: ?MarkPointState = null,
};
pub const MarkPointRequestInfo = struct {
    pub const default: @This() = .{};
    PosX: f32 = 0,
    PosY: f32 = 0,
    PosZ: f32 = 0,
    ConfigId: i32 = 0,
    MarkType: i32 = 0,
    MarkInfo: bool = false,
    IsTrace: i32 = 0,
    MapId: i32 = 0,
};
pub const TreasureBoxParam = struct {
    pub const default: @This() = .{};
    TreasureBox: std.ArrayList(MarkPointRequestInfo) = .empty,
    DetectionSlotId: i64 = 0,
};
pub const MarkTreasureBoxInfo = struct {
    pub const default: @This() = .{};
    MarkPointInfo: std.ArrayList(MarkPointInfo) = .empty,
};
pub const AttachMarkInfo = struct {
    pub const default: @This() = .{};
    MarkPointInfo: std.ArrayList(MarkPointInfo) = .empty,
};
pub const MapUnlockFieldInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const MapUnlockFieldInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    FieldId: std.ArrayList(i32) = .empty,
};
pub const MapMarkShowInfo = struct {
    pub const default: @This() = .{};
    MarkId: i32 = 0,
    ShowFlag: u32 = 0,
};
pub const TemporaryTeleportParam = struct {
    pub const default: @This() = .{};
    temporaryTeleportId: i64 = 0,
};
pub const MapMarkRequest = struct {
    pub const default: @This() = .{};
    Params: ?union(enum) {
        TemporaryTeleportParam: ?TemporaryTeleportParam,
        TreasureBoxParam: ?TreasureBoxParam,
    } = null,
    MarkPointRequestInfo: ?MarkPointRequestInfo = null,
};
pub const MapMarkResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Info: ?MarkPointInfo = null,
};
pub const RemoveMapMarkRequest = struct {
    pub const default: @This() = .{};
    MarkList: std.ArrayList(i32) = .empty,
};
pub const RemoveMapMarkResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MarkList: std.ArrayList(i32) = .empty,
};
pub const MapUnlockFieldNotify = struct {
    pub const default: @This() = .{};
    FieldId: i32 = 0,
};
pub const MapTraceInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const MapTraceInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MarkIdList: std.ArrayList(i32) = .empty,
};
pub const MapTraceRequest = struct {
    pub const default: @This() = .{};
    MarkId: i32 = 0,
};
pub const MapTraceResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MarkId: i32 = 0,
};
pub const MapCancelTraceRequest = struct {
    pub const default: @This() = .{};
    MarkId: i32 = 0,
};
pub const MapCancelTraceResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MarkId: i32 = 0,
};
pub const MapMarkInfoNotify = struct {
    pub const default: @This() = .{};
    InfoList: std.ArrayList(MarkPointInfo) = .empty,
    ShowMarkIds: std.ArrayList(MapMarkShowInfo) = .empty,
    UnlockMarkIds: std.ArrayList(i32) = .empty,
    EntityMapMarkInfo: std.ArrayList(EntityMapMarkInfoPb) = .empty,
    SystemMarkHideInfo: std.ArrayList(SystemMarkHideInfoPb) = .empty,
    CompleteMarkIds: std.ArrayList(i32) = .empty,
};
pub const MapMarkAddNotify = struct {
    pub const default: @This() = .{};
    Info: ?MarkPointInfo = null,
    TreasureBoxMarkInfo: ?MarkTreasureBoxInfo = null,
    AttackMark: ?AttachMarkInfo = null,
};
pub const MapUnlockDataNotify = struct {
    pub const default: @This() = .{};
    UnlockMultiMapIds: std.ArrayList(i32) = .empty,
    UnlockMapBlockIds: std.ArrayList(i32) = .empty,
};
pub const EntityMapMarkInfoPb = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    TemplateId: i32 = 0,
    Pos: ?Vector = null,
};
pub const SystemMarkHideInfoPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    MapId: i32 = 0,
    HideInfo: []const u8 = "",
};
pub const MonthCardRequest = struct {
    pub const default: @This() = .{};
};
pub const MonthCardResponse = struct {
    pub const default: @This() = .{};
    Days: i32 = 0,
    IsDailyGot: bool = false,
    ErrorCode: ?ErrorCode = null,
};
pub const MonthCardDailyRewardNotify = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Count: i32 = 0,
    Days: i32 = 0,
};
pub const MotorTaskTypePb = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Unknown = 0,
    Single = 1,
    Limited = 2,
    Cycle = 3,
};
pub const MotorTaskProcessPb = struct {
    pub const default: @This() = .{};
    Current: i32 = 0,
    Target: i32 = 0,
};
pub const MotorTaskRewardPb = struct {
    pub const default: @This() = .{};
    Rewarded: i32 = 0,
    WaitReward: i32 = 0,
    MaxReward: i32 = 0,
};
pub const MotorTaskPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Type: ?MotorTaskTypePb = null,
    Process: ?MotorTaskProcessPb = null,
    Reward: ?MotorTaskRewardPb = null,
    EndTime: i64 = 0,
    StartTime: i64 = 0,
};
pub const MotorInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const MotorInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Motor: ?MotorPb = null,
};
pub const MotorTechLevelUpRequest = struct {
    pub const default: @This() = .{};
    TechId: i32 = 0,
};
pub const MotorTechLevelUpResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Tree: ?MotorTechOneTreePb = null,
};
pub const MotorTechTreeSwitchRequest = struct {
    pub const default: @This() = .{};
    TreeId: i32 = 0,
};
pub const MotorTechTreeSwitchResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    TreeInUse: i32 = 0,
};
pub const MotorLevelOneKeyRewardRequest = struct {
    pub const default: @This() = .{};
};
pub const MotorLevelOneKeyRewardResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MotorRewardedLvMax: i32 = 0,
};
pub const MotorTaskOneKeyRewardRequest = struct {
    pub const default: @This() = .{};
    TaskIds: std.ArrayList(i32) = .empty,
};
pub const MotorTaskOneKeyRewardResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MotorTaskUpdateNotify = struct {
    pub const default: @This() = .{};
    Task: std.ArrayList(MotorTaskPb) = .empty,
};
pub const MotorLockedTechUpdateNotify = struct {
    pub const default: @This() = .{};
    TreeId: i32 = 0,
    Tech: std.ArrayList(MotorTechPb) = .empty,
};
pub const MotorTechPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Level: i32 = 0,
    Unlock: bool = false,
    Current: i32 = 0,
    Target: i32 = 0,
};
pub const MotorTechOneTreePb = struct {
    pub const default: @This() = .{};
    TreeId: i32 = 0,
    Tech: std.ArrayList(MotorTechPb) = .empty,
};
pub const MotorPb = struct {
    pub const default: @This() = .{};
    MotorLevel: i32 = 0,
    MotorExp: i32 = 0,
    MotorRewardedLvMax: i32 = 0,
    UnlockedTree: std.ArrayList(MotorTechOneTreePb) = .empty,
    TreeInUse: i32 = 0,
    TaskTrees: std.ArrayList(MotorTaskTreePb) = .empty,
    MotorExpLimitGainDaily: i32 = 0,
    MotorExpMonsterDropDailyLimit: i32 = 0,
};
pub const MotorTaskTreePb = struct {
    pub const default: @This() = .{};
    TreeId: i32 = 0,
    Tasks: std.ArrayList(MotorTaskPb) = .empty,
    TpRewarded: i32 = 0,
};
pub const MotorCreateRequest = struct {
    pub const default: @This() = .{};
    IsCreate: bool = false,
};
pub const MotorCreateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const OrnamentInfo = struct {
    pub const default: @This() = .{};
    UnlockOrnamentIds: std.ArrayList(i32) = .empty,
    OrnamentDressInfos: std.ArrayList(OrnamentDressInfo) = .empty,
    RedPointOrnamentIds: std.ArrayList(i32) = .empty,
};
pub const OrnamentDressInfo = struct {
    pub const default: @This() = .{};
    RoleSkinId: i32 = 0,
    DressOrnamentIds: std.ArrayList(i32) = .empty,
};
pub const OrnamentInfoNotify = struct {
    pub const default: @This() = .{};
    OrnamentInfo: ?OrnamentInfo = null,
};
pub const OrnamentDressInfoUpdateNotify = struct {
    pub const default: @This() = .{};
    OrnamentDressInfos: std.ArrayList(OrnamentDressInfo) = .empty,
};
pub const ChangeOrnamentRequest = struct {
    pub const default: @This() = .{};
    RoleSkinId: i32 = 0,
    OrnamentId: i32 = 0,
    IsDress: bool = false,
};
pub const ChangeOrnamentResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PayUpdateType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    None = 0,
    Daily = 1,
    Weekly = 2,
    Monthly = 3,
    Forever = 4,
};
pub const PayItemInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    PayId: i32 = 0,
    ItemId: i32 = 0,
    ItemCount: i32 = 0,
    BonusItemCount: i32 = 0,
    SpecialBonusItemCount: i32 = 0,
    CanSpecialBonus: bool = false,
    StageImage: []const u8 = "",
    ProductId: []const u8 = "",
    Amount: []const u8 = "",
    ComplianceDetail: []const u8 = "",
    Quality: i32 = 0,
};
pub const PayGiftInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    PayId: i32 = 0,
    ItemId: i32 = 0,
    ItemCount: i32 = 0,
    Sort: i32 = 0,
    BuyLimit: i32 = 0,
    BoughtCount: i32 = 0,
    StageImage: []const u8 = "",
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
    ProductId: []const u8 = "",
    Amount: []const u8 = "",
    TabId: i32 = 0,
    Type: i32 = 0,
    Locked: bool = false,
    IsCanBuy: bool = false,
    IsRemind: bool = false,
    BuyCondition: i32 = 0,
    CloudGameTime: i32 = 0,
    CloudGameIcon: []const u8 = "",
    Desc: []const u8 = "",
    UpdateType: ?PayUpdateType = null,
    UpdateTime: i64 = 0,
    LastUpdateTime: i64 = 0,
    Tag: i32 = 0,
    PromotionShow: i32 = 0,
    ShowStageImage: []const u8 = "",
    CurrencyDiscountTags: std.ArrayList(MapEntry([]const u8, i32)) = .empty,
    ComplianceDetail: []const u8 = "",
    Quality: i32 = 0,
    VersionId: i32 = 0,
    ShopId: i32 = 0,
    NeedConsoleRulePrompt: bool = false,
};
pub const PayInfoRequest = struct {
    pub const default: @This() = .{};
    Version: []const u8 = "",
};
pub const PayInfoResponse = struct {
    pub const default: @This() = .{};
    Infos: std.ArrayList(PayItemInfo) = .empty,
    Version: []const u8 = "",
    ErrorCode: ?ErrorCode = null,
};
pub const PayShopPrice = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Count: i32 = 0,
    PromotionCount: i32 = 0,
};
pub const PayShopItemType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Normal = 0,
    Direct = 1,
};
pub const PayShopItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    ItemId: i32 = 0,
    ItemCount: i32 = 0,
    Locked: bool = false,
    BuyLimit: i32 = 0,
    BoughtCount: i32 = 0,
    Price: ?PayShopPrice = null,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
    BeginPromotionTime: i64 = 0,
    EndPromotionTime: i64 = 0,
    UpdateType: i32 = 0,
    UpdateTime: ?PayUpdateType = null,
    ShopItemType: ?PayShopItemType = null,
    TagBeginTime: i64 = 0,
    TagEndTime: i64 = 0,
    CanBuyGoods: bool = false,
    IsRemind: bool = false,
    BuyLimitConditionId: i32 = 0,
    Coupons: std.ArrayList(i32) = .empty,
    LastUpdateTime: i64 = 0,
    StageImage: []const u8 = "",
    ShowStageImage: []const u8 = "",
    TabId: i32 = 0,
    ShopId: i32 = 0,
    Tag: i32 = 0,
    Sort: i32 = 0,
    PromotionShow: i32 = 0,
    SoldOut: bool = false,
    ActivityId: i32 = 0,
    Show: bool = false,
    ComplianceDetail: []const u8 = "",
    Quality: i32 = 0,
    DiscountSort: i32 = 0,
    OnceBuyLimit: i32 = 0,
    IsRecommend: bool = false,
    IsShowHaveNum: bool = false,
    IsBuyMaxButton: bool = false,
    ConfirmLimitCount: i32 = 0,
};
pub const PayShopInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Items: std.ArrayList(PayShopItem) = .empty,
    UpdateTime: i64 = 0,
    LastUpdateTime: i64 = 0,
    ShopTabViewType: i32 = 0,
    DynamicTabId: i32 = 0,
    Sort: i32 = 0,
    Money: std.ArrayList(i32) = .empty,
    SortRule: i32 = 0,
    PayShopTabTogContent: []const u8 = "",
};
pub const PayGiftShopInfo = struct {
    pub const default: @This() = .{};
    Gifts: std.ArrayList(PayGiftInfo) = .empty,
    Version: []const u8 = "",
};
pub const PayShopInfoRequest = struct {
    pub const default: @This() = .{};
    Version: []const u8 = "",
};
pub const PayShopInfoResponse = struct {
    pub const default: @This() = .{};
    Infos: std.ArrayList(PayShopInfo) = .empty,
    Version: []const u8 = "",
    ErrorCode: ?ErrorCode = null,
    PayGiftShopInfo: ?PayGiftShopInfo = null,
    PayShopTabData: std.ArrayList(ShopTab) = .empty,
    PayShopRecommendData: std.ArrayList(ShopRecommend) = .empty,
};
pub const ShopTab = struct {
    pub const default: @This() = .{};
    ShopId: i32 = 0,
    TabId: i32 = 0,
    Sort: i32 = 0,
    name: []const u8 = "",
    Logic: i32 = 0,
    Enable: bool = false,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
    TabSelectSpritePath: []const u8 = "",
    TabContentPath: []const u8 = "",
    Money: std.ArrayList(i32) = .empty,
};
pub const ShopRecommend = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    RecommendType: i32 = 0,
    RecommendId: i32 = 0,
    TabName: []const u8 = "",
    PrefabPath: []const u8 = "",
    Sort: i32 = 0,
    Show: bool = false,
    TabImage: []const u8 = "",
};
pub const PhBaPlanAttrDeal = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    PhBaDefault = 0,
    PhBaLock = 1,
    PhBaDiscard = 2,
};
pub const PhBaPlanAttr = struct {
    pub const default: @This() = .{};
    AttrId: i32 = 0,
    Deal: ?PhBaPlanAttrDeal = null,
};
pub const PhBaCostType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    PhBaCostDefault = 0,
    PhBaCost1 = 1,
    PhBaCost3 = 3,
    PhBaCost4 = 4,
};
pub const PhBaOneCostPlan = struct {
    pub const default: @This() = .{};
    CostType: ?PhBaCostType = null,
    AttrList: std.ArrayList(PhBaPlanAttr) = .empty,
};
pub const PhBaOneSuitPlan = struct {
    pub const default: @This() = .{};
    SuitId: i32 = 0,
    OneCostList: std.ArrayList(PhBaOneCostPlan) = .empty,
    IsOpen: bool = false,
};
pub const PhBaOneAllSuitPlan = struct {
    pub const default: @This() = .{};
    SuitPlanList: std.ArrayList(PhBaOneSuitPlan) = .empty,
    Name: []const u8 = "",
};
pub const PhBaPlanUsePlanRequest = struct {
    pub const default: @This() = .{};
};
pub const PhBaPlanUsePlanResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SelfPlanCode: []const u8 = "",
    UsePlan: ?PhBaOneAllSuitPlan = null,
    FiveStarSwitch: bool = false,
    TowPlanSame: bool = false,
};
pub const PhBaPlanSaveUsePlanRequest = struct {
    pub const default: @This() = .{};
    UsePlan: ?PhBaOneAllSuitPlan = null,
};
pub const PhBaPlanSaveUsePlanResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SelfPlanCode: []const u8 = "",
    TowPlanSame: bool = false,
};
pub const PhBaPlanFindPlanRequest = struct {
    pub const default: @This() = .{};
    TargetCode: []const u8 = "",
};
pub const PhBaPlanFindPlanResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Plan: ?PhBaOneAllSuitPlan = null,
    TowPlanSame: bool = false,
};
pub const PhBaPlanSetStatusInfo = struct {
    pub const default: @This() = .{};
    Open: bool = false,
    Suit: i32 = 0,
};
pub const PhBaPlanSetPlanStatusRequest = struct {
    pub const default: @This() = .{};
    SetInfo: std.ArrayList(PhBaPlanSetStatusInfo) = .empty,
};
pub const PhBaPlanSetPlanStatusResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    TowPlanSame: bool = false,
};
pub const PhBaPlanUpdatePlanRequest = struct {
    pub const default: @This() = .{};
};
pub const PhBaPlanUpdatePlanResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SelfPlanCode: []const u8 = "",
};
pub const PhBaPlanSetFiveStarSwitchRequest = struct {
    pub const default: @This() = .{};
    Open: bool = false,
};
pub const PhBaPlanSetFiveStarSwitchResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PhBaPlanBatchOper = struct {
    pub const default: @This() = .{};
    Oper: ?PhantomFuncValue = null,
    IncrId: std.ArrayList(i32) = .empty,
};
pub const PhBaPlanBatchOperRequest = struct {
    pub const default: @This() = .{};
    BatchOper: std.ArrayList(PhBaPlanBatchOper) = .empty,
};
pub const PhBaPlanBatchOperResponse = struct {
    pub const default: @This() = .{};
    errCode: ?ErrorCode = null,
};
pub const PhantomConsumeItem = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    Count: i32 = 0,
    ItemId: i32 = 0,
};
pub const PhantomLevelUpRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    ConsumeList: std.ArrayList(PhantomConsumeItem) = .empty,
    SlotCount: i32 = 0,
};
pub const PhantomLevelUpResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    UpdateInfo: ?PhantomItem = null,
    ItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const PhantomPutOnNotify = struct {
    pub const default: @This() = .{};
    EquipInfoList: std.ArrayList(RolePhantomEquipInfo) = .empty,
};
pub const PhantomPutOnRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    RoleId: i32 = 0,
    Pos: i32 = 0,
};
pub const PhantomPutOnResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipInfoList: std.ArrayList(RolePhantomEquipInfo) = .empty,
};
pub const PhantomAutoPutRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    PhantomItemIncrId: std.ArrayList(i32) = .empty,
};
pub const PhantomAutoPutResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipInfoList: std.ArrayList(RolePhantomEquipInfo) = .empty,
};
pub const PhantomItemUpdateNotify = struct {
    pub const default: @This() = .{};
    UpdateInfo: std.ArrayList(PhantomItem) = .empty,
};
pub const RolePhantomPropUpdateNotify = struct {
    pub const default: @This() = .{};
    PropInfo: std.ArrayList(RolePhantomPropInfo) = .empty,
};
pub const PhantomIdentifyRequest = struct {
    pub const default: @This() = .{};
    IncrId: i32 = 0,
    Count: i32 = 0,
};
pub const PhantomIdentifyResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    UpdateInfo: ?PhantomItem = null,
};
pub const PhantomSkinUnlockNotify = struct {
    pub const default: @This() = .{};
    PhantomSkinList: std.ArrayList(i32) = .empty,
};
pub const PhantomSkinChangeRequest = struct {
    pub const default: @This() = .{};
    IncrId: i32 = 0,
    SkinId: i32 = 0,
    ChangeDefault: bool = false,
};
pub const PhantomSkinChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PhantomRefiningRequest = struct {
    pub const default: @This() = .{};
    IncrIdList: std.ArrayList(i32) = .empty,
};
pub const PhantomRefiningResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Items: std.ArrayList(AddCountItemInfo) = .empty,
    ExtraItems: std.ArrayList(AddCountItemInfo) = .empty,
    CostPhantoms: std.ArrayList(PhantomItem) = .empty,
};
pub const CalabashBatchRefiningRequest = struct {
    pub const default: @This() = .{};
    IncrIdList: std.ArrayList(i32) = .empty,
};
pub const CalabashBatchRefiningResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Items: std.ArrayList(AddCountItemInfo) = .empty,
    ExtraItems: std.ArrayList(AddCountItemInfo) = .empty,
    CostPhantoms: std.ArrayList(PhantomItem) = .empty,
};
pub const PhantomBatchDirectRefiningRequest = struct {
    pub const default: @This() = .{};
    IncrIdList: std.ArrayList(i32) = .empty,
    TargetFetterGroupId: i32 = 0,
};
pub const PhantomBatchDirectRefiningResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Items: std.ArrayList(AddCountItemInfo) = .empty,
    CostPhantoms: std.ArrayList(PhantomItem) = .empty,
    DirectRefineWeekTimes: i32 = 0,
};
pub const PhantomPolishRequest = struct {
    pub const default: @This() = .{};
    IncrId: i32 = 0,
    PhantomMainPropItemId: i32 = 0,
};
pub const PhantomPolishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    UpdateInfo: ?PhantomItem = null,
};
pub const PhantomSettingType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    AutoLock = 0,
    AutoDisuse = 1,
};
pub const PhantomManageConfigUpdateRequest = struct {
    pub const default: @This() = .{};
    Setting: ?PhantomManageConfig = null,
    SettingType: ?PhantomSettingType = null,
};
pub const PhantomManageConfigUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Setting: ?PhantomManageConfig = null,
};
pub const PhantomSettingInfo = struct {
    pub const default: @This() = .{};
    Setting: ?PhantomManageConfig = null,
    SettingType: ?PhantomSettingType = null,
};
pub const PhantomSettingBatchUpdateRequest = struct {
    pub const default: @This() = .{};
    Settings: std.ArrayList(PhantomSettingInfo) = .empty,
};
pub const PhantomSettingBatchUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Settings: std.ArrayList(PhantomSettingInfo) = .empty,
};
pub const PhantomManageConfigRequest = struct {
    pub const default: @This() = .{};
};
pub const PhantomManageConfigResponse = struct {
    pub const default: @This() = .{};
    AutoLock: std.ArrayList(PhantomManageConfig) = .empty,
    AutoDisuse: std.ArrayList(PhantomManageConfig) = .empty,
};
pub const PhantomManageConfig = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
    IsOn: bool = false,
    Name: []const u8 = "",
    PhantomRule: std.ArrayList(PhantomRuleMap) = .empty,
};
pub const PhantomRuleMap = struct {
    pub const default: @This() = .{};
    RuleId: i32 = 0,
    ValueList: std.ArrayList(i32) = .empty,
};
pub const PhantomFuncValue = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Locked = 0,
    Disuse = 1,
    Reset = 2,
};
pub const PhantomFuncValueBatchRequest = struct {
    pub const default: @This() = .{};
    FuncValue: ?PhantomFuncValue = null,
    IncrId: std.ArrayList(i32) = .empty,
};
pub const PhantomFuncValueBatchResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PhantomBatchPolishRequest = struct {
    pub const default: @This() = .{};
    IncrIds: std.ArrayList(i32) = .empty,
    PhantomMainPropItemId: i32 = 0,
};
pub const PhantomBatchPolishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    UpdateInfos: std.ArrayList(PhantomItem) = .empty,
};
pub const PhantomVicePolishRequest = struct {
    pub const default: @This() = .{};
    IncrId: i32 = 0,
    LockPropIndex: std.ArrayList(i32) = .empty,
};
pub const PhantomVicePolishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    PhantomSubProp: std.ArrayList(PhantomPropInfo) = .empty,
};
pub const PhantomVicePolishAckRequest = struct {
    pub const default: @This() = .{};
    IncrId: i32 = 0,
    Ack: bool = false,
};
pub const PhantomVicePolishAckResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    UpdateInfo: ?PhantomItem = null,
};
pub const RefreshVisionEquipGroupData = struct {
    pub const default: @This() = .{};
    IncId: std.ArrayList(i32) = .empty,
    Name: []const u8 = "",
};
pub const VisionEquipGroupInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const VisionEquipGroupInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
};
pub const AddVisionEquipGroupRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Name: []const u8 = "",
};
pub const AddVisionEquipGroupResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
};
pub const DeleteVisionEquipGroupRequest = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
};
pub const DeleteVisionEquipGroupResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
};
pub const PutVisionGroupToTopRequest = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
};
pub const PutVisionGroupToTopResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
};
pub const ChangeVisionGroupNameRequest = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
    Name: []const u8 = "",
};
pub const ChangeVisionGroupNameResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
};
pub const ApplyVisionGroupRequest = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
    RoleId: i32 = 0,
};
pub const ApplyVisionGroupResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipInfoList: std.ArrayList(RolePhantomEquipInfo) = .empty,
};
pub const GetMusicInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const GetMusicInfoResponse = struct {
    pub const default: @This() = .{};
    CurMusicId: i32 = 0,
    ErrorCode: ?ErrorCode = null,
    AlbumTimeInfos: std.ArrayList(PhonographAlbumTimeInfo) = .empty,
    TotalMusicIds: std.ArrayList(i32) = .empty,
    CollectMusicIds: std.ArrayList(i32) = .empty,
};
pub const FavoriteMusicMotorCycleUpdateRequest = struct {
    pub const default: @This() = .{};
    FavoriteMusicList: std.ArrayList(i32) = .empty,
};
pub const FavoriteMusicMotorCycleUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PhonographAlbumTimeInfo = struct {
    pub const default: @This() = .{};
    AlbumId: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
    MusicIds: std.ArrayList(i32) = .empty,
    CollectMusicIds: std.ArrayList(i32) = .empty,
};
pub const FragmentMemoryData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Flag: i32 = 0,
    FinishTime: i64 = 0,
};
pub const FragmentMemoryItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Data: std.ArrayList(FragmentMemoryData) = .empty,
    IsUnlock: bool = false,
};
pub const PhotoMemoryRequest = struct {
    pub const default: @This() = .{};
};
pub const PhotoMemoryResponse = struct {
    pub const default: @This() = .{};
    Item: std.ArrayList(FragmentMemoryItem) = .empty,
};
pub const VisionFetterRecommendInfo = struct {
    pub const default: @This() = .{};
    Usage: i32 = 0,
    RecommendFetterGroupInfos: std.ArrayList(RecommendFetterGroupInfo) = .empty,
    CostCombinationInfos: std.ArrayList(CostCombinationInfo) = .empty,
};
pub const RecommendFetterGroupInfo = struct {
    pub const default: @This() = .{};
    RecommendFetterGroupId: i32 = 0,
    CountNeed: i32 = 0,
};
pub const CostCombinationInfo = struct {
    pub const default: @This() = .{};
    CostId: i32 = 0,
    Usage: i32 = 0,
};
pub const VisionAttrRecommendInfo = struct {
    pub const default: @This() = .{};
    AttrType: i32 = 0,
    AddType: i32 = 0,
    Usage: i32 = 0,
};
pub const CostVisionAttrRecommendInfo = struct {
    pub const default: @This() = .{};
    Cost: i32 = 0,
    GetMainAttrRecommendInfo: std.ArrayList(VisionAttrRecommendInfo) = .empty,
    GetSubAttrRecommendInfo: std.ArrayList(VisionAttrRecommendInfo) = .empty,
};
pub const RoleVisionRecommendDataRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const RoleVisionRecommendDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionFetterRecommendInfo: std.ArrayList(VisionFetterRecommendInfo) = .empty,
};
pub const RoleVisionRecommendAttrRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const RoleVisionRecommendAttrResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionAttrRecommendInfos: std.ArrayList(CostVisionAttrRecommendInfo) = .empty,
};
pub const MainPhantomRecommendInfo = struct {
    pub const default: @This() = .{};
    Usage: i32 = 0,
    MonsterId: i32 = 0,
    FetterGroupId: i32 = 0,
};
pub const RoleVisionMainPhantomRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const RoleVisionMainPhantomResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RecommendInfo: std.ArrayList(MainPhantomRecommendInfo) = .empty,
};
pub const PassiveSkillInfo = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    SkillCdEndTime: i64 = 0,
};
pub const RolePassiveSkillInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    PassiveSkillInfoList: std.ArrayList(PassiveSkillInfo) = .empty,
};
pub const PassiveSkillNotify = struct {
    pub const default: @This() = .{};
    RolePassiveSkillInfoList: std.ArrayList(RolePassiveSkillInfo) = .empty,
};
pub const PlayerTitleData = struct {
    pub const default: @This() = .{};
    PlayerTitleId: i32 = 0,
    IsUnlock: bool = false,
    UnlockTime: i64 = 0,
    StarLevel: i32 = 0,
    ActivityServerRewardItemData: ?ConditionTask = null,
};
pub const SetDressedPlayerTitleNotify = struct {
    pub const default: @This() = .{};
    PlayerTitleId: i32 = 0,
    CurPlayerTitleId: i32 = 0,
};
pub const PlayerTitleDataRequest = struct {
    pub const default: @This() = .{};
};
pub const PlayerTitleDataResponse = struct {
    pub const default: @This() = .{};
    PlayerTitleData: std.ArrayList(PlayerTitleData) = .empty,
    ErrorCode: ?ErrorCode = null,
    PlayerTitleLimitInfos: std.ArrayList(PlayerTitleLimitInfo) = .empty,
};
pub const PlayerTitleLimitInfo = struct {
    pub const default: @This() = .{};
    PlayerTitleId: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const ChangePlayerTitleRequest = struct {
    pub const default: @This() = .{};
    PlayerTitleId: i32 = 0,
};
pub const ChangePlayerTitleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PlayerVarNotify = struct {
    pub const default: @This() = .{};
    VarInfos: std.ArrayList(MapEntry([]const u8, VarDefinePb)) = .empty,
};
pub const MotionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Spurt = 0,
    Pullback = 1,
    BeLand = 2,
    MotionJump = 3,
    AirSprint = 4,
    BackFlip = 5,
    StepAcross = 6,
    ClimbTop = 7,
    LimitDodge = 8,
    CounterAttack = 9,
};
pub const PlayerMotionRequest = struct {
    pub const default: @This() = .{};
    Motion: ?MotionType = null,
};
pub const PlayerMotionResponse = struct {
    pub const default: @This() = .{};
    ErrorId: ?ErrorCode = null,
};
pub const JSPatchNotify = struct {
    pub const default: @This() = .{};
    Content: []const u8 = "",
};
pub const QuestState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    InActive = 0,
    Available = 1,
    InProgress = 2,
    Finish = 3,
    Delete = 4,
};
pub const QuestInfo = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
    Status: ?QuestState = null,
};
pub const QuestListNotify = struct {
    pub const default: @This() = .{};
    Quests: std.ArrayList(QuestInfo) = .empty,
};
pub const TraceQuestNotify = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const TraceQuestRequest = struct {
    pub const default: @This() = .{};
    TraceType: i32 = 0,
    QuestId: i32 = 0,
    Operate: i32 = 0,
};
pub const TraceQuestResponse = struct {
    pub const default: @This() = .{};
    ErrorId: ?ErrorCode = null,
};
pub const QuestReadyListNotify = struct {
    pub const default: @This() = .{};
    QuestId: std.ArrayList(i32) = .empty,
};
pub const QuestShowListNotify = struct {
    pub const default: @This() = .{};
    QuestId: std.ArrayList(i32) = .empty,
};
pub const QuestFinishListNotify = struct {
    pub const default: @This() = .{};
    QuestId: std.ArrayList(i32) = .empty,
};
pub const QuestRedDotRequest = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
    Operate: i32 = 0,
};
pub const QuestRedDotResponse = struct {
    pub const default: @This() = .{};
    ErrorId: ?ErrorCode = null,
};
pub const QuestRedDotNotify = struct {
    pub const default: @This() = .{};
    QuestId: std.ArrayList(i32) = .empty,
};
pub const ConfirmQuestResourceRequest = struct {
    pub const default: @This() = .{};
    QuestIds: std.ArrayList(i32) = .empty,
};
pub const ConfirmQuestResourceResponse = struct {
    pub const default: @This() = .{};
    ErrorId: ?ErrorCode = null,
};
pub const SetQuestFocusModeRequest = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const SetQuestFocusModeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CancelQuestFocusModeRequest = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const CancelQuestFocusModeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AcceptFocusWaitQuestRequest = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const AcceptFocusWaitQuestResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FocusQuestSetNotify = struct {
    pub const default: @This() = .{};
    FocusQuestId: i32 = 0,
    Reason: ?QuestFocusReason = null,
};
pub const FocusQuestChangeNotify = struct {
    pub const default: @This() = .{};
    FocusQuestId: i32 = 0,
};
pub const QuestFocusReason = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Request = 0,
    Inherit = 1,
};
pub const SetFocusModeDeterConditionRequest = struct {
    pub const default: @This() = .{};
    DisableId: bool = false,
};
pub const SetFocusModeDeterConditionResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ClientPullResourcePackageRequest = struct {
    pub const default: @This() = .{};
    Holder: bool = false,
};
pub const ClientPullResourcePackageResponse = struct {
    pub const default: @This() = .{};
    ErrorId: ?ErrorCode = null,
    FinishMp4QuestIds: std.ArrayList(i32) = .empty,
    NeedConfirmQuestIds: std.ArrayList(i32) = .empty,
};
pub const QuestReviewDataRequest = struct {
    pub const default: @This() = .{};
};
pub const QuestReviewDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const QuestBranchInfo = struct {
    pub const default: @This() = .{};
    QuestBranchInfos: std.ArrayList(OneQuestBranchPageInfo) = .empty,
    UnlockTimePoints: std.ArrayList(i32) = .empty,
    UnlockBranchComponentsGroup: std.ArrayList(i32) = .empty,
};
pub const OneQuestBranchPageInfo = struct {
    pub const default: @This() = .{};
    id: i32 = 0,
    CurBranch: i32 = 0,
    CompleteBranches: std.ArrayList(i32) = .empty,
};
pub const QuestBranchRequest = struct {
    pub const default: @This() = .{};
};
pub const QuestBranchResponse = struct {
    pub const default: @This() = .{};
    errorCode: i32 = 0,
    QuestBranchInfo: ?QuestBranchInfo = null,
};
pub const RangeType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    RangeEnter = 0,
    RangeLeave = 1,
    RangeInit = 2,
    RangeInitOut = 3,
};
pub const EntityAccessInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    RangeType: ?RangeType = null,
    AcessRangeResults: std.ArrayList(MapEntry(i32, ErrorCode)) = .empty,
};
pub const EntityAccessRangeRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    EntitiesToCheck: std.ArrayList(i64) = .empty,
    RangeType: ?RangeType = null,
};
pub const EntityAccessRangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EntityId: i64 = 0,
    Info: std.ArrayList(EntityAccessInfo) = .empty,
};
pub const PlayerAccessEffectAreaRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    RangeType: ?RangeType = null,
};
pub const PlayerAccessEffectAreaResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EntityId: i64 = 0,
    Info: ?EntityAccessInfo = null,
};
pub const InitRangeRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    EntitiesToRequest: std.ArrayList(i64) = .empty,
    IsPlayerInRange: bool = false,
};
pub const InitRangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EntityId: i64 = 0,
    Info: std.ArrayList(EntityAccessInfo) = .empty,
    PlayerAccessRangeResult: ?EntityAccessInfo = null,
};
pub const ExtraDeadInfo = struct {
    pub const default: @This() = .{};
    Message: ?union(enum) {
        BtBloodBathedModeInfo: ?BtBloodBathedModeInfo,
    } = null,
};
pub const PlayerDeadNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    DelaySeconds: i32 = 0,
    IsAutoRevive: bool = false,
    ReviveId: i32 = 0,
    IsLogin: bool = false,
    IsShowRevive: bool = false,
    ExtraDeadInfos: std.ArrayList(ExtraDeadInfo) = .empty,
};
pub const DeathStatusInfo = struct {
    pub const default: @This() = .{};
    GroupType: i32 = 0,
    LivingStatus: ?LivingStatus = null,
};
pub const AliveStatusNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    Info: std.ArrayList(DeathStatusInfo) = .empty,
};
pub const BtBloodBathedModeInfo = struct {
    pub const default: @This() = .{};
    BtType: i32 = 0,
    BtObjId: i32 = 0,
    BtObjSetting: i32 = 0,
};
pub const RoguelikeCurrencyNotify = struct {
    pub const default: @This() = .{};
    V2s: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const SceneBlockSplitPlayerNeedBlockPush = struct {
    pub const default: @This() = .{};
    PlayerNeedBlockId: std.ArrayList(i32) = .empty,
};
pub const GetRewardTreasureBoxRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const GetRewardTreasureBoxResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MobileButtonSetting = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Size: f32 = 0,
    Transparency: f32 = 0,
    ScreenX: f32 = 0,
    ScreenY: f32 = 0,
    ButtonLevel: i32 = 0,
    PanelLevel: i32 = 0,
};
pub const SettingNotify = struct {
    pub const default: @This() = .{};
    MobileButtonSettings: std.ArrayList(MobileButtonSetting) = .empty,
};
pub const LanguageSettingUpdateRequest = struct {
    pub const default: @This() = .{};
    Language: i32 = 0,
};
pub const LanguageSettingUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ServerPlayStationPlayOnlyStateRequest = struct {
    pub const default: @This() = .{};
};
pub const ServerPlayStationPlayOnlyStateResponse = struct {
    pub const default: @This() = .{};
    CrossPlayEnabled: bool = false,
};
pub const CombinationKey = struct {
    pub const default: @This() = .{};
    KeyNameList: std.ArrayList([]const u8) = .empty,
};
pub const InputAction = struct {
    pub const default: @This() = .{};
    ActionName: []const u8 = "",
    KeyNameList: std.ArrayList([]const u8) = .empty,
    Version: i32 = 0,
    InputType: ?SettingInputType = null,
};
pub const InputAxis = struct {
    pub const default: @This() = .{};
    AxisName: []const u8 = "",
    KeyScaleMap: std.ArrayList(MapEntry([]const u8, i32)) = .empty,
    Version: i32 = 0,
    InputType: ?SettingInputType = null,
};
pub const CombinationAction = struct {
    pub const default: @This() = .{};
    ActionName: []const u8 = "",
    CombinationKeyList: std.ArrayList(CombinationKey) = .empty,
    Version: i32 = 0,
    InputType: ?SettingInputType = null,
};
pub const CombinationAxis = struct {
    pub const default: @This() = .{};
    AxisName: []const u8 = "",
    CombinationKeyList: std.ArrayList(CombinationKey) = .empty,
    Version: i32 = 0,
    InputType: ?SettingInputType = null,
};
pub const InputSettingDevice = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Mouse = 0,
    Handle = 1,
};
pub const SettingInputType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Normal = 0,
    Motorcycle = 1,
};
pub const InputSettingData = struct {
    pub const default: @This() = .{};
    InputSettings: std.ArrayList(DeviceInputSetting) = .empty,
};
pub const DeviceInputSetting = struct {
    pub const default: @This() = .{};
    Device: ?InputSettingDevice = null,
    DeviceSubType: []const u8 = "",
    InputAction: std.ArrayList(InputAction) = .empty,
    InputAxis: std.ArrayList(InputAxis) = .empty,
    InputCombinationAction: std.ArrayList(CombinationAction) = .empty,
    InputCombinationAxis: std.ArrayList(CombinationAxis) = .empty,
};
pub const InputSettingRequest = struct {
    pub const default: @This() = .{};
};
pub const InputSettingResponse = struct {
    pub const default: @This() = .{};
    InputSettingData: ?InputSettingData = null,
};
pub const InputSettingUpdateRequest = struct {
    pub const default: @This() = .{};
    InputSettingData: ?InputSettingData = null,
};
pub const InputSettingUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const XboxSettingRequest = struct {
    pub const default: @This() = .{};
};
pub const XboxSettingResponse = struct {
    pub const default: @This() = .{};
    MatchXboxUser: bool = false,
};
pub const SheriffCriminalInfo = struct {
    pub const default: @This() = .{};
    CriminalId: i32 = 0,
    state: i32 = 0,
    IdentityId: i32 = 0,
};
pub const SheriffAnomalyInfo = struct {
    pub const default: @This() = .{};
    AnomalyId: i32 = 0,
    ClueIds: std.ArrayList(i32) = .empty,
    ProgressIds: std.ArrayList(i32) = .empty,
    EndingId: i32 = 0,
    CompleteTime: i64 = 0,
    IsActivated: bool = false,
    IsUnlocked: bool = false,
};
pub const SheriffZoneInfo = struct {
    pub const default: @This() = .{};
    ZoneId: i32 = 0,
    AnomalyInfos: std.ArrayList(SheriffAnomalyInfo) = .empty,
    CriminalInfos: std.ArrayList(SheriffCriminalInfo) = .empty,
    ItemCount: i64 = 0,
};
pub const SheriffZoneInfoRequest = struct {
    pub const default: @This() = .{};
    ZoneIds: std.ArrayList(i32) = .empty,
};
pub const SheriffZoneInfoResponse = struct {
    pub const default: @This() = .{};
    errorCode: i32 = 0,
    ZoneInfos: std.ArrayList(SheriffZoneInfo) = .empty,
};
pub const ShortMessageInfo = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    LastConfigId: i32 = 0,
    IsRead: bool = false,
    IsReceived: bool = false,
    Options: std.ArrayList(MapEntry(i32, i32)) = .empty,
    UnlockTime: i64 = 0,
    IsFinish: bool = false,
};
pub const AllMsgRequest = struct {
    pub const default: @This() = .{};
};
pub const AllMsgResponse = struct {
    pub const default: @This() = .{};
    ShortMessageInfos: std.ArrayList(ShortMessageInfo) = .empty,
    BubbleIds: std.ArrayList(i32) = .empty,
    BubbleId: i32 = 0,
    ChatBgIds: std.ArrayList(i32) = .empty,
    ChatBgId: i32 = 0,
    ErrCode: ?ErrorCode = null,
    PartnerChange: std.ArrayList(i32) = .empty,
};
pub const BattleFormation = struct {
    pub const default: @This() = .{};
    SelectRoles: std.ArrayList(i32) = .empty,
    BuffSelect: i32 = 0,
    SkillBranchIds: std.ArrayList(i32) = .empty,
};
pub const SlashLevelPlayInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IsLocked: bool = false,
    FirstScore: i32 = 0,
    SecondScore: i32 = 0,
    FirstBattle: ?BattleFormation = null,
    SecondBattle: ?BattleFormation = null,
    IsPassed: bool = false,
    IsEasyPass: bool = false,
};
pub const SlashAndTowerInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const SlashAndTowerInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SlashLevelPlayInfo: std.ArrayList(SlashLevelPlayInfo) = .empty,
    RewardsReceived: std.ArrayList(i32) = .empty,
    CurSeasonEndTime: i64 = 0,
    UpdateSeason: bool = false,
    CurIsHaveRecord: bool = false,
    BuffCache: std.ArrayList(i32) = .empty,
};
pub const TowerInfo = struct {
    pub const default: @This() = .{};
    CurrentSeason: i32 = 0,
    DataSeason: i32 = 0,
    TowerDifficulties: std.ArrayList(TowerDifficultyPb) = .empty,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
    MaxUnlockDifficulty: i32 = 0,
    QuickPassId: i32 = 0,
};
pub const TowerDifficultyPb = struct {
    pub const default: @This() = .{};
    Difficulty: i32 = 0,
    RewardIndex: std.ArrayList(i32) = .empty,
    TowerAreas: std.ArrayList(TowerAreaPb) = .empty,
    MaxStar: i32 = 0,
};
pub const TowerAreaPb = struct {
    pub const default: @This() = .{};
    AreaNum: i32 = 0,
    TowerFloors: std.ArrayList(TowerFloorPb) = .empty,
};
pub const TowerFloorPb = struct {
    pub const default: @This() = .{};
    TowerConfigId: i32 = 0,
    Star: i32 = 0,
    Formation: std.ArrayList(TowerRolePb) = .empty,
    StarIndex: std.ArrayList(i32) = .empty,
    IsQuickPass: bool = false,
};
pub const TowerRolePb = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    LeaveSkillId: i32 = 0,
    SkillBranchId: i32 = 0,
};
pub const TowerRequest = struct {
    pub const default: @This() = .{};
};
pub const TowerResponse = struct {
    pub const default: @This() = .{};
    TowerInfo: ?TowerInfo = null,
};
pub const TowerSeasonUpdateRequest = struct {
    pub const default: @This() = .{};
};
pub const TowerSeasonUpdateResponse = struct {
    pub const default: @This() = .{};
    Towers: ?union(enum) {
        TowerInfo: ?TowerInfo,
    } = null,
    MaxUnlockDifficulty: i32 = 0,
};
pub const MoonChasingTrackMoonHandbookRewardNotify = struct {
    pub const default: @This() = .{};
    Ids: std.ArrayList(i32) = .empty,
};
pub const MoonChasingTargetGetCountNotify = struct {
    pub const default: @This() = .{};
    TargetGetCount: i32 = 0,
};
pub const TutorialInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    CreateTime: u32 = 0,
    GetAward: bool = false,
};
pub const TutorialInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const TutorialInfoResponse = struct {
    pub const default: @This() = .{};
    UnlockList: std.ArrayList(TutorialInfo) = .empty,
};
pub const TutorialReceiveRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
};
pub const TutorialReceiveResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
    ItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const TutorialUnlockRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
};
pub const TutorialUnlockResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
    UnLockInfo: ?TutorialInfo = null,
};
pub const WeaponConsumeItem = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    Count: i32 = 0,
    ItemId: i32 = 0,
};
pub const WeaponLevelUpRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    ConsumeList: std.ArrayList(WeaponConsumeItem) = .empty,
};
pub const WeaponLevelUpResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    IncId: i32 = 0,
    WeaponLevel: i32 = 0,
    WeaponExp: i32 = 0,
    ItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const WeaponBreachRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
};
pub const WeaponBreachResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    IncId: i32 = 0,
    WeaponBreach: i32 = 0,
};
pub const WeaponResonUpRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    ConsumeList: std.ArrayList(i32) = .empty,
    ConsumeItemList: std.ArrayList(WeaponConsumeItem) = .empty,
};
pub const WeaponResonUpResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    IncId: i32 = 0,
    ResonLevel: i32 = 0,
};
pub const WeeklyFrameworkInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const WeeklyFrameworkInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: i32 = 0,
    FrameworkInfo: ?WeeklyFrameworkInfo = null,
};
pub const WeeklyFrameworkInfo = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
    ScoreTasks: std.ArrayList(i32) = .empty,
    WeeklyPlayDatas: std.ArrayList(WeeklyPlayData) = .empty,
    WorldLevel: i32 = 0,
};
pub const WeeklyPlayData = struct {
    pub const default: @This() = .{};
    qWp: ?union(enum) {
        RogueWeeklyPlayData: ?RogueWeeklyPlayData,
        FloroFarmPlayData: ?FloroFarmPlayData,
    } = null,
    id: i32 = 0,
    type: i32 = 0,
};
pub const RogueWeeklyPlayData = struct {
    pub const default: @This() = .{};
    HasRecord: bool = false,
};
pub const FloroFarmPlayData = struct {
    pub const default: @This() = .{};
    HasRecord: bool = false,
};
pub const LobbyListRequest = struct {
    pub const default: @This() = .{};
    IsFriend: bool = false,
};
pub const LobbyListResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ItemList: std.ArrayList(PlayerDetails) = .empty,
};
