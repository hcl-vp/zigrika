// typed no-op handlers for unimplemented client requests so the game doesnt freeze.
const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

const ph_ba_success_code: pb.ErrorCode = .Success;

pub fn onDollSmallMapInfoRequest(
    txn: *Transaction(pb.DollSmallMapInfoRequest),
) !void {
    txn.respond(.{ .ErrorCode = @intFromEnum(pb.ErrorCode.Success) });
}

pub fn onRoleVisionRecommendDataRequest(
    txn: *Transaction(pb.RoleVisionRecommendDataRequest),
) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onRoleVisionRecommendAttrRequest(
    txn: *Transaction(pb.RoleVisionRecommendAttrRequest),
) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onRoleVisionMainPhantomRequest(
    txn: *Transaction(pb.RoleVisionMainPhantomRequest),
) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onPhantomRefiningRequest(txn: *Transaction(pb.PhantomRefiningRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onCalabashBatchRefiningRequest(txn: *Transaction(pb.CalabashBatchRefiningRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onPhantomBatchDirectRefiningRequest(txn: *Transaction(pb.PhantomBatchDirectRefiningRequest)) !void {
    txn.respond(.{
        .ErrorCode = .Success,
        .DirectRefineWeekTimes = 0,
    });
}

pub fn onPhBaPlanUsePlanRequest(txn: *Transaction(pb.PhBaPlanUsePlanRequest)) !void {
    txn.respond(.{
        .ErrorCode = ph_ba_success_code,
        .UsePlan = emptyUsePlan(),
        .TowPlanSame = true,
    });
}

pub fn onPhBaPlanSaveUsePlanRequest(txn: *Transaction(pb.PhBaPlanSaveUsePlanRequest)) !void {
    txn.respond(.{
        .ErrorCode = ph_ba_success_code,
        .TowPlanSame = true,
    });
}

pub fn onPhBaPlanFindPlanRequest(txn: *Transaction(pb.PhBaPlanFindPlanRequest)) !void {
    txn.respond(.{
        .ErrorCode = ph_ba_success_code,
        .Plan = emptyUsePlan(),
        .TowPlanSame = true,
    });
}

pub fn onPhBaPlanUpdatePlanRequest(txn: *Transaction(pb.PhBaPlanUpdatePlanRequest)) !void {
    txn.respond(.{ .ErrorCode = ph_ba_success_code });
}

pub fn onPhBaPlanSetFiveStarSwitchRequest(txn: *Transaction(pb.PhBaPlanSetFiveStarSwitchRequest)) !void {
    txn.respond(.{ .ErrorCode = ph_ba_success_code });
}

pub fn onPhBaPlanSetPlanStatusRequest(txn: *Transaction(pb.PhBaPlanSetPlanStatusRequest)) !void {
    txn.respond(.{
        .ErrorCode = ph_ba_success_code,
        .TowPlanSame = true,
    });
}

pub fn onPhantomFuncValueBatchRequest(txn: *Transaction(pb.PhantomFuncValueBatchRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onPhBaPlanBatchOperRequest(txn: *Transaction(pb.PhBaPlanBatchOperRequest)) !void {
    txn.respond(.{ .errCode = .Success });
}

pub fn onPhantomManageConfigRequest(txn: *Transaction(pb.PhantomManageConfigRequest)) !void {
    txn.respond(.{});
}

pub fn onPhantomSettingBatchUpdateRequest(txn: *Transaction(pb.PhantomSettingBatchUpdateRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onPhantomManageConfigUpdateRequest(txn: *Transaction(pb.PhantomManageConfigUpdateRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

fn emptyUsePlan() pb.PhBaOneAllSuitPlan {
    return .{ .SuitPlanList = std.ArrayList(pb.PhBaOneSuitPlan).empty };
}
