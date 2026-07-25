const EventQueue = @import("EventQueue.zig");
const events = @import("events.zig");
const mem = @import("../mem.zig");
const Scene = @import("Scene.zig");
const Entity = Scene.Entity;

pub fn enqueueEffects(
    entity: Entity,
    fsm: *Entity.FsmComponent,
    event_queue: *EventQueue,
    alloc: mem.Alloc,
    now_ms: i64,
) !bool {
    return enqueueEffectsWithRecheck(entity, fsm, event_queue, alloc, now_ms, true);
}

pub fn enqueueEffectsWithoutRecheck(
    entity: Entity,
    fsm: *Entity.FsmComponent,
    event_queue: *EventQueue,
    alloc: mem.Alloc,
    now_ms: i64,
) !bool {
    return enqueueEffectsWithRecheck(entity, fsm, event_queue, alloc, now_ms, false);
}

fn enqueueEffectsWithRecheck(
    entity: Entity,
    fsm: *Entity.FsmComponent,
    event_queue: *EventQueue,
    alloc: mem.Alloc,
    now_ms: i64,
    recheck: bool,
) !bool {
    if (fsm.lifecycleEffectsPending()) {
        fsm.requestLifecycleRecheck(recheck);
        return true;
    }
    const effects = fsm.lifecycleEffects();
    if (effects.len == 0) return false;

    for (effects) |effect| {
        switch (effect) {
            .enter_fight => try event_queue.enqueue(.fsm_server_action, .{
                .entity = entity,
                .kind = .enter_fight,
            }),
            .add_buff => |buff_id| {
                const buffs = try alloc.arena.alloc(events.BuffAdditionEntry, 1);
                buffs[0] = .{ .id = buff_id, .is_active = true };
                try event_queue.enqueue(.buff_addition, .{
                    .target = entity,
                    .instigator = entity,
                    .buffs = buffs,
                });
            },
            .remove_buff => |buff_id| try event_queue.enqueue(.buff_removal_by_id, .{
                .entity = entity,
                .buff_id = buff_id,
            }),
            .cue_paralysis => try event_queue.enqueue(.fsm_server_action, .{
                .entity = entity,
                .kind = .cue_paralysis,
            }),
            .reset_status => try event_queue.enqueue(.fsm_server_action, .{
                .entity = entity,
                .kind = .reset_status,
            }),
            .set_rage_full => try event_queue.enqueue(.fsm_server_action, .{
                .entity = entity,
                .kind = .set_rage_full,
            }),
            .set_instance_state => |tag_id| try event_queue.enqueue(.fsm_server_action, .{
                .entity = entity,
                .kind = .{ .instance_state = tag_id },
            }),
            .activate_part => |part| try event_queue.enqueue(.fsm_server_action, .{
                .entity = entity,
                .kind = .{ .activate_part = part },
            }),
            .reset_part => |part| try event_queue.enqueue(.fsm_server_action, .{
                .entity = entity,
                .kind = .{ .reset_part = part },
            }),
        }
    }

    try event_queue.enqueue(.fsm_lifecycle_complete, .{
        .entity = entity,
        .now_ms = now_ms,
        .recheck = recheck,
    });
    fsm.markLifecycleEffectsEnqueued(alloc.gpa);
    return true;
}
