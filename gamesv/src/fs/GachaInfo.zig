const GachaInfo = @This();
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const default: GachaInfo = .{};
pub const data_path = "gacha_info";

pub const Banner = struct {
    id: i32,
    selected_pool_id: i32 = 0,
    daily_pulls: i32 = 0,
    total_pulls: i32 = 0,
};

pub const Bucket = struct {
    id: i32,
    pull_count: i32 = 0,
    pity_four: i32 = 0,
    guarantee_five: bool = false,
    guarantee_four: bool = false,
};

banners: []Banner = &.{},
buckets: []Bucket = &.{},

pub fn getBanner(info: *GachaInfo, gacha_id: i32) ?*Banner {
    for (info.banners) |*banner| {
        if (banner.id == gacha_id) return banner;
    }
    return null;
}

pub fn ensureBanner(info: *GachaInfo, gpa: Allocator, gacha_id: i32, selected_pool_id: i32) !*Banner {
    if (getBanner(info, gacha_id)) |banner| {
        if (banner.selected_pool_id == 0) banner.selected_pool_id = selected_pool_id;
        return banner;
    }

    const new_banners = try gpa.alloc(Banner, info.banners.len + 1);
    @memcpy(new_banners[0..info.banners.len], info.banners);
    new_banners[info.banners.len] = .{
        .id = gacha_id,
        .selected_pool_id = selected_pool_id,
    };

    if (info.banners.len != 0) gpa.free(info.banners);
    info.banners = new_banners;
    return &info.banners[info.banners.len - 1];
}

pub fn getBucket(info: *GachaInfo, bucket_id: i32) ?*Bucket {
    for (info.buckets) |*bucket| {
        if (bucket.id == bucket_id) return bucket;
    }
    return null;
}

pub fn ensureBucket(info: *GachaInfo, gpa: Allocator, bucket_id: i32) !*Bucket {
    if (getBucket(info, bucket_id)) |bucket| return bucket;

    const new_buckets = try gpa.alloc(Bucket, info.buckets.len + 1);
    @memcpy(new_buckets[0..info.buckets.len], info.buckets);
    new_buckets[info.buckets.len] = .{
        .id = bucket_id,
    };

    if (info.buckets.len != 0) gpa.free(info.buckets);
    info.buckets = new_buckets;
    return &info.buckets[info.buckets.len - 1];
}

pub fn deinit(info: GachaInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
