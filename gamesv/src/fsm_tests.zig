const std = @import("std");
const ConditionEvaluator = @import("logic/fsm/ConditionEvaluator.zig");
const FsmHandlers = @import("logic/handlers/fsm.zig");
const FsmLifecycle = @import("logic/FsmLifecycle.zig");
const Scene = @import("logic/Scene.zig");
const TagComponent = @import("logic/component/entity/TagComponent.zig");
const TransitionEngine = @import("logic/fsm/TransitionEngine.zig");

test {
    std.testing.refAllDecls(ConditionEvaluator);
    std.testing.refAllDecls(FsmHandlers);
    std.testing.refAllDecls(FsmLifecycle);
    std.testing.refAllDecls(Scene);
    std.testing.refAllDecls(TagComponent);
    std.testing.refAllDecls(TransitionEngine);
}
