const std = @import("std");
const pb = @import("proto").pb;
const BuffAdditionEntry = @import("../../logic/events.zig").BuffAdditionEntry;

Id: i64,
GeDesc: []const u8,
DurationPolicy: enum(u2) {
    Instant = 0,
    Infinite = 1,
    HasDuration = 2,
},
DurationCalculationPolicy: []const i32,
DurationMagnitude: []const f32,
DurationMagnitude2: []const f32,
bDurationAffectedByBulletTime: bool,
FormationPolicy: enum(u3) {
    None = 0,
    SharedByFormation = 1,
    InheritedWhenChangeRole = 2,
    InheritedWhenChangeRoleAndRemoveSelf = 3,
    SharedToSummoner = 4,
    FormationBuff = 5,
    Unknown = 6,
},
Probability: u32,
Period: f32,
bExecutePeriodicEffectOnApplication: bool,
PeriodicInhibitionPolicy: enum(u2) {
    None = 0,
    Reset = 1,
    ResetAndExecute = 2,
},
GameAttributeID: pb.EAttributeType,
CalculationPolicy: []const i32,
ModifierMagnitude: []const i32,
ModifierMagnitude2: []const i32,
StackingType: enum(u2) {
    None = 0,
    ByInstigator = 1,
    ByTarget = 2,
},
DefaultStackCount: u8,
StackAppendCount: u8,
StackLimitCount: u32,
StackDurationRefreshPolicy: enum(u1) {
    Refresh = 0,
    NoRefresh = 1,
},
StackPeriodResetPolicy: enum(u1) {
    Refresh = 0,
    NoRefresh = 1,
},
StackExpirationRemoveNumber: u8,
bDenyOverflowApplication: bool,
bClearStackOnOverflow: bool,
bRequireModifierSuccessToTriggerCues: bool,
bSuppressStackingCues: bool,
GameplayCueIds: []const i64,
GrantedTags: []const []const u8,
ApplicationSourceTagRequirements: []const []const u8,
ApplicationSourceTagIgnores: []const []const u8,
ApplicationTagRequirements: []const []const u8,
ApplicationTagIgnores: []const []const u8,
OngoingTagRequirements: []const []const u8,
OngoingTagIgnores: []const []const u8,
RemovalTagRequirements: []const []const u8,
RemovalTagIgnores: []const []const u8,
RemoveBuffWithTags: []const []const u8,
GrantedApplicationImmunityTags: []const []const u8,
GrantedApplicationImmunityTagIgnores: []const []const u8,
PrematureExpirationEffects: []const i64,
RoutineExpirationEffects: []const i64,
OverflowEffects: []const i64,
RelatedExtraEffectBuffId: []const i64,
ExtraEffectID: u32,
ExtraEffectParameters: []const []const u8,
ExtraEffectParametersGrow1: []const i32,
ExtraEffectParametersGrow2: []const i32,
ExtraEffectRequirements: []const u32,
ExtraEffectReqPara: []const []const u8,
ExtraEffectReqSetting: u1,
ExtraEffectCD: []const f32,
ExtraEffectRemoveStackNum: u32,
ExtraEffectProbability: []const u32,
BuffAction: []const []const u8,
TagLogic: []const []const u8,
DeadRemove: bool,
// RelatedAttributeBuffId, unused so no way to know
bOnlyLocalAdd: bool,
ReplaceBuffIds: []const i64,
ReplaceConditions: []const []const u8,

pub fn buffListFromIds(allocator: std.mem.Allocator, ids: []const i64) !std.ArrayListUnmanaged(BuffAdditionEntry) {
    var list: std.ArrayListUnmanaged(BuffAdditionEntry) = .empty;
    try list.ensureTotalCapacity(allocator, ids.len);
    for (ids) |id| {
        list.appendAssumeCapacity(.{ .id = id, .is_active = true });
    }
    return list;
}
