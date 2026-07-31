const std = @import("std");

pub const ConditionIndexList = struct {
    Conditions: []const i32 = &.{},
};

pub const ConditionTag = struct {
    TagId: ?i32 = null,
    TagName: ?[]const u8 = null,
};

pub const ConditionTimer = struct {
    MinTime: f32 = 0,
    MaxTime: ?f32 = null,
};

pub const ConditionCheckState = struct {
    TargetState: i32 = 0,
};

pub const ConditionCheckStateByName = struct {
    TargetStateName: []const u8 = "",
};

pub const ConditionCheckLastState = struct {
    TargetStateName: []const u8 = "",
};

pub const ConditionAttribute = struct {
    AttributeId: i32 = 0,
    Min: f32 = 0,
    Max: f32 = 0,
};

pub const ConditionAttributeRate = struct {
    AttributeId: i32 = 0,
    Denominator: f32 = 0,
    Min: f32 = 0,
    Max: f32 = 0,
};

pub const ConditionListenBeHit = struct {
    NoHitAnimation: bool = false,
    SoftKnock: bool = false,
    HeavyKnock: bool = false,
    KnockUp: bool = false,
    KnockDown: bool = false,
    Parry: bool = false,
    BreakWeakness: bool = false,
    VisionCounterAttackId: i32 = 0,
};

pub const ConditionListenEvent = struct {
    Event: []const u8 = "",
};

pub const ConditionCheckPositionState = struct {
    PositionState: i32 = 0,
};

pub const ConditionInstStateChange = struct {
    TagId: i32 = 0,
};

pub const ConditionBuffStack = struct {
    BuffId: i64 = 0,
    MinStack: i32 = 0,
    MaxStack: i32 = 0,
};

pub const ConditionPartLife = struct {
    PartName: []const u8 = "",
    CheckRate: bool = false,
    Min: f32 = 0,
    Max: f32 = 0,
};

pub const ConditionCheckPartActivated = struct {
    PartName: []const u8 = "",
};

pub const ConditionMontageTimeElapsing = struct {
    Time: f32 = 0,
};

pub const ConditionMontageTimeRemaining = struct {
    Time: f32 = 0,
};

pub const ConditionHpLessThan = struct {
    HpRatio: f32 = 0,
};

pub const ConditionBlackboardValueCompare = struct {
    Key1: i32 = 0,
    Key2: i32 = 0,
    Compare: i32 = 0,
};

pub const ConditionAttributeCompare = struct {
    Attr1: i32 = 0,
    Attr2: i32 = 0,
    Compare: i32 = 0,
};

pub const StateMachineCondition = struct {
    Index: i32 = 0,
    Name: []const u8 = "",
    Type: ?i32 = null,
    Reverse: bool = false,
    IsClient: ?bool = null,
    CondAnd: ?ConditionIndexList = null,
    CondOr: ?ConditionIndexList = null,
    CondTrue: ?struct {} = null,
    CondHpLessThan: ?ConditionHpLessThan = null,
    CondSkillEnd: ?struct {} = null,
    CondTag: ?ConditionTag = null,
    CondBBValueCompare: ?ConditionBlackboardValueCompare = null,
    CondAttrCompare: ?ConditionAttributeCompare = null,
    CondTimer: ?ConditionTimer = null,
    CondHate: ?struct {} = null,
    CondWaitClient: ?struct {} = null,
    CondCheckState: ?ConditionCheckState = null,
    CondCheckStateByName: ?ConditionCheckStateByName = null,
    CondCheckLastState: ?ConditionCheckLastState = null,
    CondAttribute: ?ConditionAttribute = null,
    CondAttributeRate: ?ConditionAttributeRate = null,
    CondListenBeHit: ?ConditionListenBeHit = null,
    CondListenEvent: ?ConditionListenEvent = null,
    CondCheckPositionState: ?ConditionCheckPositionState = null,
    CondInstStateChange: ?ConditionInstStateChange = null,
    CondBuffStack: ?ConditionBuffStack = null,
    CondPartLife: ?ConditionPartLife = null,
    CondCheckPartActivated: ?ConditionCheckPartActivated = null,
    CondCheckDissolveCombine: ?struct {} = null,
    CondMontageTimeRemaining: ?ConditionMontageTimeRemaining = null,
    CondMontageTimeElapsing: ?ConditionMontageTimeElapsing = null,
    CondHasMoveInput: ?struct {} = null,
    CondTaskFinish: ?struct {} = null,
    CondCheckGroupPatrol: ?struct {} = null,
    CondCheckGroupPerform: ?struct {} = null,
};

pub const StateMachineTransition = struct {
    From: i32,
    To: i32,
    TransitionPredictionType: ?i32 = null,
    Weight: i32 = 0,
    Conditions: []const StateMachineCondition = &.{},
};

pub const ActionDispatchEvent = struct {
    Event: []const u8 = "",
};

pub const ActionCue = struct {
    CueIds: []const i64 = &.{},
};

pub const ActionBuff = struct {
    BuffId: i64 = 0,
};

pub const ActionSkill = struct {
    SkillId: i32 = 0,
};

pub const ActionSkillByName = struct {
    SkillName: []const u8 = "",
};

pub const ActionTagCount = struct {
    TagId: i64 = 0,
    Count: i32 = 0,
};

pub const ActionInstChangeStateTag = struct {
    TagId: i64 = 0,
};

pub const ActionStopMontage = struct {
    BlendOutTime: f32 = 0,
};

pub const ActionActivatePart = struct {
    PartName: []const u8 = "",
    Activate: bool = false,
};

pub const ActionResetPart = struct {
    PartName: []const u8 = "",
    ResetActivate: bool = false,
    ResetLife: bool = false,
};

pub const ActionActivateSkillGroup = struct {
    ConfigId: i32 = 0,
    Activate: bool = false,
};

pub const ActionSendGameplayEvent = struct {
    TagId: i32 = 0,
};

pub const ActionCameraLockOn = struct {
    Enable: bool = false,
};

pub const StateMachineAction = struct {
    Name: []const u8 = "",
    Type: ?i32 = null,
    ActionDispatchEvent: ?ActionDispatchEvent = null,
    ActionAddBuff: ?ActionBuff = null,
    ActionRemoveBuff: ?ActionBuff = null,
    ActionCastSkill: ?ActionSkill = null,
    ActionCancelSkill: ?ActionSkill = null,
    ActionCue: ?ActionCue = null,
    ActionEnterFight: ?struct {} = null,
    ActionCastSkillByName: ?ActionSkillByName = null,
    ActionCancelSkillByName: ?ActionSkillByName = null,
    ActionAddTagCount: ?ActionTagCount = null,
    ActionRemoveTagCount: ?ActionTagCount = null,
    ActionInstChangeStateTag: ?ActionInstChangeStateTag = null,
    ActionStopMontage: ?ActionStopMontage = null,
    ActionExitHit: ?struct {} = null,
    ActionResetStatus: ?struct {} = null,
    ActionSetRageFullAttribute: ?struct {} = null,
    ActionActivatePart: ?ActionActivatePart = null,
    ActionResetPart: ?ActionResetPart = null,
    ActionActivateSkillGroup: ?ActionActivateSkillGroup = null,
    ActionDispatchGameEvent: ?struct {} = null,
    ActionSendGameplayEvent: ?ActionSendGameplayEvent = null,
    ActionCameraLockOn: ?ActionCameraLockOn = null,
};

pub const BindBuff = struct {
    BuffId: i64 = 0,
};

pub const BindTag = struct {
    TagId: i64 = 0,
};

pub const BindSkill = struct {
    SkillId: i32 = 0,
};

pub const BindSkillByName = struct {
    SkillName: []const u8 = "",
};

pub const BindSkillCounter = struct {
    SkillIds: []const i32 = &.{},
    BlackboardKey: []const u8 = "",
    AddValueMin: i32 = 0,
    AddValueMax: i32 = 0,
    Reset: bool = false,
};

pub const BindDelaySuicide = struct {
    SuicideDelay: f32 = 0,
    DestroyDelay: f32 = 0,
};

pub const BindConfig = struct {
    ConfigId: i32 = 0,
};

pub const BindCue = struct {
    CueIds: []const i64 = &.{},
    HideOnLoading: bool = false,
};

pub const BindLeaveFight = struct {
    RandomRadius: f32 = 0,
    MinWanderDistance: f32 = 0,
    MaxNavigationMillisecond: f32 = 0,
    MoveStateForWanderOrReset: bool = false,
    MaxStopTime: f32 = 0,
    BlinkTime: f32 = 0,
    UsePatrolPointPriority: bool = false,
};

pub const BindMontage = struct {
    MontageName: []const u8 = "",
    HideOnLoading: bool = false,
};

pub const BindBoneVisible = struct {
    BoneName: []const u8 = "",
    Visible: bool = false,
};

pub const BindMeshVisible = struct {
    Tag: []const u8 = "",
    Visible: bool = false,
    PropagateToChildren: bool = false,
};

pub const BindBoneCollision = struct {
    BoneName: []const u8 = "",
    IsBlockPawn: bool = false,
    IsBulletDetect: bool = false,
    IsBlockCamera: bool = false,
    IsBlockPawnOnExit: bool = false,
    IsBulletDetectOnExit: bool = false,
    IsBlockCameraOnExit: bool = false,
};

pub const BindPartPanelVisible = struct {
    PartName: []const u8 = "",
    Visible: bool = false,
};

pub const BindDeathMontage = struct {
    DeathType: i32 = 0,
    MontageName: []const u8 = "",
};

pub const BindPalsy = struct {
    CounterAttackEffect: []const u8 = "",
    CounterAttackCamera: []const u8 = "",
};

pub const BindCollisionChannel = struct {
    IgnoreChannels: []const i32 = &.{},
};

pub const BindDeathMontageByTag = struct {
    MontageTagIds: []const i32 = &.{},
    MontageTagNames: []const []const u8 = &.{},
    TagMontageNames: []const []const u8 = &.{},
};

pub const StateMachineBindState = struct {
    Name: []const u8 = "",
    Type: ?i32 = null,
    BindSkill: ?BindSkill = null,
    BindSkillByName: ?BindSkillByName = null,
    BindSkillCounter: ?BindSkillCounter = null,
    BindDelaySuicide: ?BindDelaySuicide = null,
    BindAiHateConfig: ?BindConfig = null,
    BindAiSenseEnable: ?BindConfig = null,
    BindBuff: ?BindBuff = null,
    BindTag: ?BindTag = null,
    BindCue: ?BindCue = null,
    BindDisableActor: ?struct {} = null,
    BindLeaveFight: ?BindLeaveFight = null,
    BindMontage: ?BindMontage = null,
    BindBoneVisible: ?BindBoneVisible = null,
    BindMeshVisible: ?BindMeshVisible = null,
    BindBoneCollision: ?BindBoneCollision = null,
    BindPartPanelVisible: ?BindPartPanelVisible = null,
    BindDeathMontage: ?BindDeathMontage = null,
    BindPalsy: ?BindPalsy = null,
    BindCollisionChannel: ?BindCollisionChannel = null,
    BindDisableCollision: ?struct {} = null,
    BindDeathMontageByTag: ?BindDeathMontageByTag = null,
};

pub const TaskSkill = struct {
    SkillId: i32 = 0,
    ConfigReplaceTagId: i32 = 0,
    ConfigReplaceTagName: []const u8 = "",
};

pub const TaskSkillByName = struct {
    SkillName: []const u8 = "",
    ConfigReplaceTagId: i32 = 0,
    ConfigReplaceTagName: []const u8 = "",
};

pub const TaskRandomMontage = struct {
    MontageNames: []const []const u8 = &.{},
    HideOnLoading: bool = false,
    BlendInTime: f32 = 0,
    RandomByClient: bool = false,
};

pub const TaskLeaveFight = struct {
    BlinkTime: f32 = 0,
    MaxStopTime: f32 = 0,
    UsePatrolPointPriority: bool = false,
};

pub const TaskMontage = struct {
    MontageName: []const u8 = "",
    HideOnLoading: bool = false,
    BlendInTime: f32 = 0,
    ForcePush2Server: bool = false,
    ConfigReplaceTagId: i32 = 0,
    ConfigReplaceTagName: []const u8 = "",
};

pub const TaskMoveToTarget = struct {
    TargetType: i32 = 0,
    MoveState: i32 = 0,
    EndDistance: f32 = 0,
    TurnSpeed: f32 = 0,
    WalkOff: bool = false,
};

pub const TaskPatrol = struct {
    MoveState: i32 = 0,
    OpenDebugMode: bool = false,
};

pub const MontageMapEntry = std.meta.Tuple(&.{ i32, []const u8 });

pub const TaskBeHitMontage = struct {
    DefaultMontageName: []const u8 = "",
    MontageMap: []const MontageMapEntry = &.{},
    BlendInTime: f32 = 0,
};

pub const StateMachineTask = struct {
    Name: []const u8 = "",
    Type: ?i32 = null,
    CanBeInterrupt: bool = false,
    TaskSkill: ?TaskSkill = null,
    TaskSkillByName: ?TaskSkillByName = null,
    TaskRandomMontage: ?TaskRandomMontage = null,
    TaskLeaveFight: ?TaskLeaveFight = null,
    TaskMontage: ?TaskMontage = null,
    TaskMoveToTarget: ?TaskMoveToTarget = null,
    TaskPatrol: ?TaskPatrol = null,
    TaskBeHitMontage: ?TaskBeHitMontage = null,
    TaskGroupPatrol: ?struct {} = null,
    TaskGroupPerform: ?struct {} = null,
};

pub const StateMachineNode = struct {
    ReferenceUuid: ?i32 = null,
    OverrideCommonUuid: ?i32 = null,
    Uuid: i32,
    Name: ?[]const u8 = null,
    Children: ?[]const i32 = null,
    IsAnimStateMachine: ?bool = null,
    IsConduitNode: bool = false,
    IsAnyState: bool = false,
    TakeControlType: i32 = 0,
    TransitionRule: i32 = 0,
    Task: ?StateMachineTask = null,
    Transitions: []const StateMachineTransition = &.{},
    OnEnterActions: []const StateMachineAction = &.{},
    OnExitActions: []const StateMachineAction = &.{},
    BindStates: []const StateMachineBindState = &.{},

    pub fn kind(self: @This()) enum {
        reference,
        override,
        custom,
    } {
        if (self.ReferenceUuid != null) {
            return .reference;
        }

        if (self.OverrideCommonUuid != null) {
            return .override;
        }

        return .custom;
    }
};

pub const StateMachineJsonData = struct {
    Version: i32,
    StateMachines: []const i32,
    Nodes: []const StateMachineNode,
};

Id: []const u8,
StateMachineJson: StateMachineJsonData,
