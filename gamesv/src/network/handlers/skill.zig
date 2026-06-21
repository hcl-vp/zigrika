const pb = @import("proto").pb;
const dispatch = @import("combat.zig");

pub fn SkillRequest(txn: *dispatch.CombatRequestTxn(.SkillRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn UseSkillRequest(txn: *dispatch.CombatRequestTxn(.UseSkillRequest)) !void {
    const request: pb.UseSkillRequest = txn.payload;
    txn.respond(.{
        .ErrorCode = .Success,
        .UseSkillInfo = request.UseSkillInfo,
        .SkillSingleId = request.SkillSingleId,
    });
}

pub fn EndSkillRequest(txn: *dispatch.CombatRequestTxn(.EndSkillRequest)) !void {
    const request: pb.EndSkillRequest = txn.payload;
    txn.respond(.{
        .ErrorCode = .Success,
        .UseSkillInfo = request.UseSkillInfo,
        .SkillSingleId = request.SkillSingleId,
    });
}

pub fn EndSkillPush(_: pb.EndSkillPush) !void {}
