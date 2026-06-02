const BasicInfo = @This();
const std = @import("std");
const pb = @import("proto").pb;

const Allocator = std.mem.Allocator;

pub const default: BasicInfo = .{
    .attributes = .{},
};

attributes: struct {
    pub const pb_attr_count = blk: {
        var count: usize = 0;
        for (std.meta.fields(@This())) |field| {
            if (@hasField(pb.PlayerAttrKey, toPascalCase(field.name))) {
                count += 1;
            }
        }

        break :blk count;
    };

    level: i32 = 80,
    exp: i32 = 0,
    coin: i32 = 777777,
    rare_coin: i32 = 777777,
    head_photo: i32 = 82001209,
    head_frame: i32 = 0,
    area_id: i32 = 1,
    name: []const u8 = "ReversedRooms",
    sign: []const u8 = "discord.gg/reversedrooms",
    sex: i32 = 0,
    origin_world_level: i32 = 8,
    cur_world_level: i32 = 8,
    world_level_time_stamp: i32 = 0,
    cash_coin: i32 = 777777,
    world_permission: i32 = 0,

    pub fn toProto(attrs: @This()) [pb_attr_count]pb.PlayerAttr {
        var list: [pb_attr_count]pb.PlayerAttr = undefined;
        inline for (comptime std.meta.fields(@This()), 0..) |field, i| {
            list[i] = .{
                .Key = @field(pb.PlayerAttrKey, toPascalCase(field.name)),
                .ValueType = if (field.type == i32) .Int32 else .String,
                .Value = if (field.type == i32)
                    .{ .Int32Value = @field(attrs, field.name) }
                else
                    .{ .StringValue = @field(attrs, field.name) },
            };
        }

        return list;
    }
},
role_show_list: []i32 = &.{},
cur_card_id: i32 = 0,
cur_player_title_id: i32 = 0,
last_modify_name_time: i64 = 0,
birthday: i32 = 20260407,
display_birthday: bool = true,

pub fn deinit(info: BasicInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}

fn toPascalCase(comptime snake_case: []const u8) []const u8 {
    var result: []const u8 = "";
    var next_upper = true;

    for (snake_case) |c| {
        if (c == '_') {
            next_upper = true;
            continue;
        }

        if (next_upper) {
            result = result ++ .{std.ascii.toUpper(c)};
            next_upper = false;
        } else {
            result = result ++ .{c};
        }
    }

    return result;
}
