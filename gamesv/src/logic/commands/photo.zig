const std = @import("std");
const pb = @import("proto").pb;
const Connection = @import("../../network/Connection.zig");
const mem = @import("../../mem.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Scene = @import("../../logic/Scene.zig");

pub const photo = struct {
    pub const alias = "cam";
    pub const description = "puts your client into 2.7 photo event mode.\nusage: photo [enabled] \nenabled by default is 1 (true)";

    pub fn call(
        events: *EventQueue,
        scene: *Scene,
        conn: *Connection,
        alloc: mem.Alloc,
        mode: ?bool,
    ) !void {
        if (mode orelse true) {
            const fight_photo_notify = pb.FightPhotoLevelDataUpdateNotify{
                .levels = blk: {
                    var levels: std.ArrayList(pb.LevelData) = .empty;
                    var roles: std.ArrayList(i32) = .empty;
                    const formation = scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
                    for (formation.roles) |maybe_role| {
                        if (maybe_role) |role| {
                            try roles.append(alloc.arena, role.role_id);
                        }
                    }
                    try levels.append(alloc.arena, .{
                        .LevelId = 100016,
                        .InstId = 8,
                        .Roles = roles,
                        .GroupId = 1,
                        .IsUnlocked = true,
                    });
                    break :blk levels;
                },
            };

            const instance_dungeon_notify = pb.CreateInstanceDungeonNotify{
                .LevelPlayId = 314800019,
            };

            const behavior_tree_info_notify = pb.BehaviorTreeInfoNotify{
                .TreeInfos = blk: {
                    var list: std.ArrayList(pb.TreeInfo) = .empty;
                    try list.append(alloc.arena, .{
                        .BlackboardId = 314800019,
                        .BtType = .BtTypeInst,
                        .TreeIncId = 69,
                        .TreeOwnerId = scene.player_id,
                    });
                    break :blk list;
                },
            };

            const update_node_status_notify = pb.UpdateNodeStatusNotify{
                .TreeOwnerId = scene.player_id,
                .TreeIncId = 69,
                .NodeId = 13,
                .Status = .Activate,
            };

            const child_quest_notify_1 = pb.UpdateChildQuestNodeStatusNotify{
                .TreeOwnerId = scene.player_id,
                .TreeIncId = 69,
                .NodeId = 13,
                .Status = .Enter,
            };

            const child_quest_notify_2 = pb.UpdateChildQuestNodeStatusNotify{
                .TreeOwnerId = scene.player_id,
                .TreeIncId = 69,
                .NodeId = 13,
                .Status = .EnterAction,
            };

            const level_event_notify = pb.LevelEventNotify{
                .PlayerId = scene.player_id,
                .IncId = 69,
                .GameCtx = pb.GameCtxPb{
                    .CtxType = .ChildQuestNodeEnterAction,
                    .CtxInfo = .{
                        .ChildQuestNodeEnterAction = pb.ChildQuestNodeEnterActionCtxPb{
                            .BehaviorTreeCtx = pb.BehaviorTreeCtxPb{
                                .IncId = 69,
                                .BtType = .BtTypeInst,
                                .BtId = 314800019,
                                .NodeId = 13,
                            },
                        },
                    },
                },
                .TotalCount = 1,
            };

            const child_quest_notify_3 = pb.UpdateChildQuestNodeStatusNotify{
                .TreeOwnerId = scene.player_id,
                .TreeIncId = 69,
                .NodeId = 13,
                .Status = .Progress,
            };

            try conn.push(fight_photo_notify, alloc.arena);
            try conn.push(instance_dungeon_notify, alloc.arena);
            try conn.push(behavior_tree_info_notify, alloc.arena);
            try conn.push(update_node_status_notify, alloc.arena);
            try conn.push(child_quest_notify_1, alloc.arena);
            try conn.push(child_quest_notify_2, alloc.arena);
            try conn.push(level_event_notify, alloc.arena);
            try conn.push(child_quest_notify_3, alloc.arena);

            try events.enqueue(.chat_command_response, .{ .content = "photo event enabled." });
        } else {
            const behavior_tree_delete_notify = pb.BehaviorTreeDeleteNotify{
                .TreeIncIds = blk: {
                    var list: std.ArrayList(i64) = .empty;
                    try list.append(alloc.arena, 69);
                    break :blk list;
                },
            };

            try conn.push(behavior_tree_delete_notify, alloc.arena);

            try events.enqueue(.chat_command_response, .{ .content = "photo event disabled." });
        }
    }
};
