const std = @import("std");
const ConditionEvaluator = @import("logic/fsm/ConditionEvaluator.zig");
const FsmHandlers = @import("logic/handlers/fsm.zig");
const FsmLifecycle = @import("logic/FsmLifecycle.zig");
const GameplayTags = @import("logic/helpers/gameplay_tags.zig");
const EntityCommands = @import("logic/commands/entity.zig");
const Scene = @import("logic/Scene.zig");
const TagComponent = @import("logic/component/entity/TagComponent.zig");
const PartComponent = @import("logic/component/entity/PartComponent.zig");
const TransitionEngine = @import("logic/fsm/TransitionEngine.zig");

test {
    std.testing.refAllDecls(ConditionEvaluator);
    std.testing.refAllDecls(FsmHandlers);
    std.testing.refAllDecls(FsmLifecycle);
    std.testing.refAllDecls(GameplayTags);
    std.testing.refAllDecls(EntityCommands);
    std.testing.refAllDecls(Scene);
    std.testing.refAllDecls(TagComponent);
    std.testing.refAllDecls(PartComponent);
    std.testing.refAllDecls(TransitionEngine);
}
