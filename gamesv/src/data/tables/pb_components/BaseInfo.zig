pub const TraceEffect = struct {
    Target: ?i32 = null,
    Effect: ?[]const u8 = null,
};

pub const InfoScanFunction = struct {
    ScanId: ?i32 = null,
    IsConcealed: ?bool = null,
    TraceEffect: ?TraceEffect = null,
};

pub const InfoHeadStateViewConfig = struct {
    HeadStateViewType: ?i32 = null,
    ZOffset: ?i32 = null,
    ForwardOffset: ?i32 = null,
};

pub const InfoCustomAoiZRadius = struct {
    Up: ?i32 = null,
    Down: ?i32 = null,
};

pub const InfoCategory = struct {
    MainType: ?[]const u8 = null,
    MonsterMatchType: ?i32 = null,
    TraceMatchType: ?i32 = null,
    EntityPlotBindingType: ?[]const u8 = null,
    ExploratoryDegree: ?i32 = null,
    HideInFlowType: ?i32 = null,
    DestructibleType: ?[]const u8 = null,
    VehicleType: ?[]const u8 = null,
    NpcType: ?i32 = null,
    AnimalType: ?i32 = null,
    CollectType: ?[]const u8 = null,
    PullStatueMatchType: ?[]const u8 = null,
    ControlMatchType: ?[]const u8 = null,
    ItemFoundation: ?[]const u8 = null,
};

Disabled: ?bool = null,
TidName: ?[]const u8 = null,
Category: ?InfoCategory = null,
Camp: ?i32 = null,
HeadInfo: ?i32 = null,
PackId: ?i32 = null,
DataLayers: ?[]i32 = null,
IsShowNameOnHead: ?bool = null,
HeadStateViewConfig: ?InfoHeadStateViewConfig = null,
OnlineInteractType: ?i32 = null,
ScanFunction: ?InfoScanFunction = null,
AoiLayer: ?i32 = null,
EntityPropertyId: ?i32 = null,
FocusPriority: ?i32 = null,
AoiZRadius: ?i32 = null,
CustomAoiZRadius: ?InfoCustomAoiZRadius = null,
ChildEntityIds: ?[]i64 = null,
NotAllowHidedByTargetRange: ?bool = null,
Occupation: ?[]const u8 = null,
IsOnlineStandalone: ?bool = null,
EntityUpdateStrategy: ?i32 = null,
SpecifiedOnlineStandaloneParentUids: ?[][]const u8 = null,
LowerNpcDensity: ?i32 = null,
MapIcon: ?i32 = null,
