pub const ConditionIndexList = struct {
    Conditions: []const i32 = &.{},
};

pub const ConditionTag = struct {
    TagId: ?i32 = null,
    TagName: ?[]const u8 = null,
};

pub const ConditionTimer = struct {
    MinTime: i32 = 0,
    MaxTime: ?i32 = null,
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
    Min: i32 = 0,
    Max: i32 = 0,
};

pub const ConditionAttributeRate = struct {
    AttributeId: i32 = 0,
    Denominator: i32 = 0,
    Min: i32 = 0,
    Max: i32 = 0,
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
    Min: i32 = 0,
    Max: i32 = 0,
};

pub const ConditionCheckPartActivated = struct {
    PartName: []const u8 = "",
};

pub const ConditionMontageTimeElapsing = struct {
    Time: i32 = 0,
};

pub const StateMachineCondition = struct {
    Index: i32 = 0,
    Name: []const u8 = "",
    Type: ?i32 = null,
    Reverse: bool = false,
    IsClient: ?bool = null,
    CondAnd: ?ConditionIndexList = null,
    CondOr: ?ConditionIndexList = null,
    CondTag: ?ConditionTag = null,
    CondTimer: ?ConditionTimer = null,
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
    CondMontageTimeRemaining: ?struct {} = null,
    CondMontageTimeElapsing: ?ConditionMontageTimeElapsing = null,
    CondHasMoveInput: ?struct {} = null,
    CondTaskFinish: ?struct {} = null,
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

pub const ActionTagCount = struct {
    TagId: i64 = 0,
    Count: i32 = 0,
};

pub const ActionInstChangeStateTag = struct {
    TagId: i64 = 0,
};

pub const ActionStopMontage = struct {
    BlendOutTime: i32 = 0,
};

pub const StateMachineAction = struct {
    Name: []const u8 = "",
    Type: ?i32 = null,
    ActionDispatchEvent: ?ActionDispatchEvent = null,
    ActionAddBuff: ?ActionBuff = null,
    ActionRemoveBuff: ?ActionBuff = null,
    ActionCue: ?ActionCue = null,
    ActionEnterFight: ?struct {} = null,
    ActionAddTagCount: ?ActionTagCount = null,
    ActionRemoveTagCount: ?ActionTagCount = null,
    ActionInstChangeStateTag: ?ActionInstChangeStateTag = null,
    ActionStopMontage: ?ActionStopMontage = null,
    ActionExitHit: ?struct {} = null,
    ActionResetStatus: ?struct {} = null,
    ActionSetRageFullAttribute: ?struct {} = null,
};

pub const BindBuff = struct {
    BuffId: i64 = 0,
};

pub const BindTag = struct {
    TagId: i64 = 0,
};

pub const StateMachineBindState = struct {
    Name: []const u8 = "",
    Type: ?i32 = null,
    BindAiHateConfig: ?struct {} = null,
    BindBuff: ?BindBuff = null,
    BindTag: ?BindTag = null,
};

pub const TaskRandomMontage = struct {
    MontageNames: []const []const u8 = &.{},
    RandomByClient: bool = false,
};

pub const TaskMoveToTarget = struct {
    TargetType: i32 = 0,
};

pub const StateMachineTask = struct {
    Name: []const u8 = "",
    Type: ?i32 = null,
    CanBeInterrupt: bool = false,
    TaskRandomMontage: ?TaskRandomMontage = null,
    TaskMoveToTarget: ?TaskMoveToTarget = null,
};

pub const StateMachineNode = struct {
    ReferenceUuid: ?i32 = null,
    OverrideCommonUuid: ?i32 = null,
    Uuid: i32,
    Name: ?[]const u8 = null,
    Children: ?[]const i32 = null,
    IsAnimStateMachine: ?bool = null,
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
