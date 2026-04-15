const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Scene = @import("../../logic/Scene.zig");
const Connection = @import("../../network/Connection.zig");
const FileSystem = @import("common").FileSystem;

pub const max_attribute = struct {
    pub const alias = "max";
    pub const description = "set the inputted attribute to its maximum possible value.\nusage: max_attribute [config_id] [EAttributeType]\nconfig_id is a number, for example 1108 is hiyuki's config id\nEAttributeType is a number.";
    pub fn call(
        events: *EventQueue,
        scene: *Scene,
        fs: *FileSystem,
        query: Scene.Query(&.{ Scene.Entity, *Scene.Entity.ConfigComponent, *Scene.Entity.AttributeComponent }),
        conn: *Connection,
        alloc: mem.Alloc,
        config_id: i32,
        attr: i32,
    ) !void {
        var notify: pb.CombatReceivePackNotify = .{};

        var it = query.iterator;
        while (it.next()) |comps| {
            const entity: Scene.Entity, const config_comp: *Scene.Entity.ConfigComponent, const attr_comp: *Scene.Entity.AttributeComponent = comps;
            if (config_comp.config_id == config_id) {
                const attr_type: pb.EAttributeType = @enumFromInt(attr);
                var attrs_for_notify: std.ArrayList(pb.GameplayAttributeData) = try .initCapacity(alloc.arena, 1);

                const max_value: i32 = blk: {
                    const attr_name = @tagName(attr_type);
                    const attr_name_max = try std.fmt.allocPrint(alloc.gpa, "{s}Max", .{attr_name});
                    defer alloc.gpa.free(attr_name_max);
                    const max_type = std.meta.stringToEnum(pb.EAttributeType, attr_name_max) orelse {
                        break :blk 10000000;
                    };
                    break :blk attr_comp.base_prop[@intCast(@intFromEnum(max_type))];
                };
                attr_comp.base_prop[@intCast(attr)] = max_value;
                try attrs_for_notify.append(alloc.arena, .{ .CurrentValue = attr_comp.base_prop[@intCast(attr)], .AttributeType = attr_type });

                try notify.Data.append(alloc.arena, .{ .Message = .{
                    .CombatNotifyData = .{
                        .CombatCommon = .{ .EntityId = entity.net_id },
                        .Message = .{
                            .AttributeChangedNotify = .{
                                .Attributes = attrs_for_notify,
                            },
                        },
                    },
                } });
                try scene.saveEntity(fs, alloc.gpa, entity);
            }
        }

        try conn.push(notify, alloc.arena);
        try events.enqueue(.chat_command_response, .{ .content = "maxxed out stat" });
    }
};

pub const empty_attribute = struct {
    pub const alias = "empty";
    pub const description = "set the inputted attribute to its lowest possible value (0).\nusage: max_attribute [config_id] [EAttributeType]\nconfig_id is a number, for example 1108 is hiyuki's config id\nEAttributeType is a number.";
    pub fn call(
        events: *EventQueue,
        scene: *Scene,
        fs: *FileSystem,
        query: Scene.Query(&.{ Scene.Entity, *Scene.Entity.ConfigComponent, *Scene.Entity.AttributeComponent }),
        conn: *Connection,
        alloc: mem.Alloc,
        config_id: i32,
        attr: i32,
    ) !void {
        var notify: pb.CombatReceivePackNotify = .{};

        var it = query.iterator;
        while (it.next()) |comps| {
            const entity: Scene.Entity, const config_comp: *Scene.Entity.ConfigComponent, const attr_comp: *Scene.Entity.AttributeComponent = comps;
            if (config_comp.config_id == config_id) {
                const attr_type: pb.EAttributeType = @enumFromInt(attr);
                var attrs_for_notify: std.ArrayList(pb.GameplayAttributeData) = try .initCapacity(alloc.arena, 1);

                attr_comp.base_prop[@intCast(attr)] = 0;
                try attrs_for_notify.append(alloc.arena, .{ .CurrentValue = attr_comp.base_prop[@intCast(attr)], .AttributeType = attr_type });

                try notify.Data.append(alloc.arena, .{ .Message = .{
                    .CombatNotifyData = .{
                        .CombatCommon = .{ .EntityId = entity.net_id },
                        .Message = .{
                            .AttributeChangedNotify = .{
                                .Attributes = attrs_for_notify,
                            },
                        },
                    },
                } });
                try scene.saveEntity(fs, alloc.gpa, entity);
            }
        }

        try conn.push(notify, alloc.arena);
        try events.enqueue(.chat_command_response, .{ .content = "emptied out stat" });
    }
};

pub const set_attribute = struct {
    pub const alias = "set";
    pub const description = "set the inputted attribute to the inputted value.\nusage: set_attribute [config_id] [EAttributeType] [value]\nconfig_id is a number, for example 1108 is hiyuki's config id\nEAttributeType is a number.\nvalue is a number";
    pub fn call(
        events: *EventQueue,
        scene: *Scene,
        fs: *FileSystem,
        query: Scene.Query(&.{ Scene.Entity, *Scene.Entity.ConfigComponent, *Scene.Entity.AttributeComponent }),
        conn: *Connection,
        alloc: mem.Alloc,
        config_id: i32,
        attr: i32,
        value: i32,
    ) !void {
        var notify: pb.CombatReceivePackNotify = .{};

        var it = query.iterator;
        while (it.next()) |comps| {
            const entity: Scene.Entity, const config_comp: *Scene.Entity.ConfigComponent, const attr_comp: *Scene.Entity.AttributeComponent = comps;
            if (config_comp.config_id == config_id) {
                const attr_type: pb.EAttributeType = @enumFromInt(attr);
                var attrs_for_notify: std.ArrayList(pb.GameplayAttributeData) = try .initCapacity(alloc.arena, 1);

                attr_comp.base_prop[@intCast(attr)] = value;
                try attrs_for_notify.append(alloc.arena, .{ .CurrentValue = attr_comp.base_prop[@intCast(attr)], .AttributeType = attr_type });

                try notify.Data.append(alloc.arena, .{ .Message = .{
                    .CombatNotifyData = .{
                        .CombatCommon = .{ .EntityId = entity.net_id },
                        .Message = .{
                            .AttributeChangedNotify = .{
                                .Attributes = attrs_for_notify,
                            },
                        },
                    },
                } });
                try scene.saveEntity(fs, alloc.gpa, entity);
            }
        }

        try conn.push(notify, alloc.arena);
        try events.enqueue(.chat_command_response, .{ .content = "set stat to inputted value" });
    }
};
