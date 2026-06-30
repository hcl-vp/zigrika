BaseInfoComponent: ?@import("BaseInfo.zig") = null,
AiComponent: ?@import("Ai.zig") = null,
ModelComponent: ?@import("Model.zig") = null,

pub fn mergeInto(template: *const @This(), target: *@This()) void {
    if (target.BaseInfoComponent == null) {
        target.BaseInfoComponent = template.BaseInfoComponent;
    }
    if (target.ModelComponent == null) {
        target.ModelComponent = template.ModelComponent;
    }
    if (target.AiComponent == null) {
        target.AiComponent = template.AiComponent;
    }
}
