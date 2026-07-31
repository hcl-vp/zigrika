pub const ConditionIndexList = struct {
    Conditions: []const i32 = &.{},
};

pub const TimerCondition = struct {
    MinTime: i32 = 0,
    MaxTime: i32 = 0,
};

pub const StateMachineCondition = struct {
    Index: i32 = 0,
    Name: []const u8 = "",
    Type: i32 = 0,
    Reverse: bool = false,
    IsClient: ?bool = null,
    CondAnd: ?ConditionIndexList = null,
    CondOr: ?ConditionIndexList = null,
    CondTimer: ?TimerCondition = null,
};

pub const StateMachineTransition = struct {
    From: i32 = 0,
    To: i32 = 0,
    TransitionPredictionType: i32 = 0,
    Weight: i32 = 0,
    Conditions: []const StateMachineCondition = &.{},
};

pub const StateMachineNode = struct {
    ReferenceUuid: ?i32 = null,
    OverrideCommonUuid: ?i32 = null,
    Uuid: i32,
    Name: []const u8 = "",
    Children: ?[]const i32 = null,
    IsAnimStateMachine: ?bool = null,
    Transitions: []const StateMachineTransition = &.{},

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
