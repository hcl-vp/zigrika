const CharacterPartConfig = @This();

ModelId: i32,
Parts: []const Part = &.{},

pub const Part = struct {
    Index: i32,
    Name: []const u8,
    LifeRatio: f32,
    BirthActivated: bool,
    PartTagId: i32,
    ActiveTagId: i32,
    CombineSocket: []const u8 = "",
};
