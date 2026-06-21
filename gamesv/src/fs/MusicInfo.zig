const MusicInfo = @This();
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const default: MusicInfo = .{};
pub const data_path = "music_info";

favorite_music_ids: []i32 = &.{},

pub fn replaceFavoriteMusicIds(info: *MusicInfo, gpa: Allocator, ids: []i32) void {
    if (info.favorite_music_ids.len != 0) gpa.free(info.favorite_music_ids);
    info.favorite_music_ids = ids;
}

pub fn deinit(info: MusicInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
