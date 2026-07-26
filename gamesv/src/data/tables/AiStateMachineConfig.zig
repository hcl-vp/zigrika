pub const StateMachineNode = struct {
    ReferenceUuid: ?i32 = null,
    OverrideCommonUuid: ?i32 = null,
    Uuid: i32,
    Children: ?[]const i32 = null,
    IsAnimStateMachine: ?bool = null,

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
