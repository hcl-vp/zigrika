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
pub const CalabashSkinDataRequest = struct {
    pub const default: @This() = .{};
};
pub const DeleteVisionEquipGroupRequest = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
};
pub const TimeCheckRequest = struct {
    pub const default: @This() = .{};
    ClientTime: i64 = 0,
    TimeDilation: f32 = 0,
    FlowTimeDilation: f32 = 0,
};
pub const VersionInfoPush = struct {
    pub const default: @This() = .{};
    AppVersion: []const u8 = "",
    LauncherVersion: []const u8 = "",
    ResourceVersion: []const u8 = "",
};
pub const AwardGroupData = struct {
    pub const default: @This() = .{};
    GroupId: i32 = 0,
    GroupRank: i32 = 0,
    CurrentAmount: i32 = 0,
    AllAmount: i32 = 0,
    RewardItems: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const UpdateAchievementInfoRequest = struct {
    pub const default: @This() = .{};
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
pub const PhantomPolishRequest = struct {
    pub const default: @This() = .{};
    IncrId: i32 = 0,
    PhantomMainPropItemId: i32 = 0,
};
pub const BulletComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const MonsterInfoPreview = struct {
    pub const default: @This() = .{};
    WaveConfigId: i32 = 0,
    HpPpb: i32 = 0,
    Damage: i32 = 0,
    Round: i32 = 0,
    IsDead: bool = false,
};
pub const RoleBreakThroughViewRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const TowerSeasonUpdateRequest = struct {
    pub const default: @This() = .{};
};
pub const LeaveInstEscActionCtxPb = struct {
    pub const default: @This() = .{};
    InstanceId: i32 = 0,
};
pub const DFsmBlackBoard = struct {
    pub const default: @This() = .{};
    Key: i32 = 0,
    Value: i32 = 0,
};
pub const HonamiStoryPosInfo = struct {
    pub const default: @This() = .{};
    IsCross: bool = false,
    Posotion: i32 = 0,
};
pub const FsmStateBehaviorType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Enter = 0,
    Exit = 1,
    BindStart = 2,
    BindEnd = 3,
    Task = 4,
};
pub const CombatDataMaxResponse = struct {
    pub const default: @This() = .{};
};
pub const ActivitySoarData = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const GetFormationDataRequest = struct {
    pub const default: @This() = .{};
};
pub const DangoMonopolyTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NotCompleted = 0,
    Completed = 1,
    HasGet = 2,
};
pub const RangeType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    RangeType_RangeEnter = 0,
    RangeType_RangeLeave = 1,
    RangeType_RangeInit = 2,
    RangeType_RangeInitOut = 3,
};
pub const PassiveSkillRemoveRequest = struct {
    pub const default: @This() = .{};
    PassiveSkillId: i64 = 0,
    TargetEntityId: i64 = 0,
};
pub const SpringSkipEntry = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    UnLock: bool = false,
    Finish: bool = false,
};
pub const ChangeStateConfirmPush = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
};
pub const RoleTagChangeRequest = struct {
    pub const default: @This() = .{};
    TagId: i32 = 0,
    TagCount: i32 = 0,
};
pub const TimeTypeState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    TimeLimited = 0,
    Permanent = 1,
    LimitToPermanent = 2,
};
pub const RangeComponentPb = struct {
    pub const default: @This() = .{};
    InRangePlayers: std.ArrayList(i32) = .empty,
    InRangeEntities: std.ArrayList(i64) = .empty,
};
pub const TowerRolePb = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    LeaveSkillId: i32 = 0,
};
pub const GmLevelActionCtxPb = struct {
    pub const default: @This() = .{};
    JsonStr: []const u8 = "",
};
pub const ChangeStateConfirmRequest = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
};
pub const RemoveGameplayEffectNotify = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    EntityId: i64 = 0,
};
pub const TrapDefenseAuxiliaryData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Level: i32 = 0,
    Branch: i32 = 0,
    MaxLevel: i32 = 0,
};
pub const GuideTriggerRequest = struct {
    pub const default: @This() = .{};
    GroupId: i32 = 0,
};
pub const IntArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(i32) = .empty,
};
pub const ScratchCardRewardData = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Count: i32 = 0,
};
pub const RbGridPosition = struct {
    pub const default: @This() = .{};
    X: i32 = 0,
    Y: i32 = 0,
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
pub const HonamiStoryMascotConfig = struct {
    pub const default: @This() = .{};
    MascotId: i32 = 0,
    State: i32 = 0,
};
pub const UseSkillFailRequest = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
};
pub const MonsterAiComponentPb = struct {
    pub const default: @This() = .{};
    WeaponId: i32 = 0,
    HatredGroupId: i64 = 0,
    AiTeamInitId: i32 = 0,
    CombatMessageId: i64 = 0,
    BasicPerceptionIds: std.ArrayList(i32) = .empty,
};
pub const NetStatusType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Wifi = 0,
    Stream = 1,
    Wired = 2,
    Other = 3,
};
pub const BattlePassRequest = struct {
    pub const default: @This() = .{};
};
pub const PhantomArenaCardReward = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
    NeedCount: i32 = 0,
    IsTaken: bool = false,
};
pub const QuestReviewDataRequest = struct {
    pub const default: @This() = .{};
};
pub const TransitionWithCharacterDisplayPb = struct {
    pub const default: @This() = .{};
    StyllId: i32 = 0,
};
pub const WeatherControlInfoWithoutCheckAsyncRequest = struct {
    pub const default: @This() = .{};
};
pub const FishingTechInfo = struct {
    pub const default: @This() = .{};
    NodeId: i32 = 0,
    Level: i32 = 0,
    CanUnlock: bool = false,
};
pub const ClientStorageListData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(i32) = .empty,
};
pub const SceneItemEventListenerComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const FunPlayChallengeRewardStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    FunPlayCanNoReward = 0,
    FunPlayCanReward = 1,
    FunPlayRewarded = 2,
};
pub const MontagePlayPush = struct {
    pub const default: @This() = .{};
    Name: []const u8 = "",
    Path: i32 = 0,
    SpeedRatio: f32 = 0,
    StartSection: []const u8 = "",
    StartTimeSeconds: f32 = 0,
};
pub const FlowOptionInfo = struct {
    pub const default: @This() = .{};
    TalkId: i32 = 0,
    OptionIndex: i32 = 0,
};
pub const LoadingConfigRequest = struct {
    pub const default: @This() = .{};
};
pub const RbDefaultBlockPbType = struct {
    pub const default: @This() = .{};
    IsMainControl: bool = false,
};
pub const BattlePassType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Free = 0,
    Pay = 1,
};
pub const ExecuteQteNotify = struct {
    pub const default: @This() = .{};
    DownEntityId: i64 = 0,
    UpEntityId: i64 = 0,
    FnvHash: i32 = 0,
};
pub const MoonChasingTargetGetCountNotify = struct {
    pub const default: @This() = .{};
    TargetGetCount: i32 = 0,
};
pub const PrivateChatDataResponse = struct {
    pub const default: @This() = .{};
    LoadSucc: bool = false,
};
pub const PlayPointStateAsyncRequest = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    ArenaId: i32 = 0,
};
pub const PublicResourceVersionInfo = struct {
    pub const default: @This() = .{};
    PublicJsonVersion: i32 = 0,
    PublicMiscVersion: i32 = 0,
    PublicUniverseEditorVersion: i32 = 0,
};
pub const RoleSkinTrialContentData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    ChallengeState: i32 = 0,
};
pub const RbVisionBlockPbType = struct {
    pub const default: @This() = .{};
};
pub const PreheatSignNodeInfo = struct {
    pub const default: @This() = .{};
    PreheatNodeId: i32 = 0,
    UnlockTime: i64 = 0,
    Rewarded: bool = false,
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
pub const FollowEntityComponentPb = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const PlayerSceneComponentPb = struct {
    pub const default: @This() = .{};
    EntityIds: std.ArrayList(i64) = .empty,
};
pub const WeaponConsumeItem = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    Count: i32 = 0,
    ItemId: i32 = 0,
};
pub const GuideInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const JSPatchNotify = struct {
    pub const default: @This() = .{};
    Content: []const u8 = "",
};
pub const ClientStorageSetData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(i32) = .empty,
};
pub const VisionTriggerPush = struct {
    pub const default: @This() = .{};
    VisionId: i32 = 0,
};
pub const WebSignResponse = struct {
    pub const default: @This() = .{};
    NoticeSign: []const u8 = "",
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
pub const RTimeStopInstPush = struct {
    pub const default: @This() = .{};
    Flag: bool = false,
    Duration: i32 = 0,
};
pub const ActivityLinkageRewardData = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Count: i32 = 0,
};
pub const FishingIllustratedRewardInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    CurrentProgress: i32 = 0,
    TargetProgress: i32 = 0,
    HasPassed: bool = false,
    IsTaken: bool = false,
};
pub const DoubleInstActivityReward = struct {
    pub const default: @This() = .{};
    GetDoubleInstRwdCount: i32 = 0,
};
pub const UnlockRoleSkinListResponse = struct {
    pub const default: @This() = .{};
    RoleSkinList: std.ArrayList(i32) = .empty,
};
pub const InfluenceInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const LordGymEntranceInfo = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    EffectBeginTime: i64 = 0,
    EffectEndTime: i64 = 0,
};
pub const EnterViewDirectionRequest = struct {
    pub const default: @This() = .{};
};
pub const MonsterWeaponComponentPb = struct {
    pub const default: @This() = .{};
    WeaponId: i32 = 0,
};
pub const FlySkinWearRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkinId: i32 = 0,
};
pub const FlagChallengeRoleLevelInfo = struct {
    pub const default: @This() = .{};
    PerLevel: i32 = 0,
    PerExp: i32 = 0,
};
pub const GivebackInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const ApplyGEType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Common = 0,
    UseExtraTime = 1,
};
pub const PlayerRebackSceneNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const LiftComponentPb = struct {
    pub const default: @This() = .{};
    Location: i32 = 0,
};
pub const DirectTrainGetPlayerIdRequest = struct {
    pub const default: @This() = .{};
};
pub const RoleActivateSkillRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillNodeId: i32 = 0,
};
pub const EnterViewDirectionPush = struct {
    pub const default: @This() = .{};
};
pub const AceBlackProductAccountInfo = struct {
    pub const default: @This() = .{};
    TdmDeviceId: []const u8 = "",
    IsRoot: bool = false,
    IsSimulator: bool = false,
};
pub const RoleElementChangeRequest = struct {
    pub const default: @This() = .{};
    ElementType: i32 = 0,
};
pub const GuideFinishRequest = struct {
    pub const default: @This() = .{};
    GroupId: i32 = 0,
};
pub const RouletteType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Explore = 0,
    RouletteType_Function = 1,
    RouletteType_TrapDefense = 2,
    RouletteType_Motorcycle = 3,
};
pub const NormalItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Count: i32 = 0,
    ExpireTime: i64 = 0,
};
pub const FurnitureComponentPb = struct {
    pub const default: @This() = .{};
    SlotId: i32 = 0,
    FurnitureId: i32 = 0,
};
pub const PhantomItemRequest = struct {
    pub const default: @This() = .{};
};
pub const SlashAndTowerInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const ClientCurrentRoleReportRequest = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    CurrentRoleId: i32 = 0,
    CurrentEntityId: i64 = 0,
};
pub const SurvivorsLevelInfo = struct {
    pub const default: @This() = .{};
    IsUnlocked: bool = false,
    ConditionGroupId: i32 = 0,
    WaveId: i32 = 0,
    KillMonsterCount: i32 = 0,
    IsFinished: bool = false,
};
pub const SummonsComponentPb = struct {
    pub const default: @This() = .{};
    Version: i32 = 0,
};
pub const ArrayIntInt = struct {
    pub const default: @This() = .{};
    Key: i32 = 0,
    Value: i32 = 0,
};
pub const QuestActiveActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const HarvestPointReward = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    State: i32 = 0,
};
pub const MonsterBoomRequest = struct {
    pub const default: @This() = .{};
    Delay: i32 = 0,
};
pub const EntityFollowTrackRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const FormationAttr = struct {
    pub const default: @This() = .{};
    AttrId: i32 = 0,
    Ratio: i32 = 0,
    BaseMaxValue: i32 = 0,
    MaxValue: i32 = 0,
    CurrentValue: i32 = 0,
};
pub const ButtonType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Home = 0,
};
pub const ItemDeprecateRequest = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    IncrId: i32 = 0,
};
pub const AnimalPerformComponentPb = struct {
    pub const default: @This() = .{};
    AnimalInitialPartIds: std.ArrayList(i32) = .empty,
};
pub const PrivateChatDataRequest = struct {
    pub const default: @This() = .{};
};
pub const VehiclePlayerData = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Seat: i32 = 0,
};
pub const CombatMaxCaseMessageRequest = struct {
    pub const default: @This() = .{};
};
pub const BuffProducerComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const SignActivity = struct {
    pub const default: @This() = .{};
    SignStateList: std.ArrayList(i32) = .empty,
};
pub const AnimStateChangeInfo = struct {
    pub const default: @This() = .{};
    AnimationStates: std.ArrayList(i32) = .empty,
    SpecialAnimationStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const PrivateChatOperateType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    CloseChat = 0,
    PrivateChatOperateType_OpenChat = 1,
    PrivateChatOperateType_ReadMsg = 2,
};
pub const ItemPkgOpenNotify = struct {
    pub const default: @This() = .{};
    OpenPkg: std.ArrayList(i32) = .empty,
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
pub const SurvivorsWeaponPbData = struct {
    pub const default: @This() = .{};
};
pub const TrapDefenseGoldenCoinPbData = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const GameplayCueNotify = struct {
    pub const default: @This() = .{};
    GameplayCueId: i64 = 0,
};
pub const ItemExchangeInfo = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    TodayTimes: i32 = 0,
    TotalTimes: i32 = 0,
    DailyLimit: i32 = 0,
    TotalLimit: i32 = 0,
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
pub const RoadNavMoveData = struct {
    pub const default: @This() = .{};
    DestRoadId: i32 = 0,
    DestIndex: i32 = 0,
    GenRoadId: i32 = 0,
    GenRoadIndex: i32 = 0,
};
pub const AnimalDestroyRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const ShopTab = struct {
    pub const default: @This() = .{};
    ShopId: i32 = 0,
    TabId: i32 = 0,
    Sort: i32 = 0,
    Name: []const u8 = "",
    Logic: i32 = 0,
    Enable: bool = false,
};
pub const PhantomIdentifyRequest = struct {
    pub const default: @This() = .{};
    IncrId: i32 = 0,
    Count: i32 = 0,
};
pub const MotorDaCtxComponentPb = struct {
    pub const default: @This() = .{};
    MotorDaCtxId: i64 = 0,
};
pub const RTimeStopRequest = struct {
    pub const default: @This() = .{};
    Flag: bool = false,
    IsStopCharacter: bool = false,
    Duration: i32 = 0,
};
pub const MotorTaskTypePb = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Unknown = 0,
    Single = 1,
    Limited = 2,
    Cycle = 3,
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
pub const TimelineTrackControlDataPb = struct {
    pub const default: @This() = .{};
    ControlPoint: i32 = 0,
};
pub const NewLinkBurstPush = struct {
    pub const default: @This() = .{};
};
pub const SwitchRoleType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    SignleWorld = 0,
    MultiWorld = 1,
    FbInstance = 2,
};
pub const LordGymInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const InputSettingDevice = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Mouse = 0,
    Handle = 1,
};
pub const FlowActionCtxPb = struct {
    pub const default: @This() = .{};
    FlowListName: []const u8 = "",
    FlowId: i32 = 0,
    StateId: i32 = 0,
    ActionId: i32 = 0,
};
pub const MoonSignInConfigData = struct {
    pub const default: @This() = .{};
    MoonId: i32 = 0,
    MoonLabelTopId: i32 = 0,
    MoonLabelBottomId: i32 = 0,
};
pub const PatrolComponentPb = struct {
    pub const default: @This() = .{};
    Dir: bool = false,
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
pub const FsmConditionPassPush = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    FromState: i32 = 0,
    ToState: i32 = 0,
    ConditionIndex: i32 = 0,
    Value: bool = false,
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
pub const SceneItemBBKey = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ManipulatableState = 0,
};
pub const ClientStorageLongData = struct {
    pub const default: @This() = .{};
    Data: i64 = 0,
};
pub const MotorTechPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Level: i32 = 0,
    Unlock: bool = false,
    Current: i32 = 0,
    Target: i32 = 0,
};
pub const TutorialInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    CreateTime: u32 = 0,
    GetAward: bool = false,
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
pub const AdvertisingPageData = struct {
    pub const default: @This() = .{};
    Show: bool = false,
    PointTime: i64 = 0,
};
pub const WeaponSkinComponentPb = struct {
    pub const default: @This() = .{};
    WeaponSkinId: i32 = 0,
};
pub const PhantomCollectProgress = struct {
    pub const default: @This() = .{};
    Phantoms: std.ArrayList(i32) = .empty,
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
};
pub const AnimationGameplayTagNotify = struct {
    pub const default: @This() = .{};
    AddTagIds: i32 = 0,
    RemoveTagIds: bool = false,
};
pub const AiHateEntity = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    HatredValue: i32 = 0,
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
pub const PartInformation = struct {
    pub const default: @This() = .{};
    PartIndex: i32 = 0,
    LifeValue: f32 = 0,
    LifeMax: f32 = 0,
    Activated: bool = false,
    PartTag: i32 = 0,
};
pub const PlayerAttrType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Int32 = 0,
    String = 1,
};
pub const FishingDataRequest = struct {
    pub const default: @This() = .{};
};
pub const EShieldUpdateType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    EShieldUpdateType_EShieldUpdateTypeAdd = 0,
    EShieldUpdateType_EShieldUpdateTypeDel = 1,
    EShieldUpdateType_EShieldUpdateTypeModify = 2,
};
pub const SceneBlockSplitPlayerNeedBlockPush = struct {
    pub const default: @This() = .{};
    PlayerNeedBlockId: std.ArrayList(i32) = .empty,
};
pub const NpcPb = struct {
    pub const default: @This() = .{};
    SplineEntityId: i32 = 0,
    SpawnEntityId: i32 = 0,
};
pub const PayInfoRequest = struct {
    pub const default: @This() = .{};
    Version: []const u8 = "",
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
pub const NPCPerformGroupComponentPb = struct {
    pub const default: @This() = .{};
    Type: []const u8 = "",
    State: []const u8 = "",
};
pub const GroupTypesWrapper = struct {
    pub const default: @This() = .{};
    GroupTypes: std.ArrayList(i32) = .empty,
};
pub const ClientStorageBoolData = struct {
    pub const default: @This() = .{};
    Data: bool = false,
};
pub const PhotographSubType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    None = 0,
    PhotographSub = 7,
    Role = 8,
    PhotographSubType_Quest = 9,
};
pub const EquipFlySkinData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkinId: i32 = 0,
};
pub const LevelPlayOpenActionCtxPb = struct {
    pub const default: @This() = .{};
    LevelPlayId: i32 = 0,
};
pub const RemoveGameplayEffectPush = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    EntityId: i64 = 0,
    IsPrematureRemoval: bool = false,
    reason: []const u8 = "",
};
pub const GachaInfoRequest = struct {
    pub const default: @This() = .{};
    Language: i32 = 0,
};
pub const PbUpLevelSkillRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillId: i32 = 0,
};
pub const HonamiStoryEnhanceLevelComponentPb = struct {
    pub const default: @This() = .{};
    Level: i32 = 0,
};
pub const OrderRemoveBuffByTagsNotify = struct {
    pub const default: @This() = .{};
    TagIds: std.ArrayList(i32) = .empty,
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
};
pub const DropVisionItemResult = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    Drop: bool = false,
};
pub const RoleDevelopConfigRequest = struct {
    pub const default: @This() = .{};
    aVersion: ?union(enum) {
        Version: []const u8,
    } = null,
};
pub const LevelPlayVarAsyncRequest = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    LevelPlayId: i32 = 0,
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
pub const RbGridDirection = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    RbForward = 0,
    RbBackward = 1,
    RbRight = 2,
    RbLeft = 3,
};
pub const PayUpdateType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    None = 0,
    Daily = 1,
    Weekly = 2,
    Monthly = 3,
    Forever = 4,
};
pub const FollowerType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    EPlayerFollowerDefault = 0,
    EPlayerFollowerExploreSkill = 1,
    FollowerType_EPlayerFollowerAuxiliary = 2,
    FollowerType_EPlayerFollowerSpecialItem = 3,
    FollowerType_EPlayerFollowerMotor = 4,
    FollowerType_EPlayerFollowerMax = 5,
};
pub const EDamageImmune = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Default = 0,
    Invincible = 1,
    BuffEffectElement = 2,
    BulletCurNoCtrl = 3,
    VehiclePassenger = 4,
    FishBoat = 5,
};
pub const Rotator = struct {
    pub const default: @This() = .{};
    Pitch: f32 = 0,
    Yaw: f32 = 0,
    Roll: f32 = 0,
};
pub const FloatArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(f32) = .empty,
};
pub const SummonInfo = struct {
    pub const default: @This() = .{};
    SummonCfgId: i32 = 0,
    SummonerId: i64 = 0,
    SummonSkillId: i32 = 0,
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
pub const ExchangeRewardRequest = struct {
    pub const default: @This() = .{};
};
pub const SimpleCombatSplineMovePbType = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const Int2Long = struct {
    pub const default: @This() = .{};
    First: i32 = 0,
    Second: i64 = 0,
};
pub const PutVisionGroupToTopRequest = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
};
pub const FishingItemRotate = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    No = 0,
    DirectionDown = 1,
    DirectionLeft = 2,
    DirectionUp = 3,
};
pub const PhantomArenaRoleInfo = struct {
    pub const default: @This() = .{};
    RoleInfoId: i32 = 0,
    IsUnlock: bool = false,
    IsTaken: bool = false,
};
pub const ExitViewDirectionRequest = struct {
    pub const default: @This() = .{};
};
pub const NearbyTrackingComponentPb = struct {
    pub const default: @This() = .{};
    IsEnable: bool = false,
};
pub const ClientStorageIntData = struct {
    pub const default: @This() = .{};
    Data: i32 = 0,
};
pub const NpcDriveVehicleComponentPb = struct {
    pub const default: @This() = .{};
    VehicleCreatureId: i64 = 0,
    Seat: i32 = 0,
};
pub const AfterJoinSceneNotify = struct {
    pub const default: @This() = .{};
};
pub const GridPbDirection = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    GridForward = 0,
    GridBackward = 1,
    GridLeft = 2,
    GridRight = 3,
};
pub const HackingComponentPb = struct {
    pub const default: @This() = .{};
    EntityIds: std.ArrayList(i64) = .empty,
};
pub const PlayerTitleDataRequest = struct {
    pub const default: @This() = .{};
};
pub const MailBindInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const MapTraceRequest = struct {
    pub const default: @This() = .{};
    MarkId: i32 = 0,
};
pub const RemoveCombineRelationNotify = struct {
    pub const default: @This() = .{};
    CombineEntity: i64 = 0,
    TargetEntity: i64 = 0,
};
pub const HonamiStoryAreaConfig = struct {
    pub const default: @This() = .{};
    AreaId: i32 = 0,
    Status: i32 = 0,
    SecreteStatus: i32 = 0,
};
pub const TutorialInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const SceneTraceResponse = struct {
    pub const default: @This() = .{};
};
pub const ExploreToolAllNotify = struct {
    pub const default: @This() = .{};
    SkillList: std.ArrayList(i32) = .empty,
    ExploreSkill: i32 = 0,
    NewUnlock: std.ArrayList(i32) = .empty,
};
pub const VisionAttrRecommendInfo = struct {
    pub const default: @This() = .{};
    AttrType: i32 = 0,
    AddType: i32 = 0,
    Usage: i32 = 0,
};
pub const ArraySkillNode = struct {
    pub const default: @This() = .{};
    SkillNodeId: i32 = 0,
    IsActive: bool = false,
    SkillId: i32 = 0,
};
pub const BoneVisibleData = struct {
    pub const default: @This() = .{};
    BoneName: []const u8 = "",
    HideBone: bool = false,
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
pub const ANStartPush = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
    AnIndex: i32 = 0,
};
pub const ExploreSkillRoulette = struct {
    pub const default: @This() = .{};
    SkillIds: std.ArrayList(i32) = .empty,
    ExtraItemId: i32 = 0,
    ExploreSkill: i32 = 0,
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
pub const PlayMontageTaskAndPush = struct {
    pub const default: @This() = .{};
    MontageName: []const u8 = "",
    MontagePathHash: i32 = 0,
    SpeedRatio: f32 = 0,
    StartSection: []const u8 = "",
    StartTimeSeconds: f32 = 0,
};
pub const PhotoMemoryRequest = struct {
    pub const default: @This() = .{};
};
pub const ProtoKeyRequest = struct {
    pub const default: @This() = .{};
    IsLogin: bool = false,
    TraceId: []const u8 = "",
};
pub const MailLevel = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    None = 0,
    General = 1,
    Important = 2,
};
pub const RefreshBuffDurationPush = struct {
    pub const default: @This() = .{};
    BuffIds: std.ArrayList(i64) = .empty,
};
pub const ToughCalcExtraRatioChangePush = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    Duration: i32 = 0,
};
pub const ANStartNotify = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
    AnIndex: i32 = 0,
};
pub const CardShowEntry = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
    IsRead: bool = false,
};
pub const LivenessRequest = struct {
    pub const default: @This() = .{};
};
pub const BattleStateChangePush = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    InBattle: bool = false,
};
pub const DrownEndTeleportRequest = struct {
    pub const default: @This() = .{};
};
pub const BuffEffectPush = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    Index: i32 = 0,
};
pub const RoleRecordComponentPb = struct {
    pub const default: @This() = .{};
    IsAutoRole: bool = false,
    ConstateId: i64 = 0,
};
pub const SetFocusModeDeterConditionRequest = struct {
    pub const default: @This() = .{};
    DisableId: bool = false,
};
pub const FishCup = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    SilverCup = 0,
    NormalCup = 1,
    GoldCup = 2,
};
pub const PhantomArenaBadgeReward = struct {
    pub const default: @This() = .{};
    BadgeRewardId: i32 = 0,
    NeedCount: i32 = 0,
    IsTaken: bool = false,
};
pub const Int2Bool = struct {
    pub const default: @This() = .{};
    First: i32 = 0,
    Second: bool = false,
};
pub const AdventureManualRequest = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
};
pub const PbAdviceContentType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Sentence = 0,
    Conjunction = 1,
    Expression = 2,
    Motion = 3,
};
pub const HeartbeatResponse = struct {
    pub const default: @This() = .{};
};
pub const ChatContentType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Text = 0,
    Emoji = 1,
};
pub const RoleGoDownPush = struct {
    pub const default: @This() = .{};
};
pub const CiacconaGalRewardData = struct {
    pub const default: @This() = .{};
    RewardDataId: i32 = 0,
    CanReceive: bool = false,
    IsRewarded: bool = false,
};
pub const TetrisLevelInfo = struct {
    pub const default: @This() = .{};
    vdC: ?union(enum) {
        DifficultyIdx: i32,
    } = null,
    ehC: ?union(enum) {
        state: i32,
    } = null,
    thC: ?union(enum) {
        UnlockTime: i64,
    } = null,
    id: i32 = 0,
    Results: std.ArrayList(MapEntry(i32, i32)) = .empty,
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
    ErrorCode_GateTokenAccessException = 25,
    ErrorCode_GateLoginUserIdErr = 26,
    ErrorCode_GateLoginNodeIdErr = 27,
    ErrorCode_GateLoginCreateCharacterErr = 28,
    ErrorCode_GateCreateCharacterException = 29,
    ErrorCode_GateEnterGameAddressNotFound = 30,
    ErrorCode_GateEnterGameException = 31,
    ErrorCode_GateEnterGameCreatePlayerErr = 32,
    ErrorCode_GateEnterGameAddPlayerErr = 33,
    ErrorCode_GameGateNodeNotFound = 34,
    ErrorCode_GamePlayerAdminExist = 35,
    ErrorCode_GameReloginGateNodeNotFound = 36,
    ErrorCode_GameReloginPlayerNotFound = 37,
    ErrorCode_ServerNotOpen = 38,
    ErrorCode_ServerMaintenance = 39,
    ErrorCode_InvalidLoginType = 40,
    ErrorCode_InvalidGateway = 41,
    ErrorCode_SDKServerError = 42,
    ErrorCode_TokenNotAuthrized = 43,
    ErrorCode_HadBan = 44,
    ErrorCode_NotInUserIdWhiteList = 45,
    ErrorCode_NoHealthyGamesvr = 46,
    ErrorCode_NoHealthyGateway = 47,
    ErrorCode_GarFailed = 48,
    ErrorCode_GarSdkCheckFail = 49,
    ErrorCode_GarNoneUserInfo = 50,
    ErrorCode_GarQueryUserInfoError = 51,
    ErrorCode_GarNoRegion = 52,
    ErrorCode_InternalExceptionCode = 53,
    ErrorCode_DecodeExceptionCode = 54,
    ErrorCode_EncodeExceptionCode = 55,
    ErrorCode_InvalidRequestExceptionCode = 56,
    ErrorCode_MessageOutOfLimitExceptionCode = 57,
    ErrorCode_MessageNoHandler = 58,
    ErrorCode_EncryptionNoCreate = 59,
    ErrorCode_DecryptFail = 60,
    ErrorCode_PlayerNotInTheScene = 61,
    ErrorCode_NonReentrantExceptionCode = 62,
    ErrorCode_PlayerLoggedOut = 63,
    ErrorCode_MsgFunctionClose = 64,
    ErrorCode_SeqNoError = 65,
    ErrorCode_InvalidMessageType = 66,
    ErrorCode_InvalidMessageHeader = 67,
    ErrorCode_InvalidSeqNo = 68,
    ErrorCode_InvalidMessageId = 69,
    ErrorCode_ProtobufDecodeFailed = 70,
    ErrorCode_ErrProtoSeedCheck = 71,
    ErrorCode_MessageCouldNotBeRouted = 72,
    ErrorCode_ErrPlayerLogined = 73,
    ErrorCode_ClosedRegister = 100000,
    ErrorCode_RegisterOutOfLimit = 100001,
    ErrorCode_HaveNoCharacter = 100002,
    ErrorCode_InvalidCharacterName = 100003,
    ErrorCode_CreateCharacterFailed = 100004,
    ErrorCode_CreateCharacterDuplicateKey = 100005,
    ErrorCode_PlayerAlreadyLogin = 100006,
    ErrorCode_PlayerLoggingIn = 100007,
    ErrorCode_ErrLoginGWReconnecting = 100008,
    ErrorCode_LoginRetry = 100009,
    ErrorCode_QueryPlayerDataFailed = 100010,
    ErrorCode_CheckPlayerDataFailed = 100011,
    ErrorCode_CheckPlayerDataFailedDebug = 100012,
    ErrorCode_LogoutUnknownError = 100013,
    ErrorCode_AccountLoggedInElsewhere = 100014,
    ErrorCode_AccountIsBlocked = 100015,
    ErrorCode_DataOverflow = 100016,
    ErrorCode_AccountBeKick = 100017,
    ErrorCode_AppVersionNotMatch = 100018,
    ErrorCode_LauncherVersionIsTooLow = 100019,
    ErrorCode_ResourceVersionIsTooLow = 100020,
    ErrorCode_CloseConnection = 100021,
    ErrorCode_ErrAcquirePlayerLockFailed = 100022,
    ErrorCode_ErrPlayerLoggingOut = 100023,
    ErrorCode_MessageChecksumFailed = 100024,
    ErrorCode_LoginTimeout = 100025,
    ErrorCode_ErrWeaponDefault = 200000,
    ErrorCode_ErrWeaponLevelLimit = 200001,
    ErrorCode_ErrWeaponBreachLimit = 200002,
    ErrorCode_ErrWeaponConsumeInvalid = 200003,
    ErrorCode_ErrWeaponPkgFull = 200004,
    ErrorCode_ErrRoleNoConfig = 200005,
    ErrorCode_ErrRoleIsActive = 200006,
    ErrorCode_ErrRoleNotActive = 200007,
    ErrorCode_ErrRoleOverNotEnough = 200008,
    ErrorCode_ErrRoleLevelNotEnough = 200009,
    ErrorCode_ErrRoleException = 200010,
    ErrorCode_ErrRoleNotExchange = 200011,
    ErrorCode_ErrRoleResonNotActive = 200012,
    ErrorCode_ErrRoleResonIsActive = 200013,
    ErrorCode_ErrRoleConfigNotRight = 200014,
    ErrorCode_ErrRoleLevelMax = 200015,
    ErrorCode_ErrRolePerResonNotActive = 200016,
    ErrorCode_ErrRoleConditionNotFind = 200017,
    ErrorCode_ErrRoleConditionNoEnough = 200018,
    ErrorCode_ErrRoleInvalidNameLength = 200019,
    ErrorCode_ErrRoleExpInvalid = 200020,
    ErrorCode_ErrRoleActiveNeedNoEnough = 200021,
    ErrorCode_ErrRoleResonMaxLevel = 200022,
    ErrorCode_ErrRoleProtoError = 200023,
    ErrorCode_ErrRoleItemListEmpty = 200024,
    ErrorCode_ErrRoleItemListCountOutRange = 200025,
    ErrorCode_ErrRoleItemExpError = 200026,
    ErrorCode_ErrRolePhantPosError = 200027,
    ErrorCode_ErrRolePhantSameError = 200028,
    ErrorCode_ErrRolePhantEmptyError = 200029,
    ErrorCode_ErrRoleItemListNoEnough = 200030,
    ErrorCode_ErrRoleGetSkillByIdFailed = 200031,
    ErrorCode_ErrRoleFavorLevelNotEnough = 200032,
    ErrorCode_ErrRolSkillNodeType = 200033,
    ErrorCode_ErrRolSkillNodeTypeActive = 200034,
    ErrorCode_ErrRolSkillNodeTypeUlock = 200035,
    ErrorCode_ErrRolSkillPointsNotEnough = 200036,
    ErrorCode_ErrTrialRoleExist = 200037,
    ErrorCode_ErrTrialRoleNotExist = 200038,
    ErrorCode_ErrTrialRoleRegionDataExist = 200039,
    ErrorCode_ErrTrialRoleBtObjDataExist = 200040,
    ErrorCode_ErrTrialRoleRegionExist = 200041,
    ErrorCode_ErrTrialRoleRegionNotExist = 200042,
    ErrorCode_ErrLoadEquipDefault = 200043,
    ErrorCode_ErrLoadEquipInvalidPos = 200044,
    ErrorCode_ErrLoadEquipInvalidRole = 200045,
    ErrorCode_ErrLoadEquipRoleConfig = 200046,
    ErrorCode_ErrPhantomIdNotExist = 200047,
    ErrorCode_ErrPhantomNotExist = 200048,
    ErrorCode_ErrPhantomLvupMax = 200049,
    ErrorCode_ErrPhantomLvupMismatchItemId = 200050,
    ErrorCode_ErrPhantomLvupNoItem = 200051,
    ErrorCode_ErrPhantomLvupLimit = 200052,
    ErrorCode_ErrPhantomItemType = 200053,
    ErrorCode_ErrPhantomInvalidPos = 200054,
    ErrorCode_ErrPhantomConfigNotFound = 200055,
    ErrorCode_ErrPhantomItemNotExist = 200056,
    ErrorCode_ErrPhantomPropNotExist = 200057,
    ErrorCode_ErrPhantomQaulityNotExist = 200058,
    ErrorCode_ErrPhantomBreachNotExist = 200059,
    ErrorCode_ErrPhantomLevelNotEnough = 200060,
    ErrorCode_ErrPhantomExpItemNotExist = 200061,
    ErrorCode_ErrPhantomSubPropRandomErr = 200062,
    ErrorCode_ErrPhantomSubPropNotEnough = 200063,
    ErrorCode_ErrPhantomSubPropGenDupicate = 200064,
    ErrorCode_ErrPhantomSubStrengthenPropNotExist = 200065,
    ErrorCode_ErrPhantomLevelConfigNotExist = 200066,
    ErrorCode_ErrPhantomLevelUpConsumeItemNotEnough = 200067,
    ErrorCode_ErrPhantomLevelUpMaterialLock = 200068,
    ErrorCode_ErrPhantomLevelUpConsumeItemErr = 200069,
    ErrorCode_ErrPhantomLevelUpRepeatItem = 200070,
    ErrorCode_ErrPhantomMainPropNotExist = 200071,
    ErrorCode_ErrPhantomGrowthNotExist = 200072,
    ErrorCode_ErrPhantomBreachItemCount = 200073,
    ErrorCode_ErrPhantomBreachRepeatItem = 200074,
    ErrorCode_ErrPhantomDecomposeEquiped = 200075,
    ErrorCode_ErrPhantomDecomposeFail = 200076,
    ErrorCode_ErrPhantomBreachBindItem = 200077,
    ErrorCode_ErrPhantomBreachErrItem = 200078,
    ErrorCode_ErrPhantomRecommendNoData = 200079,
    ErrorCode_ErrPhantomCannotTakeOff = 200080,
    ErrorCode_ErrPhantomCannotReplace = 200081,
    ErrorCode_ErrVisionSkillFavoriteTypeLimit = 200082,
    ErrorCode_ErrVisionSkillFavoriteCountLimit = 200083,
    ErrorCode_ErrVisionSkillCfgNotFound = 200084,
    ErrorCode_ErrVisionSkillNotFound = 200085,
    ErrorCode_ErrVisionSkillLevelUpMax = 200086,
    ErrorCode_ErrVisionSkillLevelUpLimit = 200087,
    ErrorCode_ErrVisionSkillSlotNotFound = 200088,
    ErrorCode_ErrVisionSkillEquipTypeLimit = 200089,
    ErrorCode_ErrVisionSkillUnEquipLimit = 200090,
    ErrorCode_ErrVisionSkillGemCfgNotFound = 200091,
    ErrorCode_ErrVisionSkillEquipLimit = 200092,
    ErrorCode_ErrVisionSkillGemLimit = 200093,
    ErrorCode_ErrVisionSkillOperFail = 200094,
    ErrorCode_ErrVisionSkillSlotEquipLimit = 200095,
    ErrorCode_ErrExploreSkillRouletteRepeat = 200096,
    ErrorCode_ErrItemCfgNotFound = 200097,
    ErrorCode_ErrItemNotFound = 200098,
    ErrorCode_ErrItemNotEnough = 200099,
    ErrorCode_ErrItemDecomposeLimit = 200100,
    ErrorCode_ErrItemUseLevelLimit = 200101,
    ErrorCode_ErrItemLockLimit = 200102,
    ErrorCode_ErrItemInvalidParams = 200103,
    ErrorCode_ErrItemDecomposeFail = 200104,
    ErrorCode_ErrItemUseFail = 200105,
    ErrorCode_ErrExchangeRewardCostItemNotEnough = 200106,
    ErrorCode_ExchangeRewardSuccess = 200107,
    ErrorCode_ErrPkgCapacityNotEnough = 200108,
    ErrorCode_ErrGiftOptionalCount = 200109,
    ErrorCode_ErrGiftOptionalNotExists = 200110,
    ErrorCode_ErrGiftNotExists = 200111,
    ErrorCode_ErrItemCount = 200112,
    ErrorCode_ErrItemIdNotContain = 200113,
    ErrorCode_ErrItemTypeNotContain = 200114,
    ErrorCode_ErrCalabashMaxLevel = 200115,
    ErrorCode_ErrCalabashConfig = 200116,
    ErrorCode_ErrCalabashLevelUp = 200117,
    ErrorCode_ErrCalabashExp = 200118,
    ErrorCode_ErrCalabashDevelopNoReward = 200119,
    ErrorCode_ErrCalabashMonsterNotFound = 200120,
    ErrorCode_PropRewardTips = 200121,
    ErrorCode_ErrEnergyMaxCharge = 200122,
    ErrorCode_ErrStateCanotTeleport = 200123,
    ErrorCode_ErrStateCannotEnterInst = 200124,
    ErrorCode_ErrStateCannotOnline = 200125,
    ErrorCode_ErrStateCannotChangeFormation = 200126,
    ErrorCode_ErrReportPlayerCountLimit = 200127,
    ErrorCode_ErrReportPlayerReasonNotFound = 200128,
    ErrorCode_ErrReportMessageLengthLimit = 200129,
    ErrorCode_ErrCookingToolFixed = 200130,
    ErrorCode_ErrCookingFormulaNotFound = 200131,
    ErrorCode_ErrCookingCount = 200132,
    ErrorCode_ErrCookingProcessNotFound = 200133,
    ErrorCode_ErrCookingLevelNotFound = 200134,
    ErrorCode_ErrCookingLevelLimt = 200135,
    ErrorCode_ErrCookingInteractiveNotFound = 200136,
    ErrorCode_ErrCookingFuncNotOpen = 200137,
    ErrorCode_ErrChallengeNotFound = 200138,
    ErrorCode_ErrChallengeNoTeam = 200139,
    ErrorCode_ErrChallengeTeamLimit = 200140,
    ErrorCode_ErrChallengeTeamMemLimit = 200141,
    ErrorCode_ErrChallengeChangeFormation = 200142,
    ErrorCode_ErrChallengeFunNotOpen = 200143,
    ErrorCode_ErrChallengeSeasonUpdate = 200144,
    ErrorCode_ErrChallengeLockRoleLimit = 200145,
    ErrorCode_ErrChallengeRoleLocked = 200146,
    ErrorCode_ErrChallengeNoRoleAlive = 200147,
    ErrorCode_ErrChallengeFormationEmpty = 200148,
    ErrorCode_ErrCycleChallengeNoRoleAlive = 200149,
    ErrorCode_ErrCycleChallengeFormationEmpty = 200150,
    ErrorCode_ErrInfluenceLocked = 200151,
    ErrorCode_ErrInfluenceRewardNotFound = 200152,
    ErrorCode_ErrInfluenceConfigNotFound = 200153,
    ErrorCode_ErrReputationLimit = 200154,
    ErrorCode_ErrInfluenceRewardFailed = 200155,
    ErrorCode_ErrInfluenceFunNotOpen = 200156,
    ErrorCode_ErrForgeFuncNotOpen = 200157,
    ErrorCode_ErrForgeCountLimit = 200158,
    ErrorCode_ErrForgeLocked = 200159,
    ErrorCode_ErrForgeConfigNotFound = 200160,
    ErrorCode_ErrForgeUnlocked = 200161,
    ErrorCode_ErrSynthesisFuncNotOpen = 200162,
    ErrorCode_ErrSynthesisConfigNotFound = 200163,
    ErrorCode_ErrSynthesisCountLimit = 200164,
    ErrorCode_ErrSynthesisLocked = 200165,
    ErrorCode_ErrSynthesisLevelNotFound = 200166,
    ErrorCode_ErrSynthesisLevelLimit = 200167,
    ErrorCode_ErrSynthesisCannotUnlock = 200168,
    ErrorCode_ErrSynthesisUnlocked = 200169,
    ErrorCode_ErrTrialRoleCannotMatch = 200170,
    ErrorCode_ErrPhantomFormationTeleport = 200171,
    ErrorCode_ErrPhantomFormationEnterInst = 200172,
    ErrorCode_ErrPhantomFormationMultiPlay = 200173,
    ErrorCode_ErrPhantomFormationAdvice = 200174,
    ErrorCode_ErrPhantomFormationChangeFormation = 200175,
    ErrorCode_ErrPhantomFormationRepeat = 200176,
    ErrorCode_ErrPhantomFormationChangeFailed = 200177,
    ErrorCode_ErrRoleChangeRoleCreateFailed = 200178,
    ErrorCode_ErrRoleChangeRoleUpdateCreateFailed = 200179,
    ErrorCode_ErrRoleChangeRoleNotUnlock = 200180,
    ErrorCode_ErrRoleChangeMultiPlay = 200181,
    ErrorCode_ErrRoleChangeInst = 200182,
    ErrorCode_ErrRoleChangeElementFunc = 200183,
    ErrorCode_ErrPhantomFormationCannotJoin = 200184,
    ErrorCode_ErrPhantomFormationHost = 200185,
    ErrorCode_ErrRoleChangeShowAllRole = 200186,
    ErrorCode_ErrInteractBoardEntityNotFound = 200187,
    ErrorCode_ErrInteractBoardRange = 200188,
    ErrorCode_ErrInteractBoardSystemNotFound = 200189,
    ErrorCode_ErrInteractBoardEntityConfig = 200190,
    ErrorCode_ErrInteractEntranceNotFound = 200191,
    ErrorCode_ErrInteractEntranceNotMatch = 200192,
    ErrorCode_ErrItemMaxUseCount = 200193,
    ErrorCode_ErrFuncNotExist = 200194,
    ErrorCode_ErrPhantomChangeInBattle = 200195,
    ErrorCode_ErrItemCanNotDestroy = 200196,
    ErrorCode_ErrPhantomEquipSourceCost = 200197,
    ErrorCode_ErrPhantomEquipTargetCost = 200198,
    ErrorCode_ErrPhantomEquipDuplicate = 200199,
    ErrorCode_ErrPhantomAutoEquipFromOther = 200200,
    ErrorCode_ErrPhantomConsumeItemCount = 200201,
    ErrorCode_ErrPhantomConsumeItemDuplicate = 200202,
    ErrorCode_ErrPhantomConsumeItemIncrDuplicate = 200203,
    ErrorCode_ErrPhantomConsumeItem = 200204,
    ErrorCode_ErrPhantomConsumeNoExp = 200205,
    ErrorCode_ErrPhantomBreachPos = 200206,
    ErrorCode_ErrPhantomBreachSuspend = 200207,
    ErrorCode_ErrPhantomBreachQuality = 200208,
    ErrorCode_ErrPhantomBreachExp = 200209,
    ErrorCode_ErrPhantomBreachConsumeItem = 200210,
    ErrorCode_ErrPhantomBreachNoSuspend = 200211,
    ErrorCode_ErrPhantomSpecialSkillRole = 200212,
    ErrorCode_ErrPhantomNotEquip = 200213,
    ErrorCode_ErrPhantomSpecilSkillPos = 200214,
    ErrorCode_ErrPhantomSubPropPlanConfig = 200215,
    ErrorCode_ErrPhantomMainPropGenFail = 200216,
    ErrorCode_ErrLivenessFuncNotOpen = 200217,
    ErrorCode_ErrLivenessTaskNotFound = 200218,
    ErrorCode_ErrLivenessTaskDataNotFound = 200219,
    ErrorCode_ErrLivenessTaskNotFinish = 200220,
    ErrorCode_ErrLivenessTaskRewarded = 200221,
    ErrorCode_ErrLivenessRewardNotFound = 200222,
    ErrorCode_ErrLivenessGoalNotReach = 200223,
    ErrorCode_ErrLivenessRewardParam = 200224,
    ErrorCode_ErrLivenessTaskRewardParam = 200225,
    ErrorCode_ErrWeaponLevelUpComsumeCount = 200226,
    ErrorCode_ErrWeaponConsumeSelf = 200227,
    ErrorCode_ErrWeaponConsumeItemNotFound = 200228,
    ErrorCode_ErrWeaponConsumeItemIdNotFound = 200229,
    ErrorCode_ErrWeaponLocked = 200230,
    ErrorCode_ErrWeaponConsumeDuplicate = 200231,
    ErrorCode_ErrWeaponEquiped = 200232,
    ErrorCode_ErrWeaponLevelUpItemDuplicate = 200233,
    ErrorCode_ErrWeaponLevelUpNoExp = 200234,
    ErrorCode_ErrWeaponLevelUpLevel = 200235,
    ErrorCode_ErrPhantomMainPropNotMatch = 200236,
    ErrorCode_ErrPhantomSubPropNotMatch = 200237,
    ErrorCode_ErrPhantomEquiped = 200238,
    ErrorCode_ErrAdviceNotInit = 200239,
    ErrorCode_ErrTowerChallengeNotOpen = 200240,
    ErrorCode_ErrTowerNotInChallenge = 200241,
    ErrorCode_ErrTowerConfigNotFound = 200242,
    ErrorCode_ErrTowerChallengeNotInOpenTime = 200243,
    ErrorCode_ErrTowerInChallenge = 200244,
    ErrorCode_ErrTowerFormationCount = 200245,
    ErrorCode_ErrTowerFormationRoleDuplicate = 200246,
    ErrorCode_ErrTowerRoleCost = 200247,
    ErrorCode_ErrTowerDifficultyNotClear = 200248,
    ErrorCode_ErrTowerFloorNotClear = 200249,
    ErrorCode_ErrTowerAreaNotClear = 200250,
    ErrorCode_ErrTowerRecommendNotSettle = 200251,
    ErrorCode_ErrTowerRewardNotFound = 200252,
    ErrorCode_ErrTowerNoReward = 200253,
    ErrorCode_ErrTowerRewarded = 200254,
    ErrorCode_ErrTowerRewardTarget = 200255,
    ErrorCode_ErrTowerSeasonUpdate = 200256,
    ErrorCode_ErrLordGymConfigNotFound = 200257,
    ErrorCode_ErrLordGymNotInPlay = 200258,
    ErrorCode_ErrLordGymLock = 200259,
    ErrorCode_ErrLordGymBtTreeNotFound = 200260,
    ErrorCode_ErrRoleSexFuncNotOpen = 200261,
    ErrorCode_ErrPhantomSubPropLocked = 200262,
    ErrorCode_ErrPhantomIdentifyNoCost = 200263,
    ErrorCode_ErrGiftPackType = 200264,
    ErrorCode_ErrGiftPackUseLimit = 200265,
    ErrorCode_ErrCdKeyNotEnable = 200266,
    ErrorCode_ErrCdKeyRequestCount = 200267,
    ErrorCode_ErrCdKeyRequestErr = 200268,
    ErrorCode_ErrCdKeyRequestDataErr = 200269,
    ErrorCode_ErrCdKeyException = 200270,
    ErrorCode_ErrCdKeyProcessCount = 200271,
    ErrorCode_ErrCdKeyNotFound = 200272,
    ErrorCode_ErrCdKeyBatchNotFound = 200273,
    ErrorCode_ErrCdKeyNotInValidTime = 200274,
    ErrorCode_ErrCdKeyBatchMaxCount = 200275,
    ErrorCode_ErrCdKeyEachPlayerMaxCount = 200276,
    ErrorCode_ErrCdKeyGroupCount = 200277,
    ErrorCode_ErrCdKeyCondition = 200278,
    ErrorCode_ErrCdKeyAddCountFail = 200279,
    ErrorCode_ErrCdKeyLength = 200280,
    ErrorCode_ErrCdKeyCharacter = 200281,
    ErrorCode_ErrGiftPackRandomErr = 200282,
    ErrorCode_ErrReconnectUserWhiteList = 200283,
    ErrorCode_ErrReconnectChannelWhiteList = 200284,
    ErrorCode_ErrReconnectIpInvalid = 200285,
    ErrorCode_ErrReconnectIpWhiteList = 200286,
    ErrorCode_ErrCdKeyExpire = 200287,
    ErrorCode_ErrWeaponResonLevelLimit = 200288,
    ErrorCode_ErrWeaponConfigNotFound = 200289,
    ErrorCode_ErrWeaponResonConfigNotFound = 200290,
    ErrorCode_ErrWeaponResonConsumeItem = 200291,
    ErrorCode_ErrWeaponResonConsumeGold = 200292,
    ErrorCode_ErrDestroyItemDuplicate = 200293,
    ErrorCode_ErrDestroyWeapon = 200294,
    ErrorCode_ErrCannotDestroyItem = 200295,
    ErrorCode_ErrCannotDestroyPhantom = 200296,
    ErrorCode_ErrCannotDestroyWeaponForm = 200297,
    ErrorCode_ErrCannotDestroyItemUnknown = 200298,
    ErrorCode_ErrWeaponConsumeQuality = 200299,
    ErrorCode_ErrPhantomSkinChangeCd = 200300,
    ErrorCode_ErrPhantomSkinUnlock = 200301,
    ErrorCode_ErrPhantomSkinMatch = 200302,
    ErrorCode_ErrLoginGameTainted = 200303,
    ErrorCode_ErrCookLimitCount = 200304,
    ErrorCode_ErrCookLimitTime = 200305,
    ErrorCode_ErrForgeLimitCount = 200306,
    ErrorCode_ErrForgeLimitTime = 200307,
    ErrorCode_ErrSynthesisLimitCount = 200308,
    ErrorCode_ErrSynthesisLimitTime = 200309,
    ErrorCode_ErrLoginIpBan = 200310,
    ErrorCode_ErrLoginDeviceBan = 200311,
    ErrorCode_ErrRoleNameEmpty = 200312,
    ErrorCode_ErrAdviceLength = 200313,
    ErrorCode_ErrPhantomRefiningCount = 200314,
    ErrorCode_ErrPhantomRefiningScore = 200315,
    ErrorCode_ErrPhantomRefiningTotalScore = 200316,
    ErrorCode_ErrPhantomRefiningDeveloped = 200317,
    ErrorCode_ErrPhotoMemoryCollectConfig = 200318,
    ErrorCode_ErrPhotoMemoryFuncNotOpen = 200319,
    ErrorCode_ErrPhotoMemoryCollectLock = 200320,
    ErrorCode_ErrPhotoMemoryCollectRewarded = 200321,
    ErrorCode_ErrRoleCount = 200322,
    ErrorCode_ErrCookFormulaUnlocked = 200323,
    ErrorCode_ErrForgeFormulaUnlocked = 200324,
    ErrorCode_ErrSynthesisFormulaUnlocked = 200325,
    ErrorCode_ErrCookFormulaBuyCount = 200326,
    ErrorCode_ErrForgeFormulaBuyCount = 200327,
    ErrorCode_ErrSynthesisFormulaBuyCount = 200328,
    ErrorCode_ErrCdKeyDailyVerifyCount = 200329,
    ErrorCode_ErrLongShanTaskNotFound = 200330,
    ErrorCode_ErrLongShanActivityClosed = 200331,
    ErrorCode_ErrLongShanTaskNotAccept = 200332,
    ErrorCode_ErrLongShanTaskNotComplete = 200333,
    ErrorCode_ErrLongShanTaskRewarded = 200334,
    ErrorCode_ErrTowerDefenceRewardParamErr = 200335,
    ErrorCode_ErrTowerDefenceInstanceNotFound = 200336,
    ErrorCode_ErrTowerDefenceActivityNotOpen = 200337,
    ErrorCode_ErrTowerDefenceActivityDataNotFound = 200338,
    ErrorCode_ErrTowerDefenceInstDataNotFound = 200339,
    ErrorCode_ErrTowerDefenceInstRewarded = 200340,
    ErrorCode_ErrTowerDefenceInstScoreNotEnough = 200341,
    ErrorCode_ErrTowerDefenceScoreRewarded = 200342,
    ErrorCode_ErrTowerDefenceScoreRewardNotEnough = 200343,
    ErrorCode_ErrTowerDefenceScoreRewardNotFound = 200344,
    ErrorCode_ErrTowerDefenceInstBuffNotEnable = 200345,
    ErrorCode_ErrTowerDefencePhantomDuplicate = 200346,
    ErrorCode_ErrTowerDefencePhantomNotSelect = 200347,
    ErrorCode_ErrorTowerDefenceInstNotOpen = 200348,
    ErrorCode_ErrorTowerDefenceInstCondition = 200349,
    ErrorCode_ErrNameModifyCd = 200350,
    ErrorCode_ErrNameVerifying = 200351,
    ErrorCode_ErrTimePointRewardActivityConfigNotFound = 200352,
    ErrorCode_ErrTimePointRewardActivityNotOpen = 200353,
    ErrorCode_ErrTimePointRewardActivityRewarded = 200354,
    ErrorCode_ErrTimePointRewardActivityTime = 200355,
    ErrorCode_ErrCDKeyVerifying = 200356,
    ErrorCode_ErrorTowerDefenceInstLocked = 200357,
    ErrorCode_ErrTrackMoonEntrustLocked = 200358,
    ErrorCode_ErrTrackMoonRoleLocked = 200359,
    ErrorCode_ErrTrackMoonBuildLocked = 200360,
    ErrorCode_ErrTrackMoonBuildEntity = 200361,
    ErrorCode_ErrCopyUserRequestErr = 200362,
    ErrorCode_ErrCopyUserInserting = 200363,
    ErrorCode_ErrCopyUserErr = 200364,
    ErrorCode_ErrCopyUserDataErr = 200365,
    ErrorCode_ErrCopyUserInsertErr = 200366,
    ErrorCode_ErrCopyUserInsertFailed = 200367,
    ErrorCode_ErrRiskHarvestBuffGroupNotFound = 200368,
    ErrorCode_ErrRiskHarvestActivityClosePlay = 200369,
    ErrorCode_ErrRiskHarvestModeChangeClosePlay = 200370,
    ErrorCode_ErrRiskHarvestLeaveClosePlay = 200371,
    ErrorCode_ErrRiskHarvestInstNotFound = 200372,
    ErrorCode_ErrRiskHarvestActivityNotOpen = 200373,
    ErrorCode_ErrRiskHarvestInstDataNotFound = 200374,
    ErrorCode_ErrRiskHarvestInstRewarded = 200375,
    ErrorCode_ErrRiskHarvestInstNotPass = 200376,
    ErrorCode_ErrRiskHarvestScoreRewardNotFound = 200377,
    ErrorCode_ErrRiskHarvestScoreRewarded = 200378,
    ErrorCode_ErrRiskHarvestScoreNotEnough = 200379,
    ErrorCode_ErrRiskHarvestRoleTrial = 200380,
    ErrorCode_ErrRiskHarvestMatching = 200381,
    ErrorCode_ErrRiskHarvestNotDefaultWorld = 200382,
    ErrorCode_ErrRiskHarvestMultiMode = 200383,
    ErrorCode_ErrRiskHarvestInstLocked = 200384,
    ErrorCode_ErrRiskHarvestInstTeleportEntityNotFound = 200385,
    ErrorCode_ErrRiskHarvestInstOpen = 200386,
    ErrorCode_ErrRiskHarvestPlayOpenFailed = 200387,
    ErrorCode_ErrRiskHarvestPlayDataNotFound = 200388,
    ErrorCode_ErrRiskHarvestBuffNoReward = 200389,
    ErrorCode_ErrRiskHarvestBuffRewarded = 200390,
    ErrorCode_ErrRiskHarvestBuffLocked = 200391,
    ErrorCode_ErrRiskHarvestBuffCountRewardNotFound = 200392,
    ErrorCode_ErrRiskHarvestBuffCountRewarded = 200393,
    ErrorCode_ErrRiskHarvestBuffCountNotEnough = 200394,
    ErrorCode_ErrRiskHarvestInstScoreNotEnough = 200395,
    ErrorCode_ErrItemDisuseLimit = 200396,
    ErrorCode_ErrItemDisuseFunc = 200397,
    ErrorCode_ErrPhantomRefiningMaxCount = 200398,
    ErrorCode_ErrPhantomRefiningDulplicate = 200399,
    ErrorCode_ErrPhantomNotNormal = 200400,
    ErrorCode_ErrGetSelfPsnOnlineId = 200401,
    ErrorCode_ErrGetPsnUserPlayerErr = 200402,
    ErrorCode_ErrTowerDefenceHostLeave = 200403,
    ErrorCode_ErrRiskHarvestNotInInst = 200404,
    ErrorCode_ErrEnterInstTypeErr = 200405,
    ErrorCode_ErrInputSettingCount = 200406,
    ErrorCode_ErrInputSettingDeviceType = 200407,
    ErrorCode_ErrInputSettingActionCount = 200408,
    ErrorCode_ErrInputSettingAxisCount = 200409,
    ErrorCode_ErrInputCombinationActionCount = 200410,
    ErrorCode_ErrInputCombinationAxisCount = 200411,
    ErrorCode_ErrInputSettingActionName = 200412,
    ErrorCode_ErrInputSettingAxisName = 200413,
    ErrorCode_ErrInputCombinationActionName = 200414,
    ErrorCode_ErrInputCombinationAxisName = 200415,
    ErrorCode_ErrInputActionKeyNameLength = 200416,
    ErrorCode_ErrInputActionKeyLength = 200417,
    ErrorCode_ErrInputAxisKeyNameLength = 200418,
    ErrorCode_ErrInputAxisKeyLength = 200419,
    ErrorCode_ErrInputCombinationActionKeyNameLength = 200420,
    ErrorCode_ErrInputCombinationActionKeyLength = 200421,
    ErrorCode_ErrInputCombinationActionKeyListLength = 200422,
    ErrorCode_ErrInputCombinationAxisKeyNameLength = 200423,
    ErrorCode_ErrInputCombinationAxisKeyLength = 200424,
    ErrorCode_ErrInputCombinationAxisKeyListLength = 200425,
    ErrorCode_ErrInputDeviceSubTypeLength = 200426,
    ErrorCode_ErrPSNAccountBlocked = 200427,
    ErrorCode_ErrRoleNameInvalid = 200428,
    ErrorCode_ErrMailBindRewardNotBind = 200429,
    ErrorCode_ErrMailBindRewarded = 200430,
    ErrorCode_ErrInputSettingNull = 200431,
    ErrorCode_ErrMultiInstExchangeCountErr = 200432,
    ErrorCode_ErrMultiInstExchangeFirstPass = 200433,
    ErrorCode_ErrMultiInstExchangeActivity = 200434,
    ErrorCode_ErrMultiInstExchangeFuncNotOpen = 200435,
    ErrorCode_ErrMultiInstExchangeTypeErr = 200436,
    ErrorCode_ErrMultiInstExchangeLevelTypeErr = 200437,
    ErrorCode_ErrRoleSkinLocked = 200438,
    ErrorCode_ErrRoleSkinConfig = 200439,
    ErrorCode_ErrRoleSkinNotMatch = 200440,
    ErrorCode_ErrRoleSkinWeaponNotSuit = 200441,
    ErrorCode_ErrSdkLoginResetByPeer = 200442,
    ErrorCode_ErrSdkLoginHttpRequestException = 200443,
    ErrorCode_ErrSdkLoginTaskTimeout = 200444,
    ErrorCode_ErrSdkLoginTaskCanceled = 200445,
    ErrorCode_ErrSexChangeCd = 200446,
    ErrorCode_ErrSexChangeLogout = 200447,
    ErrorCode_ErrSexChangeTrialActive = 200448,
    ErrorCode_ErrLobbyListRequestLimit = 200449,
    ErrorCode_ErrLobbyQueryPlayerRequestLimit = 200450,
    ErrorCode_ErrPlayerBasicInfoRequestLimit = 200451,
    ErrorCode_ErrBlockPlayerRequestLimit = 200452,
    ErrorCode_ErrPsnPlayerInfoRequestLimit = 200453,
    ErrorCode_ErrFishingPosInvalidX = 200454,
    ErrorCode_ErrFishingPosInvalidY = 200455,
    ErrorCode_ErrFishingPosOverlap = 200456,
    ErrorCode_ErrFishingParamLengthCabinLeft = 200457,
    ErrorCode_ErrFishingParamLengthCabinRight = 200458,
    ErrorCode_ErrFishingCabinNotOpen = 200459,
    ErrorCode_ErrFishingCabinNotFound = 200460,
    ErrorCode_ErrFishingCountNotMatch = 200461,
    ErrorCode_ErrFishingDuplicate = 200462,
    ErrorCode_ErrFishingRemoveItemErr = 200463,
    ErrorCode_ErrFishingItemNotFound = 200464,
    ErrorCode_ErrFishingCountNotMatchRequest = 200465,
    ErrorCode_ErrFishingCountNotMatchCabin = 200466,
    ErrorCode_ErrFishingHandInNotMatch = 200467,
    ErrorCode_ErrFishingQuickSellNoItem = 200468,
    ErrorCode_ErrFishingNoQuickSell = 200469,
    ErrorCode_ErrFishingQuickSellConfig = 200470,
    ErrorCode_ErrFishingQuickSellNotFilled = 200471,
    ErrorCode_ErrFishingQuickSellItemErr = 200472,
    ErrorCode_ErrFishingNoSellItem = 200473,
    ErrorCode_ErrFishingCanNotSell = 200474,
    ErrorCode_ErrFishingItemConfigNotFound = 200475,
    ErrorCode_ErrFishingSellItemDuplicate = 200476,
    ErrorCode_ErrFishingPriceCalFailed = 200477,
    ErrorCode_ErrFishingSellCount = 200478,
    ErrorCode_ErrFishingPointNotOpen = 200479,
    ErrorCode_ErrFishingPointConfig = 200480,
    ErrorCode_ErrFishingPointCount = 200481,
    ErrorCode_ErrFishingTempCabinMax = 200482,
    ErrorCode_ErrFishingPointGenFail = 200483,
    ErrorCode_ErrFishingTechLevel = 200484,
    ErrorCode_ErrFishingPreNodeLock = 200485,
    ErrorCode_ErrFishingTechLock = 200486,
    ErrorCode_ErrFishingTechConfig = 200487,
    ErrorCode_ErrFishingLevelMax = 200488,
    ErrorCode_ErrFishingSkinConfig = 200489,
    ErrorCode_ErrFishingPortConfig = 200490,
    ErrorCode_ErrFishingEntrustConfig = 200491,
    ErrorCode_ErrFishingEntrustNotAccepted = 200492,
    ErrorCode_ErrFishingEntrustNotFound = 200493,
    ErrorCode_ErrFishingEntrustDestination = 200494,
    ErrorCode_ErrFishingEntrustItemNotEnough = 200495,
    ErrorCode_ErrFishingEntrustItemTotalNotMatch = 200496,
    ErrorCode_ErrFishingEntrustDumplicate = 200497,
    ErrorCode_ErrFishingEntrustEmptyItem = 200498,
    ErrorCode_ErrFishingEntrustItemNotMatch = 200499,
    ErrorCode_ErrFishingEntrustRefreshInitial = 200500,
    ErrorCode_ErrFishingEntrustRefreshPrice = 200501,
    ErrorCode_ErrFishingEntrustNotAcceptable = 200502,
    ErrorCode_ErrFishingNotInBigWorld = 200503,
    ErrorCode_ErrFishingMultiMode = 200504,
    ErrorCode_ErrFishingNotOwner = 200505,
    ErrorCode_ErrFishingSkinLock = 200506,
    ErrorCode_ErrFishingPortLock = 200507,
    ErrorCode_ErrFishingCageLock = 200508,
    ErrorCode_ErrFishingCageConfig = 200509,
    ErrorCode_ErrFishingHandInConfig = 200510,
    ErrorCode_ErrFishingHandInCountNotMatch = 200511,
    ErrorCode_ErrFishingTempPointData = 200512,
    ErrorCode_ErrFishingTempPointConfig = 200513,
    ErrorCode_ErrFishingBombItem = 200514,
    ErrorCode_ErrFishingBombNoPoint = 200515,
    ErrorCode_ErrFishingBaitArea = 200516,
    ErrorCode_ErrFishingNotSailing = 200517,
    ErrorCode_ErrFishingInPort = 200518,
    ErrorCode_ErrFishingInShip = 200519,
    ErrorCode_ErrFishingIllustratedRewardNotFound = 200520,
    ErrorCode_ErrFishingIllustratedRewarded = 200521,
    ErrorCode_ErrFishingIllustratedCondition = 200522,
    ErrorCode_ErrFishingTechOutputNotFound = 200523,
    ErrorCode_ErrFishingShipNotFound = 200524,
    ErrorCode_ErrFishingPortTech = 200525,
    ErrorCode_ErrFishingRemoveFuncNotOpen = 200526,
    ErrorCode_ErrFishingIllustratedFuncNotOpen = 200527,
    ErrorCode_ErrFishingSellFuncNotOpen = 200528,
    ErrorCode_ErrFishingTechFuncNotOpen = 200529,
    ErrorCode_ErrFishingEntrustHandInQuickSell = 200530,
    ErrorCode_ErrActivityPreOpenLock = 200531,
    ErrorCode_ErrActivityShowLock = 200532,
    ErrorCode_ErrShopGoodsVisibleCondition = 200533,
    ErrorCode_ErrShopGoodsDisableCondition = 200534,
    ErrorCode_ErrFishingEntrustRefreshFail = 200535,
    ErrorCode_ErrPlayerDataVersion = 200536,
    ErrorCode_ErrBrokenCircuitRejected = 200537,
    ErrorCode_ErrRateLimiterRejected = 200538,
    ErrorCode_ErrTimeoutRejected = 200539,
    ErrorCode_ErrLoginEnvironment = 200540,
    ErrorCode_ErrLoginUserEmpty = 200541,
    ErrorCode_ErrOldGameNodeLogoutFail = 200542,
    ErrorCode_ErrOldGameNodeLogoutOffline = 200543,
    ErrorCode_ErrReloginBranchNameNotMatch = 200544,
    ErrorCode_ErrReLoginFightDataInConsistent = 200545,
    ErrorCode_ErrCreatePlayerData = 200546,
    ErrorCode_ErrReLoginPlayerLoggingOut = 200547,
    ErrorCode_ErrAccountLoggedInElsewhere = 200548,
    ErrorCode_ErrTowerChallengeTeleportLocked = 200551,
    ErrorCode_ErrTowerDefenceGroupConfig = 200552,
    ErrorCode_ErrTowerDefencePreInstNotPass = 200553,
    ErrorCode_ErrTowerDefenceRankCd = 200554,
    ErrorCode_ErrFishingFixItemNotEnough = 200549,
    ErrorCode_ErrFishingEntrustUpdateItemNotEnough = 200550,
    ErrorCode_ErrTowerDefenceGroupActivityC = 200555,
    ErrorCode_ErrTowerDefenceGroupActivity = 200556,
    ErrorCode_ErrAbyssComNotFound = 200557,
    ErrorCode_ErrAbyssInstConfig = 200558,
    ErrorCode_ErrAbyssRoomConfig = 200559,
    ErrorCode_ErrAbyssEnterCtx = 200560,
    ErrorCode_ErrAbyssActivityNotOpen = 200561,
    ErrorCode_ErrAbyssRewardConfig = 200562,
    ErrorCode_ErrAbyssRewardNotOpen = 200563,
    ErrorCode_ErrAbyssRewardClosed = 200564,
    ErrorCode_ErrAbyssRewarded = 200565,
    ErrorCode_ErrAbyssRewardCondition = 200566,
    ErrorCode_ErrAbyssLastActionNotFinish = 200567,
    ErrorCode_ErrAbyssNextRoomNotFound = 200568,
    ErrorCode_ErrAbyssRoleNotEquip = 200569,
    ErrorCode_ErrAbyssEquipRoleNotExist = 200570,
    ErrorCode_ErrAbyssEquipRoleDuplicate = 200571,
    ErrorCode_ErrAbyssRoomNoBox = 200572,
    ErrorCode_ErrAbyssRewardPlayerCount = 200573,
    ErrorCode_ErrAbyssRewardBoxEntityIncId = 200574,
    ErrorCode_ErrAbyssBoxRewarded = 200575,
    ErrorCode_ErrAbyssBoxNotBelong = 200576,
    ErrorCode_ErrAbyssBoxConfigNotFound = 200577,
    ErrorCode_ErrAbyssBoxDropFailed = 200578,
    ErrorCode_ErrAbyssChallengeLocked = 200579,
    ErrorCode_ErrAbyssChallengeNoConsume = 200580,
    ErrorCode_ErrAbyssChallengeUnlockItem = 200581,
    ErrorCode_ErrAbyssLikePlayerNotInScene = 200582,
    ErrorCode_ErrAbyssLikeDuplicate = 200583,
    ErrorCode_ErrAbyssRoleItemNotFound = 200584,
    ErrorCode_ErrAbyssRoleConfig = 200585,
    ErrorCode_ErrAbyssRoleLevelConfig = 200586,
    ErrorCode_ErrAbyssRoleMaxPluginCount = 200587,
    ErrorCode_ErrAbyssRoleLevelMaxPlugin = 200588,
    ErrorCode_ErrAbyssPutOnDuplicate = 200589,
    ErrorCode_ErrAbyssEquipOldRoleFailed = 200590,
    ErrorCode_ErrAbyssSysthesisMaxCount = 200591,
    ErrorCode_ErrAbyssSysthesisItemDuplicate = 200592,
    ErrorCode_ErrAbyssPluginItemNotFound = 200593,
    ErrorCode_ErrAbyssPluginItemLocked = 200594,
    ErrorCode_ErrAbyssPluginConfigNotFound = 200595,
    ErrorCode_ErrAbyssPluginEquipped = 200596,
    ErrorCode_ErrAbyssQuialityConfig = 200597,
    ErrorCode_ErrAbyssSysthesisConsumeItemDuplicate = 200598,
    ErrorCode_ErrAbyssRankListCd = 200599,
    ErrorCode_ErrAbyssRoleUpLevel = 200600,
    ErrorCode_ErrAbyssRoleUpItem = 200601,
    ErrorCode_ErrAbyssRoleUpNoComsume = 200602,
    ErrorCode_ErrAbyssPreChallengeNotPass = 200603,
    ErrorCode_ErrAbyssSlotConfig = 200604,
    ErrorCode_ErrAbyssSlotNotMatch = 200605,
    ErrorCode_ErrAbyssInstUnlockTime = 200606,
    ErrorCode_ErrAbyssSettled = 200607,
    ErrorCode_ErrFormationTrailGender = 200608,
    ErrorCode_ErrLongShanStageLocked = 200609,
    ErrorCode_ErrAbyssRewardIdRepeated = 200610,
    ErrorCode_ErrAbyssRewardCount = 200611,
    ErrorCode_ErrOtherPlayerCondition = 200612,
    ErrorCode_ErrAbyssItemSkillBelongTo = 200613,
    ErrorCode_ErrLongShanScoreRewardCount = 200614,
    ErrorCode_ErrLongShanScoreRewardDuplicate = 200615,
    ErrorCode_ErrLongShanScoreRewardConfig = 200616,
    ErrorCode_ErrLongShanScoreRewardActivity = 200617,
    ErrorCode_ErrLongShanScoreRewarded = 200618,
    ErrorCode_ErrLongShanScoreNotEnough = 200619,
    ErrorCode_ErrAbyssDuplicatePassive = 200620,
    ErrorCode_ErrActivityLifePointChallengeNotFound = 200621,
    ErrorCode_ErrActivityLifePointNotOpen = 200622,
    ErrorCode_ErrActivityLifePointPreLocked = 200623,
    ErrorCode_ErrPhantomSettingRuleDuplicate = 200624,
    ErrorCode_ErrPhantomSettingRuleNotFound = 200625,
    ErrorCode_ErrPhantomSettingEmpty = 200626,
    ErrorCode_ErrPhantomSettingType = 200627,
    ErrorCode_ErrPhantomSettingNameLength = 200628,
    ErrorCode_ErrPhantomSettingNull = 200629,
    ErrorCode_ErrPhantomSettingIndexRange = 200630,
    ErrorCode_ErrPhantomRuleIndexRange = 200631,
    ErrorCode_ErrPhantomRuleCount = 200632,
    ErrorCode_ErrPhantomBathchOperCount = 200633,
    ErrorCode_ErrPhantomBathchType = 200634,
    ErrorCode_ErrMobileSettingRequestParam = 200635,
    ErrorCode_ErrMobileSettingParamDuplicate = 200636,
    ErrorCode_ErrCommonUiSettingRequestParam = 200637,
    ErrorCode_ErrCommonUiSettingParamDuplicate = 200638,
    ErrorCode_ErrCommonUiSettingConfig = 200639,
    ErrorCode_ErrActivityNotOpenTip = 200640,
    ErrorCode_ErrLineCrossChallengeNotFound = 200641,
    ErrorCode_ErrActivitylineCrossNotOpen = 200642,
    ErrorCode_ErrActivitylineCrossPreLocked = 200643,
    ErrorCode_ErrPhantomSettingFuncNotOpen = 200644,
    ErrorCode_ErrTowerSeasonConfig = 200645,
    ErrorCode_ErrAccountDeactivation = 200646,
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
    ErrorCode_ErrTowerForbidRechallenge = 200667,
    ErrorCode_ErrInputSettingActoinType = 200668,
    ErrorCode_ErrCreateCharacterGender = 200669,
    ErrorCode_ErrSkillBranchRoleValid = 200670,
    ErrorCode_ErrSkillBranchNotValid = 200671,
    ErrorCode_ErrTrailRoleSkillBranchNotValid = 200672,
    ErrorCode_ErrRoleDevConfigVersion = 200673,
    ErrorCode_ErrRoleDevConfigVersionTime = 200674,
    ErrorCode_ErrRoleDevConfigNoUpdate = 200675,
    ErrorCode_ErrMotorDevelopRequestParam = 200676,
    ErrorCode_ErrMotorDevelopParamDuplicate = 200677,
    ErrorCode_ErrMotorDevelopTaskNotFound = 200678,
    ErrorCode_ErrMotorDevelopActivityNotOpen = 200679,
    ErrorCode_ErrMotorDevelopTaskNotComplete = 200680,
    ErrorCode_ErrPhantomVicePolishNoAck = 200681,
    ErrorCode_ErrClientStorageSystemCount = 200682,
    ErrorCode_ErrClientStorageSystemDuplicate = 200683,
    ErrorCode_ErrClientStorageSystem = 200684,
    ErrorCode_ErrClientStorageStringLength = 200685,
    ErrorCode_ErrClientStorageType = 200686,
    ErrorCode_ErrClientStorageCapacity = 200687,
    ErrorCode_ErrMapDefault = 300000,
    ErrorCode_ErrMapMarkNumLimit = 300001,
    ErrorCode_ErrMapNoFogConfig = 300002,
    ErrorCode_ErrMapFogAlreadyUnlock = 300003,
    ErrorCode_ErrFormationEmpty = 300004,
    ErrorCode_ErrFormationUnknown = 300005,
    ErrorCode_ErrFormationDead = 300006,
    ErrorCode_ErrFormationRoleRepeat = 300007,
    ErrorCode_ErrFormationRoleNotActive = 300008,
    ErrorCode_ErrFormationRoleIndexOut = 300009,
    ErrorCode_ErrFormationRoleCountOut = 300010,
    ErrorCode_ErrFightFormationRoleNotExist = 300011,
    ErrorCode_ErrFightFormationRoleIdNotMatch = 300012,
    ErrorCode_ErrFightFormationRoleCountNotMatch = 300013,
    ErrorCode_ErrFightFormationRoleCareerNotMatch = 300014,
    ErrorCode_ErrFightFormationRoleElementNotMatch = 300015,
    ErrorCode_ErrFightFormationCannotTrial = 300016,
    ErrorCode_ErrFightFormationTrialRoleNotMatch = 300017,
    ErrorCode_ErrFormationOverSize = 300018,
    ErrorCode_ErrSwitchRoleIsDead = 300019,
    ErrorCode_ErrUpdateFormationCurRoleIsDead = 300020,
    ErrorCode_ErrUpdateFormationRoleIdsIsNull = 300021,
    ErrorCode_ErrFormationIdOutOfRange = 300022,
    ErrorCode_ErrCanNotCancelCurFormation = 300023,
    ErrorCode_ErrCurRoleNotInFormationRoleIds = 300024,
    ErrorCode_ErrUpateFormationNotInSingleWorld = 300025,
    ErrorCode_ErrSwitchRoleTypeSignleWorld = 300026,
    ErrorCode_ErrSwitchRoleTypeMultiWorld = 300027,
    ErrorCode_ErrSwitchRoleTypeFbInstance = 300028,
    ErrorCode_ErrSwitchRoleTypeUndefine = 300029,
    ErrorCode_ErrSingWorldCanNotUpdateFightRoles = 300030,
    ErrorCode_ErrUpdateFightRolesIsNull = 300031,
    ErrorCode_ErrUpdateFightRolesCurIdNotExist = 300032,
    ErrorCode_ErrInStroyCharacterCanNotSwitchRole = 300033,
    ErrorCode_ErrSwitchRoleNotInFightRoles = 300034,
    ErrorCode_ErrCanNotSwitchRepeat = 300035,
    ErrorCode_ErrSwitchRoleEntityIdNotExist = 300036,
    ErrorCode_ErrSwitchRoleEntityNotExist = 300037,
    ErrorCode_ErrSitchRoleEntityIsDead = 300038,
    ErrorCode_ErrorTeamOperaFail = 300039,
    ErrorCode_ErrorPlayerAlreadyHaveTeam = 300040,
    ErrorCode_ErrorTeamInviteContentInvalid = 300041,
    ErrorCode_ErrorPlayerInBanTime = 300042,
    ErrorCode_ErrorPlayerInInviteCd = 300043,
    ErrorCode_ErrorPlayerAlreadyInTeam = 300044,
    ErrorCode_ErrorKickOutPermissionNotEnough = 300045,
    ErrorCode_ErrorTeamIsFull = 300046,
    ErrorCode_ErrorTeamServiceNotReady = 300047,
    ErrorCode_ErrorTeamPlayerJoinRepeat = 300048,
    ErrorCode_ErrorPlayerNotInTeam = 300049,
    ErrorCode_ErrorInvitePlayerNotExist = 300050,
    ErrorCode_ErrorKickPlayerNotInTeam = 300051,
    ErrorCode_ErrorDismissPermissionNotEnough = 300052,
    ErrorCode_ErrorTeamRoleIdNotActive = 300053,
    ErrorCode_ErrorTeamRoleIdRepeat = 300054,
    ErrorCode_ErrorJoinOtherWorldOtherNotExist = 300055,
    ErrorCode_ErrorJoinOtherWorldOtherNotInScene = 300056,
    ErrorCode_ErrorJoinOtherWorldSceneNotExist = 300057,
    ErrorCode_ErrorTeamNotExist = 300058,
    ErrorCode_ErrRewardCfgNotFound = 300059,
    ErrorCode_ErrTeleportIdNotExist = 300060,
    ErrorCode_ErrTeleportIdNotActivate = 300061,
    ErrorCode_ErrTeleportCreatureIdNotExist = 300062,
    ErrorCode_ErrTeleportIdAlreadyActivate = 300063,
    ErrorCode_ErrTeleportGmGetPlayerFailed = 300064,
    ErrorCode_ErrTeleportGmGetCreatureGenCfgFailed = 300065,
    ErrorCode_ErrTgmNotExitst = 300066,
    ErrorCode_ErrTgmNotPlayer = 300067,
    ErrorCode_ErrTgmNotGenCfg = 300068,
    ErrorCode_ErrTgmInsId = 300069,
    ErrorCode_ErrTeleportEntityNotExist = 300070,
    ErrorCode_ErrTeleportComponentNotExist = 300071,
    ErrorCode_ErrTeleportComponentNotMatch = 300072,
    ErrorCode_ErrAreaEnterRepeated = 300073,
    ErrorCode_ErrAreaIdNotExist = 300074,
    ErrorCode_ErrAreaIdNoNeedRecord = 300075,
    ErrorCode_ErrPlayerIsNotDead = 300076,
    ErrorCode_ErrPlayerCanNotRevive = 300077,
    ErrorCode_ErrPlayerReviveCountReachMax = 300078,
    ErrorCode_ErrPlayerReviveDelayNotReach = 300079,
    ErrorCode_ErrAutoReviveNotRequest = 300080,
    ErrorCode_ErrReviveRegionExisted = 300081,
    ErrorCode_ErrReviveRegionNotExisted = 300082,
    ErrorCode_ErrReviveRegionConfigNotExist = 300083,
    ErrorCode_ErrCanNotUseItemRevive = 300084,
    ErrorCode_ErrIsMatching = 300085,
    ErrorCode_ErrNotInMatcing = 300086,
    ErrorCode_ErrMatchPoolNotExist = 300087,
    ErrorCode_ErrNotFindMatchResult = 300088,
    ErrorCode_ErrConfirmResultRepeat = 300089,
    ErrorCode_ErrAlreadyHaveFbTeam = 300090,
    ErrorCode_ErrFbTeamNotExist = 300091,
    ErrorCode_ErrPlayerNotInFbTeam = 300092,
    ErrorCode_ErrHostCanNotReady = 300093,
    ErrorCode_ErrChangeReadyRepeat = 300094,
    ErrorCode_ErrFbTeamHaveSameRole = 300095,
    ErrorCode_ErrReadyStateCanNotChangeRole = 300096,
    ErrorCode_ErrChangeSameRole = 300097,
    ErrorCode_ErrNotHaveKickPermission = 300098,
    ErrorCode_ErrBeKickNotInFbTeam = 300099,
    ErrorCode_ErrNotHaveFightPermission = 300100,
    ErrorCode_ErrFbTeamNotAllReady = 300101,
    ErrorCode_ErrFbInstIdNotExist = 300102,
    ErrorCode_ErrFbMatchRoleNotMatch = 300103,
    ErrorCode_ErrSingleInstCanNotMatch = 300104,
    ErrorCode_ErrWaitOtherEnterSceneForbidMatch = 300105,
    ErrorCode_ErrIsEnteringOtherSceneForbidMatch = 300106,
    ErrorCode_InstPlayBtObjNotFound = 300107,
    ErrorCode_InstPlayNotSuccess = 300108,
    ErrorCode_InstPlayAlreadyGetReward = 300109,
    ErrorCode_InstPlayExchangeRewardFail = 300110,
    ErrorCode_InstPlaySetterRepeat = 300111,
    ErrorCode_InstEntranceNotUnlock = 300112,
    ErrorCode_InstEntranceNotOpen = 300113,
    ErrorCode_EnterInstLevelNotEnough = 300114,
    ErrorCode_EnterInstWorldLevelNotEnough = 300115,
    ErrorCode_EnterInstQuestNotEnough = 300116,
    ErrorCode_ErrForbidEnterInstInMatch = 300117,
    ErrorCode_ErrForbidEnterInstInEnteringOtherWorld = 300118,
    ErrorCode_ErrForbidEnterInstInWaitingOtherEnterWorld = 300119,
    ErrorCode_ErrEnterInstTypeNotMatch = 300120,
    ErrorCode_ErrNotHaveGetRewardCount = 300121,
    ErrorCode_ErrInMatching = 300122,
    ErrorCode_ErrNotInMatching = 300123,
    ErrorCode_ErrNotFindValidMatchServer = 300124,
    ErrorCode_ErrNotFindMatchServerPrx = 300125,
    ErrorCode_ErrNotHaveMatchTeamInfo = 300126,
    ErrorCode_ErrAlreadyConfirmMatchResult = 300127,
    ErrorCode_ErrMatchTeamNotInReadyState = 300128,
    ErrorCode_ErrMatchRoleNotActive = 300129,
    ErrorCode_ErrMatchReadyRepeat = 300130,
    ErrorCode_ErrMatchPlayerNotReady = 300131,
    ErrorCode_ErrMatchNotHostCanNotKick = 300132,
    ErrorCode_ErrMatchNotHostCanNotSetMatching = 300133,
    ErrorCode_ErrSetMatchFlagRepeat = 300134,
    ErrorCode_ErrPlayerNotInMatchTeam = 300135,
    ErrorCode_ErrGetMatchPoolFail = 300136,
    ErrorCode_ErrPlayerInMatchPool = 300137,
    ErrorCode_ErrPlayerNotInMatchPool = 300138,
    ErrorCode_ErrPlayerInMatchTeamCanNotCancel = 300139,
    ErrorCode_ErrPlayerIsConfirmResult = 300140,
    ErrorCode_ErrNotFindMatchTeam = 300141,
    ErrorCode_ErrPlayerIsReadyCanNotChangeRole = 300142,
    ErrorCode_ErrNotHostCanNotSetMultRoles = 300143,
    ErrorCode_ErrCanNotSetRepeatRole = 300144,
    ErrorCode_ErrPlayerNotReadyCanNotCancel = 300145,
    ErrorCode_ErrRoleRepeatCanNotReady = 300146,
    ErrorCode_ErrBeKickNotInMatchTeam = 300147,
    ErrorCode_ErrNotHostCanNotKick = 300148,
    ErrorCode_ErrNotHostCanNotSetTeamState = 300149,
    ErrorCode_ErrTeamMatchingCanNotStartInst = 300150,
    ErrorCode_ErrMatchTeamHavePlayerNotReady = 300151,
    ErrorCode_ErrNotHostCanNotEnterInst = 300152,
    ErrorCode_ErrMatchTeamIsNotEnterInstState = 300153,
    ErrorCode_ErrMatchInstIdNotExist = 300154,
    ErrorCode_ErrSingleInstanceCanNotMatch = 300155,
    ErrorCode_ErrOnlineStateCanNotMatch = 300156,
    ErrorCode_ErrTeamHaveSameRoleCanNotBegin = 300157,
    ErrorCode_ErrNotJoinChatChannel = 300158,
    ErrorCode_ErrChatChannelNotFound = 300159,
    ErrorCode_ErrChatChannelTypeNotMatch = 300160,
    ErrorCode_ErrChatContentTooLong = 300161,
    ErrorCode_ErrFightRoleIsAllDied = 300162,
    ErrorCode_ErrLoadingSceneIdNotMatch = 300163,
    ErrorCode_ErrLoadingPlayerNotInScene = 300164,
    ErrorCode_ErrPlayerIsSceneLoadingCanNotBeKick = 300165,
    ErrorCode_ErrTeamPlayerIsSceneLoadingCanNotDissolve = 300166,
    ErrorCode_ErrIsSceneLoadingCanNotDissolve = 300167,
    ErrorCode_ErrSceneLoadingCanNotEnterInst = 300168,
    ErrorCode_ErrActivateResetPointNotEntity = 300169,
    ErrorCode_ErrHostIsLoadingScene = 300170,
    ErrorCode_ErrHostIsLoadingSceneCanNotApply = 300171,
    ErrorCode_ErrIsLoadingSceneCanNotAcceptApply = 300172,
    ErrorCode_ErrNotFindHostWorldScene = 300173,
    ErrorCode_ErrCanNotRepeatCreateNeedSaveScene = 300174,
    ErrorCode_DeadStateCanNotAgreeOherEnter = 300175,
    ErrorCode_HostIsDeadStateCanNotEnter = 300176,
    ErrorCode_ErrSceneIsLoadingCanNotLeave = 300177,
    ErrorCode_ErrInstCanNotReChallenge = 300178,
    ErrorCode_ErrInstMemberNotEnoughCanNotReChallenge = 300179,
    ErrorCode_ErrInstHavePlayerLeaveCanNotReChallenge = 300180,
    ErrorCode_ErrInstHavePlayerNotDeadCanNotReChallenge = 300181,
    ErrorCode_ErrInstNotSettleCanNotReChallenge = 300182,
    ErrorCode_ErrInstCanNotRepetApplyRechallenge = 300183,
    ErrorCode_ErrInstCanNotRepetReceiveRechallenge = 300184,
    ErrorCode_ErrInstOwnerCanIniviteRechallenge = 300185,
    ErrorCode_ErrInstOwnerCanNotReceiveRechallenge = 300186,
    ErrorCode_ErrPlayerIsLogoutCanNotCreateScene = 300187,
    ErrorCode_ErrPlayerIsCreatingScene = 300188,
    ErrorCode_ErrPlayerCreateSceneFail = 300189,
    ErrorCode_ErrBigWorldCanNotReset = 300190,
    ErrorCode_ErrMultiGameModeCanNotReset = 300191,
    ErrorCode_ErrIsEnterSceneApplyingCanNotDoRepeate = 300192,
    ErrorCode_ErrIsQueryLobbyFriendDetailCanNotDoRepeate = 300193,
    ErrorCode_ErrIsQueryLobbyPlayerDetailCanNotDoRepeate = 300194,
    ErrorCode_ErrPlayerIsLoadingCanNotDoTeleport = 300195,
    ErrorCode_ErrPlayerIsTeleportCanNotDoTeleport = 300196,
    ErrorCode_ErrTeleportPositionIllegal = 300197,
    ErrorCode_ErrPlayerIsLoadingCanNotRevive = 300198,
    ErrorCode_ErrPlayerIsTeleportCanNotRevive = 300199,
    ErrorCode_ErrPlayerIsInTeleportCanNotBeKick = 300200,
    ErrorCode_ErrTeamPlayerIsInTeleportCanNotDissolve = 300201,
    ErrorCode_ErrHostIsInTeleportCanNotApply = 300202,
    ErrorCode_ErrIsInTeleportCanNotAcceptApply = 300203,
    ErrorCode_ErrStrNotIllegal = 400000,
    ErrorCode_ErrBasicInfoPhotoUnlocked = 400001,
    ErrorCode_ErrBasicInfoFrameUnlocked = 400002,
    ErrorCode_ErrCanNotGetSelfBasicInfo = 400003,
    ErrorCode_ErrMailNotExist = 400004,
    ErrorCode_ErrMailAlreadyRead = 400005,
    ErrorCode_ErrNoMailCanGet = 400006,
    ErrorCode_ErrMailNoAttachment = 400007,
    ErrorCode_ErrMailAttachmentIsGet = 400008,
    ErrorCode_ErrMailAttachmentNotGet = 400009,
    ErrorCode_ErrMailNotRead = 400010,
    ErrorCode_ErrNoMailCanDelete = 400011,
    ErrorCode_ErrMailItemBagFull = 400012,
    ErrorCode_ErrMailFuncNotOpen = 400013,
    ErrorCode_ErrMailOverSize = 400014,
    ErrorCode_ErrMailTakeLimit = 400015,
    ErrorCode_ErrMailAttachmentItemInvalidCount = 400016,
    ErrorCode_ErrMailAttachmentItemNoConf = 400017,
    ErrorCode_ErrMailNoConf = 400018,
    ErrorCode_ErrShopIdNotExit = 400019,
    ErrorCode_ErrShopInfoExist = 400020,
    ErrorCode_ErrShopTimeLimit = 400021,
    ErrorCode_ErrShopMoneyId = 400022,
    ErrorCode_ErrShopNumLimit = 400023,
    ErrorCode_ErrShopCondLimit = 400024,
    ErrorCode_ErrShopBankNoExit = 400025,
    ErrorCode_ErrShopNoShow = 400026,
    ErrorCode_ErrShopVersion = 400027,
    ErrorCode_ErrShopIlligalParam = 400028,
    ErrorCode_ErrDragonPoolConf = 400029,
    ErrorCode_ErrFullLevel = 400030,
    ErrorCode_ErrItemConf = 400031,
    ErrorCode_ErrNotEnoughItem = 400032,
    ErrorCode_NotMingSuTi = 400033,
    ErrorCode_HadFinishMingSuTi = 400034,
    ErrorCode_MingSuCallEntityFail = 400035,
    ErrorCode_ErrDragonPoolFuncNotOpen = 400036,
    ErrorCode_ErrWorldLevelHadDown = 400037,
    ErrorCode_ErrWorldLevelNotDown = 400038,
    ErrorCode_ErrWorldLevelMin = 400039,
    ErrorCode_ErrWorldLevelCd = 400040,
    ErrorCode_ErrIsBlockedPlayer = 400041,
    ErrorCode_ErrIsNotBlockedPlayer = 400042,
    ErrorCode_ErrBlockListCountMax = 400043,
    ErrorCode_ErrYouAreBlocked = 400044,
    ErrorCode_ErrAlreadyOnFriendList = 400045,
    ErrorCode_ErrNotOnFriendList = 400046,
    ErrorCode_ErrAlreadyOnFriendApplyList = 400047,
    ErrorCode_ErrFriendApplyNotExists = 400048,
    ErrorCode_ErrFriendListCountMax = 400049,
    ErrorCode_ErrInitiatorFriendListCountMax = 400050,
    ErrorCode_ErrReceiverApplyListCountMax = 400051,
    ErrorCode_ErrCanNotFriendApplySendToSelf = 400052,
    ErrorCode_ErrFriendApplySended = 400053,
    ErrorCode_ErrFriendRemarkLengthLimit = 400054,
    ErrorCode_ErrFriendApplyRequestLimit = 400055,
    ErrorCode_ErrFriendRequestEmpty = 400056,
    ErrorCode_ErrFriendRequestOverSize = 400057,
    ErrorCode_ErrPayShopNotExists = 400058,
    ErrorCode_ErrPayShopDisabled = 400059,
    ErrorCode_ErrPayShopGoodsNotExists = 400060,
    ErrorCode_ErrPayShopGoodsDisabled = 400061,
    ErrorCode_ErrPayShopGoodsLocked = 400062,
    ErrorCode_ErrPayShopGoodsOutSellTime = 400063,
    ErrorCode_ErrPayShopGoodsBuyLimit = 400064,
    ErrorCode_ErrPayShopDataChanged = 400065,
    ErrorCode_ErrPayShopIllegalBuyCount = 400066,
    ErrorCode_ErrPayShopIsDirect = 400067,
    ErrorCode_ErrPayShopIsNotDirect = 400068,
    ErrorCode_ErrPayShopTabDisabled = 400069,
    ErrorCode_ErrMonthCardWithoutValidity = 400070,
    ErrorCode_ErrMonthCardUpdateConfNotExist = 400071,
    ErrorCode_ErrMonthCardDaysMax = 400072,
    ErrorCode_ErrMonthCardRewardGot = 400073,
    ErrorCode_ErrMonthCardConfNotExist = 400074,
    ErrorCode_ErrIsNotSpecialItem = 400075,
    ErrorCode_ErrNoEquipSpecialItem = 400076,
    ErrorCode_ErrNoValidBattlePass = 400077,
    ErrorCode_ErrBattlePassRewardNotFound = 400078,
    ErrorCode_ErrBattlePassNotPaid = 400079,
    ErrorCode_ErrBattlePassIsPaid = 400080,
    ErrorCode_ErrBattlePassRewardLocked = 400081,
    ErrorCode_ErrBattlePassRewardTaken = 400082,
    ErrorCode_ErrBattlePassCanNotRepeatActive = 400083,
    ErrorCode_BattlePassNoRecurringReward = 400084,
    ErrorCode_ErrBattlePassIsAdvanced = 400085,
    ErrorCode_ErrBattlePassTaskNotFound = 400086,
    ErrorCode_ErrBattlePassTaskNotFinished = 400087,
    ErrorCode_ErrBattlePassTaskTaken = 400088,
    ErrorCode_ErrBattlePassExpIsFull = 400089,
    ErrorCode_ErrAdviceNotFound = 400090,
    ErrorCode_ErrConjunctionCanNotWord = 400091,
    ErrorCode_ErrAdviceTextNotExists = 400092,
    ErrorCode_ErrAdviceWordNotExists = 400093,
    ErrorCode_ErrAdviceTemplateNotExists = 400094,
    ErrorCode_ErrAdviceCellCalcException = 400095,
    ErrorCode_ErrIsNotAdviceEntity = 400096,
    ErrorCode_ErrAdviceCreateLimit = 400097,
    ErrorCode_ErrAdviceContentCanNotEmpty = 400098,
    ErrorCode_ErrAdviceEntityNotFount = 400099,
    ErrorCode_ErrAdviceVoteLimit = 400100,
    ErrorCode_ErrAdviceIsVoteUp = 400101,
    ErrorCode_ErrAdviceIsVoteDown = 400102,
    ErrorCode_ErrNoAdviceItem = 400103,
    ErrorCode_ErrAdviceCreateNotOpen = 400104,
    ErrorCode_ErrAdviceCanNotCreateByVisitor = 400105,
    ErrorCode_ErrAdviceSetingIsShow = 400106,
    ErrorCode_ErrAdviceSetingIsNoShow = 400107,
    ErrorCode_ErrAdviceUpMaxValue = 400108,
    ErrorCode_ErrAdviceDownMaxValue = 400109,
    ErrorCode_ProtoVersionCheckFail = 400110,
    ErrorCode_ProtoMd5CheckFail = 400111,
    ErrorCode_ConfigVersionCheckFail = 400112,
    ErrorCode_ConfigMd5CheckFail = 400113,
    ErrorCode_ErrInvalidMonthCardDays = 400114,
    ErrorCode_ErrMonthCardExtendedDaysMax = 400115,
    ErrorCode_ErrMobileButtonNoCfg = 400116,
    ErrorCode_ErrMoneyWrongPayCount = 400117,
    ErrorCode_ErrMailTextSenderNotFound = 400118,
    ErrorCode_ErrMailTextTitleNotFound = 400119,
    ErrorCode_ErrMailTextContentNotFound = 400120,
    ErrorCode_ErrAdviceIsNotVoteUp = 400121,
    ErrorCode_ErrParkourChallengeNoConf = 400122,
    ErrorCode_ErrParkourLocationNoConf = 400123,
    ErrorCode_ErrParkourChallengeNotOpen = 400124,
    ErrorCode_ErrParkourChallengeNoData = 400125,
    ErrorCode_ErrParkourChallengeTaken = 400126,
    ErrorCode_ErrParkourChallengeUnderscore = 400127,
    ErrorCode_ErrParkourChallengeScoreNoConf = 400128,
    ErrorCode_ErrParkourTakeFail = 400129,
    ErrorCode_ErrShopIllegalBuyCount = 400130,
    ErrorCode_ErrQuestErrTaskId = 500000,
    ErrorCode_ErrQuestErrStepId = 500001,
    ErrorCode_ErrQuestErrTaskBag = 500002,
    ErrorCode_ErrQuestStepStatusNotCanAccept = 500003,
    ErrorCode_ErrQuestStepStatusNotCanCommit = 500004,
    ErrorCode_ErrQuestStepConf = 500005,
    ErrorCode_ErrQuestStepData = 500006,
    ErrorCode_ErrQuestCanNotAccept = 500007,
    ErrorCode_ErrAreaQuestDelegationBoardRequest = 500008,
    ErrorCode_ErrAreaQuestAreaIdErr = 500009,
    ErrorCode_ErrAreaQuestExpired = 500010,
    ErrorCode_ErrDevoteLevel = 500011,
    ErrorCode_ErrDevoteRewardReceived = 500012,
    ErrorCode_ErrQuestNotFinish = 500013,
    ErrorCode_ErrDevoteId = 500014,
    ErrorCode_ErrAreaQuestLimit = 500015,
    ErrorCode_ErrQuestNodeNotActive = 500016,
    ErrorCode_ErrQuestNotActiveId = 500017,
    ErrorCode_ErrQuestNodeNotFound = 500018,
    ErrorCode_ErrQuestComNotFound = 500019,
    ErrorCode_ErrQuestTraceType = 500020,
    ErrorCode_ErrQuestNotProgress = 500021,
    ErrorCode_ErrQuestNoCombatState = 500022,
    ErrorCode_ErrQuestNodeData = 500023,
    ErrorCode_ErrQuestNotChildQuestNode = 500024,
    ErrorCode_ErrQuestNotClientSubmit = 500025,
    ErrorCode_ErrQuestAccepted = 500026,
    ErrorCode_ErrResourceOccupation = 500027,
    ErrorCode_ErrRequestOccupationType = 500028,
    ErrorCode_ErrNotFoundOccupation = 500029,
    ErrorCode_ErrNotOnlineQuestAccept = 500030,
    ErrorCode_ErrQuestDestroy = 500031,
    ErrorCode_ErrTreeNodeNotFind = 500032,
    ErrorCode_ErrTreeNodeNotActive = 500033,
    ErrorCode_ErrIsNotChildQuestNode = 500034,
    ErrorCode_ErrChildQuestConditionCanNotSubmit = 500035,
    ErrorCode_ErrNodeNotFindAction = 500036,
    ErrorCode_ErrNodeActionIsFinish = 500037,
    ErrorCode_ErrNodeActionGetItemIsNotQuestItem = 500038,
    ErrorCode_ErrNodeActionGetItemHasNotFreeSize = 500039,
    ErrorCode_ErrInvalidBtType = 500040,
    ErrorCode_ErrTimerNotFind = 500041,
    ErrorCode_ErrPreCondition = 500042,
    ErrorCode_ErrHandIdItemData = 500043,
    ErrorCode_ErrTreeNotFailedNode = 500044,
    ErrorCode_ErrTreeNotFailConf = 500045,
    ErrorCode_ErrTreeNotGiveUpConf = 500046,
    ErrorCode_ErrTreeNotRollback = 500047,
    ErrorCode_ErrNodeNotFindNpcId = 500048,
    ErrorCode_ErrNotRollbackPermission = 500049,
    ErrorCode_ErrNotRollbackRepeat = 500050,
    ErrorCode_ErrTreeSuspend = 500051,
    ErrorCode_ErrPlayerNotInQuestMap = 500052,
    ErrorCode_ErrSaveNewNotRollback = 500053,
    ErrorCode_ErrUiPlayType = 500054,
    ErrorCode_ErrOccupationTime = 500055,
    ErrorCode_ErrReleaseTime = 500056,
    ErrorCode_ErrActionSetTime = 500057,
    ErrorCode_ErrForcedOccupationResource = 500058,
    ErrorCode_ErrAddPlayBubble = 500059,
    ErrorCode_ErrDisableSwitchOccupation = 500060,
    ErrorCode_ErrOpenSystemBoardResultFail = 500061,
    ErrorCode_ErrEntityNoInhaledComponent = 500062,
    ErrorCode_ErrEntityInhaledStrength = 500063,
    ErrorCode_ErrDisableSwitchGender = 500064,
    ErrorCode_ErrTapeDefault = 600000,
    ErrorCode_ErrTapeInvalidPos = 600001,
    ErrorCode_ErrTapeIsNotActiveRole = 600002,
    ErrorCode_ErrTapeItemTypeFail = 600003,
    ErrorCode_ErrTapeNotExistTapeItem = 600004,
    ErrorCode_ErrTapeNotExistTapeConfig = 600005,
    ErrorCode_ErrTapeNotExistTapeProps = 600006,
    ErrorCode_ErrTapeHasTakeOnTape = 600007,
    ErrorCode_ErrTapeHasNotTakeOnTape = 600008,
    ErrorCode_ErrTapeNotExistTapeQualityConfig = 600009,
    ErrorCode_ErrTapeNotExistLevelUpExpConfig = 600010,
    ErrorCode_ErrTapeInvalidLevelUpExpValue = 600011,
    ErrorCode_ErrTapeNotExistExpDecayRatioConfig = 600012,
    ErrorCode_ErrTapeLevelUpEqualItem = 600013,
    ErrorCode_ErrTapeLevelUpRepeatItem = 600014,
    ErrorCode_ErrTapeLevelUpInvalidExpItemNum = 600015,
    ErrorCode_ErrTapeLevelUpInvalidExpRate = 600016,
    ErrorCode_ErrTapeLevelUpInvalidAddExp = 600017,
    ErrorCode_ErrTapeLevelUpMaxLevel = 600018,
    ErrorCode_ErrTapeLevelUpConsumeItemNotEnough = 600019,
    ErrorCode_ErrTapeLevelUpMaterialLock = 600020,
    ErrorCode_ErrTapeTransferEqualItem = 600021,
    ErrorCode_ErrTapeTransferQualityNotEqual = 600022,
    ErrorCode_ErrTapeTransferSuitNotEqual = 600023,
    ErrorCode_ErrTapeTransferMaterialLock = 600024,
    ErrorCode_ErrTapeTransferMaterialEquipped = 600025,
    ErrorCode_ErrTapeNotExistTransferPropNumConfig = 600026,
    ErrorCode_ErrTapeTransferPropNumIsMax = 600027,
    ErrorCode_ErrTapeTransferRandomSubPropFail = 600028,
    ErrorCode_ErrTapeResetTransferHasNotProp = 600029,
    ErrorCode_ErrTapeResetTransferMaterialNotEnough = 600030,
    ErrorCode_ErrTapeNotExistTapeExpItem = 600031,
    ErrorCode_ErrTapeNotExistTapeExpItemConfig = 600032,
    ErrorCode_ErrCollectEntityNotExist = 600033,
    ErrorCode_ErrCollectInvalidEntityMainType = 600034,
    ErrorCode_ErrRunningLevelPlayNotFind = 600035,
    ErrorCode_ErrLevelPlayInteractionEntity = 600036,
    ErrorCode_ErrLevelPlayNotExistByConfId = 600037,
    ErrorCode_ErrLevelPlayNotCreate = 600038,
    ErrorCode_ErrLevelPlayRewarded = 600039,
    ErrorCode_ErrLevelPlayInteractionType = 600040,
    ErrorCode_ErrLevelPlayNotPlayer = 600041,
    ErrorCode_ErrLevelPlayNotComplete = 600042,
    ErrorCode_ErrLevelPlayRewardFail = 600043,
    ErrorCode_ErrLevelPlayNotWaitState = 600044,
    ErrorCode_ErrLevelPlayAction = 600045,
    ErrorCode_ErrLevelPlayGetRewardLimit = 600046,
    ErrorCode_ErrFlowNotExist = 600047,
    ErrorCode_ErrFlowHaveNotActionWait = 600048,
    ErrorCode_ErrFlowHaveNotTalkWait = 600049,
    ErrorCode_ErrFlowHaveNotOptionWait = 600050,
    ErrorCode_ErrFlowInvalidOptionId = 600051,
    ErrorCode_ErrInteractFlowCanNotPlay = 600052,
    ErrorCode_ErrInteractInvalidFlowState = 600053,
    ErrorCode_ErrInteractOptionOwnerIsNotFlowOwner = 600054,
    ErrorCode_ErrInteractOptionOwnerIsNotActionOwner = 600055,
    ErrorCode_ErrActionOwnerIsNotEntity = 600056,
    ErrorCode_ErrActionOwnerNotFound = 600057,
    ErrorCode_ErrActionSceneNotFound = 600058,
    ErrorCode_ErrActionGroupNotFound = 600059,
    ErrorCode_ErrFinishClientActionFail = 600060,
    ErrorCode_ErrActionHostPlayerNotFound = 600061,
    ErrorCode_ErrActionFail = 600062,
    ErrorCode_ErrActionPlayerNotFound = 600063,
    ErrorCode_ErrInteractMultiGameMode = 600064,
    ErrorCode_ErrInteractAddFlowFail = 600065,
    ErrorCode_ErrBehaviorTreeOwnerNotFound = 600066,
    ErrorCode_ErrBehaviorTreeNotFound = 600067,
    ErrorCode_ErrBehaviorTreePending = 600068,
    ErrorCode_ErrBehaviorTreeTimerTypeNotFound = 600069,
    ErrorCode_ErrBehaviorTreeStopTimerFail = 600070,
    ErrorCode_ErrBehaviorTreeTimerCompNotFound = 600071,
    ErrorCode_ErrInteractCd = 600072,
    ErrorCode_ErrInteractRange = 600073,
    ErrorCode_ErrDropPickRange = 600074,
    ErrorCode_ErrBtTmpItemContextNotExist = 600075,
    ErrorCode_ErrBtTmpItemBtObjNotExist = 600076,
    ErrorCode_ErrPlayerBigWorldNotExist = 600077,
    ErrorCode_ErrRoleEntityNotExist = 600078,
    ErrorCode_ErrAddFlowFail = 600079,
    ErrorCode_ErrInteracting = 600080,
    ErrorCode_ErrInteractCollectBagFull = 600081,
    ErrorCode_ErrBtObjIsNotInstPlay = 600082,
    ErrorCode_ErrReviveConfigNotExist = 600083,
    ErrorCode_ErrFinishFlowFail = 600084,
    ErrorCode_ErrFlowActionFail = 600085,
    ErrorCode_ErrGmSubmitChildQuestNodeMaxDepth = 600086,
    ErrorCode_ErrGmSubmitChildQuestNodeIsNotProgress = 600087,
    ErrorCode_ErrEntityPatrolComponentNotExist = 600088,
    ErrorCode_ErrInteractIsNotParticipant = 600089,
    ErrorCode_ErrVisionEntityInteractFail = 600090,
    ErrorCode_ErrMaxDropTimes = 600091,
    ErrorCode_ErrStateEntityMultiHang = 600092,
    ErrorCode_ErrPlayerLoading = 600093,
    ErrorCode_ErrPlayerTeleporting = 600094,
    ErrorCode_ErrInteractBtPending = 600095,
    ErrorCode_ErrInteractDead = 600096,
    ErrorCode_ErrMultiHangEntity = 600097,
    ErrorCode_ErrRenjuCanNotResetWhenComplete = 600098,
    ErrorCode_ErrRenjuCanNotMove = 600099,
    ErrorCode_ErrEntityNotFound = 600100,
    ErrorCode_ErrSceneHostPlayerNotMatch = 600101,
    ErrorCode_ErrVehicleComponentNotFound = 600102,
    ErrorCode_ErrVehicleSeatNotFound = 600103,
    ErrorCode_ErrVehicleGettingOn = 600104,
    ErrorCode_ErrPortalEntityNotFound = 600105,
    ErrorCode_ErrPortalCompNotFound = 600106,
    ErrorCode_ErrPortalTeleportPosNotEqual = 600107,
    ErrorCode_ErrPlayerNotInVehicle = 600108,
    ErrorCode_ErrVehiclePassengerRoleExist = 600109,
    ErrorCode_ErrCreateVehiclePassengerEntityFail = 600110,
    ErrorCode_ErrVehiclePassengerNotFound = 600111,
    ErrorCode_ErrCanNotMovePlacement = 600112,
    ErrorCode_ErrGmSetLimitTeleportDungeon = 600113,
    ErrorCode_ErrMaxSetTagIdDepth = 600114,
    ErrorCode_ErrBeforeSetStateTagId = 600115,
    ErrorCode_ErrSetStateTagIdLock = 600116,
    ErrorCode_ErrDangoMonopolyActivityDataNotFound = 600117,
    ErrorCode_ErrDangoMonopolyReqTaskRewardMax = 600118,
    ErrorCode_ErrDangoMonopolyTaskConfigNotFound = 600119,
    ErrorCode_ErrDangoMonopolyTaskNotCompleted = 600120,
    ErrorCode_ErrDangoMonopolyTaskRewardHasGet = 600121,
    ErrorCode_ErrDangoMonopolyBoardConfigNotFound = 600122,
    ErrorCode_ErrDangoMonopolyGridRewardNotGet = 600123,
    ErrorCode_ErrDangoMonopolyHasNotDiceItem = 600124,
    ErrorCode_ErrDangoMonopolyHasNotGridReward = 600125,
    ErrorCode_ErrDangoMonopolyGridConfigNotFound = 600126,
    ErrorCode_ErrDangoMonopolyReqBoardRewardMax = 600127,
    ErrorCode_ErrDangoMonopolyBoardNotCompleted = 600128,
    ErrorCode_ErrDangoMonopolyBoardRewardHasGet = 600129,
    ErrorCode_ErrDangoMonopolyActivityConfigNotFound = 600130,
    ErrorCode_ErrDangoMonopolyBoardLock = 600131,
    ErrorCode_ErrChangeEntityStateActionEntityNotFound = 600132,
    ErrorCode_ErrDangoMonopolyDiceNumInvalid = 600133,
    ErrorCode_ErrDangoMonopolyBoardCompleted = 600134,
    ErrorCode_ErrLevelSequenceFrameEventCompNotFound = 600135,
    ErrorCode_ErrLevelSequenceFrameEventDataNotFound = 600136,
    ErrorCode_ErrLevelSequenceFrameEventSectionsNotFound = 600137,
    ErrorCode_ErrActionCtxInvalid = 600138,
    ErrorCode_ErrActionOwnerInvalid = 600139,
    ErrorCode_ErrGlobalFixCfgNotFound = 600140,
    ErrorCode_ErrActionGetItemIsNotQuestItem = 600141,
    ErrorCode_ErrGlobalFixExecuteCountMax = 600142,
    ErrorCode_ErrActionGroupCreateTooFrequently = 600143,
    ErrorCode_ErrActionGroupParallelTooMuch = 600144,
    ErrorCode_ErrCanNotRemoveLastTrialRole = 600145,
    ErrorCode_ErrEntityIsNotActivateState = 600146,
    ErrorCode_ErrRestoreTrialRoleNotInRegion = 600147,
    ErrorCode_ErrRemoveTrialRoleNotExist = 600148,
    ErrorCode_ErrRemoveLastTrialRole = 600149,
    ErrorCode_ErrSceneWorldNotExist = 700000,
    ErrorCode_ErrPlayerNotInScene = 700001,
    ErrorCode_ErrDropEntityNotExist = 700002,
    ErrorCode_ErrDropComponentNotExist = 700003,
    ErrorCode_ErrDropOwnerError = 700004,
    ErrorCode_ErrPlayerAlreadyInScene = 700005,
    ErrorCode_ErrSceneIdParseError = 700006,
    ErrorCode_ErrJoinSceneIdNotExist = 700007,
    ErrorCode_ErrSceneInviteFail = 700008,
    ErrorCode_ErrSceneInvitePlayerNotExist = 700009,
    ErrorCode_ErrSceneInviteTokenInvalid = 700010,
    ErrorCode_ErrSceneInviterNotExist = 700011,
    ErrorCode_ErrSceneInviteeIdNotMatch = 700012,
    ErrorCode_ErrSceneTeamIsFull = 700013,
    ErrorCode_ErrScenePlayerIsInTeam = 700014,
    ErrorCode_ErrSceneInviteerIsInPlayeInst = 700015,
    ErrorCode_ErrBeKickerNotInScene = 700016,
    ErrorCode_ErrorCanNotSceneKickSelf = 700017,
    ErrorCode_ErrCanNotKickOtherInPlayInst = 700018,
    ErrorCode_ErrCanNotKickOtherWhoIsInPlayInst = 700019,
    ErrorCode_ErrNoSceneKickPermission = 700020,
    ErrorCode_ErrInviterIsInOtherScene = 700021,
    ErrorCode_ErrInOtherSceneCanNotInvite = 700022,
    ErrorCode_ErrSceneBackSceneFlagError = 700023,
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
    ErrorCode_ErrMultiChangeRoleIndexInvalid = 700043,
    ErrorCode_ErrMultiCanNotChangeOtherRole = 700044,
    ErrorCode_ErrMultiChangeRoleEntityNorExist = 700045,
    ErrorCode_ErrSceneCanNotUseThisFunc = 700046,
    ErrorCode_ErrSceneCanNotUseThisItem = 700047,
    ErrorCode_ErrSceneFightRoleIdRepeat = 700048,
    ErrorCode_ErrShieldAddEntityNotExist = 700049,
    ErrorCode_ErrShieldAddShieldIdExisted = 700050,
    ErrorCode_ErrShieldChangeEntityNotExist = 700051,
    ErrorCode_ErrShieldChangeShieldIdNotExist = 700052,
    ErrorCode_ErrShieldRemoveEntityNotExist = 700053,
    ErrorCode_ErrShieldRemoveShieldIdNotExist = 700054,
    ErrorCode_ErrHardnessModeChangedEntityNotExist = 700055,
    ErrorCode_ErrSceneEntityNotExist = 700056,
    ErrorCode_ErrSceneEntityNotHavePartData = 700057,
    ErrorCode_ErrsceneEntityNotHavePartId = 700058,
    ErrorCode_ErrChangeControlRoleRepeat = 700059,
    ErrorCode_ErrVisionSkillCallEntityFail = 700060,
    ErrorCode_ErrSceneDataLoadError = 700061,
    ErrorCode_ErrCreatureDataError = 700062,
    ErrorCode_ErrCreatureGenIsExist = 700063,
    ErrorCode_ErrCreatureGenIsNotExist = 700064,
    ErrorCode_ErrCreatureGenIsControlByOther = 700065,
    ErrorCode_ErrCreatureGenNotHaveControlPerm = 700066,
    ErrorCode_ErrCreatureReachMaxCount = 700067,
    ErrorCode_ErrCreatureConditionNotMatch = 700068,
    ErrorCode_ErrCreatureTimeIntervalError = 700069,
    ErrorCode_ErrCreatureCfgNotExist = 700070,
    ErrorCode_ErrCreatureEntityIsNotValidity = 700071,
    ErrorCode_ErrUniqueEntityCanNotCreateTwice = 700072,
    ErrorCode_ErrRoleNotHaveVisionSkill = 700073,
    ErrorCode_ErrHitGearEntityNotExist = 700074,
    ErrorCode_ErrHitGearHaveNotEntityConfig = 700075,
    ErrorCode_ErrHitGearHaveNotGearConfig = 700076,
    ErrorCode_ErrHitGearHaveNotGameplayConfig = 700077,
    ErrorCode_ErrHitGearHaveNotStepConfig = 700078,
    ErrorCode_ErrHitGearHaveEntityCommonTag = 700079,
    ErrorCode_ErrHitGearEntityFunctionTypeFail = 700080,
    ErrorCode_ErrHitGearAcceptStepFail = 700081,
    ErrorCode_ErrCreateInstanceNotContainEntrance = 700082,
    ErrorCode_ErrCreateInstanceHaveNotEntranceConfig = 700083,
    ErrorCode_ErrCreateInstanceEntranceLock = 700084,
    ErrorCode_ErrCreateInstanceHaveNotConfig = 700085,
    ErrorCode_ErrCreateInstanceEnterCountNotEnough = 700086,
    ErrorCode_ErrCreateInstanceConditionNotMatch = 700087,
    ErrorCode_ErrEnterCountRequestHaveNotConfig = 700088,
    ErrorCode_ErrUnlockInstanceEntranceHaveNotConfig = 700089,
    ErrorCode_ErrUnlockInstanceEntranceNotNeedUnlock = 700090,
    ErrorCode_ErrUnlockInstanceEntranceUnlocked = 700091,
    ErrorCode_ErrUnlockInstanceEntranceCondiitonNotMatch = 700092,
    ErrorCode_ErrEnterSceneGameplayRequestHaveNotConfig = 700093,
    ErrorCode_ErrEnterSceneGameplayRequestAccepted = 700094,
    ErrorCode_ErrEnterSceneGameplayRequestAcceptFail = 700095,
    ErrorCode_ErrStoryCharacterCreatFail = 700096,
    ErrorCode_ErrStoryCharacterCreatRepeat = 700097,
    ErrorCode_ErrStoryCharacterNotExist = 700098,
    ErrorCode_ErrCheckGearEntityNotExist = 700099,
    ErrorCode_ErrCheckGearType = 700100,
    ErrorCode_ErrCheckGearNotEntityConfig = 700101,
    ErrorCode_ErrCheckGearActive = 700102,
    ErrorCode_ErrCheckGearInactive = 700103,
    ErrorCode_ErrTargetGearGroupEntityNotExist = 700104,
    ErrorCode_ErrTargetGearGroupConfigNotExist = 700105,
    ErrorCode_ErrTargetGearEntityNotExist = 700106,
    ErrorCode_ErrTargetGearConfigNotExist = 700107,
    ErrorCode_ErrTargetGearStartTypeIsNotHit = 700108,
    ErrorCode_ErrTargetGearStartTypeIsNotAction = 700109,
    ErrorCode_ErrTargetGearStarted = 700110,
    ErrorCode_ErrTargetGearFinished = 700111,
    ErrorCode_ErrTargetGearIsNotInCreatedConsole = 700112,
    ErrorCode_ErrTargetGearGroupEntityIsNotAllInit = 700113,
    ErrorCode_ErrLanternCatNotExit = 700114,
    ErrorCode_ErrLanternCatConfNotExit = 700115,
    ErrorCode_ErrLanternCatType = 700116,
    ErrorCode_ErrLanternActived = 700117,
    ErrorCode_ErrLanternTargetNotExit = 700118,
    ErrorCode_ErrCaptureFail = 700119,
    ErrorCode_ErrDyingFail = 700120,
    ErrorCode_ErrThrowDamageEntityNotExit = 700121,
    ErrorCode_ErrThrowDamageCalculateId = 700122,
    ErrorCode_ErrThrowDamageIdNotExit = 700123,
    ErrorCode_ErrThrowDamageRoleIdConf = 700124,
    ErrorCode_ErrThrowDamageTypeNotExit = 700125,
    ErrorCode_InstIdNotExist = 700126,
    ErrorCode_ErrControlObjectEntityNotExist = 700127,
    ErrorCode_ErrControlObjectConfigNotExist = 700128,
    ErrorCode_ErrControlGroupConfigNotExist = 700129,
    ErrorCode_ErrControlObjectLocked = 700130,
    ErrorCode_ErrControlGroupLocked = 700131,
    ErrorCode_ErrControlCanNotPutTarget = 700132,
    ErrorCode_ErrControlTargetOccupied = 700133,
    ErrorCode_ErrControlObjectCatching = 700134,
    ErrorCode_ErrControlObjectNotCatching = 700135,
    ErrorCode_ErrControlObjectOtherCatching = 700136,
    ErrorCode_ErrEntityPositionIllegal = 700137,
    ErrorCode_ErrTreasureBoxNot = 700138,
    ErrorCode_ErrTreasureBoxNotInit = 700139,
    ErrorCode_ErrTreasureBoxNotConfig = 700140,
    ErrorCode_ErrTreasureBoxHadReward = 700141,
    ErrorCode_ErrTreasureBoxNotInteraction = 700142,
    ErrorCode_ErrTreasureBoxNotDropId = 700143,
    ErrorCode_ErrTreasureBoxDropErr = 700144,
    ErrorCode_ErrTreasureBoxNotExist = 700145,
    ErrorCode_ErrTreasureBoxInvalidTag = 700146,
    ErrorCode_ErrTreasureBoxHadTag = 700147,
    ErrorCode_ErrTreasureBoxNotTag = 700148,
    ErrorCode_ErrSneakGameNotOpen = 700149,
    ErrorCode_ErrSneakFinishRepeat = 700150,
    ErrorCode_ErrClientControlDamage = 700151,
    ErrorCode_ErrSceneDataSaveFail = 700152,
    ErrorCode_NotInFbInstance = 700153,
    ErrorCode_GMErrCanNotCreateWorldInst = 700154,
    ErrorCode_GMErrPlayerAlreadyInFbInst = 700155,
    ErrorCode_GMErrTagetInstanceIsNotMulti = 700156,
    ErrorCode_GMErrPlayerNotFound = 700157,
    ErrorCode_ErrEntityFlowTooMuch = 700158,
    ErrorCode_GmErrIsWalkable = 700159,
    ErrorCode_GmErrIsNotWalkable = 700160,
    ErrorCode_GmErrNoNavmesh = 700161,
    ErrorCode_ErrBigWorldInstIdNotExist = 700162,
    ErrorCode_ErrInstIdNotBigWorld = 700163,
    ErrorCode_ErrInInstanceNotSwitchBigWorld = 700164,
    ErrorCode_ErrAlreadyInThisBigWorld = 700165,
    ErrorCode_ErrNoPermissionGetTreasureBox = 700166,
    ErrorCode_ErrCreateBigWorldRepeat = 700167,
    ErrorCode_DebugErrInstIdNotExist = 700168,
    ErrorCode_ErrSceneAiStopped = 700169,
    ErrorCode_ErrGlobalEntityConfigNotExist = 700170,
    ErrorCode_ErrSceneFixedConfigNotExist = 700171,
    ErrorCode_ErrSceneFixedEntityNotFound = 700172,
    ErrorCode_ErrSceneGlobalEntityNotFount = 700173,
    ErrorCode_ErrEntityNotHaveVarComponent = 700174,
    ErrorCode_ErrEntityVarNameNotExist = 700175,
    ErrorCode_ErrEntityVarTypeError = 700176,
    ErrorCode_ErrEntityConfigNotOffer = 700177,
    ErrorCode_ErrConfigTypeNotGloabl = 700178,
    ErrorCode_ErrConfigTypeNotSceneFixed = 700179,
    ErrorCode_ErrConfigTypeNotCharacter = 700180,
    ErrorCode_ErrEntityPosNotOffer = 700181,
    ErrorCode_ErrSceneCellPosNotFount = 700182,
    ErrorCode_ErrEntityCongigNotInSleep = 700183,
    ErrorCode_ErrSummonCfgNotFound = 700184,
    ErrorCode_ErrSummonAddEntityFail = 700185,
    ErrorCode_ErrSummonMaxCount = 700186,
    ErrorCode_ErrSummonMaxGenerations = 700187,
    ErrorCode_ErrSummonEntityIdAlreadyExist = 700188,
    ErrorCode_ErrSummonerEntityType = 700189,
    ErrorCode_ErrEntityStatusIsNotDead = 700190,
    ErrorCode_ErrEntityNotHaveAttributeComp = 700191,
    ErrorCode_ErrEntityDbData = 700192,
    ErrorCode_ErrSceneFixedEntityCreated = 700193,
    ErrorCode_ErrInvalidAwakeEntityContext = 700194,
    ErrorCode_ErrTriggerComponentNotExist = 700195,
    ErrorCode_ErrTriggerComponentMaxCount = 700196,
    ErrorCode_ErrNotSelfRole = 700197,
    ErrorCode_ErrNoControlRights = 700198,
    ErrorCode_ErrEntityHaveNotEntityOwner = 700199,
    ErrorCode_ErrEntityOwnerNotMatch = 700200,
    ErrorCode_ErrCreateSceneFixedEntitiesEmpty = 700201,
    ErrorCode_ErrInteractComponentNotExist = 700202,
    ErrorCode_ErrInteractOptionIndexInvalid = 700203,
    ErrorCode_ErrOnlineInteractNoPermission = 700204,
    ErrorCode_ErrOnlineInteractNotOpen = 700205,
    ErrorCode_ErrAwakeEntityNoPermission = 700206,
    ErrorCode_ErrCannotUseSkillStatus = 700207,
    ErrorCode_ErrInteractOptionGuidInvalid = 700208,
    ErrorCode_ErrAddInteractOptionFail = 700209,
    ErrorCode_ErrRemoveInteractOptionFail = 700210,
    ErrorCode_ErrInteractOptionOwnerNotFound = 700211,
    ErrorCode_ErrSummonPlayerId = 700212,
    ErrorCode_ErrSummonTemplateCfgNotFound = 700213,
    ErrorCode_ErrAttributeComponent = 700214,
    ErrorCode_ErrAnimFsmComponent = 700215,
    ErrorCode_ErrStateComponent = 700216,
    ErrorCode_ErrBattleComponent = 700217,
    ErrorCode_ErrPartComponent = 700218,
    ErrorCode_ErrAiControlComponent = 700219,
    ErrorCode_ErrSummonsComponent = 700220,
    ErrorCode_ErrAiBlackboardComponent = 700221,
    ErrorCode_ErrSetVarInvalidContext = 700222,
    ErrorCode_ErrSetVarInvalidVarRefPb = 700223,
    ErrorCode_ErrSetVarGetRightVarDefineFail = 700224,
    ErrorCode_ErrSetVarSetLeftVarDefineFail = 700225,
    ErrorCode_ErrCalcVarInvalidContext = 700226,
    ErrorCode_ErrCalcVarInvalidVarRef = 700227,
    ErrorCode_ErrCalcVarGetVarDefineFail = 700228,
    ErrorCode_ErrCalcVarInvalidVarType = 700229,
    ErrorCode_ErrCalcVarInvalidOp = 700230,
    ErrorCode_ErrCalcVarSetResultFail = 700231,
    ErrorCode_ErrActionEntityNoExist = 700232,
    ErrorCode_ErrActionNoInteractConfig = 700233,
    ErrorCode_ErrActionIdNoExist = 700234,
    ErrorCode_ErrActionBtObjNoExist = 700235,
    ErrorCode_ErrActionNodeNoExist = 700236,
    ErrorCode_ErrActionNoChildQuest = 700237,
    ErrorCode_ErrActionParams = 700238,
    ErrorCode_ErrActionNotEntityContext = 700239,
    ErrorCode_ErrActionExecutorNotFind = 700240,
    ErrorCode_ErrActionSessionNotFind = 700241,
    ErrorCode_ErrActionCreateSessionIdFail = 700242,
    ErrorCode_ErrActionPathConvertFail = 700243,
    ErrorCode_ErrActionConfigNotFind = 700244,
    ErrorCode_ErrActionHaveNotHandler = 700245,
    ErrorCode_ErrActionInternalError = 700246,
    ErrorCode_ErrActionInvalidIndex = 700247,
    ErrorCode_ErrActionIsNotServer = 700248,
    ErrorCode_ErrActionRemainActionNotFinish = 700249,
    ErrorCode_ErrActionExecutorIsNotBlackbard = 700250,
    ErrorCode_ErrContinuityActionNotFinish = 700251,
    ErrorCode_ErrActionIsNotContinuity = 700252,
    ErrorCode_ErrResetLocationEntityNotExist = 700253,
    ErrorCode_ErrEntityPosAbnormalNotExists = 700254,
    ErrorCode_ErrGmRemoveEntityNotExists = 700255,
    ErrorCode_ErrDrownEntityNotExists = 700256,
    ErrorCode_ErrTargetGearNotExists = 700257,
    ErrorCode_ErrOutofBattleEntityNotExists = 700258,
    ErrorCode_ErrOrderAddBuffEntityNotExists = 700259,
    ErrorCode_ErrOrderRemoveBuffEntityNotExists = 700260,
    ErrorCode_ErrActivateBuffEntityNotExists = 700261,
    ErrorCode_ErrToughCalcExtraRatioChangeEntityNotExists = 700262,
    ErrorCode_ErrAdsorbEntityNotExist = 700263,
    ErrorCode_ErrAdsorbCondNotMeet = 700264,
    ErrorCode_ErrTimelineTrackMultiGameForbid = 700265,
    ErrorCode_ErrTimelineTraceEntityNotExists = 700266,
    ErrorCode_ErrTimelineTraceComponentNotExists = 700267,
    ErrorCode_ErrTimelineTraceGroupIndex = 700268,
    ErrorCode_ErrTimelineTraceFinish = 700269,
    ErrorCode_ErrTimelineTraceCondition = 700270,
    ErrorCode_ErrTimelineTraceTargetEmpty = 700271,
    ErrorCode_ErrTimelineTraceControl = 700272,
    ErrorCode_ErrTimelineTraceFinishCondition = 700273,
    ErrorCode_ErrTimelineTraceNotInControl = 700274,
    ErrorCode_ErrForbidEnterInstance = 700275,
    ErrorCode_ErrForbitEnterBigWorld = 700276,
    ErrorCode_ErrPrefabIncIdExist = 700277,
    ErrorCode_ErrPrefabIdExist = 700278,
    ErrorCode_ErrPrefabNumberIsZero = 700279,
    ErrorCode_ErrPrefabEntityIsExist = 700280,
    ErrorCode_ErrPrefabTreasureBox = 700281,
    ErrorCode_ErrPrefabActionCreate = 700282,
    ErrorCode_ErrPrefabVarNoExist = 700283,
    ErrorCode_ErrClientOnlyEntityCantCreate = 700284,
    ErrorCode_ErrTimelineTraceActionRun = 700285,
    ErrorCode_ErrGmActivateTeleportSceneNotExist = 700286,
    ErrorCode_ErrGmCreateInstSceneHasExist = 700287,
    ErrorCode_ErrVfxNpcNotExist = 700288,
    ErrorCode_ErrVfxNpcIsNotVfxNpc = 700289,
    ErrorCode_ErrBlackboardLimit = 700290,
    ErrorCode_ErrBlackboardArrayLimit = 700291,
    ErrorCode_ErrBlackboardStringLimit = 700292,
    ErrorCode_ErrReconnectGWGetGatePlayerFailed = 800000,
    ErrorCode_ErrGWReconnectGWInvalidPlayerState = 800001,
    ErrorCode_ErrGWReconnectGWVerifyTokenFailed = 800002,
    ErrorCode_ErrGWReconnectGWBackOnlineAsyncFailed = 800003,
    ErrorCode_ErrGWReconnectGWBackOnlineAsyncException = 800004,
    ErrorCode_ErrReconnectGwclientLatestSeqNoNotHit = 800005,
    ErrorCode_ErrGWReconnectConfirmGetPlayerFailed = 800006,
    ErrorCode_ErrAttrChangeHandleInvalidClientAction = 800007,
    ErrorCode_ErrThrowDamageReqGetStateComponentFailed = 800008,
    ErrorCode_ErrThrowDamageReqEntityIsAlreadyDead = 800009,
    ErrorCode_ErrAnimalDieRequestForceSetDieError = 800010,
    ErrorCode_ErrCollectEntityForceSetEntityDieError = 800011,
    ErrorCode_ErrMonsterBoomForceSetDieError = 800012,
    ErrorCode_ErrAttrChangeReqReplaceAttrListFailed = 800013,
    ErrorCode_ErrReconnectInvalidOperation = 800014,
    ErrorCode_ErrReconnectGwNodeTainted = 800015,
    ErrorCode_ErrFavorRoleNotFound = 900000,
    ErrorCode_ErrFavorConfNotFound = 900001,
    ErrorCode_ErrFavorQuestNotFound = 900002,
    ErrorCode_ErrFavorLevelRewardLimit = 900003,
    ErrorCode_ErrFavorQuestAcceptLimit = 900004,
    ErrorCode_ErrFavorItemLocked = 900005,
    ErrorCode_ErrFavorItemHasUnLocked = 900006,
    ErrorCode_ErrElevatorEntityNotExit = 900007,
    ErrorCode_ErrElevatorConfigNotExit = 900008,
    ErrorCode_ErrElevatorLocked = 900009,
    ErrorCode_ErrElevatorIsNotReverse = 900010,
    ErrorCode_ErrElevatorIsNotForward = 900011,
    ErrorCode_ErrElevatorIsNotStart = 900012,
    ErrorCode_ErrElevatorIsNotEnd = 900013,
    ErrorCode_ErrElevatorFloorError = 900014,
    ErrorCode_ErrHostRefuse = 900015,
    ErrorCode_ErrHostOffline = 900016,
    ErrorCode_ErrHostHasOnline = 900017,
    ErrorCode_ErrHostPlayerMax = 900018,
    ErrorCode_ErrHostRefuseStrangers = 900019,
    ErrorCode_ErrHostForbidJoin = 900020,
    ErrorCode_ErrHostTemporarilyForbidJoin = 900021,
    ErrorCode_ErrSlaveInBlockList = 900022,
    ErrorCode_ErrExceedJoinLevelDiff = 900023,
    ErrorCode_ErrHostNotOpenOnlineFunc = 900024,
    ErrorCode_ErrHostInOtherPlayer = 900025,
    ErrorCode_ErrHostInForbidOnlineQuest = 900026,
    ErrorCode_ErrSlaveHasOnline = 900027,
    ErrorCode_ErrSlaveInForbidOnlineQuest = 900028,
    ErrorCode_ErrSlaveNotOpenOnlineFunc = 900029,
    ErrorCode_ErrSlaveApplyRepeated = 900030,
    ErrorCode_ErrSlaveTryApplySelf = 900031,
    ErrorCode_ErrLobbyTryQuerySelf = 900032,
    ErrorCode_ErrSlaveRequestExpired = 900033,
    ErrorCode_ErrEnterringOtherScene = 900034,
    ErrorCode_ErrWaitingOtherJoin = 900035,
    ErrorCode_ErrWaitListFull = 900036,
    ErrorCode_ErrAlreayInWaitEnterList = 900037,
    ErrorCode_ErrHostNotInBigWorld = 900038,
    ErrorCode_ErrPlayerNotInBigWorld = 900039,
    ErrorCode_ErrPlayerNotInWaitList = 900040,
    ErrorCode_ErrForbidOperaInMatching = 900041,
    ErrorCode_ErrLobbyNotFoundPlayer = 900042,
    ErrorCode_ErrRoleTrailCannotOnline = 900043,
    ErrorCode_ErrHostRoleTrail = 900044,
    ErrorCode_ErrInMatchingCanNotJoinOther = 900045,
    ErrorCode_ErrInMatchCanNotBeApply = 900046,
    ErrorCode_ErrInMatchCanNotAcceptApply = 900047,
    ErrorCode_ErrSlaveInFlow = 900048,
    ErrorCode_ErrHostInFlow = 900049,
    ErrorCode_ErrAchievementNotClinet = 900050,
    ErrorCode_ErrTriggerConditionNotMet = 900051,
    ErrorCode_ErrNpcTraceNotConf = 900052,
    ErrorCode_ErrBuffProducerConfNotFound = 900053,
    ErrorCode_ErrBuffProducerHasDone = 900054,
    ErrorCode_ErrBuffConsumerConfNotFound = 900055,
    ErrorCode_ErrBuffConsumerBuffNotFound = 900056,
    ErrorCode_ErrBuffConsumerEntityNotFound = 900057,
    ErrorCode_ErrItemPosInvaild = 900058,
    ErrorCode_ErrItemIdInvaild = 900059,
    ErrorCode_ErrRouletteFuncIdInvaild = 900060,
    ErrorCode_ErrStateIsRunning = 900061,
    ErrorCode_ErrSceneEntityNotFind = 900062,
    ErrorCode_ErrActionPlayersIsEmpty = 900063,
    ErrorCode_ErrFireBulletNoLauncher = 900064,
    ErrorCode_ErrFireBulletNoTarget = 900065,
    ErrorCode_ErrTurntableConfigNotFound = 900066,
    ErrorCode_ErrTurntableActivityNotOpen = 900067,
    ErrorCode_ErrTurntableActivityIsFinish = 900068,
    ErrorCode_ErrTurntableActivityQuestNotFinish = 900069,
    ErrorCode_ErrTurntableActivityRoundConfigNotFound = 900070,
    ErrorCode_ErrEnrichmentAreaIsEmpty = 900071,
    ErrorCode_ErrEnrichmentAreaNotFind = 900072,
    ErrorCode_ErrEnrichmentAreaInCD = 900073,
    ErrorCode_ErrEnrichmentAreaInFog = 900074,
    ErrorCode_ErrEntityWalkingPoint = 900075,
    ErrorCode_ErrServerConfigReload = 900076,
    ErrorCode_ErrAreaCheckFailed = 900077,
    ErrorCode_ErrHostSceneBlockSplitFail = 900078,
    ErrorCode_ErrSlaveSceneBlockSplitFail = 900079,
    ErrorCode_ErrHookLockBatchCollectMaxCount = 900080,
    ErrorCode_ErrHookLockBatchCollectFail = 900081,
    ErrorCode_ErrEntityPackIdErr = 900082,
    ErrorCode_ErrBuffItemConfig = 1000000,
    ErrorCode_ErrBuffItemNotShare = 1000001,
    ErrorCode_ErrBuffItemShareRoleId = 1000002,
    ErrorCode_ErrBuffItemRoleIdNotExist = 1000003,
    ErrorCode_ErrBuffItemNotEnough = 1000004,
    ErrorCode_ErrBuffItemMultiUse = 1000005,
    ErrorCode_ErrBuffItemCdLimit = 1000006,
    ErrorCode_ErrBuffItemNumZero = 1000007,
    ErrorCode_ErrBuffItemNotPlayer = 1000008,
    ErrorCode_ErrSceneItemNotExit = 1000009,
    ErrorCode_ErrSceneItemType = 1000010,
    ErrorCode_ErrSceneItemOperate = 1000011,
    ErrorCode_ErrSceneItemState = 1000012,
    ErrorCode_ErrStateEntityNoExit = 1000013,
    ErrorCode_ErrStateEntityNotTagComp = 1000014,
    ErrorCode_ErrStateEntityTypeNotExit = 1000015,
    ErrorCode_ErrStateEntityStateNotExit = 1000016,
    ErrorCode_ErrStateEntityNotConfig = 1000017,
    ErrorCode_ErrStateEntityStateType = 1000018,
    ErrorCode_ErrStateEntityStateNoChange = 1000019,
    ErrorCode_ErrStateEntitySilent = 1000020,
    ErrorCode_ErrStateEntityComplete = 1000021,
    ErrorCode_ErrStateEntityLock = 1000022,
    ErrorCode_ErrStateEntityNotBorn = 1000023,
    ErrorCode_ErrStateNameNoExit = 1000024,
    ErrorCode_ErrStateInBorn = 1000025,
    ErrorCode_ErrStateCondition = 1000026,
    ErrorCode_ErrStateNotOwner = 1000027,
    ErrorCode_ErrChangeSelfStateObjNotEntity = 1000028,
    ErrorCode_ErrFoundationNotExists = 1000029,
    ErrorCode_ErrTeleControlNotExists = 1000030,
    ErrorCode_ErrFoundationNotComponent = 1000031,
    ErrorCode_ErrFoundationActived = 1000032,
    ErrorCode_ErrFoundationUnActived = 1000033,
    ErrorCode_ErrFoundationNotMatch = 1000034,
    ErrorCode_ErrFoundationNotInRange = 1000035,
    ErrorCode_ErrFoundationNotStateId = 1000036,
    ErrorCode_ErrGravityGearNotExists = 1000037,
    ErrorCode_ErrGravityGearNotConfig = 1000038,
    ErrorCode_ErrGravityGearForbidReset = 1000039,
    ErrorCode_ErrFollowTrackEntityNoExist = 1000040,
    ErrorCode_ErrFollowTrackNotComp = 1000041,
    ErrorCode_ErrFollowTrackNotFoundationId = 1000042,
    ErrorCode_ErrFollowTrackNotFoundation = 1000043,
    ErrorCode_ErrFollowTrackActiveed = 1000044,
    ErrorCode_ErrThrowPlayerNotExit = 1000045,
    ErrorCode_ErrAnimalEntityNotExist = 1000046,
    ErrorCode_ErrNotAnimalEntity = 1000047,
    ErrorCode_ErrSneakBtObjNotExist = 1000048,
    ErrorCode_ErrSneakNodeIdNotExist = 1000049,
    ErrorCode_ErrSneakNotFailedNode = 1000050,
    ErrorCode_ErrSneakNotTime = 1000051,
    ErrorCode_ErrSneakTime = 1000052,
    ErrorCode_ErrInSneak = 1000053,
    ErrorCode_ErrNotInSneak = 1000054,
    ErrorCode_ErrBeControlledEntityNotExist = 1000055,
    ErrorCode_ErrNotBeControlledEntity = 1000056,
    ErrorCode_ErrNotBeControlledPlayer = 1000057,
    ErrorCode_ErrNotBeControlledNotPlayer = 1000058,
    ErrorCode_ErrBeControlledShowEntityNotExist = 1000059,
    ErrorCode_ErrNotBeControlledShowEntity = 1000060,
    ErrorCode_ErrNotBeControlledShowPlayer = 1000061,
    ErrorCode_ErrBeControlledShowNoChange = 1000062,
    ErrorCode_ErrGravityGearCondition = 1000063,
    ErrorCode_ErrChairEntityNoExist = 1000064,
    ErrorCode_ErrChairSitDownErr = 1000065,
    ErrorCode_ErrChairEntity = 1000066,
    ErrorCode_ErrPlayerAlreadySit = 1000067,
    ErrorCode_ErrChairNotStateConfig = 1000068,
    ErrorCode_ErrSneakBtObjIncId = 1000069,
    ErrorCode_ErrTimelineMove = 1000070,
    ErrorCode_ErrBeControlledConfig = 1000071,
    ErrorCode_ErrBeControlledThrow = 1000072,
    ErrorCode_ErrBeControlledTimeNull = 1000073,
    ErrorCode_ErrTriggerEnterActionEffective = 1000074,
    ErrorCode_ErrTriggerLeaveActionEffective = 1000075,
    ErrorCode_ErrTriggerLastActionStateError = 1000076,
    ErrorCode_GuideGroupInfoIsNull = 1100000,
    ErrorCode_GuideStateError = 1100001,
    ErrorCode_GuideConfigNotFind = 1100002,
    ErrorCode_GuideNoEnough = 1100003,
    ErrorCode_GuideIsFinish = 1100004,
    ErrorCode_GuidePerIsNotFinish = 1100005,
    ErrorCode_GuideNoCondition = 1100006,
    ErrorCode_GuideNoCurGroup = 1100007,
    ErrorCode_GuideIsServerMonitor = 1100008,
    ErrorCode_GuideNoPending = 1100009,
    ErrorCode_GuideStepRepeat = 1100010,
    ErrorCode_GuideGroupNoClient = 1100011,
    ErrorCode_GuideGroupDoing = 1100012,
    ErrorCode_GuideGroupIsNotRepeat = 1100013,
    ErrorCode_GuideTutorialConfigNotFind = 1100014,
    ErrorCode_GuideTutorialIsUnlock = 1100015,
    ErrorCode_GuideTutorialNotUnlock = 1100016,
    ErrorCode_GuideTutorialIsReceive = 1100017,
    ErrorCode_GuideTutorialAwardConfigNotFind = 1100018,
    ErrorCode_GuideTutorialAwardError = 1100019,
    ErrorCode_GuideGroupIdNoMatch = 1100020,
    ErrorCode_ErrRequestTypeNotExist = 1100021,
    ErrorCode_ErrIllustratedEntryLock = 1100022,
    ErrorCode_ErrIllustratedEntryBanUnlock = 1100023,
    ErrorCode_ErrRequestTypeMax = 1100024,
    ErrorCode_AchievementEntryNotExist = 1100025,
    ErrorCode_AchievementEntryNotFinish = 1100026,
    ErrorCode_AchievementEntryIsReceive = 1100027,
    ErrorCode_AchievementEntryNoConfig = 1100028,
    ErrorCode_AchievementEntryNotOpen = 1100029,
    ErrorCode_AchievementGroupEntryNotExist = 1100030,
    ErrorCode_AchievementGroupEntryNotFinish = 1100031,
    ErrorCode_AchievementGroupEntryIsReceive = 1100032,
    ErrorCode_AchievementGroupEntryNoConfig = 1100033,
    ErrorCode_AchievementGroupEntryNotOpen = 1100034,
    ErrorCode_SilentAreaNotConfig = 1100035,
    ErrorCode_SilentAreaNotUnlock = 1100036,
    ErrorCode_SilentAreaNotFinish = 1100037,
    ErrorCode_SilentAreaReceive = 1100038,
    ErrorCode_AchievementEntryIsFinish = 1100039,
    ErrorCode_AchievementEntryNeedCondition = 1100040,
    ErrorCode_AchievementSceneNotFind = 1100041,
    ErrorCode_BirthdayIsSetting = 1100042,
    ErrorCode_BirthdayInValid = 1100043,
    ErrorCode_RoleShowListMaxCount = 1100044,
    ErrorCode_RoleShowListHasRepeatId = 1100045,
    ErrorCode_RoleShowListHasInValidId = 1100046,
    ErrorCode_CardShowListMaxCount = 1100047,
    ErrorCode_CardShowListHasRepeatId = 1100048,
    ErrorCode_CardShowListHasInValidId = 1100049,
    ErrorCode_CardRepeatSet = 1100050,
    ErrorCode_CardIsInValidId = 1100051,
    ErrorCode_CardIsRead = 1100052,
    ErrorCode_RoleShowListEmpty = 1100053,
    ErrorCode_SettingNotFind = 1100054,
    ErrorCode_RogueRoadConfigNotFind = 1100055,
    ErrorCode_RollRogueRoomError = 1100056,
    ErrorCode_RollRogueBuffError = 1100057,
    ErrorCode_GetRogueRoomIdsError = 1100058,
    ErrorCode_GetRoguePortalEntityNotFind = 1100059,
    ErrorCode_GetRoguePortalLocationNotFind = 1100060,
    ErrorCode_HttpTimeout = 1100061,
    ErrorCode_HttpResultUndefine = 1100062,
    ErrorCode_ConvGateTimeout = 1100063,
    ErrorCode_ProtoKeyTimeout = 1100064,
    ErrorCode_LoginReqTimeout = 1100065,
    ErrorCode_EnterGameTimeout = 1100066,
    ErrorCode_ReReconvReqTimeout = 1100067,
    ErrorCode_RecvSeqNoNotHit = 1100068,
    ErrorCode_AchievementFuncNotOpen = 1100069,
    ErrorCode_RoguelikeInstComponentNotFind = 1100070,
    ErrorCode_RogueCurRoomDataIsNull = 1100071,
    ErrorCode_LevelPlayComponentNotFind = 1100072,
    ErrorCode_OpenLevelPlayFail = 1100073,
    ErrorCode_CloseLevelPlayFail = 1100074,
    ErrorCode_RogueRoomConfigNotFind = 1100075,
    ErrorCode_RogueRoomTypeNotRight = 1100076,
    ErrorCode_RogueRoomTypeNotConfig = 1100077,
    ErrorCode_RogueRoomSubLevelNotFind = 1100078,
    ErrorCode_SelectNextRoomIsValid = 1100079,
    ErrorCode_RogueGainPackageFail = 1100080,
    ErrorCode_RogueGainListIsNull = 1100081,
    ErrorCode_RogueGainIdValid = 1100082,
    ErrorCode_QulityListCountNotRight = 1100083,
    ErrorCode_RandomResultCountNotRight = 1100084,
    ErrorCode_GuaranteeRogueBuffInValid = 1100085,
    ErrorCode_RoleBuffPoolNotFind = 1100086,
    ErrorCode_NotValidBuff = 1100087,
    ErrorCode_NotValidPhantom = 1100088,
    ErrorCode_RandomPhantomFail = 1100089,
    ErrorCode_NotValidRole = 1100090,
    ErrorCode_RandomRoleFail = 1100091,
    ErrorCode_RogueRoadNotFind = 1100092,
    ErrorCode_ResultCountNotMatch = 1100093,
    ErrorCode_InValidRoomCountNotMatch = 1100094,
    ErrorCode_GuaranteeRogueRoomInValid = 1100095,
    ErrorCode_InstIdNotMatchLevelPlayId = 1100096,
    ErrorCode_GetRoomBornPositionFail = 1100097,
    ErrorCode_RoguePortalDataNotClean = 1100098,
    ErrorCode_RoguePortalRoomDataNotFind = 1100099,
    ErrorCode_RogueSelectRoomFail = 1100100,
    ErrorCode_RogueProgressDataIsEmpty = 1100101,
    ErrorCode_RogueGainTypeIsValid = 1100102,
    ErrorCode_RougeNotOpen = 1100103,
    ErrorCode_RougeInstIdIsValid = 1100104,
    ErrorCode_RogueRoleListCountNotRight = 1100105,
    ErrorCode_RogueMainRoleConfigNotFind = 1100106,
    ErrorCode_RogueGainDataDictError = 1100107,
    ErrorCode_RogueDiscountedBuffConfigNotFind = 1100108,
    ErrorCode_RogueDiscountedRoomTypeConfigNotFind = 1100109,
    ErrorCode_RogueDiscountedShopConfigNotFind = 1100110,
    ErrorCode_RogueDiscountedCalculateFail = 1100111,
    ErrorCode_RogueMoneyNotEnough = 1100112,
    ErrorCode_RougeShopRefreshTimeEmpyt = 1100113,
    ErrorCode_RougeCurRoomNotFinish = 1100114,
    ErrorCode_PlayerDataRepairErrorDebug = 1100115,
    ErrorCode_PlayerDataRepairError = 1100116,
    ErrorCode_CreateCharacterReqTimeout = 1100117,
    ErrorCode_SignActivityNotOpen = 1100118,
    ErrorCode_SignActivityNoConfig = 1100119,
    ErrorCode_SignActivityIndexValid = 1100120,
    ErrorCode_SignActivityNoData = 1100121,
    ErrorCode_SignActivityStateNotRight = 1100122,
    ErrorCode_RogueSeasonDataNull = 1100123,
    ErrorCode_RogueSeasonConfigNotFind = 1100124,
    ErrorCode_RogueTokenConfigNotFind = 1100125,
    ErrorCode_RogueTokenStatusVaild = 1100126,
    ErrorCode_RogueSeasonRewardConfigNotFind = 1100127,
    ErrorCode_RogueSeasonRewardIsReceive = 1100128,
    ErrorCode_RougeSeasonPointNotEnough = 1100129,
    ErrorCode_RougeRoomDataError = 1100130,
    ErrorCode_RogueGainDataError = 1100131,
    ErrorCode_RogueRoleIdsError = 1100132,
    ErrorCode_RogueRogueRoomRouteError = 1100133,
    ErrorCode_RogueGetCurRoomLevelPlayError = 1100134,
    ErrorCode_RogueTalentTreeConfigNotFind = 1100135,
    ErrorCode_RogueTalentTreeConditionNotMet = 1100136,
    ErrorCode_RogueTalentTreePerNodeLock = 1100137,
    ErrorCode_RogueTalentTreeNodeMaxLevel = 1100138,
    ErrorCode_RogueTalentTreeConsumeNoEnough = 1100139,
    ErrorCode_RogueRoadRandomRoleBuffError = 1100140,
    ErrorCode_ActivityFuncNotOpen = 1100141,
    ErrorCode_RogueGuideInstNotSupport = 1100142,
    ErrorCode_ErrPayReceiptCannotRefundClose = 1100143,
    ErrorCode_ErrPayReceiptRefundCloseFail = 1100144,
    ErrorCode_PayRefundOverdueBan = 1100145,
    ErrorCode_UnknowChannelId = 1100146,
    ErrorCode_LoginServerNotFind = 1100147,
    ErrorCode_OldGameNodeLogoutFail = 1100148,
    ErrorCode_LoginHandleSwitchError = 1100149,
    ErrorCode_NoAvailableLoginService = 1100150,
    ErrorCode_ServerIsClosing = 1100151,
    ErrorCode_AddPlayerRecordFail = 1100152,
    ErrorCode_FindGatewayFail = 1100153,
    ErrorCode_CommonFightRolesInfoError = 1100154,
    ErrorCode_CurRoleEntityNotFind = 1100155,
    ErrorCode_ScenePlayerInfoNotFind = 1100156,
    ErrorCode_IncrAdviceVoteError = 1100157,
    ErrorCode_InsertAdviceError = 1100158,
    ErrorCode_UpdateAdviceError = 1100159,
    ErrorCode_DeleteAdviceError = 1100160,
    ErrorCode_EntityNoInWater = 1100161,
    ErrorCode_AttributeComponentNotFind = 1100162,
    ErrorCode_TryAddItemDataFail = 1100163,
    ErrorCode_ItemConfigTypeNotRight = 1100164,
    ErrorCode_ItemLogicNotFind = 1100165,
    ErrorCode_RemoveItemLogicNotFind = 1100166,
    ErrorCode_AddItemLogicNotFind = 1100167,
    ErrorCode_AddItemFail = 1100168,
    ErrorCode_UpdatePlayerARemarkFail = 1100169,
    ErrorCode_DeleteFriendApplyFail = 1100170,
    ErrorCode_DeleteFriendshipFail = 1100171,
    ErrorCode_WorldTeamIsNull = 1100172,
    ErrorCode_TeamCountNotRight = 1100173,
    ErrorCode_AddCalabashExpFail = 1100174,
    ErrorCode_SendRequestToSdkFail = 1100175,
    ErrorCode_DirtyWordErrorCode = 1100176,
    ErrorCode_HarvestActivityNotOpen = 1100177,
    ErrorCode_HarvestActivityPointReceived = 1100178,
    ErrorCode_HarvestActivityPointNotConfig = 1100179,
    ErrorCode_HarvestActivityPointNotEnough = 1100180,
    ErrorCode_HarvestActivityLevelNoData = 1100181,
    ErrorCode_HarvestActivityLevelReceived = 1100182,
    ErrorCode_HarvestActivityLevelNotConfig = 1100183,
    ErrorCode_HarvestActivityLevelNotEnough = 1100184,
    ErrorCode_HarvestActivityLevelDiffNotConfig = 1100185,
    ErrorCode_RoguelikeEventConfigNotFind = 1100186,
    ErrorCode_RoguelikeEventIndexError = 1100187,
    ErrorCode_RoguelikeInstConfigNotFind = 1100188,
    ErrorCode_RoguelikeMainRoleError = 1100189,
    ErrorCode_RoguelikeEventIsEmpty = 1100190,
    ErrorCode_RoguelikeEventRandomError = 1100191,
    ErrorCode_RoguelikeEventRandomEmpty = 1100192,
    ErrorCode_PhantomCollectActivityNotOpen = 1100193,
    ErrorCode_PhantomCollectActivitynNotConfig = 1100194,
    ErrorCode_PhantomCollectActivitynNoData = 1100195,
    ErrorCode_PhantomCollectActivityReceived = 1100196,
    ErrorCode_HarvestInstIdInValid = 1100197,
    ErrorCode_HarvestVarNotExist = 1100198,
    ErrorCode_HarvestResultCacheNotExist = 1100199,
    ErrorCode_HarvestInstNotOpen = 1100200,
    ErrorCode_HarvestActivityLimitDataNotFind = 1100201,
    ErrorCode_HarvestDiffConfigNotFind = 1100202,
    ErrorCode_HarvestActivityDiffConfigNotFind = 1100203,
    ErrorCode_ErrIllustratedConfigNotFind = 1100204,
    ErrorCode_CharacterAlreadyCreated = 1100205,
    ErrorCode_SdkHelperInternalError = 1100206,
    ErrorCode_GameServiceControllerInternalError = 1100207,
    ErrorCode_DoGetCacheInfoInternalError = 1100208,
    ErrorCode_DoGetCacheInfosInternalError = 1100209,
    ErrorCode_DeleteFriendLoadedInternalError = 1100210,
    ErrorCode_UpdateFriendRemarkInternalError = 1100211,
    ErrorCode_CheckApplyRequestInternalError = 1100212,
    ErrorCode_OnReLoginInternalError = 1100213,
    ErrorCode_CreateCharacterRequestInternalError = 1100214,
    ErrorCode_LoginRequestInternalError = 1100215,
    ErrorCode_LoginRequestInternalError2 = 1100216,
    ErrorCode_EnterGameRequestInternalError = 1100217,
    ErrorCode_ReconnectRequestInternalError = 1100218,
    ErrorCode_ReconnectRequestInternalError2 = 1100219,
    ErrorCode_SwitchNodeInternalError = 1100220,
    ErrorCode_InnerLoginInternalError = 1100221,
    ErrorCode_AccessTokenInternalError = 1100222,
    ErrorCode_CreateCharacterInternalError = 1100223,
    ErrorCode_RogueSeasonNotValid = 1100224,
    ErrorCode_RogueCurRoleNotFind = 1100225,
    ErrorCode_RogueSeasonNotMatch = 1100226,
    ErrorCode_RogueGainLogicNotFind = 1100227,
    ErrorCode_RogueBuffConfigNotFind = 1100228,
    ErrorCode_RoguePhantomNotConfig = 1100229,
    ErrorCode_RogueRoleNotConfig = 1100230,
    ErrorCode_RoguePopularSlotConfigNotFind = 1100231,
    ErrorCode_RoguePopularCountIsMax = 1100232,
    ErrorCode_RoguePopularConfigNotFind = 1100233,
    ErrorCode_RogueRoleNotOpen = 1100234,
    ErrorCode_RogueGuideInstError = 1100235,
    ErrorCode_RogueMainRoleChange = 1100236,
    ErrorCode_RogueShopConfigNull = 1100237,
    ErrorCode_RogueGainIsSelect = 1100238,
    ErrorCode_RogueGainNoRefresh = 1100239,
    ErrorCode_RogueRefreshCostNotFind = 1100240,
    ErrorCode_RogueNotMaxLayer = 1100241,
    ErrorCode_RogueRoomSubLevelNotFind2 = 1100242,
    ErrorCode_RoguePopularSlotArgConfigNotFind = 1100243,
    ErrorCode_RogueInstSeasonNotMatch = 1100244,
    ErrorCode_RogueSeasonTalentTreeNotFind = 1100245,
    ErrorCode_RogueGainOptionsNotFind = 1100246,
    ErrorCode_RogueGainIsSell = 1100247,
    ErrorCode_RogueMiracleCreationConfNotFind = 1100248,
    ErrorCode_RogueGainPackageError = 1100249,
    ErrorCode_RogueTrialRoleIdsCountNotRight = 1100250,
    ErrorCode_RogueVarNotExist = 1100251,
    ErrorCode_RougeWhiteCatConfigNotFind = 1100252,
    ErrorCode_RougeWhiteCatNotOpen = 1100253,
    ErrorCode_RougeWhiteCatLimitedTime = 1100254,
    ErrorCode_RougeWhiteCatRewardLock = 1100255,
    ErrorCode_RougeWhiteCatRewardIsReceive = 1100256,
    ErrorCode_RougeWhiteCatRewardIndexErr = 1100257,
    ErrorCode_RougeWhiteCatInstIndexErr = 1100258,
    ErrorCode_RougeWhiteCatInstLock = 1100259,
    ErrorCode_RougeWhiteCatBossRewardIndexErr = 1100260,
    ErrorCode_RougeWhiteCatBossRewardLock = 1100261,
    ErrorCode_RougeWhiteCatBossRewardIsReceive = 1100262,
    ErrorCode_RougeWhiteCatLevelPlayIndexErr = 1100263,
    ErrorCode_RougeWhiteCatLevelPlayLock = 1100264,
    ErrorCode_RougeWhiteCatLevelPlayIsReceive = 1100265,
    ErrorCode_ResourceVersionTooLow = 1100266,
    ErrorCode_RogueLimitTimeRewardConfigNotFind = 1100267,
    ErrorCode_RogueWhiteCatLimitedTimeOut = 1100268,
    ErrorCode_RougeWhiteCatLimitedRewardLock = 1100269,
    ErrorCode_RougeWhiteCatLimitedRewardIsReceive = 1100270,
    ErrorCode_RougeWhiteCatBlackFlowerNoCount = 1100271,
    ErrorCode_RogueInstCountNotRight = 1100272,
    ErrorCode_RogueInstFightFormationNotConfig = 1100273,
    ErrorCode_RogueTrialRoleNotValid = 1100274,
    ErrorCode_RogueRoleNotValid = 1100275,
    ErrorCode_ErrorBlackFlowerEntityNotRight = 1100276,
    ErrorCode_ErrorBlackFlowerStatus = 1100277,
    ErrorCode_ErrorBlackFlowerCanNotReward = 1100278,
    ErrorCode_ErrorBlackFlowerRewardFail = 1100279,
    ErrorCode_ErrorPhantomUnlockError = 1100280,
    ErrorCode_ErrorPhantomSwitchError = 1100281,
    ErrorCode_ActivityConfigNotFind = 1100282,
    ErrorCode_ActivityNotOpen = 1100283,
    ErrorCode_DirectTrainActivityConfigNotFind = 1100284,
    ErrorCode_ActivityTypeNotFind = 1100285,
    ErrorCode_SetGlobalVarFail = 1100286,
    ErrorCode_ErrMultigame = 1100287,
    ErrorCode_RogueWeeklyCycleNoFind = 1100288,
    ErrorCode_RogueWeeklyCycleIdNotMatch = 1100289,
    ErrorCode_RogueWeeklyCycleInstIdNotMatch = 1100290,
    ErrorCode_RogueWeeklyCycleSexNotMatch = 1100291,
    ErrorCode_RogueWeeklyCycleActivityIdNotMatch = 1100292,
    ErrorCode_RogueWeeklyCycleAwardNotFind = 1100293,
    ErrorCode_RogueWeeklyCycleAwardStateNotMatch = 1100294,
    ErrorCode_RogueWeeklyInstResultFail = 1100295,
    ErrorCode_RogueWeeklyGoldNoEnough = 1100296,
    ErrorCode_HasRogueProgressCanNotChangeSex = 1100297,
    ErrorCode_RogueWeeklyWorldLevelNotMatch = 1100298,
    ErrorCode_ResourceVersionIsTooLowWithTips = 1100299,
    ErrorCode_RogueResInstIdNotMatch = 1100300,
    ErrorCode_RogueResInstGridConfigNotFind = 1100301,
    ErrorCode_RogueResInBossInst = 1100302,
    ErrorCode_RogueResCurGridIsNull = 1100303,
    ErrorCode_RogueResPathCountFail = 1100304,
    ErrorCode_RogueResPathRepeat = 1100305,
    ErrorCode_RogueResPathGridNoNear = 1100306,
    ErrorCode_RogueResPathGridNoValid = 1100307,
    ErrorCode_RogueResPathGridNoVision = 1100308,
    ErrorCode_RogueResPathGridBlock = 1100309,
    ErrorCode_RogueResPlayerBanMove = 1100310,
    ErrorCode_RogueResHasOp = 1100311,
    ErrorCode_RogueResTrialRoleNotFind = 1100312,
    ErrorCode_RogueResTrialRoleNoValid = 1100313,
    ErrorCode_RogueResThemeConfNotFind = 1100314,
    ErrorCode_RogueResCrossInstDataIsNull = 1100315,
    ErrorCode_RogueResOpEmpty = 1100316,
    ErrorCode_RogueResOpNotMatch = 1100317,
    ErrorCode_RogueResCollectionConfNotFind = 1100318,
    ErrorCode_RogueResCollectionStateErr = 1100319,
    ErrorCode_RogueResEndingAwardConfNotFind = 1100320,
    ErrorCode_RogueResEndingAwardIsReceived = 1100321,
    ErrorCode_RogueResEndingAwardNotFinish = 1100322,
    ErrorCode_RogueResTalentConfNotFind = 1100323,
    ErrorCode_RogueResTaskConfNotFind = 1100324,
    ErrorCode_RogueResTaskDatanotFind = 1100325,
    ErrorCode_RogueResTaskAwardIsReceived = 1100326,
    ErrorCode_RogueResTaskAwardNotFinish = 1100327,
    ErrorCode_RogueResEffectConfNoFind = 1100328,
    ErrorCode_RogueResOptionNoRestCount = 1100329,
    ErrorCode_RogueResOptionCantMulti = 1100330,
    ErrorCode_RogueResOptionRepeat = 1100331,
    ErrorCode_RogueResOptionCantGiveUp = 1100332,
    ErrorCode_RogueResOptionCantRefresh = 1100333,
    ErrorCode_RogueResOptionIndexNoValid = 1100334,
    ErrorCode_RogueResOptionTypeError = 1100335,
    ErrorCode_RogueResOptionIsSelect = 1100336,
    ErrorCode_RogueResCollectionIndexMax = 1100337,
    ErrorCode_RogueResCollectionDropConfigNoFind = 1100338,
    ErrorCode_RogueResNoBaseGainLogic = 1100339,
    ErrorCode_RogueResGridAwardNoConf = 1100340,
    ErrorCode_RogueResBornPositionNoConf = 1100341,
    ErrorCode_RogueResEffectExecFail = 1100342,
    ErrorCode_RogueResOptionFinish = 1100343,
    ErrorCode_RogueResOpTypeErr = 1100344,
    ErrorCode_RogueResGridEventNoConf = 1100345,
    ErrorCode_RogueResGridEventStepNoConf = 1100346,
    ErrorCode_RogueResStepOptionNoValid = 1100347,
    ErrorCode_RogueResGridEventNoData = 1100348,
    ErrorCode_RogueResSelectIndexNoValid = 1100349,
    ErrorCode_RogueResGotoNextRoomNoData = 1100350,
    ErrorCode_RogueResSelectOpNoData = 1100351,
    ErrorCode_RogueResBranchTaskNoConf = 1100352,
    ErrorCode_RogueResBranchTaskNoData = 1100353,
    ErrorCode_RogueResBranchTaskIsReceive = 1100354,
    ErrorCode_RogueResBranchTaskNoFinish = 1100355,
    ErrorCode_RogueResTokenShopPriceErr = 1100356,
    ErrorCode_RogueResTaskTypeErr = 1100357,
    ErrorCode_RogueRandomNoPoolName = 1100358,
    ErrorCode_RogueRandomNoHit = 1100359,
    ErrorCode_RogueRandomNoValidResult = 1100360,
    ErrorCode_RogueResFormationIdNoValid = 1100361,
    ErrorCode_RogueResFormationRoleCountErr = 1100362,
    ErrorCode_RogueResRandomNoShopGoods = 1100363,
    ErrorCode_RogueResRandomShopGoodsNoEnough = 1100364,
    ErrorCode_RogueResFormationRoleNoValid = 1100365,
    ErrorCode_RogueResFormationNoData = 1100366,
    ErrorCode_RogueResGainRoleNoFind = 1100367,
    ErrorCode_RogueResGainRoleLvNoConf = 1100368,
    ErrorCode_RogueResGainRoleLvNoLv = 1100369,
    ErrorCode_RogueResGainRoleNoBuffPool = 1100370,
    ErrorCode_RogueResGainRoleNoMaxlv = 1100371,
    ErrorCode_RogueResGainRoleRollEffectNoValid = 1100372,
    ErrorCode_RogueResGainRoleRollRetNoMatch = 1100373,
    ErrorCode_RogueResGainRoleShopNoConf = 1100374,
    ErrorCode_RogueResGainRoleRollEmpty = 1100375,
    ErrorCode_RogueResGainRoleBondNoValid = 1100376,
    ErrorCode_RogueResRoleBuffGuaranteeFail = 1100377,
    ErrorCode_RogueResRoleBuffNoMore = 1100378,
    ErrorCode_RogueResRoleBuffRandomFail = 1100379,
    ErrorCode_RogueRoleShopRollFail = 1100380,
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
    ErrorCode_NewbieCarnivalTaskTaken = 1100403,
    ErrorCode_NewbieCarnivalTaskRunning = 1100404,
    ErrorCode_ErrShopFixeNotExist = 1100405,
    ErrorCode_ErrShopBankNoExist = 1100406,
    ErrorCode_ErrShopBankNoMatch = 1100407,
    ErrorCode_ErrPayShopBuyCountOverFlow = 1100408,
    ErrorCode_ErrShopBuyCountOverFlow = 1100409,
    ErrorCode_EnergyOverFlow = 1100410,
    ErrorCode_EnergyNotEnough = 1100411,
    ErrorCode_StoreEnergyNotEnough = 1100412,
    ErrorCode_ErrPayShopBuyLimitCondition = 1100413,
    ErrorCode_ErrPayShopEchoItemOver2 = 1100414,
    ErrorCode_ErrPayShopEchoItemOver3 = 1100415,
    ErrorCode_ErrPayShopEchoItemOver4 = 1100416,
    ErrorCode_CreateReceiptCoreParamError = 1100417,
    ErrorCode_ReceiptsDealCloseCoreParamError = 1100418,
    ErrorCode_ReceiptsRefundCloseCoreParamError = 1100419,
    ErrorCode_CreateReceiptCoreException = 1100420,
    ErrorCode_ReceiptsDealCloseCoreException = 1100421,
    ErrorCode_ReceiptsRefundCloseCoreFail = 1100422,
    ErrorCode_ReceiptsRefundCloseCoreException = 1100423,
    ErrorCode_ErrPayConfigClientCantBuy = 1100424,
    ErrorCode_RecyclePersonalGiftNoData = 1100425,
    ErrorCode_ErrPersonalGiftBuyLimit = 1100426,
    ErrorCode_CreateReceiptNoConf = 1100427,
    ErrorCode_CreateReceiptFail = 1100428,
    ErrorCode_ReceiptDealCloseNoData = 1100429,
    ErrorCode_ReceiptDealClosePlayerIdUnMatch = 1100430,
    ErrorCode_ReceiptCannotDealClose = 1100431,
    ErrorCode_ReceiptDealCloseFail = 1100432,
    ErrorCode_ReceiptRefundCloseNoData = 1100433,
    ErrorCode_ReceiptRefundClosePlayerIdUnMatch = 1100434,
    ErrorCode_ReceiptCannotRefundClose = 1100435,
    ErrorCode_ReceiptRefundCloseFail = 1100436,
    ErrorCode_ReceiptRefundNoData = 1100437,
    ErrorCode_CreateReceiptParamError = 1100438,
    ErrorCode_CreateReceiptException = 1100439,
    ErrorCode_ReceiptsDealCloseParamError = 1100440,
    ErrorCode_ReceiptsDealCloseException = 1100441,
    ErrorCode_ReceiptRefundCloseParamError = 1100442,
    ErrorCode_ReceiptRefundCloseException = 1100443,
    ErrorCode_ReceiptRefundParamError = 1100444,
    ErrorCode_UpdateRogueWeeklyArtifactsFail = 1100445,
    ErrorCode_RogueWeeklyArtifactsEmpty = 1100446,
    ErrorCode_RogueWeeklyArtifactsIndexErr = 1100447,
    ErrorCode_RogueResSkipBattleLvNoEnough = 1100448,
    ErrorCode_RogueResCanNotSkipBattle = 1100449,
    ErrorCode_RogueResRandomGridNoConf = 1100450,
    ErrorCode_StrangerHostCount = 1100451,
    ErrorCode_SurvivorsNotInitOp = 1100452,
    ErrorCode_SurvivorsNotSelectOp = 1100453,
    ErrorCode_SurvivorsNoRoleAndWeapon = 1100454,
    ErrorCode_SurvivorsRandomEmpty = 1100455,
    ErrorCode_SurvivorsOptionEmpty = 1100456,
    ErrorCode_SurvivorsSelectEmpty = 1100457,
    ErrorCode_SurvivorsRandomGuaranteedEmpty = 1100458,
    ErrorCode_SurvivorsLevelNoConf = 1100459,
    ErrorCode_SurvivorsWeaponPoolEmpty = 1100460,
    ErrorCode_SurvivorsWeaponEmpty = 1100461,
    ErrorCode_SurvivorsGoldNoEnough = 1100462,
    ErrorCode_SurvivorsWeaponMax = 1100463,
    ErrorCode_SurvivorsNoSupportGiveUp = 1100464,
    ErrorCode_SurvivorsNoRestSelectCount = 1100465,
    ErrorCode_SurvivorsNoSupportMultiSelect = 1100466,
    ErrorCode_SurvivorsRepeatSelect = 1100467,
    ErrorCode_SurvivorsComponentNoFind = 1100468,
    ErrorCode_SurvivorsOpNotFind = 1100469,
    ErrorCode_SurvivorsSelectErr = 1100470,
    ErrorCode_SurvivorsNoVar = 1100471,
    ErrorCode_SurvivorsInstIdErr = 1100472,
    ErrorCode_SurvivorsInstLock = 1100473,
    ErrorCode_SurvivorsInstNotTime = 1100474,
    ErrorCode_SurvivorsInstNoEndlessMode = 1100475,
    ErrorCode_SurvivorsNeedContinue = 1100476,
    ErrorCode_SurvivorsLevelCantUseRole = 1100477,
    ErrorCode_SurvivorsLevelCantUseWeapon = 1100478,
    ErrorCode_SurvivorsRoleNoMatch = 1100479,
    ErrorCode_SurvivorsStepErr1 = 1100480,
    ErrorCode_SurvivorsStepErr2 = 1100481,
    ErrorCode_SurvivorsStepErr3 = 1100482,
    ErrorCode_SurvivorsCantBuy = 1100483,
    ErrorCode_SurvivorsRoleLvNoConf = 1100484,
    ErrorCode_SurvivorsWeaponLvNoConf = 1100485,
    ErrorCode_SurvivorsRoleNoFind = 1100486,
    ErrorCode_SurvivorsWaponNoFind = 1100487,
    ErrorCode_SurvivorsItemNoFind = 1100488,
    ErrorCode_SurvivorsRoleLvMax = 1100489,
    ErrorCode_SurvivorsWeaponLvMax = 1100490,
    ErrorCode_SurvivorsRefreshOpFail = 1100491,
    ErrorCode_SurvivorsWeightEmpty = 1100492,
    ErrorCode_SurvivorsActivityNoData = 1100493,
    ErrorCode_SurvivorsRefreshCostFail = 1100494,
    ErrorCode_SurvivorsNoLastInstData = 1100495,
    ErrorCode_SurvivorsActivityNoConf = 1100496,
    ErrorCode_SurvivorsTalentNoConf = 1100497,
    ErrorCode_SurvivorsTaskCountMax = 1100498,
    ErrorCode_SurvivorsTaskNoConf = 1100499,
    ErrorCode_SurvivorsTaskCantReward = 1100500,
    ErrorCode_SurvivorsTaskRepeat = 1100501,
    ErrorCode_SurvivorsTaskEmpty = 1100502,
    ErrorCode_SurvivorsAllLock = 1100503,
    ErrorCode_RogueResNoGlobalConf = 1100504,
    ErrorCode_RogueResLimitedRoles = 1100505,
    ErrorCode_SurvivorsNeedPassNormalMode = 1100506,
    ErrorCode_SurvivorsOptionIsSelect = 1100507,
    ErrorCode_SurvivorsTalentTreeConditionNotMet = 1100508,
    ErrorCode_SurvivorsTalentTreePerNodeLock = 1100509,
    ErrorCode_SurvivorsTalentTreeNodeMaxLevel = 1100510,
    ErrorCode_SurvivorsTalentTreeConsumeNoEnough = 1100511,
    ErrorCode_ShortMessageNoConf = 1100512,
    ErrorCode_ShortMessageOptionNoConf = 1100513,
    ErrorCode_ShortMessageNoData = 1100514,
    ErrorCode_ShortMessageNoData2 = 1100515,
    ErrorCode_ShortMessageIsRead = 1100516,
    ErrorCode_ShortMessageNoMatch = 1100517,
    ErrorCode_ShortMessageNoReply = 1100518,
    ErrorCode_ShortMessageIsReply = 1100519,
    ErrorCode_ShortMessageNoReward = 1100520,
    ErrorCode_ShortMessageIsReward = 1100521,
    ErrorCode_ShortMessageNoFinish = 1100522,
    ErrorCode_ErrorPhantomCollectMax = 1100523,
    ErrorCode_ErrorPhantomCollectRepeated = 1100524,
    ErrorCode_ErrorPhantomCollectLock = 1100525,
    ErrorCode_ErrorNoSceneComp = 1100526,
    ErrorCode_ErrorNewTowerIsInChallenge = 1100527,
    ErrorCode_ErrorNewTowerIsNoChallenge = 1100528,
    ErrorCode_ErrorNewTowerLevelIdNotMatch = 1100529,
    ErrorCode_ErrorNewTowerLevelNoConf = 1100530,
    ErrorCode_ErrorNewTowerCycleNoConf = 1100531,
    ErrorCode_ErrorNewTowerLevelNoData = 1100532,
    ErrorCode_ErrorNewTowerNoTeamCache = 1100533,
    ErrorCode_ErrorNewTowerNoIndexTeamCache = 1100534,
    ErrorCode_ErrorNewTowerScoreRewardMax = 1100535,
    ErrorCode_ErrorNewTowerScoreNoConf = 1100536,
    ErrorCode_ErrorNewTowerScoreRepeat = 1100537,
    ErrorCode_ErrorNewTowerScoreEmpty = 1100538,
    ErrorCode_ErrorNewTowerCycleNoInTime = 1100539,
    ErrorCode_ErrorNewTowerCurCycleNoConf = 1100540,
    ErrorCode_ErrorNewTowerCycleNoLevel = 1100541,
    ErrorCode_ErrorNewTowerTeamIndexErr = 1100542,
    ErrorCode_ErrorNewTowerTeamMax = 1100543,
    ErrorCode_ErrorNewTowerBuffMax = 1100544,
    ErrorCode_ErrorNewTowerBuffRepeat = 1100545,
    ErrorCode_ErrorNewTowerRoleRepeat = 1100546,
    ErrorCode_ErrorNewTowerRoleEmpty = 1100547,
    ErrorCode_ErrorNewTowerRoleNoMatch = 1100548,
    ErrorCode_ErrorNewTowerRoleMax = 1100549,
    ErrorCode_ErrorNewTowerBuffNoMatch = 1100550,
    ErrorCode_ErrorNewTowerRoleNoEnergy = 1100551,
    ErrorCode_ErrorNewTowerWaveNoInfo = 1100552,
    ErrorCode_ErrorNewTowerWaveFinish = 1100553,
    ErrorCode_ErrorShortMessageNoOpen = 1100554,
    ErrorCode_ErrorShortMessageOptionMax = 1100555,
    ErrorCode_ErrorShortMessageBubbleNoData = 1100556,
    ErrorCode_ErrorShortMessageBubbleNoConf = 1100557,
    ErrorCode_ErrorShortMessageChatBgNoData = 1100558,
    ErrorCode_ErrorShortMessageChatBgNoConf = 1100559,
    ErrorCode_ErrorNewTowerInstStateErr = 1100560,
    ErrorCode_ErrorNewTowerRoleWeaponPhantom = 1100561,
    ErrorCode_ErrorNewTowerNoTeamData = 1100562,
    ErrorCode_ErrorNewTowerNoCacheSet = 1100563,
    ErrorCode_ErrorNewTowerRoleWeaponNoMatch = 1100564,
    ErrorCode_ErrorNewTowerRolePhantomNoMatch = 1100565,
    ErrorCode_ShortMessageOptionNoConf2 = 1100566,
    ErrorCode_ShortMessageOptionNoConf3 = 1100567,
    ErrorCode_ErrorNewTowerEntityNoFind = 1100568,
    ErrorCode_ErrorNewTowerSeasonAwardNoConf = 1100569,
    ErrorCode_ErrorNewTowerSeasonNoConf = 1100570,
    ErrorCode_ErrorNewTowerSeasonNotOpen = 1100571,
    ErrorCode_ErrorNewTowerSeasonAwardRepeat = 1100572,
    ErrorCode_ErrorNewTowerSeasonAwardEmpty = 1100573,
    ErrorCode_NewTowerNoLastCycleIdReview = 1100574,
    ErrorCode_NewTowerNoActivityData = 1100575,
    ErrorCode_NewTowerNoHistoryData = 1100576,
    ErrorCode_ErrorNewTowerSeasonAwardTimeout = 1100577,
    ErrorCode_ErrChatNotFriendNorOnline = 1200000,
    ErrorCode_ErrChatContentFilterFailed = 1200001,
    ErrorCode_ErrChatLockState = 1200002,
    ErrorCode_ErrChatEmojiNotValid = 1200003,
    ErrorCode_ErrChatSendTooFast = 1200004,
    ErrorCode_ErrChatMuteNotValidId = 1200005,
    ErrorCode_ErrBanChatDefault = 1200006,
    ErrorCode_ErrRoleQuestFuncNotOpen = 1200007,
    ErrorCode_ErrRoleQuestMaxCount = 1200008,
    ErrorCode_ErrRoleQuestUnlockPointNotEnough = 1200009,
    ErrorCode_ErrDailyQuestNotFoundArea = 1200010,
    ErrorCode_ErrDailyQuestNotFoundInfluence = 1200011,
    ErrorCode_ErrDailyQuestRewardAlreadyGet = 1200012,
    ErrorCode_ErrDailyQuestDataError = 1200013,
    ErrorCode_ErrDailyQuestCantGetReward = 1200014,
    ErrorCode_ErrEntityBuffProducerStateError = 1200015,
    ErrorCode_ErrEntityBuffProducerNotFound = 1200016,
    ErrorCode_ErrVoiceRemainChangeRoleNotInFormation = 1200017,
    ErrorCode_ErrVoiceRemainChangeRoleNotAlive = 1200018,
    ErrorCode_ErrApplyEffectFail = 1300000,
    ErrorCode_ErrOutofBattleTargetNotMonster = 1300001,
    ErrorCode_ErrMonsterBoomEntityNotExists = 1300002,
    ErrorCode_ErrMonsterBoomNotMonster = 1300003,
    ErrorCode_ErrMonsterBoomIsDead = 1300004,
    ErrorCode_ErrAnimationStateSpecialFuncException = 1300005,
    ErrorCode_ErrPayConfigNotFound = 1400000,
    ErrorCode_ErrPayCreateReceiptFail = 1400001,
    ErrorCode_ErrPayReceiptNotFound = 1400002,
    ErrorCode_ErrPayReceiptPlayerIdUnMatch = 1400003,
    ErrorCode_ErrPayReceiptCannotDealClose = 1400004,
    ErrorCode_ErrPayReceiptDealCloseFail = 1400005,
    ErrorCode_ErrPayNotEnable = 1400006,
    ErrorCode_ErrPayDataChanged = 1400007,
    ErrorCode_ErrPayUpdateReceiptFail = 1400008,
    ErrorCode_ErrGachaConfigNotFound = 1400009,
    ErrorCode_ErrGachaRuleGroupConfigNotFound = 1400010,
    ErrorCode_ErrGachaRulesNotFound = 1400011,
    ErrorCode_ErrGachaTypeKnowns = 1400012,
    ErrorCode_ErrGachaDailyTimesLimit = 1400013,
    ErrorCode_ErrGachaTotalTimesLimit = 1400014,
    ErrorCode_ErrGachaDailyTotalTimesLimit = 1400015,
    ErrorCode_ErrGachaIsNotOpen = 1400016,
    ErrorCode_ErrGachaIsNotInOpenTime = 1400017,
    ErrorCode_ErrGachaFuncIsNotOpen = 1400018,
    ErrorCode_ErrItemExchageConfigNotFound = 1400019,
    ErrorCode_ErrItemExchageDailyTimesLimit = 1400020,
    ErrorCode_ErrItemExchangeTotalTimesLimit = 1400021,
    ErrorCode_ErrGachaLimitNotFound = 1400022,
    ErrorCode_ErrGachaLimitsEmpty = 1400023,
    ErrorCode_ErrTextServerTimeout = 1400024,
    ErrorCode_ErrTextServerResFail = 1400025,
    ErrorCode_ErrTextServerResEmpty = 1400026,
    ErrorCode_ErrTextServerResException = 1400027,
    ErrorCode_ErrItemExchageParamError = 1400028,
    ErrorCode_ErrBattlePassFuncIsNotOpen = 1400029,
    ErrorCode_ErrPayShopFuncIsNotOpen = 1400030,
    ErrorCode_ErrGachaPoolConfigNotFound = 1400031,
    ErrorCode_ErrGachaPoolIsNotOpen = 1400032,
    ErrorCode_ErrGachaPoolIsNotInOpenTime = 1400033,
    ErrorCode_ErrGachaPoolLimitNotFound = 1400034,
    ErrorCode_ErrGachaPoolNotBelongToGacha = 1400035,
    ErrorCode_ErrGachaUsePoolIdNotSet = 1400036,
    ErrorCode_ErrGachaTimesNonsupport = 1400037,
    ErrorCode_ErrGachaFrontRuleGroupNotFinish = 1400038,
    ErrorCode_ErrGachaRuleGroupFinish = 1400039,
    ErrorCode_ErrPayGiftBuyLimit = 1400040,
    ErrorCode_ErrPayGiftTypeUnknown = 1400041,
    ErrorCode_ErrPayGiftNotInSellTime = 1400042,
    ErrorCode_ErrBattlePassBuyLevelLimit = 1400043,
    ErrorCode_ErrBattlePassBuyLevelError = 1400044,
    ErrorCode_ErrJsFileNotFound = 1400045,
    ErrorCode_ErrPayReceiptIsRefunded = 1400046,
    ErrorCode_ErrPayReceiptIsNotPay = 1400047,
    ErrorCode_ErrPayReceiptRefundFail = 1400048,
    ErrorCode_ErrPayGiftLocked = 1400049,
    ErrorCode_ErrPayGiftBuyConditionLimit = 1400050,
    ErrorCode_ErrMapMarkConfigIdNotExist = 1400051,
    ErrorCode_ErrTreasureSlotMarkNotExist = 1400052,
    ErrorCode_ErrTreasureBoxMarkNotExist = 1400053,
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
    ErrorCode_ErrGachaPersonalPermissionExpired = 1400074,
    ErrorCode_ErrPayGiftVersionConfigNotFound = 1400075,
    ErrorCode_ErrPayGiftSelfDefineVersionError = 1400076,
    ErrorCode_ErrInfoDisplayId = 1500000,
    ErrorCode_ErrItemAlreadyInCd = 1500001,
    ErrorCode_ErrCantFinAdventureConfig = 1500002,
    ErrorCode_ErrAdventureRewardReceived = 1500003,
    ErrorCode_ErrAdventureTaskCache = 1500004,
    ErrorCode_ErrAdventureState = 1500005,
    ErrorCode_ErrAdventureRewardOrder = 1500006,
    ErrorCode_ErrAdventureChapterState = 1500007,
    ErrorCode_ErrCantDetectRepeat = 1500008,
    ErrorCode_ErrNotInCurrentFollowList = 1500009,
    ErrorCode_ErrCantDetectOtherDetectionType = 1500010,
    ErrorCode_ErrNotSelectCurrentDetectionId = 1500011,
    ErrorCode_ErrDetectionConfigNotFound = 1500012,
    ErrorCode_ErrDetectionListCantBeEmpty = 1500013,
    ErrorCode_ErrCantFindAnyDetectionTarget = 1500014,
    ErrorCode_ErrCantFindTurntableComponentEntity = 1500015,
    ErrorCode_ErrHaveNoTurntableControlComponent = 1500016,
    ErrorCode_ErrCantFindLevitationMagnetComponentEntity = 1500017,
    ErrorCode_ErrHaveNoLevitaionMagnetComponent = 1500018,
    ErrorCode_ErrCantFindBoardEntity = 1500019,
    ErrorCode_ErrCantFindPlacementEntity = 1500020,
    ErrorCode_ErrHaveNoPlacementComponent = 1500021,
    ErrorCode_ErrCantFindBoardEntityComponent = 1500022,
    ErrorCode_ErrBoardHaveNoAnyPlacement = 1500023,
    ErrorCode_ErrBoardNotActiveAllGrid = 1500024,
    ErrorCode_ErrNeedBeControlledBefore = 1500025,
    ErrorCode_ErrPlaceFailOfAlreadyOnBoard = 1500026,
    ErrorCode_ErrInvalidBoardPosition = 1500027,
    ErrorCode_ErrNeedRemoveControlRelation = 1500028,
    ErrorCode_ErrNotOccupyOnBoard = 1500029,
    ErrorCode_ErrHaveNoFillRule = 1500030,
    ErrorCode_ErrGridPosAlreadyOccupied = 1500031,
    ErrorCode_ErrHaveNoJigsawFoundationConfig = 1500032,
    ErrorCode_ErrInvalidGridPos = 1500033,
    ErrorCode_ErrGridPosAlreadyActive = 1500034,
    ErrorCode_ErrCantPlaceItemOnBoard = 1500035,
    ErrorCode_ErrNeedJigsawFoundationComponentWhenBeControlled = 1500036,
    ErrorCode_ErrHaveNoBoardComponentConfig = 1500037,
    ErrorCode_ErrNeedJigsawItemComponentWhenBeControlled = 1500038,
    ErrorCode_ErrCantFindOriginBoardEntity = 1500039,
    ErrorCode_ErrDistanceNotInRangeBetweenEntity = 1500040,
    ErrorCode_ErrJigsawFoundationIsAlreadySilent = 1500041,
    ErrorCode_ErrCrystalEntityNotFound = 1500042,
    ErrorCode_ErrGachaBoardEntityNotFound = 1500043,
    ErrorCode_ErrNotCrystalEntity = 1500044,
    ErrorCode_ErrNotGachaFoundationEntity = 1500045,
    ErrorCode_ErrGachaHoleIsFull = 1500046,
    ErrorCode_ErrJigsawItemSilent = 1500047,
    ErrorCode_ErrThrowDamageConfigNotExists = 1500048,
    ErrorCode_ErrThrowDamageComponetNotExists = 1500049,
    ErrorCode_ErrEggNotMatchEggFoundation = 1500050,
    ErrorCode_ProgressBarEntityNotFound = 1500051,
    ErrorCode_NotProgressBarEntity = 1500052,
    ErrorCode_ProgressBarIsSilent = 1500053,
    ErrorCode_ScenePlayerInfoNotFound = 1500054,
    ErrorCode_PlayerNotInAnyScene = 1500055,
    ErrorCode_TeleportNotInValidDistance = 1500056,
    ErrorCode_AddMapMarkInfoLackOfTeleportParam = 1500057,
    ErrorCode_TemporaryTeleportNotExists = 1500058,
    ErrorCode_ErrNotHostPlayer = 1500059,
    ErrorCode_ErrMarkIdNotExists = 1500060,
    ErrorCode_ErrCantUpdateTemporaryTeleportMarkInfo = 1500061,
    ErrorCode_NotHostCantAddTemporaty = 1500062,
    ErrorCode_TemporaryTeleportPosIsNotWalkable = 1500063,
    ErrorCode_BadTemporaryTeleportConfig = 1500064,
    ErrorCode_HaveNoTemporaryTeleportComponent = 1500065,
    ErrorCode_ErrCantDetectAtInvalidPoint = 1500066,
    ErrorCode_ErrNotDetectionTreasureBoxBefore = 1500067,
    ErrorCode_ErrJigsawFoundationIsCompleteCantModifyGridState = 1500068,
    ErrorCode_GridIsActiveCantSwitchState = 1500069,
    ErrorCode_GridIsOccupiedCantSwitchState = 1500070,
    ErrorCode_ErrHaveNoBaseInfoComponent = 1500071,
    ErrorCode_ErrHaveNoParentEntity = 1500072,
    ErrorCode_NotRelationEntity = 1500073,
    ErrorCode_ErrLevelPlayNotRunning = 1500074,
    ErrorCode_ErrStateCantChangeWhenLifeCycleDestroy = 1500075,
    ErrorCode_ErrRangeEntityIdNotFoundWhenForbidTempTeleport = 1500076,
    ErrorCode_TemporaryTeleportIsForbidden = 1500077,
    ErrorCode_ErrGravityGearIsComplete = 1500078,
    ErrorCode_ErrInvalidRoleWhenUpdatePassiveSkill = 1500079,
    ErrorCode_ErrInvalidRolePassiveSkillId = 1500080,
    ErrorCode_ErrPassiveSkillNotAddBuff = 1500081,
    ErrorCode_ErrPassiveSkillCantSpecifyBuff = 1500082,
    ErrorCode_ErrPassiveSkillAddBuffFail = 1500083,
    ErrorCode_ErrPassiveSkillAddBulletFail = 1500084,
    ErrorCode_ErrBuffCreatePassiveSkillFail = 1500085,
    ErrorCode_ErrInvalidPreContext = 1500086,
    ErrorCode_ErrBadPassiveSkillId = 1500087,
    ErrorCode_ErrPassiveSkillComponentNotFound = 1500088,
    ErrorCode_ErrRepeatePassiveSkill = 1500089,
    ErrorCode_ErrBadPassiveSkillTriggerType = 1500090,
    ErrorCode_ErrAddPassiveSkillFailOfEntityNotFound = 1500091,
    ErrorCode_ErrEntityNotClientControlWhenAddPassiveSkill = 1500092,
    ErrorCode_ErrEntityNotClientControlWhenRemovePassiveSkill = 1500093,
    ErrorCode_ErrPassiveSkillNotFoundWhenRemovePassiveSkill = 1500094,
    ErrorCode_ErrRepeatedBattleContext = 1500095,
    ErrorCode_ErrPassiveSkillAddSkillFail = 1500096,
    ErrorCode_ErrCombatSendPackAbnormal = 1500097,
    ErrorCode_ErrContextCheckFail = 1500098,
    ErrorCode_ErrFsmComponentNotFound = 1500099,
    ErrorCode_ErrFsmCreateContextFail = 1500100,
    ErrorCode_ErrFsmStateBehaviorPreMessageCantBeZero = 1500101,
    ErrorCode_ErrFsmBehaviorCheckBattleContextFail = 1500102,
    ErrorCode_ErrFsmPlayMontageLackPreMessage = 1500103,
    ErrorCode_ErrFsmPlayMontageCheckContextFail = 1500104,
    ErrorCode_ErrFsmPlayMontageConfigCheckFail = 1500105,
    ErrorCode_ErrSkillFlowNotExist = 1500106,
    ErrorCode_ErrGetReportDataOverLimit = 1500107,
    ErrorCode_ErrGetReportDataTooFast = 1500108,
    ErrorCode_ErrNotInAnyScene = 1500109,
    ErrorCode_ErrAceLogDataNotFound = 1500110,
    ErrorCode_ErrAceLogDataRepeatReport = 1500111,
    ErrorCode_ErrAceInvalidLogId = 1500112,
    ErrorCode_ErrAceSceneGlobalObjNotFound = 1500113,
    ErrorCode_ErrAceBadParam = 1500114,
    ErrorCode_ErrS2CConfirmIdNotExists = 1500115,
    ErrorCode_ErrPassiveSkillConfigNotFound = 1500116,
    ErrorCode_ErrNotBehaviorController = 1500117,
    ErrorCode_ErrPlayMontageFail = 1500118,
    ErrorCode_ErrFightDataInConsistent = 1500119,
    ErrorCode_ErrNotInAoiSight = 1500120,
    ErrorCode_ErrPassiveSkillNotOwner = 1500121,
    ErrorCode_ErrReportStartFirstly = 1500122,
    ErrorCode_ErrBattleEntityNotFound = 1500123,
    ErrorCode_ErrBattleCampNotDefined = 1500124,
    ErrorCode_ErrOtherInternalError = 1500125,
    ErrorCode_ErrHaventBattleComponent = 1500126,
    ErrorCode_ErrLackCombinePartInfoParam = 1500127,
    ErrorCode_ErrCombinerEntityNotExists = 1500128,
    ErrorCode_ErrTargetEntityNotExists = 1500129,
    ErrorCode_ErrTargetPartNotExists = 1500130,
    ErrorCode_ErrCombineComponentNotExists = 1500131,
    ErrorCode_ErrAlreadyCombineToOtherEntity = 1500132,
    ErrorCode_ErrLackCombinerOffsetPos = 1500133,
    ErrorCode_ErrLackCombinerOffsetRotate = 1500134,
    ErrorCode_ErrCombineEntityNotFound = 1500135,
    ErrorCode_ErrDissolveCheckBattleContextFail = 1500136,
    ErrorCode_ErrRepeatedRole = 1500137,
    ErrorCode_ErrNotStateMachineBehavior = 1500138,
    ErrorCode_ErrDiscardMsgWhenChangeSceneMultiMode = 1500140,
    ErrorCode_ErrMayOccurDbAbnormal = 1500139,
    ErrorCode_ErrEntityLivingStatusNotifyCheckFsmPlayMontageOfFsmGroupConfigNotExists = 1500141,
    ErrorCode_ErrEntityLivingStatusNotifyCheckFsmPlayMontageOfConfigNotExists = 1500142,
    ErrorCode_ErrEntityLivingStatusNotifyCheckFsmPlayMontageFail = 1500143,
    ErrorCode_ErrFsmActionCheckFsmPlayMontageFail = 1500144,
    ErrorCode_ErrFsmActionCheckSkillFail = 1500145,
    ErrorCode_ErrFsmActionCheckBufflFail = 1500146,
    ErrorCode_ErrFsmPlayMontageCheckAnParamError = 1500147,
    ErrorCode_ErrFsmPlayMontageCheckAnMontageConfigNotFound = 1500148,
    ErrorCode_ErrFsmPlayMontageCheckAnMontageFail = 1500149,
    ErrorCode_ErrMontageConfigNotFound = 1500150,
    ErrorCode_ErrANConfigNotFound = 1500151,
    ErrorCode_ErrBulletConfigNotFound = 1500152,
    ErrorCode_ErrFsmVersion = 1500153,
    ErrorCode_ErrUpdateFightRoleRepeated = 1500154,
    ErrorCode_TrialRoleEntityOverLimit = 1500155,
    ErrorCode_ErrHaveNoRoleInfos = 1500156,
    ErrorCode_ErrTeamHaveNoAnyRoles = 1500157,
    ErrorCode_ErrSkillMontageNotNormalMontage = 1500158,
    ErrorCode_ErrMontageContextConfigNotFound = 1500159,
    ErrorCode_ErrMontageContextCheckAnFail = 1500160,
    ErrorCode_ErrLivingStatusContextCheckPlayMontageContextFail = 1500161,
    ErrorCode_ErrContextHaveNoFsmGroupConfig = 1500162,
    ErrorCode_ErrLivingStatusContextFsmGroupConfigNotFound = 1500163,
    ErrorCode_ErrFsmActionCheckPlayEntityMontageFail = 1500164,
    ErrorCode_ErrMontageContext1CheckPlayEntityMontageFail = 1500165,
    ErrorCode_ErrCombatSkillGAHandleGetEntityFailed = 1600000,
    ErrorCode_ErrCombatMaterialHandleGetEntityFailed = 1600001,
    ErrorCode_ErrCombatParticleHandleGetEntityFailed = 1600002,
    ErrorCode_ErrCombatPartLifeChangeEntityNotExisted = 1600003,
    ErrorCode_ErrCombatCreateBulletTargetNotExisted = 1600004,
    ErrorCode_ErrCombatDeleteBulletTargetNotExisted = 1600005,
    ErrorCode_ErrCombatDeleteBulletGetEntityFailed = 1600006,
    ErrorCode_ErrCombatBulletTargetNoExist = 1600007,
    ErrorCode_ErrPartEntityNotExisted = 1600008,
    ErrorCode_ErrNoAiControlRights = 1600009,
    ErrorCode_ErrAiHateComponent = 1600010,
    ErrorCode_ErrSummonerPlayerControl = 1600011,
    ErrorCode_ErrConfDamageNotFound = 1600012,
    ErrorCode_ErrProcessDamageFailed = 1600013,
    ErrorCode_ErrInjuryFreeLandingTag = 1600014,
    ErrorCode_ErrNotFindActiveGameplayEffect = 1600015,
    ErrorCode_NotClientControlBuff = 1600016,
    ErrorCode_ErrBuffNoEffectConf = 1600017,
    ErrorCode_ErrBuffCannotCreateBullet = 1600018,
    ErrorCode_ErrBuffCannotCreateBuff = 1600019,
    ErrorCode_ErrNoBuffConf = 1600020,
    ErrorCode_ErrStoppedAi = 1600021,
    ErrorCode_ErrEntityIsNotAlive = 1600022,
    ErrorCode_ErrSummonCannotSwitchAiControl = 1600023,
    ErrorCode_ErrAiControlNotChange = 1600024,
    ErrorCode_ErrPlayerCannotControlEntity = 1600025,
    ErrorCode_ErrNotFoundBuffEffect = 1600026,
    ErrorCode_ErrBuffEffectAuthority = 1600027,
    ErrorCode_ErrConcomitantDestroy = 1600028,
    ErrorCode_ErrPlayerFollowersComponent = 1600029,
    ErrorCode_ErrBuffComponentNotExist = 1600030,
    ErrorCode_ErrOrderApplyBuffFailed = 1600031,
    ErrorCode_ErrPlayerBuff = 1600032,
    ErrorCode_ErrFindPathNoEndPos = 1600033,
    ErrorCode_ErrNotGetCurRole = 1600034,
    ErrorCode_ErrFindPathFailed = 1600035,
    ErrorCode_ErrEntityFsmMachineNotExist = 1700000,
    ErrorCode_ErrEntityFsmStateIncorrect = 1700001,
    ErrorCode_ErrIsNotAiControler = 1700002,
    ErrorCode_ErrIEntityFsmCantTransit = 1700003,
    ErrorCode_ErrIEntityFsmTransitCondition = 1700004,
    ErrorCode_ErrIEntityFsmTransitToState = 1700005,
    ErrorCode_ErrIEntityFsmConfirmNotExist = 1700006,
    ErrorCode_ErrIEntityFsmConfirmNotWait = 1700007,
    ErrorCode_ErrITest = 1700008,
    ErrorCode_ErrITest1 = 1700009,
    ErrorCode_ErrITest2 = 1700010,
    ErrorCode_ErrIEntityFsmCondCantPass = 1700011,
    ErrorCode_ErrIEntityFsmActionParamType = 1700012,
    ErrorCode_ErrIEntityFsmActionParam = 1700013,
    ErrorCode_ErrIEntityFsmActionExecuted = 1700014,
    ErrorCode_ErrIEntityFsmActionNotMatchState = 1700015,
    ErrorCode_ErrSkillNotExecuting = 1700016,
    ErrorCode_ErrExecuteSkillNotMatch = 1700017,
    ErrorCode_ErrBlueprintPinNotSupport = 1700018,
    ErrorCode_ErrBlueprintPinNotMontage = 1700019,
    ErrorCode_ErrBlueprintPinMontageIndex = 1700020,
    ErrorCode_ErrConfSkillNotExist = 1700021,
    ErrorCode_ErrSkillGANotExist = 1700022,
    ErrorCode_ErrSkillGAHaveNoBuff = 1700023,
    ErrorCode_ErrSkillGAHaveNoBuffId = 1700024,
    ErrorCode_ErrSkillGAHaveNoBullet = 1700025,
    ErrorCode_ErrSkillGAHaveNoBulletId = 1700026,
    ErrorCode_ErrMontageNotMatchSkill = 1700027,
    ErrorCode_ErrMontageIndexError = 1700028,
    ErrorCode_ErrVisiionSkillNotEquip = 1700029,
    ErrorCode_ErrSkillCD = 1700030,
    ErrorCode_ErrHaveNoBattleContext = 1700031,
    ErrorCode_ErrContextFsmActionOnce = 1700032,
    ErrorCode_ErrPlayMontageButNoSkill = 1700033,
    ErrorCode_ErrMontageNotExist = 1700034,
    ErrorCode_ErrMontageNotContainBuff = 1700035,
    ErrorCode_ErrMontageNotContainBullet = 1700036,
    ErrorCode_ErrMontageCantBring = 1700037,
    ErrorCode_ErrSkillInfoParamError = 1700038,
    ErrorCode_ErrNoWorldTeam = 1800000,
    ErrorCode_ErrWorldTeamNoMember = 1800001,
    ErrorCode_ErrNoHostIs = 1800002,
    ErrorCode_ErrNoInstId = 1800003,
    ErrorCode_ErrNoTeamInfo = 1800004,
    ErrorCode_ErrHostNoTeamInfo = 1800005,
    ErrorCode_ErrHasInMatchTeam = 1800006,
    ErrorCode_ErrNotInMatchTeam = 1800007,
    ErrorCode_ErrHostIsParam = 1800008,
    ErrorCode_ErrMatchModeIParam = 1800009,
    ErrorCode_ErrMatchTeamFull = 1800010,
    ErrorCode_ErrLocalTeamCanNotOpt = 1800011,
    ErrorCode_ErrHostInLocalTeam = 1800012,
    ErrorCode_ErrNoMatchNodeId = 1800013,
    ErrorCode_ErrPlayerSceneIsNull = 1800014,
    ErrorCode_ErrPlayerSceneRolesNull = 1800015,
    ErrorCode_ErrInvalidMatchState = 1800016,
    ErrorCode_ErrRepeatedMatchState = 1800017,
    ErrorCode_ErrApplyrPlayerInMatchNotEnterMatchTeam = 1800018,
    ErrorCode_ErrOtherVersionLowNoOperate = 1800019,
    ErrorCode_ErrPlayerVersionLowNeedUpdate = 1800020,
    ErrorCode_ErrMultiGameModeNoWorldLevelDown = 1800021,
    ErrorCode_ErrMultiGameModeNoWorldLevelRegain = 1800022,
    ErrorCode_ErrOtherHasOnline = 1800023,
    ErrorCode_SwitchRoleNotInCurrentFormation = 1800024,
    ErrorCode_ErrNoChangeRoles = 1800025,
    ErrorCode_ErrExploreSkillPullGiantMultiGame = 1800026,
    ErrorCode_ErrExploreSkillPullGiantNotExist = 1800027,
    ErrorCode_ErrHttpRpcParam = 1800028,
    ErrorCode_ErrPlayerNotInGameNode = 1800029,
    ErrorCode_ErrApplyJoinPlayerCurRoleIsDead = 1800030,
    ErrorCode_ErrPlayerCurRoleIsDeadNoJoin = 1800031,
    ErrorCode_ErrPlayerCurRoleIsDead = 1800032,
    ErrorCode_ErrSwitchMultiverse = 1800033,
    ErrorCode_ErrSwitchNode = 1800034,
    ErrorCode_ErrMatchConfirmPlayerDead = 1800035,
    ErrorCode_ErrCheckPublicResourceVersionLower = 1800036,
    ErrorCode_ErrCheckPublicResourceVersionHigher = 1800037,
    ErrorCode_ErrCheckPublicResourceClientVersionErr = 1800038,
    ErrorCode_ErrCheckPublicResourceServerVersionErr = 1800039,
    ErrorCode_ErrCheckPublicResourceClientVersionParamErr = 1800040,
    ErrorCode_ErrCheckClientVersionNeedUpdate = 1800041,
    ErrorCode_ErrBranchNameNotMatch = 1800042,
    ErrorCode_ErrMatchRpcAlready = 1800043,
    ErrorCode_ErrOtherPlayerEnterHost = 1800044,
    ErrorCode_ErrPlayerEnterHost = 1800045,
    ErrorCode_ErrLevelPlayChangeSprotModeInMutile = 1800046,
    ErrorCode_ErrMatchingNotInvite = 1800047,
    ErrorCode_ErrEnableFunctionFB = 1800048,
    ErrorCode_ErrMatchSelectTrialRole = 1800049,
    ErrorCode_ErrNoFindLastBigScene = 1800050,
    ErrorCode_ErrExploreSkillCustomMultiGame = 1800051,
    ErrorCode_ErrExploreSkillCustomNotExist = 1800052,
    ErrorCode_ErrMatchInviteMemberDead = 1800053,
    ErrorCode_ErrMatchAcceptInviteMemberDead = 1800054,
    ErrorCode_ErrNoFishBoat = 1800055,
    ErrorCode_ErrTemplateNotExists = 1800056,
    ErrorCode_ErrDisableSubLevels = 1800058,
    ErrorCode_ErrSubLevelsClientNoPermission = 1800059,
    ErrorCode_ErrExploreSkillCustomNoActions = 1800057,
    ErrorCode_ErrMatchClientVersion = 1800060,
    ErrorCode_ErrCurNodeIsTainted = 1800061,
    ErrorCode_ErrTeamMateNodeIsTainted = 1800062,
    ErrorCode_ErrMapFuctionNotOpen = 1800063,
    ErrorCode_ErrNotSceneOwner = 1800064,
    ErrorCode_ErrLevelPlayUiListIsNull = 1800065,
    ErrorCode_ErrOpenLevelPlayNotClientUi = 1800066,
    ErrorCode_ErrOpenLevelPlayFailed = 1800067,
    ErrorCode_ErrBlackSwordChallengeId = 1800068,
    ErrorCode_ErrCalabashLevelRequest = 1900000,
    ErrorCode_ErrCalabashLevelRewardDone = 1900001,
    ErrorCode_ErrCalabashLevelConfig = 1900002,
    ErrorCode_ErrSkillTreeActiveConsume = 1900003,
    ErrorCode_ErrLoadFriendData = 1900004,
    ErrorCode_ErrNoLoadPrivateChatData = 1900005,
    ErrorCode_ErrNotInWolrd = 1900006,
    ErrorCode_ErrNotInGround = 1900007,
    ErrorCode_ErrInFighting = 1900008,
    ErrorCode_ErrNotHaveCountryAccess = 1900009,
    ErrorCode_ErrSkillIsEffect = 1900010,
    ErrorCode_ErrNoSoundBox = 1900011,
    ErrorCode_ErrConsumeNotEnough = 1900012,
    ErrorCode_ErrExploreSkillCountLimit = 1900013,
    ErrorCode_ErrLegalAreaNoTreasureBox = 1900014,
    ErrorCode_ErrTreasureBoxAllActive = 1900015,
    ErrorCode_ExploreProgressNoCountry = 1900016,
    ErrorCode_ExploreProgressNoScoreCfg = 1900017,
    ErrorCode_ExploreProgressLackProgress = 1900018,
    ErrorCode_ExploreProgressRewardDone = 1900019,
    ErrorCode_ExploreProgressNoArea = 1900020,
    ErrorCode_ExploreToolNotConfirm = 1900021,
    ErrorCode_ExploreToolNotOpen = 1900022,
    ErrorCode_ErrTreasureBoxPlaceFail = 1900023,
    ErrorCode_ErrTreasureBoxData = 1900024,
    ErrorCode_ErrPayShopBuyCondition = 1900025,
    ErrorCode_ErrGatherActivityData = 1900026,
    ErrorCode_ErrGatherTaskNoFinish = 1900027,
    ErrorCode_ErrHadGatherReward = 1900028,
    ErrorCode_ErrHadGetSharedReward = 1900029,
    ErrorCode_ErrSharedPlat = 1900030,
    ErrorCode_ErrTowerTargetComplete = 1900031,
    ErrorCode_ErrTowerGuideRewardHad = 1900032,
    ErrorCode_ErrTowerGuideNoOpen = 1900033,
    ErrorCode_ErrTowerGuideConfig = 1900034,
    ErrorCode_ErrNewBieCourseConfig = 1900035,
    ErrorCode_ErrNewBieCourseRewardHad = 1900036,
    ErrorCode_ErrNewBieCourseLevel = 1900037,
    ErrorCode_ErrDetectionTargetSilence = 1900038,
    ErrorCode_ErrRoleTrialNotInit = 1900039,
    ErrorCode_ErrRoleTrialNoFinish = 1900040,
    ErrorCode_ErrRoleTrialReward = 1900041,
    ErrorCode_ErrRoleTrialRewardDone = 1900042,
    ErrorCode_ErrAdventureTaskReward = 1900043,
    ErrorCode_ErrChapterReward = 1900044,
    ErrorCode_ErrSilentFirstPassStatus = 1900045,
    ErrorCode_ErrSilentFirstPassReward = 1900046,
    ErrorCode_ErrPayShopEchoRole = 1900047,
    ErrorCode_ErrPayShopEchoItemOver = 1900048,
    ErrorCode_ErrDailyAdventureActivityInit = 1900049,
    ErrorCode_ErrDailyAdventureActivityPtEnough = 1900050,
    ErrorCode_ErrDailyAdventureActivityRewardDone = 1900051,
    ErrorCode_ErrDailyAdventureActivityRewardTake = 1900052,
    ErrorCode_ErrDailyAdventureActivityTaskDone = 1900053,
    ErrorCode_ErrRoleTrialTimeOut = 1900054,
    ErrorCode_ErrFriendRemarkNull = 1900055,
    ErrorCode_ErrTrackMoonRoleUnLock = 1900056,
    ErrorCode_ErrTrackMoonTrigger = 1900057,
    ErrorCode_ErrTrackMoonBuildingUnLock = 1900058,
    ErrorCode_ErrTrackMoonBuildingCurve = 1900059,
    ErrorCode_ErrTrackMoonBuildingLock = 1900060,
    ErrorCode_ErrMoonEntrustCfg = 1900061,
    ErrorCode_ErrMoonRoleCfg = 1900062,
    ErrorCode_ErrMoonRoleTrailCurve = 1900063,
    ErrorCode_ErrMoonBuildingCfg = 1900064,
    ErrorCode_ErrMoonItemConsume = 1900065,
    ErrorCode_ErrDirtyWordDeserialize = 1900066,
    ErrorCode_ErrMoonTargetNoFinish = 1900067,
    ErrorCode_ErrMoonActivityReward = 1900068,
    ErrorCode_ErrMoonActivityOpen = 1900069,
    ErrorCode_ErrCircumDoReward = 1900070,
    ErrorCode_ErrRetrunRewardCfg = 1900071,
    ErrorCode_ErrRetrunRewardLevel = 1900072,
    ErrorCode_ErrRetrunHaddone = 1900073,
    ErrorCode_ErrSignRewardCfg = 1900074,
    ErrorCode_ErrCircumSignHadRwd = 1900075,
    ErrorCode_ErrCircumNoSign = 1900076,
    ErrorCode_ErrScoreRewardCfg = 1900077,
    ErrorCode_ErrCircumScoreHadRwd = 1900078,
    ErrorCode_ErrCircumScoreLack = 1900079,
    ErrorCode_ErrCircumTaskNoFinish = 1900080,
    ErrorCode_LoginServiceInvalidToken = 1900081,
    ErrorCode_LoginFusing = 1900082,
    ErrorCode_LoginRateLimiterRejected = 1900083,
    ErrorCode_LoginTimeoutRejected = 1900084,
    ErrorCode_AccountInputErr = 1900085,
    ErrorCode_DevInvalidLoginType = 1900086,
    ErrorCode_GARInvalidLoginType = 1900087,
    ErrorCode_GARDevInvalidLoginType = 1900088,
    ErrorCode_SdkserverTimeOut = 1900089,
    ErrorCode_ReconnectInvalidOperation = 1900090,
    ErrorCode_PbMessageAppVersionNotMatch = 1900091,
    ErrorCode_ErrPluginReconnectIpWhiteList = 1900092,
    ErrorCode_NotInUserIdWhiteListWithChannel = 1900093,
    ErrorCode_ErrPluginReconnectChannelWhiteList = 1900094,
    ErrorCode_PluginPlayerLoggingIn = 1900095,
    ErrorCode_LoginFusing2 = 1900096,
    ErrorCode_SoundBoxExploreFull = 1900097,
    ErrorCode_ErrMoonEntrustNoData = 1900098,
    ErrorCode_ErrMoonMoneyNotEnough = 1900099,
    ErrorCode_ErrCircumFluenceTimeIn = 1900100,
    ErrorCode_DragonPoolRewardWayErr = 1900101,
    ErrorCode_DragonPoolNoHandIn = 1900102,
    ErrorCode_WeaponSkinNoEquiped = 1900103,
    ErrorCode_WeaponSkinDataErr = 1900104,
    ErrorCode_WeaponSkinUnLockErr = 1900105,
    ErrorCode_WeaponSkinEquipDone = 1900106,
    ErrorCode_WeaponSkinTypeErr = 1900107,
    ErrorCode_FriendOfflineMsgErr = 1900108,
    ErrorCode_FindSpringSignConfigErr = 1900109,
    ErrorCode_SpringSignDataErr = 1900110,
    ErrorCode_SpringSignRewardDone = 1900111,
    ErrorCode_SpringSignRewardGetErr = 1900112,
    ErrorCode_SpringSignNoOpen = 1900113,
    ErrorCode_SpringSignNoTask = 1900114,
    ErrorCode_SpringSignInviteNum = 1900115,
    ErrorCode_SpringSignRolePool = 1900116,
    ErrorCode_SpringSignDrawPoolNull = 1900117,
    ErrorCode_FarmGoldActivityNotOpen = 1900118,
    ErrorCode_FarmGoldActivityPointReceived = 1900119,
    ErrorCode_FarmGoldActivityPointNotConfig = 1900120,
    ErrorCode_FarmGoldActivityPointNotEnough = 1900121,
    ErrorCode_FarmGoldActivityLevelNoData = 1900122,
    ErrorCode_FarmGoldActivityLevelReceived = 1900123,
    ErrorCode_FarmGoldActivityLevelNotConfig = 1900124,
    ErrorCode_FarmGoldActivityLevelDiffNotConfig = 1900125,
    ErrorCode_FarmGoldInstIdInValid = 1900126,
    ErrorCode_FarmGoldVarNotExist = 1900127,
    ErrorCode_FarmGoldResultCacheNotExist = 1900128,
    ErrorCode_FarmGoldInstNotOpen = 1900129,
    ErrorCode_FarmGoldActivityLimitDataNotFind = 1900130,
    ErrorCode_MapTravelDataErr = 1900131,
    ErrorCode_MapTravelConfigErr = 1900132,
    ErrorCode_MapTravelCannotReward = 1900133,
    ErrorCode_MapTravelRewardGet = 1900134,
    ErrorCode_MapTravelMaxLevel = 1900135,
    ErrorCode_MapTravelLackExp = 1900136,
    ErrorCode_FarmGoldLevelNotOpen = 1900137,
    ErrorCode_MapTravelAreaLock = 1900138,
    ErrorCode_MapTravelAreaConfigErr = 1900139,
    ErrorCode_SlashAndTowerCacheErr = 1900142,
    ErrorCode_SlashAndTowerConfigErr = 1900143,
    ErrorCode_SlashAndTowerDataErr = 1900144,
    ErrorCode_SlashAndTowerReceivedLevelAward = 1900145,
    ErrorCode_SlashAndTowerNotReward = 1900146,
    ErrorCode_SlashAndTowerRoleNum = 1900147,
    ErrorCode_SlashAndTowerBuffNum = 1900148,
    ErrorCode_SlashAndTowerBuffConfig = 1900149,
    ErrorCode_SlashAndTowerBuffAccess = 1900150,
    ErrorCode_SlashAndTowerRoleSame = 1900151,
    ErrorCode_SlashAndTowerSeasonErr = 1900152,
    ErrorCode_SlashAndTowerBuffLack = 1900153,
    ErrorCode_MapTravelLevelUpCfgErr = 1900140,
    ErrorCode_MapTravelLevelCfgErr = 1900141,
    ErrorCode_TeamParkOurTaskCfgErr = 1900154,
    ErrorCode_TeamParkOurDataErr = 1900155,
    ErrorCode_TeamParkOurCfgNoMatch = 1900156,
    ErrorCode_TeamParkOurTaskDoing = 1900157,
    ErrorCode_TeamParkOurTaskTaken = 1900158,
    ErrorCode_TeamParkOurLevelLock = 1900159,
    ErrorCode_TeamParkOurFindNoLevel = 1900160,
    ErrorCode_SlashAndTowerRewardErr = 1900161,
    ErrorCode_SlashAndTowerBuffSeasonErr = 1900162,
    ErrorCode_SlashAndTowerNotOpen = 1900163,
    ErrorCode_SlashAndTowerSeasonToCfgErr = 1900164,
    ErrorCode_SlashAndTowerSeasonNoUpdate = 1900165,
    ErrorCode_SlashAndTowerFirstNoPass = 1900166,
    ErrorCode_SlashAndTowerLevelErr = 1900167,
    ErrorCode_TeamParkMemberErr = 1900168,
    ErrorCode_AvignonNotOpen = 1900172,
    ErrorCode_AvignonNotConfig = 1900173,
    ErrorCode_AvignonTaskNotFinish = 1900174,
    ErrorCode_AvignonTaskNotData = 1900175,
    ErrorCode_AvignonHadReward = 1900176,
    ErrorCode_SlashAndTowerTeamErr = 1900169,
    ErrorCode_SlashAndTowerBuffErr = 1900170,
    ErrorCode_SeasonTowerNoMatch = 1900171,
    ErrorCode_TeamParkOurMemberErr = 1900177,
    ErrorCode_BattlePassRewardDone = 1900178,
    ErrorCode_SlashAndTowerAwardCfgErr = 1900179,
    ErrorCode_NoFlySkinItem = 1900180,
    ErrorCode_FlySkinHadWear = 1900181,
    ErrorCode_NoOldFlySkinItem = 1900182,
    ErrorCode_OldFlySkinNoWear = 1900183,
    ErrorCode_RoleWearNoFlySkin = 1900184,
    ErrorCode_FlySkinParaGliderNoOpen = 1900185,
    ErrorCode_FlySkinSoaringWingNoOpen = 1900186,
    ErrorCode_NoRoleWearFlySkinSucc = 1900187,
    ErrorCode_FlySkinItemNoConfig = 1900188,
    ErrorCode_SlashAndTowerLevelSettle = 1900189,
    ErrorCode_FlySkinTypeErr = 1900190,
    ErrorCode_FlySkinTrialRole = 1900191,
    ErrorCode_RegreeNotOpen = 1900192,
    ErrorCode_RegressNoConfig = 1900193,
    ErrorCode_RegressWrongId = 1900194,
    ErrorCode_NoRegressRoundData = 1900195,
    ErrorCode_NotInRegress = 1900196,
    ErrorCode_AskRewardNoFinish = 1900197,
    ErrorCode_BirthdayNotArrived = 1900198,
    ErrorCode_BirthdayRoleInvalid = 1900199,
    ErrorCode_BirthdayNoCfg = 1900200,
    ErrorCode_HadBirthDayReward = 1900201,
    ErrorCode_BirthdayNoReset = 1900202,
    ErrorCode_BirthDayRewardTimeInvalid = 1900203,
    ErrorCode_BirthdayMustNowYear = 1900204,
    ErrorCode_BirthDayNotOpen = 1900205,
    ErrorCode_BirthDayRewardNotFinish = 1900206,
    ErrorCode_BirthdayRoleDone = 1900207,
    ErrorCode_MoraleNoRewardGet = 1900208,
    ErrorCode_FloroNoRanchData = 1900209,
    ErrorCode_FloroNoRanchTech = 1900210,
    ErrorCode_FloroTechUnLock = 1900211,
    ErrorCode_FloroPreNodeLock = 1900212,
    ErrorCode_FloroTechPoint = 1900213,
    ErrorCode_FloroNoFindActivityTask = 1900214,
    ErrorCode_FloroNoFindTaskCfg = 1900215,
    ErrorCode_FloroTaskIsRunning = 1900216,
    ErrorCode_FloroTaskInValidTime = 1900217,
    ErrorCode_FloroRewardDone = 1900218,
    ErrorCode_FloroMilestoneNoFind = 1900219,
    ErrorCode_FloroDropNoFind = 1900220,
    ErrorCode_FloroNoReward = 1900221,
    ErrorCode_FloroActivityParamErr = 1900222,
    ErrorCode_ConditionTimeOut = 1900223,
    ErrorCode_ConditionModuleErr = 1900224,
    ErrorCode_ConditionGroupIdErr = 1900225,
    ErrorCode_ConditionRegisterFail = 1900226,
    ErrorCode_FloroRanchSetAgain = 1900227,
    ErrorCode_MoonPhaseNoOpen = 1900228,
    ErrorCode_MoonPhaseNoCount = 1900229,
    ErrorCode_ErrRandomDone = 1900230,
    ErrorCode_PhaseMoonRandomErr = 1900231,
    ErrorCode_PhaseMoonCfgErr = 1900232,
    ErrorCode_MoonLabelErr = 1900233,
    ErrorCode_MoonPhaseRewardErr = 1900234,
    ErrorCode_MoonPhaseRewardDone = 1900235,
    ErrorCode_PhaseMoonItemErr = 1900236,
    ErrorCode_MoonPhaseBuffFail = 1900237,
    ErrorCode_CoopRoleMaxLevelErr = 1900238,
    ErrorCode_CoopRoleNoUnLock = 1900239,
    ErrorCode_CoopRoleSpRewradErr = 1900240,
    ErrorCode_CoopRoleRewardErr = 1900241,
    ErrorCode_NoRewardCanGain = 1900242,
    ErrorCode_CoopRoleDataErr = 1900243,
    ErrorCode_CoopIdErr = 1900244,
    ErrorCode_MotorcycleMotorIpErr = 1900245,
    ErrorCode_MotorcycleRewardEmpty = 1900246,
    ErrorCode_RoadBookNotData = 1900247,
    ErrorCode_RoadBookNotInOpen = 1900248,
    ErrorCode_RoadBookTaskCannotReward = 1900249,
    ErrorCode_RoadBookRewardHad = 1900250,
    ErrorCode_RoadBookOverMaxLevel = 1900251,
    ErrorCode_RoadBookCfgErr = 1900252,
    ErrorCode_RoadBookTaskLock = 1900253,
    ErrorCode_RoadBookChallengeScoreErr = 1900254,
    ErrorCode_RoadBookDuplicateReward = 1900255,
    ErrorCode_RoadBookNoRewardGet = 1900256,
    ErrorCode_GuessJokerLevelErr = 1900257,
    ErrorCode_GuessJokerNotInScene = 1900258,
    ErrorCode_GuessJokerNotGameObj = 1900259,
    ErrorCode_GuessJokerPlayCardErr = 1900260,
    ErrorCode_GuessJokerActionPhaseErr = 1900261,
    ErrorCode_GuessJokerDeckErr = 1900262,
    ErrorCode_GuessJokerNoHandCard = 1900263,
    ErrorCode_GuessJokerBanCard = 1900264,
    ErrorCode_GuessJokerOnlyPair = 1900265,
    ErrorCode_GuessJokerPairAll = 1900266,
    ErrorCode_GuessJokerCardRefuse = 1900267,
    ErrorCode_GuessJokerDrawCardErr = 1900268,
    ErrorCode_JokerSkillTriggerFail = 1900269,
    ErrorCode_JokerSkillNoConfig = 1900270,
    ErrorCode_JokerSkillOwnerErr = 1900271,
    ErrorCode_GuessJokerPlayCardOver = 1900272,
    ErrorCode_GuessJokerPlayCardAgain = 1900273,
    ErrorCode_JokerGuessLevelLock = 1900274,
    ErrorCode_JokerGuessPreLevelLock = 1900275,
    ErrorCode_GuessJokerInitErr = 1900276,
    ErrorCode_NoDrinkRequireListConfig = 1900277,
    ErrorCode_DrinkBaseCountError = 1900278,
    ErrorCode_DrinkBaseNoConfig = 1900279,
    ErrorCode_DrinkBatchingCountErr = 1900280,
    ErrorCode_DrinkBatchingConfigErr = 1900281,
    ErrorCode_DrinkOrnaNoConfig = 1900282,
    ErrorCode_DrinkRoleLikeNoConfig = 1900283,
    ErrorCode_DrinkLikePointErr = 1900284,
    ErrorCode_GuessJokerScriptPlayErr = 1900285,
    ErrorCode_GuessJokerScriptDrawErr = 1900286,
    ErrorCode_GuessJokerNoPlayerWait = 1900287,
    ErrorCode_GuessJokerSkillUseOver = 1900288,
    ErrorCode_DrinkBatchingRepeate = 1900289,
    ErrorCode_SpringFestivalNoReward = 1900290,
    ErrorCode_SpringFestivalDropNoFind = 1900291,
    ErrorCode_SpringFestivalTaskRunning = 1900292,
    ErrorCode_SpringFestivalHadReward = 1900293,
    ErrorCode_SpringFestivalActivityIdErr = 1900294,
    ErrorCode_SpringFestivalTaskFindErr = 1900295,
    ErrorCode_SpringFestivalNoActivityCfg = 1900296,
    ErrorCode_SpringFestivalParamCountErr = 1900297,
    ErrorCode_SpringFestivalParamAgainErr = 1900298,
    ErrorCode_PayShopGoodsIdRepeatErr = 1900299,
    ErrorCode_PayShopBindActivityErr = 1900300,
    ErrorCode_PayShopActivityFromErr = 1900301,
    ErrorCode_PayShopFromErr = 1900302,
    ErrorCode_ErrPayShopGoodsTypeCountOverFlow = 1900303,
    ErrorCode_ErrPayShopTotalCountOverFlow = 1900304,
    ErrorCode_ErrRegressDevelopTask = 1900305,
    ErrorCode_ErrRegressVersion = 1900306,
    ErrorCode_DrinksLevelLock = 1900307,
    ErrorCode_DrinksRoleInviteErr = 1900308,
    ErrorCode_DrinksNoRoleData = 1900309,
    ErrorCode_GuessJokerTraceOver = 1900310,
    ErrorCode_GuessJokerDataErr = 1900311,
    ErrorCode_GuessJokerTaskRunning = 1900312,
    ErrorCode_GuessJokerTaskDone = 1900313,
    ErrorCode_DrinksRewardTaskRunning = 1900314,
    ErrorCode_DrinksRewardTaskDone = 1900315,
    ErrorCode_CoopReqLenthOver = 1900316,
    ErrorCode_CoopRewardIdErr = 1900317,
    ErrorCode_CoopRewardConfigNotFind = 1900318,
    ErrorCode_CoopRewardDiff = 1900319,
    ErrorCode_CoopActivityDataErr = 1900320,
    ErrorCode_CoopRewardDone = 1900321,
    ErrorCode_CoopRewardNoFinish = 1900322,
    ErrorCode_CoopItemDropErr = 1900323,
    ErrorCode_CoopItemDropErr2 = 1900324,
    ErrorCode_ErrDoCommonRewardConfigError = 2000000,
    ErrorCode_InstPlayNotSettle = 2000001,
    ErrorCode_InstPlayNotFinishExecute = 2000002,
    ErrorCode_ErrResetItemEntityNotContain = 2000003,
    ErrorCode_InstPlayExchangeRewardNotExist = 2000004,
    ErrorCode_MapConfigNull = 2000005,
    ErrorCode_MapConfigError = 2000006,
    ErrorCode_InstPlayComponentNotExist = 2000007,
    ErrorCode_InstTeleportResetPlayerDead = 2000008,
    ErrorCode_DrownEndTeleportInBigWorld = 2000009,
    ErrorCode_ErrFightTrialRoleRoldIdsError = 2000010,
    ErrorCode_ErrFightTrialRoleFromationError = 2000011,
    ErrorCode_ErrInstSaveFail = 2000012,
    ErrorCode_ErrActiveFoundationControlPlayerError = 2000013,
    ErrorCode_ErrActiveFoundationOccupation = 2000014,
    ErrorCode_ErrSingleInstanceCanNotOnline = 2000015,
    ErrorCode_ErrInstanceRechallengeLimit = 2000016,
    ErrorCode_ErrTargetSame = 2000017,
    ErrorCode_ErrAttachTargetType = 2000018,
    ErrorCode_ErrAttachInfoNull = 2000019,
    ErrorCode_ErrLevelPlayChallengeFail = 2000020,
    ErrorCode_ErrGMTip = 2000021,
    ErrorCode_ErrPosSenderEntityNoExist = 2000022,
    ErrorCode_ErrPosSenderComponentNoExist = 2000023,
    ErrorCode_ErrPosSenderParamError = 2000024,
    ErrorCode_ErrPosSenderRemoveSenderNotSame = 2000025,
    ErrorCode_ErrConnectorEntityNoExist = 2000026,
    ErrorCode_ErrConnectorCompNoExist = 2000027,
    ErrorCode_ErrConnectorPreIdError = 2000028,
    ErrorCode_ErrConnectorCompleteState = 2000029,
    ErrorCode_ErrConnectorActiveStateError = 2000030,
    ErrorCode_ErrConnectorMatchErro = 2000031,
    ErrorCode_ErrActiveControlOccupation = 2000032,
    ErrorCode_ErrPortalCreatorActive = 2000033,
    ErrorCode_ErrComponentNull = 2000034,
    ErrorCode_ErrPortalCreatorConfigError = 2000035,
    ErrorCode_ErrPortalCreatorCreateFail = 2000036,
    ErrorCode_ErrTrialRoleEnterInst = 2000037,
    ErrorCode_ErrNpcInVehicle = 2000038,
    ErrorCode_ErrSceneItemBBNotChange = 2000039,
    ErrorCode_ErrInitMatchNotSuccess = 2000040,
    ErrorCode_ErrFightFormationSameRoleError = 2000041,
    ErrorCode_ErrFightMainRoleConflict = 2000042,
    ErrorCode_ErrVehicleItemConfigError = 2000043,
    ErrorCode_ErrVehicleCreateError = 2000044,
    ErrorCode_ErrVehicleEntityTypeError = 2000045,
    ErrorCode_ErrInstanceActivityExpire = 2000046,
    ErrorCode_ErrSlashAndTowerLevelUnlock = 2000047,
    ErrorCode_ErrInstLevelUnlock = 2000048,
    ErrorCode_ErrEnterInstConfigError = 2000049,
    ErrorCode_ErrMoveWithSplineConfigError = 2000050,
    ErrorCode_ErrMoveWithSplineIdError = 2000051,
    ErrorCode_ErrMoveWithSplineStop = 2000052,
    ErrorCode_ErrMoveWithSplineEntityConfigError = 2000053,
    ErrorCode_ErrMoveWithSplineControlPlayerError = 2000054,
    ErrorCode_ErrLeaveSceneStarted = 2000055,
    ErrorCode_ErrInstTeleportInstLimit = 2000056,
    ErrorCode_ErrGetOnVehicleNotInAoiSight = 2000057,
    ErrorCode_ErrHoldHandCharacterNotCurrent = 2000058,
    ErrorCode_ErrEnterInstPreInstNotComplete = 2000059,
    ErrorCode_ErrSetSystemVarError = 2000060,
    ErrorCode_ErrSetVarPermission = 2000061,
    ErrorCode_ErrSetVarCtxError = 2000062,
    ErrorCode_ErrSetVarGameCtxSceneError = 2000063,
    ErrorCode_ErrSetVarNotPublic = 2000064,
    ErrorCode_ErrSetVarComponent = 2000065,
    ErrorCode_ErrSetVarTargetNull = 2000066,
    ErrorCode_ErrVehicleNotMotor = 2000067,
    ErrorCode_ErrVehicleFormationError = 2000068,
    ErrorCode_ErrShareRideConflict = 2000069,
    ErrorCode_ErrShareRideNotExist = 2000070,
    ErrorCode_ErrNotInShareRide = 2000071,
    ErrorCode_ErrNotInVehicle = 2000072,
    ErrorCode_ErrSceneRoadGraphNotExist = 2000073,
    ErrorCode_ErrVehicleFlowRewardMax = 2000074,
    ErrorCode_ErrGetOnVehicleFailInFlow = 2000075,
    ErrorCode_ErrGetOnPlayerVechielGravityDifferent = 2000076,
    ErrorCode_ErrChangeFightState = 2100000,
    ErrorCode_ErrAddFragileFail = 2100001,
    ErrorCode_ErrStoreEnergyClose = 2100002,
    ErrorCode_ErrAttrOverMax = 2100003,
    ErrorCode_ErrBattleVersion = 2100004,
    ErrorCode_ErrGmkillEntityNotValid = 2200000,
    ErrorCode_ErrSplineConfigNotExist = 2200001,
    ErrorCode_BossRushActivityNotOpen = 2200002,
    ErrorCode_BossRushActivityScoreRewardNotExist = 2200003,
    ErrorCode_BossRushActivityLevelRewardNotExist = 2200004,
    ErrorCode_BossRushActivityScoreNotEnough = 2200005,
    ErrorCode_BossRushActivityLevelNotPass = 2200006,
    ErrorCode_BossRushActivityRewardClaimed = 2200007,
    ErrorCode_BossRushActivityBuffSelectionNotValid = 2200008,
    ErrorCode_BossRushActivityConfigNotExist = 2200009,
    ErrorCode_BossRushActivityCharacterSelectionNotValid = 2200010,
    ErrorCode_BossRushActivityComponentNotExist = 2200011,
    ErrorCode_BossRushActivityCharacterSelectionEmpty = 2200012,
    ErrorCode_BossRushActivityBuffSelectionEmpty = 2200013,
    ErrorCode_BossRushActivityLevelNotOpen = 2200014,
    ErrorCode_InRangeEntityDuplicate = 2200015,
    ErrorCode_InRangeEntityNotExist = 2200016,
    ErrorCode_NpcPerformComponentNotExist = 2200017,
    ErrorCode_NpcPerformStateNotInit = 2200018,
    ErrorCode_NpcPerformActionTargetEntityNotExist = 2200019,
    ErrorCode_ActionQueueTypeNotExist = 2200020,
    ErrorCode_ActionQueueCtxTypeNotExist = 2200021,
    ErrorCode_ExecuteQueueOwnerHasAction = 2200022,
    ErrorCode_ActionQueueExceedMaxCount = 2200023,
    ErrorCode_ActionQueueStartActionGroupFail = 2200024,
    ErrorCode_ActionQueueComponentNotExist = 2200025,
    ErrorCode_ActionQueueNotInit = 2200026,
    ErrorCode_ChangeBatchEntitiesStateError = 2200027,
    ErrorCode_EnableNearbyTrackingTargetEntityNotExist = 2200028,
    ErrorCode_EnableNearbyTrackingSelfNotEntity = 2200029,
    ErrorCode_EnableNearbyTrackingSelfComponentNotExist = 2200030,
    ErrorCode_SetTeleControlEntityNotExist = 2200031,
    ErrorCode_SetTeleControlTypeNotExist = 2200032,
    ErrorCode_SetTeleControlComponentNotExist = 2200033,
    ErrorCode_SetTeleControlCoordEntityNotExist = 2200034,
    ErrorCode_SceneItemAttributeIdNotInType = 2200035,
    ErrorCode_SceneItemAttributeIdNotExist = 2200036,
    ErrorCode_ModifySceneItemAttributeEntityNotExist = 2200037,
    ErrorCode_AddSceneItemAttributeTagDuplicate = 2200038,
    ErrorCode_RemoveSceneItemAttributeTagNotExist = 2200039,
    ErrorCode_AttributeEntityLock = 2200040,
    ErrorCode_AttributeEntitySilent = 2200041,
    ErrorCode_ModifySceneItemAttributeTagNotExist = 2200042,
    ErrorCode_ErrEnterInstCtx = 2200043,
    ErrorCode_ErrEnterInstBlackboardValueNotExist = 2200044,
    ErrorCode_TriggerLocked = 2200045,
    ErrorCode_TriggerIgnore = 2200046,
    ErrorCode_TriggerEntityNull = 2200047,
    ErrorCode_TriggerEntityNotMatch = 2200048,
    ErrorCode_TriggerMatchCountNotMet = 2200049,
    ErrorCode_TriggerActionEmpty = 2200050,
    ErrorCode_ExceedMaxTriggerCount = 2200051,
    ErrorCode_TriggerAlreadyLeaveWhenEnterCondFail = 2200052,
    ErrorCode_TriggerLeaveConfigEmpty = 2200053,
    ErrorCode_TriggerConditionNotMet = 2200054,
    ErrorCode_TriggerRangeRationalityFail = 2200055,
    ErrorCode_TrampleEntityNotMatch = 2200056,
    ErrorCode_TrampleConditionNotMet = 2200057,
    ErrorCode_TrampleMatchCountNotMet = 2200058,
    ErrorCode_HasDestroySelfActionInQueue = 2200059,
    ErrorCode_EntityWillDestroy = 2200060,
    ErrorCode_AddInRangePlayerDuplicate = 2200061,
    ErrorCode_AddInRangeEntityDuplicate = 2200062,
    ErrorCode_RemoveInRangePlayerNotExist = 2200063,
    ErrorCode_RemoveInRangeEntityNotExist = 2200064,
    ErrorCode_GravityDirectionNoChange = 2200072,
    ErrorCode_HookExitWayNotExist = 2200065,
    ErrorCode_HookLockPointLocked = 2200066,
    ErrorCode_HookLockAddPlayerDuplicate = 2200067,
    ErrorCode_HookLockRemovePlayerNotExist = 2200068,
    ErrorCode_KiteHookLockPointOnlyOnePlayer = 2200069,
    ErrorCode_EffectAreaAddBuffFail = 2200073,
    ErrorCode_ErrGravityInteractNoPermission = 2200074,
    ErrorCode_PlayerNotInAnyGravityRegion = 2200075,
    ErrorCode_ErrSceneEntityAlreadyExist = 2200070,
    ErrorCode_PlayerLeaveGravityRegionInAbnormalGravity = 2200076,
    ErrorCode_HookLockPointConditionNotMet = 2200071,
    ErrorCode_PlayerInAbnormalGravity = 2200077,
    ErrorCode_GravityFlipIndexNoChange = 2200078,
    ErrorCode_GravityFlipIndexNotExist = 2200079,
    ErrorCode_GravityFlipTypeNoChange = 2200080,
    ErrorCode_GravityFlipTypeNotExist = 2200081,
    ErrorCode_GravityFlipNotUpdateToTargetDirection = 2200082,
    ErrorCode_ReliablePosNotInGravityRegion = 2200083,
    ErrorCode_TargetPosNotInGravityRegion = 2200084,
    ErrorCode_PlayerCurGravityDirectionNotInOptions = 2200085,
    ErrorCode_WaterfallClimbingParticipatorCountErr = 2200086,
    ErrorCode_WaterfallClimbingParticipatorNoVehicle = 2200087,
    ErrorCode_WaterfallClimbingVehicleNoPassenger = 2200088,
    ErrorCode_WaterfallClimbingPlayerNotInPassenger = 2200089,
    ErrorCode_ErrVehicleEntityNotExist = 2200090,
    ErrorCode_GravityFlipLocked = 2200091,
    ErrorCode_ClientActionSkipped = 2200092,
    ErrorCode_AbnormalGravityCannotAddTemporary = 2200093,
    ErrorCode_ErrReliablePosEntityNotExist = 2200094,
    ErrorCode_UpdateReliablePosGravityDirNotMatch = 2200095,
    ErrorCode_UpdateReliablePosNotWalkable = 2200096,
    ErrorCode_UpdateReliablePosSelfNotEntity = 2200097,
    ErrorCode_GravityDirectionHasNaN = 2200098,
    ErrorCode_ErrHostInAbnormalGravity = 2200099,
    ErrorCode_MultiModeCannotTeleport = 2200100,
    ErrorCode_NotTrapDefenseInst = 2200101,
    ErrorCode_GridCellCreateFuncNotFound = 2200102,
    ErrorCode_GridSystemNotExist = 2200103,
    ErrorCode_ErrGridCellType = 2200104,
    ErrorCode_GridCellDirectionNotSpecified = 2200105,
    ErrorCode_NotGridObjectEntity = 2200106,
    ErrorCode_GridNotExist = 2200107,
    ErrorCode_GridCellNotExist = 2200108,
    ErrorCode_GridCellAlreadyOccupied = 2200109,
    ErrorCode_GridCellDisabled = 2200110,
    ErrorCode_GridCellPositionNotValid = 2200111,
    ErrorCode_SimpleCombatEntityNotMonster = 2200112,
    ErrorCode_GridObjectEntityNotFound = 2200113,
    ErrorCode_NotLowMemoryPlatform = 2200114,
    ErrorCode_ErrLowMemorySwitchingScene = 2200115,
    ErrorCode_SimpleCombatEntityBuffNotExist = 2200116,
    ErrorCode_SimpleCombatEntityBuffDuplicate = 2200117,
    ErrorCode_TrapDefenseRandomBdFail = 2200118,
    ErrorCode_TrapDefenseBdConfigNotExist = 2200119,
    ErrorCode_TrapDefenseBdGroupConfigOfBdNotExist = 2200120,
    ErrorCode_TrapDefenseRandomQualityFail = 2200121,
    ErrorCode_TrapDefenseRandomBdGroupFail = 2200122,
    ErrorCode_TrapDefenseBdGroupPoolEmpty = 2200123,
    ErrorCode_TrapDefenseNoAvailableBd = 2200124,
    ErrorCode_TrapDefenseNoAvailableQuality = 2200125,
    ErrorCode_TrapDefenseDrawActionConfigNotExist = 2200126,
    ErrorCode_TrapDefenseInstConfigNotExist = 2200127,
    ErrorCode_TrapDefenseWaveConfigNotExist = 2200128,
    ErrorCode_TrapDefenseSpawnMonsterWaveConfigNotExist = 2200129,
    ErrorCode_TrapDefenseMonsterConfigNotExist = 2200130,
    ErrorCode_TrapDefenseMonsterDataDuplicate = 2200131,
    ErrorCode_TrapDefenseTrapConfigNotExist = 2200132,
    ErrorCode_TrapDefenseTrapEntityNotFound = 2200133,
    ErrorCode_TrapDefenseNotPreviewStep = 2200134,
    ErrorCode_TrapDefenseBdGroupConfigNotExist = 2200135,
    ErrorCode_TrapDefenseBdPoolEmpty = 2200136,
    ErrorCode_TrapDefenseQualityPoolEmpty = 2200137,
    ErrorCode_ErrTrapDefenseRequestParam = 2200138,
    ErrorCode_ErrTrapDefenseRequestParamDuplicate = 2200139,
    ErrorCode_ErrTrapDefenseRewardConfig = 2200140,
    ErrorCode_ErrTrapDefenseRewardTime = 2200141,
    ErrorCode_ErrTrapDefenseRewardReceived = 2200142,
    ErrorCode_ErrTrapDefenseRewardNotComplete = 2200143,
    ErrorCode_ErrTrapDefenseSceneErr = 2200144,
    ErrorCode_ErrTrapDefenseContextEmpty = 2200145,
    ErrorCode_ErrTrapDefenseChallengeConfig = 2200146,
    ErrorCode_ErrTrapDefenseChallengeNotOpen = 2200147,
    ErrorCode_ErrTrapDefenseBuildingLock = 2200148,
    ErrorCode_ErrTrapDefenseAuxiliaryLock = 2200149,
    ErrorCode_ErrTrapDefenseSlotCount = 2200150,
    ErrorCode_ErrTrapDefenseSlotBuildingDuplicate = 2200151,
    ErrorCode_ErrTrapDefenseSlotDuplicate = 2200152,
    ErrorCode_ErrTrapDefenseBuildingConfig = 2200153,
    ErrorCode_ErrTrapDefenseAuxiliaryConfig = 2200154,
    ErrorCode_ErrTrapDefenseSlotAuxiliaryDuplicate = 2200155,
    ErrorCode_ErrTrapDefenseForceBuilding = 2200156,
    ErrorCode_ErrTrapDefenseForceAuxiliary = 2200157,
    ErrorCode_ErrTrapDefenseBuildingLevelConfig = 2200158,
    ErrorCode_ErrTrapDefenseBuildingMaxLevel = 2200159,
    ErrorCode_ErrTrapDefenseActivityConfig = 2200160,
    ErrorCode_ErrTrapDefenseAuxiliaryLevelConfig = 2200161,
    ErrorCode_ErrTrapDefenseAuxiliaryMaxLevel = 2200162,
    ErrorCode_ErrTrapDefenseAuxiliaryBranch = 2200163,
    ErrorCode_ErrTrapDefenseBuildingBranch = 2200164,
    ErrorCode_ErrTrapDefenseAuxiliaryReset = 2200165,
    ErrorCode_ErrTrapDefenseBuildingReset = 2200166,
    ErrorCode_ErrTrapDefenseTechConfig = 2200167,
    ErrorCode_ErrTrapDefenseTechUnlock = 2200168,
    ErrorCode_ErrTrapDefenseTechPreNodeConfig = 2200169,
    ErrorCode_ErrTrapDefenseTechPreNodeLock = 2200170,
    ErrorCode_ErrTrapDefenseTechCostNotEnough = 2200171,
    ErrorCode_TrapDefenseItemConfigNotExist = 2200172,
    ErrorCode_TrapDefenseItemExceedCarryLimit = 2200173,
    ErrorCode_TrapDefenseItemNotEnough = 2200174,
    ErrorCode_TrapDefenseBuyShopBdGroupNotExist = 2200175,
    ErrorCode_TrapDefenseBuyShopItemNotExist = 2200176,
    ErrorCode_TrapDefenseGoldNotEnough = 2200177,
    ErrorCode_TrapDefensePayGoldFail = 2200178,
    ErrorCode_TrapDefenseBuyShopItemNotEnough = 2200179,
    ErrorCode_TrapDefenseShopDataNotExist = 2200180,
    ErrorCode_TrapDefenseShopConfigNotExist = 2200181,
    ErrorCode_TrapDefenseShopRefreshCountNotEnough = 2200182,
    ErrorCode_TrapDefenseGoldenCoinConfigNotExist = 2200183,
    ErrorCode_TrapDefenseNotGoldenCoinEntity = 2200184,
    ErrorCode_TrapDefenseNotMonsterEntity = 2200185,
    ErrorCode_TrapDefenseNotBuildingEntity = 2200186,
    ErrorCode_TrapDefenseVarCannotUnderZero = 2200187,
    ErrorCode_TrapDefenseVarTypeNotExist = 2200188,
    ErrorCode_TrapDefenseBuyShopBdGroupSold = 2200189,
    ErrorCode_TrapDefenseTrapAmountExceedLimit = 2200190,
    ErrorCode_TrapDefenseNotRewardStep = 2200191,
    ErrorCode_TrapDefenseBdDrawDataNotExist = 2200192,
    ErrorCode_TrapDefenseBdDrawRefreshCountNotEnough = 2200193,
    ErrorCode_TrapDefenseSpecialCellConfigNotExist = 2200194,
    ErrorCode_TrapDefenseSpecialCellCertainLevelConfigNotExist = 2200195,
    ErrorCode_ErrActionTargetEntityNotExist = 2200196,
    ErrorCode_TrapDefenseCleanerNotEnough = 2200197,
    ErrorCode_TrapDefenseItemConfigError = 2200198,
    ErrorCode_TrapDefenseSpecialCellTypeNotSame = 2200199,
    ErrorCode_TrapDefenseCellNotSpecialCell = 2200200,
    ErrorCode_TrapDefenseExceedMaxTrapCount = 2200201,
    ErrorCode_GridSystemCannotGetWorldGridPos = 2200202,
    ErrorCode_TrapDefenseTrapCannotSelfDestruct = 2200203,
    ErrorCode_TrapDefenseBdDrawResultEmpty = 2200204,
    ErrorCode_TrapDefenseBdGroupMaxLevel = 2200205,
    ErrorCode_TrapDefenseCannotDeductHealth = 2200206,
    ErrorCode_SimpleCombatBuffConfigNotExist = 2200207,
    ErrorCode_SimpleCombatSubTypeNotExist = 2200208,
    ErrorCode_TrapDefenseBdGroupDisabled = 2200209,
    ErrorCode_TrapDefenseMonsterDisabled = 2200210,
    ErrorCode_TrapDefenseGainExceedLimit = 2200211,
    ErrorCode_OnlyOneRollBlockCanBeActivated = 2200212,
    ErrorCode_RollBlockGroupConfigNotExist = 2200213,
    ErrorCode_RollBlockDifficultyConfigNotExist = 2200214,
    ErrorCode_RollBlockNextDifficultyConfigNotExist = 2200215,
    ErrorCode_RollBlockGamePlayIdNotExist = 2200216,
    ErrorCode_RollBlockGamePlayNotExist = 2200217,
    ErrorCode_RollBlockMovementEntityNotExist = 2200218,
    ErrorCode_RollBlockMovementEntityNotBlock = 2200219,
    ErrorCode_RollBlockMainControlPlayerNotExist = 2200220,
    ErrorCode_RollBlockEntityNotMoving = 2200221,
    ErrorCode_RollBlockNoGridAfterRoll = 2200222,
    ErrorCode_RollBlockTemplateConfigNotExist = 2200223,
    ErrorCode_RollBlockNotMainControlPlayer = 2200224,
    ErrorCode_RollBlockEntityNotExist = 2200225,
    ErrorCode_RollBlockBlockWillChangeState = 2200226,
    ErrorCode_RollBlockBlockStateNoChange = 2200227,
    ErrorCode_RollBlockMainControlBlockNotExist = 2200228,
    ErrorCode_RollBlockDifficultyDataNotExist = 2200229,
    ErrorCode_RollBlockPositionNoFloor = 2200230,
    ErrorCode_RollBlockPositionItemCannotPass = 2200231,
    ErrorCode_RollBlockPositionBlockCannotPass = 2200232,
    ErrorCode_RollBlockInputCannotMove = 2200233,
    ErrorCode_RollBlockPositionFloorCannotPass = 2200234,
    ErrorCode_RollBlockHintAlreadyActive = 2200235,
    ErrorCode_RollBlockHintBlockNotExist = 2200236,
    ErrorCode_RollBlockHintEmpty = 2200237,
    ErrorCode_RollBlockAlreadyRewarded = 2200238,
    ErrorCode_RollBlockDifficultyNotPassed = 2200239,
    ErrorCode_RollBlockHintStepNotExecuting = 2200240,
    ErrorCode_RollBlockCurDifficultyConfigNotExist = 2200241,
    ErrorCode_RollBlockHintStepExecuting = 2200242,
    ErrorCode_RollBlockChildQuestGamePlayActived = 2200243,
    ErrorCode_RollBlockOnlyOneControllableBlock = 2200244,
    ErrorCode_RollBlockGamePlayStateNoChange = 2200245,
    ErrorCode_RollBlockGamePlayCannotReady = 2200246,
    ErrorCode_RollBlockGamePlayNotReady = 2200247,
    ErrorCode_RollBlockSendResetTooFrequently = 2200248,
    ErrorCode_EasterEggIdNotExist = 2200249,
    ErrorCode_TargetSceneNotBigWorldInst = 2200250,
    ErrorCode_EnterBigWorldInstCtxNotImplemented = 2200251,
    ErrorCode_EasterEggOwnerTypeNotImplemented = 2200252,
    ErrorCode_RollBlockCannotReset = 2200253,
    ErrorCode_CurSceneNotBigWorld = 2200254,
    ErrorCode_NotQaAccountWithHIddenServer = 2300000,
    ErrorCode_DisabledFuncInHIddenServer = 2300001,
    ErrorCode_ErrActionExecutorFinishConditionNotSport = 2400000,
    ErrorCode_ErrAlreadyInSwitchNode = 2400001,
    ErrorCode_ErrCornActivityId = 2500000,
    ErrorCode_ErrCornActivityNoOpen = 2500001,
    ErrorCode_ErrCornNoActivityData = 2500002,
    ErrorCode_NoPlayIdCorniceReward = 2500003,
    ErrorCode_ActivityNoOpenCorniceReward = 2500004,
    ErrorCode_ScoreLimitCorniceReward = 2500005,
    ErrorCode_RewardedCorniceReward = 2500006,
    ErrorCode_NoUnlockCorniceReward = 2500007,
    ErrorCode_NoScoreCorniceReward = 2500008,
    ErrorCode_TrackMoonPhaseNoConfig = 2500009,
    ErrorCode_TrackMoonPhaseActivityNoOpen = 2500010,
    ErrorCode_TrackMoonPhaseNoPolulary = 2500011,
    ErrorCode_TrackMoonPhaseNoData = 2500012,
    ErrorCode_TrackMoonPhaseRewarded = 2500013,
    ErrorCode_TrackMoonPhaseDataNoConfig = 2500014,
    ErrorCode_TrackMoonPhaseDataNoOpen = 2500015,
    ErrorCode_TrackMoonPhaseDataNoData = 2500016,
    ErrorCode_BCTRewardNoTConfig = 2500017,
    ErrorCode_BCTRewardNoOpenActivity = 2500018,
    ErrorCode_BCTRewardNoData = 2500019,
    ErrorCode_BCTRewardNoUnlock = 2500020,
    ErrorCode_BCTRewardNoComplete = 2500021,
    ErrorCode_BCARewardNoRConfig = 2500022,
    ErrorCode_BCARewardNoOpenActivity = 2500023,
    ErrorCode_BCARewardNoData = 2500024,
    ErrorCode_BCARewardNoActive = 2500025,
    ErrorCode_BCARewarded = 2500026,
    ErrorCode_BCARewardNoActiveReward = 2500027,
    ErrorCode_CornTranNoPlayConfig = 2500028,
    ErrorCode_CornTranNoOpenPlay = 2500029,
    ErrorCode_CornTranNoOpenActivity = 2500030,
    ErrorCode_CornTranNoEntityConfig = 2500031,
    ErrorCode_BCARewardRepeatRewardId = 2500032,
    ErrorCode_BCARewardDifferActivityId = 2500033,
    ErrorCode_BCTRewardNoActivity = 2500034,
    ErrorCode_BCTRewardIllegalRewardNum = 2500035,
    ErrorCode_BCTRewardNoUnlockStage = 2500036,
    ErrorCode_PreheatSignNodeNoConfig = 2500037,
    ErrorCode_PreheatSignNodeNoData = 2500038,
    ErrorCode_PreheatSignActivityOnOpen = 2500039,
    ErrorCode_PreheatSignNodeNoUnlock = 2500040,
    ErrorCode_PreheatSignNodeNoRewardStatus = 2500041,
    ErrorCode_PreheatSignNodeNoAnswer = 2500042,
    ErrorCode_ScratchCardNoRoundConfig = 2500043,
    ErrorCode_ScratchCardNoActivityConfig = 2500044,
    ErrorCode_ScratchCardNoDbData = 2500045,
    ErrorCode_ScratchCardIllegalIndex = 2500046,
    ErrorCode_ScratchCardIndexRewarded = 2500047,
    ErrorCode_ScratchCardNoTime = 2500048,
    ErrorCode_ScratchCardNoRandomReward = 2500049,
    ErrorCode_ScratchCardRoundNoUnlock = 2500050,
    ErrorCode_BossRushPlayerNoSceneData = 2500051,
    ErrorCode_BossRushPlayerCanNoChooseBuff = 2500052,
    ErrorCode_BossRushPlayerIllegalIndex = 2500053,
    ErrorCode_BossRushHadSameBuffId = 2500054,
    ErrorCode_BossRushBuffCountLimit = 2500055,
    ErrorCode_BossRushBuffIllegal = 2500056,
    ErrorCode_BossRushBuffNoConfig = 2500057,
    ErrorCode_ScratchCardActivityNoOpen = 2500058,
    ErrorCode_MowToweNoLevelConfig = 2500059,
    ErrorCode_MowTowerActivityNoOpen = 2500060,
    ErrorCode_MowToweNoCacheData = 2500061,
    ErrorCode_MowTowerNoPassFirstInst = 2500062,
    ErrorCode_MowTowerLevelsIdError = 2500063,
    ErrorCode_MowTowerRoleIdError = 2500064,
    ErrorCode_MowTowerBuffIdError = 2500065,
    ErrorCode_MowTowerNoComponent = 2500066,
    ErrorCode_MowTowerHadSameRole = 2500067,
    ErrorCode_MowTowerBuffCountError = 2500068,
    ErrorCode_MowTowerNoFirstInst = 2500069,
    ErrorCode_MowTowerNoActivityData = 2500070,
    ErrorCode_MowTowerScoreLimit = 2500071,
    ErrorCode_MowTowerScoreRewarded = 2500072,
    ErrorCode_MowTowerScoreRewardConfig = 2500073,
    ErrorCode_MowTowerNoInScene = 2500074,
    ErrorCode_MowTowerNoRewardConfig = 2500075,
    ErrorCode_MaterialReplaceNoTargetConfig = 2500076,
    ErrorCode_MaterialReplaceNoConsumeConfig = 2500077,
    ErrorCode_MaterialReplaceNoSameGroup = 2500078,
    ErrorCode_MaterialReplaceErrConsumeNum = 2500079,
    ErrorCode_ErrRoleSkinTrialNotInit = 2500080,
    ErrorCode_ErrRoleSkinTrialNoFinish = 2500081,
    ErrorCode_ErrRoleSkinTrialReward = 2500082,
    ErrorCode_ErrRoleSkinTrialRewardDone = 2500083,
    ErrorCode_ErrRoleSkinTrialTimeOut = 2500084,
    ErrorCode_PhantomEquipGroupNoEquipPhantom = 2500085,
    ErrorCode_PhantomEquipGroupCountLimit = 2500086,
    ErrorCode_PhantomEquipGroupHadInTop = 2500087,
    ErrorCode_PhantomEquipGroupNameEmpty = 2500088,
    ErrorCode_PhantomEquipGroupNameCountLimiy = 2500089,
    ErrorCode_PhantomRecommendFuncNoOpen = 2500090,
    ErrorCode_BossRushTaskNoFinish = 2500091,
    ErrorCode_PhantomGroupUseSame = 2500092,
    ErrorCode_PhantomGroupFunNoOpen = 2500093,
    ErrorCode_NoFishingActivityConfig = 2500094,
    ErrorCode_NoInFishingActivityTime = 2500095,
    ErrorCode_FishingActivityCanNoReward = 2500096,
    ErrorCode_NoFishingActivityMileConfig = 2500097,
    ErrorCode_FishingActivitySameMileId = 2500098,
    ErrorCode_FishingActivityRewarded = 2500099,
    ErrorCode_PlayerTitleFuncNoOpen = 2500100,
    ErrorCode_PlayerTitleHadUndress = 2500101,
    ErrorCode_PlayerTitleHadDress = 2500102,
    ErrorCode_PlayerTitleNoUnlock = 2500103,
    ErrorCode_BabelTowerActivityNoOpen = 2500104,
    ErrorCode_BabelTowerLevelNoOpen = 2500105,
    ErrorCode_BabelTowerDeEffectNoFind = 2500106,
    ErrorCode_BabelTowerDeEffectCanNoChoose = 2500107,
    ErrorCode_BabelTowerDeEffectMutex = 2500108,
    ErrorCode_BabelTowerNoDailyTask = 2500109,
    ErrorCode_BabelTowerTaskNoComplete = 2500110,
    ErrorCode_BabelTowerTaskRewarded = 2500111,
    ErrorCode_BabelTowerRoleLimit = 2500112,
    ErrorCode_BabelTowerNoBuffConfig = 2500113,
    ErrorCode_BabelTowerBuffCanNoChoose = 2500114,
    ErrorCode_BabelTowerBuffNumIllegal = 2500115,
    ErrorCode_BabelTowerBuffChooseCountLimit = 2500116,
    ErrorCode_NoBabelTowerInsComponent = 2500117,
    ErrorCode_BabelTowerNoSelectBuff = 2500118,
    ErrorCode_PhantomPolishFuncNoOpen = 2500119,
    ErrorCode_PhantomPolishHadLevelUp = 2500120,
    ErrorCode_PhantomPolishQualityLimit = 2500121,
    ErrorCode_PhantomPolishSamePro = 2500122,
    ErrorCode_ExploreActivityNoOpen = 2500123,
    ErrorCode_ExploreActivityTaskNoFinish = 2500124,
    ErrorCode_ExploreActivityTaskRewarded = 2500125,
    ErrorCode_BabelTowerDeTermNoUnlock = 2500126,
    ErrorCode_BabelTowerBuffNoUnlock = 2500127,
    ErrorCode_BabelTowerIsNoDifficult = 2500128,
    ErrorCode_PlayerTitleNoConfig = 2500129,
    ErrorCode_PlayerFixIndexIllegal = 2500130,
    ErrorCode_PlayerFixHadFlag = 2500131,
    ErrorCode_PlayerFixFrontNoFlag = 2500132,
    ErrorCode_BabelTowerNoSelectRoles = 2500133,
    ErrorCode_PhBaErrSelectNum = 2500134,
    ErrorCode_PhBaErrSelectTarget = 2500135,
    ErrorCode_PhBaNoFighterLogic = 2500136,
    ErrorCode_PhBaNoChallengeConf = 2500137,
    ErrorCode_PhBaSlotIllegal = 2500138,
    ErrorCode_PhBaNoEvolveNum = 2500139,
    ErrorCode_PhBaNoFighter = 2500140,
    ErrorCode_PhBaNoHandCard = 2500141,
    ErrorCode_PhBaNoCardConf = 2500142,
    ErrorCode_PhBaNoCardEvolveCountInValid = 2500143,
    ErrorCode_PhBaErrCostNoMatch = 2500144,
    ErrorCode_PhBaNoCardRoleConf = 2500145,
    ErrorCode_PhBaNoContainSkill = 2500146,
    ErrorCode_PhBaNoSkillConf = 2500147,
    ErrorCode_PhBaNoCardCanNoUse = 2500148,
    ErrorCode_PhBaIsWaitClient = 2500149,
    ErrorCode_PhBaNoDeployRound = 2500150,
    ErrorCode_PhBaNoClientParam = 2500151,
    ErrorCode_PhBaNoClientParamMatch = 2500152,
    ErrorCode_PhBaErrSelectCardNum = 2500153,
    ErrorCode_PhBaErrSelectReplace = 2500154,
    ErrorCode_PhBaErrPreStep = 2500155,
    ErrorCode_PhBaCanNoSelect = 2500156,
    ErrorCode_PhBaConditionLimit = 2500157,
    ErrorCode_PhBaNoOwnerFighter = 2500158,
    ErrorCode_PhBaNoTriggerFighter = 2500159,
    ErrorCode_PhBaSelectParamNull = 2500160,
    ErrorCode_PhBaNoBuffData = 2500161,
    ErrorCode_PhBaNoBuffConf = 2500162,
    ErrorCode_PhBaErrCardGroupIndex = 2500163,
    ErrorCode_PhBaCardRoleUnlock = 2500164,
    ErrorCode_PhBaNoCardGroupConf = 2500165,
    ErrorCode_PhBaSloFull = 2500166,
    ErrorCode_PhBaHandCardEmpty = 2500167,
    ErrorCode_PbSelectCardNotFound = 2500168,
    ErrorCode_PbSelectCardCount = 2500169,
    ErrorCode_PbNoNpcFighter = 2500170,
    ErrorCode_PbNoPlayerFighter = 2500171,
    ErrorCode_PbBTEventDataIllegal = 2500172,
    ErrorCode_PbNoCardFighter = 2500173,
    ErrorCode_PbNoHandCardVarData = 2500174,
    ErrorCode_PbNoPosVarData = 2500175,
    ErrorCode_PbNoHandCard = 2500176,
    ErrorCode_PbNoCardFighterVarData = 2500177,
    ErrorCode_PbNoNpcConfig = 2500178,
    ErrorCode_PbNoCostPoint = 2500179,
    ErrorCode_PbNoActiveSkill = 2500180,
    ErrorCode_PbErrSelectTargets = 2500181,
    ErrorCode_PbErrHadFighter = 2500182,
    ErrorCode_PbErrCardUnmovable = 2500183,
    ErrorCode_PbNoCanSelectTarget = 2500184,
    ErrorCode_PbCanNotOpOtherUnit = 2500185,
    ErrorCode_PbCanNoBeEvolve = 2500186,
    ErrorCode_PbKeyCostCanNotOp = 2500187,
    ErrorCode_PbNoReChallenge = 2500188,
    ErrorCode_PbFuncNoOpen = 2500189,
    ErrorCode_PbNoRequestReChallenge = 2500190,
    ErrorCode_PbNoSameSlotIndex = 2500191,
    ErrorCode_PhBaHaCardEmpty = 2500192,
    ErrorCode_PhBaPassedChallenge = 2500193,
    ErrorCode_FunPlayNoConfig = 2500194,
    ErrorCode_FunPlayNoFinish = 2500195,
    ErrorCode_FunPlayHadRewarded = 2500196,
    ErrorCode_PbCardSkillCountLimit = 2500197,
    ErrorCode_BabelRoleIsSelected = 2500248,
    ErrorCode_BabelNoTalentConfig = 2500249,
    ErrorCode_BabelInnerCanNoOpe = 2500250,
    ErrorCode_BabelTalentIsLearned = 2500251,
    ErrorCode_BabelTalentNoFinish = 2500252,
    ErrorCode_BabelNoActivityConfig = 2500253,
    ErrorCode_BabelRankListInCd = 2500254,
    ErrorCode_FunPlayDayNoOpen = 2500255,
    ErrorCode_CheckShopConditionFail = 2500262,
    ErrorCode_HonamiStoryBagUpdateRepeat = 2500263,
    ErrorCode_HonamiStoryBagNoConfig = 2500264,
    ErrorCode_HonamiStoryNormalAddItemErr = 2500265,
    ErrorCode_HonamiStoryNoBagDb = 2500266,
    ErrorCode_HonamiStoryUpdateItemSizeIllegal = 2500267,
    ErrorCode_HonamiStoryItemUpdateRepeat = 2500268,
    ErrorCode_HonamiStoryBagHadItem = 2500269,
    ErrorCode_HonamiStoryBagPosIllegal = 2500270,
    ErrorCode_HonamiStoryItemUpdateTypeErr = 2500271,
    ErrorCode_HonamiStoryBagNoHadItem = 2500272,
    ErrorCode_HonamiStoryDropItemNoEntityId = 2500273,
    ErrorCode_HonamiStoryDropItemNoEntity = 2500274,
    ErrorCode_HonamiStoryNoDropEntity = 2500275,
    ErrorCode_HonamiStoryDropNoItemDb = 2500276,
    ErrorCode_HonamiStoryItemNoBalance = 2500277,
    ErrorCode_HonamiStoryNoUpdateItem = 2500278,
    ErrorCode_HonamiStoryCheckMarkNoItemConfig = 2500279,
    ErrorCode_HonamiStoryCheckMarkOverSize = 2500280,
    ErrorCode_HonamiStoryCheckWideOverSize = 2500281,
    ErrorCode_HonamiStoryCheckMarkRepeat = 2500282,
    ErrorCode_HonamiStoryActivityNoSame = 2500283,
    ErrorCode_HonamiStoryNoEquipRackData = 2500284,
    ErrorCode_HonamiStoryNoEquipType = 2500285,
    ErrorCode_HonamiStoryNoEquipConfig = 2500286,
    ErrorCode_HonamiStoryNoEquipTypeNoMatch = 2500287,
    ErrorCode_HonamiStoryActivityIdErr = 2500288,
    ErrorCode_HonamiStoryInnerCanNoModifyRole = 2500289,
    ErrorCode_HonamiStoryRoleNoValid = 2500290,
    ErrorCode_HonamiStoryNoChallengeConfig = 2500291,
    ErrorCode_NoHonamiStoryInstType = 2500292,
    ErrorCode_HonamiStoryNoItemConfig = 2500293,
    ErrorCode_HonamiStoryPickDistanceErr = 2500294,
    ErrorCode_HonamiStoryNoDressWeapon = 2500295,
    ErrorCode_HonamiStoryNoWeaponConfig = 2500296,
    ErrorCode_HonamiStoryWeaponPluginPosErr = 2500297,
    ErrorCode_HonamiStoryWeaponPluginTypeNoMatch = 2500298,
    ErrorCode_HonamiStoryWareHouseOverSize = 2500299,
    ErrorCode_HonamiStoryNoOpenSafeBag = 2500300,
    ErrorCode_HonamiStoryNoOpenSafeBagItem = 2500301,
    ErrorCode_HonamiStoryBagTypeNoMatch = 2500302,
    ErrorCode_HonamiStoryWeaponPluginNoUnDress = 2500303,
    ErrorCode_HonamiStoryChangeItemPosSame = 2500304,
    ErrorCode_HonamiStoryEquipPosError = 2500305,
    ErrorCode_HonamiStoryEquipPosRepeat = 2500306,
    ErrorCode_HonamiStoryOriPosErr = 2500307,
    ErrorCode_HonamiStoryInstCanNoOpe = 2500308,
    ErrorCode_HonamiStoryIsRewarded = 2500309,
    ErrorCode_HonamiStoryNoFinish = 2500310,
    ErrorCode_HonamiStoryNoConfig = 2500311,
    ErrorCode_HonamiStoryHadActivateTalent = 2500312,
    ErrorCode_HonamiStoryIsUnlocked = 2500313,
    ErrorCode_HonamiStoryItemCanNoSell = 2500314,
    ErrorCode_HonamiStoryRewardRepeat = 2500315,
    ErrorCode_HonamiStoryInstHadFinish = 2500316,
    ErrorCode_HonamiStoryLifeSupportFullLevel = 2500317,
    ErrorCode_HonamiStoryDangerLevelIllegal = 2500318,
    ErrorCode_HonamiStoryWeaponHadDress = 2500319,
    ErrorCode_HonamiStoryItemIsLock = 2500320,
    ErrorCode_HonamiStoryFunNoOpen = 2500321,
    ErrorCode_HonamiStoryHadSafeLeave = 2500322,
    ErrorCode_HonamiStoryInTop = 2500323,
    ErrorCode_HonamiStoryAreaNoUnlock = 2500324,
    ErrorCode_HonamiStoryPreSlotUnlock = 2500325,
    ErrorCode_TotalTopUpNoActivityConfig = 2500326,
    ErrorCode_TotalTopUpNoFinish = 2500327,
    ErrorCode_TotalTopUpRewarded = 2500328,
    ErrorCode_TotalTopUpRoleFullChain = 2500329,
    ErrorCode_WeekCardUseRepeat = 2500330,
    ErrorCode_WeekCardNoConfig = 2500331,
    ErrorCode_WeekCardNoActive = 2500332,
    ErrorCode_WeekCardCanNoReward = 2500333,
    ErrorCode_WeekCardRewarded = 2500334,
    ErrorCode_WeekCardNoEffect = 2500335,
    ErrorCode_FlagChallengeTaskNoFinish = 2500336,
    ErrorCode_FlagChallengeNoConfig = 2500337,
    ErrorCode_FlagChallengeTaskRewarded = 2500338,
    ErrorCode_FlagChallengeRewardRepeat = 2500339,
    ErrorCode_FlagChallengeNoUnlock = 2500340,
    ErrorCode_FeiXuePreheatNoFinish = 2500341,
    ErrorCode_FeiXuePreheatNoConfig = 2500342,
    ErrorCode_FeiXuePreheatRewarded = 2500343,
    ErrorCode_FeiXuePreheatRewardRepeat = 2500344,
    ErrorCode_FlagChallengePassed = 2500355,
    ErrorCode_ErrAlertAreaId = 2600000,
    ErrorCode_ErrAlertAreaEnable = 2600001,
    ErrorCode_ErrAlertAreaDisable = 2600002,
    ErrorCode_ErrAlertUiEnable = 2600003,
    ErrorCode_ErrAlertUiDisable = 2600004,
    ErrorCode_ErrAlertUiVisible = 2600005,
    ErrorCode_ErrAlertUiInvisible = 2600006,
    ErrorCode_ErrAlertValueError = 2600007,
    ErrorCode_ErrAlertSetAlertValueType = 2600008,
    ErrorCode_LevelPlayReportConfigNotExist = 2600009,
    ErrorCode_LevelPlayReportTypeError = 2600010,
    ErrorCode_LevelPlayReportVarsEmpty = 2600011,
    ErrorCode_LevelPlayReportPlayVarsError = 2600012,
    ErrorCode_CameraAlertHasAlert = 2600013,
    ErrorCode_CameraAlertHasNotAlert = 2600014,
    ErrorCode_CameraAlertTagIdNotExist = 2600015,
    ErrorCode_LevelPlayConfigNotExist = 2600016,
    ErrorCode_LevelPlayRepeateInstId = 2600017,
    ErrorCode_LevelPlayNotBelongInst = 2600018,
    ErrorCode_LevelPlayIdsNotExist = 2600019,
    ErrorCode_LevelPlayInstCountError = 2600020,
    ErrorCode_LevelPlayCountError = 2600021,
    ErrorCode_TimerHasPause = 2600022,
    ErrorCode_TimerHasNotPause = 2600023,
    ErrorCode_TimerHasFinish = 2600024,
    ErrorCode_CanNotContinueInst = 2600025,
    ErrorCode_ChapterNotExist = 2600026,
    ErrorCode_ChapterResultHasFinish = 2600027,
    ErrorCode_ChapterResultNotFinish = 2600028,
    ErrorCode_ChapterResultRewardCanNotTake = 2600029,
    ErrorCode_ChoiceHasUnlock = 2600030,
    ErrorCode_ChoiceNotUnlock = 2600031,
    ErrorCode_ChapterResultNotExist = 2600032,
    ErrorCode_ChapterResultRewardHasTake = 2600033,
    ErrorCode_ChoiceNotExist = 2600034,
    ErrorCode_InspirationNotEnough = 2600035,
    ErrorCode_ActivityRewardCanNotTake = 2600036,
    ErrorCode_ActivityResultNotExist = 2600037,
    ErrorCode_ScheduleRewardNotExist = 2600038,
    ErrorCode_ScheduleRewardHasTake = 2600039,
    ErrorCode_ScheduleRewardCanNotTake = 2600040,
    ErrorCode_ActivityRewardHasTake = 2600041,
    ErrorCode_QuestWaitConfirmResource = 2600042,
    ErrorCode_HasGuest = 2600043,
    ErrorCode_QuestConfigNotExist = 2600044,
    ErrorCode_QuestDataNotExist = 2600045,
    ErrorCode_ErrorQuestState = 2600046,
    ErrorCode_QuestCanNotSetFocus = 2600047,
    ErrorCode_ErrorQuestNotFocus = 2600048,
    ErrorCode_QuestIncDicNotExist = 2600049,
    ErrorCode_QuestFocusWaitAccept = 2600050,
    ErrorCode_ErrQuestResourceState = 2600051,
    ErrorCode_NoNeedDownloadQuestResource = 2600052,
    ErrorCode_HasFinishQuestResource = 2600053,
    ErrorCode_ErrInteracTreeSuspend = 2600054,
    ErrorCode_InQuestFocusMode = 2600055,
    ErrorCode_MultiModeCannotSetQuestFocus = 2600056,
    ErrorCode_MultiModeCannotCancelQuestFocus = 2600057,
    ErrorCode_InstanceCannotSetQuestFocus = 2600058,
    ErrorCode_InstanceCannotCancelQuestFocus = 2600059,
    ErrorCode_QuestFocusModeCannotAcceptQuest = 2600060,
    ErrorCode_ErrorNotFocusWaitQuest = 2600061,
    ErrorCode_ErrorBanInteractEntity = 2600062,
    ErrorCode_DisabledFocusMode = 2600063,
    ErrorCode_ErrorNotVaildGlobalSetting = 2600064,
    ErrorCode_ErrorSameGlobalSetting = 2600065,
    ErrorCode_ErrorNotVaildBtObjSetting = 2600066,
    ErrorCode_ErrorSameBtObjSetting = 2600067,
    ErrorCode_CopyUserLoginInvalidToken = 2600068,
    ErrorCode_LoginInvalidToken = 2600069,
    ErrorCode_AccessInvalidToken = 2600070,
    ErrorCode_ErrNotAtomicProcessChildQuest = 2600071,
    ErrorCode_ErrNotAtomicProcessStoveCoreFall = 2600072,
    ErrorCode_ErrSplineEntityIdNotExist = 2600073,
    ErrorCode_ErrSplineEntityNotExist = 2600074,
    ErrorCode_MotorFightInstNotLevelConfig = 2600075,
    ErrorCode_MotorFightSubLevelNotFind = 2600076,
    ErrorCode_MotorFightNextSubLevelNotExist = 2600077,
    ErrorCode_MotorFightErrorSubLevel = 2600078,
    ErrorCode_MotorFightHasEnterSubLevel = 2600079,
    ErrorCode_MotorFightCurSubLevelNotKillFinish = 2600080,
    ErrorCode_MotorFightHasNotEnterSubLevel = 2600081,
    ErrorCode_MotorFightCusSubLevelHasNotKillFinish = 2600082,
    ErrorCode_MotorFightCurWaveNotFound = 2600083,
    ErrorCode_MotorFightErrorKillParams = 2600084,
    ErrorCode_MotorFighttExceedRefreshMonster = 2600085,
    ErrorCode_MotorFighttExceedRefreshBoss = 2600086,
    ErrorCode_MotorFightNotKillBoss = 2600087,
    ErrorCode_MotorFightBossDropCollectionHasSelect = 2600088,
    ErrorCode_MotorFightSelectPosCollectionNotExist = 2600089,
    ErrorCode_MotorFightCollectionConfigNotExist = 2600090,
    ErrorCode_MotorFightWaveGroupNotExist = 2600091,
    ErrorCode_MotorFightBossMustKilled = 2600092,
    ErrorCode_MotorFightBossNotExist = 2600093,
    ErrorCode_MotorFightSelectBuffGateNotExist = 2600094,
    ErrorCode_MotorFightCurSubLevelCollectionNoSelectFinish = 2600095,
    ErrorCode_MotorFightSubLevelConfigNotFind = 2600096,
    ErrorCode_MotorFightSubLevelIndexError = 2600097,
    ErrorCode_MotorFightBossHasKilled = 2600098,
    ErrorCode_MotorFightBossHasNotRefreshTimes = 2600099,
    ErrorCode_MotorFightBossDropCollectionError = 2600100,
    ErrorCode_MotorFightHasNotKillBossInfo = 2600101,
    ErrorCode_MotorFightIsLastBoss = 2600102,
    ErrorCode_MotorFightBuffGateHasSelect = 2600103,
    ErrorCode_MotorFightSubLevelStateError = 2600104,
    ErrorCode_MotorFightSubLevelNotFound = 2600105,
    ErrorCode_MotorFightHasGameOver = 2600106,
    ErrorCode_MotorFightCurWaveNotExist = 2600107,
    ErrorCode_MotorFightCurWaveNotKillFinish = 2600108,
    ErrorCode_ErrorCodeIdCreateRuleChange2 = 2700001,
    ErrorCode_RacingBetsActivityIdErr = 2700002,
    ErrorCode_RacingBetsActivityDataErr = 2700003,
    ErrorCode_RacingBetsRewardConfErr = 2700004,
    ErrorCode_RacingBetsTaskIdNotExist = 2700005,
    ErrorCode_RacingBetsTaskRewarded = 2700006,
    ErrorCode_RacingBetsTaskUndone = 2700007,
    ErrorCode_RacingBetsTaskRewardFail = 2700008,
    ErrorCode_RacingBetsSeasonConfErr = 2700009,
    ErrorCode_RacingBetsLegMatchIdNotExist = 2700010,
    ErrorCode_RacingBetsOddsTimesErr = 2700011,
    ErrorCode_RacingBetsOddsVersionErr = 2700012,
    ErrorCode_RacingBetsOddsVersionCodeErr = 2700013,
    ErrorCode_RacingBetsOddsConfErr = 2700014,
    ErrorCode_RacingBetsOddsDangoErr = 2700015,
    ErrorCode_RacingBetsOddsDangoConfErr = 2700016,
    ErrorCode_RacingBetsOddsTimeErr = 2700017,
    ErrorCode_RacingBetsOddsRetry = 2700018,
    ErrorCode_RacingBetsCostFundsErr = 2700019,
    ErrorCode_RacingBetsGearTimesLimit = 2700020,
    ErrorCode_RacingBetsGearInfoErr = 2700021,
    ErrorCode_RacingBetsGearRefundParamErr = 2700022,
    ErrorCode_RacingBetsGearRefundFail = 2700023,
    ErrorCode_RacingBetsGearNotRefund = 2700024,
    ErrorCode_RacingBetsActivityConfErr = 2700025,
    ErrorCode_RacingBetsOddsFundsLack = 2700026,
    ErrorCode_RacingBetsOddsLack = 2700027,
    ErrorCode_RacingBetsGroupNotExist = 2700028,
    ErrorCode_RacingBetsGroupConfNotExist = 2700029,
    ErrorCode_RacingBetsGroupConfError = 2700030,
    ErrorCode_RacingBetsNotInInst = 2700031,
    ErrorCode_RacingBetsFundsNotEnough = 2700032,
    ErrorCode_RacingBetsFundsCalcErr = 2700033,
    ErrorCode_RacingBetsLegMatchNotOpen = 2700034,
    ErrorCode_RacingBetsDangoActionTypeErr = 2700035,
    ErrorCode_RacingBetsDangoMatchParamErr = 2700036,
    ErrorCode_RacingBetsInstSubTypeErr = 2700037,
    ErrorCode_RacingBetsEntityErr = 2700038,
    ErrorCode_RacingBetsLegMatchIdErr = 2700039,
    ErrorCode_RacingBetsBulletScreenTableNotExist = 2700040,
    ErrorCode_RacingBetsBulletScreenIdErr = 2700041,
    ErrorCode_RacingBetsBulletActionIndexNotExist = 2700042,
    ErrorCode_RacingBetsBulletScreenLegMatchNotExist = 2700043,
    ErrorCode_RacingBetsBulletNotFundOpenRankCurTime = 2700044,
    ErrorCode_RacingBetsBulletGetRankErr = 2700045,
    ErrorCode_RacingBetsBulletCD = 2700046,
    ErrorCode_ActivityLinkageActivityIdConfErr = 2700047,
    ErrorCode_ActivityLinkageConfErr = 2700048,
    ErrorCode_ActivityLinkageRewardErr = 2700049,
    ErrorCode_ActivityLinkageDataErr = 2700050,
    ErrorCode_ActivityLinkageConfIndexErr = 2700051,
    ErrorCode_ActivityLinkageRewardStatusErr = 2700052,
    ErrorCode_ActivityLinkagePageTimeErr = 2700053,
    ErrorCode_RacingBetsdynamicOddsConfErr = 2700054,
    ErrorCode_RacingBetsdynamicOddsProportionErr = 2700055,
    ErrorCode_RacingBetsDangoDataNotExist = 2700056,
    ErrorCode_RacingBetsMatchDataErr = 2700057,
    ErrorCode_RacingBetsMatchRoundTimeErr = 2700058,
    ErrorCode_RacingBetsNotGear = 2700059,
    ErrorCode_RacingBetsLegSettle = 2700060,
    ErrorCode_RacingBetsRankNotOpen = 2700061,
    ErrorCode_RacingBetsActionIndexErr = 2700062,
    ErrorCode_RacingBetsMatchRoundNotFund = 2700063,
    ErrorCode_RacingBetsDangoConfNotExist = 2700064,
    ErrorCode_RacingBetsDangoTemplateConfNotExist = 2700065,
    ErrorCode_RacingBetsDangoEntityCreateFail = 2700066,
    ErrorCode_RacingBetsLegMatchConfNotExist = 2700067,
    ErrorCode_PhantomBattleCardUnlocked = 2700068,
    ErrorCode_PhantomBattleActDataNotExist = 2700069,
    ErrorCode_RacingBetsLegNextOddsErr = 2700070,
    ErrorCode_RacingBetsRankNotExist = 2700071,
    ErrorCode_RacingBetsPlayerNotExistInRank = 2700072,
    ErrorCode_PhantomBattleCardTableNotExist = 2700073,
    ErrorCode_PhantomBattleCardNumLimit = 2700074,
    ErrorCode_PhantomBattleActTableNotExist = 2700075,
    ErrorCode_PhantomBattleCardGroupLimit = 2700076,
    ErrorCode_PhantomBattleGroupLimit = 2700077,
    ErrorCode_PhantomBattleMainCostLimit = 2700078,
    ErrorCode_PhantomBattleCardLocked = 2700079,
    ErrorCode_PhantomBattleGroupNameLimit = 2700080,
    ErrorCode_PhantomBattleGroupNotExist = 2700081,
    ErrorCode_PhantomBattleRomoveReason = 2700082,
    ErrorCode_RacingBetsBulletIdErr = 2700083,
    ErrorCode_RacingBetsPlayerDataNotExist = 2700084,
    ErrorCode_RacingBetsTaskDataNotExist = 2700085,
    ErrorCode_PhantomBattleGroupElementLimit = 2700086,
    ErrorCode_PhantomBattleOutLookUped = 2700087,
    ErrorCode_PhantomBattleTaskConfNotExist = 2700088,
    ErrorCode_PhantomBattleConditionDataErr = 2700089,
    ErrorCode_PhantomBattleConditionConfNotExist = 2700090,
    ErrorCode_PhantomBattleConditionGroupConfNotExist = 2700091,
    ErrorCode_PhantomBattleTaskStutas = 2700092,
    ErrorCode_PhantomBattleTaskReward = 2700093,
    ErrorCode_PhantomBattleTaskNotFinish = 2700094,
    ErrorCode_PhantomBattleTaskProgressErr = 2700095,
    ErrorCode_PhantomBattleBadgeUnlocked = 2700096,
    ErrorCode_PhantomBattleLevelConfNotExist = 2700097,
    ErrorCode_PhantomBattBadgeRewardConfNotExist = 2700098,
    ErrorCode_PhantomBattCardRewardConfNotExist = 2700099,
    ErrorCode_PhantomBattBadgeUnlockNotEnough = 2700100,
    ErrorCode_PhantomBattBadgeConfErr = 2700101,
    ErrorCode_PhantomBattBadgeRewardErr = 2700102,
    ErrorCode_PhantomBattleLevelRewardConfNotExist = 2700103,
    ErrorCode_PhantomBattCardUnlockNotEnough = 2700104,
    ErrorCode_PhantomBattCardRewardConfErr = 2700105,
    ErrorCode_PhantomBattLvNotEnough = 2700106,
    ErrorCode_PhantomBattLvRewardConfErr = 2700107,
    ErrorCode_PhantomBattCardRewardErr = 2700108,
    ErrorCode_PhantomBattLvRewardErr = 2700109,
    ErrorCode_PhantomBattLvRewardConfNotExist = 2700110,
    ErrorCode_PhantomBattRoleLock = 2700111,
    ErrorCode_PhantomBattRoleReward = 2700112,
    ErrorCode_PhantomBattRoleRewardErr = 2700113,
    ErrorCode_PhantomBattPassRewardErr = 2700114,
    ErrorCode_PhantomBattFirstPassRewardErr = 2700115,
    ErrorCode_PhantomBattleChallengeConfNotFind = 2700116,
    ErrorCode_PhantomBattleChallengeOpenLimit = 2700117,
    ErrorCode_PhantomBattleParamLimit = 2700118,
    ErrorCode_PhantomBattleParamRepeat = 2700119,
    ErrorCode_PhantomBattleFuncOpenChallengeRepeat = 2700120,
    ErrorCode_PhantomBattleFuncOpenCardGroup = 2700121,
    ErrorCode_PhantomBattleFuncOpenCard = 2700122,
    ErrorCode_PhantomBattleFuncOpenCardOutlookUp = 2700123,
    ErrorCode_PhantomBattleCardNotAllowBuy = 2700124,
    ErrorCode_FloroRanchHasUnSettleIns = 2700125,
    ErrorCode_FloroRanchSubInsConfNotExist = 2700126,
    ErrorCode_FloroRanchRacesLimit = 2700127,
    ErrorCode_FloroRanchBaseTerrainLimit = 2700128,
    ErrorCode_FloroRanchBaseCardLimit = 2700129,
    ErrorCode_FloroRanchRaceRepeat = 2700130,
    ErrorCode_FloroRanchGamePlayNotExist = 2700131,
    ErrorCode_FloroRanchGamePlayGachaNotExist = 2700132,
    ErrorCode_FloroRanchCardNotExistInGacha = 2700133,
    ErrorCode_FloroRanchPhantomCreateFail = 2700134,
    ErrorCode_FloroRanchTributeCoinLimit = 2700135,
    ErrorCode_FloroRanchRaceNotEnough = 2700136,
    ErrorCode_FloroRanchStageNotSettle = 2700137,
    ErrorCode_FloroRanchActivitysNotFind = 2700138,
    ErrorCode_FloroRanchGamePlayShopNotExist = 2700139,
    ErrorCode_FloroRanchGamePlayShopItemNotExist = 2700140,
    ErrorCode_FloroRanchDiamondNotEnough = 2700141,
    ErrorCode_FloroRanchCardTableNotExist = 2700142,
    ErrorCode_FloroRanchToyTableNotExist = 2700143,
    ErrorCode_FloroRanchTerrainTableNotExist = 2700144,
    ErrorCode_FloroRanchToyNumLimit = 2700145,
    ErrorCode_FloroRanchNotEnoughToyIndex = 2700146,
    ErrorCode_FloroRanchToyCreateFail = 2700147,
    ErrorCode_FloroRanchCardGroupTableNotExist = 2700148,
    ErrorCode_FloroRanchCardGroupNotExist = 2700149,
    ErrorCode_FloroRanchBuffTableNotExist = 2700150,
    ErrorCode_FloroRanchRemoveUnitNotExist = 2700151,
    ErrorCode_PhantomBattleCardMaxLimit = 2700152,
    ErrorCode_FloroRanchRefreshTableNotExist = 2700153,
    ErrorCode_FloroRanchPlayTaskNotExist = 2700154,
    ErrorCode_FloroRanchSkillTableNotExist = 2700155,
    ErrorCode_FloroRanchSkillUseTimesLimit = 2700156,
    ErrorCode_FloroRanchSkillLogicNotExist = 2700157,
    ErrorCode_FloroRanchSkillLogicErr = 2700158,
    ErrorCode_FloroRanchSkillLogicFail = 2700159,
    ErrorCode_PhantomBattleNameLimitConfErr = 2700160,
    ErrorCode_FloroRanchNotEnableUnlimitedMode = 2700161,
    ErrorCode_PhantomBattleLimitTime = 2700162,
    ErrorCode_FloroRanchToyWeightConfErr = 2700163,
    ErrorCode_FloroRanchAnimalNumLimit = 2700164,
    ErrorCode_FloroRanchRaceTableNotFind = 2700165,
    ErrorCode_FloroRanchRaceLock = 2700166,
    ErrorCode_FloroRanchSkillLock = 2700167,
    ErrorCode_FloroRanchSubInsLock = 2700168,
    ErrorCode_RoleSelfBgmUnableOperate = 2700169,
    ErrorCode_RoleSelfBgmFlyTableNotExist = 2700170,
    ErrorCode_RoleSelfBgmUnableOp = 2700171,
    ErrorCode_FloroRanchInsLock = 2700172,
    ErrorCode_FloroRanchInsConfNotFind = 2700173,
    ErrorCode_FloroRanchInsIdNotFind = 2700174,
    ErrorCode_FloroRanchInsRaceNotInReq = 2700175,
    ErrorCode_FloroRanchUnEnableTribute = 2700176,
    ErrorCode_FloroRanchIsMulti = 2700177,
    ErrorCode_ButtonLockParamLimit = 2700178,
    ErrorCode_ButtonLockParamRepeat = 2700179,
    ErrorCode_PhantomBattlePlayerCardGroupBuildErr = 2700180,
    ErrorCode_PhantomBattleNpcCardGroupBuildErr = 2700181,
    ErrorCode_PhantomBattleNpcRecordLoadFail = 2700182,
    ErrorCode_PhantomBattleCardTypeErr = 2700183,
    ErrorCode_PhantomBattleActTypeErr = 2700184,
    ErrorCode_PhantomNoDurableSkill = 2700185,
    ErrorCode_PhantomBattleAreaCardNumLimit = 2700186,
    ErrorCode_PhantomBattleItemCardNumLimit = 2700187,
    ErrorCode_PhantomBattleCallTaskNumErr = 2700188,
    ErrorCode_PhantomBattleNotCanSoltIndex = 2700189,
    ErrorCode_PhantomBattleSoltMaxLimit = 2700190,
    ErrorCode_PhantomBattleTaskIdErr = 2700191,
    ErrorCode_PhantomBattleActIdErr = 2700192,
    ErrorCode_PhantomBattleConditionParamErr = 2700193,
    ErrorCode_PhantomBattleAreaCardConfigErr = 2700194,
    ErrorCode_PhantomBattleAreaLock = 2700195,
    ErrorCode_PhantomBattleGuideActTableNotExist = 2700196,
    ErrorCode_NewPlayerSupportTaskConfNotExist = 2700197,
    ErrorCode_NewPlayerSupportTaskRewardIndex = 2700198,
    ErrorCode_NewPlayerSupportTaskParamLimit = 2700199,
    ErrorCode_NewPlayerSupportTaskParamRepeat = 2700200,
    ErrorCode_NewPlayerSupportTaskReward = 2700201,
    ErrorCode_NewPlayerSupportTaskNotFinish = 2700202,
    ErrorCode_NewPlayerSupportDataNotEixst = 2700203,
    ErrorCode_NewPlayerSupportNotFindTrialRole = 2700204,
    ErrorCode_NewPlayerSupportRoleLock = 2700205,
    ErrorCode_NewPlayerSupportWorldLvErr = 2700206,
    ErrorCode_NewPlayerSupportRolePageErr = 2700207,
    ErrorCode_NewTrialRoleActivityRoleCheckErr = 2700208,
    ErrorCode_NewTrialRoleActivityInsNotFind = 2700209,
    ErrorCode_NewTrialRoleActivityInsUnableUse = 2700210,
    ErrorCode_NewTrialRoleActivityLogicNotFind = 2700211,
    ErrorCode_NewTrialRoleActivityDelegateNotFind = 2700212,
    ErrorCode_RegressNotFindTrialRole = 2700213,
    ErrorCode_RegressNotFindActivityTrialRole = 2700214,
    ErrorCode_RegressDisposableReward = 2700215,
    ErrorCode_RegressDisposableRewardConfigNotFind = 2700216,
    ErrorCode_RegressPayBonusLimit = 2700217,
    ErrorCode_GachaRoleDevelopInsNotOpen = 2700218,
    ErrorCode_PhantomBattleNoComponent = 2700219,
    ErrorCode_PhantomBattleUnableSkip = 2700220,
    ErrorCode_RegressMaxBonusItemNum = 2700221,
    ErrorCode_RegressBonusRewardNoConfig = 2700222,
    ErrorCode_RegressBonusBuyLvLimit = 2700223,
    ErrorCode_PhantomBattleCallCardLimt = 2700224,
    ErrorCode_PhantomBattleCallItemLimt = 2700225,
    ErrorCode_GachaRoleDevelopInsLimit = 2700226,
    ErrorCode_GachaRolesilentAreaIdNotFind = 2700227,
    ErrorCode_GachaRolesilentAreaUnlock = 2700228,
    ErrorCode_NewTrialRoleActivityNotFindTrialRoleConf = 2700229,
    ErrorCode_PhantomBattleSkipErr = 2700230,
    ErrorCode_NewTrialRoleGachaRoleDevelopNotFind = 2700231,
    ErrorCode_RegressTrialRoleLock = 2700232,
    ErrorCode_NewPlayerSupportTrialRoleLock = 2700233,
    ErrorCode_PhantomBattleCopyCardLimit = 2700234,
    ErrorCode_RegressTrialNoCanRewardTask = 2700235,
    ErrorCode_NewPlayerSupportNoCanRewardTask = 2700236,
    ErrorCode_FarmGoldPointReqLimit = 2700237,
    ErrorCode_FarmGoldPointReqErr = 2700238,
    ErrorCode_FarmGoldPointReqRe = 2700239,
    ErrorCode_FarmGoldLevelReqLimit = 2700240,
    ErrorCode_FarmGoldLevelReqErr = 2700241,
    ErrorCode_FarmGoldLevelReqRe = 2700242,
    ErrorCode_FarmGoldPointRewardDropErr = 2700243,
    ErrorCode_FarmGoldLevelRewardDropErr = 2700244,
    ErrorCode_NewTrialRoleInCurTeam = 2700245,
    ErrorCode_RegressEndTimeErr = 2700246,
    ErrorCode_NewTrialRoleMatchingUnableTrial = 2700247,
    ErrorCode_PhBaFindCd = 2700248,
    ErrorCode_PhBaTargetPlanNotExist = 2700249,
    ErrorCode_PhBaPlanUploadErr = 2700250,
    ErrorCode_PhBaPlanErr = 2700251,
    ErrorCode_PhBaSaveCd = 2700252,
    ErrorCode_PhBaAttrNotInCost = 2700253,
    ErrorCode_PhBaCostMainPropNotExist = 2700254,
    ErrorCode_PhBaFetterGroupLimit = 2700255,
    ErrorCode_PhBaAttrTypeLimit = 2700256,
    ErrorCode_PhBaCostTypeNumLimit = 2700257,
    ErrorCode_PhBaCodeLimit = 2700258,
    ErrorCode_PhBaCodeIllegal = 2700259,
    ErrorCode_PhBaCurUsePlanNotExist = 2700260,
    ErrorCode_PhBaTargetSuitNotExist = 2700261,
    ErrorCode_PhBaPlanFuncNotOpen = 2700262,
    ErrorCode_InsUnableMultiEnter = 2700263,
    ErrorCode_PhBaPlanSuitCountErr = 2700264,
    ErrorCode_PhBaPlanTargetSuitNotExist = 2700265,
    ErrorCode_NewTrialRoleNumLimit = 2700266,
    ErrorCode_PhBaPlanCostTypeRepeat = 2700267,
    ErrorCode_PhBaPlanSuitIdRepeat = 2700268,
    ErrorCode_GateUdpPortNotExist = 2800000,
    ErrorCode_GateKcpGetConvFail = 2800001,
    ErrorCode_ErrScreenActionExecutorNotFind = 2900000,
    ErrorCode_ErrScreenActionInfoNotFind = 2900001,
    ErrorCode_ErrScreenActionTypeNotMatch = 2900002,
    ErrorCode_ErrScreenActionNotFadeInScreen = 2900003,
    ErrorCode_ErrScreenActionNotFadeOutScreen = 2900004,
    ErrorCode_ErrSceneItemSequenceFrameRegister = 2900005,
    ErrorCode_ErrSceneItemSequenceFrameComponentConfig = 2900006,
    ErrorCode_ErrSceneItemSequenceFrameComponent = 2900007,
    ErrorCode_ErrSceneItemSequenceFrame = 2900008,
    ErrorCode_ErrSceneItemSequenceFrameMatchEventCbType = 2900009,
    ErrorCode_ErrSceneItemSequenceFrameNeedServerAction = 2900010,
    ErrorCode_ErrSceneItemSequenceFrameUnAnsEvent = 2900011,
    ErrorCode_ErrSceneBlockSplitNotBlock = 2900027,
    ErrorCode_ErrSunSpiritCollectOverNum = 2900012,
    ErrorCode_ErrSunSpiritInteractAction = 2900013,
    ErrorCode_ErrSunSpiritGetComponentConfig = 2900014,
    ErrorCode_ErrSunSpiritEntityRemove = 2900015,
    ErrorCode_ErrSunSpiritRepeateAdd = 2900016,
    ErrorCode_ErrSunSpiritNumUnEnough = 2900017,
    ErrorCode_ErrSunSpiritEnableEntityHistoryUse = 2900018,
    ErrorCode_ErrSunSpiritGetPlayerTempOccupySunSpiritInfo = 2900019,
    ErrorCode_ErrSunSpiritActionExecutorNotFind = 2900020,
    ErrorCode_ErrSunSpiritActionInfoNotFind = 2900021,
    ErrorCode_ErrSunSpiritActionIndexNotMatch = 2900022,
    ErrorCode_ErrSunSpiritActionTypeNotMatch = 2900023,
    ErrorCode_ErrSunSpiritActionParamOperationType = 2900024,
    ErrorCode_ErrSunSpiritAreaConfig = 2900025,
    ErrorCode_ErrSunSpiritNotHostPlayer = 2900026,
    ErrorCode_ErrResourcePackageSdkCheck = 2900028,
    ErrorCode_ErrResourcePackageFuncClose = 2900029,
    ErrorCode_ErrResourcePackageRedisWrite = 2900030,
    ErrorCode_ErrResourcePackageInvalidToken = 2900031,
    ErrorCode_ErrResourcePackageRateLimiterCircuit = 2900032,
    ErrorCode_ErrResourcePackageRateLimiterRejected = 2900033,
    ErrorCode_ErrResourcePackageException = 2900034,
    ErrorCode_ErrResourcePackageTimeoutRejected = 2900035,
    ErrorCode_ErrLoadCalabashDefault = 3000000,
    ErrorCode_CalabashSkinUnLockErr = 3000001,
    ErrorCode_RepeqtedRequest = 3000002,
    ErrorCode_ErrSynthesisBatchItemNotSupport = 3000003,
    ErrorCode_ErrSynthesisBatchItemDeadLoop = 3000004,
    ErrorCode_ErrSynthesisBatchItemCntNotMatch = 3000005,
    ErrorCode_ErrSynthesisBatchItemReapeat = 3000006,
    ErrorCode_ErrBatchSynthesisCoinOverflow = 3000007,
    ErrorCode_ErrPhantomSkinNotExist = 3000008,
    ErrorCode_ErrPhantomSkinNotUnlock = 3000009,
    ErrorCode_ErrPhantomInteractionNotUnlock = 3000010,
    ErrorCode_ErrIllustratedNotUnlock = 3000011,
    ErrorCode_ErrPhantomInteractionEquipCountNotMatch = 3000012,
    ErrorCode_ErrPhantomInteractionConfigNotFind = 3000013,
    ErrorCode_ErrPhantomSkinRepeatOperation = 3000044,
    ErrorCode_ErrPhantomInteractionNotShowable = 3000045,
    ErrorCode_ErrArtemisNodeNoConfig = 3000014,
    ErrorCode_ErrArtemisActivityNotOpen = 3000015,
    ErrorCode_ErrArtemisNodeNoData = 3000016,
    ErrorCode_ErrArtemisNodeNoUnlock = 3000017,
    ErrorCode_ErrArtemisNodeNotRewardStatus = 3000018,
    ErrorCode_ErrArtemisNodeAlreadyFixed = 3000019,
    ErrorCode_ErrArtemisNodeAlreadyFinished = 3000020,
    ErrorCode_ErrArtemisState = 3000021,
    ErrorCode_ErrArtemisInvalidUpdate = 3000022,
    ErrorCode_ErrIndexOutOfRange = 3000023,
    ErrorCode_ErrArtemisActivityNotExist = 3000024,
    ErrorCode_MotorParkourLevelNoOpen = 3000025,
    ErrorCode_MotorParkourNoConfig = 3000026,
    ErrorCode_MotorParkourInstComponentNotExist = 3000027,
    ErrorCode_MotorParkourGetTimeRecordFailed = 3000028,
    ErrorCode_ErrMotorParkourLevelRewardIndexLengthError = 3000029,
    ErrorCode_ErrMotorParkourActivityDataNotExist = 3000030,
    ErrorCode_ErrMotorParkourLevelRewardIndexInvalid = 3000031,
    ErrorCode_ErrMotorParkourRecordCfgNotExist = 3000032,
    ErrorCode_ErrMotorParkourGetRewardStatusFail = 3000033,
    ErrorCode_ErrMotorParkourRewardNotAvailable = 3000034,
    ErrorCode_ErrMotorParkourLevelRewardIndexDuplicate = 3000035,
    ErrorCode_ErrMotorParkourRewardCfgNotExist = 3000043,
    ErrorCode_ErrMotorParkourLevelInfoFailed = 3000046,
    ErrorCode_ErrMotorParkourPreLevelNotComplete = 3000073,
    ErrorCode_ErrAreaTerminalPinFull = 3000036,
    ErrorCode_ErrAreaTerminalPinExist = 3000037,
    ErrorCode_ErrAreaTerminalPinNotExist = 3000038,
    ErrorCode_ErrAreaTerminalParamError = 3000039,
    ErrorCode_ErrActivityLock = 3000040,
    ErrorCode_ErrFuncLock = 3000041,
    ErrorCode_ErrNoAreaTerminalCfg = 3000042,
    ErrorCode_ErrSpringFestivalActivityConfigNotFound = 3000068,
    ErrorCode_ErrSpringFestivalActivityDataNotFound = 3000069,
    ErrorCode_ErrSpringFestivalComponentNotFound = 3000070,
    ErrorCode_ErrSpringFestivalRuntimeInfoNotFound = 3000071,
    ErrorCode_ErrMultiModeCanNotRequest = 3000083,
    ErrorCode_ErrSpringFestivalActivityNotOpen = 3000084,
    ErrorCode_ErrSpringFestivalFuncNotExist = 3000100,
    ErrorCode_ErrSpringFestivalFuncLock = 3000101,
    ErrorCode_ErrSpringFestivalActivityIdNotMatch = 3000103,
    ErrorCode_ErrFurnitureDiyActivityConfigNotFound = 3000047,
    ErrorCode_ErrFurnitureAreaIdNotExistInActivity = 3000048,
    ErrorCode_ErrFurnitureAreaConfigNotFound = 3000049,
    ErrorCode_ErrFurnitureDiyActivityDataNotFound = 3000050,
    ErrorCode_ErrFurnitureSlotConfigNotExist = 3000051,
    ErrorCode_ErrFurnitureConfigNotExist = 3000052,
    ErrorCode_ErrFurnitureNotAvailable = 3000053,
    ErrorCode_ErrFurnitureAreaDataNotFound = 3000054,
    ErrorCode_ErrSpecificFurnitureCount = 3000055,
    ErrorCode_ErrFurnitureSlotNotSupportChildTag = 3000056,
    ErrorCode_ErrFurnitureSlotNotSupportFurniture = 3000057,
    ErrorCode_ErrFurnitureDiyComponentNotFound = 3000058,
    ErrorCode_ErrNotFurnitureSlotConfig = 3000059,
    ErrorCode_ErrFurnitureSlotConfigSlotCountError = 3000060,
    ErrorCode_ErrFurnitureSlotSubFurnitureCount = 3000061,
    ErrorCode_ErrFurnitureEntityConfigNotFound = 3000062,
    ErrorCode_ErrEntityCreateFailed = 3000063,
    ErrorCode_ErrFurnitureUnloadSubFurnitureNotEmpty = 3000064,
    ErrorCode_ErrEntitiesNull = 3000065,
    ErrorCode_ErrConvertShortIdToFurnitureIdFailed = 3000066,
    ErrorCode_ErrFurnitureSlotDuplicateInRequest = 3000067,
    ErrorCode_ErrFurnitureSlotNotBelongToArea = 3000106,
    ErrorCode_ErrSpringFestivalFurnitureHadUnlock = 3000117,
    ErrorCode_ErrExploreDegreeTypeNotFound = 3000072,
    ErrorCode_ErrActivityBrochureCfgNotFound = 3000074,
    ErrorCode_ErrBrochureRewardRequestEmptyBookItems = 3000075,
    ErrorCode_ErrBrochureCfgNotFound = 3000076,
    ErrorCode_ErrBrochureNotBelongToActivity = 3000077,
    ErrorCode_ErrBrochureNotUnlock = 3000078,
    ErrorCode_ErrBrochureRewardRequestDuplicateBookItem = 3000079,
    ErrorCode_ErrBookItemCfgNotFound = 3000080,
    ErrorCode_ErrBookItemNotFinish = 3000081,
    ErrorCode_ErrBookItemAlreadyRewarded = 3000082,
    ErrorCode_ErrBrochureRewardTimeInvalid = 3000091,
    ErrorCode_ErrBookItemNotBelongToBrochure = 3000104,
    ErrorCode_ErrExhibitionComponentCfgNotExist = 3000085,
    ErrorCode_ErrItemTypeNotMatchExhibitType = 3000086,
    ErrorCode_ErrExhibitConfigTypeInvalid = 3000087,
    ErrorCode_ErrExhibitionComponentNotExist = 3000088,
    ErrorCode_ErrExhibitionPhantomNotExist = 3000089,
    ErrorCode_ErrRepeatedEntity = 3000092,
    ErrorCode_ErrPhonographMusicNotExist = 3000093,
    ErrorCode_ErrMusicNotUnlocked = 3000102,
    ErrorCode_ErrInstanceConfigNotFound = 3000090,
    ErrorCode_ErrInvalidEnterContextCase = 3000094,
    ErrorCode_ErrTetrisLevelInfoDuplicate = 3000095,
    ErrorCode_ErrTetrisActivityDataNotFound = 3000096,
    ErrorCode_ErrTetrisLevelConfigNotExist = 3000097,
    ErrorCode_ErrTetrisLevelRewardDuplicate = 3000098,
    ErrorCode_ErrTetrisLevelStateInvalid = 3000099,
    ErrorCode_ErrActivityNotMatchTetrisLevel = 3000118,
    ErrorCode_ErrTetrisTargetScoreIdNotExist = 3000119,
    ErrorCode_ErrTetrisLevelHasRewarded = 3000120,
    ErrorCode_ErrTetrisLevelNotFinished = 3000121,
    ErrorCode_ErrTetrisLevelDifficultyIndexInvalid = 3000126,
    ErrorCode_ErrTetrisTargetScoreCountNotMatch = 3000127,
    ErrorCode_ErrTetrisScoreInvalid = 3000128,
    ErrorCode_ErrGetVarDefine = 3000129,
    ErrorCode_ErrDataPersistenceTetrisBoardGame = 3000130,
    ErrorCode_ErrTetrisTargetScoreNotEnough = 3000131,
    ErrorCode_ErrTetrisConfigInvalid = 3000132,
    ErrorCode_ErrTetrisPreLevelNotFinished = 3000137,
    ErrorCode_Wlf_test = 3000105,
    ErrorCode_DropCatchNoConfig = 3000107,
    ErrorCode_DropCatchLevelNotOpen = 3000108,
    ErrorCode_ErrDropCatchLevelRewardIndexLengthError = 3000109,
    ErrorCode_ErrDropCatchActivityDataNotExist = 3000110,
    ErrorCode_ErrDropCatchLevelRewardIndexDuplicate = 3000111,
    ErrorCode_ErrDropCatchLevelRewardIndexInvalid = 3000112,
    ErrorCode_ErrDropCatchRewardCfgNotExist = 3000113,
    ErrorCode_ErrDropCatchRewardNotAvailable = 3000114,
    ErrorCode_ErrDropCatchLevelInfoFailed = 3000115,
    ErrorCode_ErrDropCatchLevelScoreInvalid = 3000116,
    ErrorCode_ErrDropCatchEntityComponentNotExist = 3000122,
    ErrorCode_ErrDropCatchComponentNotExist = 3000123,
    ErrorCode_ErrDropCatchRewardCfgNotActivity = 3000124,
    ErrorCode_ErrDropCatchDataNotExist = 3000125,
    ErrorCode_ErrGetSelfXboxOnlineId = 3000133,
    ErrorCode_ErrXboxPlayerInfoRequestLimit = 3000134,
    ErrorCode_ErrGetXboxUserPlayerErr = 3000135,
    ErrorCode_ErrXboxAccountBlocked = 3000136,
    ErrorCode_PhotoFightLevelNotFound = 3100000,
    ErrorCode_PhotoFightActivityNotOpen = 3100001,
    ErrorCode_PhotoFightSceneComponentInfoLost = 3100002,
    ErrorCode_PhotoFightGroupNotFound = 3100003,
    ErrorCode_PhotoFightLevelNotOpen = 3100004,
    ErrorCode_PhotoFightPreInstNotCleared = 3100005,
    ErrorCode_PhotoFightSceneComponentLost = 3100006,
    ErrorCode_PhotoFightTargetStatusHigher = 3100007,
    ErrorCode_PhotoFightNoTargetRole = 3100008,
    ErrorCode_PhotoFightRoleInvalid = 3100009,
    ErrorCode_PhotoFightRewardCfgNotFound = 3100010,
    ErrorCode_PhotoFightRewardInvalidInput = 3100011,
    ErrorCode_PhotoFightAlreadyRewarded = 3100012,
    ErrorCode_PhotoFightCannotRewarded = 3100081,
    ErrorCode_WuWuKujiQuestNotFound = 3100013,
    ErrorCode_WuWuKujiQuestNotOpenDay = 3100014,
    ErrorCode_WuWuKujiQuestAllFinished = 3100015,
    ErrorCode_WuWuKujiActivityNotOpen = 3100016,
    ErrorCode_WuWuKujiPreGuideNotFinished = 3100017,
    ErrorCode_WuWuKujiPreQuestNotFinished = 3100018,
    ErrorCode_WuWuKujiActivityConfigNotFound = 3100019,
    ErrorCode_WuWuKujiTrickTypeInvalid = 3100020,
    ErrorCode_WuWuKujiNoAvailableTrick = 3100021,
    ErrorCode_WuWuKujiAwardGroupCfgNotFound = 3100022,
    ErrorCode_WuWuKujiNoAvailableGroup = 3100023,
    ErrorCode_WuWuKujiGroupRewardTimesExceededMax = 3100024,
    ErrorCode_WuWuKujiGroupRemainTimesError = 3100025,
    ErrorCode_WeatherCtlInvalidInMulti = 3100026,
    ErrorCode_WeatherCtlMapDataNotFound = 3100027,
    ErrorCode_WeatherCtlSwitchCfgNotFound = 3100028,
    ErrorCode_WeatherCtlSwitchLocked = 3100029,
    ErrorCode_WeatherCtlAreaWeatherLocked = 3100030,
    ErrorCode_WeatherCtlAreaDateLocked = 3100031,
    ErrorCode_WeatherCtlAddHourNoNegative = 3100032,
    ErrorCode_WeatherCtlInMulti = 3100052,
    ErrorCode_WeatherCtlInBattle = 3100053,
    ErrorCode_WeatherCtlInQuest = 3100054,
    ErrorCode_WeatherCtlNotInBigWorld = 3100082,
    ErrorCode_WeatherCtlNotOpen = 3100162,
    ErrorCode_InfrArchiveTaskCfgNotFound = 3100033,
    ErrorCode_InfrLevelCfgNotFound = 3100034,
    ErrorCode_InfrShopPhaseCfgNotFound = 3100035,
    ErrorCode_InfrShopGoodsCfgNotFound = 3100036,
    ErrorCode_InfrFireAddExpNegative = 3100037,
    ErrorCode_InfrFireAlreadyMaxLevel = 3100038,
    ErrorCode_InfrFireConditionNotMet = 3100039,
    ErrorCode_InfrRoadBuildCfgNotFound = 3100040,
    ErrorCode_InfrRoadCannotTrace = 3100041,
    ErrorCode_InfrFireShopGoodsNotFound = 3100042,
    ErrorCode_InfrFireShopPhaseNotUnlocked = 3100043,
    ErrorCode_InfrFireShopBuyLimitExceeded = 3100044,
    ErrorCode_InfrFireShopBuyTimesInvalid = 3100045,
    ErrorCode_InfrArchiveTaskInvalidInput = 3100046,
    ErrorCode_InfrArchiveTaskCannotRewarded = 3100047,
    ErrorCode_InfrFireExpNotEnough = 3100048,
    ErrorCode_InfrRoadNotInProgress = 3100049,
    ErrorCode_InfrFireLevelNotInProgress = 3100050,
    ErrorCode_InfrRoadConditionNotMet = 3100051,
    ErrorCode_InfrNotOpen = 3100073,
    ErrorCode_InfrPhoneTaskInvalidInput = 3100083,
    ErrorCode_InfrPhoneTaskCannotRewarded = 3100084,
    ErrorCode_InfrPhoneTaskCfgNotFound = 3100085,
    ErrorCode_InfrRoadSwitchTraceInMulti = 3100173,
    ErrorCode_InfrThemeActivityTaskNotFound = 3100074,
    ErrorCode_InfrThemeActivityTaskRewarded = 3100075,
    ErrorCode_InfrThemeActivityTaskNotComplete = 3100076,
    ErrorCode_InfrThemeActivityInputInvalid = 3100077,
    ErrorCode_InfrThemeActivityIdMisMatch = 3100094,
    ErrorCode_InfrThemeActivityTaskCannotRewarded = 3100078,
    ErrorCode_MotorTechPreNodeLock = 3100055,
    ErrorCode_MotorTechPreNotUpgraded = 3100056,
    ErrorCode_MotorTechLevelLower = 3100057,
    ErrorCode_MotorTechNotUnlocked = 3100058,
    ErrorCode_MotorTechLevelMax = 3100059,
    ErrorCode_MotorTechCfgNotFound = 3100060,
    ErrorCode_MotorLvlConfigNotFound = 3100061,
    ErrorCode_MotorFuncNotOpen = 3100062,
    ErrorCode_MotorTaskCannotRewarded = 3100063,
    ErrorCode_MotorTaskInvalidParam = 3100064,
    ErrorCode_MotorTaskCfgNotFound = 3100065,
    ErrorCode_MotorTechTreeCfgNotFound = 3100066,
    ErrorCode_MotorTechTreeLocked = 3100067,
    ErrorCode_MotorPlayerUsingSkill = 3100068,
    ErrorCode_MotorPlayerClimbing = 3100069,
    ErrorCode_MotorPlayerInWater = 3100070,
    ErrorCode_MotorPlayerInAir = 3100071,
    ErrorCode_MotorPlayerOnMotor = 3100072,
    ErrorCode_MotorTaskNotInOneTree = 3100079,
    ErrorCode_MotorExpInvalid = 3100080,
    ErrorCode_MotorOutlookLocked = 3100086,
    ErrorCode_MotorFrameCfgNotFound = 3100087,
    ErrorCode_MotorStickerCfgNotFound = 3100088,
    ErrorCode_MotorOutlookBanInRegion = 3100089,
    ErrorCode_MotorOutlookConflict = 3100090,
    ErrorCode_MotorStickerPartCountError = 3100091,
    ErrorCode_MotorStickerPartIdError = 3100092,
    ErrorCode_MotorOutlookNotOwned = 3100093,
    ErrorCode_MotorLevelRewardAllClaimed = 3100159,
    ErrorCode_PlayerNotInMotorArea = 3100160,
    ErrorCode_MotorDecorationsCfgNotFound = 3100164,
    ErrorCode_MotorDecorationsPartCountError = 3100165,
    ErrorCode_MotorDecorationsPartIdError = 3100166,
    ErrorCode_MotorTechTreeInCd = 3100175,
    ErrorCode_ArrowSwordLevelCfgNotFound = 3100095,
    ErrorCode_ArrowSwordTalentCfgNotFound = 3100096,
    ErrorCode_ArrowSwordTaskCfgNotFound = 3100097,
    ErrorCode_ArrowSwordItemCfgNotFound = 3100098,
    ErrorCode_ArrowSwordRoleCfgNotFound = 3100099,
    ErrorCode_ArrowSwordPreNotCleared = 3100100,
    ErrorCode_ArrowSwordActivityTypeNotMatch = 3100101,
    ErrorCode_ArrowSwordTaskStatusHigher = 3100102,
    ErrorCode_ArrowSwordInvalidInput = 3100103,
    ErrorCode_ArrowSwordDataOwnerErr = 3100104,
    ErrorCode_ArrowSwordActivityIdMisMatch = 3100105,
    ErrorCode_ArrowSwordTalentLocked = 3100106,
    ErrorCode_ArrowSwordTalentAlreadyInUse = 3100107,
    ErrorCode_ArrowSwordTalentPreNodeNotInUse = 3100108,
    ErrorCode_ArrowSwordActivityCfgNotFound = 3100109,
    ErrorCode_ArrowSwordTalentNotInUse = 3100110,
    ErrorCode_ArrowSwordActivityNotOpen = 3100111,
    ErrorCode_ArrowSwordActivityEnd = 3100112,
    ErrorCode_ArrowSwordComponentNoFind = 3100113,
    ErrorCode_ArrowSwordSaveDataLost = 3100114,
    ErrorCode_ArrowSwordRoleNotUnlock = 3100115,
    ErrorCode_ArrowSwordRankListCd = 3100116,
    ErrorCode_ArrowSwordComponentInstLost = 3100117,
    ErrorCode_ArrowSwordInstNotInProgress = 3100118,
    ErrorCode_ArrowSwordInstNotInitialized = 3100119,
    ErrorCode_ArrowSwordHaveUnfinishedInst = 3100120,
    ErrorCode_MotorFightLevelCfgNotFound = 3100121,
    ErrorCode_MotorFightTalentCfgNotFound = 3100122,
    ErrorCode_MotorFightTaskCfgNotFound = 3100123,
    ErrorCode_MotorFightItemCfgNotFound = 3100124,
    ErrorCode_MotorFightRoleCfgNotFound = 3100125,
    ErrorCode_MotorFightPreNotCleared = 3100126,
    ErrorCode_MotorFightActivityTypeNotMatch = 3100127,
    ErrorCode_MotorFightTaskStatusHigher = 3100128,
    ErrorCode_MotorFightInvalidInput = 3100129,
    ErrorCode_MotorFightDataOwnerErr = 3100130,
    ErrorCode_MotorFightActivityIdMisMatch = 3100131,
    ErrorCode_MotorFightTalentLocked = 3100132,
    ErrorCode_MotorFightTalentAlreadyInUse = 3100133,
    ErrorCode_MotorFightTalentPreNodeNotInUse = 3100134,
    ErrorCode_MotorFightActivityCfgNotFound = 3100135,
    ErrorCode_MotorFightTalentNotInUse = 3100136,
    ErrorCode_MotorFightActivityNotOpen = 3100137,
    ErrorCode_MotorFightActivityEnd = 3100138,
    ErrorCode_MotorFightComponentNoFind = 3100139,
    ErrorCode_MotorFightSaveDataLost = 3100140,
    ErrorCode_MotorFightRoleNotUnlock = 3100141,
    ErrorCode_MotorFightRankListCd = 3100142,
    ErrorCode_MotorFightComponentInstLost = 3100143,
    ErrorCode_MotorFightInstNotInProgress = 3100144,
    ErrorCode_MotorFightInstNotInitialized = 3100145,
    ErrorCode_MotorFightHaveUnfinishedInst = 3100146,
    ErrorCode_MotorFightAlreadySettle = 3100147,
    ErrorCode_MotorFightNoInfiniteLevel = 3100161,
    ErrorCode_MotorFightNoRoundData = 3100163,
    ErrorCode_MotorFightLevelNotOpen = 3100170,
    ErrorCode_MotorFightFirstClearRewardFail = 3100171,
    ErrorCode_MotorFightSettleResultNull = 3100172,
    ErrorCode_EncircleChallengeCfgNotFound = 3100148,
    ErrorCode_EncircleChallengeNotOpen = 3100149,
    ErrorCode_EncirclePreChallengeNotPass = 3100150,
    ErrorCode_EncircleChallengeStepErr = 3100151,
    ErrorCode_EncircleActivityTypeNotMatch = 3100174,
    ErrorCode_EncircleChallengeNotStart = 3100177,
    ErrorCode_EncircleMultiGame = 3100179,
    ErrorCode_EncircleActivityNotOpen = 3100206,
    ErrorCode_FetterGroupNotExist = 3100152,
    ErrorCode_DirectRefiningQualityErr = 3100153,
    ErrorCode_FetterGroupConfigErr = 3100154,
    ErrorCode_FetterGroupDirectRefineLocked = 3100155,
    ErrorCode_PhantomDirectRefiningFetterNotFound = 3100156,
    ErrorCode_PhantomDirectRefiningWeekTimesLimit = 3100157,
    ErrorCode_PhantomMonsterConfNotFound = 3100158,
    ErrorCode_GivebackScoreCannotReward = 3100167,
    ErrorCode_GivebackScoreCfgNotFound = 3100168,
    ErrorCode_GivebackNotOpen = 3100169,
    ErrorCode_GivebackInvalidInput = 3100176,
    ErrorCode_GivebackParseDataError = 3100178,
    ErrorCode_RhythmNotInLimitTime = 3100180,
    ErrorCode_RhythmTaskCfgNotFound = 3100181,
    ErrorCode_RhythmActivityCfgNotFound = 3100182,
    ErrorCode_RhythmPlanetCfgNotFound = 3100183,
    ErrorCode_RhythmLevelCfgNotFound = 3100184,
    ErrorCode_RhythmSubLevelCfgNotFound = 3100185,
    ErrorCode_RhythmRoleCfgNotFound = 3100190,
    ErrorCode_RhythmInputInvalid = 3100186,
    ErrorCode_RhythmActivityDataNotExist = 3100187,
    ErrorCode_RhythmTaskCannotReward = 3100188,
    ErrorCode_RhythmInMulti = 3100189,
    ErrorCode_RhythmSubLevelNotOpen = 3100191,
    ErrorCode_RhythmPreSubLevelNotCompleted = 3100192,
    ErrorCode_RhythmLevelNotOpen = 3100193,
    ErrorCode_RhythmPlanetNotOpen = 3100194,
    ErrorCode_RhythmRoleLock = 3100195,
    ErrorCode_RhythmActivityIdMisMatch = 3100196,
    ErrorCode_RhythmInvalidPayload = 3100197,
    ErrorCode_RhythmActivityTypeNotMatch = 3100198,
    ErrorCode_RhythmNoPartnerRoleId = 3100199,
    ErrorCode_RhythmGetRankInCd = 3100200,
    ErrorCode_RhythmInstNotMatch = 3100201,
    ErrorCode_RhythmActivityEnd = 3100202,
    ErrorCode_RhythmPartnerNotSet = 3100203,
    ErrorCode_RhythmStartInfoLost = 3100204,
    ErrorCode_RhythmSubLevelNotMatch = 3100205,
    ErrorCode_ErrNotGetFightInfoDtType = 3200000,
    ErrorCode_ErrFightInfoDtType = 3200001,
    ErrorCode_ErrSetFightInfoDtType = 3200002,
    ErrorCode_ErrChangeDtTypeParamError = 3200003,
    ErrorCode_ErrCurSceneNotMatch = 3300000,
    ErrorCode_ErrTargetNotForDeadEye = 3300001,
    ErrorCode_ErrDeadEyeCount = 3300002,
    ErrorCode_ErrNoMoveEvent = 3300003,
    ErrorCode_ErrEntityTypeNotSupport = 3300004,
    ErrorCode_ErrExploreSkillNoActions = 3300005,
    ErrorCode_ErrExploreSkillActionMultiGame = 3300006,
    ErrorCode_ErrExploreSkillActionNotExist = 3300007,
    ErrorCode_ErrMonsterNotGameplayTagComp = 3300008,
    ErrorCode_ErrDecalEffectNotFound = 3300009,
    ErrorCode_ErrEntityNotInCurMap = 3300010,
    ErrorCode_ErrEntityNotInCurScene = 3300011,
    ErrorCode_ErrEntityNotForNpcTimeSchedule = 3300012,
    ErrorCode_ErrEntityNotInAnySchedule = 3300013,
    ErrorCode_ErrSplineConfigNotFound = 3300014,
    ErrorCode_ErrSplineIdxOutofBound = 3300015,
    ErrorCode_ErrPositionConfig = 3300016,
    ErrorCode_ErrSplineNotForTimeSchedule = 3300017,
    ErrorCode_ErrBlackScreenIllegalSource = 3400000,
};
pub const ActiveBuffPush = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    On: bool = false,
};
pub const BossRushBuffSelectionStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BuffEmpty = 0,
    BuffSelected = 1,
    BuffLocked = 2,
    BuffInactive = 3,
};
pub const AccessPathTimeServerConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const SceneMode = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Single = 0,
    Multi = 1,
};
pub const TutorialUnlockRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
};
pub const FeiXuePreheatInfo = struct {
    pub const default: @This() = .{};
    id: i32 = 0,
    state: i32 = 0,
    QuestUnlockTime: i64 = 0,
};
pub const MotorFightTalentPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Unlock: bool = false,
    InUse: bool = false,
};
pub const ConditionTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ConditionTaskRunning = 0,
    ConditionTaskFinish = 1,
    ConditionTaskTaken = 2,
};
pub const ArrayIntDouble = struct {
    pub const default: @This() = .{};
    Key: i32 = 0,
    Value: f64 = 0,
};
pub const AchievementProgress = struct {
    pub const default: @This() = .{};
    CurProgress: i32 = 0,
    TotalProgress: i32 = 0,
};
pub const DrownPush = struct {
    pub const default: @This() = .{};
};
pub const AnimationGameplayTagPush = struct {
    pub const default: @This() = .{};
    AddTagIds: i32 = 0,
    RemoveTagIds: bool = false,
};
pub const PlayerBasicInfoGetRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
};
pub const ControlTemporaryTeleportParam = struct {
    pub const default: @This() = .{};
    TemporaryTeleportIds: std.ArrayList(i64) = .empty,
};
pub const OneFishingIllustratedData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    MaxSize: i32 = 0,
    MinSize: i32 = 0,
};
pub const BlockState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BStateAll = 0,
    BStateSimple = 1,
    BStateComplete = 2,
};
pub const PlayMontageTaskAndRequest = struct {
    pub const default: @This() = .{};
    MontageName: []const u8 = "",
    MontagePathHash: i32 = 0,
    SpeedRatio: f32 = 0,
    StartSection: []const u8 = "",
    StartTimeSeconds: f32 = 0,
};
pub const EntityConfigType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    OldEntity = 0,
    Level = 1,
    Global = 2,
    EntityConfigType_Character = 3,
    EntityConfigType_Template = 4,
    EntityConfigType_Prefab = 5,
};
pub const InitHonamiActivityRequest = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
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
pub const CoopRoleInfo = struct {
    pub const default: @This() = .{};
    CoopRoleId: i32 = 0,
    RoleLevel: i32 = 0,
    RewardLevel: i32 = 0,
};
pub const ExitViewDirectionPush = struct {
    pub const default: @This() = .{};
};
pub const DestroyType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NotDelay = 0,
    Delay = 1,
};
pub const MotorTaskRewardPb = struct {
    pub const default: @This() = .{};
    Rewarded: i32 = 0,
    WaitReward: i32 = 0,
    MaxReward: i32 = 0,
};
pub const PlayerTitleLimitInfo = struct {
    pub const default: @This() = .{};
    PlayerTitleId: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const TrapDefenseAuxiliaryPbData = struct {
    pub const default: @This() = .{};
    ConfigId: std.ArrayList(i32) = .empty,
};
pub const AbyssDangoRoleData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Level: i32 = 0,
    EquipItems: std.ArrayList(i32) = .empty,
};
pub const HonamiStoryItemCollectionConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: i32 = 0,
};
pub const DangoMonopolyBoardData = struct {
    pub const default: @This() = .{};
    PropertyIds: std.ArrayList(i32) = .empty,
    RecordDiceRollTimes: i32 = 0,
    RecordTriggerMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const PhantomBattleGuideActivity = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
    DropId: i32 = 0,
    RewardTotalNum: i32 = 0,
    SendReward: bool = false,
    RecordActId: i32 = 0,
};
pub const BeControlledComponentPb = struct {
    pub const default: @This() = .{};
    PlayerEntityId: i64 = 0,
    RelationId: i32 = 0,
    IsShow: bool = false,
    MatchIndex: i32 = 0,
    ConstateId: i64 = 0,
};
pub const CombinationKey = struct {
    pub const default: @This() = .{};
    KeyNameList: std.ArrayList([]const u8) = .empty,
};
pub const ActivateBuffRequest = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    On: bool = false,
};
pub const HonamiStoryScoreRewardInfo = struct {
    pub const default: @This() = .{};
    ScoreRewardId: i32 = 0,
    Status: i32 = 0,
};
pub const ActivateBuffNotify = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    On: bool = false,
};
pub const GatherActivityTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    GatherLock = 0,
    GatherActivityTaskState_GatherRunning = 1,
    GatherActivityTaskState_GatherInComplete = 2,
    GatherActivityTaskState_GatherDone = 3,
    GatherActivityTaskState_GatherTakeReward = 4,
};
pub const GrapplingHookPointComponentPb = struct {
    pub const default: @This() = .{};
    HookLockPointDisabled: bool = false,
};
pub const ResonantChainUnlockRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const Mp4BackgroundColor = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Mp4BackgroundColorBlack = 0,
    Mp4BackgroundColorWhite = 1,
};
pub const PushDataCompleteNotify = struct {
    pub const default: @This() = .{};
};
pub const EntityRemoveInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Type: i32 = 0,
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
pub const AttributesIdsComponentPb = struct {
    pub const default: @This() = .{};
    PbSceneItemAttributeIds: std.ArrayList(i32) = .empty,
};
pub const HeartbeatRequest = struct {
    pub const default: @This() = .{};
    AntiData: []const u8 = "",
};
pub const ActivityCorniceMeetingLevelEntryData = struct {
    pub const default: @This() = .{};
    MaxScore: i32 = 0,
    RemainTime: i32 = 0,
    UnlockTime: i64 = 0,
    RewardedMap: std.ArrayList(i32) = .empty,
};
pub const LoadingConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const WeatherControlInfoWithoutCheckAsyncResponse = struct {
    pub const default: @This() = .{};
    UnlockedWeatherSwitchConfigIdList: std.ArrayList(i32) = .empty,
};
pub const FightFormation = struct {
    pub const default: @This() = .{};
    FormationId: i32 = 0,
    CurRole: i32 = 0,
    RoleIds: std.ArrayList(i32) = .empty,
    IsCurrent: bool = false,
};
pub const ExhibitionComponentPb = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
};
pub const MonsterBoomPush = struct {
    pub const default: @This() = .{};
    Delay: i32 = 0,
};
pub const SoarLevelPlayInfo = struct {
    pub const default: @This() = .{};
    SoarLevelPlatId: i32 = 0,
    HistorySoarScore: i32 = 0,
    ReceiveIds: std.ArrayList(i32) = .empty,
};
pub const SceneTimeInfo = struct {
    pub const default: @This() = .{};
    Hour: i32 = 0,
    Minute: i32 = 0,
    OwnerTimeClockTimeSpan: i64 = 0,
};
pub const HackTargetComponentPb = struct {
    pub const default: @This() = .{};
    HackTargetEntityId: i64 = 0,
};
pub const TaskData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: i32 = 0,
    Progress: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const TeleportFinishRequest = struct {
    pub const default: @This() = .{};
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
pub const MoraleAreaData = struct {
    pub const default: @This() = .{};
    AreaDataId: i32 = 0,
    ExploreBoxReceivedCount: i32 = 0,
};
pub const PassiveSkillRemovePush = struct {
    pub const default: @This() = .{};
    PassiveSkillId: i64 = 0,
    TargetEntityId: i64 = 0,
};
pub const EntityTimelineEventType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    LeftIn = 0,
    LeftOut = 1,
    RightIn = 2,
    RightOut = 3,
};
pub const OrderRemoveBuffNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    StackCount: i32 = 0,
};
pub const Vector = struct {
    pub const default: @This() = .{};
    X: f32 = 0,
    Y: f32 = 0,
    Z: f32 = 0,
};
pub const BuffEffectRequest = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    Index: i32 = 0,
};
pub const PullingFoundationComponentPb = struct {
    pub const default: @This() = .{};
    RelationId: i32 = 0,
    MatchIndex: i32 = 0,
};
pub const FlySkinWearAllRoleRequest = struct {
    pub const default: @This() = .{};
    SkinId: i32 = 0,
};
pub const SmartObjectComponent = struct {
    pub const default: @This() = .{};
    LastPassIndex: i32 = 0,
};
pub const VisionTriggerNotify = struct {
    pub const default: @This() = .{};
    VisionId: i32 = 0,
};
pub const ChangeStateConfirmNotify = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
};
pub const ActivityTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ActivityTaskRunning = 0,
    ActivityTaskFinish = 1,
    ActivityTaskTaken = 2,
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
pub const RefreshVisionEquipGroupData = struct {
    pub const default: @This() = .{};
    IncId: std.ArrayList(i32) = .empty,
    Name: []const u8 = "",
};
pub const PhantomPropInfo = struct {
    pub const default: @This() = .{};
    PhantomPropId: i32 = 0,
    Value: i32 = 0,
};
pub const KeepMovementState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    KeepMovementStateInvalid = 0,
    KeepMovementState_Kite = 1,
    KeepMovementState_Soar = 2,
};
pub const VisionSkillInformation = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
    Level: i32 = 0,
    Quality: i32 = 0,
    VisionEntityId: i64 = 0,
    Index: i32 = 0,
};
pub const RoleOperateSelfBgmRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    IsOpen: bool = false,
};
pub const WeaponSkinRequest = struct {
    pub const default: @This() = .{};
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
pub const LongArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(i64) = .empty,
};
pub const CalabashSkinComponentPb = struct {
    pub const default: @This() = .{};
    CalabashSkinId: i32 = 0,
};
pub const SceneAreaState = struct {
    pub const default: @This() = .{};
    AreaId: i32 = 0,
    State: bool = false,
};
pub const FlagStrongholdInfo = struct {
    pub const default: @This() = .{};
    id: i32 = 0,
    IsPass: bool = false,
};
pub const EntityState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Default = 0,
    Sleep = 1,
    Born = 2,
    Other = 3,
};
pub const GameplayTagData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    TagCount: i32 = 0,
};
pub const TransitionFlowPb = struct {
    pub const default: @This() = .{};
    FlowListName: []const u8 = "",
    FlowId: i32 = 0,
    StateId: i32 = 0,
};
pub const ValidTimeItemRequest = struct {
    pub const default: @This() = .{};
};
pub const DrownRequest = struct {
    pub const default: @This() = .{};
};
pub const AdventreTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    UnFinish = 0,
    Finish = 1,
    Received = 2,
};
pub const RoleBrief = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Level: i32 = 0,
};
pub const TransferCtxPb = struct {
    pub const default: @This() = .{};
    TeleportId: i32 = 0,
};
pub const MainPhantomRecommendInfo = struct {
    pub const default: @This() = .{};
    Usage: i32 = 0,
    MonsterId: i32 = 0,
    FetterGroupId: i32 = 0,
};
pub const AchievementInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const VehicleSource = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    VehicleSourceNone = 0,
    VehicleSourceFishingShip = 1,
    VehicleSourceGongduolaSummon = 2,
};
pub const MotorInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const AnimalDropRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const RogueSeasonReward = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IsReceive: bool = false,
};
pub const DangoActorData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Record: i32 = 0,
    Odds: i32 = 0,
};
pub const HonamiStoryRoleSlot = struct {
    pub const default: @This() = .{};
    SlotId: i32 = 0,
    IsUnlocked: bool = false,
};
pub const FavorItemStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    ItemLocked = 0,
    ItemCanUnLock = 1,
    ItemUnLocked = 2,
};
pub const UpdatePlayStationBlockAccountResponse = struct {
    pub const default: @This() = .{};
};
pub const ConditionTaskStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Undone = 0,
    TaskFinish = 1,
    Received = 2,
};
pub const StringArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList([]const u8) = .empty,
};
pub const RTimeStopPush = struct {
    pub const default: @This() = .{};
    Flag: bool = false,
    IsStopCharacter: bool = false,
    Duration: i32 = 0,
};
pub const TowerInfoData = struct {
    pub const default: @This() = .{};
    DangerLevel: i32 = 0,
    MaxFloor: i32 = 0,
};
pub const FloroRanchSubDungeonData = struct {
    pub const default: @This() = .{};
    DataId: i32 = 0,
    ConditionId: i32 = 0,
    IsLocked: bool = false,
    IsFinished: bool = false,
};
pub const SolarSpeedContext = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    Score: i32 = 0,
    Ranking: i32 = 0,
    StartTime: i32 = 0,
    LapRecord: i32 = 0,
};
pub const VisionEquipGroupInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const LivingStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Alive = 0,
    Dead = 1,
    Init = 2,
};
pub const CumulativeShopSubTaskData = struct {
    pub const default: @This() = .{};
    CanGetReward: i32 = 0,
    ProgressCount: i32 = 0,
    TotalProgressCount: i32 = 0,
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
pub const RemoveBuffByServerIdS2cRequestNotify = struct {
    pub const default: @This() = .{};
    ServerId: i32 = 0,
    StackCount: i32 = 0,
    Reason: i32 = 0,
};
pub const ItemEntry = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    ItemCount: i32 = 0,
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
pub const RoleVisionRecommendAttrRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const UpdatePlayStationBlockAccountRequest = struct {
    pub const default: @This() = .{};
    BlockedIds: std.ArrayList([]const u8) = .empty,
};
pub const MapTraceInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const StarRewardState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    RiskHarvestCanNoReward = 0,
    RiskHarvestCanReward = 1,
    RiskHarvestRewarded = 2,
};
pub const FriendAllRequest = struct {
    pub const default: @This() = .{};
};
pub const SelectDetectionTarget = struct {
    pub const default: @This() = .{};
    DetectionId: i32 = 0,
    Type: i32 = 0,
    Id: i32 = 0,
    IsTrace: i32 = 0,
};
pub const PlayerHeadDataResponse = struct {
    pub const default: @This() = .{};
    PlayerHeadDataIds: std.ArrayList(i32) = .empty,
};
pub const HoldHandComponentPb = struct {
    pub const default: @This() = .{};
    TargetEntityId: i64 = 0,
    HandType: i32 = 0,
    IsFollow: bool = false,
};
pub const EntityCtxPb = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    IncId: i64 = 0,
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
pub const EncircleChallengePb = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    OpenTime: i64 = 0,
    Pass: bool = false,
    MinStep: i32 = 0,
};
pub const BatchBulletCastComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const SignState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Lock = 0,
    Unlock = 1,
    IsReceive = 2,
};
pub const SceneTraceRequest = struct {
    pub const default: @This() = .{};
    SceneTraceId: i64 = 0,
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
pub const QuestState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    InActive = 0,
    QuestState_Available = 1,
    QuestState_InProgress = 2,
    QuestState_Finish = 3,
    QuestState_Delete = 4,
};
pub const RoguelikeCurrencyNotify = struct {
    pub const default: @This() = .{};
    V2s: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const SurvivorsPlayerCharacterPbData = struct {
    pub const default: @This() = .{};
};
pub const ServerPlayStationPlayOnlyStateResponse = struct {
    pub const default: @This() = .{};
    CrossPlayEnabled: bool = false,
};
pub const ActivityRequest = struct {
    pub const default: @This() = .{};
};
pub const SceneLoadingFinishRequest = struct {
    pub const default: @This() = .{};
    SceneId: []const u8 = "",
};
pub const ICustomScreenSpinePb = struct {
    pub const default: @This() = .{};
    SpineId: i32 = 0,
};
pub const PassiveSkillInfo = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    SkillCdEndTime: i64 = 0,
};
pub const AdventureDetectionConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    EffectBeginTime: i64 = 0,
    EffectEndTime: i64 = 0,
};
pub const TsAnimNotifyStateAbsoluteTimeStopRequest = struct {
    pub const default: @This() = .{};
    Flag: bool = false,
    Duration: i32 = 0,
};
pub const FloroRanchSubDungeonHistoryData = struct {
    pub const default: @This() = .{};
    DataId: i32 = 0,
    MaxDays: i32 = 0,
    MaxCoins: i32 = 0,
};
pub const AdventureItemData = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    ItemNum: i32 = 0,
};
pub const MoonChasingTrackMoonHandbookRewardNotify = struct {
    pub const default: @This() = .{};
    Ids: std.ArrayList(i32) = .empty,
};
pub const RogueBossInstData = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    IsUnlock: bool = false,
    CanUnlock: bool = false,
    UnlockTime: i64 = 0,
};
pub const ClientDataComponentPb = struct {
    pub const default: @This() = .{};
    IsStaticInit: bool = false,
    OwnerId: i64 = 0,
    GroupId: i32 = 0,
};
pub const SurvivorsMonsterPbData = struct {
    pub const default: @This() = .{};
    SpawnPointEntityId: i32 = 0,
};
pub const SurvivorsGoldenCoinPbData = struct {
    pub const default: @This() = .{};
};
pub const CaughtInfo = struct {
    pub const default: @This() = .{};
    Attacker: i64 = 0,
    CaughtInfoId: i64 = 0,
    IsEnd: bool = false,
    FightState: i32 = 0,
};
pub const CiacconaGalChoiceData = struct {
    pub const default: @This() = .{};
    ChoiceDataId: i32 = 0,
    SecondState: bool = false,
    FirstState: bool = false,
};
pub const HonamiStoryEquipItemInfo = struct {
    pub const default: @This() = .{};
    MainPropLibraryId: i32 = 0,
    OriBuffTempId: std.ArrayList(i32) = .empty,
    ChildBuffTempId: std.ArrayList(i32) = .empty,
};
pub const RoleShowListUpdateRequest = struct {
    pub const default: @This() = .{};
    RoleList: std.ArrayList(i32) = .empty,
};
pub const PayShopItemType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Normal = 0,
    Direct = 1,
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
pub const ClientStorageMapData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const DFsmBlackboardCustom = struct {
    pub const default: @This() = .{};
    Key: []const u8 = "",
    Value: i32 = 0,
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
};
pub const DirectionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    GravityUp = 0,
    GravityDown = 1,
    GravityLeft = 2,
    GravityRight = 3,
};
pub const NewTrialRoleInfo = struct {
    pub const default: @This() = .{};
    TrialRoleId: i32 = 0,
    WorldLv: i32 = 0,
};
pub const MapUnlockFieldInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const ChangeStateRequest = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    FromState: i32 = 0,
    ToState: i32 = 0,
};
pub const ListenInformation = struct {
    pub const default: @This() = .{};
    Id: std.ArrayList(i32) = .empty,
    Range: f32 = 0,
};
pub const NewBieCourseActivity = struct {
    pub const default: @This() = .{};
    HadTakeReward: std.ArrayList(i32) = .empty,
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
pub const ToughCalcExtraRatioChangeRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    Duration: i32 = 0,
};
pub const TsAnimNotifyStateAbsoluteTimeStopPush = struct {
    pub const default: @This() = .{};
    Flag: bool = false,
    Duration: i32 = 0,
};
pub const LivenessTakeRequest = struct {
    pub const default: @This() = .{};
    Ids: std.ArrayList(i32) = .empty,
};
pub const GachaConsume = struct {
    pub const default: @This() = .{};
    Times: i32 = 0,
    Consume: i32 = 0,
};
pub const EntityOnLandedResponse = struct {
    pub const default: @This() = .{};
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
};
pub const TrapDefenseBuildingPbData = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    battleLevel: i32 = 0,
    ConstructCost: i32 = 0,
    DeconstructReturn: i32 = 0,
};
pub const RoleVisionRecommendDataRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const DropCatchLevelInfo = struct {
    pub const default: @This() = .{};
    DropCatchId: i32 = 0,
    RewardStates: std.ArrayList(i32) = .empty,
    UnlockTime: i64 = 0,
    Score: i32 = 0,
};
pub const RoleConfigInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillBranch: i32 = 0,
};
pub const PlayerHeadDataRequest = struct {
    pub const default: @This() = .{};
};
pub const TalentInfoData = struct {
    pub const default: @This() = .{};
    TalentId: i32 = 0,
    State: i32 = 0,
};
pub const StateComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const DarkCoastDeliveryRequest = struct {
    pub const default: @This() = .{};
    DragonPoolId: i32 = 0,
};
pub const TrapDefenseSpecialCellPbData = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const ServerPlayStationPlayOnlyStateRequest = struct {
    pub const default: @This() = .{};
};
pub const CiacconaGalInspirationData = struct {
    pub const default: @This() = .{};
    InspirationCount: i32 = 0,
    RefreshTime: i64 = 0,
};
pub const FightRoleInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    EntityId: i64 = 0,
    OnStageWithoutControl: bool = false,
};
pub const ModifyEntityCampNotify = struct {
    pub const default: @This() = .{};
    TargetEntityId: i64 = 0,
    Camp: i32 = 0,
};
pub const EntityPositionRequest = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    DungeonInstanceId: i32 = 0,
};
pub const MapCancelTraceRequest = struct {
    pub const default: @This() = .{};
    MarkId: i32 = 0,
};
pub const TotalTopUpRewardInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Score: i32 = 0,
    RewardContent: std.ArrayList(MapEntry(i32, i32)) = .empty,
    Status: i32 = 0,
};
pub const DetectionUnlock = struct {
    pub const default: @This() = .{};
    MonsterDetectionIds: std.ArrayList(i32) = .empty,
    DungeonDetectionIds: std.ArrayList(i32) = .empty,
    SilentAreaDetectionIds: std.ArrayList(i32) = .empty,
};
pub const AdventureManualDataRequest = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
};
pub const SunSpiritTakeUpPb = struct {
    pub const default: @This() = .{};
    TrapEntityConfigId: i32 = 0,
    Index: i32 = 0,
};
pub const DropComponentPb = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    ShowPlanId: i32 = 0,
    ItemCount: i32 = 0,
    EntityConfigId: i32 = 0,
};
pub const PayShopInfoRequest = struct {
    pub const default: @This() = .{};
    Version: []const u8 = "",
};
pub const Function = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Flag: i32 = 0,
};
pub const InterruptSkillInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    SkillId: i32 = 0,
    BulletId: i64 = 0,
};
pub const CombatDataMaxNotify = struct {
    pub const default: @This() = .{};
};
pub const BoardGridPositionInfo = struct {
    pub const default: @This() = .{};
    Row: i32 = 0,
    Column: i32 = 0,
    RotAngle: i32 = 0,
};
pub const RoleSkinChangeRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkinId: i32 = 0,
    IsWearWeaponSkin: bool = false,
};
pub const BoardGridDynamicConfig = struct {
    pub const default: @This() = .{};
    RowIndex: i32 = 0,
    ColumnIndex: i32 = 0,
    Flags: i64 = 0,
};
pub const TeleportTransferRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
};
pub const OrderRemoveBuffByTagsRequest = struct {
    pub const default: @This() = .{};
    TagIds: std.ArrayList(i32) = .empty,
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
pub const ChangeStateNotify = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    FromState: i32 = 0,
    ToState: i32 = 0,
};
pub const HonamiStoryNormalItemInfo = struct {
    pub const default: @This() = .{};
};
pub const FlowStartTeleportCtxPb = struct {
    pub const default: @This() = .{};
    FlowListName: []const u8 = "",
    FlowId: i32 = 0,
    StateId: i32 = 0,
};
pub const IntVector2D = struct {
    pub const default: @This() = .{};
    X: i32 = 0,
    Y: i32 = 0,
};
pub const GachaReward = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    ItemCount: i32 = 0,
};
pub const MailBind = struct {
    pub const default: @This() = .{};
    IsBind: bool = false,
    IsReward: bool = false,
    CloseTime: i64 = 0,
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
pub const DrinkMixRole = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    FirstPass: bool = false,
    MaxLike: bool = false,
    RewardGet: bool = false,
};
pub const GameplayCueRequest = struct {
    pub const default: @This() = .{};
    GameplayCueId: i64 = 0,
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
pub const InterruptSkillInDelayRequest = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
};
pub const StateTagComponentPb = struct {
    pub const default: @This() = .{};
    StateTagId: i32 = 0,
};
pub const ItemLockRequest = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    IncrId: i32 = 0,
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
    IllustratedType_Noun = 8,
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
pub const WeaponItemRequest = struct {
    pub const default: @This() = .{};
};
pub const PlacementItemPb = struct {
    pub const default: @This() = .{};
    LocatedBoardEntityConfigId: i32 = 0,
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
pub const FavorQuestStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Locked = 0,
    CanAccept = 1,
    Accepted = 2,
    Completed = 3,
};
pub const CiacconaGalEndingData = struct {
    pub const default: @This() = .{};
    SubEndingDataId: i32 = 0,
    IsRewarded: bool = false,
};
pub const RoleTagChangePush = struct {
    pub const default: @This() = .{};
    TagId: i32 = 0,
    TagCount: i32 = 0,
};
pub const UseSkillFailPush = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
};
pub const BuffStackCountRequest = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    NewStackCount: i32 = 0,
    IsPrematureRemoval: bool = false,
    InstigatorId: i64 = 0,
};
pub const DFsm = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    CurrentState: i32 = 0,
    Flag: i32 = 0,
    StateElapseTime: i32 = 0,
};
pub const EquipPos = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Weapon = 0,
    WeaponSkin = 1,
    End = 2,
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
pub const PhantomArenaBadge = struct {
    pub const default: @This() = .{};
    BadgeId: i32 = 0,
    IsUnlock: bool = false,
};
pub const InterruptSkillInDelayPush = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
};
pub const RTimeStopInstRequest = struct {
    pub const default: @This() = .{};
    Flag: bool = false,
    Duration: i32 = 0,
};
pub const TransferContextId = struct {
    pub const default: @This() = .{};
    BulletContextId: i64 = 0,
};
pub const EntityRewardItemPb = struct {
    pub const default: @This() = .{};
    HasCount: i32 = 0,
    NextResetTime: i64 = 0,
};
pub const PbMailAttachment = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Count: i32 = 0,
};
pub const NormalItemRequest = struct {
    pub const default: @This() = .{};
};
pub const ClientDeviceLevel = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Low = 0,
    Medium = 1,
    High = 2,
};
pub const PushContextIdNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
};
pub const CharacterBattleStateInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    InBattle: bool = false,
};
pub const SendEquipSkinRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const EntityActiveRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const ConsumptiveTaskType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Unknown = 0,
    Single = 1,
    Cycle = 2,
};
pub const PhantomAutoPutRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    PhantomItemIncrId: std.ArrayList(i32) = .empty,
};
pub const GlobalFixCtxPb = struct {
    pub const default: @This() = .{};
    FixId: i32 = 0,
};
pub const FlagChallengeLevelInfo = struct {
    pub const default: @This() = .{};
    id: i32 = 0,
    UnlockTime: i64 = 0,
    state: i32 = 0,
};
pub const TowerRequest = struct {
    pub const default: @This() = .{};
};
pub const EntityInteractRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    OptionIndex: i32 = 0,
    VisionEntityId: i64 = 0,
};
pub const PhantomArenaCardInfo = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
    IsUnlock: bool = false,
    IsCardOutlookUnlock: bool = false,
};
pub const OneForgeConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
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
pub const QuestDestroyActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const RecoverPropFromServer = struct {
    pub const default: @This() = .{};
    AttrId: i32 = 0,
    Ratio: i32 = 0,
    MaxValue: i32 = 0,
    ValueIncrement: i32 = 0,
};
pub const GuideInfoResponse = struct {
    pub const default: @This() = .{};
    GuideGroupFinishList: std.ArrayList(i32) = .empty,
};
pub const QuestFinishActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
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
pub const PlayerBattleStateChangeNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    InBattle: bool = false,
};
pub const QuestAcceptActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const GachaUsePoolRequest = struct {
    pub const default: @This() = .{};
    GachaId: i32 = 0,
    PoolId: i32 = 0,
};
pub const LanguageSettingUpdateRequest = struct {
    pub const default: @This() = .{};
    Language: i32 = 0,
};
pub const JumpTaskCondInfo = struct {
    pub const default: @This() = .{};
    JumpId: i32 = 0,
    ConditionGroupIds: std.ArrayList(i32) = .empty,
};
pub const SimpleTrackReportAsyncRequest = struct {
    pub const default: @This() = .{};
};
pub const MontagePlayNotify = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
};
pub const DragonPoolInfo = struct {
    pub const default: @This() = .{};
    DragonPoolId: i32 = 0,
    ActiveStatus: i32 = 0,
    Level: i32 = 0,
    InjectedCoreItemCount: i32 = 0,
};
pub const PassiveSkillAddPush = struct {
    pub const default: @This() = .{};
    PassiveSkillId: i64 = 0,
    TargetEntityId: i64 = 0,
};
pub const LobbyListRequest = struct {
    pub const default: @This() = .{};
    IsFriend: bool = false,
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
pub const TrapDefenseMonsterPbData = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const LevelPlayCtxPb = struct {
    pub const default: @This() = .{};
    LevelPlayId: i32 = 0,
};
pub const TeleportDataRequest = struct {
    pub const default: @This() = .{};
};
pub const BuffConsumerComponentPb = struct {
    pub const default: @This() = .{};
    ConstateId: i64 = 0,
};
pub const ScratchTicketConditionData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Progress: i32 = 0,
    FinishedAchievementNum: i32 = 0,
};
pub const ClientStorageStringData = struct {
    pub const default: @This() = .{};
    Data: []const u8 = "",
};
pub const ValidTimeItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Count: i32 = 0,
    IncrId: i32 = 0,
    ExpireTime: i64 = 0,
};
pub const TutorialReceiveRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
};
pub const LevelPlayRewardActionCtxPb = struct {
    pub const default: @This() = .{};
    LevelPlayId: i32 = 0,
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
    reason: []const u8 = "",
};
pub const ActorVisiblePush = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsActorVisible: bool = false,
};
pub const FormationRoleInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    MaxHp: i32 = 0,
    CurHp: i32 = 0,
    Level: i32 = 0,
    RoleSkinId: i32 = 0,
};
pub const ClientCurrentRoleReportPush = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    CurrentRoleId: i32 = 0,
    CurrentEntityId: i64 = 0,
};
pub const TriggerExitSkillRequest = struct {
    pub const default: @This() = .{};
    EnterEntityId: i64 = 0,
    LeaveEntityId: i64 = 0,
};
pub const RacingBetsTimeTuple = struct {
    pub const default: @This() = .{};
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const MotorParkourRewardState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    MotorParkourRewardLocked = 0,
    MotorParkourRewardAvailable = 1,
    MotorParkourRewardRewarded = 2,
};
pub const BabelDebuff = struct {
    pub const default: @This() = .{};
    BuffId: i32 = 0,
    Unlocked: bool = false,
};
pub const FanComponentPb = struct {
    pub const default: @This() = .{};
    NumOfTurns: i32 = 0,
};
pub const SettingInputType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Normal = 0,
    Motorcycle = 1,
};
pub const ANStartRequest = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
    AnIndex: i32 = 0,
};
pub const TransformBuffStackNotify = struct {
    pub const default: @This() = .{};
    BuffHandle: i64 = 0,
    BuffId: i64 = 0,
    BuffStackModifier: i32 = 0,
};
pub const PrivateTag = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    Tags: std.ArrayList([]const u8) = .empty,
};
pub const PhantomConsumeItem = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    Count: i32 = 0,
    ItemId: i32 = 0,
};
pub const BattleFormation = struct {
    pub const default: @This() = .{};
    SelectRoles: std.ArrayList(i32) = .empty,
    BuffSelect: i32 = 0,
};
pub const MonsterCaptureComponentPb = struct {
    pub const default: @This() = .{};
    TemplateId: i32 = 0,
    EntityId: i32 = 0,
    MonsterId: i32 = 0,
};
pub const SceneDateUpdateReason = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    TimeFlowAuto = 0,
    LevelPlayAuto = 1,
    PlayerOperate = 2,
};
pub const MotorDiyOnwedPb = struct {
    pub const default: @This() = .{};
    SkinOwned: std.ArrayList(i32) = .empty,
    StickerOnwed: std.ArrayList(i32) = .empty,
    DecorationsOwned: std.ArrayList(i32) = .empty,
    FrameOwned: std.ArrayList(i32) = .empty,
};
pub const PassiveSkillRemoveNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    SkillIdList: std.ArrayList(i64) = .empty,
};
pub const RemoveGameplayEffectRequest = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    EntityId: i64 = 0,
    IsPrematureRemoval: bool = false,
};
pub const ResonInfo = struct {
    pub const default: @This() = .{};
    ResonId: i32 = 0,
    IsOpen: bool = false,
    Increase: i32 = 0,
};
pub const AbyssPluginItemInfo = struct {
    pub const default: @This() = .{};
    ItemId: i32 = 0,
    Count: i32 = 0,
    IncrId: i32 = 0,
    FuncValue: i32 = 0,
};
pub const TimePointRewardData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    RewardTime: i64 = 0,
    Rewarded: bool = false,
    CanGetReward: bool = false,
};
pub const RoleSaveInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    WeaponIncId: i32 = 0,
    PhantomIncId: std.ArrayList(i32) = .empty,
};
pub const TemplateSpawnerType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    TemplateDefault = 0,
    TemplateMatrix = 1,
};
pub const UnlockRoleSkinListRequest = struct {
    pub const default: @This() = .{};
};
pub const SeamlessTeleportFinishConfigPb = struct {
    pub const default: @This() = .{};
    IsnotStopScreenEffect: bool = false,
    EffectExtraState: i32 = 0,
};
pub const InfluenceInfo = struct {
    pub const default: @This() = .{};
    InfluenceId: i32 = 0,
    RewardIndex: i32 = 0,
    Relation: i32 = 0,
};
pub const LevelPlayDestroyActionCtxPb = struct {
    pub const default: @This() = .{};
    LevelPlayId: i32 = 0,
};
pub const ExecuteQtePush = struct {
    pub const default: @This() = .{};
    DownEntityId: i64 = 0,
    UpEntityId: i64 = 0,
    FnvHash: i32 = 0,
};
pub const TriggerExitSkillPush = struct {
    pub const default: @This() = .{};
    EnterEntityId: i64 = 0,
    LeaveEntityId: i64 = 0,
};
pub const RemoveBuffS2cRequestNotify = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    StackCount: i32 = 0,
    Reason: i32 = 0,
};
pub const HonamiStoryCustomLoadingPb = struct {
    pub const default: @This() = .{};
    LoadingId: i32 = 0,
};
pub const RecommendFetterGroupInfo = struct {
    pub const default: @This() = .{};
    RecommendFetterGroupId: i32 = 0,
    CountNeed: i32 = 0,
};
pub const GuessJokerLevelInfo = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    LevelPass: bool = false,
    UnLock: bool = false,
    RewardGet: bool = false,
    PlayerWin: bool = false,
};
pub const RoleShowEntry = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Level: i32 = 0,
};
pub const BabelBuff = struct {
    pub const default: @This() = .{};
    BuffId: i32 = 0,
    Unlocked: bool = false,
};
pub const PreOpenDetections = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    PreOpenId: i32 = 0,
    PreOpenBeginTime: i64 = 0,
    PreOpenEndTIme: i64 = 0,
};
pub const GetRewardTreasureBoxRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const BattleStateChangeRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    InBattle: bool = false,
};
pub const ActivityRoleGiveData = struct {
    pub const default: @This() = .{};
    IsGetReward: bool = false,
};
pub const EntityOnLandedRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const GachaRequest = struct {
    pub const default: @This() = .{};
    GachaId: i32 = 0,
    GachaTimes: i32 = 0,
};
pub const MotorTaskProcessPb = struct {
    pub const default: @This() = .{};
    Current: i32 = 0,
    Target: i32 = 0,
};
pub const AbyssRewardInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    CanGetReward: bool = false,
    CurrentProgress: i32 = 0,
    TargetProgress: i32 = 0,
    CanUnlock: bool = false,
};
pub const GameplayCuePush = struct {
    pub const default: @This() = .{};
    GameplayCueId: i64 = 0,
};
pub const OneExploreItem = struct {
    pub const default: @This() = .{};
    ExploreProgressId: i32 = 0,
    ExplorePercent: i32 = 0,
    CurCount: i32 = 0,
    TotalCount: i32 = 0,
    IsLocked: bool = false,
};
pub const RoleFavorListRequest = struct {
    pub const default: @This() = .{};
};
pub const InitRangeRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    EntitiesToRequest: std.ArrayList(i64) = .empty,
    IsPlayerInRange: bool = false,
};
pub const BookItemState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BookItemLock = 0,
    BookItemUnlock = 1,
    BookItemRewarded = 2,
};
pub const CrystalMonsterSlotInfo = struct {
    pub const default: @This() = .{};
    EntityIds: std.ArrayList(i32) = .empty,
    MonsterType: i32 = 0,
};
pub const EBulletCreateSource = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NormalSource = 0,
    ReboundSource = 1,
};
pub const DailyAdventureTaskState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    DailyAdventureTaskRunning = 0,
    DailyAdventureTaskFinish = 1,
    DailyAdventureTaskTaken = 2,
};
pub const CumulativeShopTaskData = struct {
    pub const default: @This() = .{};
    Current: i32 = 0,
    TargetProgress: i32 = 0,
};
pub const AdviceSetRequest = struct {
    pub const default: @This() = .{};
    IsShow: bool = false,
};
pub const MaterialInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    AssetName: []const u8 = "",
    IsGroup: bool = false,
};
pub const PbOverRoleRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
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
pub const TriggerComponentPb = struct {
    pub const default: @This() = .{};
    TriggerCount: i32 = 0,
    ExitTriggerCount: i32 = 0,
    ConstateId: i64 = 0,
};
pub const PrivateChatHistoryRequest = struct {
    pub const default: @This() = .{};
    TargetUid: i32 = 0,
    StartIndex: i32 = 0,
};
pub const RoguelikeTokenList = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IsReceive: bool = false,
};
pub const EEndSkillReason = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Default = 0,
    BeginOtherSkill = 1,
    BeHit = 2,
    BeCounter = 3,
};
pub const PhantomPutOnRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    RoleId: i32 = 0,
    Pos: i32 = 0,
};
pub const FloroRanchCommonData = struct {
    pub const default: @This() = .{};
    DataId: i32 = 0,
    ConditionId: i32 = 0,
    IsLocked: bool = false,
};
pub const RoleInstanceList = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    IsUnlock: bool = false,
    CanUnlock: bool = false,
};
pub const MoraleFlag = struct {
    pub const default: @This() = .{};
    FlagId: i32 = 0,
    BoxReceivedCount: i32 = 0,
    BoxTotalCount: i32 = 0,
};
pub const AdviceRequest = struct {
    pub const default: @This() = .{};
};
pub const EquipComponentPb = struct {
    pub const default: @This() = .{};
    WeaponId: i32 = 0,
    WeaponBreachLevel: i32 = 0,
};
pub const RoleSkillBranchModifyRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkillBranch: i32 = 0,
};
pub const PbBattlePassReward = struct {
    pub const default: @This() = .{};
    Level: i32 = 0,
    ItemId: i32 = 0,
    Type: i32 = 0,
};
pub const OrderRemoveBuffRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    StackCount: i32 = 0,
    reason: []const u8 = "",
};
pub const EnterAreaRequest = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    LeaveId: i32 = 0,
};
pub const H5ViewActivityData = struct {
    pub const default: @This() = .{};
    RedDot: bool = false,
};
pub const AddVisionEquipGroupRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Name: []const u8 = "",
};
pub const ForgeInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const SlientFirstAwardState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NotUnlock = 0,
    NotFinish = 1,
    IsFinish = 2,
    SlientFirstAwardState_IsReceive = 3,
};
pub const SkillComponentPb = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
    ConstateId: i64 = 0,
};
pub const RoleVisionMainPhantomRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
};
pub const ExchangeRewardResponse = struct {
    pub const default: @This() = .{};
    ExchangeShareData: std.ArrayList(MapEntry(i32, i32)) = .empty,
    ExchangeRewardData: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const FragileChangeRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Flag: bool = false,
};
pub const CharacterDetachRequest = struct {
    pub const default: @This() = .{};
    EntityA: i64 = 0,
    EntityB: i64 = 0,
};
pub const PartUpdateInfo = struct {
    pub const default: @This() = .{};
    PartIndex: i32 = 0,
    Activated: bool = false,
    Reset: bool = false,
};
pub const JigsawBaseComponentPb = struct {
    pub const default: @This() = .{};
    MoveCount: i32 = 0,
    EntityId: i32 = 0,
    Winner: i32 = 0,
};
pub const MotorDiyInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const LevelPlayInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    IsFirst: bool = false,
    State: i32 = 0,
    UpdateTime: i64 = 0,
    GetRewardCount: i32 = 0,
};
pub const DailyQuestTerminateActionCtxPb = struct {
    pub const default: @This() = .{};
    QuestId: i32 = 0,
};
pub const GetDetectionLabelInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const BlackboardParamType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BlackboardParamType_None = 0,
    BlackboardParamType_Int = 1,
    BlackboardParamType_IntArray = 2,
    BlackboardParamType_Long = 3,
    BlackboardParamType_LongArray = 4,
    BlackboardParamType_Boolean = 5,
    BlackboardParamType_String = 6,
    BlackboardParamType_StringArray = 7,
    BlackboardParamType_Float = 8,
    BlackboardParamType_FloatArray = 9,
    BlackboardParamType_Vector = 10,
    BlackboardParamType_VectorArray = 11,
    BlackboardParamType_Rotator = 12,
    BlackboardParamType_RotatorArray = 13,
    BlackboardParamType_Entity = 14,
    BlackboardParamType_EntityArray = 15,
};
pub const GetMusicInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const InstEnterInfoPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    ChallengedTimes: i32 = 0,
};
pub const TransitionWithCustomLoadingPb = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
};
pub const MotorFightLevelPb = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    OpenTime: i64 = 0,
    Cleared: bool = false,
    BestScore: i32 = 0,
    LastRoleId: i32 = 0,
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
    VDefFactor: i64 = 0,
    VResistanceFactor: f32 = 0,
    VbDamageReduce: f32 = 0,
    VbElementReduce: f32 = 0,
    AEnergyChange: i64 = 0,
    WeaknessLvValue: f32 = 0,
    VWeaknessBuffStack: i64 = 0,
    HitDamageBonusRate: f32 = 0,
    WeakDamageBonusRate: f32 = 0,
};
pub const VisionExploreSkillNotify = struct {
    pub const default: @This() = .{};
    ExploreSkill: i32 = 0,
};
pub const SkinRewardActivityRewardState = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    SkinRewardActivityRewardState_InitState = 0,
    SkinRewardActivityRewardState_TaskComplete = 1,
    SkinRewardActivityRewardState_TaskRewarded = 2,
};
pub const ItemExchangeInfoRequest = struct {
    pub const default: @This() = .{};
};
pub const AccessPathTimeServerConfigRequest = struct {
    pub const default: @This() = .{};
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
pub const LoadEquipData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    SkinId: i32 = 0,
};
pub const SilenceNpcNotify = struct {
    pub const default: @This() = .{};
    vTs: std.ArrayList(MapEntry(i32, bool)) = .empty,
};
pub const PhantomBattleCardSkillUnlockInfo = struct {
    pub const default: @This() = .{};
    CardId: i32 = 0,
    Unlock: bool = false,
    TargetNum: i32 = 0,
    CurNum: i32 = 0,
};
pub const RhythmRedDotPb = struct {
    pub const default: @This() = .{};
    ReadPlanet: std.ArrayList(i32) = .empty,
    ReadSubLevel: std.ArrayList(i32) = .empty,
    ReadRole: std.ArrayList(i32) = .empty,
};
pub const InputSettingRequest = struct {
    pub const default: @This() = .{};
};
pub const TransitionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Empty = 0,
    PlayEffect = 1,
    TransitionType_PlayMp4 = 2,
    TransitionType_CenterText = 3,
    TransitionType_FadeInScreen = 4,
    TransitionType_Seamless = 5,
    TransitionType_WithCharacterDisplay = 6,
    TransitionType_WithCustomLoading = 7,
    TransitionType_WithSpine = 8,
    TransitionType_WithSpecialCustomLoading = 9,
};
pub const RolePhantomEquipInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    PhantomItemIncrId: std.ArrayList(i32) = .empty,
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
    EntityTriggerAction = 7,
    EntityLeaveTrigger = 8,
    EntityDestructible = 9,
    EntityTimelineTrack = 10,
    LevelPlayOpenAction = 11,
    LevelPlayRewardAction = 12,
    QuestActiveAction = 13,
    QuestAcceptAction = 14,
    QuestFinishAction = 15,
    GameCtxType_ChildQuest_BehaviorTreeStartAction_EnterAction = 16,
    GameCtxType_ChildQuest_BehaviorTreeStartAction_FinishAction = 17,
    GameCtxType_QuestSucceed_BehaviorTreeStartAction_FinishAction = 18,
    GameCtxType_QuestFailed_BehaviorTreeStartAction_FinishAction = 19,
    GameCtxType_BehaviorTreeStartAction_EnterAction = 20,
    GameCtxType_EntityConditionListeningAction = 21,
    GameCtxType_PlayFlowChildQuestNode = 22,
    GameCtxType_HandInItemChildQuestNode = 23,
    GameCtxType_DoInteractChildQuestNode = 24,
    GameCtxType_BehaviorTreeStartAction_Action = 25,
    GameCtxType_ExploreInteractAction = 26,
    GameCtxType_LevelPlay = 27,
    GameCtxType_GmLevelAction = 28,
    GameCtxType_GmPlayFlow = 29,
    GameCtxType_SceneItemLifeCycleComponentCreate = 30,
    GameCtxType_SceneItemLifeCycleComponentDetroy = 31,
    GameCtxType_GameCtxGm = 32,
    GameCtxType_FlowActionCtx = 33,
    GameCtxType_BehaviorTerminateAction = 34,
    GameCtxType_ChildQuestNodeFixAction = 35,
    GameCtxType_ConditionNodeFixAction = 36,
    GameCtxType_EntityFixAction = 37,
    GameCtxType_ConditionNode = 38,
    GameCtxType_EntityBeamReceiveAction = 39,
    GameCtxType_EntityGroupFailureAction = 40,
    GameCtxType_ChildQuestNodeCondition = 41,
    GameCtxType_EntityStateChangeConditionAction = 42,
    GameCtxType_RequestPlayerGameCurrStateBt = 43,
    GameCtxType_RequestEntityCurrState = 44,
    GameCtxType_TriggerConditionListeningAction = 45,
    GameCtxType_FlowStartTeleport = 46,
    GameCtxType_EntityVisibleCondition = 47,
    GameCtxType_FailedNodeTeleport = 48,
    GameCtxType_LeaveInstEscActionCtx = 49,
    GameCtxType_TrampleActiveActionCtx = 50,
    GameCtxType_TrampleDeActiveActionCtx = 51,
    GameCtxType_DefaultGameCtx = 52,
    GameCtxType_LevelPlayExploratoryCtx = 53,
    GameCtxType_RenjuCompleteActionCtx = 54,
    GameCtxType_JigsawFoundationMatchedActionCtx = 55,
    GameCtxType_CompositionFixAction = 56,
    GameCtxType_JigsawFoundationUnMatchedActionCtx = 57,
    GameCtxType_HookLockPointActionCtx = 58,
    GameCtxType_ClientTriggerActionCtx = 59,
    GameCtxType_ExploreSkillCustomAction = 60,
    GameCtxType_LevelSequenceFrameEventAction = 61,
    GameCtxType_JigsawFoundationMatchedConditionActionCtx = 62,
    GameCtxType_CameraAlertComponentCreate = 63,
    GameCtxType_RenjuExitMatchedAction = 64,
    GameCtxType_RenjuExitUnMatchedAction = 65,
    GameCtxType_LevelPlayDestroyAction = 66,
    GameCtxType_EffectAreaConditionListeningAction = 67,
    GameCtxType_OccupationInfoAction = 68,
    GameCtxType_EntityHeadInfoCondition = 69,
    GameCtxType_TemplateSpawnerConditionListen = 70,
    GameCtxType_TemplateSpawnerAction = 71,
    GameCtxType_BatchRefresherConditionListen = 72,
    GameCtxType_QuestDestroyAction = 73,
    GameCtxType_RequestGameCurrState = 74,
    GameCtxType_TemplateSpawnerStateConditionListen = 75,
    GameCtxType_CompositionConditionEnterAction = 76,
    GameCtxType_TrapDefenseSystem = 77,
    GameCtxType_SceneItemSequenceFrameEventActionCtx = 78,
    GameCtxType_TargetGearHitPart = 79,
    GameCtxType_GlobalFixCtx = 80,
    GameCtxType_ChildQuestNodeStuckCheckAction = 81,
    GameCtxType_GameCurrFetchVar = 82,
    GameCtxType_EntityAfterConditionActionCtx = 83,
    GameCtxType_ChildQuestNodePreCondition = 84,
    GameCtxType_BtNodePreCondition = 85,
    GameCtxType_DynamicSpawnMonsterRefresherConditionListen = 86,
    GameCtxType_BeamCastHitPlayerActionCtx = 87,
    GameCtxType_MotorSliderCtx = 88,
    GameCtxType_RollBlockGamePlayActionCtx = 89,
    GameCtxType_MotorParkourSystem = 90,
    GameCtxType_TransferCtx = 91,
    GameCtxType_SystemModuleDataSyncComponent = 92,
    GameCtxType_DynamicEntityRewardCtx = 93,
    GameCtxType_elf = 94,
    GameCtxType_MotorFightActivity = 95,
    GameCtxType_PasserByNpcSpawnerConditionListenCtx = 96,
    GameCtxType_EffectAreaListeningAction = 97,
    GameCtxType_SurvivorsSystem = 98,
    GameCtxType_TimeScheduleConditionCtx = 99,
};
pub const EntityPatrolStopRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
};
pub const PayShopPrice = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Count: i32 = 0,
    PromotionCount: i32 = 0,
};
pub const DrownNotify = struct {
    pub const default: @This() = .{};
};
pub const SpecialGachaPair = struct {
    pub const default: @This() = .{};
    TypeId: i32 = 0,
    GachaId: i32 = 0,
};
pub const ENewLinkStage = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    NewLinkStageNone = 0,
    NewLinkStageLock = 1,
    Accumulate = 2,
    Ready = 3,
    Burst = 4,
};
pub const CounterAttackInfo = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    FightState: i32 = 0,
    TriggerCounterType: i32 = 0,
    CounterAnIndex: i32 = 0,
};
pub const BuffEffectCd = struct {
    pub const default: @This() = .{};
    BuffId: i64 = 0,
    ListCdRemaining: std.ArrayList(i32) = .empty,
};
pub const BuffEffectExecutePush = struct {
    pub const default: @This() = .{};
    HandleId: i32 = 0,
    Index: i32 = 0,
};
pub const AnimationGameplayTagRequest = struct {
    pub const default: @This() = .{};
    AddTagIds: i32 = 0,
    RemoveTagIds: bool = false,
};
pub const ChangeVisionGroupNameRequest = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
    Name: []const u8 = "",
};
pub const EntityLoadCompleteNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    EntityIds: std.ArrayList(i64) = .empty,
    EntityIdsUnload: std.ArrayList(i64) = .empty,
};
pub const LogicStateComponentPb = struct {
    pub const default: @This() = .{};
    PositionState: i32 = 0,
    MoveState: i32 = 0,
    DirectionState: i32 = 0,
    PositionSubState: i32 = 0,
};
pub const WebSignRequest = struct {
    pub const default: @This() = .{};
};
pub const ApplyVisionGroupRequest = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
    RoleId: i32 = 0,
};
pub const EnergyInfo = struct {
    pub const default: @This() = .{};
    EnergyCount: i32 = 0,
    LastRenewEnergyTime: i32 = 0,
    EnergyType: i32 = 0,
};
pub const UnlockDetectionLabelInfo = struct {
    pub const default: @This() = .{};
    UnlockedGuideIds: std.ArrayList(i32) = .empty,
    UnlockedDetectionTextIds: std.ArrayList(i32) = .empty,
};
pub const RemoveBuffByIdS2cRequestNotify = struct {
    pub const default: @This() = .{};
    BuffId: i64 = 0,
    StackCount: i32 = 0,
    Reason: i32 = 0,
};
pub const MonthCardRequest = struct {
    pub const default: @This() = .{};
};
pub const BossRushRewardClaimStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Incomplete = 0,
    Claimable = 1,
    Claimed = 2,
};
pub const RogueWeeklyLastInfo = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    CurLayer: i32 = 0,
    MaxLayer: i32 = 0,
    WorldLevel: i32 = 0,
};
pub const AudioState = struct {
    pub const default: @This() = .{};
    TreeOwnerId: i32 = 0,
    TreeIncId: i64 = 0,
    GroupType: []const u8 = "",
    State: []const u8 = "",
};
pub const MatrixInfo = struct {
    pub const default: @This() = .{};
    X: i32 = 0,
    Y: i32 = 0,
};
pub const ICustomScreenBackgroundImagePb = struct {
    pub const default: @This() = .{};
    BgPath: []const u8 = "",
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
pub const MowTowerRewardStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    CanNoReward = 0,
    CanReward = 1,
    Rewarded = 2,
};
pub const FragmentMemoryData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Flag: i32 = 0,
    FinishTime: i64 = 0,
};
pub const FurnitureDiySlotInfo = struct {
    pub const default: @This() = .{};
    SlotEntityCfgId: i32 = 0,
    RootFurnitureId: i32 = 0,
    SubFurnitureIds: std.ArrayList(i32) = .empty,
};
pub const ParkourActivityChallenge = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    BeginTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const ExploreProgressRequest = struct {
    pub const default: @This() = .{};
    AreaIds: std.ArrayList(i32) = .empty,
};
pub const RhythmSubLevelPb = struct {
    pub const default: @This() = .{};
    SubLevelId: i32 = 0,
    Cleared: bool = false,
    BestScore: i32 = 0,
    BestAccuracy: i32 = 0,
    BestRank: i32 = 0,
};
pub const UpdateVoxelEnvRequest = struct {
    pub const default: @This() = .{};
    ServerCaveMode: i32 = 0,
};
pub const TempFishPointInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    CurCount: i32 = 0,
    MaxCount: i32 = 0,
    ConfigId: i32 = 0,
    GamePlayId: i32 = 0,
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
    reason: []const u8 = "",
};
pub const ExecuteQteRequest = struct {
    pub const default: @This() = .{};
    DownEntityId: i64 = 0,
    UpEntityId: i64 = 0,
    FnvHash: i32 = 0,
};
pub const BeamReceiveActionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BeginAction = 0,
    CompleteAction = 1,
    StopAction = 2,
};
pub const ActorVisibleNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsActorVisible: bool = false,
};
pub const AchievementGroupEntry = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    FinishTime: u32 = 0,
    IsReceive: bool = false,
};
pub const CiacconaGalSubEndingData = struct {
    pub const default: @This() = .{};
    SubEndingDataId: i32 = 0,
    IsFinished: bool = false,
    IsRewarded: bool = false,
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
pub const MotorDiyEquippedPb = struct {
    pub const default: @This() = .{};
    SkinEquipped: i32 = 0,
    StickerEquipped: std.ArrayList(i32) = .empty,
    DecorationsEquipped: std.ArrayList(i32) = .empty,
    FrameEquipped: i32 = 0,
};
pub const AdvertisingPageInfo = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    UnlockIndex: i32 = 0,
    RewardedIndex: i32 = 0,
};
pub const EnergySyncRequest = struct {
    pub const default: @This() = .{};
    EnergyTypes: std.ArrayList(i32) = .empty,
};
pub const FsmConditionPassRequest = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    FromState: i32 = 0,
    ToState: i32 = 0,
    ConditionIndex: i32 = 0,
    Value: bool = false,
};
pub const SecGetReportData2FlowRequest = struct {
    pub const default: @This() = .{};
    ReportData: []const u8 = "",
};
pub const PassiveSkillAddRequest = struct {
    pub const default: @This() = .{};
    PassiveSkillId: i64 = 0,
    TargetEntityId: i64 = 0,
};
pub const ActorVisibleRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsActorVisible: bool = false,
};
pub const ActivityInviteNewbie = struct {
    pub const default: @This() = .{};
    InviteCode: []const u8 = "",
    Score: i32 = 0,
    RedDot: bool = false,
};
pub const WeaponBreachRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
};
pub const HookInteractActionType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Hooked = 0,
    ExitMidway = 1,
    ExitEndpoint = 2,
};
pub const SimpleTrackReportMsg = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    LevelPlayId: i32 = 0,
    GainTreasureCount: i32 = 0,
};
pub const BattleStateChangeNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    InBattle: bool = false,
};
pub const RoleTrialTask = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    ChallengeState: i32 = 0,
};
pub const CalabashSkinTakeOnRequest = struct {
    pub const default: @This() = .{};
    SkinId: i32 = 0,
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
pub const AfterTeleportScreenColor = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    AfterTeleportScreenColorBlack = 0,
    AfterTeleportScreenColorWhite = 1,
};
pub const BtType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    BtTypeInvalid = 0,
    BtTypeQuest = 1,
    BtTypeLevelPlay = 2,
    BtTypeInst = 3,
    BtTypeInstDecision = 4,
};
pub const AdviceSettingNotify = struct {
    pub const default: @This() = .{};
    IsShow: bool = false,
};
pub const AttributeEventEffectData = struct {
    pub const default: @This() = .{};
    TriggeredActiveHandles: std.ArrayList(i32) = .empty,
};
pub const LevelData = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    InstId: i32 = 0,
    Roles: std.ArrayList(i32) = .empty,
    GroupId: i32 = 0,
    IsUnlocked: bool = false,
};
pub const StaticHookMoveType = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Hook = 0,
    Pull = 1,
};
pub const AllMsgRequest = struct {
    pub const default: @This() = .{};
};
pub const ActiveBulletHandle = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    HandleId: i32 = 0,
};
pub const MingSuGenInfo = struct {
    pub const default: @This() = .{};
    CreatureGenId: i64 = 0,
};
pub const RoadBookMotorcycleInfo = struct {
    pub const default: @This() = .{};
    MotorcyclePlayId: i32 = 0,
    HistorySoarScore: i32 = 0,
    ReceiveIds: std.ArrayList(i32) = .empty,
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
pub const ConcomitantsComponentPb = struct {
    pub const default: @This() = .{};
    VisionEntityId: std.ArrayList(i64) = .empty,
    CustomEntityIds: std.ArrayList(i64) = .empty,
    PhantomRoleId: i64 = 0,
    BossRushId: i64 = 0,
};
pub const FishingEntrustStatus = enum(i32) {
    pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);
    Created = 0,
    Acceptable = 1,
    Accepted = 2,
};
pub const MotorCreateRequest = struct {
    pub const default: @This() = .{};
    IsCreate: bool = false,
};
pub const FollowShooterComponentPb = struct {
    pub const default: @This() = .{};
    PlayerEntityId: i64 = 0,
    SummonConfigId: i32 = 0,
};
pub const MotorSliderCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    IsEnter: bool = false,
};
pub const BeamCastHitPlayerActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const PbUpLevelRoleRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    ItemList: std.ArrayList(ArrayIntInt) = .empty,
};
pub const WeaponLevelUpResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    IncId: i32 = 0,
    WeaponLevel: i32 = 0,
    WeaponExp: i32 = 0,
    ItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const OrderRemoveBuffByTagsResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const TowerDefenseActivityInfo = struct {
    pub const default: @This() = .{};
    InstanceInfos: std.ArrayList(TowerDefenceInstanceInfo) = .empty,
    RewardedScoreIds: std.ArrayList(i32) = .empty,
    TotalScore: i32 = 0,
    ShowName: bool = false,
};
pub const PbMoveToPointConfig = struct {
    pub const default: @This() = .{};
    TargetPos: ?Vector = null,
    MoveType: i32 = 0,
};
pub const AnimationStateInitRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const RiskHarvestStarRewardInfo = struct {
    pub const default: @This() = .{};
    TargetScore: i32 = 0,
    State: ?StarRewardState = null,
};
pub const ActivityMapExploreData = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(MapEntry(i32, ActivityTaskState)) = .empty,
};
pub const ButtonEnableResult = struct {
    pub const default: @This() = .{};
    Type: ?ButtonType = null,
    Enabled: bool = false,
};
pub const DrownResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const HitEndRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    TargetId: i64 = 0,
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
pub const BoneVisibleChangePush = struct {
    pub const default: @This() = .{};
    BoneVisibleData: ?BoneVisibleData = null,
};
pub const PbUpLevelRoleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    Exp: i32 = 0,
    Level: i32 = 0,
    ItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const LevelGroupData = struct {
    pub const default: @This() = .{};
    GroupId: i32 = 0,
    OpenTime: i64 = 0,
    levels: std.ArrayList(LevelData) = .empty,
};
pub const RoleElementChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const LordGymPassRecord = struct {
    pub const default: @This() = .{};
    LoadGymId: i32 = 0,
    PassTime: i32 = 0,
    RoleIds: std.ArrayList(RoleBrief) = .empty,
};
pub const SysBuffComponentPb = struct {
    pub const default: @This() = .{};
    SysBuffInfos: std.ArrayList(SysBuffInformation) = .empty,
};
pub const MapTraceInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MarkIdList: std.ArrayList(i32) = .empty,
};
pub const AnimalDieRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Pos: ?Vector = null,
};
pub const SkillResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CaughtResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CaughtNotify = struct {
    pub const default: @This() = .{};
    Info: ?CaughtInfo = null,
};
pub const SwitchLogicStatePush = struct {
    pub const default: @This() = .{};
    States: ?LogicStateComponentPb = null,
    ClientEntityId: i64 = 0,
};
pub const EntityLeaveTriggerCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    TriggerEntityIncId: i64 = 0,
};
pub const PrivateChatRequest = struct {
    pub const default: @This() = .{};
    TargetUid: i32 = 0,
    ChatContentType: ?ChatContentType = null,
    Content: []const u8 = "",
};
pub const ActivityLinkageTabData = struct {
    pub const default: @This() = .{};
    TabDataId: i32 = 0,
    EndTime: i64 = 0,
    RewardData: std.ArrayList(ActivityLinkageRewardData) = .empty,
    IsReceive: bool = false,
    StartTime: i64 = 0,
};
pub const FarmGoldData = struct {
    pub const default: @This() = .{};
    PointRewardGet: std.ArrayList(i32) = .empty,
    LevelPlayTasks: std.ArrayList(FarmGoldLevelPlayInfo) = .empty,
};
pub const FsmBlackboardNotify = struct {
    pub const default: @This() = .{};
    FsmBlackBoards: std.ArrayList(DFsmBlackBoard) = .empty,
};
pub const MapCancelTraceResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MarkId: i32 = 0,
};
pub const MonsterDrownResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FormationAttrResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const DErrorResult = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
};
pub const BtnStateRequest = struct {
    pub const default: @This() = .{};
    Type: ?ButtonType = null,
    Types: std.ArrayList(ButtonType) = .empty,
};
pub const EntityGroupFailureCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const LifePointDrawActivityData = struct {
    pub const default: @This() = .{};
    LifePointChallengeData: std.ArrayList(LifePointChallengeData) = .empty,
};
pub const AchievementEntry = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    FinishTime: u32 = 0,
    IsReceive: bool = false,
    Progress: ?AchievementProgress = null,
};
pub const AiBlackboardsResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const GachaUsePoolResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const QuestReviewDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const GivebackInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AnimalDestroyResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const GravityFlipComponent = struct {
    pub const default: @This() = .{};
    Direction: ?DirectionType = null,
};
pub const FadeBackgroundFadeOutEffectPb = struct {
    pub const default: @This() = .{};
    FadeOutEffectPb: ?union(enum) {
        FadeBackgroundFadeOutEffectBlackPb: ?FadeBackgroundFadeOutEffectBlackPb,
    } = null,
};
pub const PlayerMotionRequest = struct {
    pub const default: @This() = .{};
    Motion: ?MotionType = null,
};
pub const MotorCreateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const MotorTechOneTreePb = struct {
    pub const default: @This() = .{};
    TreeId: i32 = 0,
    Tech: std.ArrayList(MotorTechPb) = .empty,
};
pub const GameplayAttributeData = struct {
    pub const default: @This() = .{};
    CurrentValue: i32 = 0,
    ValueIncrement: i32 = 0,
    AttributeType: ?EAttributeType = null,
};
pub const VisionExploreSkillSetRequest = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
    IsAutoChange: bool = false,
    RouletteType: ?RouletteType = null,
};
pub const RogueWeeklyAward = struct {
    pub const default: @This() = .{};
    SignState: ?SignState = null,
    CurProgress: i32 = 0,
    MaxProgress: i32 = 0,
    ConfigId: i32 = 0,
};
pub const RemoveBuffS2cResponsePush = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SwitchLogicStateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AdventreTask = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    State: ?AdventreTaskState = null,
    AdventreProgress: i32 = 0,
};
pub const PhantomLevelUpRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    ConsumeList: std.ArrayList(PhantomConsumeItem) = .empty,
    SlotCount: i32 = 0,
};
pub const MailBindInfoResponse = struct {
    pub const default: @This() = .{};
    MailBind: ?MailBind = null,
};
pub const SwitchLogicStateNotify = struct {
    pub const default: @This() = .{};
    States: ?LogicStateComponentPb = null,
};
pub const SunSpiritPb = struct {
    pub const default: @This() = .{};
    InstId: i32 = 0,
    EntityConfigId: i32 = 0,
    TakeUpData: ?SunSpiritTakeUpPb = null,
};
pub const AreaInfo = struct {
    pub const default: @This() = .{};
    AreaId: i32 = 0,
    Atmosphere: i32 = 0,
    FurnitureDiySlotInfos: std.ArrayList(FurnitureDiySlotInfo) = .empty,
};
pub const PlayerMotionResponse = struct {
    pub const default: @This() = .{};
    ErrorId: ?ErrorCode = null,
};
pub const ItemLockResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RandomInteractCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    OptionIndex: i32 = 0,
};
pub const AdventureRewardData = struct {
    pub const default: @This() = .{};
    DropId: i32 = 0,
    Items: std.ArrayList(AdventureItemData) = .empty,
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
};
pub const BuffStackCountResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AccessPathTimeServerConfigResponse = struct {
    pub const default: @This() = .{};
    AccessPathTimeServerConfig: std.ArrayList(AccessPathTimeServerConfig) = .empty,
};
pub const EntityIsVisibleNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsVisible: bool = false,
    CombatCommon: ?CombatCommon = null,
};
pub const ModifyBulletParamsResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const TriggerExitSkillResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SetFocusModeDeterConditionResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RbRollMovement = struct {
    pub const default: @This() = .{};
    Direction: ?RbGridDirection = null,
};
pub const RTimeStopResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RoleLevelUpViewRequest = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    MaxItemId: i32 = 0,
    ItemList: std.ArrayList(ArrayIntInt) = .empty,
};
pub const WeaponLevelUpRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    ConsumeList: std.ArrayList(WeaponConsumeItem) = .empty,
};
pub const PhantomCollectReward = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        Progress: ?PhantomCollectProgress,
    } = null,
    Type: i32 = 0,
    State: i32 = 0,
};
pub const InputAction = struct {
    pub const default: @This() = .{};
    ActionName: []const u8 = "",
    KeyNameList: std.ArrayList([]const u8) = .empty,
    Version: i32 = 0,
    InputType: ?SettingInputType = null,
};
pub const WeaponResonUpResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    IncId: i32 = 0,
    ResonLevel: i32 = 0,
};
pub const GameplayCueResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
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
    reason: []const u8 = "",
};
pub const AnimalDieResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FlySkinWearResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RoleSkillBranchModifyResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
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
pub const TagComponentPb = struct {
    pub const default: @This() = .{};
    GameplayTags: std.ArrayList(GameplayTagData) = .empty,
    EntityCommonTags: std.ArrayList(i32) = .empty,
    InitGameplayTag: bool = false,
};
pub const ApplyBuffS2cResponsePush = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Handle: i32 = 0,
    IsActive: bool = false,
};
pub const CharacterDetachResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AiInformationResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SwitchCharacterStateRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    OldState: i32 = 0,
    NewState: i32 = 0,
};
pub const EnterViewDirectionResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AnimationStateChangedResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const QuestionaireRewardState = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: ?ActivityTaskState = null,
};
pub const CrystalMonsterInfoPb = struct {
    pub const default: @This() = .{};
    SlotInfoList: std.ArrayList(CrystalMonsterSlotInfo) = .empty,
};
pub const ActivityCorniceMeetingData = struct {
    pub const default: @This() = .{};
    UnlockTime: i64 = 0,
    LevelEntryData: std.ArrayList(MapEntry(i32, ActivityCorniceMeetingLevelEntryData)) = .empty,
};
pub const ExploreSkillCustomCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const WeaponBreachResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    IncId: i32 = 0,
    WeaponBreach: i32 = 0,
};
pub const MonsterDrownRequest = struct {
    pub const default: @This() = .{};
    Pos: ?Vector = null,
};
pub const ActivateBuffResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RTimeStopInstResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PartComponentPb = struct {
    pub const default: @This() = .{};
    PartLifeInfos: std.ArrayList(PartInformation) = .empty,
};
pub const VisionExploreSkillSetResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SkillId: i32 = 0,
};
pub const InputSettingUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const EntityIsVisibleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const DestroyBulletResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const DangoMonopolyConfig = struct {
    pub const default: @This() = .{};
    TaskId: i32 = 0,
    ActivityTaskState: ?DangoMonopolyTaskState = null,
    Progress: i32 = 0,
    TargetProgress: i32 = 0,
};
pub const PbBattlePassRecurringReward = struct {
    pub const default: @This() = .{};
    Type: ?BattlePassType = null,
    ItemId: i32 = 0,
    Count: i32 = 0,
};
pub const DrinkMixData = struct {
    pub const default: @This() = .{};
    RoleLevelInfo: std.ArrayList(DrinkMixRole) = .empty,
};
pub const PartUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FsmStateBehaviorResponse = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const AttrData = struct {
    pub const default: @This() = .{};
    AttributeType: ?EAttributeType = null,
    CurrentValue: i32 = 0,
    ValueIncrement: i32 = 0,
};
pub const EquipWeaponSkinRequest = struct {
    pub const default: @This() = .{};
    Data: ?LoadEquipData = null,
};
pub const FightFormationNotifyInfo = struct {
    pub const default: @This() = .{};
    FormationId: i32 = 0,
    CurRole: i32 = 0,
    RoleInfos: std.ArrayList(FormationRoleInfo) = .empty,
    IsCurrent: bool = false,
};
pub const RolePhantomPropInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    BaseProp: std.ArrayList(ArrayIntInt) = .empty,
    AddProp: std.ArrayList(ArrayIntInt) = .empty,
};
pub const RbBreakableObstaclePbType = struct {
    pub const default: @This() = .{};
    LinkPoints: std.ArrayList(Vector) = .empty,
};
pub const ExploreSkillActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const TowerFloorPb = struct {
    pub const default: @This() = .{};
    TowerConfigId: i32 = 0,
    Star: i32 = 0,
    Formation: std.ArrayList(TowerRolePb) = .empty,
    StarIndex: std.ArrayList(i32) = .empty,
    IsQuickPass: bool = false,
};
pub const FollowerList = struct {
    pub const default: @This() = .{};
    Type: ?FollowerType = null,
    EntityId: i64 = 0,
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
pub const EntityRemoveNotify = struct {
    pub const default: @This() = .{};
    RemoveInfos: std.ArrayList(EntityRemoveInfo) = .empty,
    IsRemove: bool = false,
};
pub const FlowOptionInfoList = struct {
    pub const default: @This() = .{};
    OptionIndexList: std.ArrayList(FlowOptionInfo) = .empty,
};
pub const CaughtRequest = struct {
    pub const default: @This() = .{};
    Info: ?CaughtInfo = null,
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
pub const JigsawFoundationMatchedConditionActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    MatchedIndex: i32 = 0,
    ConditionIndex: i32 = 0,
};
pub const ItemExchangeInfoResponse = struct {
    pub const default: @This() = .{};
    ItemExchangeInfos: std.ArrayList(ItemExchangeInfo) = .empty,
};
pub const RoleOperateSelfBgmResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    IsOpen: bool = false,
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
pub const TransitionWithSpecialCustomLoadingPb = struct {
    pub const default: @This() = .{};
    LoadingType: ?union(enum) {
        HonamiStoryCustomLoadingPb: ?HonamiStoryCustomLoadingPb,
    } = null,
};
pub const BoneVisibleChangeRequest = struct {
    pub const default: @This() = .{};
    BoneVisibleData: ?BoneVisibleData = null,
};
pub const SceneItemStateChangeConditionAction = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    StateIndex: i32 = 0,
    ConditionIndex: i32 = 0,
};
pub const SummonResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AnimationGameplayTagResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CostVisionAttrRecommendInfo = struct {
    pub const default: @This() = .{};
    Cost: i32 = 0,
    GetMainAttrRecommendInfo: std.ArrayList(VisionAttrRecommendInfo) = .empty,
    GetSubAttrRecommendInfo: std.ArrayList(VisionAttrRecommendInfo) = .empty,
};
pub const WeaponResonUpRequest = struct {
    pub const default: @This() = .{};
    IncId: i32 = 0,
    ConsumeList: std.ArrayList(i32) = .empty,
    ConsumeItemList: std.ArrayList(WeaponConsumeItem) = .empty,
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
pub const FragmentMemoryItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Data: std.ArrayList(FragmentMemoryData) = .empty,
    IsUnlock: bool = false,
};
pub const EntityAccessRangeRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    EntitiesToCheck: std.ArrayList(i64) = .empty,
    RangeType: ?RangeType = null,
};
pub const PreheatSignActivityData = struct {
    pub const default: @This() = .{};
    PreheatSignNodeInfos: std.ArrayList(PreheatSignNodeInfo) = .empty,
};
pub const ProtoKeyResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Type: i32 = 0,
    Key: []const u8 = "",
};
pub const OrderApplyBuffResponse = struct {
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
pub const TimeCheckResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ClientTime: i64 = 0,
    ServerTime: i64 = 0,
    ServerCombatTime: i64 = 0,
    ServerStopTime: i64 = 0,
    ServerFlowTimestamp: i64 = 0,
};
pub const TeleportFinishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const UpdateSceneDateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    CurrDate: u32 = 0,
};
pub const AreaExploreInfo = struct {
    pub const default: @This() = .{};
    AreaId: i32 = 0,
    ExploreProgress: std.ArrayList(OneExploreItem) = .empty,
    ExplorePercent: i32 = 0,
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
pub const PartUpdateNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PartInfos: std.ArrayList(PartInformation) = .empty,
};
pub const EntityInteractResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Interacting: bool = false,
};
pub const FavorItem = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: ?FavorItemStatus = null,
};
pub const EnergyUpdateNotify = struct {
    pub const default: @This() = .{};
    UpdateInfo: std.ArrayList(EnergyInfo) = .empty,
};
pub const CaughtPush = struct {
    pub const default: @This() = .{};
    Info: ?CaughtInfo = null,
};
pub const EntityIsVisibleRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsVisible: bool = false,
    CombatCommon: ?CombatCommon = null,
};
pub const MonsterBoomResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RolePassiveSkillInfo = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    PassiveSkillInfoList: std.ArrayList(PassiveSkillInfo) = .empty,
};
pub const FavorQuest = struct {
    pub const default: @This() = .{};
    Chapter: i32 = 0,
    Status: ?FavorQuestStatus = null,
};
pub const RbJumpMovement = struct {
    pub const default: @This() = .{};
    Direction: ?RbGridDirection = null,
};
pub const EntityFollowTrackResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FuncOpenNotify = struct {
    pub const default: @This() = .{};
    Func: std.ArrayList(Function) = .empty,
};
pub const RoleShowListUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RbBlockIdlePbState = struct {
    pub const default: @This() = .{};
    Position: ?Vector = null,
    Rotation: ?Vector = null,
};
pub const VisionFetterRecommendInfo = struct {
    pub const default: @This() = .{};
    Usage: i32 = 0,
    RecommendFetterGroupInfos: std.ArrayList(RecommendFetterGroupInfo) = .empty,
};
pub const ControlParam = struct {
    pub const default: @This() = .{};
    Param: ?union(enum) {
        TemporaryTeleportParam: ?ControlTemporaryTeleportParam,
    } = null,
    ControlType: i32 = 0,
};
pub const EntityPatrolStopResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const DrownEndTeleportResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SettingNotify = struct {
    pub const default: @This() = .{};
    MobileButtonSettings: std.ArrayList(MobileButtonSetting) = .empty,
};
pub const GetDetectionLabelInfoResponse = struct {
    pub const default: @This() = .{};
    UnlockLabelInfo: ?UnlockDetectionLabelInfo = null,
};
pub const EnterGameRequest = struct {
    pub const default: @This() = .{};
    SingleInstanceId: i32 = 0,
    MultiInstanceId: i32 = 0,
    Mode: i32 = 0,
    Pos: ?Vector = null,
};
pub const RemoveGameplayEffectResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Handle: i32 = 0,
};
pub const AllLimitTimeReward = struct {
    pub const default: @This() = .{};
    SignState: ?SignState = null,
    CurProgress: i32 = 0,
    Target: i32 = 0,
    ConfigId: i32 = 0,
};
pub const StorageInfoUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const NormalInteractCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    OptionIndex: i32 = 0,
};
pub const ClientStorageMapMapData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(MapEntry(i32, ClientStorageMapData)) = .empty,
};
pub const ActivityFunPlayChallengeData = struct {
    pub const default: @This() = .{};
    ChallengeId: i32 = 0,
    UnlockTime: i64 = 0,
    RewardStatus: ?FunPlayChallengeRewardStatus = null,
    FunPlaySharpComment: std.ArrayList(i32) = .empty,
    FinishTime: i64 = 0,
};
pub const HonamiStoryRoleData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    RoleSlots: std.ArrayList(HonamiStoryRoleSlot) = .empty,
    DressWeapon: i32 = 0,
};
pub const AnimStateChangeInfoList = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    AnimStateChangeInfo: std.ArrayList(AnimStateChangeInfo) = .empty,
};
pub const GuideFinishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
};
pub const AnimalDropResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const TsAnimNotifyStateAbsoluteTimeStopResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ExploreSkillRouletteUpdateNotify = struct {
    pub const default: @This() = .{};
    RouletteInfo: std.ArrayList(ExploreSkillRoulette) = .empty,
};
pub const ActivityLineCrossData = struct {
    pub const default: @This() = .{};
    Challenges: std.ArrayList(LineCrossChallengeData) = .empty,
};
pub const BuffEffectResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
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
pub const BoneVisibleChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SceneLoadingFinishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SkinRewardActivityRewardInfo = struct {
    pub const default: @This() = .{};
    ConfigId: i32 = 0,
    State: ?SkinRewardActivityRewardState = null,
};
pub const RoleSkinTrialActivity = struct {
    pub const default: @This() = .{};
    RoleSkinTrialContentData: std.ArrayList(RoleSkinTrialContentData) = .empty,
};
pub const UpdateVoxelEnvResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ServerCaveMode: i32 = 0,
};
pub const ActorVisibleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
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
pub const SwitchRoleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
};
pub const SwitchCharacterStateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const UpdateSceneDateRequest = struct {
    pub const default: @This() = .{};
    AddDays: u32 = 0,
    Hour: i32 = 0,
    Minute: i32 = 0,
    Reason: ?SceneDateUpdateReason = null,
};
pub const AiInformationNotify = struct {
    pub const default: @This() = .{};
    AiBlackboardCd: std.ArrayList(Int2Long) = .empty,
};
pub const LogicStateInitResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RbLaserEmitterPbType = struct {
    pub const default: @This() = .{};
    LaserPoints: std.ArrayList(Vector) = .empty,
};
pub const EntityIsVisiblePush = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsVisible: bool = false,
    CombatCommon: ?CombatCommon = null,
};
pub const ApplyGameplayEffectResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ClientTriggerActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    IsEnter: bool = false,
};
pub const RenjuCompleteActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    Controller: i32 = 0,
};
pub const TutorialInfoResponse = struct {
    pub const default: @This() = .{};
    UnlockList: std.ArrayList(TutorialInfo) = .empty,
};
pub const NormalItemResponse = struct {
    pub const default: @This() = .{};
    NormalItemList: std.ArrayList(NormalItem) = .empty,
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
pub const FsmStateBehaviorRequest = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
    Index: i32 = 0,
    Type: ?FsmStateBehaviorType = null,
};
pub const PrivateChatResponse = struct {
    pub const default: @This() = .{};
    TargetUid: i32 = 0,
    ErrorCode: ?ErrorCode = null,
    MsgId: []const u8 = "",
    FilterMsg: []const u8 = "",
};
pub const BattleStateChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PlayMontageTaskAndResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const AiHateNotify = struct {
    pub const default: @This() = .{};
    HateList: std.ArrayList(AiHateEntity) = .empty,
};
pub const ItemDeprecateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ValidTimeItemResponse = struct {
    pub const default: @This() = .{};
    ItemList: std.ArrayList(ValidTimeItem) = .empty,
};
pub const AiHateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
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
pub const JigsawFoundationUnMatchedActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    MatchedIndex: i32 = 0,
};
pub const RhythmShipLevelPb = struct {
    pub const default: @This() = .{};
    LevelId: i32 = 0,
    RhythmSubLevelPb: std.ArrayList(RhythmSubLevelPb) = .empty,
};
pub const DropCatchActivityInfo = struct {
    pub const default: @This() = .{};
    DropCatchLevelInfos: std.ArrayList(DropCatchLevelInfo) = .empty,
};
pub const MonsterDrownPush = struct {
    pub const default: @This() = .{};
    Pos: ?Vector = null,
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
};
pub const PlayerAccessEffectAreaRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    RangeType: ?RangeType = null,
};
pub const StateChangeActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    StateIndex: i32 = 0,
};
pub const DrownEndTeleportPush = struct {
    pub const default: @This() = .{};
    ycu: ?union(enum) {
        TeleportPos: ?Vector,
    } = null,
};
pub const CharacterBattleStateChangeNotify = struct {
    pub const default: @This() = .{};
    CharacterBattleStateInfo: std.ArrayList(CharacterBattleStateInfo) = .empty,
};
pub const OccupiedBoardGridInfo = struct {
    pub const default: @This() = .{};
    Pos: ?BoardGridPositionInfo = null,
    OccupyingEntityConfigId: i32 = 0,
    EntityConfigType: i32 = 0,
};
pub const OrderRemoveBuffResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PartUpdatePush = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PartUpdateInfos: std.ArrayList(PartUpdateInfo) = .empty,
};
pub const SummonerComponentPb = struct {
    pub const default: @This() = .{};
    SummonerId: i64 = 0,
    SummonCfgId: i32 = 0,
    SummonSkillId: i32 = 0,
    PlayerId: i32 = 0,
    Type: ?ESummonType = null,
};
pub const CombinationAction = struct {
    pub const default: @This() = .{};
    ActionName: []const u8 = "",
    CombinationKeyList: std.ArrayList([]const u8) = .empty,
    Version: i32 = 0,
    InputType: ?SettingInputType = null,
};
pub const GetRewardTreasureBoxResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const InputAxis = struct {
    pub const default: @This() = .{};
    AxisName: []const u8 = "",
    KeyScaleMap: std.ArrayList(MapEntry([]const u8, i32)) = .empty,
    Version: i32 = 0,
    InputType: ?SettingInputType = null,
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
};
pub const FlowEndResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const VisionSkillChangeNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    VisionSkillInfos: std.ArrayList(VisionSkillInformation) = .empty,
};
pub const AnimationStateChangedRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const DailyAdventureActivityTask = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Current: i32 = 0,
    Target: i32 = 0,
    Status: ?DailyAdventureTaskState = null,
};
pub const TutorialReceiveResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
    ItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const TrampleActivateCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const PatrolInfoPb = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        SmartObjectComponent: ?SmartObjectComponent,
    } = null,
};
pub const LivenessInfo = struct {
    pub const default: @This() = .{};
    LivenessCount: i32 = 0,
    RewardedLiveness: std.ArrayList(i32) = .empty,
    Tasks: std.ArrayList(LivenessTask) = .empty,
    DayEnd: i64 = 0,
    AreaId: i32 = 0,
};
pub const EnterAreaResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Id: i32 = 0,
};
pub const LanguageSettingUpdateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const BookItemInfo = struct {
    pub const default: @This() = .{};
    BookItemId: i32 = 0,
    BookItemState: ?BookItemState = null,
};
pub const NewLinkStateNotify = struct {
    pub const default: @This() = .{};
    LinkConfigId: i32 = 0,
    Current: ?ENewLinkStage = null,
    PlayerId: i32 = 0,
};
pub const BehaviorTreeCtxPb = struct {
    pub const default: @This() = .{};
    IncId: i64 = 0,
    BtType: ?BtType = null,
    BtId: i32 = 0,
    NodeId: i32 = 0,
};
pub const CalabashSkinDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipedSkinId: i32 = 0,
    SkinIdList: std.ArrayList(i32) = .empty,
};
pub const RoleTagChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const GatherTaskDoneInfo = struct {
    pub const default: @This() = .{};
    TaskId: i32 = 0,
    State: ?GatherActivityTaskState = null,
};
pub const FadeBackgroundFadeInEffectPb = struct {
    pub const default: @This() = .{};
    FadeInEffectPb: ?union(enum) {
        FadeBackgroundFadeInEffectBlackPb: ?FadeBackgroundFadeInEffectBlackPb,
    } = null,
};
pub const IllustratedInfoRequest = struct {
    pub const default: @This() = .{};
    TypeList: std.ArrayList(IllustratedType) = .empty,
};
pub const UpdateFormationRequest = struct {
    pub const default: @This() = .{};
    Formations: std.ArrayList(FightFormation) = .empty,
};
pub const ToughCalcExtraRatioChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const GetMusicInfoResponse = struct {
    pub const default: @This() = .{};
    MusicIds: std.ArrayList(i32) = .empty,
    CurMusicId: i32 = 0,
    ErrorCode: ?ErrorCode = null,
    FavoriteMusicList: std.ArrayList(i32) = .empty,
};
pub const DynamicEntityRewardCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const RemoveBuffByIdS2cResponsePush = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SwitchCharacterStatePush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    OldState: i32 = 0,
    NewState: i32 = 0,
};
pub const MotorFightTalentTreePb = struct {
    pub const default: @This() = .{};
    Talent: std.ArrayList(MotorFightTalentPb) = .empty,
};
pub const ActivityTimePointRewarData = struct {
    pub const default: @This() = .{};
    Rewards: std.ArrayList(TimePointRewardData) = .empty,
};
pub const BossRushScoreRewardData = struct {
    pub const default: @This() = .{};
    RewardDataId: i32 = 0,
    State: ?BossRushRewardClaimStatus = null,
};
pub const AdviceSetResponse = struct {
    pub const default: @This() = .{};
    IsShow: bool = false,
    ErrorCode: ?ErrorCode = null,
};
pub const AiBlackboardCdResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const EntityDestructibleCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const SwitchCharacterStateNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    OldState: i32 = 0,
    NewState: i32 = 0,
};
pub const MapUnlockFieldInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    FieldId: std.ArrayList(i32) = .empty,
};
pub const LevelPlayInfoNotify = struct {
    pub const default: @This() = .{};
    LevelPlayInfo: std.ArrayList(LevelPlayInfo) = .empty,
};
pub const SendEquipSkinResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FragileChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PassiveSkillAddResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const CreateBulletResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const RoleLoadEquipData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    Pos: ?EquipPos = null,
    EquipIncId: i32 = 0,
};
pub const RoleConfigInfoNotify = struct {
    pub const default: @This() = .{};
    RoleConfigs: std.ArrayList(RoleConfigInfo) = .empty,
};
pub const InterruptSkillInDelayResponse = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const PrivateChatOperateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const HitEndResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ClientStorageMapListData = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(MapEntry(i32, ClientStorageListData)) = .empty,
};
pub const RecoverPropChangedNotify = struct {
    pub const default: @This() = .{};
    Attributes: std.ArrayList(RecoverPropFromServer) = .empty,
    Duration: i64 = 0,
};
pub const EntityTriggerCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    TriggerEntityIncId: i64 = 0,
};
pub const LoadingConfigResponse = struct {
    pub const default: @This() = .{};
    LoadingConfig: std.ArrayList(LoadingConfig) = .empty,
};
pub const Mp4BackgroundColorPb = struct {
    pub const default: @This() = .{};
    FadeIn: ?Mp4BackgroundColor = null,
    FadeOut: ?Mp4BackgroundColor = null,
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
pub const SceneItemLifeCycleComponentDestroyCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const ExploreSkillPullGiantCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const MotorIsEnablePush = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    IsEnable: bool = false,
    CombatCommon: ?CombatCommon = null,
};
pub const AiHateRequest = struct {
    pub const default: @This() = .{};
    HateList: std.ArrayList(AiHateEntity) = .empty,
};
pub const MapTraceResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MarkId: i32 = 0,
};
pub const TotalTopUpActivityInfo = struct {
    pub const default: @This() = .{};
    Score: i32 = 0,
    TotalTopUpRewardInfos: std.ArrayList(TotalTopUpRewardInfo) = .empty,
};
pub const TetrisActivityInfo = struct {
    pub const default: @This() = .{};
    TetrisLevelInfos: std.ArrayList(TetrisLevelInfo) = .empty,
};
pub const ConditionTask = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Current: i32 = 0,
    Target: i32 = 0,
    Status: ?ConditionTaskState = null,
};
pub const ParkourActivity = struct {
    pub const default: @This() = .{};
    Challenges: std.ArrayList(ParkourActivityChallenge) = .empty,
};
pub const JigsawFoundationMatchedActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    MatchedIndex: i32 = 0,
};
pub const PrivateChatOperateRequest = struct {
    pub const default: @This() = .{};
    OperateType: ?PrivateChatOperateType = null,
    TargetPlayerId: i32 = 0,
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
};
pub const FormationAttrNotify = struct {
    pub const default: @This() = .{};
    Duration: i64 = 0,
    FormationAttrs: std.ArrayList(FormationAttr) = .empty,
};
pub const HardLevelBuffs = struct {
    pub const default: @This() = .{};
    BuffId: i32 = 0,
    Slot: i32 = 0,
    State: ?BossRushBuffSelectionStatus = null,
};
pub const EntityAfterConditionActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    PreCondtionListeningIndex: i32 = 0,
    AfterCondtionListeningIndex: i32 = 0,
};
pub const ActivityMoonSignInData = struct {
    pub const default: @This() = .{};
    MoonPhaseSelectList: std.ArrayList(MoonSignInConfigData) = .empty,
    IsGrandReward: bool = false,
    CurrentMoonId: i32 = 0,
};
pub const TargetGearHitPartCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    HitPartIndex: i32 = 0,
};
pub const MonthCardResponse = struct {
    pub const default: @This() = .{};
    Days: i32 = 0,
    IsDailyGot: bool = false,
    ErrorCode: ?ErrorCode = null,
};
pub const HitEndPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    TargetId: i64 = 0,
};
pub const BroadcastAddBuffFailedNotify = struct {
    pub const default: @This() = .{};
    BuffId: i64 = 0,
    StackCount: i32 = 0,
    InstigatorId: i64 = 0,
    TransferContextId: ?TransferContextId = null,
};
pub const VectorArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(Vector) = .empty,
};
pub const MaterialResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ResonantChainUnlockResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    ResonantChainGroupIndex: i32 = 0,
};
pub const GuideTriggerResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
};
pub const BoneVisibleChangeNotify = struct {
    pub const default: @This() = .{};
    BoneVisibleData: ?BoneVisibleData = null,
};
pub const FeiXuePreheatActivityInfo = struct {
    pub const default: @This() = .{};
    FeiXuePreheatInfos: std.ArrayList(FeiXuePreheatInfo) = .empty,
};
pub const RacingBetsRewardData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Status: ?ConditionTaskStatus = null,
    Progress: i32 = 0,
    TargetProgress: i32 = 0,
    ConditionFinishState: bool = false,
};
pub const TimelineTrackComponentPb = struct {
    pub const default: @This() = .{};
    Index: i32 = 0,
    ControlDatas: std.ArrayList(TimelineTrackControlDataPb) = .empty,
};
pub const EntityStaticHookMoveResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const ClientCurrentRoleReportResponse = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    CurrentEntityId: i64 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const PartUpdateRequest = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PartUpdateInfos: std.ArrayList(PartUpdateInfo) = .empty,
};
pub const EntityConditionListeningActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    EntityConditionListeningIndex: i32 = 0,
};
pub const RbFloorComponentPb = struct {
    pub const default: @This() = .{};
    GamePlayIncId: i32 = 0,
    Type: i32 = 0,
    OccupiedCellPositions: std.ArrayList(RbGridPosition) = .empty,
};
pub const EnterGameResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ClientWaitingMode: i32 = 0,
    ClientWaitingTime: i32 = 0,
    ClientAutoInInterval: i32 = 0,
};
pub const AiHatePush = struct {
    pub const default: @This() = .{};
    HateList: std.ArrayList(AiHateEntity) = .empty,
};
pub const PbOverRoleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    Breakthrough: i32 = 0,
};
pub const AnimationStateInitResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
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
pub const VehiclePb = struct {
    pub const default: @This() = .{};
    Source: ?VehicleSource = null,
};
pub const MotorParkourLevelInfo = struct {
    pub const default: @This() = .{};
    MotorParkourId: i32 = 0,
    RewardStates: std.ArrayList(MotorParkourRewardState) = .empty,
    UnlockTime: i64 = 0,
    BestPassTime: i32 = 0,
};
pub const AttributeChangedResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const PassiveSkillItemPb = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    SkillId: i64 = 0,
};
pub const ExecuteQteResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SwitchLogicStateRequest = struct {
    pub const default: @This() = .{};
    States: ?LogicStateComponentPb = null,
    ClientEntityId: i64 = 0,
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
};
pub const LongShanMainData = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Tasks: std.ArrayList(LongShanMainTaskData) = .empty,
    CanUnlock: bool = false,
    BeginOpenTime: i64 = 0,
    EndOpenTime: i64 = 0,
};
pub const RoleSkinChangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const InstDataNotify = struct {
    pub const default: @This() = .{};
    EnterInfos: std.ArrayList(InstEnterInfoPb) = .empty,
};
pub const CharacterAttachResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const WeaponItemResponse = struct {
    pub const default: @This() = .{};
    WeaponItemList: std.ArrayList(WeaponItem) = .empty,
};
pub const ShieldUpdateInfo = struct {
    pub const default: @This() = .{};
    Handle: i32 = 0,
    ConfigId: i32 = 0,
    ShieldValue: i32 = 0,
    UpdateType: ?EShieldUpdateType = null,
};
pub const VisionSkillComponentPb = struct {
    pub const default: @This() = .{};
    VisionSkillInfos: std.ArrayList(VisionSkillInformation) = .empty,
};
pub const TeleportDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Ids: std.ArrayList(i32) = .empty,
};
pub const CounterAttackPush = struct {
    pub const default: @This() = .{};
    CounterAttackInfo: ?CounterAttackInfo = null,
};
pub const AnimationStateChangedPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
};
pub const RoleTrialInfoActivity = struct {
    pub const default: @This() = .{};
    RoleTrialTask: std.ArrayList(RoleTrialTask) = .empty,
};
pub const ScratchTicketRoundData = struct {
    pub const default: @This() = .{};
    RoundId: i32 = 0,
    UnlockTime: i64 = 0,
    AreaStageRewardDataList: std.ArrayList(MapEntry(i32, ScratchCardRewardData)) = .empty,
    LeftRewardItem: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const RotatorArrayBlackboard = struct {
    pub const default: @This() = .{};
    Values: std.ArrayList(Rotator) = .empty,
};
pub const AnimationStateComponentPb = struct {
    pub const default: @This() = .{};
    AnimationStates: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    BoneVisibleDatas: std.ArrayList(BoneVisibleData) = .empty,
    AnimationTags: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
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
pub const ExitViewDirectionResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const SceneItemLifeCycleComponentCreateCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
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
pub const FsmCustomBlackboardDatas = struct {
    pub const default: @This() = .{};
    BlackboardIntValues: std.ArrayList(DFsmBlackboardCustom) = .empty,
};
pub const RacingBetsSeasonData = struct {
    pub const default: @This() = .{};
    CurCash: i32 = 0,
    TotalCash: i32 = 0,
    RacingBetsLegMatchData: std.ArrayList(RacingBetsLegMatchData) = .empty,
    HitNum: i32 = 0,
};
pub const CalabashSkinTakeOnResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SkinId: i32 = 0,
};
pub const ShieldComponentPb = struct {
    pub const default: @This() = .{};
    ShieldInfoPbList: std.ArrayList(ShieldInfoPb) = .empty,
    ShieldValueTotal: i32 = 0,
};
pub const InfluenceInfoResponse = struct {
    pub const default: @This() = .{};
    InfluenceInfos: std.ArrayList(InfluenceInfo) = .empty,
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
pub const ItemDict = struct {
    pub const default: @This() = .{};
    Items: std.ArrayList(ItemEntry) = .empty,
};
pub const PassiveSkillRemoveResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
};
pub const FormationAttrRequest = struct {
    pub const default: @This() = .{};
    Duration: i64 = 0,
    FormationAttrs: std.ArrayList(FormationAttr) = .empty,
};
pub const ActivityTask = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Current: i32 = 0,
    Target: i32 = 0,
    Status: ?ActivityTaskState = null,
    PreItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const EncircleActivityPb = struct {
    pub const default: @This() = .{};
    Challenges: std.ArrayList(EncircleChallengePb) = .empty,
};
pub const EntityGroupActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    TriggerIndex: i32 = 0,
    IsMatch: bool = false,
};
pub const PbAdviceContent = struct {
    pub const default: @This() = .{};
    Type: ?PbAdviceContentType = null,
    Id: i32 = 0,
    Word: i32 = 0,
};
pub const TrampleDeActiveCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
};
pub const LivenessTakeResponse = struct {
    pub const default: @This() = .{};
    Ids: std.ArrayList(i32) = .empty,
    ErrorCode: ?ErrorCode = null,
};
pub const AnimationStateInitPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Id: i64 = 0,
    States: std.ArrayList(i32) = .empty,
    SpecialStates: std.ArrayList(i32) = .empty,
    ModelId: i32 = 0,
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
};
pub const TutorialUnlockResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
    UnLockInfo: ?TutorialInfo = null,
};
pub const DeleteVisionEquipGroupResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
};
pub const RelativeMoveReplaySample = struct {
    pub const default: @This() = .{};
    BaseMovementEntityId: i64 = 0,
    RelativeLocation: ?Vector = null,
    RelativeRotation: ?Rotator = null,
};
pub const ActivityTaskData = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(ActivityTask) = .empty,
};
pub const DragonPoolDropItems = struct {
    pub const default: @This() = .{};
    DragonPoolId: i32 = 0,
    DropIds: std.ArrayList(i32) = .empty,
    DropItems: std.ArrayList(ItemDict) = .empty,
};
pub const FightRoleInfos = struct {
    pub const default: @This() = .{};
    GroupType: i32 = 0,
    FightRoleInfos: std.ArrayList(FightRoleInfo) = .empty,
    CurRole: i32 = 0,
    LivingStatus: ?LivingStatus = null,
    IsFixedLocation: bool = false,
};
pub const MonsterGachaDataPb = struct {
    pub const default: @This() = .{};
    MonsterCrystalInfoList: std.ArrayList(CrystalMonsterInfoPb) = .empty,
};
pub const CoopTaskCompleteInfo = struct {
    pub const default: @This() = .{};
    CoopTaskId: i32 = 0,
    Task: ?ConditionTask = null,
    UnLockTime: i64 = 0,
    LevelPlay1Done: bool = false,
    LevelPlay2Done: bool = false,
};
pub const DestroyBulletResponsePush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
};
pub const ChangeVisionGroupNameResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
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
pub const CircumFluenceTaskData = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(ActivityTask) = .empty,
    ClaimedReward: std.ArrayList(ActivityTask) = .empty,
    TaskScoreRewardId: std.ArrayList(i32) = .empty,
    NowOpen: bool = false,
    EndTime: i64 = 0,
    NextRefreshTime: i64 = 0,
};
pub const CharacterAttachInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
    PartIndex: i32 = 0,
};
pub const AddVisionEquipGroupResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
};
pub const PhantomPutOnResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipInfoList: std.ArrayList(RolePhantomEquipInfo) = .empty,
};
pub const EquipWeaponSkinResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    DataList: std.ArrayList(LoadEquipData) = .empty,
};
pub const DailyAdventureActivityData = struct {
    pub const default: @This() = .{};
    DailyAdventureActivityTasks: std.ArrayList(DailyAdventureActivityTask) = .empty,
    PtRewardTaken: std.ArrayList(i32) = .empty,
};
pub const CompositionEnterActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
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
};
pub const EquipTakeOnRequest = struct {
    pub const default: @This() = .{};
    Data: ?RoleLoadEquipData = null,
};
pub const ActivityMoraleData = struct {
    pub const default: @This() = .{};
    AreaData: std.ArrayList(MoraleAreaData) = .empty,
    MoraleProgressReward: std.ArrayList(i32) = .empty,
    MoraleFlags: std.ArrayList(MoraleFlag) = .empty,
};
pub const EnergySyncResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SyncInfo: std.ArrayList(EnergyInfo) = .empty,
};
pub const PrivateMessageNotify = struct {
    pub const default: @This() = .{};
    ChatContent: ?ChatContentProto = null,
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
pub const SceneFishPointInfo = struct {
    pub const default: @This() = .{};
    FishPoints: std.ArrayList(SceneFishPointData) = .empty,
    TempFishPoints: std.ArrayList(TempFishPointInfo) = .empty,
};
pub const ChangeStateResponse = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    Error: ?DErrorResult = null,
    CurrentState: i32 = 0,
};
pub const EntitySimplyMoveInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Location: ?Vector = null,
    Rotation: ?Rotator = null,
};
pub const PrivateChatHistoryContentProto = struct {
    pub const default: @This() = .{};
    TargetUid: i32 = 0,
    Chats: std.ArrayList(ChatContentProto) = .empty,
    HistoryIsEnd: bool = false,
    TotalNums: i32 = 0,
};
pub const ChildQuestNodeEnterActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const MaterialPush = struct {
    pub const default: @This() = .{};
    MaterialInfo: ?MaterialInfo = null,
    CombatCommon: ?CombatCommon = null,
};
pub const ICustomScreenTypeBasePb = struct {
    pub const default: @This() = .{};
    ScreenPb: ?union(enum) {
        ICustomScreenSpinePb: ?ICustomScreenSpinePb,
        ICustomScreenBackgroundImagePb: ?ICustomScreenBackgroundImagePb,
    } = null,
};
pub const PhotoMemoryResponse = struct {
    pub const default: @This() = .{};
    Item: std.ArrayList(FragmentMemoryItem) = .empty,
};
pub const ExploreProgressResponse = struct {
    pub const default: @This() = .{};
    AreaProgress: std.ArrayList(AreaExploreInfo) = .empty,
};
pub const ActivityLinkageData = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    Data: std.ArrayList(ActivityLinkageTabData) = .empty,
};
pub const GatherActivityInfo = struct {
    pub const default: @This() = .{};
    GatherTaskDoneInfo: std.ArrayList(GatherTaskDoneInfo) = .empty,
};
pub const DestroyBulletRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
};
pub const RollBlockGamePlayActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
    ParamType: i32 = 0,
};
pub const EntityPositionResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Pos: ?Vector = null,
};
pub const SecGetReportData2FlowResponse = struct {
    pub const default: @This() = .{};
    Error: ?DErrorResult = null,
};
pub const AttributeChangedNotify = struct {
    pub const default: @This() = .{};
    Attributes: std.ArrayList(GameplayAttributeData) = .empty,
};
pub const Transform = struct {
    pub const default: @This() = .{};
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
};
pub const StuckCheckCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
    Index: i32 = 0,
};
pub const AiBlackboardCdNotify = struct {
    pub const default: @This() = .{};
    AiBlackboardCdDel: std.ArrayList(i32) = .empty,
    AiBlackboardCdModify: std.ArrayList(Int2Long) = .empty,
    AiBlackboardCdComplete: std.ArrayList(Int2Bool) = .empty,
};
pub const EntityLivingStatusNotify = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    LivingStatus: ?LivingStatus = null,
    DropVisionItem: std.ArrayList(DropVisionItemResult) = .empty,
};
pub const BlackCoastThemeStageInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Tasks: std.ArrayList(ActivityTask) = .empty,
};
pub const RhythmTaskPb = struct {
    pub const default: @This() = .{};
    TaskType: i32 = 0,
    Task: std.ArrayList(ConditionTask) = .empty,
};
pub const RoleActivateSkillResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    SkillInfo: ?ArrayIntInt = null,
};
pub const LogicStateInitNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    EntityId: i64 = 0,
    InitData: ?LogicStateComponentPb = null,
};
pub const FsmConditionPassResponse = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    Error: ?DErrorResult = null,
};
pub const MaterialRequest = struct {
    pub const default: @This() = .{};
    MaterialInfo: ?MaterialInfo = null,
    CombatCommon: ?CombatCommon = null,
};
pub const ANStartResponse = struct {
    pub const default: @This() = .{};
    SkillId: i64 = 0,
    MontageIndex: i32 = 0,
    AnIndex: i32 = 0,
    Error: ?DErrorResult = null,
};
pub const TrapDefenseRewardData = struct {
    pub const default: @This() = .{};
    ActivityServerRewardItemData: ?ConditionTask = null,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
};
pub const HandInItemChildQuestNodeCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const FriendApply = struct {
    pub const default: @This() = .{};
    Info: ?PlayerDetails = null,
    CreatedTime: i64 = 0,
};
pub const TemplateSpawnerActionCtxPb = struct {
    pub const default: @This() = .{};
    Type: ?union(enum) {
        DestroyType: ?DestroyType,
    } = null,
    EntityCtx: ?EntityCtxPb = null,
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
pub const FriendInfo = struct {
    pub const default: @This() = .{};
    Info: ?PlayerDetails = null,
    Remark: []const u8 = "",
};
pub const AttributeComponentPb = struct {
    pub const default: @This() = .{};
    HardnessModeId: i32 = 0,
    RageModeId: i32 = 0,
    AttrData: std.ArrayList(AttrData) = .empty,
};
pub const FailedNodeActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const ControlInfoNotify = struct {
    pub const default: @This() = .{};
    ForbidList: std.ArrayList(ControlParam) = .empty,
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
pub const OneBrochureInfo = struct {
    pub const default: @This() = .{};
    BrochureId: i32 = 0,
    BookItemInfos: std.ArrayList(BookItemInfo) = .empty,
};
pub const GridObjectComponentPb = struct {
    pub const default: @This() = .{};
    InitGridPlacementPbInfo: ?GridPlacementPbInfo = null,
};
pub const PayInfoResponse = struct {
    pub const default: @This() = .{};
    Infos: std.ArrayList(PayItemInfo) = .empty,
    Version: []const u8 = "",
    ErrorCode: ?ErrorCode = null,
};
pub const MotorDevelopActivityData = struct {
    pub const default: @This() = .{};
    Task: std.ArrayList(ConditionTask) = .empty,
};
pub const MaterialNotify = struct {
    pub const default: @This() = .{};
    MaterialInfo: ?MaterialInfo = null,
    CombatCommon: ?CombatCommon = null,
};
pub const PassiveSkillNotify = struct {
    pub const default: @This() = .{};
    RolePassiveSkillInfoList: std.ArrayList(RolePassiveSkillInfo) = .empty,
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
pub const PartComponentInitNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PartComponent: ?PartComponentPb = null,
};
pub const RogueResTaskThemeData = struct {
    pub const default: @This() = .{};
    RogueSignReward: std.ArrayList(ActivityTask) = .empty,
    RogueResThemeId: i32 = 0,
    EndTime: i64 = 0,
};
pub const PbAdvice = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    AreaId: i32 = 0,
    Contents: std.ArrayList(PbAdviceContent) = .empty,
    UpVote: i32 = 0,
};
pub const MotorDiyPb = struct {
    pub const default: @This() = .{};
    MotorDiyOnwer: ?MotorDiyOnwedPb = null,
    MotorDiyEquipped: ?MotorDiyEquippedPb = null,
};
pub const FollowerComponentPb = struct {
    pub const default: @This() = .{};
    FollowerList: std.ArrayList(FollowerList) = .empty,
};
pub const RoleVisionMainPhantomResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RecommendInfo: std.ArrayList(MainPhantomRecommendInfo) = .empty,
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
pub const LivenessResponse = struct {
    pub const default: @This() = .{};
    LivenessInfo: ?LivenessInfo = null,
};
pub const PhantomCollectActivity = struct {
    pub const default: @This() = .{};
    PhantomCollectRewards: std.ArrayList(PhantomCollectReward) = .empty,
};
pub const MotorParkourActivityInfo = struct {
    pub const default: @This() = .{};
    MotorParkourLevelInfos: std.ArrayList(MotorParkourLevelInfo) = .empty,
};
pub const PlayPointStateAsyncResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    LevelPlayStateDict: std.ArrayList(MapEntry(i32, LevelPlayStateMsg)) = .empty,
};
pub const TeamChallengeInfo = struct {
    pub const default: @This() = .{};
    RoleSaveInfos: std.ArrayList(RoleSaveInfo) = .empty,
    BuffIds: std.ArrayList(i32) = .empty,
    LastMonsterInfoPreview: ?MonsterInfoPreview = null,
    TeamScore: i32 = 0,
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
pub const TowerAreaPb = struct {
    pub const default: @This() = .{};
    AreaNum: i32 = 0,
    TowerFloors: std.ArrayList(TowerFloorPb) = .empty,
};
pub const AiBlackboardCdRequest = struct {
    pub const default: @This() = .{};
    AiBlackboardCdModify: std.ArrayList(Int2Long) = .empty,
    AiBlackboardCdComplete: std.ArrayList(Int2Bool) = .empty,
};
pub const HarvestActivity = struct {
    pub const default: @This() = .{};
    HarvestPointRewards: std.ArrayList(HarvestPointReward) = .empty,
    HarvestLevelRewards: std.ArrayList(HarvestLevelReward) = .empty,
};
pub const ChangeStateConfirmResponse = struct {
    pub const default: @This() = .{};
    FsmId: i32 = 0,
    State: i32 = 0,
    Error: ?DErrorResult = null,
};
pub const MowTowerActivityData = struct {
    pub const default: @This() = .{};
    MowTowerLevelsInfo: std.ArrayList(MowTowerLevelsInfo) = .empty,
};
pub const FishingIllustratedInfo = struct {
    pub const default: @This() = .{};
    IllustratedList: std.ArrayList(OneFishingIllustratedData) = .empty,
    RewardedId: std.ArrayList(FishingIllustratedRewardInfo) = .empty,
    UnlockDetections: std.ArrayList(i32) = .empty,
};
pub const CombinationAxis = struct {
    pub const default: @This() = .{};
    AxisName: []const u8 = "",
    CombinationKeyList: std.ArrayList(CombinationKey) = .empty,
    Version: i32 = 0,
    InputType: ?SettingInputType = null,
};
pub const SkinRewardActivityData = struct {
    pub const default: @This() = .{};
    RewardInfos: std.ArrayList(SkinRewardActivityRewardInfo) = .empty,
};
pub const ActivityTurnTableData = struct {
    pub const default: @This() = .{};
    IsAllFinish: bool = false,
    GroupId: i32 = 0,
    Rewards: std.ArrayList(i32) = .empty,
    TurntableTasks: std.ArrayList(ActivityTask) = .empty,
};
pub const GetFormationDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Formations: std.ArrayList(FightFormation) = .empty,
};
pub const ExploreSkillRouletteSetRequest = struct {
    pub const default: @This() = .{};
    SkillRoulettes: std.ArrayList(ExploreSkillRoulette) = .empty,
    RouletteType: ?RouletteType = null,
    XHn: std.ArrayList(ExploreSkillRoulette) = .empty,
};
pub const PbUpLevelSkillResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    RoleId: i32 = 0,
    SkillInfo: ?ArrayIntInt = null,
};
pub const LogicStateInitRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    EntityId: i64 = 0,
    InitData: ?LogicStateComponentPb = null,
    ClientEntityId: i64 = 0,
};
pub const PhantomAutoPutResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipInfoList: std.ArrayList(RolePhantomEquipInfo) = .empty,
};
pub const WeaponSkinResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipList: std.ArrayList(LoadEquipData) = .empty,
};
pub const PutVisionGroupToTopResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
};
pub const FlySkinWearAllRoleResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    FlySkinData: std.ArrayList(EquipFlySkinData) = .empty,
};
pub const ActivityFishingData = struct {
    pub const default: @This() = .{};
    ActivityTaskData: std.ArrayList(ActivityTask) = .empty,
    MilestoneReward: std.ArrayList(MapEntry(i32, i32)) = .empty,
    LimitTimeReward: i64 = 0,
    LimitTimeEnd: i64 = 0,
    MilestoneRewardItemAccumulate: i32 = 0,
};
pub const DestroyBulletNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
    IsCreateSubBullet: bool = false,
};
pub const AdventureManualData = struct {
    pub const default: @This() = .{};
    AdventreTask: std.ArrayList(AdventreTask) = .empty,
    NowChapter: i32 = 0,
    ReceivedChapter: i32 = 0,
    UnlockChapters: std.ArrayList(i32) = .empty,
    RewardChapters: std.ArrayList(i32) = .empty,
};
pub const PassiveSkillComponentPb = struct {
    pub const default: @This() = .{};
    PassiveSkillItemPbList: std.ArrayList(PassiveSkillItemPb) = .empty,
};
pub const ShieldUpdateNotify = struct {
    pub const default: @This() = .{};
    Shields: std.ArrayList(ShieldUpdateInfo) = .empty,
};
pub const PlayFlowChildQuestNodeCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const MotorCycleIpActivityData = struct {
    pub const default: @This() = .{};
    TaskDataList: std.ArrayList(ConditionTask) = .empty,
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
pub const PackAnimChangedNotify = struct {
    pub const default: @This() = .{};
    EntityAnimState: std.ArrayList(AnimStateChangeInfoList) = .empty,
};
pub const SimpleTrackReportAsyncResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SimpleTrackReportMsgs: std.ArrayList(SimpleTrackReportMsg) = .empty,
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
pub const HookLockPointActionCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    InteractionType: ?HookInteractActionType = null,
};
pub const AllMsgResponse = struct {
    pub const default: @This() = .{};
    ShortMessageInfos: std.ArrayList(ShortMessageInfo) = .empty,
    BubbleIds: std.ArrayList(i32) = .empty,
    BubbleId: i32 = 0,
    ChatBgIds: std.ArrayList(i32) = .empty,
    ChatBgId: i32 = 0,
    ErrCode: ?ErrorCode = null,
};
pub const UseSkillFailResponse = struct {
    pub const default: @This() = .{};
    SkillId: i32 = 0,
    Error: ?DErrorResult = null,
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
};
pub const UpdateFormationResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Formation: ?FightFormation = null,
};
pub const MoveToPointComponentPb = struct {
    pub const default: @This() = .{};
    PbMoveToPointConfig: ?PbMoveToPointConfig = null,
};
pub const SpringSignData = struct {
    pub const default: @This() = .{};
    SpringSignActivityTasks: std.ArrayList(ActivityTask) = .empty,
    CanInvite: bool = false,
    DrawRoles: std.ArrayList(i32) = .empty,
    SkinReward: bool = false,
};
pub const PlayerTitleData = struct {
    pub const default: @This() = .{};
    PlayerTitleId: i32 = 0,
    IsUnlock: bool = false,
    UnlockTime: i64 = 0,
    StarLevel: i32 = 0,
    ActivityServerRewardItemData: ?ConditionTask = null,
};
pub const PayGiftShopInfo = struct {
    pub const default: @This() = .{};
    Gifts: std.ArrayList(PayGiftInfo) = .empty,
    Version: []const u8 = "",
};
pub const DoInteractChildQuestNodeCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const FsmCustomBlackboardNotify = struct {
    pub const default: @This() = .{};
    FsmCustomBlackboardDatas: ?FsmCustomBlackboardDatas = null,
};
pub const BeamReceiveAction = struct {
    pub const default: @This() = .{};
    ReceiveType: ?BeamReceiveActionType = null,
    EntityCtx: ?EntityCtxPb = null,
};
pub const ModifyBulletParams = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    Handle: ?ActiveBulletHandle = null,
    TargetId: i64 = 0,
};
pub const FlowEndRequest = struct {
    pub const default: @This() = .{};
    FlowIncId: i64 = 0,
    IsSkip: bool = false,
    OptionInfos: std.ArrayList(MapEntry(i32, FlowOptionInfoList)) = .empty,
};
pub const SunSpiritGearComponentPb = struct {
    pub const default: @This() = .{};
    TakeUpInfo: std.ArrayList(SunSpiritPb) = .empty,
};
pub const ActionGroupNodeActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const PlayerFightFormations = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    Formations: std.ArrayList(FightFormationNotifyInfo) = .empty,
};
pub const EntityAccessInfo = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    RangeType: ?RangeType = null,
    AcessRangeResults: std.ArrayList(MapEntry(i32, ErrorCode)) = .empty,
};
pub const ChildQuestNodeFinishActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const ActivityFunPlayData = struct {
    pub const default: @This() = .{};
    ActivityFunPlayChallengeData: std.ArrayList(ActivityFunPlayChallengeData) = .empty,
};
pub const VisionEquipGroupInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionEquipList: std.ArrayList(RefreshVisionEquipGroupData) = .empty,
};
pub const DynAttachComponentPb = struct {
    pub const default: @This() = .{};
    PbDynAttachEntityConfigId: i32 = 0,
    PbDynAttachEntityActorKey: []const u8 = "",
    Pos: ?Vector = null,
    Rot: ?Rotator = null,
    PbDynAttachRefActorKey: []const u8 = "",
};
pub const AiBlackboardCdPush = struct {
    pub const default: @This() = .{};
    AiBlackboardCdModify: std.ArrayList(Int2Long) = .empty,
    AiBlackboardCdComplete: std.ArrayList(Int2Bool) = .empty,
};
pub const CompositionConditionEnterActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
    ConditionIndex: i32 = 0,
};
pub const PatrolInfoComponentPb = struct {
    pub const default: @This() = .{};
    SceneAiEnabled: bool = false,
    PatrolInfo: ?PatrolInfoPb = null,
};
pub const ActivityLongShanMain = struct {
    pub const default: @This() = .{};
    StageData: std.ArrayList(LongShanMainData) = .empty,
    ScoreRewardedId: std.ArrayList(i32) = .empty,
};
pub const SuccessNodeActionCtxPb = struct {
    pub const default: @This() = .{};
    BehaviorTreeCtx: ?BehaviorTreeCtxPb = null,
};
pub const RhythmShipPlanetPb = struct {
    pub const default: @This() = .{};
    PlanetId: i32 = 0,
    OpenTime: i64 = 0,
    RhythmShipLevelPb: std.ArrayList(RhythmShipLevelPb) = .empty,
};
pub const DamageRecordEntity = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    BuffIds: std.ArrayList(i64) = .empty,
    Attr: std.ArrayList(GameplayAttributeData) = .empty,
    AttrSnapshot: std.ArrayList(GameplayAttributeData) = .empty,
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
};
pub const TestDamageRecordEntity = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    ConfigId: i32 = 0,
    BuffIds: std.ArrayList(i64) = .empty,
    Attr: std.ArrayList(GameplayAttributeData) = .empty,
};
pub const CiacconaGalChapterData = struct {
    pub const default: @This() = .{};
    ChapterDataId: i32 = 0,
    CanUnlock: bool = false,
    CiacconaGalSubEndingData: std.ArrayList(CiacconaGalSubEndingData) = .empty,
    CiacconaGalChoiceData: std.ArrayList(CiacconaGalChoiceData) = .empty,
};
pub const EntityTimelineTrackCtxPb = struct {
    pub const default: @This() = .{};
    EntityCtx: ?EntityCtxPb = null,
    GroupIndex: i32 = 0,
    ControlPoint: i32 = 0,
    EventType: ?EntityTimelineEventType = null,
};
pub const AttributeChangedRequest = struct {
    pub const default: @This() = .{};
    Id: i64 = 0,
    Attributes: std.ArrayList(GameplayAttributeData) = .empty,
};
pub const PassiveSkillAddNotify = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    PassiveSkillItemPbList: std.ArrayList(PassiveSkillItemPb) = .empty,
};
pub const LogicStateInitPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    EntityId: i64 = 0,
    InitData: ?LogicStateComponentPb = null,
    ClientEntityId: i64 = 0,
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
pub const ApplyVisionGroupResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EquipInfoList: std.ArrayList(RolePhantomEquipInfo) = .empty,
};
pub const PlayerBasicInfoGetResponse = struct {
    pub const default: @This() = .{};
    Info: ?PlayerDetails = null,
    ErrorCode: ?ErrorCode = null,
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
pub const RacingBetsGroupMatchInfo = struct {
    pub const default: @This() = .{};
    MatchId: i32 = 0,
    GroupMatchTime: ?RacingBetsTimeTuple = null,
    LegMatch: std.ArrayList(RacingBetsLegMatch) = .empty,
    PromoteDangoList: std.ArrayList(i32) = .empty,
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
pub const MotorTaskPb = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Type: ?MotorTaskTypePb = null,
    Process: ?MotorTaskProcessPb = null,
    Reward: ?MotorTaskRewardPb = null,
    EndTime: i64 = 0,
    StartTime: i64 = 0,
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
pub const MotorSummonAndRidePush = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    VehicleIncId: i64 = 0,
    Transform: ?Transform = null,
};
pub const ExploreSkillRouletteSetResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    SkillRoulettes: std.ArrayList(ExploreSkillRoulette) = .empty,
    RouletteType: ?RouletteType = null,
    XHn: std.ArrayList(ExploreSkillRoulette) = .empty,
};
pub const ActivityAvignon = struct {
    pub const default: @This() = .{};
    RewardData: ?ActivityTaskData = null,
    StageId: std.ArrayList(i32) = .empty,
};
pub const TowerDifficultyPb = struct {
    pub const default: @This() = .{};
    Difficulty: i32 = 0,
    RewardIndex: std.ArrayList(i32) = .empty,
    TowerAreas: std.ArrayList(TowerAreaPb) = .empty,
    MaxStar: i32 = 0,
};
pub const PhantomIdentifyResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    UpdateInfo: ?PhantomItem = null,
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
pub const EquipTakeOnResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    DataList: std.ArrayList(RoleLoadEquipData) = .empty,
};
pub const PhantomPolishResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    UpdateInfo: ?PhantomItem = null,
};
pub const GachaResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    GachaResults: std.ArrayList(GachaResult) = .empty,
};
pub const RoleVisionRecommendAttrResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionAttrRecommendInfos: std.ArrayList(CostVisionAttrRecommendInfo) = .empty,
};
pub const UpdateFormationNotify = struct {
    pub const default: @This() = .{};
    PlayersFormations: std.ArrayList(PlayerFightFormations) = .empty,
};
pub const AdviceComponentPb = struct {
    pub const default: @This() = .{};
    Advice: ?PbAdvice = null,
    PlayerId: i32 = 0,
    PlayerName: []const u8 = "",
};
pub const ModifyBulletParamsPush = struct {
    pub const default: @This() = .{};
    ModifyBulletParams: ?ModifyBulletParams = null,
};
pub const MailInfosNotify = struct {
    pub const default: @This() = .{};
    MailInfos: std.ArrayList(PbMailInfo) = .empty,
};
pub const ActivityRogueData = struct {
    pub const default: @This() = .{};
    BeginOpenTime: i64 = 0,
    EndOpenTime: i64 = 0,
    RoguelikeSeason: ?RoguelikeSeason = null,
};
pub const UpdateAchievementInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    AchievementEntryList: std.ArrayList(AchievementEntry) = .empty,
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
pub const AddCombineEntitiesRelationNotify = struct {
    pub const default: @This() = .{};
    CharacterAttachInfo: ?CharacterAttachInfo = null,
    TargetEntity: i64 = 0,
};
// pub const TestDamageRecordNotify = struct {
//     pub const default: @This() = .{};
//     TimestampMs: i64 = 0,
//     Entities: std.ArrayList(Debug.TestDamageRecordEntity) = .empty,
// };
pub const PhantomLevelUpResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    UpdateInfo: ?PhantomItem = null,
    ItemMap: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const MotorSummonAndRideNotify = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    EntityId: i64 = 0,
    VehicleIncId: i64 = 0,
    Transform: ?Transform = null,
};
pub const ActivityBlackCoastData = struct {
    pub const default: @This() = .{};
    StageData: std.ArrayList(BlackCoastThemeStageInfo) = .empty,
    RewardIds: std.ArrayList(i32) = .empty,
};
pub const CharacterAttachComponentPb = struct {
    pub const default: @This() = .{};
    PbCombinePartInfoList: std.ArrayList(CharacterAttachInfo) = .empty,
    PbCombineTargetServerId: i64 = 0,
};
pub const PermanentRogueData = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        RogueResTaskThemeData: ?RogueResTaskThemeData,
    } = null,
};
pub const ModifyBulletParamsRequest = struct {
    pub const default: @This() = .{};
    ModifyBulletParams: ?ModifyBulletParams = null,
};
pub const AchievementGroupInfo = struct {
    pub const default: @This() = .{};
    AchievementGroupEntry: ?AchievementGroupEntry = null,
    AchievementEntryList: std.ArrayList(AchievementEntry) = .empty,
};
pub const CumulativeShopTaskConfig = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    Type: ?ConsumptiveTaskType = null,
    CumulativeShopTaskData: ?CumulativeShopTaskData = null,
    CumulativeShopSubTaskData: ?CumulativeShopSubTaskData = null,
};
pub const ForgeInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ForgeInfoList: std.ArrayList(OneForgeInfo) = .empty,
    ForgeConfigs: std.ArrayList(OneForgeConfig) = .empty,
    LimitRefreshTime: i64 = 0,
};
pub const EntityAccessRangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EntityId: i64 = 0,
    Info: std.ArrayList(EntityAccessInfo) = .empty,
};
pub const GroupFormation = struct {
    pub const default: @This() = .{};
    PlayerId: i32 = 0,
    FightRoleInfos: std.ArrayList(FightRoleInfos) = .empty,
    CurrentGroupType: i32 = 0,
};
pub const RoleVisionRecommendDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    VisionFetterRecommendInfo: std.ArrayList(VisionFetterRecommendInfo) = .empty,
};
pub const LordGymInfoResponse = struct {
    pub const default: @This() = .{};
    UnlockLoadGymIds: std.ArrayList(i32) = .empty,
    ReadLoadGymIds: std.ArrayList(i32) = .empty,
    LordGymPassRecords: std.ArrayList(LordGymPassRecord) = .empty,
    LordGymEntranceInfos: std.ArrayList(LordGymEntranceInfo) = .empty,
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
pub const PrivateChatHistoryNotify = struct {
    pub const default: @This() = .{};
    AllChats: std.ArrayList(PrivateChatHistoryContentProto) = .empty,
};
pub const BtnStateResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Type: ?ButtonType = null,
    Enabled: bool = false,
    Result: std.ArrayList(ButtonEnableResult) = .empty,
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
pub const MapTravelActivityData = struct {
    pub const default: @This() = .{};
    ActivityTasks: std.ArrayList(ActivityTask) = .empty,
    MonsterGain: std.ArrayList(i32) = .empty,
    GetFullReward: bool = false,
    MapTravelLevel: i32 = 0,
    UnlockAreas: std.ArrayList(i32) = .empty,
    SoarLevels: std.ArrayList(SoarLevelPlayInfo) = .empty,
};
pub const SummonRequest = struct {
    pub const default: @This() = .{};
    SummonerEntityId: i64 = 0,
    SummonInfo: ?SummonRequestInfo = null,
};
pub const LobbyListResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ItemList: std.ArrayList(PlayerDetails) = .empty,
};
pub const CharacterAttachRequest = struct {
    pub const default: @This() = .{};
    CharacterAttachInfo: ?CharacterAttachInfo = null,
    TargetEntity: i64 = 0,
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
pub const PlayerAccessEffectAreaResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EntityId: i64 = 0,
    Info: ?EntityAccessInfo = null,
};
pub const InitRangeResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    EntityId: i64 = 0,
    Info: std.ArrayList(EntityAccessInfo) = .empty,
    PlayerAccessRangeResult: ?EntityAccessInfo = null,
};
pub const InfrThemeActivityPb = struct {
    pub const default: @This() = .{};
    ActivityTaskData: ?ActivityTaskData = null,
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
pub const ModifyBulletParamsNotify = struct {
    pub const default: @This() = .{};
    ModifyBulletParams: ?ModifyBulletParams = null,
};
pub const RbBlockMovementPbAction = struct {
    pub const default: @This() = .{};
    Type: ?union(enum) {
        Roll: ?RbRollMovement,
        Jump: ?RbJumpMovement,
    } = null,
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
pub const HonamiStoryDropItemComponentPb = struct {
    pub const default: @This() = .{};
    Item: ?HonamiStoryItemInfo = null,
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
pub const ActivityScratchTicketData = struct {
    pub const default: @This() = .{};
    RoundData: std.ArrayList(ScratchTicketRoundData) = .empty,
    ConditionData: std.ArrayList(ScratchTicketConditionData) = .empty,
};
pub const EntitySimplyMoveInfoPackagePush = struct {
    pub const default: @This() = .{};
    MoveInfos: std.ArrayList(EntitySimplyMoveInfo) = .empty,
    SceneOwnerId: i32 = 0,
};
pub const FightPhotoActivityData = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    LevelGroups: std.ArrayList(LevelGroupData) = .empty,
    Tasks: std.ArrayList(TaskData) = .empty,
};
pub const RiskHarvestActivityData = struct {
    pub const default: @This() = .{};
    InstInfos: std.ArrayList(RiskHarvestInstInfo) = .empty,
    RewardedScores: std.ArrayList(i32) = .empty,
    RewardedBuffGroups: std.ArrayList(i32) = .empty,
    UnlockBuffGroups: std.ArrayList(i32) = .empty,
    RewardedBuffTypeIds: std.ArrayList(i32) = .empty,
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
pub const IllustratedClass = struct {
    pub const default: @This() = .{};
    Type: ?IllustratedType = null,
    IllustratedEntryList: std.ArrayList(IllustratedEntry) = .empty,
};
pub const BoardPb = struct {
    pub const default: @This() = .{};
    OccupiedGridList: std.ArrayList(OccupiedBoardGridInfo) = .empty,
    DynamicGridConfigs: std.ArrayList(BoardGridDynamicConfig) = .empty,
    CanMove: bool = false,
};
pub const RoleDevelopConfigs = struct {
    pub const default: @This() = .{};
    DevPropsList: std.ArrayList(RoleDevPropsConfig) = .empty,
    DevTargetRole: i32 = 0,
    DevPropsProjectList: std.ArrayList(RoleDevPropsProjectConfig) = .empty,
    Version: []const u8 = "",
};
pub const RogueResTaskData = struct {
    pub const default: @This() = .{};
    PermanentRogueData: ?PermanentRogueData = null,
    RogueResCollectionState: std.ArrayList(MapEntry(i32, i32)) = .empty,
};
pub const UpdateGroupFormationNotify = struct {
    pub const default: @This() = .{};
    GroupFormation: std.ArrayList(GroupFormation) = .empty,
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
pub const EntityMoveSplineComponentPb = struct {
    pub const default: @This() = .{};
    RuntimeData: ?union(enum) {
        SceneItemSplineRuntimeData: ?SceneItemSplineRuntimeData,
    } = null,
    SplineEntityId: i32 = 0,
    MoveSplineConfig: ?MoveSplineConfig = null,
};
pub const PbGetRoleListNotify = struct {
    pub const default: @This() = .{};
    RoleList: std.ArrayList(RoleInfo) = .empty,
};
pub const SolarisSpeedActivity = struct {
    pub const default: @This() = .{};
    SolarSpeedContext: std.ArrayList(SolarSpeedContext) = .empty,
    ActivityTaskDatas: ?ActivityTaskData = null,
};
pub const MotorTaskTreePb = struct {
    pub const default: @This() = .{};
    TreeId: i32 = 0,
    Tasks: std.ArrayList(MotorTaskPb) = .empty,
    TpRewarded: i32 = 0,
};
pub const EntityFsmComponentPb = struct {
    pub const default: @This() = .{};
    Fsms: std.ArrayList(DFsm) = .empty,
    HashCode: i32 = 0,
    CommonHashCode: i32 = 0,
    BlackBoard: std.ArrayList(DFsmBlackBoard) = .empty,
    FsmCustomBlackboardDatas: ?FsmCustomBlackboardDatas = null,
};
pub const RoleCoopActivityData = struct {
    pub const default: @This() = .{};
    CoopRoleInfos: std.ArrayList(CoopRoleInfo) = .empty,
    RewardGetList: std.ArrayList(i32) = .empty,
    CoopTaskCompleteInfos: std.ArrayList(CoopTaskCompleteInfo) = .empty,
    PreCompleteIds: std.ArrayList(i32) = .empty,
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
pub const HandInInfo = struct {
    pub const default: @This() = .{};
    Id: i32 = 0,
    FishingItem: std.ArrayList(FishingItemInfo) = .empty,
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
pub const RbBlockMovingPbState = struct {
    pub const default: @This() = .{};
    Action: ?RbBlockMovementPbAction = null,
};
pub const DarkCoastDeliveryResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    DragonPoolDropItems: ?DragonPoolDropItems = null,
    DefeatedGuard: std.ArrayList(i32) = .empty,
    ReceivedGuardReward: std.ArrayList(i32) = .empty,
    LevelGain: i32 = 0,
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
pub const MotorDiyInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    MotorDiy: ?MotorDiyPb = null,
};
pub const AchievementInfoResponse = struct {
    pub const default: @This() = .{};
    AchievementGroupInfoList: std.ArrayList(AchievementGroupInfo) = .empty,
    AchievementFinishedStar: i32 = 0,
    FinishedAchievementNum: i32 = 0,
};
pub const TemplateEntitySpawnerComponentPb = struct {
    pub const default: @This() = .{};
    SpawnerType: ?TemplateSpawnerType = null,
    CreateEntityInfos: std.ArrayList(SpawnerEntityInfo) = .empty,
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
pub const AdventureManualDataResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    AdventureManualData: ?AdventureManualData = null,
};
pub const GachaInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    GachaInfos: std.ArrayList(GachaInfo) = .empty,
    DailyTotalLeftTimes: i32 = 0,
    RecordId: []const u8 = "",
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
pub const HonamiStoryBackpackEntry = struct {
    pub const default: @This() = .{};
    Item: ?HonamiStoryItemInfo = null,
    State: ?HonamiStoryPosInfo = null,
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
pub const AdviceResponse = struct {
    pub const default: @This() = .{};
    Advices: std.ArrayList(PbAdvice) = .empty,
    UpVoteIds: std.ArrayList(i64) = .empty,
    ErrorCode: ?ErrorCode = null,
};
pub const PrivateChatHistoryResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Data: ?PrivateChatHistoryContentProto = null,
};
pub const ActivityComponentPb = struct {
    pub const default: @This() = .{};
    Data: ?union(enum) {
        SurvivorsMonsterPbData: ?SurvivorsMonsterPbData,
        SurvivorsWeaponPbData: ?SurvivorsWeaponPbData,
        SurvivorsPlayerCharacterPbData: ?SurvivorsPlayerCharacterPbData,
        SurvivorsGoldenCoinPbData: ?SurvivorsGoldenCoinPbData,
    } = null,
    ConfigId: i32 = 0,
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
pub const CumulativeShopData = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    TaskData: std.ArrayList(CumulativeShopTaskConfig) = .empty,
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
pub const BeginnerCarnivalData = struct {
    pub const default: @This() = .{};
    RoleId: i32 = 0,
    ActivityTaskData: ?ActivityTaskData = null,
    JumpTaskIds: std.ArrayList(i32) = .empty,
    JumpTaskCondInfos: std.ArrayList(JumpTaskCondInfo) = .empty,
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
pub const FriendAllResponse = struct {
    pub const default: @This() = .{};
    FriendInfoList: std.ArrayList(FriendInfo) = .empty,
    FriendApplyList: std.ArrayList(FriendApply) = .empty,
    ErrorCode: ?ErrorCode = null,
};
pub const UseSkillRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    BattleFlags: std.ArrayList(i32) = .empty,
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
pub const PlayerVarNotify = struct {
    pub const default: @This() = .{};
    VarInfos: std.ArrayList(MapEntry([]const u8, VarDefinePb)) = .empty,
};
pub const UseSkillNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
};
pub const RoleDevelopConfigResponse = struct {
    pub const default: @This() = .{};
    Configs: ?RoleDevelopConfigs = null,
    ErrorCode: ?ErrorCode = null,
};
pub const FightBuffComponentPb = struct {
    pub const default: @This() = .{};
    FightBuffInfos: std.ArrayList(FightBuffInformation) = .empty,
    ListBuffEffectCd: std.ArrayList(BuffEffectCd) = .empty,
    ClientBornBuffIds: std.ArrayList(i64) = .empty,
    ClientBornMessageId: i64 = 0,
};
pub const TowerSeasonUpdateResponse = struct {
    pub const default: @This() = .{};
    Towers: ?union(enum) {
        TowerInfo: ?TowerInfo,
    } = null,
    MaxUnlockDifficulty: i32 = 0,
};
pub const BabelTowerActivity = struct {
    pub const default: @This() = .{};
    BabelTowerDataList: std.ArrayList(BabelTowerData) = .empty,
    BabelDebuffUnlocks: std.ArrayList(BabelDebuff) = .empty,
    BabelBuffUnlocks: std.ArrayList(BabelBuff) = .empty,
    NormalQuest: std.ArrayList(ActivityTask) = .empty,
    DailyQuest: std.ArrayList(ActivityTask) = .empty,
    CurrentItemCount: i32 = 0,
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
pub const IllustratedInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ErrorParams: std.ArrayList([]const u8) = .empty,
    IllustratedClassList: std.ArrayList(IllustratedClass) = .empty,
};
pub const PlayerTitleDataResponse = struct {
    pub const default: @This() = .{};
    PlayerTitleData: std.ArrayList(PlayerTitleData) = .empty,
    ErrorCode: ?ErrorCode = null,
    PlayerTitleLimitInfos: std.ArrayList(PlayerTitleLimitInfo) = .empty,
};
pub const HitResponse = struct {
    pub const default: @This() = .{};
    HitInfo: ?HitInformation = null,
    ErrorCode: ?ErrorCode = null,
};
pub const HitRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    HitInfo: ?HitInformation = null,
    SkillMessageId: i64 = 0,
};
pub const MotorFightActivityPb = struct {
    pub const default: @This() = .{};
    MotorFightLevelPb: std.ArrayList(MotorFightLevelPb) = .empty,
    Task: std.ArrayList(ConditionTask) = .empty,
    TalentTree: ?MotorFightTalentTreePb = null,
    UnlockedItem: std.ArrayList(i32) = .empty,
    UnlockedRole: std.ArrayList(i32) = .empty,
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
pub const EntityVarComponentPb = struct {
    pub const default: @This() = .{};
    Vars: std.ArrayList(MapEntry([]const u8, VarDefinePb)) = .empty,
};
pub const TowerResponse = struct {
    pub const default: @This() = .{};
    TowerInfo: ?TowerInfo = null,
};
pub const SceneFishCageInfo = struct {
    pub const default: @This() = .{};
    Cages: std.ArrayList(SceneFishCageData) = .empty,
};
pub const HonamiStoryBackpack = struct {
    pub const default: @This() = .{};
    BackpackId: i32 = 0,
    Width: i32 = 0,
    Capacity: i32 = 0,
    Items: std.ArrayList(HonamiStoryBackpackEntry) = .empty,
};
pub const BattlePassResponse = struct {
    pub const default: @This() = .{};
    BattlePass: ?PbBattlePass = null,
    ErrorCode: ?ErrorCode = null,
};
pub const FlagChallengeActivityInfo = struct {
    pub const default: @This() = .{};
    ConditionTasks: std.ArrayList(ConditionTask) = .empty,
    FlagChallengeLevelInfos: std.ArrayList(FlagChallengeLevelInfo) = .empty,
    FlagStrongholdInfos: std.ArrayList(FlagStrongholdInfo) = .empty,
    FlagChallengeRoleLevelInfo: ?FlagChallengeRoleLevelInfo = null,
    UnlockTeleporterId: std.ArrayList(i32) = .empty,
};
pub const EndSkillNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
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
pub const FsmResetNotify = struct {
    pub const default: @This() = .{};
    EntityFsmComponentPb: ?EntityFsmComponentPb = null,
};
pub const MovingEntityData = struct {
    pub const default: @This() = .{};
    EntityId: i64 = 0,
    Originator: i64 = 0,
    MoveInfos: std.ArrayList(MoveReplaySample) = .empty,
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
pub const HitNotify = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    HitInfo: ?HitInformation = null,
};
pub const EndSkillResponse = struct {
    pub const default: @This() = .{};
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    ErrorCode: ?ErrorCode = null,
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
pub const SkillNotify = struct {
    pub const default: @This() = .{};
    UseSkillInfo: ?UseSkillInformation = null,
    SkillNodeInfos: ?SkillNodeInfo = null,
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
pub const LevelPlayVarAsyncResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Vars: std.ArrayList(MapEntry([]const u8, VarDefinePb)) = .empty,
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
pub const ActivityPermanentRogueData = struct {
    pub const default: @This() = .{};
    PermanentSeasonData: std.ArrayList(PermanentSeasonData) = .empty,
    RogueResTaskData: ?RogueResTaskData = null,
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
pub const MovePackagePush = struct {
    pub const default: @This() = .{};
    MovingEntities: std.ArrayList(MovingEntityData) = .empty,
    SceneOwnerId: i32 = 0,
};
pub const RoleFavorListResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    FavorList: std.ArrayList(RoleFavor) = .empty,
};
pub const FloroRanchActivityData = struct {
    pub const default: @This() = .{};
    FloroRangeData: ?FloroRangeData = null,
    UnFinishedSubIns: i32 = 0,
    SavedStage: i32 = 0,
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
};
pub const SkillRequest = struct {
    pub const default: @This() = .{};
    UseSkillInfo: ?UseSkillInformation = null,
    SkillNodeInfos: ?SkillNodeInfo = null,
};
pub const UseSkillResponse = struct {
    pub const default: @This() = .{};
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    ErrorCode: ?ErrorCode = null,
};
pub const RbBlockPbState = struct {
    pub const default: @This() = .{};
    State: ?union(enum) {
        MovingState: ?RbBlockMovingPbState,
        IdleState: ?RbBlockIdlePbState,
    } = null,
};
pub const RhythmActivityPb = struct {
    pub const default: @This() = .{};
    RhythmShipPlanetPb: std.ArrayList(RhythmShipPlanetPb) = .empty,
    RhythmRoleId: i32 = 0,
    RhythmTask: std.ArrayList(RhythmTaskPb) = .empty,
    UnlockedRole: std.ArrayList(i32) = .empty,
    RedDot: ?RhythmRedDotPb = null,
};
pub const EndSkillRequest = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    Reason: ?EEndSkillReason = null,
    InterruptSkillInfo: ?InterruptSkillInfo = null,
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
};
pub const DeviceInputSetting = struct {
    pub const default: @This() = .{};
    DeviceType: ?InputSettingDevice = null,
    DeviceSubType: []const u8 = "",
    Action: std.ArrayList(InputAction) = .empty,
    Axis: std.ArrayList(InputAxis) = .empty,
    CombinationAction: std.ArrayList(CombinationAction) = .empty,
    CombinationAxis: std.ArrayList(CombinationAxis) = .empty,
};
pub const EndSkillPush = struct {
    pub const default: @This() = .{};
    CombatCommon: ?CombatCommon = null,
    UseSkillInfo: ?UseSkillInformation = null,
    SkillSingleId: i32 = 0,
    Reason: ?EEndSkillReason = null,
    InterruptSkillInfo: ?InterruptSkillInfo = null,
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
};
pub const NewPlayerSupportActivityData = struct {
    pub const default: @This() = .{};
    TrialRoleInfoList: std.ArrayList(NewTrialRoleInfo) = .empty,
    TaskDataList: std.ArrayList(ConditionTask) = .empty,
    CurUseTrialRoleId: i32 = 0,
    CurUseRoleInfo: ?RoleInfo = null,
    aVg: i32 = 0,
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
pub const BossRushActivityData = struct {
    pub const default: @This() = .{};
    LevelDetailInfo: std.ArrayList(LevelInfo) = .empty,
    RewardInfo: std.ArrayList(BossRushScoreRewardData) = .empty,
    UnlockedBuffIndices: std.ArrayList(i32) = .empty,
    TaskProgressReward: std.ArrayList(ActivityTask) = .empty,
};
pub const PassiveGaSkillComponentPb = struct {
    pub const default: @This() = .{};
    SkillInfoList: std.ArrayList(CharacterSkillComponentPb) = .empty,
    SkillComponentPb: std.ArrayList(SkillComponentPb) = .empty,
};
pub const SceneItemComponentPb = struct {
    pub const default: @This() = .{};
    PosSender: i32 = 0,
    BlackBoards: std.ArrayList(SceneItemBlackboardParam) = .empty,
};
pub const HonamiStoryPlayerBagInfo = struct {
    pub const default: @This() = .{};
    Warehouse: ?HonamiStoryBackpack = null,
    EquipRack: ?HonamiStoryBackpack = null,
    RoleEquipList: std.ArrayList(HonamiStoryRoleData) = .empty,
    UnlockedWeaponIds: std.ArrayList(i32) = .empty,
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
pub const InputSettingData = struct {
    pub const default: @This() = .{};
    InputSettings: std.ArrayList(DeviceInputSetting) = .empty,
};
pub const ActivityBetHorsesData = struct {
    pub const default: @This() = .{};
    ActivityId: i32 = 0,
    StartAndEndTime: ?RacingBetsTimeTuple = null,
    MatchInfo: std.ArrayList(RacingBetsGroupMatchInfo) = .empty,
    RacingBetsSeasonData: ?RacingBetsSeasonData = null,
    BetsRewardData: std.ArrayList(RacingBetsRewardData) = .empty,
    LegMatchTimeList: std.ArrayList(i64) = .empty,
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
pub const MotorInfoResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    Motor: ?MotorPb = null,
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
pub const InputSettingResponse = struct {
    pub const default: @This() = .{};
    InputSettingData: ?InputSettingData = null,
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
pub const DamageRecordNotify = struct {
    pub const default: @This() = .{};
    TimestampMs: i64 = 0,
    DamageConfId: i64 = 0,
    DamageValue: i32 = 0,
    SkillId: i64 = 0,
    SkillLevel: i32 = 0,
    BulletId: i64 = 0,
    DamageSourceType: ?CreateBulletNotify = null,
    IsCritical: bool = false,
    // Attacker: ?Debug.DamageRecordEntity = null,
    // Victim: ?Debug.DamageRecordEntity = null,
    // DamageCalculationDetails: ?Debug.DamageCalculationDetails = null,
    IsWeakness: bool = false,
};
pub const InputSettingUpdateRequest = struct {
    pub const default: @This() = .{};
    InputSettingData: ?InputSettingData = null,
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
pub const AiBlackboardsRequest = struct {
    pub const default: @This() = .{};
    AiBlackboards: std.ArrayList(BlackboardParam) = .empty,
};
pub const AiBlackboardsPush = struct {
    pub const default: @This() = .{};
    AiBlackboards: std.ArrayList(BlackboardParam) = .empty,
};
pub const BlackboardParamComponentPb = struct {
    pub const default: @This() = .{};
    BlackboardParams: std.ArrayList(BlackboardParam) = .empty,
};
pub const StorageInfoUpdateRequest = struct {
    pub const default: @This() = .{};
    Infos: std.ArrayList(ClientStorageInfo) = .empty,
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
pub const AiInformation = struct {
    pub const default: @This() = .{};
    AiBlackboards: std.ArrayList(BlackboardParam) = .empty,
    HateList: std.ArrayList(AiHateEntity) = .empty,
    AiBlackboardCd: std.ArrayList(Int2Long) = .empty,
};
pub const AiInformationPush = struct {
    pub const default: @This() = .{};
    AiInfo: ?AiInformation = null,
};
pub const AiInformationRequest = struct {
    pub const default: @This() = .{};
    AiInfo: ?AiInformation = null,
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
pub const FishingDataResponse = struct {
    pub const default: @This() = .{};
    FishingData: ?FishingData = null,
};
pub const InitHonamiActivityResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    HonamiStoryActivityData: ?HonamiStoryActivityData = null,
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
    } = null,
    TransitionType: ?TransitionType = null,
};
pub const GameCtxPb = struct {
    pub const default: @This() = .{};
    CtxInfo: ?union(enum) {
        BehaviorTree: ?BehaviorTreeCtxPb,
        Entity: ?EntityCtxPb,
        NormalInteract: ?NormalInteractCtxPb,
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
    } = null,
    CtxType: ?GameCtxType = null,
};
pub const BubbleInfo = struct {
    pub const default: @This() = .{};
    ActionGuid: []const u8 = "",
    GameCtx: ?GameCtxPb = null,
};
pub const DynamicInteractInfo = struct {
    pub const default: @This() = .{};
    OptionGuid: []const u8 = "",
    GameCtx: ?GameCtxPb = null,
    Text: []const u8 = "",
    DelayRemove: bool = false,
};
pub const BubbleComponentPb = struct {
    pub const default: @This() = .{};
    BubbleInfos: std.ArrayList(BubbleInfo) = .empty,
};
pub const InteractComponentPb = struct {
    pub const default: @This() = .{};
    DynamicInteractInfos: std.ArrayList(DynamicInteractInfo) = .empty,
    RandomInteractIndex: std.ArrayList(i32) = .empty,
    Interacting: bool = false,
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
        PlayMontageTaskAndResponse: ?PlayMontageTaskAndResponse,
        TsAnimNotifyStateAbsoluteTimeStopResponse: ?TsAnimNotifyStateAbsoluteTimeStopResponse,
        SwitchRoleResponse: ?SwitchRoleResponse,
        RoleTagChangeResponse: ?RoleTagChangeResponse,
        ExecuteQteResponse: ?ExecuteQteResponse,
        CharacterAttachResponse: ?CharacterAttachResponse,
        CharacterDetachResponse: ?CharacterDetachResponse,
        ClientCurrentRoleReportResponse: ?ClientCurrentRoleReportResponse,
        CombatDataMaxResponse: ?CombatDataMaxResponse,
    } = null,
    CombatCommon: ?CombatCommon = null,
    RequestId: i32 = 0,
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
        PlayMontageTaskAndPush: ?PlayMontageTaskAndPush,
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
    } = null,
    CombatCommon: ?CombatCommon = null,
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
        PlayMontageTaskAndRequest: ?PlayMontageTaskAndRequest,
        TsAnimNotifyStateAbsoluteTimeStopRequest: ?TsAnimNotifyStateAbsoluteTimeStopRequest,
        SwitchRoleRequest: ?SwitchRoleRequest,
        RoleTagChangeRequest: ?RoleTagChangeRequest,
        ExecuteQteRequest: ?ExecuteQteRequest,
        CharacterAttachRequest: ?CharacterAttachRequest,
        CharacterDetachRequest: ?CharacterDetachRequest,
        ClientCurrentRoleReportRequest: ?ClientCurrentRoleReportRequest,
        CombatMaxCaseMessageRequest: ?CombatMaxCaseMessageRequest,
    } = null,
    CombatCommon: ?CombatCommon = null,
    RequestId: i32 = 0,
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
        // DamageRecordNotify: ?Debug.DamageRecordNotify,
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
        // TestDamageRecordNotify: ?Debug.TestDamageRecordNotify,
        BuffDurationNotify: ?BuffDurationNotify,
        EntityLivingStatusNotify: ?EntityLivingStatusNotify,
        NewLinkStateNotify: ?NewLinkStateNotify,
        BroadcastAddBuffFailedNotify: ?BroadcastAddBuffFailedNotify,
        PackAnimChangedNotify: ?PackAnimChangedNotify,
        VisionTriggerNotify: ?VisionTriggerNotify,
        RemoveBuffByServerIdS2cRequestNotify: ?RemoveBuffByServerIdS2cRequestNotify,
        TransformBuffStackNotify: ?TransformBuffStackNotify,
        MotorSummonAndRideNotify: ?MotorSummonAndRideNotify,
        CombatDataMaxNotify: ?CombatDataMaxNotify,
    } = null,
    CombatCommon: ?CombatCommon = null,
};
pub const CombatSendData = struct {
    pub const default: @This() = .{};
    Message: ?union(enum) {
        Push: ?CombatPushData,
        Request: ?CombatRequestData,
    } = null,
};
pub const CombatSendPackRequest = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(CombatSendData) = .empty,
    HostPlayerId: i32 = 0,
};
pub const CombatReceiveData = struct {
    pub const default: @This() = .{};
    Message: ?union(enum) {
        CombatNotifyData: ?CombatNotifyData,
        CombatResponseData: ?CombatResponseData,
    } = null,
};
pub const CombatReceivePackNotify = struct {
    pub const default: @This() = .{};
    Data: std.ArrayList(CombatReceiveData) = .empty,
};
pub const CombatSendPackResponse = struct {
    pub const default: @This() = .{};
    ErrorCode: ?ErrorCode = null,
    ReceivePackNotify: ?CombatReceivePackNotify = null,
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
    } = null,
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
    } = null,
    Id: i32 = 0,
    Type: i32 = 0,
    BeginShowTime: i64 = 0,
    EndShowTime: i64 = 0,
    BeginOpenTime: i64 = 0,
    EndOpenTime: i64 = 0,
    IsUnlock: bool = false,
    CompletePreQuests: std.ArrayList(i32) = .empty,
    IsFirstOpen: bool = false,
    FinishConditions: std.ArrayList(i32) = .empty,
    TimeTypeState: ?TimeTypeState = null,
    IsPreOpen: bool = false,
    StartTime: i64 = 0,
    EndTime: i64 = 0,
    BeginRewardTimeInternal: i64 = 0,
    EndRewardTimeInternal: i64 = 0,
};
pub const DirectTrainGetPlayerIdResponse = struct {
    pub const default: @This() = .{};
    MU1: ?union(enum) {
        Activities: ?ActivityData,
    } = null,
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
pub const ActivityResponse = struct {
    pub const default: @This() = .{};
    Activities: std.ArrayList(ActivityData) = .empty,
    ErrorCode: ?ErrorCode = null,
};
pub const EntityAddNotify = struct {
    pub const default: @This() = .{};
    EntityPbs: std.ArrayList(EntityPb) = .empty,
    RemoveTagIds: bool = false,
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
pub const PlayerSceneAoiData = struct {
    pub const default: @This() = .{};
    DynamicEntityList: std.ArrayList(DynamicEntityInformation) = .empty,
    GenIds: std.ArrayList(i64) = .empty,
    Entities: std.ArrayList(EntityPb) = .empty,
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
pub const JoinSceneNotify = struct {
    pub const default: @This() = .{};
    SceneInfo: ?SceneInformation = null,
    MaxEntityId: i64 = 0,
    TransitionOption: ?TransitionOptionPb = null,
};
