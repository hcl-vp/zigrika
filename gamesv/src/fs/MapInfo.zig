const MapInfo = @This();
const std = @import("std");
const pb = @import("proto").pb;

const Allocator = std.mem.Allocator;

pub const default: MapInfo = .{};
pub const data_path = "map_info";

fn customMarkState(state: i32) pb.MarkPointState {
    return switch (state) {
        1 => .MarkDisable,
        2 => .MarkComplete,
        else => .MarkNormal,
    };
}

pub const CustomMark = struct {
    id: i32,
    x: f32,
    y: f32,
    z: f32,
    is_trace: i32,
    mark_type: i32,
    map_id: i32,
    config_id: i32,
    locked: bool,
    state: i32,

    pub fn toPb(mark: CustomMark) pb.MarkPointInfo {
        return .{
            .PosX = mark.x,
            .PosY = mark.y,
            .PosZ = mark.z,
            .ConfigId = mark.config_id,
            .MarkId = mark.id,
            .IsTrace = mark.is_trace,
            .MarkType = mark.mark_type,
            .MapId = mark.map_id,
            .IsServerDisable = mark.locked,
            .MarkPointState = customMarkState(mark.state),
        };
    }
};

custom_marks: []CustomMark = &.{},
tracked_mark_ids: []i32 = &.{},
next_custom_mark_id: i32 = 1_000_000,

fn containsId(ids: []const i32, id: i32) bool {
    for (ids) |existing| {
        if (existing == id) return true;
    }

    return false;
}

fn containsAnyId(ids: []const i32, candidates: []const i32) bool {
    for (candidates) |id| {
        if (containsId(ids, id)) return true;
    }

    return false;
}

fn emptyCustomMarks() []CustomMark {
    return @constCast(&.{});
}

fn emptyTrackedIds() []i32 {
    return @constCast(&.{});
}

fn replaceIds(info: *MapInfo, gpa: Allocator, ids: []i32) void {
    if (info.tracked_mark_ids.len != 0) gpa.free(info.tracked_mark_ids);
    info.tracked_mark_ids = ids;
}

pub fn addCustomMark(info: *MapInfo, gpa: Allocator, request: pb.MarkPointRequestInfo) !CustomMark {
    const mark_id = info.next_custom_mark_id;
    info.next_custom_mark_id += 1;

    const mark: CustomMark = .{
        .id = mark_id,
        .x = request.PosX,
        .y = request.PosY,
        .z = request.PosZ,
        .is_trace = request.IsTrace,
        .mark_type = request.MarkType,
        .map_id = request.MapId,
        .config_id = request.ConfigId,
        .locked = false,
        .state = 0,
    };

    const marks = try gpa.alloc(CustomMark, info.custom_marks.len + 1);
    @memcpy(marks[0..info.custom_marks.len], info.custom_marks);
    marks[info.custom_marks.len] = mark;

    if (info.custom_marks.len != 0) gpa.free(info.custom_marks);
    info.custom_marks = marks;

    return mark;
}

pub fn deleteCustomMarks(info: *MapInfo, gpa: Allocator, mark_ids: []const i32) !void {
    if (mark_ids.len == 0) return;

    var mark_count: usize = 0;
    for (info.custom_marks) |mark| {
        if (!containsId(mark_ids, mark.id)) mark_count += 1;
    }

    if (mark_count != info.custom_marks.len) {
        const marks = if (mark_count == 0) emptyCustomMarks() else marks: {
            const marks = try gpa.alloc(CustomMark, mark_count);
            var write_index: usize = 0;
            for (info.custom_marks) |mark| {
                if (containsId(mark_ids, mark.id)) continue;
                marks[write_index] = mark;
                write_index += 1;
            }
            break :marks marks;
        };

        if (info.custom_marks.len != 0) gpa.free(info.custom_marks);
        info.custom_marks = marks;
    }

    if (containsAnyId(info.tracked_mark_ids, mark_ids)) {
        var track_count: usize = 0;
        for (info.tracked_mark_ids) |mark_id| {
            if (!containsId(mark_ids, mark_id)) track_count += 1;
        }

        const tracked = if (track_count == 0) emptyTrackedIds() else tracked: {
            const tracked = try gpa.alloc(i32, track_count);
            var write_index: usize = 0;
            for (info.tracked_mark_ids) |mark_id| {
                if (containsId(mark_ids, mark_id)) continue;
                tracked[write_index] = mark_id;
                write_index += 1;
            }
            break :tracked tracked;
        };

        replaceIds(info, gpa, tracked);
    }
}

pub fn trackMark(info: *MapInfo, gpa: Allocator, mark_id: i32) !void {
    if (mark_id == 0 or containsId(info.tracked_mark_ids, mark_id)) return;

    const ids = try gpa.alloc(i32, info.tracked_mark_ids.len + 1);
    @memcpy(ids[0..info.tracked_mark_ids.len], info.tracked_mark_ids);
    ids[info.tracked_mark_ids.len] = mark_id;
    replaceIds(info, gpa, ids);
}

pub fn untrackMark(info: *MapInfo, gpa: Allocator, mark_id: i32) !void {
    if (!containsId(info.tracked_mark_ids, mark_id)) return;

    if (info.tracked_mark_ids.len == 1) {
        replaceIds(info, gpa, emptyTrackedIds());
        return;
    }

    var write_index: usize = 0;
    const ids = try gpa.alloc(i32, info.tracked_mark_ids.len - 1);
    for (info.tracked_mark_ids) |existing| {
        if (existing == mark_id) continue;
        ids[write_index] = existing;
        write_index += 1;
    }

    replaceIds(info, gpa, ids);
}

pub fn deinit(info: MapInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
