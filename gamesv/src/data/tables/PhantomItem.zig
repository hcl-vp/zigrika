ItemId: i32,
MonsterId: i32,
ParentMonsterId: i32 = 0,
MainProp: MainPropConfig,
SkillId: i32,
MeshId: i32 = 0,
Rarity: i32,
QualityId: i32,
LevelUpGroupId: i32,
ShowInBag: bool,
Destructible: bool,
FetterGroup: []const i32,
PhantomType: i32 = 0,

pub const MainPropConfig = struct {
    RandGroupId: i32,
    RandNum: i32,
};
