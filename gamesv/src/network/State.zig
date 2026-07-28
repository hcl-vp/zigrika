const State = @This();
const std = @import("std");
const common = @import("common");
const mem = @import("../mem.zig");

const Io = std.Io;
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;
const Assets = @import("../data/Assets.zig");
const Connection = @import("Connection.zig");
const ArenaAllocator = std.heap.ArenaAllocator;
const Scene = @import("../logic/Scene.zig");
const PlayerID = @import("../logic/PlayerID.zig");
const PlayerComponentStorage = @import("../logic/component/player/PlayerComponentStorage.zig");
const BuffTimerScheduler = @import("../logic/schedulers/BuffTimerScheduler.zig");
const DirtySaveQueue = @import("../logic/schedulers/DirtySaveQueue.zig");

const log = std.log.scoped(.state);

io: Io,
gpa: Allocator,
fs: *FileSystem,
conn: *Connection,
assets: *const Assets,
arena: ArenaAllocator,
player_id: PlayerID,
player_components: PlayerComponentStorage,
scene: ?Scene,
buff_timers: BuffTimerScheduler,
dirty_saves: DirtySaveQueue,

pub fn init(
    gpa: Allocator,
    io: Io,
    fs: *FileSystem,
    conn: *Connection,
    assets: *const Assets,
    pcs: PlayerComponentStorage,
    player_id: i32,
) State {
    return .{
        .io = io,
        .gpa = gpa,
        .fs = fs,
        .conn = conn,
        .arena = .init(gpa),
        .assets = assets,
        .player_components = pcs,
        .player_id = .{ .id = player_id },
        .scene = null,
        .buff_timers = .{},
        .dirty_saves = .{},
    };
}

pub fn deinit(s: *State, fs: *FileSystem) void {
    const now_ms = (Io.Clock.awake).now(s.io).toMilliseconds();
    if (s.scene) |*scene| {
        DirtySaveQueue.saveAllBuffs(
            s.gpa,
            fs,
            scene,
            &s.buff_timers,
            s.assets,
            now_ms,
        ) catch |err| {
            log.err("failed to save buff durations during session cleanup: {t}", .{err});
        };
    }

    s.dirty_saves.flush(
        s.gpa,
        fs,
        &s.player_components.role,
        &s.player_components.weapon,
        if (s.scene) |*scene| scene else null,
        &s.buff_timers,
        s.assets,
        now_ms,
    ) catch |err| {
        log.err("failed to flush dirty saves during session cleanup: {t}", .{err});
    };

    s.dirty_saves.deinit(s.gpa);
    s.buff_timers.deinit(s.gpa);
    s.arena.deinit();
    s.player_components.deinit(s.gpa);
    if (s.scene) |*scene| scene.deinit(s.gpa, fs);
}

pub fn extract(s: *State, comptime T: type) !T {
    if (T == Io) return s.io;
    if (T == *FileSystem) return s.fs;
    if (T == *Connection) return s.conn;
    if (T == *const Assets) return s.assets;
    if (T == PlayerID) return s.player_id;
    if (T == mem.Alloc) return .{
        .gpa = s.gpa,
        .arena = s.arena.allocator(),
    };

    if (T == *?Scene) return &s.scene;
    if (T == *Scene) return &(s.scene orelse return error.NotInScene);
    if (T == *BuffTimerScheduler) return &s.buff_timers;
    if (T == *DirtySaveQueue) return &s.dirty_saves;

    const is_struct = comptime std.meta.activeTag(@typeInfo(T)) == .@"struct";

    if (is_struct and @hasDecl(T, "scene_query_types")) {
        if (s.scene) |*scene| {
            return .{
                .iterator = .{ .entities = &scene.entities },
            };
        } else {
            return error.NotInScene;
        }
    }

    if (comptime PlayerComponentStorage.hasComponent(T)) return s.player_components.extract(T);
    if (T == *State) return s;

    @compileError("the type '" ++ @typeName(T) ++ "' can't be extracted out of State");
}
