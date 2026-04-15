BaseInfoComponent: ?@import("BaseInfo.zig") = null,

pub fn mergeInto(template: *const @This(), target: *@This()) void {
    if (target.BaseInfoComponent == null) {
        target.BaseInfoComponent = template.BaseInfoComponent;
    }
}
