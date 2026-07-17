const std = @import("std");
const ConditionEvaluator = @import("logic/fsm/ConditionEvaluator.zig");
const TagComponent = @import("logic/component/entity/TagComponent.zig");

test {
    std.testing.refAllDecls(ConditionEvaluator);
    std.testing.refAllDecls(TagComponent);
}
