const std = @import("std");

BaseInfoComponent: ?@import("BaseInfo.zig") = null,
AiComponent: ?@import("Ai.zig") = null,
AttributeComponent: ?@import("Attribute.zig") = null,
ModelComponent: ?@import("Model.zig") = null,

fn mergeComponentField(comptime field_name: []const u8, template: *const @This(), target: *@This()) void {
    if (@field(target, field_name)) |*target_comp| {
        const template_comp = @field(template, field_name) orelse return;

        inline for (comptime std.meta.fields(@TypeOf(target_comp.*))) |field| {
            switch (@typeInfo(field.type)) {
                .optional => {
                    if (@field(target_comp, field.name) == null) {
                        @field(target_comp, field.name) = @field(template_comp, field.name);
                    }
                },
                else => {},
            }
        }
    } else {
        @field(target, field_name) = @field(template, field_name);
    }
}

pub fn mergeInto(template: *const @This(), target: *@This()) void {
    mergeComponentField("BaseInfoComponent", template, target);
    mergeComponentField("AiComponent", template, target);
    mergeComponentField("AttributeComponent", template, target);
    mergeComponentField("ModelComponent", template, target);
}
