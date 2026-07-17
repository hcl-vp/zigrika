const Assets = @import("../../data/Assets.zig");

const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;

pub fn fromAiBaseId(
    comptime Component: type,
    ai_id: ?i32,
    assets: *const Assets,
) ?Component {
    const graph = findAiStateMachineGraph(ai_id, assets) orelse return null;
    return .{ .graph = graph };
}

pub fn hasUsableAiBaseId(ai_id: ?i32, assets: *const Assets) bool {
    return findAiStateMachineGraph(ai_id, assets) != null;
}

pub fn fromStateMachineId(
    comptime Component: type,
    id: []const u8,
    assets: *const Assets,
) !Component {
    const graph = assets.fsm_graphs.get(id) orelse return error.InvalidFsmConfiguration;
    return .{ .graph = graph };
}

pub fn getCommonFsm(assets: *const Assets) ?AiStateMachineConfig {
    return assets.tables.ai_state_machine_config.getDataById("SM_Common");
}

fn findAiStateMachineGraph(ai_id: ?i32, assets: *const Assets) ?*const Assets.FsmGraphRegistry.Graph {
    const id = ai_id orelse return null;
    if (id <= 0) return null;

    const ai_base = assets.tables.ai_base.getDataById(id) orelse return null;
    if (ai_base.StateMachine.len == 0) return null;
    return assets.fsm_graphs.get(ai_base.StateMachine);
}
