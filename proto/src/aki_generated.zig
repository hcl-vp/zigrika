pub const DangoAbyssActivityData = struct {
    pub const RoleList_field_number: u32 = 1;
    pub const AbyssPluginItemInfo_field_number: u32 = 2;
    pub const AbyssRewardInfo_field_number: u32 = 3;
    pub const UnlockChallengeIdList_field_number: u32 = 4;
    pub const LikeCount_field_number: u32 = 5;
    pub const AbyssChallengeData_field_number: u32 = 6;
    pub const StartTime_field_number: u32 = 7;
    pub const EndTime_field_number: u32 = 8;
};
pub const AbyssChallengeData = struct {
    pub const ChallengeId_field_number: u32 = 1;
    pub const CanUnlock_field_number: u32 = 2;
    pub const CanChallenge_field_number: u32 = 3;
    pub const UnlockTime_field_number: u32 = 4;
    pub const ConditionFinishState_field_number: u32 = 5;
    pub const MaxProgress_field_number: u32 = 6;
    pub const MinPassTime_field_number: u32 = 7;
    pub const IsPassed_field_number: u32 = 8;
};
pub const AbyssDangoRoleData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Level_field_number: u32 = 2;
    pub const EquipItems_field_number: u32 = 3;
};
pub const AbyssPluginItemInfo = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
    pub const IncrId_field_number: u32 = 3;
    pub const FuncValue_field_number: u32 = 4;
};
pub const AbyssRewardInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const CanGetReward_field_number: u32 = 4;
    pub const CurrentProgress_field_number: u32 = 6;
    pub const TargetProgress_field_number: u32 = 7;
    pub const CanUnlock_field_number: u32 = 9;
};
pub const AddCountItemInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
    pub const IncrId_field_number: u32 = 3;
};
pub const ItemLockRequest = struct {
    pub const msg_id: u16 = 28400;
    pub const ItemId_field_number: u32 = 5;
    pub const IncrId_field_number: u32 = 1;
};
pub const ItemLockResponse = struct {
    pub const msg_id: u16 = 24035;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const RewardItemInfo = struct {
    pub const ShowPlanId_field_number: u32 = 1;
    pub const ItemId_field_number: u32 = 2;
    pub const Count_field_number: u32 = 3;
    pub const IncrId_field_number: u32 = 4;
};
pub const ItemRewardNotify = struct {
    pub const msg_id: u16 = 26719;
    pub const DropId_field_number: u32 = 11;
    pub const Reason_field_number: u32 = 10;
    pub const Magnification_field_number: u32 = 6;
    pub const DropFrom_field_number: u32 = 1;
    pub const RewardItems_field_number: u32 = 7;
};
pub const RewardItemInfoList = struct {
    pub const ItemList_field_number: u32 = 1;
};
pub const NormalItemRequest = struct {
    pub const msg_id: u16 = 29216;
};
pub const NormalItemResponse = struct {
    pub const msg_id: u16 = 19801;
    pub const NormalItemList_field_number: u32 = 14;
};
pub const NormalItemUpdateNotify = struct {
    pub const msg_id: u16 = 24526;
    pub const NormalItemList_field_number: u32 = 8;
    pub const NoTips_field_number: u32 = 1;
};
pub const NormalItemAddNotify = struct {
    pub const msg_id: u16 = 25940;
    pub const NormalItemList_field_number: u32 = 12;
    pub const NoTips_field_number: u32 = 10;
    pub const Reason_field_number: u32 = 3;
};
pub const WeaponItemRequest = struct {
    pub const msg_id: u16 = 22918;
};
pub const WeaponItemResponse = struct {
    pub const msg_id: u16 = 20850;
    pub const WeaponItemList_field_number: u32 = 8;
};
pub const WeaponItemAddNotify = struct {
    pub const msg_id: u16 = 23989;
    pub const WeaponItemList_field_number: u32 = 6;
    pub const AddFromRole_field_number: u32 = 7;
    pub const Reason_field_number: u32 = 15;
};
pub const WeaponItemRemoveNotify = struct {
    pub const msg_id: u16 = 29848;
    pub const WeaponItemIncrIdList_field_number: u32 = 7;
};
pub const PhantomItemRequest = struct {
    pub const msg_id: u16 = 29826;
};
pub const RolePhantomEquipInfo = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const PhantomItemIncrId_field_number: u32 = 2;
};
pub const RolePhantomPropInfo = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const BaseProp_field_number: u32 = 2;
    pub const AddProp_field_number: u32 = 3;
};
pub const PhantomItemResponse = struct {
    pub const msg_id: u16 = 28177;
    pub const PhantomItemList_field_number: u32 = 13;
    pub const EquipInfoList_field_number: u32 = 15;
    pub const PropInfo_field_number: u32 = 9;
    pub const MaxCost_field_number: u32 = 3;
    pub const PhantomSkinList_field_number: u32 = 6;
    pub const DirectRefineWeekTimes_field_number: u32 = 5;
};
pub const PhantomItemAddNotify = struct {
    pub const msg_id: u16 = 21758;
    pub const PhantomItemList_field_number: u32 = 7;
    pub const Reason_field_number: u32 = 4;
};
pub const PhantomItemRemoveNotify = struct {
    pub const msg_id: u16 = 24063;
    pub const PhantomItemIncrIdList_field_number: u32 = 1;
};
pub const ItemFuncValueUpdateNotify = struct {
    pub const msg_id: u16 = 20219;
    pub const IncrId_field_number: u32 = 8;
    pub const FuncValue_field_number: u32 = 12;
};
pub const WeaponItem = struct {
    pub const Id_field_number: u32 = 1;
    pub const IncrId_field_number: u32 = 2;
    pub const FuncValue_field_number: u32 = 3;
    pub const WeaponLevel_field_number: u32 = 4;
    pub const WeaponExp_field_number: u32 = 5;
    pub const WeaponBreach_field_number: u32 = 6;
    pub const WeaponResonLevel_field_number: u32 = 7;
    pub const RoleId_field_number: u32 = 8;
};
pub const PhantomItem = struct {
    pub const Id_field_number: u32 = 1;
    pub const IncrId_field_number: u32 = 2;
    pub const FuncValue_field_number: u32 = 3;
    pub const PhantomLevel_field_number: u32 = 4;
    pub const PhantomExp_field_number: u32 = 5;
    pub const PhantomMainProp_field_number: u32 = 6;
    pub const PhantomSubProp_field_number: u32 = 7;
    pub const FetterGroupId_field_number: u32 = 8;
    pub const SkinId_field_number: u32 = 9;
    pub const UnAckSubProp_field_number: u32 = 10;
    pub const LockPropIndex_field_number: u32 = 11;
};
pub const NormalItem = struct {
    pub const Id_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
    pub const ExpireTime_field_number: u32 = 4;
};
pub const PhantomPropInfo = struct {
    pub const PhantomPropId_field_number: u32 = 1;
    pub const Value_field_number: u32 = 2;
};
pub const ItemPkgOpenNotify = struct {
    pub const msg_id: u16 = 23295;
    pub const OpenPkg_field_number: u32 = 13;
};
pub const ValidTimeItemRequest = struct {
    pub const msg_id: u16 = 27750;
};
pub const ValidTimeItem = struct {
    pub const Id_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
    pub const IncrId_field_number: u32 = 3;
    pub const ExpireTime_field_number: u32 = 4;
};
pub const ValidTimeItemResponse = struct {
    pub const msg_id: u16 = 27294;
    pub const ItemList_field_number: u32 = 12;
};
pub const RobotRoleInfo = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const BaseProp_field_number: u32 = 2;
    pub const AddProp_field_number: u32 = 3;
    pub const RoleEquipmentPropData_field_number: u32 = 4;
};
pub const RobotRolePropRequest = struct {
    pub const msg_id: u16 = 23048;
    pub const RoleIds_field_number: u32 = 14;
};
pub const RobotRolePropResponse = struct {
    pub const msg_id: u16 = 16853;
    pub const Error_field_number: u32 = 6;
    pub const RobotRoleInfo_field_number: u32 = 5;
};
pub const ItemDeprecateRequest = struct {
    pub const msg_id: u16 = 25713;
    pub const ItemId_field_number: u32 = 4;
    pub const IncrId_field_number: u32 = 12;
};
pub const ItemDeprecateResponse = struct {
    pub const msg_id: u16 = 25490;
    pub const ErrorCode_field_number: u32 = 5;
};
pub const AccessPathTimeServerConfigRequest = struct {
    pub const msg_id: u16 = 20347;
};
pub const AccessPathTimeServerConfig = struct {
    pub const Id_field_number: u32 = 1;
    pub const BeginTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
};
pub const AccessPathTimeServerConfigResponse = struct {
    pub const msg_id: u16 = 22384;
    pub const AccessPathTimeServerConfig_field_number: u32 = 13;
};
pub const DErrorResult = struct {
    pub const ErrorCode_field_number: u32 = 1;
    pub const ErrorParams_field_number: u32 = 2;
};
pub const PbGetRoleListNotify = struct {
    pub const msg_id: u16 = 29520;
    pub const RoleList_field_number: u32 = 5;
};
pub const PbUpLevelRoleRequest = struct {
    pub const msg_id: u16 = 17427;
    pub const RoleId_field_number: u32 = 1;
    pub const ItemList_field_number: u32 = 7;
};
pub const PbUpLevelRoleResponse = struct {
    pub const msg_id: u16 = 28924;
    pub const ErrorCode_field_number: u32 = 10;
    pub const RoleId_field_number: u32 = 8;
    pub const Exp_field_number: u32 = 6;
    pub const Level_field_number: u32 = 7;
    pub const ItemMap_field_number: u32 = 14;
};
pub const PbOverRoleRequest = struct {
    pub const msg_id: u16 = 23087;
    pub const RoleId_field_number: u32 = 5;
};
pub const PbOverRoleResponse = struct {
    pub const msg_id: u16 = 19514;
    pub const ErrorCode_field_number: u32 = 1;
    pub const RoleId_field_number: u32 = 12;
    pub const Breakthrough_field_number: u32 = 15;
};
pub const PbUpLevelSkillRequest = struct {
    pub const msg_id: u16 = 23879;
    pub const RoleId_field_number: u32 = 9;
    pub const SkillId_field_number: u32 = 8;
    pub const UseBox_field_number: u32 = 15;
};
pub const PbUpLevelSkillResponse = struct {
    pub const msg_id: u16 = 29794;
    pub const ErrorCode_field_number: u32 = 9;
    pub const RoleId_field_number: u32 = 2;
    pub const SkillInfo_field_number: u32 = 1;
};
pub const PbRolePropsNotify = struct {
    pub const msg_id: u16 = 29840;
    pub const RoleId_field_number: u32 = 5;
    pub const BaseProp_field_number: u32 = 3;
    pub const AddProp_field_number: u32 = 2;
};
pub const ArrayIntInt = struct {
    pub const Key_field_number: u32 = 1;
    pub const Value_field_number: u32 = 2;
};
pub const ArrayIntDouble = struct {
    pub const Key_field_number: u32 = 1;
    pub const Value_field_number: u32 = 2;
};
pub const ArraySkillNode = struct {
    pub const SkillNodeId_field_number: u32 = 1;
    pub const IsActive_field_number: u32 = 2;
    pub const SkillId_field_number: u32 = 3;
};
pub const ResonInfo = struct {
    pub const ResonId_field_number: u32 = 1;
    pub const IsOpen_field_number: u32 = 2;
    pub const Increase_field_number: u32 = 3;
};
pub const RoleInfo = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const Name_field_number: u32 = 2;
    pub const Level_field_number: u32 = 3;
    pub const Exp_field_number: u32 = 4;
    pub const Breakthrough_field_number: u32 = 5;
    pub const Skills_field_number: u32 = 6;
    pub const Phantom_field_number: u32 = 7;
    pub const Star_field_number: u32 = 8;
    pub const Favor_field_number: u32 = 10;
    pub const Reson_field_number: u32 = 11;
    pub const CurModel_field_number: u32 = 12;
    pub const Models_field_number: u32 = 13;
    pub const BaseProp_field_number: u32 = 14;
    pub const AddProp_field_number: u32 = 15;
    pub const CreateTime_field_number: u32 = 17;
    pub const SkillNodeState_field_number: u32 = 19;
    pub const ResonantChainGroupIndex_field_number: u32 = 20;
    pub const SkinId_field_number: u32 = 21;
    pub const EnableSelfBgm_field_number: u32 = 22;
};
pub const PbRoleSkillLevelNotify = struct {
    pub const msg_id: u16 = 29836;
    pub const RoleId_field_number: u32 = 1;
    pub const SkillInfo_field_number: u32 = 8;
};
pub const SkillEffect = struct {
    pub const Level_field_number: u32 = 1;
    pub const EffectDescList_field_number: u32 = 3;
};
pub const OneSkillEffect = struct {
    pub const Id_field_number: u32 = 1;
    pub const Desc_field_number: u32 = 3;
};
pub const RoleLevelUpViewRequest = struct {
    pub const msg_id: u16 = 24495;
    pub const RoleId_field_number: u32 = 14;
    pub const MaxItemId_field_number: u32 = 1;
    pub const ItemList_field_number: u32 = 12;
};
pub const RoleLevelUpViewResponse = struct {
    pub const msg_id: u16 = 24347;
    pub const ErrorCode_field_number: u32 = 5;
    pub const Level_field_number: u32 = 10;
    pub const LevelExpInfo_field_number: u32 = 9;
    pub const Exp_field_number: u32 = 7;
    pub const AddExp_field_number: u32 = 13;
    pub const FinalProp_field_number: u32 = 15;
    pub const CostList_field_number: u32 = 4;
    pub const OverflowList_field_number: u32 = 8;
    pub const ItemList_field_number: u32 = 14;
};
pub const RoleBreakThroughViewRequest = struct {
    pub const msg_id: u16 = 23195;
    pub const RoleId_field_number: u32 = 8;
};
pub const RoleBreakThroughViewResponse = struct {
    pub const msg_id: u16 = 15163;
    pub const ErrorCode_field_number: u32 = 2;
    pub const LevelLimit_field_number: u32 = 12;
    pub const UnLockSkillId_field_number: u32 = 7;
    pub const CostList_field_number: u32 = 14;
    pub const RewardList_field_number: u32 = 3;
    pub const FinalProp_field_number: u32 = 15;
    pub const IsConditionFinish_field_number: u32 = 4;
};
pub const RoleSkillLevelUpViewRequest = struct {
    pub const msg_id: u16 = 27567;
    pub const RoleId_field_number: u32 = 6;
    pub const SkillId_field_number: u32 = 1;
};
pub const RoleSkillLevelUpViewResponse = struct {
    pub const msg_id: u16 = 29970;
    pub const ErrorCode_field_number: u32 = 15;
    pub const SkillEffectList_field_number: u32 = 4;
    pub const CostList_field_number: u32 = 1;
};
pub const RoleSkillViewRequest = struct {
    pub const msg_id: u16 = 23092;
    pub const RoleId_field_number: u32 = 3;
    pub const SkillId_field_number: u32 = 15;
};
pub const RoleSkillViewResponse = struct {
    pub const msg_id: u16 = 22663;
    pub const ErrorCode_field_number: u32 = 10;
    pub const SkillEffectList_field_number: u32 = 4;
    pub const PreSkillEffectList_field_number: u32 = 5;
    pub const IsConditionFinish_field_number: u32 = 1;
};
pub const RoleActivateSkillRequest = struct {
    pub const msg_id: u16 = 24339;
    pub const RoleId_field_number: u32 = 8;
    pub const SkillNodeId_field_number: u32 = 10;
};
pub const RoleActivateSkillResponse = struct {
    pub const msg_id: u16 = 26119;
    pub const ErrorCode_field_number: u32 = 13;
    pub const RoleId_field_number: u32 = 14;
    pub const SkillInfo_field_number: u32 = 10;
};
pub const RoleSkillNodeNotify = struct {
    pub const msg_id: u16 = 27849;
    pub const RoleId_field_number: u32 = 9;
    pub const SkillNodeState_field_number: u32 = 2;
};
pub const ResonantChainUnlockRequest = struct {
    pub const msg_id: u16 = 18343;
    pub const RoleId_field_number: u32 = 11;
};
pub const ResonantChainUnlockResponse = struct {
    pub const msg_id: u16 = 20812;
    pub const ErrorCode_field_number: u32 = 1;
    pub const RoleId_field_number: u32 = 7;
    pub const ResonantChainGroupIndex_field_number: u32 = 13;
};
pub const RoleSexChangeRequest = struct {
    pub const msg_id: u16 = 25431;
    pub const Sex_field_number: u32 = 7;
};
pub const RoleSexChangeResponse = struct {
    pub const msg_id: u16 = 25854;
    pub const ErrorCode_field_number: u32 = 5;
    pub const Sex_field_number: u32 = 6;
};
pub const RoleElementChangeRequest = struct {
    pub const msg_id: u16 = 16331;
    pub const ElementType_field_number: u32 = 2;
};
pub const RoleElementChangeResponse = struct {
    pub const msg_id: u16 = 26044;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const RoleChangeNotify = struct {
    pub const msg_id: u16 = 22372;
    pub const SourceRoleId_field_number: u32 = 1;
    pub const RoleInfo_field_number: u32 = 13;
};
pub const RoleChangeUnlockNotify = struct {
    pub const msg_id: u16 = 29988;
    pub const UnlockRoleIds_field_number: u32 = 12;
    pub const NextAllowChangeTime_field_number: u32 = 8;
};
pub const RoleSkinChangeRequest = struct {
    pub const msg_id: u16 = 27771;
    pub const RoleId_field_number: u32 = 9;
    pub const SkinId_field_number: u32 = 13;
    pub const IsWearWeaponSkin_field_number: u32 = 2;
};
pub const RoleSkinChangeResponse = struct {
    pub const msg_id: u16 = 23402;
    pub const ErrorCode_field_number: u32 = 14;
};
pub const UnlockRoleSkinListRequest = struct {
    pub const msg_id: u16 = 20733;
};
pub const UnlockRoleSkinListResponse = struct {
    pub const msg_id: u16 = 24815;
    pub const RoleSkinList_field_number: u32 = 3;
};
pub const UnlockRoleSkinListNofity = struct {
    pub const msg_id: u16 = 25673;
    pub const RoleSkinList_field_number: u32 = 4;
};
pub const RoleOperateSelfBgmRequest = struct {
    pub const msg_id: u16 = 20516;
    pub const RoleId_field_number: u32 = 7;
    pub const IsOpen_field_number: u32 = 6;
};
pub const RoleOperateSelfBgmResponse = struct {
    pub const msg_id: u16 = 15784;
    pub const ErrorCode_field_number: u32 = 14;
    pub const RoleId_field_number: u32 = 1;
    pub const IsOpen_field_number: u32 = 3;
};
pub const RoleDevelopConfigRequest = struct {
    pub const msg_id: u16 = 26334;
    aVersion: ?union(enum) {
    } = null,
    pub const Version_field_number: u32 = 4;
};
pub const RoleDevelopConfigResponse = struct {
    pub const msg_id: u16 = 19230;
    pub const Configs_field_number: u32 = 12;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const RoleDevelopConfigs = struct {
    pub const DevPropsList_field_number: u32 = 1;
    pub const DevTargetRole_field_number: u32 = 2;
    pub const DevPropsProjectList_field_number: u32 = 3;
    pub const Version_field_number: u32 = 4;
    pub const DevTargetPlanId_field_number: u32 = 5;
    pub const DevTargetFirstPhantomId_field_number: u32 = 6;
};
pub const RoleDevPropsProjectConfig = struct {
    pub const Id_field_number: u32 = 1;
    pub const ElementId_field_number: u32 = 2;
    pub const RoleName_field_number: u32 = 3;
    pub const RoleExperience_field_number: u32 = 4;
    pub const RoleGoalLevel_field_number: u32 = 5;
    pub const WeaponGoalLevel_field_number: u32 = 6;
    pub const WeaponExperience_field_number: u32 = 7;
    pub const RoleItemGroup_field_number: u32 = 8;
    pub const WeaponBreachItemGroup_field_number: u32 = 9;
    pub const WeaponType_field_number: u32 = 10;
    pub const SkillItemGroup_field_number: u32 = 11;
    pub const PrefectSkillLevel_field_number: u32 = 12;
    pub const RoleHeadIcon_field_number: u32 = 13;
    pub const RoleHeadIconSmall_field_number: u32 = 14;
    pub const FormationRoleCard_field_number: u32 = 15;
};
pub const RoleDevPropsConfig = struct {
    pub const Id_field_number: u32 = 1;
    pub const ProspectBeginTime_field_number: u32 = 2;
    pub const ProspectEndTime_field_number: u32 = 3;
    pub const TypeId_field_number: u32 = 4;
    pub const GachaId_field_number: u32 = 5;
    pub const SpecialGachaPair_field_number: u32 = 6;
    pub const SortId_field_number: u32 = 7;
};
pub const SpecialGachaPair = struct {
    pub const TypeId_field_number: u32 = 1;
    pub const GachaId_field_number: u32 = 2;
};
pub const RoleConfigInfoNotify = struct {
    pub const msg_id: u16 = 22377;
    pub const RoleConfigs_field_number: u32 = 1;
};
pub const RoleConfigInfo = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const SkillBranch_field_number: u32 = 2;
};
pub const RoleSkillBranchModifyRequest = struct {
    pub const msg_id: u16 = 23861;
    pub const RoleId_field_number: u32 = 12;
    pub const SkillBranch_field_number: u32 = 9;
};
pub const RoleSkillBranchModifyResponse = struct {
    pub const msg_id: u16 = 19854;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const RoleConfigInfoUpdateNotify = struct {
    pub const msg_id: u16 = 23877;
    pub const RoleConfigs_field_number: u32 = 2;
};
pub const RoleSkillQuickLevelUpRequest = struct {
    pub const msg_id: u16 = 25103;
    pub const RoleId_field_number: u32 = 10;
    pub const SkillId_field_number: u32 = 6;
    pub const TargetLevel_field_number: u32 = 15;
    pub const UseBox_field_number: u32 = 7;
};
pub const RoleSkillQuickLevelUpResponse = struct {
    pub const msg_id: u16 = 16282;
    pub const ErrorCode_field_number: u32 = 7;
    pub const RoleInfo_field_number: u32 = 4;
};
pub const SecGetReportData2FlowRequest = struct {
    pub const msg_id: u16 = 24945;
    pub const ReportData_field_number: u32 = 11;
};
pub const SecGetReportData2FlowResponse = struct {
    pub const msg_id: u16 = 16138;
    pub const Error_field_number: u32 = 14;
};
pub const Vector = struct {
    pub const X_field_number: u32 = 1;
    pub const Y_field_number: u32 = 2;
    pub const Z_field_number: u32 = 3;
};
pub const Rotator = struct {
    pub const Pitch_field_number: u32 = 1;
    pub const Yaw_field_number: u32 = 2;
    pub const Roll_field_number: u32 = 3;
};
pub const Transform = struct {
    pub const Pos_field_number: u32 = 1;
    pub const Rot_field_number: u32 = 2;
};
pub const GameplayAttributeData = struct {
    pub const CurrentValue_field_number: u32 = 1;
    pub const ValueIncrement_field_number: u32 = 2;
    pub const AttributeType_field_number: u32 = 3;
};
pub const AttrData = struct {
    pub const AttributeType_field_number: u32 = 1;
    pub const CurrentValue_field_number: u32 = 2;
    pub const ValueIncrement_field_number: u32 = 3;
};
pub const GameplayTagData = struct {
    pub const Id_field_number: u32 = 1;
    pub const TagCount_field_number: u32 = 2;
};
pub const CommonTagData = struct {
    pub const TagId_field_number: u32 = 1;
    pub const RemoveTagIds_field_number: u32 = 2;
};
pub const MovementInformation = struct {
    pub const LinearVelocity_field_number: u32 = 1;
    pub const AngularVelocity_field_number: u32 = 2;
    pub const Location_field_number: u32 = 3;
    pub const Rotation_field_number: u32 = 4;
    pub const bSimulatedPhysicSleep_field_number: u32 = 5;
    pub const bRepPhysics_field_number: u32 = 6;
    pub const MovementMode_field_number: u32 = 7;
    pub const TimeStamp_field_number: u32 = 8;
    pub const InputDirection_field_number: u32 = 9;
    pub const ResetMeshOffset_field_number: u32 = 10;
    pub const IsJump_field_number: u32 = 11;
    pub const HorizontalJumpSpeed_field_number: u32 = 12;
};
pub const RelativeMoveReplaySample = struct {
    pub const BaseMovementEntityId_field_number: u32 = 1;
    pub const RelativeLocation_field_number: u32 = 2;
    pub const RelativeRotation_field_number: u32 = 3;
};
pub const MoveReplaySample = struct {
    pub const LinearVelocity_field_number: u32 = 1;
    pub const Location_field_number: u32 = 2;
    pub const Rotation_field_number: u32 = 3;
    pub const MovementMode_field_number: u32 = 4;
    pub const TimeStamp_field_number: u32 = 5;
    pub const InputDirection_field_number: u32 = 6;
    pub const Tags_field_number: u32 = 7;
    pub const RelativeMoveReplaySample_field_number: u32 = 8;
    pub const ControllerPitch_field_number: u32 = 9;
    pub const TimeScale_field_number: u32 = 10;
    pub const ServerTimeStamp_field_number: u32 = 11;
    pub const RTT_field_number: u32 = 12;
    pub const SlideForward_field_number: u32 = 13;
    pub const MoveState_field_number: u32 = 14;
    pub const SkillId_field_number: u32 = 15;
    pub const ElapsedLogicTickTime_field_number: u32 = 16;
};
pub const PrivateTag = struct {
    pub const PlayerId_field_number: u32 = 1;
    pub const Tags_field_number: u32 = 31;
};
pub const CombatCommon = struct {
    pub const PreMessageId_field_number: u32 = 1;
    pub const MessageId_field_number: u32 = 2;
    pub const Originator_field_number: u32 = 3;
    pub const TimeStamp_field_number: u32 = 4;
    pub const EntityId_field_number: u32 = 5;
    pub const IsServerRequest_field_number: u32 = 6;
};
pub const EntityRemoveInfo = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const Type_field_number: u32 = 2;
};
pub const RoleShowEntry = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const Level_field_number: u32 = 2;
};
pub const PlayerDetails = struct {
    pub const PlayerId_field_number: u32 = 1;
    pub const Name_field_number: u32 = 2;
    pub const Level_field_number: u32 = 3;
    pub const OriginWorldLevel_field_number: u32 = 4;
    pub const CurWorldLevel_field_number: u32 = 5;
    pub const HeadId_field_number: u32 = 6;
    pub const HeadFrameId_field_number: u32 = 7;
    pub const Signature_field_number: u32 = 8;
    pub const IsOnline_field_number: u32 = 9;
    pub const IsCanLobbyOnline_field_number: u32 = 10;
    pub const LastOfflineTime_field_number: u32 = 11;
    pub const TeamMemberCount_field_number: u32 = 12;
    pub const LevelGap_field_number: u32 = 13;
    pub const Birthday_field_number: u32 = 14;
    pub const RoleShowList_field_number: u32 = 15;
    pub const CardShowList_field_number: u32 = 16;
    pub const CurCard_field_number: u32 = 17;
    pub const DisplayBirthday_field_number: u32 = 18;
    pub const LastEnterMultiWillTime_field_number: u32 = 19;
    pub const SdkUserId_field_number: u32 = 20;
    pub const SdkOnlineId_field_number: u32 = 21;
    pub const SdkAccountId_field_number: u32 = 22;
    pub const CrossPlayEnabled_field_number: u32 = 23;
    pub const LimitState_field_number: u32 = 24;
    pub const PlayerTitleId_field_number: u32 = 25;
    pub const CurPlayerTitleId_field_number: u32 = 26;
    pub const Sex_field_number: u32 = 27;
    pub const Deactivation_field_number: u32 = 28;
    pub const XboxUserId_field_number: u32 = 29;
    pub const XboxOnlineId_field_number: u32 = 30;
    pub const XboxAccountId_field_number: u32 = 31;
    pub const MatchXboxUser_field_number: u32 = 32;
    pub const XboxSocialState_field_number: u32 = 33;
};
pub const EntitySimplyMoveInfo = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const Location_field_number: u32 = 2;
    pub const Rotation_field_number: u32 = 3;
};
pub const AchievementProgress = struct {
    pub const CurProgress_field_number: u32 = 1;
    pub const TotalProgress_field_number: u32 = 2;
};
pub const AchievementEntry = struct {
    pub const Id_field_number: u32 = 1;
    pub const FinishTime_field_number: u32 = 2;
    pub const IsReceive_field_number: u32 = 3;
    pub const Progress_field_number: u32 = 4;
};
pub const AchievementGroupEntry = struct {
    pub const Id_field_number: u32 = 1;
    pub const FinishTime_field_number: u32 = 2;
    pub const IsReceive_field_number: u32 = 3;
};
pub const AchievementGroupInfo = struct {
    pub const AchievementGroupEntry_field_number: u32 = 1;
    pub const AchievementEntryList_field_number: u32 = 2;
};
pub const AchievementInfoRequest = struct {
    pub const msg_id: u16 = 18849;
};
pub const AchievementInfoResponse = struct {
    pub const msg_id: u16 = 28221;
    pub const AchievementGroupInfoList_field_number: u32 = 5;
    pub const AchievementFinishedStar_field_number: u32 = 10;
    pub const FinishedAchievementNum_field_number: u32 = 13;
};
pub const UpdateAchievementInfoRequest = struct {
    pub const msg_id: u16 = 25344;
};
pub const UpdateAchievementInfoResponse = struct {
    pub const msg_id: u16 = 27285;
    pub const ErrorCode_field_number: u32 = 9;
    pub const AchievementEntryList_field_number: u32 = 8;
};
pub const LevelEventNotify = struct {
    pub const msg_id: u16 = 19151;
    pub const PlayerId_field_number: u32 = 3;
    pub const IncId_field_number: u32 = 8;
    pub const GameCtx_field_number: u32 = 1;
    pub const TotalCount_field_number: u32 = 5;
    pub const StartIndex_field_number: u32 = 7;
    pub const EndIndex_field_number: u32 = 10;
    pub const NeedFinishReq_field_number: u32 = 9;
};
pub const GameCtxPb = struct {
    CtxInfo: ?union(enum) {
    } = null,
    pub const BehaviorTree_field_number: u32 = 2;
    pub const Entity_field_number: u32 = 3;
    pub const NormalInteract_field_number: u32 = 4;
    pub const DynamicInteract_field_number: u32 = 5;
    pub const RandomInteract_field_number: u32 = 6;
    pub const StateChangeAction_field_number: u32 = 7;
    pub const EntityGroupAction_field_number: u32 = 8;
    pub const EntityTrigger_field_number: u32 = 9;
    pub const EntityLeaveTriggerCtx_field_number: u32 = 10;
    pub const EntityDestructible_field_number: u32 = 11;
    pub const EntityTimelineTrack_field_number: u32 = 12;
    pub const LevelPlayOpenAction_field_number: u32 = 13;
    pub const LevelPlayRewardAction_field_number: u32 = 14;
    pub const QuestActiveAction_field_number: u32 = 15;
    pub const QuestAcceptAction_field_number: u32 = 16;
    pub const QuestFinishAction_field_number: u32 = 17;
    pub const ChildQuestNodeEnterAction_field_number: u32 = 18;
    pub const ChildQuestNodeFinishAction_field_number: u32 = 19;
    pub const SuccessNodeAction_field_number: u32 = 20;
    pub const FailedNodeAction_field_number: u32 = 21;
    pub const CompositionEnterAction_field_number: u32 = 22;
    pub const EntityConditionListeningAction_field_number: u32 = 23;
    pub const PlayFlowChildQuestNode_field_number: u32 = 24;
    pub const HandInItemChildQuestNode_field_number: u32 = 25;
    pub const DoInteractChildQuestNode_field_number: u32 = 26;
    pub const ActionGroupNodeAction_field_number: u32 = 27;
    pub const ExploreSkillPullGiantAction_field_number: u32 = 28;
    pub const LevelPlay_field_number: u32 = 29;
    pub const GmLevelAction_field_number: u32 = 30;
    pub const LifeCycleCreateAction_field_number: u32 = 31;
    pub const LifeCycleDestroyAction_field_number: u32 = 32;
    pub const FlowAction_field_number: u32 = 33;
    pub const DailyQuestTerminateAction_field_number: u32 = 34;
    pub const EntityBeamReceiveAction_field_number: u32 = 35;
    pub const EntityGroupFailureAction_field_number: u32 = 36;
    pub const EntityStateChangeConditionAction_field_number: u32 = 37;
    pub const FlowStartTeleport_field_number: u32 = 38;
    pub const LeaveInstEscActionCtx_field_number: u32 = 39;
    pub const TrampleActiveAction_field_number: u32 = 40;
    pub const TrampleDeActiveAction_field_number: u32 = 41;
    pub const RenjuCompleteAction_field_number: u32 = 42;
    pub const JigsawFoundationMatchedAction_field_number: u32 = 43;
    pub const JigsawFoundationUnMatchedAction_field_number: u32 = 44;
    pub const HookLockPointAction_field_number: u32 = 45;
    pub const ClientTriggerAction_field_number: u32 = 46;
    pub const ExploreSkillCustomAction_field_number: u32 = 47;
    pub const JigsawFoundationMatchedConditionAction_field_number: u32 = 48;
    pub const LevelPlayDestroyAction_field_number: u32 = 49;
    pub const TemplateSpawnerAction_field_number: u32 = 50;
    pub const QuestDestroyAction_field_number: u32 = 51;
    pub const CompositionConditionEnterAction_field_number: u32 = 52;
    pub const TargetGearHitPartAction_field_number: u32 = 53;
    pub const GlobalFix_field_number: u32 = 54;
    pub const StuckCheckAction_field_number: u32 = 55;
    pub const AfterConditionAction_field_number: u32 = 56;
    pub const MotorSlider_field_number: u32 = 58;
    pub const RollBlockGamePlayAction_field_number: u32 = 59;
    pub const Transfer_field_number: u32 = 60;
    pub const DynamicEntityReward_field_number: u32 = 61;
    pub const BeamCastHitPlayerActionCtxPb_field_number: u32 = 62;
    pub const ExploreSkillAction_field_number: u32 = 63;
    pub const PollutionRangeAction_field_number: u32 = 64;
    pub const EntityQuickHackSkillAction_field_number: u32 = 65;
    pub const RecallQuestActiveAction_field_number: u32 = 66;
    pub const RecallQuestAcceptAction_field_number: u32 = 67;
    pub const RecallQuestFinishAction_field_number: u32 = 68;
    pub const RecallQuestDestroyAction_field_number: u32 = 69;
    pub const EdDebugEnterAction_field_number: u32 = 3401;
    pub const CtxType_field_number: u32 = 1;
};
pub const EntityCtxPb = struct {
    pub const ConfigId_field_number: u32 = 1;
    pub const IncId_field_number: u32 = 2;
};
pub const NormalInteractCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const OptionIndex_field_number: u32 = 2;
};
pub const DynamicInteractCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const OptionGuid_field_number: u32 = 2;
    pub const finalOptionCtx_field_number: u32 = 3;
};
pub const MotorSliderCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const IsEnter_field_number: u32 = 2;
};
pub const RandomInteractCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const OptionIndex_field_number: u32 = 2;
};
pub const StateChangeActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const StateIndex_field_number: u32 = 2;
};
pub const SceneItemStateChangeConditionAction = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const StateIndex_field_number: u32 = 2;
    pub const ConditionIndex_field_number: u32 = 3;
};
pub const EntityGroupActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const TriggerIndex_field_number: u32 = 2;
    pub const IsMatch_field_number: u32 = 3;
};
pub const EntityGroupFailureCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const EntityTriggerCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const TriggerEntityIncId_field_number: u32 = 2;
};
pub const ClientTriggerActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const IsEnter_field_number: u32 = 2;
};
pub const EntityLeaveTriggerCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const TriggerEntityIncId_field_number: u32 = 2;
};
pub const EntityDestructibleCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const EntityTimelineTrackCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const GroupIndex_field_number: u32 = 2;
    pub const ControlPoint_field_number: u32 = 3;
    pub const EventType_field_number: u32 = 4;
};
pub const EntityConditionListeningActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const EntityConditionListeningIndex_field_number: u32 = 2;
};
pub const EntityAfterConditionActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const PreCondtionListeningIndex_field_number: u32 = 2;
    pub const AfterCondtionListeningIndex_field_number: u32 = 3;
};
pub const BeamCastHitPlayerActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const ExploreSkillPullGiantCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const ExploreSkillCustomCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const GmLevelActionCtxPb = struct {
    pub const JsonStr_field_number: u32 = 1;
};
pub const SceneItemLifeCycleComponentCreateCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const SceneItemLifeCycleComponentDestroyCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const TrampleActivateCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const TrampleDeActiveCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const RenjuCompleteActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const Controller_field_number: u32 = 2;
};
pub const JigsawFoundationMatchedActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const MatchedIndex_field_number: u32 = 2;
};
pub const JigsawFoundationUnMatchedActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const MatchedIndex_field_number: u32 = 2;
};
pub const JigsawFoundationMatchedConditionActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const MatchedIndex_field_number: u32 = 2;
    pub const ConditionIndex_field_number: u32 = 3;
};
pub const DynamicEntityRewardCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const ExploreSkillActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
};
pub const BehaviorTreeCtxPb = struct {
    pub const IncId_field_number: u32 = 1;
    pub const BtType_field_number: u32 = 2;
    pub const BtId_field_number: u32 = 3;
    pub const NodeId_field_number: u32 = 4;
};
pub const LevelPlayCtxPb = struct {
    pub const LevelPlayId_field_number: u32 = 1;
};
pub const LevelPlayOpenActionCtxPb = struct {
    pub const LevelPlayId_field_number: u32 = 1;
};
pub const LevelPlayDestroyActionCtxPb = struct {
    pub const LevelPlayId_field_number: u32 = 1;
};
pub const LevelPlayRewardActionCtxPb = struct {
    pub const LevelPlayId_field_number: u32 = 1;
};
pub const QuestActiveActionCtxPb = struct {
    pub const QuestId_field_number: u32 = 1;
};
pub const QuestAcceptActionCtxPb = struct {
    pub const QuestId_field_number: u32 = 1;
};
pub const QuestFinishActionCtxPb = struct {
    pub const QuestId_field_number: u32 = 1;
};
pub const DailyQuestTerminateActionCtxPb = struct {
    pub const QuestId_field_number: u32 = 1;
};
pub const QuestDestroyActionCtxPb = struct {
    pub const QuestId_field_number: u32 = 1;
};
pub const LeaveInstEscActionCtxPb = struct {
    pub const InstanceId_field_number: u32 = 1;
};
pub const ChildQuestNodeEnterActionCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const ChildQuestNodeFinishActionCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const SuccessNodeActionCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const FailedNodeActionCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const CompositionEnterActionCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const CompositionConditionEnterActionCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
    pub const ConditionIndex_field_number: u32 = 2;
};
pub const TargetGearHitPartCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const HitPartIndex_field_number: u32 = 2;
};
pub const PlayFlowChildQuestNodeCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const HandInItemChildQuestNodeCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const DoInteractChildQuestNodeCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const ActionGroupNodeActionCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const FlowActionCtxPb = struct {
    pub const FlowListName_field_number: u32 = 1;
    pub const FlowId_field_number: u32 = 2;
    pub const StateId_field_number: u32 = 3;
    pub const ActionId_field_number: u32 = 4;
};
pub const BeamReceiveAction = struct {
    pub const ReceiveType_field_number: u32 = 1;
    pub const EntityCtx_field_number: u32 = 2;
};
pub const PlayEnterOrExitPollutionRangeCtxPb = struct {
    pub const RangeType_field_number: u32 = 1;
    pub const EntityCtx_field_number: u32 = 2;
};
pub const FlowStartTeleportCtxPb = struct {
    pub const FlowListName_field_number: u32 = 1;
    pub const FlowId_field_number: u32 = 2;
    pub const StateId_field_number: u32 = 3;
};
pub const HookLockPointActionCtxPb = struct {
    pub const EntityCtx_field_number: u32 = 1;
    pub const InteractionType_field_number: u32 = 2;
};
pub const TemplateSpawnerActionCtxPb = struct {
    Type: ?union(enum) {
    } = null,
    pub const DestroyType_field_number: u32 = 2;
    pub const EntityCtx_field_number: u32 = 1;
};
pub const GlobalFixCtxPb = struct {
    pub const FixId_field_number: u32 = 1;
};
pub const StuckCheckCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
    pub const Index_field_number: u32 = 2;
};
pub const RollBlockGamePlayActionCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
    pub const ParamType_field_number: u32 = 2;
};
pub const TransferCtxPb = struct {
    pub const TeleportId_field_number: u32 = 1;
};
pub const EntityQuickHackSkillCtxPb = struct {
    pub const SkillId_field_number: u32 = 1;
    pub const EntityState_field_number: u32 = 2;
    pub const EntityCtx_field_number: u32 = 3;
};
pub const RecallQuestActiveActionCtxPb = struct {
    pub const RecallQuestId_field_number: u32 = 1;
};
pub const EdDebugEnterActionCtxPb = struct {
    pub const BehaviorTreeCtx_field_number: u32 = 1;
};
pub const RecallQuestAcceptActionCtxPb = struct {
    pub const RecallQuestId_field_number: u32 = 1;
};
pub const RecallQuestFinishActionCtxPb = struct {
    pub const RecallQuestId_field_number: u32 = 1;
};
pub const RecallQuestDestroyActionCtxPb = struct {
    pub const RecallQuestId_field_number: u32 = 1;
};
pub const TeleportUpdateNotify = struct {
    pub const msg_id: u16 = 20363;
    pub const Ids_field_number: u32 = 5;
};
pub const TeleportDataRequest = struct {
    pub const msg_id: u16 = 26838;
};
pub const TeleportDataResponse = struct {
    pub const msg_id: u16 = 16502;
    pub const ErrorCode_field_number: u32 = 3;
    pub const Ids_field_number: u32 = 2;
};
pub const TeleportTransferRequest = struct {
    pub const msg_id: u16 = 16026;
    pub const Id_field_number: u32 = 6;
};
pub const TeleportTransferResponse = struct {
    pub const msg_id: u16 = 20168;
    pub const ErrorCode_field_number: u32 = 3;
    pub const MapId_field_number: u32 = 14;
    pub const PosX_field_number: u32 = 6;
    pub const PosY_field_number: u32 = 11;
    pub const PosZ_field_number: u32 = 9;
    pub const Pitch_field_number: u32 = 12;
    pub const Yaw_field_number: u32 = 10;
    pub const Roll_field_number: u32 = 13;
};
pub const TeleportNotify = struct {
    pub const msg_id: u16 = 27302;
    v70: ?union(enum) {
    } = null,
    pub const TransferEffectId_field_number: u32 = 9;
    pub const MapId_field_number: u32 = 2;
    pub const Pos_field_number: u32 = 11;
    pub const Rot_field_number: u32 = 4;
    pub const Gravity_field_number: u32 = 12;
    pub const Reason_field_number: u32 = 5;
    pub const GameCtx_field_number: u32 = 13;
    pub const TransitionOption_field_number: u32 = 6;
    pub const DisableAutoFade_field_number: u32 = 1;
};
pub const TransitionOptionPb = struct {
    Option: ?union(enum) {
    } = null,
    pub const TransitionMp4_field_number: u32 = 2;
    pub const TransitionFlow_field_number: u32 = 3;
    pub const TransitionInSeamless_field_number: u32 = 4;
    pub const FadeInScreenShowTime_field_number: u32 = 5;
    pub const TransitionWithCharacterDisplay_field_number: u32 = 6;
    pub const TransitionWithCustomLoading_field_number: u32 = 7;
    pub const TransitionWithSpineLoadingPb_field_number: u32 = 8;
    pub const TransitionWithSpecialCustomLoadingPb_field_number: u32 = 9;
    pub const PlayFlowPb_field_number: u32 = 10;
    pub const TransitionType_field_number: u32 = 1;
};
pub const Mp4BackgroundColorPb = struct {
    pub const FadeIn_field_number: u32 = 1;
    pub const FadeOut_field_number: u32 = 2;
};
pub const TransitionMp4Pb = struct {
    ScreenColor: ?union(enum) {
    } = null,
    pub const AfterTeleportScreenColor_field_number: u32 = 5;
    pub const ResourePath_field_number: u32 = 1;
    pub const ReplayWhenReLogin_field_number: u32 = 2;
    pub const IsFadeInScreenAfterTeleport_field_number: u32 = 3;
    pub const Mp4BackgroundColor_field_number: u32 = 4;
};
pub const TransitionFlowPb = struct {
    pub const FlowListName_field_number: u32 = 1;
    pub const FlowId_field_number: u32 = 2;
    pub const StateId_field_number: u32 = 3;
};
pub const TransitionInSeamlessPb = struct {
    WeatherDaPath: ?union(enum) {
    } = null,
    EffectDaPath: ?union(enum) {
    } = null,
    Config: ?union(enum) {
    } = null,
    pub const TransitionWeatherDaPath_field_number: u32 = 8;
    pub const SceneEffectDaPath_field_number: u32 = 10;
    pub const SeamlessTeleportFinishConfig_field_number: u32 = 11;
    pub const EffectPath_field_number: u32 = 1;
    pub const LeastTime_field_number: u32 = 2;
    pub const EffectExpandTime_field_number: u32 = 3;
    pub const EffectCollapseTime_field_number: u32 = 4;
    pub const HasFloorParams_field_number: u32 = 5;
    pub const FloorParams_field_number: u32 = 6;
    pub const IsTeleportInPlace_field_number: u32 = 7;
    pub const KeepStates_field_number: u32 = 9;
};
pub const TransitionWithCharacterDisplayPb = struct {
    pub const StyllId_field_number: u32 = 1;
};
pub const TransitionWithCustomLoadingPb = struct {
    pub const ConfigId_field_number: u32 = 1;
};
pub const FloorParams = struct {
    pub const FloorMeshPath_field_number: u32 = 1;
    pub const FloorMaterialPath_field_number: u32 = 2;
    pub const PosX_field_number: u32 = 3;
    pub const PosY_field_number: u32 = 4;
    pub const FloorAppearTime_field_number: u32 = 5;
    pub const FloorDisappearTime_field_number: u32 = 6;
};
pub const SeamlessTeleportFinishConfigPb = struct {
    pub const IsnotStopScreenEffect_field_number: u32 = 1;
    pub const EffectExtraState_field_number: u32 = 2;
};
pub const TeleportFinishRequest = struct {
    pub const msg_id: u16 = 23486;
};
pub const TeleportFinishResponse = struct {
    pub const msg_id: u16 = 15237;
    pub const ErrorCode_field_number: u32 = 2;
};
pub const TransitionWithSpineLoadingPb = struct {
    BackgroundFadeInEffectPb: ?union(enum) {
    } = null,
    BackgroundFadeOutEffectPb: ?union(enum) {
    } = null,
    Time: ?union(enum) {
    } = null,
    CustomShowUiPb: ?union(enum) {
    } = null,
    AkEvent: ?union(enum) {
    } = null,
    pub const FadeBackgroundFadeInEffectPb_field_number: u32 = 2;
    pub const FadeBackgroundFadeOutEffectPb_field_number: u32 = 3;
    pub const KeepTime_field_number: u32 = 4;
    pub const ICustomShowUiPb_field_number: u32 = 5;
    pub const StartAkEvent_field_number: u32 = 6;
    pub const ICustomScreenTypeBasePb_field_number: u32 = 1;
};
pub const TransitionPlayFlowPb = struct {
    pub const ActionParamPb_field_number: u32 = 1;
    pub const FadeBackgroundFadeInEffectPb_field_number: u32 = 2;
    pub const FadeBackgroundFadeOutEffectPb_field_number: u32 = 3;
};
pub const TransitionPlayFlowActionParamPb = struct {
    pub const FlowListName_field_number: u32 = 1;
    pub const FlowId_field_number: u32 = 2;
    pub const StateId_field_number: u32 = 3;
    pub const FlowGuid_field_number: u32 = 4;
};
pub const TransitionWithSpecialCustomLoadingPb = struct {
    LoadingType: ?union(enum) {
    } = null,
    pub const HonamiStoryCustomLoadingPb_field_number: u32 = 1;
};
pub const HonamiStoryCustomLoadingPb = struct {
    pub const LoadingId_field_number: u32 = 1;
};
pub const ICustomScreenTypeBasePb = struct {
    ScreenPb: ?union(enum) {
    } = null,
    pub const ICustomScreenSpinePb_field_number: u32 = 1;
    pub const ICustomScreenBackgroundImagePb_field_number: u32 = 2;
    pub const ICustomScreenLoadingPb_field_number: u32 = 3;
};
pub const ICustomScreenSpinePb = struct {
    pub const SpineId_field_number: u32 = 1;
};
pub const ICustomScreenBackgroundImagePb = struct {
    pub const BgPath_field_number: u32 = 1;
};
pub const ICustomScreenLoadingPb = struct {
    LoadingType: ?union(enum) {
    } = null,
    pub const ICustomScreenLoadingCyberpunkPb_field_number: u32 = 1;
};
pub const ICustomScreenLoadingCyberpunkPb = struct {
};
pub const ICustomShowUiPb = struct {
    CustomScreenTextSettingPb: ?union(enum) {
    } = null,
    HideCircle: ?union(enum) {
    } = null,
    pub const ICustomScreenTextSettingPb_field_number: u32 = 1;
    pub const IsHideCircle_field_number: u32 = 2;
};
pub const ICustomScreenTextSettingPb = struct {
    ShowTextInfo: ?union(enum) {
    } = null,
    TextContent: ?union(enum) {
    } = null,
    EdTextContent: ?union(enum) {
    } = null,
    pub const IsShowTextInfo_field_number: u32 = 1;
    pub const TidTextContent_field_number: u32 = 2;
    pub const EdTidTextContent_field_number: u32 = 3;
};
pub const FadeBackgroundFadeInEffectPb = struct {
    FadeInEffectPb: ?union(enum) {
    } = null,
    pub const FadeBackgroundFadeInEffectBlackPb_field_number: u32 = 1;
    pub const FadeBackgroundFadeInEffectScreenPb_field_number: u32 = 2;
};
pub const FadeBackgroundFadeInEffectBlackPb = struct {
    FadeIn: ?union(enum) {
    } = null,
    FadeOut: ?union(enum) {
    } = null,
    pub const FadeInTime_field_number: u32 = 2;
    pub const FadeOutTime_field_number: u32 = 3;
    pub const FadeColor_field_number: u32 = 1;
};
pub const FadeBackgroundFadeInEffectScreenPb = struct {
    pub const ScreenEffect_field_number: u32 = 1;
};
pub const FadeBackgroundFadeOutEffectPb = struct {
    FadeOutEffectPb: ?union(enum) {
    } = null,
    pub const FadeBackgroundFadeOutEffectBlackPb_field_number: u32 = 1;
    pub const FadeBackgroundFadeOutEffectSceenPb_field_number: u32 = 2;
};
pub const FadeBackgroundFadeOutEffectBlackPb = struct {
    FadeIn: ?union(enum) {
    } = null,
    FadeOut: ?union(enum) {
    } = null,
    pub const FadeInTime_field_number: u32 = 2;
    pub const FadeOutTime_field_number: u32 = 3;
    pub const FadeColor_field_number: u32 = 1;
};
pub const FadeBackgroundFadeOutEffectSceenPb = struct {
    pub const ScreenEffect_field_number: u32 = 1;
};
pub const CircumFluenceTaskData = struct {
    pub const ActivityTasks_field_number: u32 = 1;
    pub const ClaimedReward_field_number: u32 = 2;
    pub const TaskScoreRewardId_field_number: u32 = 3;
    pub const NowOpen_field_number: u32 = 5;
    pub const EndTime_field_number: u32 = 6;
    pub const NextRefreshTime_field_number: u32 = 7;
};
pub const ParkourActivityChallenge = struct {
    pub const ChallengeId_field_number: u32 = 1;
    pub const BeginTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
};
pub const ParkourActivity = struct {
    pub const Challenges_field_number: u32 = 1;
};
pub const DoubleInstActivityReward = struct {
    pub const GetDoubleInstRwdCount_field_number: u32 = 1;
};
pub const GatherTaskDoneInfo = struct {
    pub const TaskId_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const GatherActivityInfo = struct {
    pub const GatherTaskDoneInfo_field_number: u32 = 1;
};
pub const SignActivity = struct {
    pub const SignStateList_field_number: u32 = 1;
    pub const RewardFree_field_number: u32 = 2;
};
pub const HarvestPointReward = struct {
    pub const Id_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const HarvestLevelReward = struct {
    pub const Id_field_number: u32 = 1;
    pub const StartTime_field_number: u32 = 2;
    pub const IsOpen_field_number: u32 = 3;
    pub const Points_field_number: u32 = 4;
    pub const Diff_field_number: u32 = 5;
    pub const State_field_number: u32 = 6;
};
pub const HarvestActivity = struct {
    pub const HarvestPointRewards_field_number: u32 = 1;
    pub const HarvestLevelRewards_field_number: u32 = 2;
};
pub const NewBieCourseActivity = struct {
    pub const HadTakeReward_field_number: u32 = 1;
};
pub const RoleTrialTask = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const ChallengeState_field_number: u32 = 2;
    pub const BeginOpenTime_field_number: u32 = 5;
    pub const EndOpenTime_field_number: u32 = 6;
};
pub const RoleTrialInfoActivity = struct {
    pub const RoleTrialTask_field_number: u32 = 1;
};
pub const PhantomCollectReward = struct {
    Data: ?union(enum) {
    } = null,
    pub const Progress_field_number: u32 = 3;
    pub const Type_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const PhantomCollectProgress = struct {
    pub const Phantoms_field_number: u32 = 1;
};
pub const PhantomCollectActivity = struct {
    pub const PhantomCollectRewards_field_number: u32 = 1;
};
pub const ActivityRogueData = struct {
    pub const BeginOpenTime_field_number: u32 = 1;
    pub const EndOpenTime_field_number: u32 = 2;
    pub const RoguelikeSeason_field_number: u32 = 3;
};
pub const RoguelikeTokenList = struct {
    pub const Id_field_number: u32 = 1;
    pub const IsReceive_field_number: u32 = 2;
};
pub const RogueSeasonReward = struct {
    pub const Id_field_number: u32 = 1;
    pub const IsReceive_field_number: u32 = 2;
};
pub const RoguelikeSeason = struct {
    pub const SeasonId_field_number: u32 = 1;
    pub const StartTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
    pub const RoguelikeTokenList_field_number: u32 = 4;
    pub const SeasonRewardList_field_number: u32 = 5;
    pub const TokenItemCount_field_number: u32 = 6;
    pub const BlackFlowerUseCount_field_number: u32 = 7;
    pub const BlackFlowerMaxCount_field_number: u32 = 8;
    pub const TowerTrialBestClearCount_field_number: u32 = 10;
};
pub const ActivityRoleGiveData = struct {
    pub const IsGetReward_field_number: u32 = 1;
};
pub const ActivityCorniceMeetingData = struct {
    pub const UnlockTime_field_number: u32 = 1;
    pub const LevelEntryData_field_number: u32 = 2;
};
pub const AdvertisingPageData = struct {
    pub const Show_field_number: u32 = 1;
    pub const PointTime_field_number: u32 = 2;
};
pub const ActivityData = struct {
    Data: ?union(enum) {
    } = null,
    pub const ParkourActivity_field_number: u32 = 10;
    pub const SignActivity_field_number: u32 = 11;
    pub const NewBieCourseActivity_field_number: u32 = 12;
    pub const DoubleInstActivityReward_field_number: u32 = 13;
    pub const HarvestActivity_field_number: u32 = 14;
    pub const RoleTrialInfoActivity_field_number: u32 = 15;
    pub const PhantomCollectActivity_field_number: u32 = 16;
    pub const GatherActivityInfo_field_number: u32 = 17;
    pub const DailyAdventureActivityData_field_number: u32 = 18;
    pub const ActivityRogueData_field_number: u32 = 19;
    pub const ActivityLongShanMain_field_number: u32 = 20;
    pub const ActivityTurnTableData_field_number: u32 = 21;
    pub const BossRushActivityData_field_number: u32 = 22;
    pub const TrackMoonActivityTaskData_field_number: u32 = 23;
    pub const ActivityTimePointRewarData_field_number: u32 = 24;
    pub const TowerDefenseActivityInfo_field_number: u32 = 25;
    pub const CircumFluenceTaskData_field_number: u32 = 26;
    pub const ActivityRoleGiveData_field_number: u32 = 27;
    pub const ActivityCorniceMeetingData_field_number: u32 = 28;
    pub const RiskHarvestActivityData_field_number: u32 = 29;
    pub const ActivityBlackCoastData_field_number: u32 = 31;
    pub const DreamLinkActivityData_field_number: u32 = 32;
    pub const ActivityScratchTicketData_field_number: u32 = 34;
    pub const PreheatSignActivityData_field_number: u32 = 35;
    pub const MowTowerActivityData_field_number: u32 = 36;
    pub const FarmGoldData_field_number: u32 = 37;
    pub const SpringSignData_field_number: u32 = 38;
    pub const MapTravelActivityData_field_number: u32 = 39;
    pub const RoleSkinTrialActivity_field_number: u32 = 40;
    pub const ActivityFishingData_field_number: u32 = 41;
    pub const ActivityWeeklyRogueData_field_number: u32 = 43;
    pub const SolarisSpeedActivity_field_number: u32 = 44;
    pub const BabelTowerActivity_field_number: u32 = 45;
    pub const ActivityBetHorsesData_field_number: u32 = 46;
    pub const ActivityMapExploreData_field_number: u32 = 47;
    pub const ActivityPermanentRogueData_field_number: u32 = 48;
    pub const ActivityAvignon_field_number: u32 = 49;
    pub const DangoAbyssActivityData_field_number: u32 = 50;
    pub const ActivityInviteNewbie_field_number: u32 = 51;
    pub const ActivityDangoMonopolyData_field_number: u32 = 52;
    pub const ActivityCiacconaGalData_field_number: u32 = 53;
    pub const ActivityLinkageData_field_number: u32 = 54;
    pub const ActivityRegressData_field_number: u32 = 55;
    pub const CumulativeShopData_field_number: u32 = 56;
    pub const PhantomArenaActivityData_field_number: u32 = 57;
    pub const BeginnerCarnivalData_field_number: u32 = 58;
    pub const ActivityMoraleData_field_number: u32 = 59;
    pub const FloroRanchActivityData_field_number: u32 = 60;
    pub const LifePointDrawActivityData_field_number: u32 = 61;
    pub const ActivityTrapDefenseData_field_number: u32 = 62;
    pub const ActivityFunPlayData_field_number: u32 = 63;
    pub const ActivitySoarData_field_number: u32 = 64;
    pub const ActivityLineCrossData_field_number: u32 = 65;
    pub const ActivityMoonSignInData_field_number: u32 = 66;
    pub const HonamiStoryActivityData_field_number: u32 = 71;
    pub const FightPhotoActivityData_field_number: u32 = 72;
    pub const SurvivorsActivityData_field_number: u32 = 73;
    pub const ActivityPrizeDrawingData_field_number: u32 = 74;
    pub const AdvertisingPageData_field_number: u32 = 75;
    pub const AdvertisingPageInfo_field_number: u32 = 76;
    pub const RoleCoopActivityData_field_number: u32 = 77;
    pub const MotorCycleIpActivityData_field_number: u32 = 78;
    pub const PhantomBattleRecordActivityInfo_field_number: u32 = 79;
    pub const InfrThemeActivityPb_field_number: u32 = 80;
    pub const RoadBookActivityInfo_field_number: u32 = 81;
    pub const PhantomBattleGuideActivity_field_number: u32 = 82;
    pub const NewTowerClimbingActivityData_field_number: u32 = 83;
    pub const NewPlayerSupportActivityData_field_number: u32 = 84;
    pub const MotorParkourActivityInfo_field_number: u32 = 85;
    pub const SpringFestivalActivityInfo_field_number: u32 = 86;
    pub const TotalTopUpActivityInfo_field_number: u32 = 87;
    pub const MotorFightActivityPb_field_number: u32 = 88;
    pub const H5ViewActivityData_field_number: u32 = 89;
    pub const SkinRewardActivityData_field_number: u32 = 90;
    pub const EncircleActivityPb_field_number: u32 = 91;
    pub const MotorDevelopActivityData_field_number: u32 = 92;
    pub const FlagChallengeActivityInfo_field_number: u32 = 93;
    pub const FeiXuePreheatActivityInfo_field_number: u32 = 94;
    pub const RhythmActivityPb_field_number: u32 = 95;
    pub const DropCatchActivityInfo_field_number: u32 = 96;
    pub const TetrisActivityInfo_field_number: u32 = 97;
    pub const PinballActivityData_field_number: u32 = 98;
    pub const BossPilingActivityInfo_field_number: u32 = 99;
    pub const ThemeCelebration_field_number: u32 = 100;
    pub const WuWuWeekActivity_field_number: u32 = 101;
    pub const MotorDecalActivityData_field_number: u32 = 102;
    pub const LinkageCheckInActivityData_field_number: u32 = 103;
    pub const RoleGiftActivityData_field_number: u32 = 104;
    pub const KurotatoActivityData_field_number: u32 = 105;
    pub const GolemCrackActivityInfo_field_number: u32 = 106;
    pub const EdgeRunnerActivityInfo_field_number: u32 = 107;
    pub const OnlineMotorActivityData_field_number: u32 = 108;
    pub const RealmBetweenActivityInfo_field_number: u32 = 109;
    pub const ThroughTrainSummaryActivityData_field_number: u32 = 110;
    pub const NewbieMainActivityPb_field_number: u32 = 111;
    pub const NewbieCourseV2ActivityPb_field_number: u32 = 112;
    pub const NewbieAdventureV2Pb_field_number: u32 = 113;
    pub const NewPlayerSupportActivityV2Pb_field_number: u32 = 114;
    pub const ThroughTrainActivityData_field_number: u32 = 115;
    pub const RoverRogueActivityData_field_number: u32 = 116;
    pub const QingXiaoActivityInfo_field_number: u32 = 117;
    pub const Id_field_number: u32 = 1;
    pub const Type_field_number: u32 = 2;
    pub const BeginShowTime_field_number: u32 = 3;
    pub const EndShowTime_field_number: u32 = 4;
    pub const BeginOpenTime_field_number: u32 = 5;
    pub const EndOpenTime_field_number: u32 = 6;
    pub const IsUnlock_field_number: u32 = 7;
    pub const CompletePreQuests_field_number: u32 = 8;
    pub const IsFirstOpen_field_number: u32 = 9;
    pub const FinishConditions_field_number: u32 = 30;
    pub const ActivityOpenType_field_number: u32 = 33;
    pub const IsPreOpen_field_number: u32 = 42;
    pub const StartTime_field_number: u32 = 67;
    pub const EndTime_field_number: u32 = 68;
    pub const BeginRewardTimeInternal_field_number: u32 = 69;
    pub const EndRewardTimeInternal_field_number: u32 = 70;
};
pub const ActivityRequest = struct {
    pub const msg_id: u16 = 28374;
};
pub const ActivityResponse = struct {
    pub const msg_id: u16 = 17580;
    pub const Activities_field_number: u32 = 7;
    pub const ErrorCode_field_number: u32 = 14;
};
pub const ActivityTurnTableData = struct {
    pub const IsAllFinish_field_number: u32 = 1;
    pub const GroupId_field_number: u32 = 2;
    pub const Rewards_field_number: u32 = 3;
    pub const TurntableTasks_field_number: u32 = 4;
};
pub const ActivityCorniceMeetingLevelEntryData = struct {
    pub const MaxScore_field_number: u32 = 1;
    pub const RemainTime_field_number: u32 = 2;
    pub const UnlockTime_field_number: u32 = 3;
    pub const RewardedMap_field_number: u32 = 4;
};
pub const BlackCoastThemeStageInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const Tasks_field_number: u32 = 2;
};
pub const ActivityBlackCoastData = struct {
    pub const StageData_field_number: u32 = 1;
    pub const RewardIds_field_number: u32 = 2;
};
pub const DreamLinkActivityData = struct {
    pub const MaxEnergy_field_number: u32 = 1;
    pub const SignStateList_field_number: u32 = 3;
    pub const RoleInstanceList_field_number: u32 = 5;
    pub const LevelPlayList_field_number: u32 = 6;
    pub const BossRewardIds_field_number: u32 = 7;
    pub const AllLimitTimeReward_field_number: u32 = 8;
    pub const ScoreMap_field_number: u32 = 9;
    pub const LimitTimeReward_field_number: u32 = 10;
    pub const LimitTimeEnd_field_number: u32 = 11;
    pub const RogueBossInstData_field_number: u32 = 12;
    pub const PlayTime_field_number: u32 = 13;
    pub const UnlockButtons_field_number: u32 = 14;
};
pub const AllLimitTimeReward = struct {
    pub const SignState_field_number: u32 = 1;
    pub const CurProgress_field_number: u32 = 2;
    pub const Target_field_number: u32 = 3;
    pub const ConfigId_field_number: u32 = 4;
};
pub const RoleInstanceList = struct {
    pub const InstId_field_number: u32 = 1;
    pub const IsUnlock_field_number: u32 = 2;
    pub const CanUnlock_field_number: u32 = 3;
};
pub const RogueBossInstData = struct {
    pub const InstId_field_number: u32 = 1;
    pub const IsUnlock_field_number: u32 = 2;
    pub const CanUnlock_field_number: u32 = 3;
    pub const UnlockTime_field_number: u32 = 4;
};
pub const LevelPlayList = struct {
    pub const Index_field_number: u32 = 1;
    pub const LevelPlayId_field_number: u32 = 2;
    pub const State_field_number: u32 = 3;
    pub const IsUnlock_field_number: u32 = 4;
    pub const UnlockTime_field_number: u32 = 5;
    pub const PlayTime_field_number: u32 = 6;
};
pub const ScratchTicketRoundData = struct {
    pub const RoundId_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
    pub const AreaStageRewardDataList_field_number: u32 = 3;
    pub const LeftRewardItem_field_number: u32 = 4;
};
pub const ScratchCardRewardData = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
};
pub const ScratchTicketConditionData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Progress_field_number: u32 = 2;
    pub const FinishedAchievementNum_field_number: u32 = 3;
};
pub const ActivityScratchTicketData = struct {
    pub const RoundData_field_number: u32 = 1;
    pub const ConditionData_field_number: u32 = 2;
};
pub const PreheatSignNodeInfo = struct {
    pub const PreheatNodeId_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
    pub const Rewarded_field_number: u32 = 3;
};
pub const PreheatSignActivityData = struct {
    pub const PreheatSignNodeInfos_field_number: u32 = 1;
};
pub const SpringSignData = struct {
    pub const SpringSignActivityTasks_field_number: u32 = 1;
    pub const CanInvite_field_number: u32 = 2;
    pub const DrawRoles_field_number: u32 = 3;
    pub const SkinReward_field_number: u32 = 4;
};
pub const MowTowerLevelsInfo = struct {
    pub const BabelTowerLevelId_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
    pub const IsUnlock_field_number: u32 = 3;
    pub const FirstScore_field_number: u32 = 4;
    pub const SecondScore_field_number: u32 = 9;
    pub const LevelRewardStatus_field_number: u32 = 5;
    pub const HardLevelBuffs_field_number: u32 = 6;
    pub const FirstRoleSelection_field_number: u32 = 7;
    pub const SecondRoleSelection_field_number: u32 = 8;
};
pub const MowTowerActivityData = struct {
    pub const MowTowerLevelsInfo_field_number: u32 = 1;
};
pub const ThroughTrainActivityData = struct {
    pub const IsFinish_field_number: u32 = 1;
};
pub const ThroughTrainSummaryActivityData = struct {
    pub const ActivityIds_field_number: u32 = 1;
    pub const CompletedActivityIds_field_number: u32 = 2;
};
pub const RoleSkinTrialContentData = struct {
    pub const Id_field_number: u32 = 1;
    pub const ChallengeState_field_number: u32 = 2;
};
pub const RoleSkinTrialActivity = struct {
    pub const RoleSkinTrialContentData_field_number: u32 = 1;
};
pub const ActivityWeeklyRogueData = struct {
    Data: ?union(enum) {
    } = null,
    pub const RogueWeeklyLastInfo_field_number: u32 = 3;
    pub const CycleId_field_number: u32 = 1;
    pub const Score_field_number: u32 = 2;
    pub const RogueWeeklyAward_field_number: u32 = 4;
    pub const MaxScore_field_number: u32 = 7;
    pub const CurWorldLevel_field_number: u32 = 8;
    pub const UseFreeCount_field_number: u32 = 9;
    pub const MaxFreeCount_field_number: u32 = 10;
};
pub const RogueWeeklyAward = struct {
    pub const SignState_field_number: u32 = 1;
    pub const CurProgress_field_number: u32 = 2;
    pub const MaxProgress_field_number: u32 = 3;
    pub const ConfigId_field_number: u32 = 4;
};
pub const RogueWeeklyLastInfo = struct {
    pub const InstId_field_number: u32 = 1;
    pub const CurLayer_field_number: u32 = 2;
    pub const MaxLayer_field_number: u32 = 3;
    pub const WorldLevel_field_number: u32 = 4;
};
pub const ActivityPermanentRogueData = struct {
    pub const PermanentSeasonData_field_number: u32 = 1;
    pub const RogueResTaskData_field_number: u32 = 2;
};
pub const PermanentSeasonData = struct {
    pub const PermanentSeasonDataId_field_number: u32 = 1;
    pub const SkillDict_field_number: u32 = 2;
    pub const RogueResEndId_field_number: u32 = 3;
    pub const RogueResEndAward_field_number: u32 = 4;
    pub const TrialRoleIds_field_number: u32 = 5;
    pub const RoleIds_field_number: u32 = 6;
    pub const EndTime_field_number: u32 = 7;
    pub const ShopItemCount_field_number: u32 = 8;
};
pub const RogueResTaskData = struct {
    pub const PermanentRogueData_field_number: u32 = 1;
    pub const RogueResCollectionState_field_number: u32 = 2;
};
pub const PermanentRogueData = struct {
    pub const msg_id: u16 = 17498;
    Data: ?union(enum) {
    } = null,
    pub const RogueResTaskThemeData_field_number: u32 = 10;
};
pub const RogueResTaskThemeData = struct {
    pub const RogueSignReward_field_number: u32 = 1;
    pub const RogueResThemeId_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
};
pub const ActivityFishingData = struct {
    pub const ActivityTaskData_field_number: u32 = 1;
    pub const MilestoneReward_field_number: u32 = 2;
    pub const LimitTimeReward_field_number: u32 = 3;
    pub const LimitTimeEnd_field_number: u32 = 4;
    pub const MilestoneRewardItemAccumulate_field_number: u32 = 5;
};
pub const BabelTowerData = struct {
    pub const BabelTowerLevelId_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
    pub const NormalLevelBuffs_field_number: u32 = 3;
    pub const RoleIds_field_number: u32 = 4;
    pub const HardLevelBuffs_field_number: u32 = 5;
    pub const HardLevelItems_field_number: u32 = 6;
    pub const HardLevelStar_field_number: u32 = 7;
    pub const HasPassed_field_number: u32 = 8;
    pub const MaxPassRoleSelection_field_number: u32 = 9;
    pub const MaxPassBuffSelection_field_number: u32 = 10;
    pub const MaxPassStar_field_number: u32 = 11;
    pub const SkillBranchId_field_number: u32 = 12;
    pub const MaxPassUseTime_field_number: u32 = 13;
};
pub const BabelDebuff = struct {
    pub const BuffId_field_number: u32 = 1;
    pub const Unlocked_field_number: u32 = 2;
};
pub const BabelBuff = struct {
    pub const BuffId_field_number: u32 = 1;
    pub const Unlocked_field_number: u32 = 2;
};
pub const BabelTowerActivity = struct {
    pub const BabelTowerDataList_field_number: u32 = 1;
    pub const BabelDebuffUnlocks_field_number: u32 = 2;
    pub const BabelBuffUnlocks_field_number: u32 = 3;
    pub const NormalQuest_field_number: u32 = 4;
    pub const DailyQuest_field_number: u32 = 5;
    pub const CurrentItemCount_field_number: u32 = 6;
    pub const ShowName_field_number: u32 = 7;
};
pub const ActivityMapExploreData = struct {
    pub const ActivityTasks_field_number: u32 = 1;
};
pub const ActivityInviteNewbie = struct {
    pub const InviteCode_field_number: u32 = 1;
    pub const Score_field_number: u32 = 2;
    pub const RedDot_field_number: u32 = 3;
};
pub const ActivityDangoMonopolyData = struct {
    pub const CurrentBoardId_field_number: u32 = 1;
    pub const CurrentGridId_field_number: u32 = 2;
    pub const RewardGridId_field_number: u32 = 3;
    pub const BoardRewards_field_number: u32 = 4;
    pub const DangoTaskConfig_field_number: u32 = 5;
    pub const TaskEndTimeMap_field_number: u32 = 6;
    pub const UnlockTime_field_number: u32 = 7;
    pub const BoardMap_field_number: u32 = 8;
};
pub const DangoMonopolyBoardData = struct {
    pub const PropertyIds_field_number: u32 = 1;
    pub const RecordDiceRollTimes_field_number: u32 = 2;
    pub const RecordTriggerMap_field_number: u32 = 3;
};
pub const DangoMonopolyConfig = struct {
    pub const TaskId_field_number: u32 = 1;
    pub const ActivityTaskState_field_number: u32 = 2;
    pub const Progress_field_number: u32 = 3;
    pub const TargetProgress_field_number: u32 = 4;
};
pub const ActivityCiacconaGalData = struct {
    pub const ChapterData_field_number: u32 = 1;
    pub const ProgressRewardData_field_number: u32 = 2;
    pub const EndingData_field_number: u32 = 3;
    pub const CiacconaGalInspirationData_field_number: u32 = 4;
    pub const State2Unlock_field_number: u32 = 5;
    pub const State3Unlock_field_number: u32 = 6;
    pub const RewardStartTime_field_number: u32 = 7;
    pub const RewardEndTime_field_number: u32 = 8;
};
pub const CiacconaGalChapterData = struct {
    pub const ChapterDataId_field_number: u32 = 1;
    pub const CanUnlock_field_number: u32 = 2;
    pub const CiacconaGalSubEndingData_field_number: u32 = 3;
    pub const CiacconaGalChoiceData_field_number: u32 = 4;
};
pub const CiacconaGalChoiceData = struct {
    pub const ChoiceDataId_field_number: u32 = 1;
    pub const SecondState_field_number: u32 = 2;
    pub const FirstState_field_number: u32 = 3;
};
pub const CiacconaGalSubEndingData = struct {
    pub const SubEndingDataId_field_number: u32 = 1;
    pub const IsFinished_field_number: u32 = 2;
    pub const IsRewarded_field_number: u32 = 3;
};
pub const CiacconaGalRewardData = struct {
    pub const RewardDataId_field_number: u32 = 1;
    pub const CanReceive_field_number: u32 = 2;
    pub const IsRewarded_field_number: u32 = 3;
};
pub const CiacconaGalInspirationData = struct {
    pub const InspirationCount_field_number: u32 = 1;
    pub const RefreshTime_field_number: u32 = 2;
};
pub const CiacconaGalEndingData = struct {
    pub const SubEndingDataId_field_number: u32 = 1;
    pub const IsRewarded_field_number: u32 = 2;
};
pub const PhantomArenaActivityData = struct {
    pub const PhantomArenaChallengeInfoList_field_number: u32 = 1;
    pub const ActivityTasks_field_number: u32 = 2;
    pub const PhantomArenaMasterInfo_field_number: u32 = 3;
    pub const BadgeInfo_field_number: u32 = 4;
    pub const BadgeReward_field_number: u32 = 5;
    pub const CardList_field_number: u32 = 6;
    pub const CardReward_field_number: u32 = 7;
    pub const RoleInfo_field_number: u32 = 8;
    pub const DeckInfo_field_number: u32 = 9;
    pub const TimeLimitShopEndTime_field_number: u32 = 10;
};
pub const PhantomArenaChallengeInfo = struct {
    pub const ChallengeInfoId_field_number: u32 = 1;
    pub const IsUnlock_field_number: u32 = 2;
    pub const CanReChallenge_field_number: u32 = 3;
    pub const LastCardRoleId_field_number: u32 = 4;
    pub const LastCardGroupIndex_field_number: u32 = 5;
    pub const FinishConditions_field_number: u32 = 6;
    pub const IsUncover_field_number: u32 = 7;
    pub const IsShow_field_number: u32 = 8;
};
pub const PhantomArenaMasterInfo = struct {
    pub const MasterLevel_field_number: u32 = 1;
    pub const MasterExp_field_number: u32 = 2;
    pub const RewardTaken_field_number: u32 = 3;
    pub const MasterWeeklyExp_field_number: u32 = 4;
    pub const LastUsedDeckServerId_field_number: u32 = 5;
    pub const LastUsedCardRoleId_field_number: u32 = 6;
};
pub const PhantomArenaBadge = struct {
    pub const BadgeId_field_number: u32 = 1;
    pub const IsUnlock_field_number: u32 = 2;
};
pub const PhantomArenaBadgeReward = struct {
    pub const BadgeRewardId_field_number: u32 = 1;
    pub const NeedCount_field_number: u32 = 2;
    pub const IsTaken_field_number: u32 = 3;
};
pub const PhantomArenaCardInfo = struct {
    pub const CardId_field_number: u32 = 1;
    pub const IsUnlock_field_number: u32 = 2;
    pub const IsCardOutlookUnlock_field_number: u32 = 3;
};
pub const PhantomArenaCardReward = struct {
    pub const CardId_field_number: u32 = 1;
    pub const NeedCount_field_number: u32 = 2;
    pub const IsTaken_field_number: u32 = 3;
};
pub const PhantomArenaRoleInfo = struct {
    pub const RoleInfoId_field_number: u32 = 1;
    pub const IsUnlock_field_number: u32 = 2;
    pub const IsTaken_field_number: u32 = 3;
};
pub const PhantomArenaDeckInfo = struct {
    pub const Name_field_number: u32 = 1;
    pub const BattleCardIds_field_number: u32 = 2;
    pub const CanUse_field_number: u32 = 3;
    pub const LastUseChallengeId_field_number: u32 = 4;
    pub const Index_field_number: u32 = 5;
    pub const SkillUnlockInfos_field_number: u32 = 6;
};
pub const PhantomBattleGuideActivity = struct {
    pub const QuestId_field_number: u32 = 1;
    pub const DropId_field_number: u32 = 2;
    pub const RewardTotalNum_field_number: u32 = 3;
    pub const SendReward_field_number: u32 = 4;
    pub const RecordActId_field_number: u32 = 5;
};
pub const BeginnerCarnivalData = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const ActivityTaskData_field_number: u32 = 2;
    pub const JumpTaskIds_field_number: u32 = 3;
    pub const JumpTaskCondInfos_field_number: u32 = 4;
};
pub const JumpTaskCondInfo = struct {
    pub const JumpId_field_number: u32 = 1;
    pub const ConditionGroupIds_field_number: u32 = 2;
};
pub const ActivityFunPlayChallengeData = struct {
    pub const ChallengeId_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
    pub const RewardStatus_field_number: u32 = 3;
    pub const FunPlaySharpComment_field_number: u32 = 4;
    pub const FinishTime_field_number: u32 = 5;
};
pub const ActivityFunPlayData = struct {
    pub const ActivityFunPlayChallengeData_field_number: u32 = 1;
};
pub const ActivitySoarData = struct {
    pub const QuestId_field_number: u32 = 1;
};
pub const InitHonamiActivityRequest = struct {
    pub const msg_id: u16 = 20902;
    pub const ActivityId_field_number: u32 = 12;
};
pub const InitHonamiActivityResponse = struct {
    pub const msg_id: u16 = 25258;
    pub const ErrorCode_field_number: u32 = 7;
    pub const HonamiStoryActivityData_field_number: u32 = 2;
};
pub const HonamiStoryActivityData = struct {
    pub const PlayerBagInfo_field_number: u32 = 1;
    pub const ActivatedTalentId_field_number: u32 = 2;
    pub const ItemCollectionList_field_number: u32 = 3;
    pub const MascotConfigList_field_number: u32 = 4;
    pub const AreaConfigList_field_number: u32 = 5;
    pub const PermanentTaskData_field_number: u32 = 6;
    pub const LimitTaskData_field_number: u32 = 7;
    pub const ScoreRewardInfo_field_number: u32 = 8;
    pub const LifeSupportLevel_field_number: u32 = 10;
    pub const LimitShopConsumeItemNum_field_number: u32 = 11;
    pub const PbTowerInfos_field_number: u32 = 12;
    pub const TalentInfos_field_number: u32 = 13;
    pub const ItemCollectionInfos_field_number: u32 = 14;
    pub const TotalRevenue_field_number: u32 = 15;
};
pub const InfrThemeActivityPb = struct {
    pub const ActivityTaskData_field_number: u32 = 2;
};
pub const FlagChallengeActivityInfo = struct {
    pub const ConditionTasks_field_number: u32 = 1;
    pub const FlagChallengeLevelInfos_field_number: u32 = 2;
    pub const FlagStrongholdInfos_field_number: u32 = 3;
    pub const FlagChallengeRoleLevelInfo_field_number: u32 = 4;
    pub const UnlockTeleporterId_field_number: u32 = 5;
};
pub const BossPilingActivityInfo = struct {
    pub const ConditionTasks_field_number: u32 = 1;
    pub const BossPilingLevelInfos_field_number: u32 = 2;
};
pub const DailyAdventureActivityTask = struct {
    pub const Id_field_number: u32 = 1;
    pub const Current_field_number: u32 = 2;
    pub const Target_field_number: u32 = 3;
    pub const Status_field_number: u32 = 4;
};
pub const DailyAdventureActivityData = struct {
    pub const DailyAdventureActivityTasks_field_number: u32 = 1;
    pub const PtRewardTaken_field_number: u32 = 2;
};
pub const LongShanMainData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Tasks_field_number: u32 = 2;
    pub const CanUnlock_field_number: u32 = 3;
    pub const BeginOpenTime_field_number: u32 = 4;
    pub const EndOpenTime_field_number: u32 = 5;
};
pub const LongShanMainTaskData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Current_field_number: u32 = 2;
    pub const Target_field_number: u32 = 3;
    pub const IsFinished_field_number: u32 = 4;
    pub const IsTaken_field_number: u32 = 5;
    pub const Unlock_field_number: u32 = 6;
    pub const FinishConditions_field_number: u32 = 7;
    pub const ConditionId_field_number: u32 = 8;
    pub const ConditionGroupId_field_number: u32 = 9;
    pub const UnlockConditionFinish_field_number: u32 = 10;
};
pub const ActivityLongShanMain = struct {
    pub const StageData_field_number: u32 = 1;
    pub const ScoreRewardedId_field_number: u32 = 2;
};
pub const BossRushActivityData = struct {
    pub const LevelDetailInfo_field_number: u32 = 1;
    pub const RewardInfo_field_number: u32 = 2;
    pub const UnlockedBuffIndices_field_number: u32 = 3;
    pub const TaskProgressReward_field_number: u32 = 4;
};
pub const LevelInfo = struct {
    pub const InstId_field_number: u32 = 1;
    pub const StartTime_field_number: u32 = 2;
    pub const IsOpen_field_number: u32 = 3;
    pub const Score_field_number: u32 = 4;
    pub const RoleInfo_field_number: u32 = 5;
    pub const BuffInfo_field_number: u32 = 6;
    pub const LevelRewardClaimStatus_field_number: u32 = 7;
    pub const SelectScoreBuffs_field_number: u32 = 8;
    pub const LevelScoreRewardStatus_field_number: u32 = 9;
};
pub const BossRushScoreRewardData = struct {
    pub const RewardDataId_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const HardLevelBuffs = struct {
    pub const BuffId_field_number: u32 = 1;
    pub const Slot_field_number: u32 = 2;
    pub const State_field_number: u32 = 3;
};
pub const ActivityTask = struct {
    pub const Id_field_number: u32 = 1;
    pub const Current_field_number: u32 = 2;
    pub const Target_field_number: u32 = 3;
    pub const Status_field_number: u32 = 4;
    pub const PreItemMap_field_number: u32 = 5;
};
pub const ActivityTaskData = struct {
    pub const ActivityTasks_field_number: u32 = 1;
};
pub const ConditionTask = struct {
    pub const Id_field_number: u32 = 1;
    pub const Current_field_number: u32 = 2;
    pub const Target_field_number: u32 = 3;
    pub const Status_field_number: u32 = 4;
};
pub const ActivityTimePointRewarData = struct {
    pub const Rewards_field_number: u32 = 1;
};
pub const TimePointRewardData = struct {
    pub const Id_field_number: u32 = 1;
    pub const RewardTime_field_number: u32 = 2;
    pub const Rewarded_field_number: u32 = 3;
    pub const CanGetReward_field_number: u32 = 4;
};
pub const TowerDefenseActivityInfo = struct {
    pub const InstanceInfos_field_number: u32 = 1;
    pub const RewardedScoreIds_field_number: u32 = 2;
    pub const TotalScore_field_number: u32 = 3;
    pub const ShowName_field_number: u32 = 4;
};
pub const TowerDefenceInstanceInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const Score_field_number: u32 = 2;
    pub const Rewarded_field_number: u32 = 3;
    pub const IsPassed_field_number: u32 = 4;
    pub const UnlockTime_field_number: u32 = 5;
    pub const MaxScore_field_number: u32 = 6;
    pub const PassTime_field_number: u32 = 7;
};
pub const RiskHarvestStarRewardInfo = struct {
    pub const TargetScore_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const RiskHarvestInstInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
    pub const IsUnlock_field_number: u32 = 3;
    pub const Score_field_number: u32 = 4;
    pub const Rewarded_field_number: u32 = 5;
    pub const IsFinished_field_number: u32 = 6;
    pub const StarRewardInfos_field_number: u32 = 7;
};
pub const RiskHarvestActivityData = struct {
    pub const InstInfos_field_number: u32 = 1;
    pub const RewardedScores_field_number: u32 = 2;
    pub const RewardedBuffGroups_field_number: u32 = 3;
    pub const UnlockBuffGroups_field_number: u32 = 4;
    pub const RewardedBuffTypeIds_field_number: u32 = 5;
};
pub const FarmGoldLevelPlayInfo = struct {
    pub const InstId_field_number: u32 = 1;
    pub const StartTime_field_number: u32 = 2;
    pub const Challenges_field_number: u32 = 3;
    pub const Points_field_number: u32 = 4;
    pub const LevelRewardGet_field_number: u32 = 5;
    pub const Difficulty_field_number: u32 = 6;
};
pub const FarmGoldData = struct {
    pub const PointRewardGet_field_number: u32 = 1;
    pub const LevelPlayTasks_field_number: u32 = 2;
};
pub const MapTravelActivityData = struct {
    pub const ActivityTasks_field_number: u32 = 1;
    pub const MonsterGain_field_number: u32 = 2;
    pub const GetFullReward_field_number: u32 = 3;
    pub const MapTravelLevel_field_number: u32 = 4;
    pub const UnlockAreas_field_number: u32 = 5;
    pub const SoarLevels_field_number: u32 = 6;
};
pub const SoarLevelPlayInfo = struct {
    pub const SoarLevelPlatId_field_number: u32 = 1;
    pub const HistorySoarScore_field_number: u32 = 2;
    pub const ReceiveIds_field_number: u32 = 3;
};
pub const SolarSpeedContext = struct {
    pub const LevelId_field_number: u32 = 1;
    pub const Score_field_number: u32 = 2;
    pub const Ranking_field_number: u32 = 3;
    pub const StartTime_field_number: u32 = 4;
    pub const LapRecord_field_number: u32 = 5;
};
pub const SolarisSpeedActivity = struct {
    pub const SolarSpeedContext_field_number: u32 = 1;
    pub const ActivityTaskDatas_field_number: u32 = 2;
};
pub const RacingBetsLegMatchData = struct {
    pub const LegMatchesId_field_number: u32 = 1;
    pub const DangoId_field_number: u32 = 2;
    pub const BettingGearId_field_number: u32 = 3;
    pub const BettingGearCash_field_number: u32 = 4;
    pub const Odds_field_number: u32 = 5;
    pub const OddsVersion_field_number: u32 = 6;
    pub const LeaveCancelNum_field_number: u32 = 7;
    pub const OddsReward_field_number: u32 = 8;
};
pub const DangoActorData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Record_field_number: u32 = 2;
    pub const Odds_field_number: u32 = 3;
};
pub const RacingBetsOrganInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const Point_field_number: u32 = 2;
};
pub const RacingBetsTimeTuple = struct {
    pub const BeginTime_field_number: u32 = 1;
    pub const EndTime_field_number: u32 = 2;
};
pub const RacingBetsLegMatch = struct {
    pub const Id_field_number: u32 = 1;
    pub const DangoActorData_field_number: u32 = 2;
    pub const MatchStartEndTime_field_number: u32 = 3;
    pub const GearStartEndTime_field_number: u32 = 4;
    pub const BetDangoRank_field_number: u32 = 5;
    pub const OddsRateRefreshTime_field_number: u32 = 6;
    pub const OddsVersion_field_number: u32 = 7;
    pub const MasterLevel_field_number: u32 = 8;
    pub const OrganInfo_field_number: u32 = 9;
};
pub const RacingBetsGroupMatchInfo = struct {
    pub const MatchId_field_number: u32 = 1;
    pub const GroupMatchTime_field_number: u32 = 2;
    pub const LegMatch_field_number: u32 = 3;
    pub const PromoteDangoList_field_number: u32 = 4;
    pub const Dangos_field_number: u32 = 5;
};
pub const RacingBetsSeasonData = struct {
    pub const CurCash_field_number: u32 = 1;
    pub const TotalCash_field_number: u32 = 2;
    pub const RacingBetsLegMatchData_field_number: u32 = 3;
    pub const HitNum_field_number: u32 = 4;
};
pub const RacingBetsRewardData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Status_field_number: u32 = 2;
    pub const Progress_field_number: u32 = 3;
    pub const TargetProgress_field_number: u32 = 4;
    pub const ConditionFinishState_field_number: u32 = 6;
};
pub const ActivityBetHorsesData = struct {
    pub const ActivityId_field_number: u32 = 1;
    pub const StartAndEndTime_field_number: u32 = 2;
    pub const MatchInfo_field_number: u32 = 3;
    pub const RacingBetsSeasonData_field_number: u32 = 4;
    pub const BetsRewardData_field_number: u32 = 5;
    pub const LegMatchTimeList_field_number: u32 = 6;
    pub const CloseSettleMenuLegMatchList_field_number: u32 = 7;
};
pub const ActivityAvignon = struct {
    pub const RewardData_field_number: u32 = 1;
    pub const StageId_field_number: u32 = 2;
};
pub const ActivityLinkageRewardData = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
};
pub const ActivityLinkageTabData = struct {
    pub const TabDataId_field_number: u32 = 1;
    pub const EndTime_field_number: u32 = 2;
    pub const RewardData_field_number: u32 = 3;
    pub const IsReceive_field_number: u32 = 4;
    pub const StartTime_field_number: u32 = 5;
};
pub const ActivityLinkageData = struct {
    pub const ActivityId_field_number: u32 = 1;
    pub const Data_field_number: u32 = 2;
};
pub const QuestionaireRewardState = struct {
    pub const Id_field_number: u32 = 1;
    pub const Status_field_number: u32 = 2;
};
pub const ActivityRegressData = struct {
    pub const TaskProgressReward_field_number: u32 = 1;
    pub const ClaimedReward_field_number: u32 = 2;
    pub const TaskScoreRewardId_field_number: u32 = 3;
    pub const Grade_field_number: u32 = 4;
    pub const EndTime_field_number: u32 = 6;
    pub const RefreshTime_field_number: u32 = 7;
    pub const BossDoubleDropCount_field_number: u32 = 8;
    pub const WeekDoubleDropCount_field_number: u32 = 9;
    pub const Questionnaire_field_number: u32 = 10;
    pub const QuestionaireRewardState_field_number: u32 = 13;
    pub const BossDoubleDropUnlock_field_number: u32 = 11;
    pub const WeekDoubleDropUnlock_field_number: u32 = 12;
    pub const PayScoreRewards_field_number: u32 = 14;
    pub const DisposableReward_field_number: u32 = 15;
    pub const RoleInfo_field_number: u32 = 16;
    pub const PayRewardUnlock_field_number: u32 = 17;
    pub const CurUseTrialRoleId_field_number: u32 = 18;
    pub const CurUseRoleInfo_field_number: u32 = 19;
};
pub const NewPlayerSupportActivityData = struct {
    pub const TrialRoleInfoList_field_number: u32 = 1;
    pub const TaskDataList_field_number: u32 = 2;
    pub const CurUseTrialRoleId_field_number: u32 = 3;
    pub const CurUseRoleInfo_field_number: u32 = 4;
    pub const NewPlayerPoolFinalGachaRoleId_field_number: u32 = 5;
};
pub const NewTrialRoleInfo = struct {
    pub const TrialRoleId_field_number: u32 = 1;
    pub const WorldLv_field_number: u32 = 2;
};
pub const CumulativeShopTaskData = struct {
    pub const Current_field_number: u32 = 1;
    pub const TargetProgress_field_number: u32 = 2;
};
pub const CumulativeShopSubTaskData = struct {
    pub const CanGetReward_field_number: u32 = 1;
    pub const ProgressCount_field_number: u32 = 2;
    pub const TotalProgressCount_field_number: u32 = 3;
};
pub const CumulativeShopTaskConfig = struct {
    pub const Id_field_number: u32 = 1;
    pub const Type_field_number: u32 = 2;
    pub const CumulativeShopTaskData_field_number: u32 = 3;
    pub const CumulativeShopSubTaskData_field_number: u32 = 4;
};
pub const CumulativeShopData = struct {
    pub const ActivityId_field_number: u32 = 2;
    pub const TaskData_field_number: u32 = 3;
    pub const TotalScore_field_number: u32 = 4;
};
pub const MoraleFlag = struct {
    pub const FlagId_field_number: u32 = 1;
    pub const BoxReceivedCount_field_number: u32 = 2;
    pub const BoxTotalCount_field_number: u32 = 3;
};
pub const MoraleAreaData = struct {
    pub const AreaDataId_field_number: u32 = 1;
    pub const ExploreBoxReceivedCount_field_number: u32 = 2;
};
pub const ActivityMoraleData = struct {
    pub const AreaData_field_number: u32 = 1;
    pub const MoraleProgressReward_field_number: u32 = 2;
    pub const MoraleFlags_field_number: u32 = 4;
};
pub const FloroRanchActivityData = struct {
    pub const FloroRangeData_field_number: u32 = 1;
    pub const UnFinishedSubIns_field_number: u32 = 2;
    pub const SavedStage_field_number: u32 = 3;
    pub const CurWeeklyInsId_field_number: u32 = 4;
};
pub const FloroRanchCommonData = struct {
    pub const DataId_field_number: u32 = 1;
    pub const ConditionId_field_number: u32 = 2;
    pub const IsLocked_field_number: u32 = 3;
};
pub const FloroRanchSubDungeonData = struct {
    pub const DataId_field_number: u32 = 1;
    pub const ConditionId_field_number: u32 = 2;
    pub const IsLocked_field_number: u32 = 3;
    pub const IsFinished_field_number: u32 = 4;
};
pub const FloroRangeData = struct {
    pub const FloroRanchCardData_field_number: u32 = 1;
    pub const FloroRanchUnlockedTechDataIds_field_number: u32 = 2;
    pub const FloroRanchToyData_field_number: u32 = 3;
    pub const FloroRanchSkillData_field_number: u32 = 5;
    pub const FloroRanchMilestoneData_field_number: u32 = 7;
    pub const FloroRanchRaceData_field_number: u32 = 9;
    pub const FloroRanchSubDungeonData_field_number: u32 = 10;
    pub const ConditionTask_field_number: u32 = 11;
    pub const FloroRanchSubDungeonHistoryData_field_number: u32 = 13;
    pub const FloroRanchSubDungeonIdsRedDot_field_number: u32 = 14;
    pub const IsReadComic_field_number: u32 = 15;
    pub const FloroRangeUnlockTime_field_number: u32 = 16;
    pub const FloroRangeEndTime_field_number: u32 = 17;
    pub const InsUnLockCondition_field_number: u32 = 18;
};
pub const FloroRanchSubDungeonHistoryData = struct {
    pub const DataId_field_number: u32 = 1;
    pub const MaxDays_field_number: u32 = 2;
    pub const MaxCoins_field_number: u32 = 3;
};
pub const LifePointChallengeData = struct {
    pub const ChallengeId_field_number: u32 = 1;
    pub const CanGetReward_field_number: u32 = 2;
    pub const OpenTime_field_number: u32 = 3;
    pub const RewardId_field_number: u32 = 4;
    pub const EntityConfigId_field_number: u32 = 5;
    pub const IsPreChallengeState_field_number: u32 = 6;
};
pub const LifePointDrawActivityData = struct {
    pub const LifePointChallengeData_field_number: u32 = 1;
};
pub const ActivityTrapDefenseData = struct {
    pub const TrapDefenseTalentNodeIds_field_number: u32 = 1;
    pub const SpecialReward_field_number: u32 = 2;
    pub const Rewards_field_number: u32 = 3;
    pub const Auxiliaries_field_number: u32 = 4;
    pub const Buildings_field_number: u32 = 5;
    pub const Challenges_field_number: u32 = 6;
    pub const StartTime_field_number: u32 = 7;
    pub const EndTime_field_number: u32 = 8;
    pub const TrapDefenseBdDataIdUnlocks_field_number: u32 = 9;
    pub const TrapDefenseTalentTreeMaxPoints_field_number: u32 = 10;
    pub const TrapDefenseTalentTreePoints_field_number: u32 = 11;
    pub const TrapDefenseRemainPoints_field_number: u32 = 12;
    pub const TrapDefenseTotalPoints_field_number: u32 = 13;
    pub const TrapDefenseBdBuffIdUnlocks_field_number: u32 = 14;
};
pub const TrapDefenseRewardData = struct {
    pub const ActivityServerRewardItemData_field_number: u32 = 1;
    pub const StartTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
};
pub const TrapDefenseLevelData = struct {
    pub const ChallengeId_field_number: u32 = 1;
    pub const CanUnlock_field_number: u32 = 2;
    pub const TargetProgress_field_number: u32 = 3;
    pub const IsPassed_field_number: u32 = 4;
    pub const CanGetReward_field_number: u32 = 5;
    pub const UnlockTime_field_number: u32 = 6;
    pub const IsLeaved_field_number: u32 = 7;
    pub const MaxFinishWaveTimes_field_number: u32 = 8;
};
pub const TrapDefenseBuildingData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Level_field_number: u32 = 2;
    pub const Branch_field_number: u32 = 3;
    pub const MaxLevel_field_number: u32 = 4;
    pub const CellPrice_field_number: u32 = 5;
    pub const OriginalConstructPrice_field_number: u32 = 6;
    pub const DiscountConstructPrice_field_number: u32 = 7;
    pub const DeconstructReturn_field_number: u32 = 8;
};
pub const TrapDefenseAuxiliaryData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Level_field_number: u32 = 2;
    pub const Branch_field_number: u32 = 3;
    pub const MaxLevel_field_number: u32 = 4;
};
pub const LineCrossChallengeData = struct {
    pub const ChallengeId_field_number: u32 = 1;
    pub const CanGetReward_field_number: u32 = 2;
    pub const OpenTime_field_number: u32 = 3;
    pub const RewardDataId_field_number: u32 = 4;
    pub const EntityConfigId_field_number: u32 = 5;
    pub const IsPreChallengeState_field_number: u32 = 6;
};
pub const ActivityLineCrossData = struct {
    pub const Challenges_field_number: u32 = 1;
};
pub const MoonSignInConfigData = struct {
    pub const MoonId_field_number: u32 = 1;
    pub const MoonLabelTopId_field_number: u32 = 2;
    pub const MoonLabelBottomId_field_number: u32 = 3;
};
pub const ActivityMoonSignInData = struct {
    pub const MoonPhaseSelectList_field_number: u32 = 1;
    pub const IsGrandReward_field_number: u32 = 2;
    pub const CurrentMoonId_field_number: u32 = 3;
};
pub const FightPhotoActivityData = struct {
    pub const ActivityId_field_number: u32 = 1;
    pub const LevelGroups_field_number: u32 = 2;
    pub const Tasks_field_number: u32 = 4;
};
pub const LevelGroupData = struct {
    pub const GroupId_field_number: u32 = 1;
    pub const OpenTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
    pub const levels_field_number: u32 = 4;
};
pub const LevelData = struct {
    pub const LevelId_field_number: u32 = 1;
    pub const InstId_field_number: u32 = 2;
    pub const Roles_field_number: u32 = 3;
    pub const GroupId_field_number: u32 = 4;
    pub const IsUnlocked_field_number: u32 = 5;
};
pub const FightPhotoLevelDataUpdateNotify = struct {
    pub const msg_id: u16 = 25208;
    pub const levels_field_number: u32 = 7;
};
pub const TaskData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Status_field_number: u32 = 4;
    pub const Progress_field_number: u32 = 5;
};
pub const SurvivorsLevelData = struct {
    ModeInfo: ?union(enum) {
    } = null,
    pub const EndlessInfo_field_number: u32 = 4;
    pub const LevelId_field_number: u32 = 1;
    pub const OpenTime_field_number: u32 = 2;
    pub const NormalInfo_field_number: u32 = 3;
};
pub const SurvivorsLevelInfo = struct {
    pub const IsUnlocked_field_number: u32 = 1;
    pub const ConditionGroupId_field_number: u32 = 2;
    pub const WaveId_field_number: u32 = 3;
    pub const KillMonsterCount_field_number: u32 = 4;
    pub const IsFinished_field_number: u32 = 5;
};
pub const SurvivorsActivityData = struct {
    pub const NormalTaskData_field_number: u32 = 1;
    pub const ScoreTaskDatas_field_number: u32 = 2;
    pub const UnlockedWeapons_field_number: u32 = 3;
    pub const UnlockedRoles_field_number: u32 = 4;
    pub const UnlockedItems_field_number: u32 = 5;
    pub const TalentTreeNodes_field_number: u32 = 6;
    pub const SurvivorsChallengeInfos_field_number: u32 = 7;
};
pub const ActivityPrizeDrawingData = struct {
    pub const ActivityId_field_number: u32 = 1;
    pub const KujiId_field_number: u32 = 2;
    pub const AwardGroups_field_number: u32 = 3;
    pub const CostItemId_field_number: u32 = 4;
    pub const CostItemCount_field_number: u32 = 5;
    pub const QuestFinishedCount_field_number: u32 = 6;
    pub const QuestTotalCount_field_number: u32 = 7;
    pub const QuestId_field_number: u32 = 8;
};
pub const AwardGroupData = struct {
    pub const GroupId_field_number: u32 = 1;
    pub const GroupRank_field_number: u32 = 2;
    pub const CurrentAmount_field_number: u32 = 3;
    pub const AllAmount_field_number: u32 = 4;
    pub const RewardItems_field_number: u32 = 5;
};
pub const HonamiStoryItemInfo = struct {
    ItemInfo: ?union(enum) {
    } = null,
    pub const HonamiStoryNormalItemInfo_field_number: u32 = 4;
    pub const EquipItemInfo_field_number: u32 = 5;
    pub const IncrId_field_number: u32 = 1;
    pub const ItemId_field_number: u32 = 2;
    pub const FuncValue_field_number: u32 = 3;
};
pub const HonamiStoryNormalItemInfo = struct {
};
pub const HonamiStoryEquipItemInfo = struct {
    pub const MainPropLibraryId_field_number: u32 = 1;
    pub const OriBuffTempId_field_number: u32 = 2;
    pub const ChildBuffTempId_field_number: u32 = 3;
};
pub const HonamiStoryPosInfo = struct {
    pub const IsCross_field_number: u32 = 1;
    pub const Posotion_field_number: u32 = 2;
};
pub const TowerInfoData = struct {
    pub const DangerLevel_field_number: u32 = 1;
    pub const MaxFloor_field_number: u32 = 2;
};
pub const HonamiStoryBackpackEntry = struct {
    pub const Item_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const HonamiStoryBackpack = struct {
    pub const BackpackId_field_number: u32 = 1;
    pub const Width_field_number: u32 = 2;
    pub const Capacity_field_number: u32 = 3;
    pub const Items_field_number: u32 = 4;
};
pub const HonamiStoryPlayerBagInfo = struct {
    pub const Warehouse_field_number: u32 = 1;
    pub const EquipRack_field_number: u32 = 2;
    pub const RoleEquipList_field_number: u32 = 3;
    pub const UnlockedWeaponIds_field_number: u32 = 4;
};
pub const HonamiStoryRoleData = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const RoleSlots_field_number: u32 = 2;
    pub const DressWeapon_field_number: u32 = 3;
};
pub const HonamiStoryRoleSlot = struct {
    pub const SlotId_field_number: u32 = 1;
    pub const IsUnlocked_field_number: u32 = 2;
};
pub const HonamiStoryItemCollectionConfig = struct {
    pub const Id_field_number: u32 = 1;
    pub const Status_field_number: u32 = 2;
};
pub const HonamiStoryMascotConfig = struct {
    pub const MascotId_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const HonamiStoryAreaConfig = struct {
    pub const AreaId_field_number: u32 = 1;
    pub const Status_field_number: u32 = 2;
    pub const SecreteStatus_field_number: u32 = 3;
};
pub const HonamiStoryScoreRewardInfo = struct {
    pub const ScoreRewardId_field_number: u32 = 1;
    pub const Status_field_number: u32 = 2;
};
pub const TalentInfoData = struct {
    pub const TalentId_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const RoleCoopActivityData = struct {
    pub const CoopRoleInfos_field_number: u32 = 2;
    pub const RewardGetList_field_number: u32 = 3;
    pub const CoopTaskCompleteInfos_field_number: u32 = 4;
    pub const PreCompleteIds_field_number: u32 = 5;
};
pub const CoopTaskCompleteInfo = struct {
    pub const CoopTaskId_field_number: u32 = 1;
    pub const Task_field_number: u32 = 2;
    pub const UnLockTime_field_number: u32 = 3;
    pub const LevelPlay1Done_field_number: u32 = 4;
    pub const LevelPlay2Done_field_number: u32 = 5;
};
pub const CoopRoleInfo = struct {
    pub const CoopRoleId_field_number: u32 = 1;
    pub const RoleLevel_field_number: u32 = 2;
    pub const RewardLevel_field_number: u32 = 3;
    pub const FinishTime_field_number: u32 = 4;
};
pub const AdvertisingPageInfo = struct {
    pub const ActivityId_field_number: u32 = 1;
    pub const UnlockIndex_field_number: u32 = 2;
    pub const RewardedIndex_field_number: u32 = 3;
};
pub const MotorCycleIpActivityData = struct {
    pub const TaskDataList_field_number: u32 = 1;
};
pub const PhantomBattleCardSkillUnlockInfo = struct {
    pub const CardId_field_number: u32 = 1;
    pub const Unlock_field_number: u32 = 2;
    pub const TargetNum_field_number: u32 = 3;
    pub const CurNum_field_number: u32 = 4;
};
pub const MotorParkourActivityInfo = struct {
    pub const MotorParkourLevelInfos_field_number: u32 = 1;
};
pub const MotorParkourLevelInfo = struct {
    pub const MotorParkourId_field_number: u32 = 1;
    pub const RewardStates_field_number: u32 = 2;
    pub const UnlockTime_field_number: u32 = 3;
    pub const BestPassTime_field_number: u32 = 4;
};
pub const RoadBookActivityInfo = struct {
    pub const ActivityTasks_field_number: u32 = 1;
    pub const MonsterGain_field_number: u32 = 2;
    pub const GetFullReward_field_number: u32 = 3;
    pub const RoadBookLevel_field_number: u32 = 4;
    pub const UnLockAreas_field_number: u32 = 5;
    pub const SoarLevels_field_number: u32 = 6;
};
pub const RoadBookMotorcycleInfo = struct {
    pub const MotorcyclePlayId_field_number: u32 = 1;
    pub const HistorySoarScore_field_number: u32 = 2;
    pub const ReceiveIds_field_number: u32 = 3;
};
pub const MotorFightActivityPb = struct {
    pub const MotorFightLevelPb_field_number: u32 = 2;
    pub const Task_field_number: u32 = 3;
    pub const TalentTree_field_number: u32 = 4;
    pub const UnlockedItem_field_number: u32 = 5;
    pub const UnlockedRole_field_number: u32 = 6;
};
pub const MotorFightTalentTreePb = struct {
    pub const Talent_field_number: u32 = 1;
};
pub const MotorFightLevelPb = struct {
    pub const LevelId_field_number: u32 = 1;
    pub const OpenTime_field_number: u32 = 2;
    pub const Cleared_field_number: u32 = 3;
    pub const BestScore_field_number: u32 = 4;
    pub const LastRoleId_field_number: u32 = 5;
};
pub const MotorFightTalentPb = struct {
    pub const Id_field_number: u32 = 1;
    pub const Unlock_field_number: u32 = 3;
    pub const InUse_field_number: u32 = 4;
};
pub const EncircleChallengePb = struct {
    pub const ChallengeId_field_number: u32 = 1;
    pub const OpenTime_field_number: u32 = 2;
    pub const Pass_field_number: u32 = 3;
    pub const MinStep_field_number: u32 = 5;
};
pub const EncircleActivityPb = struct {
    pub const Challenges_field_number: u32 = 1;
};
pub const NewTowerClimbingActivityData = struct {
    pub const CycleId_field_number: u32 = 1;
    pub const Records_field_number: u32 = 2;
    pub const ScoreTasks_field_number: u32 = 3;
    pub const ActivityTasks_field_number: u32 = 4;
    pub const CycleBeginTime_field_number: u32 = 5;
    pub const CycleCloseTime_field_number: u32 = 6;
    pub const SeasonId_field_number: u32 = 7;
    pub const SeasonBeginTime_field_number: u32 = 8;
    pub const SeasonCloseTime_field_number: u32 = 9;
    pub const SeasonTasks_field_number: u32 = 10;
};
pub const NewTowerClimbingLevelRecord = struct {
    pub const LevelId_field_number: u32 = 1;
    pub const WaveConfigIds_field_number: u32 = 2;
    pub const NextMonsterInfoPreview_field_number: u32 = 3;
    pub const TeamChallengeInfos_field_number: u32 = 4;
    pub const Score_field_number: u32 = 7;
    pub const IsUnlock_field_number: u32 = 8;
    pub const RoleEnergyDict_field_number: u32 = 9;
    pub const HistoryScore_field_number: u32 = 10;
};
pub const MonsterInfoPreview = struct {
    pub const WaveConfigId_field_number: u32 = 1;
    pub const HpPpb_field_number: u32 = 2;
    pub const Damage_field_number: u32 = 3;
    pub const Round_field_number: u32 = 4;
    pub const IsDead_field_number: u32 = 5;
};
pub const RoleSaveInfo = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const WeaponIncId_field_number: u32 = 2;
    pub const PhantomIncId_field_number: u32 = 3;
    pub const SkillBranchId_field_number: u32 = 4;
};
pub const TeamChallengeInfo = struct {
    pub const RoleSaveInfos_field_number: u32 = 1;
    pub const BuffIds_field_number: u32 = 2;
    pub const LastMonsterInfoPreview_field_number: u32 = 3;
    pub const TeamScore_field_number: u32 = 4;
};
pub const NewPlayerSupportActivityV2Pb = struct {
    pub const TrialRoleInfoList_field_number: u32 = 1;
    pub const CurUseTrialRoleId_field_number: u32 = 3;
    pub const CurUseRoleInfo_field_number: u32 = 4;
    pub const DeduplicateGachaRoleIds_field_number: u32 = 5;
    pub const NbWeekCardEndShowTime_field_number: u32 = 6;
    pub const NbGiftPackEndShowTime_field_number: u32 = 7;
    pub const NbGachaEndShowTime_field_number: u32 = 8;
    pub const NbLivenessEndShowTime_field_number: u32 = 9;
    pub const NewPlayerPoolFinalGachaRoleId_field_number: u32 = 10;
};
pub const SpringFestivalActivityInfo = struct {
    pub const AreaInfos_field_number: u32 = 1;
    pub const UnlockFurnitures_field_number: u32 = 2;
    pub const DrinkMixData_field_number: u32 = 3;
    pub const OneBrochureInfos_field_number: u32 = 4;
    pub const JokerLevelInfos_field_number: u32 = 5;
    pub const ConditionTasks_field_number: u32 = 6;
    pub const SpringFunctionIds_field_number: u32 = 7;
    pub const RewardScoreIds_field_number: u32 = 8;
    pub const RewardLevelIds_field_number: u32 = 9;
    pub const Atmosphere_field_number: u32 = 10;
    pub const AtmosphereLevel_field_number: u32 = 11;
    pub const SpringSkipEntries_field_number: u32 = 12;
};
pub const SpringSkipEntry = struct {
    pub const Id_field_number: u32 = 1;
    pub const UnLock_field_number: u32 = 2;
    pub const Finish_field_number: u32 = 3;
};
pub const DrinkMixData = struct {
    pub const RoleLevelInfo_field_number: u32 = 1;
};
pub const DrinkMixRole = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const FirstPass_field_number: u32 = 2;
    pub const MaxLike_field_number: u32 = 3;
    pub const RewardGet_field_number: u32 = 4;
};
pub const GuessJokerLevelInfo = struct {
    pub const LevelId_field_number: u32 = 1;
    pub const LevelPass_field_number: u32 = 2;
    pub const UnLock_field_number: u32 = 3;
    pub const RewardGet_field_number: u32 = 4;
    pub const PlayerWin_field_number: u32 = 5;
};
pub const AreaInfo = struct {
    pub const AreaId_field_number: u32 = 1;
    pub const Atmosphere_field_number: u32 = 2;
    pub const FurnitureDiySlotInfos_field_number: u32 = 3;
};
pub const FurnitureDiySlotInfo = struct {
    pub const SlotEntityCfgId_field_number: u32 = 1;
    pub const RootFurnitureId_field_number: u32 = 2;
    pub const SubFurnitureIds_field_number: u32 = 3;
};
pub const OneBrochureInfo = struct {
    pub const BrochureId_field_number: u32 = 1;
    pub const BookItemInfos_field_number: u32 = 2;
};
pub const BookItemInfo = struct {
    pub const BookItemId_field_number: u32 = 1;
    pub const BookItemState_field_number: u32 = 2;
};
pub const TotalTopUpRewardInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const Score_field_number: u32 = 2;
    pub const RewardContent_field_number: u32 = 3;
    pub const Status_field_number: u32 = 4;
};
pub const TotalTopUpActivityInfo = struct {
    pub const Score_field_number: u32 = 1;
    pub const TotalTopUpRewardInfos_field_number: u32 = 2;
};
pub const H5ViewActivityData = struct {
    pub const RedDot_field_number: u32 = 1;
    pub const AllRewardClaimed_field_number: u32 = 2;
};
pub const SkinRewardActivityData = struct {
    pub const RewardInfos_field_number: u32 = 1;
};
pub const SkinRewardActivityRewardInfo = struct {
    pub const ConfigId_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const MotorDevelopActivityData = struct {
    pub const Task_field_number: u32 = 1;
};
pub const FlagChallengeLevelInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
    pub const State_field_number: u32 = 3;
};
pub const FlagStrongholdInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const IsPass_field_number: u32 = 2;
};
pub const FlagChallengeRoleLevelInfo = struct {
    pub const PerLevel_field_number: u32 = 1;
    pub const PerExp_field_number: u32 = 2;
};
pub const FeiXuePreheatInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
    pub const QuestUnlockTime_field_number: u32 = 3;
};
pub const FeiXuePreheatActivityInfo = struct {
    pub const FeiXuePreheatInfos_field_number: u32 = 1;
};
pub const RhythmActivityPb = struct {
    pub const RhythmShipPlanetPb_field_number: u32 = 2;
    pub const RhythmRoleId_field_number: u32 = 3;
    pub const RhythmTask_field_number: u32 = 5;
    pub const UnlockedRole_field_number: u32 = 6;
    pub const RedDot_field_number: u32 = 7;
};
pub const RhythmShipPlanetPb = struct {
    pub const PlanetId_field_number: u32 = 1;
    pub const OpenTime_field_number: u32 = 2;
    pub const RhythmShipLevelPb_field_number: u32 = 3;
};
pub const RhythmShipLevelPb = struct {
    pub const LevelId_field_number: u32 = 1;
    pub const RhythmSubLevelPb_field_number: u32 = 2;
};
pub const RhythmSubLevelPb = struct {
    pub const SubLevelId_field_number: u32 = 1;
    pub const Cleared_field_number: u32 = 2;
    pub const BestScore_field_number: u32 = 3;
    pub const BestAccuracy_field_number: u32 = 4;
    pub const BestRank_field_number: u32 = 5;
};
pub const RhythmTaskPb = struct {
    pub const TaskType_field_number: u32 = 1;
    pub const Task_field_number: u32 = 2;
};
pub const RhythmRedDotPb = struct {
    pub const ReadPlanet_field_number: u32 = 2;
    pub const ReadSubLevel_field_number: u32 = 4;
    pub const ReadRole_field_number: u32 = 5;
};
pub const DropCatchActivityInfo = struct {
    pub const DropCatchLevelInfos_field_number: u32 = 1;
};
pub const DropCatchLevelInfo = struct {
    pub const DropCatchId_field_number: u32 = 1;
    pub const RewardStates_field_number: u32 = 2;
    pub const UnlockTime_field_number: u32 = 3;
    pub const Score_field_number: u32 = 4;
};
pub const TetrisActivityInfo = struct {
    pub const TetrisLevelInfos_field_number: u32 = 1;
};
pub const TetrisLevelInfo = struct {
    vdC: ?union(enum) {
    } = null,
    ehC: ?union(enum) {
    } = null,
    thC: ?union(enum) {
    } = null,
    pub const DifficultyIdx_field_number: u32 = 2;
    pub const State_field_number: u32 = 3;
    pub const UnlockTime_field_number: u32 = 4;
    pub const Id_field_number: u32 = 1;
    pub const Results_field_number: u32 = 5;
};
pub const PinballActivityData = struct {
    pub const Chapters_field_number: u32 = 1;
    pub const Levels_field_number: u32 = 2;
    pub const Weapons_field_number: u32 = 3;
    pub const Roles_field_number: u32 = 4;
    pub const ConditionTasks_field_number: u32 = 5;
    pub const GroupFormations_field_number: u32 = 6;
};
pub const PinballGroupFormation = struct {
    pub const LevelGroup_field_number: u32 = 1;
    pub const RoleIds_field_number: u32 = 2;
};
pub const PinballChapterData = struct {
    pub const ChapterId_field_number: u32 = 1;
    pub const UnLockTime_field_number: u32 = 2;
};
pub const PinballLevelData = struct {
    data: ?union(enum) {
    } = null,
    pub const NormalLevel_field_number: u32 = 2;
    pub const CowLevel_field_number: u32 = 3;
    pub const TowerLevel_field_number: u32 = 4;
    pub const DailyLevel_field_number: u32 = 5;
    pub const ConfigId_field_number: u32 = 1;
};
pub const NormalLevel = struct {
    pub const StarByte_field_number: u32 = 1;
};
pub const CowLevel = struct {
    pub const LevelScore_field_number: u32 = 1;
};
pub const TowerLevel = struct {
    pub const StarByte_field_number: u32 = 1;
    pub const CostTime_field_number: u32 = 2;
};
pub const DailyLevel = struct {
    pub const RandomLevelId_field_number: u32 = 1;
    pub const reward_field_number: u32 = 2;
};
pub const PinballWeapon = struct {
    pub const ConfigId_field_number: u32 = 1;
    pub const IncrId_field_number: u32 = 2;
    pub const FuncValue_field_number: u32 = 3;
    pub const roleId_field_number: u32 = 4;
    pub const SubEntryId_field_number: u32 = 5;
};
pub const PinballWeapons = struct {
    pub const PinballWeaponList_field_number: u32 = 1;
};
pub const PinballRoles = struct {
    pub const Roles_field_number: u32 = 1;
};
pub const PinballRoleData = struct {
    pub const ConfigId_field_number: u32 = 1;
    pub const RoleLevel_field_number: u32 = 2;
};
pub const BossPilingLevelInfo = struct {
    pub const id_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
    pub const BossHpNum_field_number: u32 = 3;
    pub const SelectRoleIds_field_number: u32 = 4;
    pub const SkillBranchId_field_number: u32 = 5;
};
pub const ThemeCelebration = struct {
    pub const PersonalRewardIds_field_number: u32 = 1;
    pub const WorldRewardIds_field_number: u32 = 2;
    pub const SubActivityTimes_field_number: u32 = 3;
};
pub const WuWuWeekActivity = struct {
    pub const ConditionTasks_field_number: u32 = 1;
    pub const TaskPack_field_number: u32 = 2;
};
pub const WuWuTaskPack = struct {
    pub const WuWuPackageId_field_number: u32 = 1;
    pub const UnLockTime_field_number: u32 = 2;
    pub const HadReward_field_number: u32 = 3;
};
pub const SubActivityBeginTime = struct {
    pub const Id_field_number: u32 = 1;
    pub const BeginTime_field_number: u32 = 2;
};
pub const MotorDecalActivityData = struct {
    pub const ConditionTasks_field_number: u32 = 1;
};
pub const LinkageCheckInActivityData = struct {
    pub const CheckInDay_field_number: u32 = 1;
    pub const NormalReward_field_number: u32 = 2;
    pub const KeepReward_field_number: u32 = 3;
};
pub const GolemCrackActivityInfo = struct {
    pub const GolemCrackLevelInfos_field_number: u32 = 1;
};
pub const GolemCrackLevelInfo = struct {
    NlC: ?union(enum) {
    } = null,
    VlC: ?union(enum) {
    } = null,
    pub const state_field_number: u32 = 2;
    pub const UnlockTime_field_number: u32 = 3;
    pub const id_field_number: u32 = 1;
};
pub const EdgeRunnerActivityInfo = struct {
    pub const EdgeRunnerFunctionIds_field_number: u32 = 1;
    pub const RewardScoreId_field_number: u32 = 2;
    pub const EdgeRunnerLordGymPassRecords_field_number: u32 = 3;
    pub const ConditionTasks_field_number: u32 = 4;
    pub const PreUnlockIds_field_number: u32 = 5;
};
pub const EdgeRunnerLordGymPassRecord = struct {
    pub const LoadGymId_field_number: u32 = 1;
    pub const PassTime_field_number: u32 = 2;
};
pub const LordGymInfoRequest = struct {
    pub const msg_id: u16 = 18431;
};
pub const LordGymInfoResponse = struct {
    pub const msg_id: u16 = 27680;
    pub const UnlockLoadGymIds_field_number: u32 = 9;
    pub const ReadLoadGymIds_field_number: u32 = 6;
    pub const LordGymPassRecords_field_number: u32 = 14;
    pub const LordGymEntranceInfos_field_number: u32 = 15;
    pub const LordGymGroupInfos_field_number: u32 = 11;
};
pub const LordGymEntranceInfo = struct {
    pub const ConfigId_field_number: u32 = 1;
    pub const EffectBeginTime_field_number: u32 = 2;
    pub const EffectEndTime_field_number: u32 = 3;
};
pub const LordGymGroupInfo = struct {
    pub const GroupId_field_number: u32 = 1;
    pub const PassDiff_field_number: u32 = 2;
};
pub const RoleBrief = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const Level_field_number: u32 = 2;
};
pub const LordGymPassRecord = struct {
    pub const LoadGymId_field_number: u32 = 1;
    pub const PassTime_field_number: u32 = 2;
    pub const RoleIds_field_number: u32 = 3;
};
pub const RoleGiftActivityData = struct {
    pub const RewardHadGet_field_number: u32 = 1;
};
pub const KurotatoItemPanelPbData = struct {
    pub const ItemPbDatas_field_number: u32 = 1;
};
pub const KurotatoItemPbData = struct {
    pub const itemId_field_number: u32 = 1;
    pub const count_field_number: u32 = 2;
    pub const PreWaveDealtDamage_field_number: u32 = 3;
};
pub const KurotatoWeaponPanelPbData = struct {
    pub const WeaponPbDatas_field_number: u32 = 1;
};
pub const KurotatoWeaponPbData = struct {
    pub const WeaponId_field_number: u32 = 1;
    pub const IncId_field_number: u32 = 2;
    pub const PreWaveDealtDamage_field_number: u32 = 3;
    pub const SellPrice_field_number: u32 = 4;
};
pub const KurotatoActivityData = struct {
    pub const KurotatoLevelInfos_field_number: u32 = 1;
    pub const KurotatoRoleInfos_field_number: u32 = 2;
    pub const UnlockWeapons_field_number: u32 = 3;
    pub const UnlockItems_field_number: u32 = 4;
    pub const ScoreTasks_field_number: u32 = 5;
    pub const ResTasks_field_number: u32 = 6;
    pub const LimitTasks_field_number: u32 = 7;
};
pub const KurotatoLevelInfo = struct {
    jSp: ?union(enum) {
    } = null,
    DOLLARSp: ?union(enum) {
    } = null,
    pub const EndlessLevelInfo_field_number: u32 = 5;
    pub const InstData_field_number: u32 = 8;
    pub const LevelId_field_number: u32 = 1;
    pub const IsUnlock_field_number: u32 = 2;
    pub const UnlockTime_field_number: u32 = 3;
    pub const IsFinished_field_number: u32 = 4;
};
pub const KurotatoEndlessLevelInfo = struct {
    pub const FinishWave_field_number: u32 = 1;
    pub const TotalKillCount_field_number: u32 = 2;
    pub const PassRoleIds_field_number: u32 = 3;
};
pub const KurotatoRoleInfo = struct {
    DOLLARSp: ?union(enum) {
    } = null,
    pub const InstData_field_number: u32 = 4;
    pub const roleId_field_number: u32 = 1;
    pub const IsUnlock_field_number: u32 = 2;
    pub const MaxFinishWave_field_number: u32 = 3;
    pub const KillCount_field_number: u32 = 5;
};
pub const KurotatoInstInfo = struct {
    pub const LevelId_field_number: u32 = 1;
    pub const CurWave_field_number: u32 = 2;
    pub const roleId_field_number: u32 = 3;
    pub const RoleLevel_field_number: u32 = 4;
    pub const RoleExp_field_number: u32 = 5;
    pub const ItemPanelPbData_field_number: u32 = 6;
    pub const WeaponPanelPbData_field_number: u32 = 7;
    pub const PropertyMap_field_number: u32 = 8;
    pub const SaveTimestamp_field_number: u32 = 9;
    pub const WaveType_field_number: u32 = 10;
};
pub const OnlineMotorLevelInfo = struct {
    pub const LevelId_field_number: u32 = 1;
    pub const Ranking_field_number: u32 = 2;
    pub const TimeCost_field_number: u32 = 3;
};
pub const OnlineMotorLevelUnLockTime = struct {
    pub const LevelId_field_number: u32 = 1;
    pub const UnLockTime_field_number: u32 = 2;
};
pub const OnlineMotorActivityData = struct {
    pub const OnlineMotorLevelInfos_field_number: u32 = 1;
    pub const LevelTasks_field_number: u32 = 2;
    pub const GlobalTasks_field_number: u32 = 3;
    pub const UnLocks_field_number: u32 = 4;
};
pub const OnlineMotorTask = struct {
    pub const taskId_field_number: u32 = 1;
    pub const state_field_number: u32 = 2;
    pub const PlayCount_field_number: u32 = 3;
    pub const Champion_field_number: u32 = 4;
    pub const SpeedLap_field_number: u32 = 5;
    pub const FirstRunner_field_number: u32 = 6;
};
pub const RealmBetweenActivityInfo = struct {
    pub const ActivityTasks_field_number: u32 = 1;
    pub const MonsterGain_field_number: u32 = 2;
    pub const GetFullReward_field_number: u32 = 3;
    pub const RealmBetweenLevel_field_number: u32 = 4;
    pub const UnLockAreas_field_number: u32 = 5;
    pub const SoarLevels_field_number: u32 = 6;
};
pub const RealmBetweenMotorcycleInfo = struct {
    pub const MotorcyclePlayId_field_number: u32 = 1;
    pub const HistorySoarScore_field_number: u32 = 2;
    pub const ReceiveIds_field_number: u32 = 3;
};
pub const NewbieMainActivityPb = struct {
    pub const NewbieMainTabs_field_number: u32 = 2;
    pub const TakenScoreRewardIds_field_number: u32 = 3;
    pub const ProgressScore_field_number: u32 = 4;
};
pub const NewbieMainTabPb = struct {
    pub const TabId_field_number: u32 = 1;
    pub const CompletedTaskIds_field_number: u32 = 2;
};
pub const NewbieCourseV2ActivityPb = struct {
    pub const HadTakeReward_field_number: u32 = 1;
    pub const BeginOpenTime_field_number: u32 = 2;
};
pub const NewbieAdventureV2Pb = struct {
    pub const Chapter_field_number: u32 = 2;
};
pub const NewbieAdventureV2ChapterPb = struct {
    pub const id_field_number: u32 = 1;
    pub const Task_field_number: u32 = 2;
    pub const RewardRoleId_field_number: u32 = 3;
    pub const RewardedRoleId_field_number: u32 = 4;
    pub const RewardDrop_field_number: u32 = 5;
};
pub const RoverRogueInsEntry = struct {
    pub const instId_field_number: u32 = 1;
    pub const DifficultyName_field_number: u32 = 2;
    pub const Level_field_number: u32 = 3;
    pub const ExpectedTimeMinSec_field_number: u32 = 4;
    pub const ExpectedTimeMaxSec_field_number: u32 = 5;
    pub const Unlocked_field_number: u32 = 6;
    pub const BestGrade_field_number: u32 = 7;
};
pub const RoverRogueActivityData = struct {
    pub const activityId_field_number: u32 = 1;
    pub const HistoryInsInfo_field_number: u32 = 2;
    pub const UnlockRoleIdList_field_number: u32 = 3;
    pub const UnlockBlessRoleIdList_field_number: u32 = 4;
    pub const UnlockBlessIdList_field_number: u32 = 5;
    pub const UnlockTalentIdList_field_number: u32 = 6;
    pub const UnlockItemIdList_field_number: u32 = 7;
    pub const UnlockLootIdList_field_number: u32 = 8;
    pub const ConditionTasks_field_number: u32 = 9;
    pub const ActiveTalentIdList_field_number: u32 = 10;
    pub const TokenItem_field_number: u32 = 11;
    pub const TalentItem_field_number: u32 = 12;
    pub const UnlockRoleType_field_number: u32 = 13;
    pub const EquippedLoot_field_number: u32 = 14;
    pub const InsInfoList_field_number: u32 = 15;
};
pub const RoverRogueHistoryInsInfo = struct {
    pub const CurInsId_field_number: u32 = 1;
    pub const CurLayer_field_number: u32 = 2;
    pub const TotalLayer_field_number: u32 = 3;
    pub const LootId_field_number: u32 = 4;
};
pub const QingXiaoActivityInfo = struct {
    pub const ConditionTasks_field_number: u32 = 1;
};
pub const AdventreTask = struct {
    pub const Id_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
    pub const AdventreProgress_field_number: u32 = 3;
};
pub const AdventureManualData = struct {
    pub const AdventreTask_field_number: u32 = 1;
    pub const NowChapter_field_number: u32 = 2;
    pub const ReceivedChapter_field_number: u32 = 3;
    pub const UnlockChapters_field_number: u32 = 4;
    pub const RewardChapters_field_number: u32 = 5;
};
pub const AdventureItemData = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const ItemNum_field_number: u32 = 2;
};
pub const AdventureRewardData = struct {
    pub const DropId_field_number: u32 = 1;
    pub const Items_field_number: u32 = 2;
};
pub const DetectionTarget = struct {
    pub const Id_field_number: u32 = 1;
    pub const Type_field_number: u32 = 2;
    pub const UnlockState_field_number: u32 = 3;
    pub const RefresherTime_field_number: u32 = 4;
    pub const DetectionId_field_number: u32 = 5;
    pub const IsTrace_field_number: u32 = 6;
};
pub const DetectionUnlock = struct {
    pub const MonsterDetectionIds_field_number: u32 = 1;
    pub const DungeonDetectionIds_field_number: u32 = 2;
    pub const SilentAreaDetectionIds_field_number: u32 = 3;
};
pub const SelectDetectionTarget = struct {
    pub const DetectionId_field_number: u32 = 1;
    pub const Type_field_number: u32 = 2;
    pub const Id_field_number: u32 = 3;
    pub const IsTrace_field_number: u32 = 4;
};
pub const AdventureManualDataRequest = struct {
    pub const msg_id: u16 = 29160;
    pub const PlayerId_field_number: u32 = 6;
};
pub const AdventureManualDataResponse = struct {
    pub const msg_id: u16 = 28629;
    pub const ErrorCode_field_number: u32 = 14;
    pub const AdventureManualData_field_number: u32 = 5;
};
pub const AdventureUpdateNotify = struct {
    pub const msg_id: u16 = 24195;
    pub const AdventureManualData_field_number: u32 = 12;
};
pub const AdventureManualRequest = struct {
    pub const msg_id: u16 = 20163;
    pub const PlayerId_field_number: u32 = 8;
};
pub const AdventureManualResponse = struct {
    pub const msg_id: u16 = 27833;
    pub const ErrorCode_field_number: u32 = 5;
    pub const AdventureManualData_field_number: u32 = 12;
    pub const DetectionTarget_field_number: u32 = 7;
    pub const AdventureRewardData_field_number: u32 = 4;
    pub const DetectionUnlocks_field_number: u32 = 15;
    pub const NowSelectDetectionTarget_field_number: u32 = 3;
    pub const SlientFirstAwardMap_field_number: u32 = 1;
    pub const SilenceAreaConfigs_field_number: u32 = 2;
    pub const DungeonDetections_field_number: u32 = 9;
    pub const PreOpeDungeonDetections_field_number: u32 = 6;
    pub const PreOpenSilenceAreaDetections_field_number: u32 = 8;
};
pub const PreOpenDetections = struct {
    pub const Id_field_number: u32 = 1;
    pub const PreOpenId_field_number: u32 = 2;
    pub const PreOpenBeginTime_field_number: u32 = 3;
    pub const PreOpenEndTIme_field_number: u32 = 4;
};
pub const AdventureDetectionConfig = struct {
    pub const Id_field_number: u32 = 1;
    pub const EffectBeginTime_field_number: u32 = 2;
    pub const EffectEndTime_field_number: u32 = 3;
};
pub const UnlockDetectionLabelInfo = struct {
    pub const UnlockedGuideIds_field_number: u32 = 1;
    pub const UnlockedDetectionTextIds_field_number: u32 = 2;
};
pub const GetDetectionLabelInfoRequest = struct {
    pub const msg_id: u16 = 20178;
};
pub const GetDetectionLabelInfoResponse = struct {
    pub const msg_id: u16 = 24153;
    pub const UnlockLabelInfo_field_number: u32 = 15;
};
pub const AdviceSettingNotify = struct {
    pub const msg_id: u16 = 28625;
    pub const IsShow_field_number: u32 = 1;
};
pub const AdviceSetRequest = struct {
    pub const msg_id: u16 = 21659;
    pub const IsShow_field_number: u32 = 1;
};
pub const AdviceSetResponse = struct {
    pub const msg_id: u16 = 25432;
    pub const IsShow_field_number: u32 = 14;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const PbAdvice = struct {
    pub const Id_field_number: u32 = 1;
    pub const AreaId_field_number: u32 = 2;
    pub const Contents_field_number: u32 = 3;
    pub const UpVote_field_number: u32 = 4;
};
pub const AdviceComponentPb = struct {
    pub const Advice_field_number: u32 = 1;
    pub const PlayerId_field_number: u32 = 2;
    pub const PlayerName_field_number: u32 = 3;
};
pub const PbAdviceContent = struct {
    pub const Type_field_number: u32 = 1;
    pub const Id_field_number: u32 = 2;
    pub const Word_field_number: u32 = 3;
};
pub const AdviceRequest = struct {
    pub const msg_id: u16 = 25888;
};
pub const AdviceResponse = struct {
    pub const msg_id: u16 = 18557;
    pub const Advices_field_number: u32 = 5;
    pub const UpVoteIds_field_number: u32 = 12;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const AiHateEntity = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const HatredValue_field_number: u32 = 2;
};
pub const Int2Long = struct {
    pub const First_field_number: u32 = 1;
    pub const Second_field_number: u32 = 2;
};
pub const Int2Bool = struct {
    pub const First_field_number: u32 = 1;
    pub const Second_field_number: u32 = 2;
};
pub const AiInformation = struct {
    pub const AiBlackboards_field_number: u32 = 1;
    pub const HateList_field_number: u32 = 2;
    pub const AiBlackboardCd_field_number: u32 = 3;
};
pub const AiInformationRequest = struct {
    pub const msg_id: u16 = 26333;
    pub const AiInfo_field_number: u32 = 4;
};
pub const AiInformationPush = struct {
    pub const msg_id: u16 = 27990;
    pub const AiInfo_field_number: u32 = 9;
};
pub const AiInformationResponse = struct {
    pub const msg_id: u16 = 21592;
    pub const ErrorCode_field_number: u32 = 7;
};
pub const AiInformationNotify = struct {
    pub const msg_id: u16 = 15805;
    pub const AiBlackboardCd_field_number: u32 = 15;
};
pub const AiBlackboardsRequest = struct {
    pub const msg_id: u16 = 16504;
    pub const AiBlackboards_field_number: u32 = 2;
};
pub const AiBlackboardsPush = struct {
    pub const msg_id: u16 = 20334;
    pub const AiBlackboards_field_number: u32 = 4;
};
pub const AiBlackboardsResponse = struct {
    pub const msg_id: u16 = 21397;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const AiBlackboardCdRequest = struct {
    pub const msg_id: u16 = 25857;
    pub const AiBlackboardCdModify_field_number: u32 = 7;
    pub const AiBlackboardCdComplete_field_number: u32 = 4;
};
pub const AiBlackboardCdPush = struct {
    pub const msg_id: u16 = 27774;
    pub const AiBlackboardCdModify_field_number: u32 = 7;
    pub const AiBlackboardCdComplete_field_number: u32 = 11;
};
pub const AiBlackboardCdResponse = struct {
    pub const msg_id: u16 = 16519;
    pub const ErrorCode_field_number: u32 = 9;
};
pub const AiBlackboardCdNotify = struct {
    pub const msg_id: u16 = 22240;
    pub const AiBlackboardCdDel_field_number: u32 = 12;
    pub const AiBlackboardCdModify_field_number: u32 = 4;
    pub const AiBlackboardCdComplete_field_number: u32 = 7;
};
pub const AiHateRequest = struct {
    pub const msg_id: u16 = 20606;
    pub const HateList_field_number: u32 = 13;
};
pub const AiHatePush = struct {
    pub const msg_id: u16 = 21860;
    pub const HateList_field_number: u32 = 7;
};
pub const AiHateResponse = struct {
    pub const msg_id: u16 = 15211;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const AiHateNotify = struct {
    pub const msg_id: u16 = 29150;
    pub const HateList_field_number: u32 = 6;
};
pub const IntArrayBlackboard = struct {
    pub const Values_field_number: u32 = 1;
};
pub const LongArrayBlackboard = struct {
    pub const Values_field_number: u32 = 1;
};
pub const StringArrayBlackboard = struct {
    pub const Values_field_number: u32 = 1;
};
pub const FloatArrayBlackboard = struct {
    pub const Values_field_number: u32 = 1;
};
pub const VectorArrayBlackboard = struct {
    pub const Values_field_number: u32 = 1;
};
pub const RotatorArrayBlackboard = struct {
    pub const Values_field_number: u32 = 1;
};
pub const BlackboardParam = struct {
    Value: ?union(enum) {
    } = null,
    pub const IntValue_field_number: u32 = 3;
    pub const IntValues_field_number: u32 = 4;
    pub const LongValue_field_number: u32 = 5;
    pub const LongValues_field_number: u32 = 6;
    pub const BooleanValue_field_number: u32 = 7;
    pub const StringValue_field_number: u32 = 8;
    pub const StringValues_field_number: u32 = 9;
    pub const FloatValue_field_number: u32 = 10;
    pub const FloatValues_field_number: u32 = 11;
    pub const VectorValue_field_number: u32 = 12;
    pub const VectorValues_field_number: u32 = 13;
    pub const RotatorValue_field_number: u32 = 14;
    pub const RotatorValues_field_number: u32 = 15;
    pub const Key_field_number: u32 = 1;
    pub const Type_field_number: u32 = 2;
};
pub const EnterAreaRequest = struct {
    pub const msg_id: u16 = 27794;
    pub const Id_field_number: u32 = 15;
    pub const LeaveId_field_number: u32 = 6;
};
pub const EnterAreaResponse = struct {
    pub const msg_id: u16 = 17948;
    pub const ErrorCode_field_number: u32 = 2;
    pub const Id_field_number: u32 = 8;
};
pub const AudioState = struct {
    pub const TreeOwnerId_field_number: u32 = 1;
    pub const TreeIncId_field_number: u32 = 2;
    pub const GroupType_field_number: u32 = 3;
    pub const State_field_number: u32 = 4;
};
pub const BanLogoutInfo = struct {
    pub const Reason_field_number: u32 = 1;
    pub const BanEndTime_field_number: u32 = 2;
};
pub const CardShowEntry = struct {
    pub const CardId_field_number: u32 = 1;
    pub const IsRead_field_number: u32 = 2;
};
pub const BasicInfoNotify = struct {
    pub const msg_id: u16 = 29300;
    pub const Id_field_number: u32 = 14;
    pub const Attributes_field_number: u32 = 10;
    pub const MingSuGenInfos_field_number: u32 = 12;
    pub const DragonPoolInfos_field_number: u32 = 11;
    pub const RoleShowList_field_number: u32 = 15;
    pub const CurCardId_field_number: u32 = 2;
    pub const Birthday_field_number: u32 = 7;
    pub const CardUnlockList_field_number: u32 = 8;
    pub const RandomSeed_field_number: u32 = 1;
    pub const DisplayBirthDay_field_number: u32 = 6;
    pub const LastModifyNameTime_field_number: u32 = 5;
    pub const ModifyNameTime_field_number: u32 = 3;
    pub const BusinessCompliance_field_number: u32 = 9;
    pub const NewbieGuideV2_field_number: u32 = 4;
};
pub const ModifyNameRequest = struct {
    pub const msg_id: u16 = 17271;
    pub const Name_field_number: u32 = 1;
};
pub const ModifyNameResponse = struct {
    pub const msg_id: u16 = 22158;
    pub const Name_field_number: u32 = 8;
    pub const ErrorCode_field_number: u32 = 4;
    pub const LastModifyNameTime_field_number: u32 = 12;
    pub const ModifyNameTime_field_number: u32 = 1;
};
pub const ModifySignatureRequest = struct {
    pub const msg_id: u16 = 27721;
    pub const Signature_field_number: u32 = 5;
};
pub const ModifySignatureResponse = struct {
    pub const msg_id: u16 = 22846;
    pub const Signature_field_number: u32 = 3;
    pub const ErrorCode_field_number: u32 = 2;
};
pub const ChangeHeadPhotoRequest = struct {
    pub const msg_id: u16 = 28207;
    pub const HeadPhotoId_field_number: u32 = 10;
};
pub const ChangeHeadPhotoResponse = struct {
    pub const msg_id: u16 = 22077;
    pub const HeadPhotoId_field_number: u32 = 15;
    pub const ErrorCode_field_number: u32 = 2;
};
pub const ClientBasicInfo = struct {
    pub const Platform_field_number: u32 = 1;
    pub const DeviceId_field_number: u32 = 2;
    pub const NetStatus_field_number: u32 = 3;
    pub const Model_field_number: u32 = 4;
    pub const CPU_field_number: u32 = 5;
    pub const DeviceLevel_field_number: u32 = 6;
    pub const Language_field_number: u32 = 7;
    pub const DistinctId_field_number: u32 = 8;
    pub const MacAddress_field_number: u32 = 9;
    pub const PkgId_field_number: u32 = 10;
    pub const ServerTag_field_number: u32 = 11;
    pub const SystemLanguage_field_number: u32 = 12;
    pub const OS_field_number: u32 = 13;
    pub const DeviceId2ShuShu_field_number: u32 = 14;
    pub const ScreenHeight_field_number: u32 = 15;
    pub const ScreenWidth_field_number: u32 = 16;
    pub const DeviceInfo_field_number: u32 = 17;
    pub const DriverDate_field_number: u32 = 18;
    pub const ClientVersion_field_number: u32 = 19;
    pub const OSVersion_field_number: u32 = 20;
};
pub const PlayerBasicInfoGetRequest = struct {
    pub const msg_id: u16 = 18999;
    pub const Id_field_number: u32 = 2;
};
pub const PlayerBasicInfoGetResponse = struct {
    pub const msg_id: u16 = 27753;
    pub const Info_field_number: u32 = 11;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const BirthdayInitRequest = struct {
    pub const msg_id: u16 = 17909;
    pub const Birthday_field_number: u32 = 8;
};
pub const BirthdayInitResponse = struct {
    pub const msg_id: u16 = 17137;
    pub const ErrorCode_field_number: u32 = 12;
};
pub const RoleShowListUpdateRequest = struct {
    pub const msg_id: u16 = 16952;
    pub const RoleList_field_number: u32 = 8;
};
pub const RoleShowListUpdateResponse = struct {
    pub const msg_id: u16 = 17207;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const ChangeCardRequest = struct {
    pub const msg_id: u16 = 26472;
    pub const CardId_field_number: u32 = 8;
};
pub const ChangeCardResponse = struct {
    pub const msg_id: u16 = 29217;
    pub const ErrorCode_field_number: u32 = 8;
};
pub const ReadCardRequest = struct {
    pub const msg_id: u16 = 15863;
    pub const CardId_field_number: u32 = 10;
};
pub const ReadCardResponse = struct {
    pub const msg_id: u16 = 22941;
    pub const ErrorCode_field_number: u32 = 14;
};
pub const BirthdayShowSetRequest = struct {
    pub const msg_id: u16 = 28857;
    pub const DisPlay_field_number: u32 = 14;
};
pub const BirthdayShowSetResponse = struct {
    pub const msg_id: u16 = 24192;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const PlayerNameUpdateNotify = struct {
    pub const msg_id: u16 = 17076;
    pub const Name_field_number: u32 = 10;
    pub const LastModifyNameTime_field_number: u32 = 3;
};
pub const UpdatePlayStationBlockAccountRequest = struct {
    pub const msg_id: u16 = 17068;
    pub const BlockedIds_field_number: u32 = 14;
};
pub const UpdatePlayStationBlockAccountResponse = struct {
    pub const msg_id: u16 = 16611;
};
pub const PlayerHeadDataRequest = struct {
    pub const msg_id: u16 = 15090;
};
pub const PlayerHeadDataResponse = struct {
    pub const msg_id: u16 = 26481;
    pub const PlayerHeadDataIds_field_number: u32 = 11;
};
pub const WebSignRequest = struct {
    pub const msg_id: u16 = 20272;
};
pub const WebSignResponse = struct {
    pub const msg_id: u16 = 15812;
    pub const NoticeSign_field_number: u32 = 11;
};
pub const StorageInfoNotify = struct {
    pub const msg_id: u16 = 22882;
    pub const Infos_field_number: u32 = 14;
};
pub const StorageInfoUpdateNotify = struct {
    pub const msg_id: u16 = 19726;
    pub const Adds_field_number: u32 = 1;
    pub const Updates_field_number: u32 = 13;
    pub const Removes_field_number: u32 = 5;
};
pub const StorageInfoRequest = struct {
    pub const msg_id: u16 = 24737;
};
pub const StorageInfoResponse = struct {
    pub const msg_id: u16 = 19447;
    pub const Infos_field_number: u32 = 4;
};
pub const StorageInfoUpdateRequest = struct {
    pub const msg_id: u16 = 27208;
    pub const Infos_field_number: u32 = 3;
};
pub const StorageInfoUpdateResponse = struct {
    pub const msg_id: u16 = 15680;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const ClientStorageInfo = struct {
    Data: ?union(enum) {
    } = null,
    pub const MapMapData_field_number: u32 = 3;
    pub const MapListData_field_number: u32 = 4;
    pub const MapData_field_number: u32 = 5;
    pub const ListData_field_number: u32 = 6;
    pub const SetData_field_number: u32 = 7;
    pub const BoolData_field_number: u32 = 8;
    pub const IntData_field_number: u32 = 9;
    pub const LongData_field_number: u32 = 10;
    pub const StringData_field_number: u32 = 11;
    pub const SystemId_field_number: u32 = 1;
};
pub const ClientStorageMapData = struct {
    pub const Data_field_number: u32 = 1;
};
pub const ClientStorageMapMapData = struct {
    pub const Data_field_number: u32 = 1;
};
pub const ClientStorageMapListData = struct {
    pub const Data_field_number: u32 = 1;
};
pub const ClientStorageListData = struct {
    pub const Data_field_number: u32 = 1;
};
pub const ClientStorageSetData = struct {
    pub const Data_field_number: u32 = 1;
};
pub const ClientStorageBoolData = struct {
    pub const Data_field_number: u32 = 1;
};
pub const ClientStorageIntData = struct {
    pub const Data_field_number: u32 = 1;
};
pub const ClientStorageLongData = struct {
    pub const Data_field_number: u32 = 1;
};
pub const ClientStorageStringData = struct {
    pub const Data_field_number: u32 = 1;
};
pub const PlayerXboxBlockListRequest = struct {
    pub const msg_id: u16 = 22114;
    pub const XboxAccountIds_field_number: u32 = 10;
};
pub const PlayerXboxBlockListResponse = struct {
    pub const msg_id: u16 = 25592;
};
pub const RoleVoice = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const VoiceId_field_number: u32 = 2;
};
pub const PlayerVoiceLanguageRequest = struct {
    pub const msg_id: u16 = 20779;
};
pub const PlayerVoiceLanguageResponse = struct {
    pub const msg_id: u16 = 26822;
    pub const ErrorCode_field_number: u32 = 10;
    pub const RoleVoices_field_number: u32 = 15;
};
pub const RoleVoiceSetting = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const VoiceLanguage_field_number: u32 = 2;
};
pub const PlayerRoleVoiceSetRequest = struct {
    pub const msg_id: u16 = 15648;
    pub const RoleVoices_field_number: u32 = 7;
};
pub const PlayerRoleVoiceSetResponse = struct {
    pub const msg_id: u16 = 29893;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const PlayerAttr = struct {
    Value: ?union(enum) {
    } = null,
    pub const Int32Value_field_number: u32 = 3;
    pub const StringValue_field_number: u32 = 4;
    pub const Key_field_number: u32 = 1;
    pub const ValueType_field_number: u32 = 2;
};
pub const PlayerAttrNotify = struct {
    pub const msg_id: u16 = 25010;
    pub const Attributes_field_number: u32 = 2;
};
pub const MingSuGenInfo = struct {
    pub const CreatureGenId_field_number: u32 = 1;
};
pub const DragonPoolInfo = struct {
    pub const DragonPoolId_field_number: u32 = 1;
    pub const ActiveStatus_field_number: u32 = 3;
    pub const Level_field_number: u32 = 4;
    pub const InjectedCoreItemCount_field_number: u32 = 5;
};
pub const ItemEntry = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const ItemCount_field_number: u32 = 2;
};
pub const ItemDict = struct {
    pub const Items_field_number: u32 = 1;
};
pub const DragonPoolDropItems = struct {
    pub const DragonPoolId_field_number: u32 = 1;
    pub const DropIds_field_number: u32 = 2;
    pub const DropItems_field_number: u32 = 3;
};
pub const DarkCoastDeliveryRequest = struct {
    pub const msg_id: u16 = 22572;
    pub const DragonPoolId_field_number: u32 = 14;
};
pub const DarkCoastDeliveryResponse = struct {
    pub const msg_id: u16 = 25351;
    pub const ErrorCode_field_number: u32 = 1;
    pub const DragonPoolDropItems_field_number: u32 = 4;
    pub const DefeatedGuard_field_number: u32 = 12;
    pub const ReceivedGuardReward_field_number: u32 = 13;
    pub const LevelGain_field_number: u32 = 9;
};
pub const TransferContextId = struct {
    pub const BulletContextId_field_number: u32 = 1;
};
pub const PbBattlePassReward = struct {
    pub const Level_field_number: u32 = 1;
    pub const ItemId_field_number: u32 = 2;
    pub const Type_field_number: u32 = 3;
};
pub const PbBattlePassRecurringReward = struct {
    pub const Type_field_number: u32 = 1;
    pub const ItemId_field_number: u32 = 2;
    pub const Count_field_number: u32 = 3;
};
pub const PbBattlePass = struct {
    pub const InTimeRange_field_number: u32 = 1;
    pub const Id_field_number: u32 = 2;
    pub const Level_field_number: u32 = 3;
    pub const Exp_field_number: u32 = 4;
    pub const WeeklyTotalExp_field_number: u32 = 5;
    pub const PayStatus_field_number: u32 = 6;
    pub const TakenRewards_field_number: u32 = 7;
    pub const BeginTime_field_number: u32 = 8;
    pub const EndTime_field_number: u32 = 9;
    pub const RecurringRewards_field_number: u32 = 10;
    pub const HadEnter_field_number: u32 = 11;
};
pub const BattlePassRequest = struct {
    pub const msg_id: u16 = 20218;
};
pub const BattlePassResponse = struct {
    pub const msg_id: u16 = 19513;
    pub const BattlePass_field_number: u32 = 1;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const NodeInfo = struct {
    ExtraInfo: ?union(enum) {
    } = null,
    pub const ChildQuestNodeInfo_field_number: u32 = 2;
    pub const Status_field_number: u32 = 1;
};
pub const TreeInfo = struct {
    pub const TreeOwnerId_field_number: u32 = 1;
    pub const TreeIncId_field_number: u32 = 2;
    pub const BtType_field_number: u32 = 3;
    pub const BlackboardId_field_number: u32 = 4;
    pub const Nodes_field_number: u32 = 5;
    pub const Vars_field_number: u32 = 6;
    pub const TimerInfos_field_number: u32 = 7;
    pub const SuspendType_field_number: u32 = 8;
    pub const OccupationInfo_field_number: u32 = 9;
    pub const AudioState_field_number: u32 = 10;
    pub const IsScreenOccupy_field_number: u32 = 11;
    pub const CharacterLookAtInfos_field_number: u32 = 12;
    pub const SuspendNodeId_field_number: u32 = 13;
};
pub const BehaviorTreeInfoNotify = struct {
    pub const msg_id: u16 = 23728;
    pub const TreeInfos_field_number: u32 = 10;
};
pub const BehaviorTreeDeleteNotify = struct {
    pub const msg_id: u16 = 27135;
    pub const TreeIncIds_field_number: u32 = 9;
};
pub const ChildQuestNodeProgress = struct {
    Progress: ?union(enum) {
    } = null,
    pub const Kill_field_number: u32 = 1;
    pub const GetItem_field_number: u32 = 2;
    pub const MonsterCreator_field_number: u32 = 3;
    pub const UseItem_field_number: u32 = 4;
    pub const levelPlayCount_field_number: u32 = 5;
    pub const Interact_field_number: u32 = 6;
    pub const CompleteInst_field_number: u32 = 7;
    pub const EntityStateList_field_number: u32 = 8;
    pub const GpuMonster_field_number: u32 = 9;
};
pub const GpuMonsterProgress = struct {
    pub const CurKillNum_field_number: u32 = 1;
};
pub const EntityStateProgress = struct {
    pub const EntityId_field_number: u32 = 1;
};
pub const ChildQuestNodeInfo = struct {
    pub const Status_field_number: u32 = 1;
    pub const Progress_field_number: u32 = 2;
};
pub const KillProgress = struct {
    pub const MonId_field_number: u32 = 1;
    pub const PrefabNum_field_number: u32 = 2;
    pub const CurrNum_field_number: u32 = 3;
    pub const TotalNum_field_number: u32 = 4;
};
pub const InteractProgress = struct {
    pub const NpcId_field_number: u32 = 1;
};
pub const GetItemProgress = struct {
    pub const Info_field_number: u32 = 1;
};
pub const GetItemCount = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
};
pub const SceneMonsterCreatedMonsterInfo = struct {
    pub const PrefabId_field_number: u32 = 1;
    pub const MapId_field_number: u32 = 2;
    pub const BaseLife_field_number: u32 = 3;
    pub const State_field_number: u32 = 4;
};
pub const MonsterCreatorProgress = struct {
    pub const Slots_field_number: u32 = 1;
    pub const TotalNum_field_number: u32 = 2;
};
pub const MonsterCreatorProgressSlot = struct {
    pub const WaveId_field_number: u32 = 1;
    pub const KillMonIds_field_number: u32 = 2;
    pub const CurrentWaveEndTime_field_number: u32 = 3;
    pub const SpawnStepType_field_number: u32 = 4;
    pub const CreatorEntityConfigId_field_number: u32 = 5;
    pub const MonsterInfo_field_number: u32 = 6;
};
pub const UseItemProgress = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
};
pub const CompleteInstProgress = struct {
    pub const InstId_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
};
pub const UpdateNodeProgressNotify = struct {
    pub const msg_id: u16 = 26566;
    pub const TreeOwnerId_field_number: u32 = 12;
    pub const TreeIncId_field_number: u32 = 15;
    pub const NodeId_field_number: u32 = 14;
    pub const Progress_field_number: u32 = 8;
};
pub const UpdateChildQuestNodeStatusNotify = struct {
    pub const msg_id: u16 = 21167;
    pub const TreeOwnerId_field_number: u32 = 1;
    pub const TreeIncId_field_number: u32 = 2;
    pub const NodeId_field_number: u32 = 7;
    pub const Status_field_number: u32 = 11;
};
pub const UpdateNodeStatusNotify = struct {
    pub const msg_id: u16 = 20143;
    pub const TreeOwnerId_field_number: u32 = 8;
    pub const TreeIncId_field_number: u32 = 1;
    pub const NodeId_field_number: u32 = 13;
    pub const Status_field_number: u32 = 7;
};
pub const OccupationPbInfo = struct {
    pub const ResourceName_field_number: u32 = 1;
    pub const NodeId_field_number: u32 = 2;
    pub const IncId_field_number: u32 = 3;
};
pub const TimerInfoPb = struct {
    pub const TimerType_field_number: u32 = 1;
    pub const NodeId_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
    pub const PauseTime_field_number: u32 = 4;
};
pub const CharacterLookAtInfo = struct {
    TargetId: ?union(enum) {
    } = null,
    TargetPossition: ?union(enum) {
    } = null,
    pub const TargetEntityId_field_number: u32 = 3;
    pub const TargetPos_field_number: u32 = 4;
    pub const EntityId_field_number: u32 = 1;
    pub const TargetType_field_number: u32 = 2;
};
pub const FightBuffInformation = struct {
    pub const HandleId_field_number: u32 = 1;
    pub const BuffId_field_number: u32 = 2;
    pub const Level_field_number: u32 = 3;
    pub const StackCount_field_number: u32 = 4;
    pub const InstigatorId_field_number: u32 = 5;
    pub const EntityId_field_number: u32 = 6;
    pub const ApplyType_field_number: u32 = 7;
    pub const Duration_field_number: u32 = 8;
    pub const LeftDuration_field_number: u32 = 9;
    pub const Context_field_number: u32 = 10;
    pub const IsActive_field_number: u32 = 11;
    pub const ServerId_field_number: u32 = 12;
    pub const MessageId_field_number: u32 = 13;
    pub const ConfBuffId_field_number: u32 = 14;
};
pub const EntityPb = struct {
    d3s: ?union(enum) {
    } = null,
    pub const Camp_field_number: u32 = 20;
    pub const Id_field_number: u32 = 1;
    pub const ConfigId_field_number: u32 = 2;
    pub const ConfigType_field_number: u32 = 3;
    pub const EntityType_field_number: u32 = 4;
    pub const Pos_field_number: u32 = 5;
    pub const Rot_field_number: u32 = 6;
    pub const InitPos_field_number: u32 = 7;
    pub const LivingStatus_field_number: u32 = 8;
    pub const IsVisible_field_number: u32 = 9;
    pub const PlayerId_field_number: u32 = 10;
    pub const ComponentPbs_field_number: u32 = 11;
    pub const DurabilityValue_field_number: u32 = 12;
    pub const EntityState_field_number: u32 = 13;
    pub const InitLinearVelocity_field_number: u32 = 14;
    pub const IsPosAbnormal_field_number: u32 = 15;
    pub const PrefabId_field_number: u32 = 17;
    pub const PrefabIncId_field_number: u32 = 18;
    pub const SubEntityType_field_number: u32 = 19;
    pub const OwnerIncId_field_number: u32 = 21;
    pub const Gravity_field_number: u32 = 22;
    pub const RoleSkinId_field_number: u32 = 23;
    pub const IsActorVisible_field_number: u32 = 24;
    pub const SoarWingSkinId_field_number: u32 = 25;
    pub const ParaglidingSkinId_field_number: u32 = 26;
    pub const IsSnapLocation_field_number: u32 = 27;
    pub const ClientHiddenFlag_field_number: u32 = 28;
};
pub const EntityComponentPb = struct {
    ComponentPb: ?union(enum) {
    } = null,
    pub const AttributeComponent_field_number: u32 = 1;
    pub const TagComponent_field_number: u32 = 2;
    pub const TriggerComponent_field_number: u32 = 3;
    pub const SummonerComponent_field_number: u32 = 4;
    pub const PartComponent_field_number: u32 = 5;
    pub const VisionSkillComponent_field_number: u32 = 6;
    pub const AnimationStateComponent_field_number: u32 = 7;
    pub const BlackboardParamComponent_field_number: u32 = 8;
    pub const SysBuffComponent_field_number: u32 = 10;
    pub const ClientDataComponent_field_number: u32 = 11;
    pub const MonsterWeaponComponentPb_field_number: u32 = 12;
    pub const MonsterAiComponentPb_field_number: u32 = 13;
    pub const FightBuffComponent_field_number: u32 = 15;
    pub const NearbyTrackingComponentPb_field_number: u32 = 16;
    pub const DropComponentPb_field_number: u32 = 17;
    pub const MonsterCaptureComponent_field_number: u32 = 18;
    pub const LogicStateComponentPb_field_number: u32 = 19;
    pub const AdviceComponentPb_field_number: u32 = 20;
    pub const LiftComponentPb_field_number: u32 = 21;
    pub const InteractComponent_field_number: u32 = 22;
    pub const EquipComponent_field_number: u32 = 23;
    pub const BeControlledComponentPb_field_number: u32 = 24;
    pub const ConcomitantsComponentPb_field_number: u32 = 25;
    pub const TimelineTrackComponentPb_field_number: u32 = 26;
    pub const SummonsComponentPb_field_number: u32 = 27;
    pub const EntityFsmComponentPb_field_number: u32 = 28;
    pub const BoardPb_field_number: u32 = 29;
    pub const PlacementItemPb_field_number: u32 = 30;
    pub const StateTagComponentPb_field_number: u32 = 31;
    pub const MonsterGachaDataPb_field_number: u32 = 32;
    pub const FanComponentPb_field_number: u32 = 33;
    pub const NpcPb_field_number: u32 = 34;
    pub const BubbleComponent_field_number: u32 = 35;
    pub const PatrolComponent_field_number: u32 = 36;
    pub const RangeComponent_field_number: u32 = 37;
    pub const PassiveSkillComponentPb_field_number: u32 = 38;
    pub const PassiveGaSkillComponentPb_field_number: u32 = 39;
    pub const DynAttachComponentPb_field_number: u32 = 40;
    pub const EntityVarComponentPb_field_number: u32 = 41;
    pub const FollowShooterComponentPb_field_number: u32 = 42;
    pub const StateComponentPb_field_number: u32 = 43;
    pub const BulletComponentPb_field_number: u32 = 44;
    pub const BuffProducerComponentPb_field_number: u32 = 45;
    pub const BuffConsumerComponentPb_field_number: u32 = 46;
    pub const SceneItemComponentPb_field_number: u32 = 47;
    pub const ShieldComponentPb_field_number: u32 = 48;
    pub const NPCPerformGroupComponentPb_field_number: u32 = 49;
    pub const PlayerSceneComponentPb_field_number: u32 = 50;
    pub const JigsawBaseComponentPb_field_number: u32 = 51;
    pub const RoleRecordComponentPb_field_number: u32 = 52;
    pub const FollowerComponentPb_field_number: u32 = 53;
    pub const AttributesIdsComponentPb_field_number: u32 = 54;
    pub const PullingFoundationComponentPb_field_number: u32 = 55;
    pub const BatchBulletCastComponentPb_field_number: u32 = 56;
    pub const WeaponSkinComponentPb_field_number: u32 = 57;
    pub const CharacterAttachComponentPb_field_number: u32 = 58;
    pub const PatrolInfoComponentPb_field_number: u32 = 59;
    pub const AnimalPerformComponentPb_field_number: u32 = 60;
    pub const NpcDriveVehicleComponentPb_field_number: u32 = 61;
    pub const GrapplingHookPointComponentPb_field_number: u32 = 62;
    pub const HackingComponentPb_field_number: u32 = 63;
    pub const HackTargetComponentPb_field_number: u32 = 64;
    pub const GravityFlipComponent_field_number: u32 = 65;
    pub const EntityMoveSplineComponentPb_field_number: u32 = 66;
    pub const EntityRewardItemPb_field_number: u32 = 67;
    pub const TemplateEntitySpawnerComponentPb_field_number: u32 = 68;
    pub const GridObjectComponentPb_field_number: u32 = 69;
    pub const SimpleCombatComponentPb_field_number: u32 = 70;
    pub const TrapDefenseComponentPb_field_number: u32 = 71;
    pub const HoldHandComponentPb_field_number: u32 = 72;
    pub const SceneItemEventListenerComponentPb_field_number: u32 = 73;
    pub const ActivityComponentPb_field_number: u32 = 74;
    pub const CalabashSkinComponentPb_field_number: u32 = 75;
    pub const HonamiStoryDropItemComponentPb_field_number: u32 = 76;
    pub const HonamiStoryEnhanceLevelComponentPb_field_number: u32 = 77;
    pub const MoveToPointComponentPb_field_number: u32 = 78;
    pub const RbBlockComponentPb_field_number: u32 = 79;
    pub const SpiritGearComponentPb_field_number: u32 = 80;
    pub const VehiclePb_field_number: u32 = 81;
    pub const RbFloorComponentPb_field_number: u32 = 82;
    pub const RbItemComponentPb_field_number: u32 = 83;
    pub const RoadNetworkComponentPb_field_number: u32 = 84;
    pub const FollowEntityComponentPb_field_number: u32 = 85;
    pub const MotorOutlookComponentPb_field_number: u32 = 86;
    pub const MotorDaCtxComponentPb_field_number: u32 = 87;
    pub const ExhibitionComponentPb_field_number: u32 = 88;
    pub const FurnitureComponentPb_field_number: u32 = 89;
    pub const OrnamentComponentPb_field_number: u32 = 90;
    pub const FlowerPollutionComponentPb_field_number: u32 = 91;
    pub const DollGrabMachineComponentPb_field_number: u32 = 92;
    pub const DollGrabShowcaseComponentPb_field_number: u32 = 93;
    pub const GpuEntityComponentPb_field_number: u32 = 94;
    pub const RoverRoguePortalComponentPb_field_number: u32 = 95;
};
pub const RoverRoguePortalComponentPb = struct {
    pub const RewardType_field_number: u32 = 1;
    pub const BlessRoleId_field_number: u32 = 2;
};
pub const MotorDaCtxComponentPb = struct {
    pub const MotorDaCtxId_field_number: u32 = 1;
};
pub const MonsterAiComponentPb = struct {
    pub const WeaponId_field_number: u32 = 1;
    pub const HatredGroupId_field_number: u32 = 2;
    pub const AiTeamInitId_field_number: u32 = 3;
    pub const CombatMessageId_field_number: u32 = 4;
    pub const BasicPerceptionIds_field_number: u32 = 5;
    pub const HatredId_field_number: u32 = 6;
};
pub const MonsterWeaponComponentPb = struct {
    pub const WeaponId_field_number: u32 = 1;
};
pub const BatchBulletCastComponentPb = struct {
    pub const ConstateId_field_number: u32 = 1;
};
pub const RangeComponentPb = struct {
    pub const InRangePlayers_field_number: u32 = 1;
    pub const InRangeEntities_field_number: u32 = 2;
};
pub const ClientDataComponentPb = struct {
    pub const IsStaticInit_field_number: u32 = 1;
    pub const OwnerId_field_number: u32 = 2;
    pub const GroupId_field_number: u32 = 3;
};
pub const AttributeComponentPb = struct {
    pub const HardnessModeId_field_number: u32 = 2;
    pub const RageModeId_field_number: u32 = 3;
    pub const AttrData_field_number: u32 = 4;
};
pub const TagComponentPb = struct {
    pub const GameplayTags_field_number: u32 = 1;
    pub const EntityCommonTags_field_number: u32 = 2;
    pub const InitGameplayTag_field_number: u32 = 3;
};
pub const TriggerComponentPb = struct {
    pub const TriggerCount_field_number: u32 = 1;
    pub const ExitTriggerCount_field_number: u32 = 2;
    pub const ConstateId_field_number: u32 = 3;
};
pub const StateTagComponentPb = struct {
    pub const StateTagId_field_number: u32 = 1;
};
pub const VisionSkillComponentPb = struct {
    pub const VisionSkillInfos_field_number: u32 = 1;
    pub const PhantomSkillInfo_field_number: u32 = 2;
};
pub const EntityVarComponentPb = struct {
    pub const Vars_field_number: u32 = 1;
};
pub const BoneVisibleData = struct {
    pub const BoneName_field_number: u32 = 1;
    pub const HideBone_field_number: u32 = 2;
};
pub const AnimationStateComponentPb = struct {
    pub const AnimationStates_field_number: u32 = 1;
    pub const SpecialStates_field_number: u32 = 2;
    pub const BoneVisibleDatas_field_number: u32 = 3;
    pub const AnimationTags_field_number: u32 = 4;
    pub const ModelId_field_number: u32 = 5;
};
pub const LogicStateComponentPb = struct {
    pub const PositionState_field_number: u32 = 1;
    pub const MoveState_field_number: u32 = 2;
    pub const DirectionState_field_number: u32 = 3;
    pub const PositionSubState_field_number: u32 = 4;
};
pub const LiftComponentPb = struct {
    pub const Location_field_number: u32 = 1;
};
pub const BlackboardParamComponentPb = struct {
    pub const BlackboardParams_field_number: u32 = 1;
};
pub const SysBuffComponentPb = struct {
    pub const SysBuffInfos_field_number: u32 = 1;
};
pub const SysBuffInformation = struct {
    pub const ServerId_field_number: u32 = 1;
    pub const BuffId_field_number: u32 = 2;
    pub const Level_field_number: u32 = 3;
    pub const MessageId_field_number: u32 = 4;
    pub const InstigatorId_field_number: u32 = 5;
    pub const Duration_field_number: u32 = 6;
    pub const StackCount_field_number: u32 = 7;
    pub const ApplyType_field_number: u32 = 8;
    pub const IsIterable_field_number: u32 = 9;
};
pub const FightBuffComponentPb = struct {
    pub const FightBuffInfos_field_number: u32 = 1;
    pub const ListBuffEffectCd_field_number: u32 = 2;
    pub const ClientBornBuffIds_field_number: u32 = 3;
    pub const ClientBornMessageId_field_number: u32 = 4;
};
pub const NearbyTrackingComponentPb = struct {
    pub const IsEnable_field_number: u32 = 1;
};
pub const DropComponentPb = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const ShowPlanId_field_number: u32 = 2;
    pub const ItemCount_field_number: u32 = 3;
    pub const EntityConfigId_field_number: u32 = 4;
};
pub const MonsterCaptureComponentPb = struct {
    pub const TemplateId_field_number: u32 = 1;
    pub const EntityId_field_number: u32 = 2;
    pub const MonsterId_field_number: u32 = 3;
};
pub const BubbleInfo = struct {
    pub const ActionGuid_field_number: u32 = 1;
    pub const GameCtx_field_number: u32 = 2;
};
pub const BubbleComponentPb = struct {
    pub const BubbleInfos_field_number: u32 = 1;
};
pub const RoleRecordComponentPb = struct {
    pub const IsAutoRole_field_number: u32 = 1;
    pub const ConstateId_field_number: u32 = 2;
};
pub const DynamicInteractInfo = struct {
    pub const OptionGuid_field_number: u32 = 1;
    pub const GameCtx_field_number: u32 = 2;
    pub const Text_field_number: u32 = 3;
    pub const DelayRemove_field_number: u32 = 4;
};
pub const InteractComponentPb = struct {
    pub const DynamicInteractInfos_field_number: u32 = 1;
    pub const RandomInteractIndex_field_number: u32 = 2;
    pub const Interacting_field_number: u32 = 3;
};
pub const SceneItemComponentPb = struct {
    pub const PosSender_field_number: u32 = 1;
    pub const BlackBoards_field_number: u32 = 2;
};
pub const BeControlledComponentPb = struct {
    pub const PlayerEntityId_field_number: u32 = 1;
    pub const RelationId_field_number: u32 = 2;
    pub const IsShow_field_number: u32 = 3;
    pub const MatchIndex_field_number: u32 = 4;
    pub const ConstateId_field_number: u32 = 5;
};
pub const PullingFoundationComponentPb = struct {
    pub const RelationId_field_number: u32 = 1;
    pub const MatchIndex_field_number: u32 = 2;
};
pub const DynAttachComponentPb = struct {
    pub const PbDynAttachEntityConfigId_field_number: u32 = 1;
    pub const PbDynAttachEntityActorKey_field_number: u32 = 2;
    pub const Pos_field_number: u32 = 3;
    pub const Rot_field_number: u32 = 4;
    pub const PbDynAttachRefActorKey_field_number: u32 = 5;
};
pub const ConcomitantsComponentPb = struct {
    pub const VisionEntityId_field_number: u32 = 1;
    pub const CustomEntityIds_field_number: u32 = 2;
    pub const PhantomRoleId_field_number: u32 = 3;
    pub const BossRushId_field_number: u32 = 4;
};
pub const FollowEntityComponentPb = struct {
    pub const EntityId_field_number: u32 = 1;
};
pub const TimelineTrackControlDataPb = struct {
    pub const ControlPoint_field_number: u32 = 1;
};
pub const TimelineTrackComponentPb = struct {
    pub const Index_field_number: u32 = 1;
    pub const ControlDatas_field_number: u32 = 2;
};
pub const BoardPb = struct {
    pub const OccupiedGridList_field_number: u32 = 1;
    pub const DynamicGridConfigs_field_number: u32 = 2;
    pub const CanMove_field_number: u32 = 3;
};
pub const CrystalMonsterSlotInfo = struct {
    pub const EntityIds_field_number: u32 = 1;
    pub const MonsterType_field_number: u32 = 2;
};
pub const CrystalMonsterInfoPb = struct {
    pub const SlotInfoList_field_number: u32 = 1;
};
pub const MonsterGachaDataPb = struct {
    pub const MonsterCrystalInfoList_field_number: u32 = 1;
};
pub const FanComponentPb = struct {
    pub const NumOfTurns_field_number: u32 = 1;
};
pub const PassiveSkillItemPb = struct {
    pub const CombatCommon_field_number: u32 = 1;
    pub const SkillId_field_number: u32 = 2;
};
pub const PassiveSkillComponentPb = struct {
    pub const PassiveSkillItemPbList_field_number: u32 = 1;
};
pub const CharacterSkillComponentPb = struct {
    pub const UseSkillInfo_field_number: u32 = 1;
    pub const MontageIndex_field_number: u32 = 2;
    pub const MontagePlayTime_field_number: u32 = 3;
    pub const Section_field_number: u32 = 4;
    pub const SpeedRatio_field_number: u32 = 5;
    pub const MessageId_field_number: u32 = 6;
    pub const MontageContext_field_number: u32 = 7;
};
pub const SkillComponentPb = struct {
    pub const SkillId_field_number: u32 = 1;
    pub const ConstateId_field_number: u32 = 2;
};
pub const PassiveGaSkillComponentPb = struct {
    pub const SkillInfoList_field_number: u32 = 1;
    pub const SkillComponentPb_field_number: u32 = 2;
};
pub const UseSkillInformation = struct {
    pub const CombatCommon_field_number: u32 = 1;
    pub const Id_field_number: u32 = 2;
    pub const SkillId_field_number: u32 = 3;
    pub const MovementInformation_field_number: u32 = 4;
    pub const Location_field_number: u32 = 5;
    pub const TargetId_field_number: u32 = 6;
    pub const TimeStamp_field_number: u32 = 7;
    pub const IsSpecialSkill_field_number: u32 = 8;
    pub const Duration_field_number: u32 = 9;
    pub const SkillInterruptLevel_field_number: u32 = 10;
    pub const FightState_field_number: u32 = 11;
};
pub const StateComponentPb = struct {
    pub const ConstateId_field_number: u32 = 1;
};
pub const BuffProducerComponentPb = struct {
    pub const ConstateId_field_number: u32 = 1;
};
pub const BuffConsumerComponentPb = struct {
    pub const ConstateId_field_number: u32 = 1;
};
pub const SceneItemEventListenerComponentPb = struct {
    pub const ConstateId_field_number: u32 = 1;
};
pub const BulletComponentPb = struct {
    pub const ConstateId_field_number: u32 = 1;
};
pub const EntityAddNotify = struct {
    pub const msg_id: u16 = 24934;
    pub const EntityPbs_field_number: u32 = 6;
    pub const RemoveTagIds_field_number: u32 = 10;
};
pub const EntityRemoveNotify = struct {
    pub const msg_id: u16 = 23010;
    pub const RemoveInfos_field_number: u32 = 2;
    pub const IsRemove_field_number: u32 = 11;
};
pub const VarDefinePb = struct {
    Value: ?union(enum) {
    } = null,
    pub const Boolean_field_number: u32 = 2;
    pub const Int_field_number: u32 = 3;
    pub const String_field_number: u32 = 4;
    pub const Float_field_number: u32 = 5;
    pub const Entity_field_number: u32 = 6;
    pub const Quest_field_number: u32 = 7;
    pub const QuestState_field_number: u32 = 8;
    pub const Transform_field_number: u32 = 9;
    pub const Prefab_field_number: u32 = 10;
    pub const VarType_field_number: u32 = 1;
};
pub const NpcPb = struct {
    pub const SplineEntityId_field_number: u32 = 2;
    pub const SpawnEntityId_field_number: u32 = 3;
};
pub const LogicStateInitRequest = struct {
    pub const msg_id: u16 = 17932;
    pub const CombatCommon_field_number: u32 = 10;
    pub const EntityId_field_number: u32 = 15;
    pub const InitData_field_number: u32 = 3;
    pub const ClientEntityId_field_number: u32 = 2;
};
pub const LogicStateInitPush = struct {
    pub const msg_id: u16 = 27995;
    pub const CombatCommon_field_number: u32 = 8;
    pub const EntityId_field_number: u32 = 2;
    pub const InitData_field_number: u32 = 6;
    pub const ClientEntityId_field_number: u32 = 10;
};
pub const LogicStateInitResponse = struct {
    pub const msg_id: u16 = 28559;
    pub const ErrorCode_field_number: u32 = 7;
};
pub const LogicStateInitNotify = struct {
    pub const msg_id: u16 = 22556;
    pub const CombatCommon_field_number: u32 = 1;
    pub const EntityId_field_number: u32 = 13;
    pub const InitData_field_number: u32 = 9;
};
pub const SwitchLogicStateRequest = struct {
    pub const msg_id: u16 = 21267;
    pub const States_field_number: u32 = 11;
    pub const ClientEntityId_field_number: u32 = 4;
};
pub const SwitchLogicStatePush = struct {
    pub const msg_id: u16 = 21298;
    pub const States_field_number: u32 = 14;
    pub const ClientEntityId_field_number: u32 = 7;
};
pub const SwitchLogicStateResponse = struct {
    pub const msg_id: u16 = 29656;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const SwitchLogicStateNotify = struct {
    pub const msg_id: u16 = 25867;
    pub const States_field_number: u32 = 2;
};
pub const EntityActiveRequest = struct {
    pub const msg_id: u16 = 29189;
    pub const EntityId_field_number: u32 = 2;
};
pub const EntityActiveResponse = struct {
    pub const msg_id: u16 = 23468;
    pub const ErrorCode_field_number: u32 = 13;
    pub const ComponentPbs_field_number: u32 = 10;
    pub const IsVisible_field_number: u32 = 4;
    pub const Pos_field_number: u32 = 1;
    pub const Rot_field_number: u32 = 8;
    pub const AiControlPlayerId_field_number: u32 = 12;
};
pub const AnimationGameplayTagRequest = struct {
    pub const msg_id: u16 = 27099;
    pub const AddTagIds_field_number: u32 = 11;
    pub const RemoveTagIds_field_number: u32 = 9;
};
pub const AnimationGameplayTagPush = struct {
    pub const msg_id: u16 = 20767;
    pub const AddTagIds_field_number: u32 = 3;
    pub const RemoveTagIds_field_number: u32 = 9;
};
pub const AnimationGameplayTagResponse = struct {
    pub const msg_id: u16 = 23411;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const AnimationGameplayTagNotify = struct {
    pub const msg_id: u16 = 16847;
    pub const AddTagIds_field_number: u32 = 1;
    pub const RemoveTagIds_field_number: u32 = 14;
};
pub const AnimalDieRequest = struct {
    pub const msg_id: u16 = 21844;
    pub const EntityId_field_number: u32 = 13;
    pub const Pos_field_number: u32 = 12;
};
pub const AnimalDieResponse = struct {
    pub const msg_id: u16 = 19423;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const AnimalDestroyRequest = struct {
    pub const msg_id: u16 = 17358;
    pub const EntityId_field_number: u32 = 14;
};
pub const AnimalDestroyResponse = struct {
    pub const msg_id: u16 = 21969;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const AnimalDropRequest = struct {
    pub const msg_id: u16 = 27703;
    pub const EntityId_field_number: u32 = 13;
};
pub const AnimalDropResponse = struct {
    pub const msg_id: u16 = 22256;
    pub const ErrorCode_field_number: u32 = 14;
};
pub const EntityStateReadyNotify = struct {
    pub const msg_id: u16 = 20256;
    pub const EntityId_field_number: u32 = 10;
    pub const TagId_field_number: u32 = 1;
    pub const Ready_field_number: u32 = 13;
};
pub const EntityInteractRequest = struct {
    pub const msg_id: u16 = 25096;
    pub const EntityId_field_number: u32 = 5;
    pub const OptionIndex_field_number: u32 = 6;
    pub const VisionEntityId_field_number: u32 = 3;
};
pub const EntityInteractResponse = struct {
    pub const msg_id: u16 = 17192;
    pub const ErrorCode_field_number: u32 = 5;
    pub const Interacting_field_number: u32 = 6;
};
pub const EntityDynamicInteractRequest = struct {
    pub const msg_id: u16 = 21019;
    pub const EntityId_field_number: u32 = 13;
    pub const OptionGuid_field_number: u32 = 2;
};
pub const EntityDynamicInteractResponse = struct {
    pub const msg_id: u16 = 26768;
    pub const ErrorCode_field_number: u32 = 14;
    pub const Interacting_field_number: u32 = 11;
};
pub const BoneVisibleChangeRequest = struct {
    pub const msg_id: u16 = 16080;
    pub const BoneVisibleData_field_number: u32 = 4;
};
pub const BoneVisibleChangePush = struct {
    pub const msg_id: u16 = 24360;
    pub const BoneVisibleData_field_number: u32 = 5;
};
pub const BoneVisibleChangeResponse = struct {
    pub const msg_id: u16 = 15448;
    pub const ErrorCode_field_number: u32 = 12;
};
pub const BoneVisibleChangeNotify = struct {
    pub const msg_id: u16 = 21869;
    pub const BoneVisibleData_field_number: u32 = 6;
};
pub const EquipComponentPb = struct {
    pub const WeaponId_field_number: u32 = 1;
    pub const WeaponBreachLevel_field_number: u32 = 2;
};
pub const WeaponSkinComponentPb = struct {
    pub const WeaponSkinId_field_number: u32 = 1;
};
pub const OrnamentComponentPb = struct {
    pub const OrnamentIds_field_number: u32 = 1;
};
pub const CharacterAttachComponentPb = struct {
    pub const PbCombinePartInfoList_field_number: u32 = 1;
    pub const PbCombineTargetServerId_field_number: u32 = 2;
};
pub const EntityEquipChangeNotify = struct {
    pub const msg_id: u16 = 29283;
    pub const EntityId_field_number: u32 = 12;
    pub const EquipComponent_field_number: u32 = 5;
};
pub const EntityEquipSkinChangeNotify = struct {
    pub const msg_id: u16 = 27386;
    pub const EntityId_field_number: u32 = 12;
    pub const WeaponSkinComponentPb_field_number: u32 = 2;
};
pub const EntityDressOrnamentChangeNotify = struct {
    pub const msg_id: u16 = 24402;
    pub const EntityId_field_number: u32 = 1;
    pub const OrnamentComponentPb_field_number: u32 = 7;
};
pub const EntityStaticHookMoveRequest = struct {
    pub const msg_id: u16 = 16855;
    Target: ?union(enum) {
    } = null,
    pub const TargetEntityId_field_number: u32 = 14;
    pub const TargetPos_field_number: u32 = 7;
    pub const EntityId_field_number: u32 = 2;
    pub const HookMoveType_field_number: u32 = 15;
};
pub const EntityStaticHookMovePush = struct {
    pub const msg_id: u16 = 26844;
    Target: ?union(enum) {
    } = null,
    pub const TargetEntityId_field_number: u32 = 6;
    pub const TargetPos_field_number: u32 = 4;
    pub const EntityId_field_number: u32 = 15;
    pub const HookMoveType_field_number: u32 = 9;
};
pub const EntityStaticHookMoveResponse = struct {
    pub const msg_id: u16 = 15900;
    pub const ErrorCode_field_number: u32 = 3;
};
pub const EntityStaticHookMoveNotify = struct {
    pub const msg_id: u16 = 29924;
    Target: ?union(enum) {
    } = null,
    pub const TargetEntityId_field_number: u32 = 13;
    pub const TargetPos_field_number: u32 = 11;
    pub const EntityId_field_number: u32 = 12;
    pub const HookMoveType_field_number: u32 = 6;
};
pub const SilenceNpcNotify = struct {
    pub const msg_id: u16 = 22123;
    pub const vTs_field_number: u32 = 1;
};
pub const EntityPatrolStopRequest = struct {
    pub const msg_id: u16 = 22837;
    pub const EntityId_field_number: u32 = 12;
};
pub const EntityPatrolStopResponse = struct {
    pub const msg_id: u16 = 27586;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const PatrolComponentPb = struct {
    pub const Dir_field_number: u32 = 1;
};
pub const FlowerPollutionComponentPb = struct {
    pub const UnPollutionSpline_field_number: u32 = 1;
};
pub const DollGrabMachineComponentPb = struct {
    pub const CanCapturedItems_field_number: u32 = 1;
    pub const HighScore_field_number: u32 = 2;
    pub const AccumulatedScore_field_number: u32 = 3;
};
pub const DollGrabShowcaseComponentPb = struct {
    pub const DollItems_field_number: u32 = 1;
};
pub const DollSmallMapInfoRequest = struct {
    pub const msg_id: u16 = 28182;
};
pub const DollSmallMapInfoResponse = struct {
    pub const msg_id: u16 = 29935;
    pub const ErrorCode_field_number: u32 = 9;
    pub const SceneUnlimitedScoreInfos_field_number: u32 = 11;
    pub const SceneDollDeliveryInfos_field_number: u32 = 14;
};
pub const SceneUnlimitedScoreInfo = struct {
    pub const instId_field_number: u32 = 1;
    pub const UnlimitedScoreInfos_field_number: u32 = 2;
};
pub const UnlimitedScoreInfo = struct {
    pub const entityId_field_number: u32 = 1;
    pub const HighestScore_field_number: u32 = 2;
    pub const AccumulatedScore_field_number: u32 = 3;
};
pub const SceneDollDeliveryInfo = struct {
    pub const instId_field_number: u32 = 1;
    pub const DollDeliveryInfos_field_number: u32 = 2;
};
pub const DollDeliveryInfo = struct {
    pub const ShowcaseEntityId_field_number: u32 = 1;
    pub const DeliveredDolls_field_number: u32 = 2;
};
pub const EntityPositionRequest = struct {
    pub const msg_id: u16 = 27346;
    pub const ConfigId_field_number: u32 = 5;
    pub const DungeonInstanceId_field_number: u32 = 12;
};
pub const EntityPositionResponse = struct {
    pub const msg_id: u16 = 20311;
    pub const ErrorCode_field_number: u32 = 13;
    pub const Pos_field_number: u32 = 9;
};
pub const ShieldInfoPb = struct {
    pub const Handle_field_number: u32 = 1;
    pub const ConfigId_field_number: u32 = 2;
    pub const ShieldValue_field_number: u32 = 3;
    pub const Priority_field_number: u32 = 4;
    pub const BuffHandle_field_number: u32 = 5;
    pub const IsValid_field_number: u32 = 6;
};
pub const ShieldComponentPb = struct {
    pub const ShieldInfoPbList_field_number: u32 = 1;
    pub const ShieldValueTotal_field_number: u32 = 2;
};
pub const NPCPerformGroupComponentPb = struct {
    pub const Type_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const PlayerSceneComponentPb = struct {
    pub const EntityIds_field_number: u32 = 1;
};
pub const AttributesIdsComponentPb = struct {
    pub const PbSceneItemAttributeIds_field_number: u32 = 1;
};
pub const VehicleManipulateRequest = struct {
    pub const msg_id: u16 = 29131;
    Exit: ?union(enum) {
    } = null,
    pub const ExitType_field_number: u32 = 10;
    pub const EntityId_field_number: u32 = 13;
    pub const HostPlayerId_field_number: u32 = 4;
    pub const IsEntering_field_number: u32 = 2;
    pub const Seat_field_number: u32 = 15;
    pub const ClientPredicted_field_number: u32 = 11;
    pub const ReasonMsg_field_number: u32 = 14;
};
pub const VehicleManipulateResponse = struct {
    pub const msg_id: u16 = 26229;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const VehicleFinishRequest = struct {
    pub const msg_id: u16 = 22362;
    pub const EntityId_field_number: u32 = 9;
};
pub const VehicleFinishResponse = struct {
    pub const msg_id: u16 = 24967;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const EntityEnterVehicleRequest = struct {
    pub const msg_id: u16 = 16496;
    Exit: ?union(enum) {
    } = null,
    pub const ExitType_field_number: u32 = 5;
    pub const EntityId_field_number: u32 = 2;
    pub const VehicleCreatureId_field_number: u32 = 10;
    pub const HostPlayerId_field_number: u32 = 8;
    pub const IsEntering_field_number: u32 = 11;
    pub const Seat_field_number: u32 = 4;
    pub const ClientPredicted_field_number: u32 = 14;
    pub const ReasonMsg_field_number: u32 = 13;
};
pub const EntityEnterVehicleResponse = struct {
    pub const msg_id: u16 = 20762;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const VehicleUpdateEntityNotify = struct {
    pub const msg_id: u16 = 22121;
    pub const EntityId_field_number: u32 = 10;
    pub const VehicleCreatureId_field_number: u32 = 5;
    pub const Seat_field_number: u32 = 7;
    pub const IsEntering_field_number: u32 = 6;
    pub const ExitType_field_number: u32 = 13;
    pub const ClientPredicted_field_number: u32 = 2;
};
pub const VehiclePlayerData = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const Seat_field_number: u32 = 2;
};
pub const ChangeVehicleRideSharingRequest = struct {
    pub const msg_id: u16 = 19111;
    pub const RoleId_field_number: u32 = 14;
    pub const Seat_field_number: u32 = 10;
};
pub const ChangeVehicleRideSharingResponse = struct {
    pub const msg_id: u16 = 18705;
    pub const ErrorCode_field_number: u32 = 14;
};
pub const RemoveRideSharingPassengerRequest = struct {
    pub const msg_id: u16 = 27695;
    pub const RoleId_field_number: u32 = 12;
};
pub const RemoveRideSharingPassengerResponse = struct {
    pub const msg_id: u16 = 28336;
    pub const ErrorCode_field_number: u32 = 5;
};
pub const UpdateVehicleRideSharingNotify = struct {
    pub const msg_id: u16 = 29293;
    pub const PlayerId_field_number: u32 = 13;
    pub const RoleId_field_number: u32 = 6;
    pub const Seat_field_number: u32 = 5;
    pub const EntityId_field_number: u32 = 2;
};
pub const SendMovieModeRideSharingRequest = struct {
    pub const msg_id: u16 = 17464;
    pub const IsInMovieRideSharingMode_field_number: u32 = 14;
    pub const ShareRideMode_field_number: u32 = 11;
};
pub const SendMovieModeRideSharingResponse = struct {
    pub const msg_id: u16 = 29870;
    pub const ErrorCode_field_number: u32 = 2;
};
pub const VehicleShareNotify = struct {
    pub const msg_id: u16 = 16414;
    pub const PlayerId_field_number: u32 = 10;
    pub const ShareRideMode_field_number: u32 = 9;
    pub const IsInMovieRideSharingMode_field_number: u32 = 1;
    pub const Reason_field_number: u32 = 5;
};
pub const PatrolInfoComponentPb = struct {
    pub const SceneAiEnabled_field_number: u32 = 1;
    pub const PatrolInfo_field_number: u32 = 2;
};
pub const PatrolInfoPb = struct {
    Data: ?union(enum) {
    } = null,
    pub const SmartObjectComponent_field_number: u32 = 1;
};
pub const SmartObjectComponent = struct {
    pub const LastPassIndex_field_number: u32 = 1;
};
pub const AnimalPerformComponentPb = struct {
    pub const AnimalInitialPartIds_field_number: u32 = 1;
};
pub const NpcDriveVehicleComponentPb = struct {
    pub const VehicleCreatureId_field_number: u32 = 1;
    pub const Seat_field_number: u32 = 2;
};
pub const GrapplingHookPointComponentPb = struct {
    pub const HookLockPointDisabled_field_number: u32 = 1;
};
pub const MoveToPointComponentPb = struct {
    pub const PbMoveToPointConfig_field_number: u32 = 1;
};
pub const PbMoveToPointConfig = struct {
    pub const TargetPos_field_number: u32 = 1;
    pub const MoveType_field_number: u32 = 2;
    pub const IsExact_field_number: u32 = 3;
};
pub const EntityMoveSplineComponentPb = struct {
    RuntimeData: ?union(enum) {
    } = null,
    pub const SceneItemSplineRuntimeData_field_number: u32 = 11;
    pub const SplineEntityId_field_number: u32 = 1;
    pub const MoveSplineConfig_field_number: u32 = 2;
};
pub const MoveSplineConfig = struct {
    StartPoint: ?union(enum) {
    } = null,
    EndPoint: ?union(enum) {
    } = null,
    LookDir: ?union(enum) {
    } = null,
    Cycle: ?union(enum) {
    } = null,
    Circle: ?union(enum) {
    } = null,
    pub const StartPointIndex_field_number: u32 = 1;
    pub const EndPointIndex_field_number: u32 = 2;
    pub const IsLookDir_field_number: u32 = 3;
    pub const CycleCount_field_number: u32 = 4;
    pub const IsCircle_field_number: u32 = 5;
};
pub const SceneItemSplineRuntimeData = struct {
    Distance: ?union(enum) {
    } = null,
    Rot: ?union(enum) {
    } = null,
    pub const DistanceAlongPath_field_number: u32 = 1;
    pub const CurRot_field_number: u32 = 3;
    pub const CurPos_field_number: u32 = 2;
};
pub const TemplateEntitySpawnerComponentPb = struct {
    pub const SpawnerType_field_number: u32 = 1;
    pub const CreateEntityInfos_field_number: u32 = 2;
};
pub const GroupTypesWrapper = struct {
    pub const GroupTypes_field_number: u32 = 1;
};
pub const SpawnerEntityInfo = struct {
    Group: ?union(enum) {
    } = null,
    SpawnerSubType: ?union(enum) {
    } = null,
    pub const GroupTypes_field_number: u32 = 2;
    pub const MatrixInfo_field_number: u32 = 3;
    pub const IncId_field_number: u32 = 1;
};
pub const MatrixInfo = struct {
    pub const X_field_number: u32 = 1;
    pub const Y_field_number: u32 = 2;
};
pub const GridObjectComponentPb = struct {
    pub const InitGridPlacementPbInfo_field_number: u32 = 1;
};
pub const GridPlacementPbInfo = struct {
    GridPb: ?union(enum) {
    } = null,
    pub const Direction_field_number: u32 = 4;
    pub const ActorGuide_field_number: u32 = 1;
    pub const X_field_number: u32 = 2;
    pub const Y_field_number: u32 = 3;
};
pub const SimpleCombatComponentPb = struct {
    SplineConfig: ?union(enum) {
    } = null,
    SplineMove: ?union(enum) {
    } = null,
    pub const SplineConfigId_field_number: u32 = 3;
    pub const SplineMoveType_field_number: u32 = 7;
    pub const SubTypeId_field_number: u32 = 1;
    pub const BuffLayers_field_number: u32 = 4;
    pub const SimpleCombatEntityAttributePbInfo_field_number: u32 = 5;
    pub const LockedAttributeMap_field_number: u32 = 6;
};
pub const SimpleCombatSplineMovePbType = struct {
    pub const ConfigId_field_number: u32 = 3;
};
pub const TrapDefenseComponentPb = struct {
    Data: ?union(enum) {
    } = null,
    pub const BuildingPbData_field_number: u32 = 1;
    pub const AuxiliaryPbData_field_number: u32 = 2;
    pub const MonsterPbData_field_number: u32 = 3;
    pub const GoldenCointPbData_field_number: u32 = 4;
    pub const SpecialCellPbdata_field_number: u32 = 5;
};
pub const TrapDefenseBuildingPbData = struct {
    pub const ConfigId_field_number: u32 = 1;
    pub const battleLevel_field_number: u32 = 2;
    pub const ConstructCost_field_number: u32 = 3;
    pub const DeconstructReturn_field_number: u32 = 4;
};
pub const TrapDefenseAuxiliaryPbData = struct {
    pub const ConfigId_field_number: u32 = 1;
};
pub const TrapDefenseMonsterPbData = struct {
    pub const ConfigId_field_number: u32 = 1;
};
pub const TrapDefenseGoldenCoinPbData = struct {
    pub const ConfigId_field_number: u32 = 1;
};
pub const TrapDefenseSpecialCellPbData = struct {
    pub const ConfigId_field_number: u32 = 1;
};
pub const HoldHandComponentPb = struct {
    pub const TargetEntityId_field_number: u32 = 1;
    pub const HandType_field_number: u32 = 2;
    pub const IsFollow_field_number: u32 = 3;
    pub const ActionType_field_number: u32 = 4;
};
pub const ActivityComponentPb = struct {
    Data: ?union(enum) {
    } = null,
    pub const SurvivorsMonsterPbData_field_number: u32 = 2;
    pub const SurvivorsWeaponPbData_field_number: u32 = 3;
    pub const SurvivorsPlayerCharacterPbData_field_number: u32 = 4;
    pub const SurvivorsGoldenCoinPbData_field_number: u32 = 5;
    pub const PinballKSCRolePbData_field_number: u32 = 6;
    pub const KurotatoCharacterEntityPbData_field_number: u32 = 7;
    pub const KurotatoDropEntityPbData_field_number: u32 = 8;
    pub const KurotatoWeaponEntityPbData_field_number: u32 = 9;
    pub const KurotatoMonsterEntityPbData_field_number: u32 = 10;
    pub const KurotatoStructureEntityPbData_field_number: u32 = 11;
    pub const ConfigId_field_number: u32 = 1;
};
pub const SurvivorsMonsterPbData = struct {
    pub const SpawnPointEntityId_field_number: u32 = 1;
};
pub const SurvivorsWeaponPbData = struct {
};
pub const SurvivorsPlayerCharacterPbData = struct {
};
pub const SurvivorsGoldenCoinPbData = struct {
};
pub const KurotatoMonsterEntityPbData = struct {
    jl0: ?union(enum) {
    } = null,
    Tv0: ?union(enum) {
    } = null,
    pub const SpawnConfigId_field_number: u32 = 1;
    pub const SpawnConfigGroupIndex_field_number: u32 = 2;
};
pub const KurotatoWeaponEntityPbData = struct {
    pub const IncId_field_number: u32 = 1;
};
pub const KurotatoCharacterEntityPbData = struct {
};
pub const KurotatoDropEntityPbData = struct {
};
pub const KurotatoStructureEntityPbData = struct {
};
pub const GpuEntityComponentPb = struct {
    data: ?union(enum) {
    } = null,
    pub const GpuMonsterEntityPbData_field_number: u32 = 2;
    pub const GpuRolePbEntityData_field_number: u32 = 3;
    pub const ConfigId_field_number: u32 = 1;
};
pub const GpuMonsterEntityPbData = struct {
};
pub const GpuRoleEntityPbData = struct {
    pub const IncId_field_number: u32 = 1;
};
pub const CalabashSkinComponentPb = struct {
    pub const CalabashSkinId_field_number: u32 = 1;
};
pub const EntityCalabashSkinChangeNotify = struct {
    pub const msg_id: u16 = 17510;
    pub const EntityId_field_number: u32 = 7;
    pub const CalabashSkinCoponent_field_number: u32 = 9;
};
pub const HonamiStoryDropItemComponentPb = struct {
    pub const Item_field_number: u32 = 1;
};
pub const HonamiStoryEnhanceLevelComponentPb = struct {
    pub const Level_field_number: u32 = 1;
};
pub const RbGridPosition = struct {
    pub const X_field_number: u32 = 1;
    pub const Y_field_number: u32 = 2;
};
pub const RbBlockComponentPb = struct {
    Type: ?union(enum) {
    } = null,
    pub const DefaultBlockType_field_number: u32 = 10;
    pub const VisionBlockType_field_number: u32 = 11;
    pub const CenterPosition_field_number: u32 = 1;
    pub const SizeX_field_number: u32 = 2;
    pub const SizeY_field_number: u32 = 3;
    pub const SizeZ_field_number: u32 = 4;
    pub const Forward_field_number: u32 = 5;
    pub const Right_field_number: u32 = 6;
    pub const State_field_number: u32 = 7;
    pub const GamePlayIncId_field_number: u32 = 8;
    pub const OccupiedCellPositions_field_number: u32 = 9;
};
pub const RbDefaultBlockPbType = struct {
    pub const IsMainControl_field_number: u32 = 1;
};
pub const RbVisionBlockPbType = struct {
};
pub const RbFloorComponentPb = struct {
    pub const GamePlayIncId_field_number: u32 = 1;
    pub const Type_field_number: u32 = 2;
    pub const OccupiedCellPositions_field_number: u32 = 3;
};
pub const RbItemComponentPb = struct {
    Type: ?union(enum) {
    } = null,
    pub const BreakableObstacleType_field_number: u32 = 3;
    pub const RbLaserEmitterType_field_number: u32 = 4;
    pub const GamePlayIncId_field_number: u32 = 1;
    pub const OccupiedCellPositions_field_number: u32 = 2;
};
pub const RbBreakableObstaclePbType = struct {
    pub const LinkPoints_field_number: u32 = 1;
};
pub const RbLaserEmitterPbType = struct {
    pub const LaserPoints_field_number: u32 = 1;
};
pub const SunSpiritTakeUpPb = struct {
    pub const TrapEntityConfigId_field_number: u32 = 1;
    pub const Index_field_number: u32 = 2;
};
pub const SunSpiritPb = struct {
    pub const InstId_field_number: u32 = 1;
    pub const EntityConfigId_field_number: u32 = 2;
    pub const TakeUpData_field_number: u32 = 3;
};
pub const SunSpiritGearComponentPb = struct {
    pub const TakeUpInfo_field_number: u32 = 1;
};
pub const VehiclePb = struct {
    pub const Source_field_number: u32 = 1;
};
pub const RoadNavMoveData = struct {
    pub const DestRoadId_field_number: u32 = 1;
    pub const DestIndex_field_number: u32 = 2;
    pub const GenRoadId_field_number: u32 = 3;
    pub const GenRoadIndex_field_number: u32 = 4;
};
pub const RoadNetworkComponentPb = struct {
    MoveData: ?union(enum) {
    } = null,
    pub const NavMoveData_field_number: u32 = 5;
    pub const DestRoadId_field_number: u32 = 1;
    pub const DestIndex_field_number: u32 = 2;
    pub const GenRoadId_field_number: u32 = 3;
    pub const GenRoadIndex_field_number: u32 = 4;
};
pub const ExhibitionComponentPb = struct {
    pub const ItemId_field_number: u32 = 1;
};
pub const FurnitureComponentPb = struct {
    pub const SlotId_field_number: u32 = 1;
    pub const FurnitureId_field_number: u32 = 2;
};
pub const PinballKSCRolePbData = struct {
};
pub const VisionSkillInformation = struct {
    pub const SkillId_field_number: u32 = 1;
    pub const Level_field_number: u32 = 2;
    pub const Quality_field_number: u32 = 3;
    pub const VisionEntityId_field_number: u32 = 4;
    pub const Index_field_number: u32 = 5;
};
pub const VisionSkillChangeNotify = struct {
    pub const msg_id: u16 = 15344;
    pub const EntityId_field_number: u32 = 11;
    pub const VisionSkillInfos_field_number: u32 = 12;
    pub const PhantomSkillInfo_field_number: u32 = 13;
};
pub const PartComponentPb = struct {
    pub const PartLifeInfos_field_number: u32 = 1;
};
pub const PartComponentInitNotify = struct {
    pub const msg_id: u16 = 16221;
    pub const EntityId_field_number: u32 = 14;
    pub const PartComponent_field_number: u32 = 2;
};
pub const PartInformation = struct {
    pub const PartIndex_field_number: u32 = 1;
    pub const LifeValue_field_number: u32 = 2;
    pub const LifeMax_field_number: u32 = 3;
    pub const Activated_field_number: u32 = 4;
    pub const PartTag_field_number: u32 = 5;
};
pub const PartUpdateInfo = struct {
    pub const PartIndex_field_number: u32 = 1;
    pub const Activated_field_number: u32 = 2;
    pub const Reset_field_number: u32 = 3;
};
pub const PartUpdateRequest = struct {
    pub const msg_id: u16 = 21344;
    pub const EntityId_field_number: u32 = 4;
    pub const PartUpdateInfos_field_number: u32 = 9;
};
pub const PartUpdatePush = struct {
    pub const msg_id: u16 = 15701;
    pub const EntityId_field_number: u32 = 8;
    pub const PartUpdateInfos_field_number: u32 = 10;
};
pub const PartUpdateResponse = struct {
    pub const msg_id: u16 = 26290;
    pub const ErrorCode_field_number: u32 = 8;
};
pub const PartUpdateNotify = struct {
    pub const msg_id: u16 = 29702;
    pub const EntityId_field_number: u32 = 15;
    pub const PartInfos_field_number: u32 = 4;
};
pub const ApplyGameplayEffectRequest = struct {
    pub const msg_id: u16 = 28580;
    Time: ?union(enum) {
    } = null,
    pub const Duration_field_number: u32 = 7;
    pub const Handle_field_number: u32 = 2;
    pub const Id_field_number: u32 = 3;
    pub const Level_field_number: u32 = 12;
    pub const InstigatorId_field_number: u32 = 9;
    pub const ApplyType_field_number: u32 = 6;
    pub const ServerId_field_number: u32 = 11;
    pub const StackCount_field_number: u32 = 15;
    pub const IsActive_field_number: u32 = 8;
};
pub const ApplyGameplayEffectPush = struct {
    pub const msg_id: u16 = 22678;
    Time: ?union(enum) {
    } = null,
    pub const Duration_field_number: u32 = 10;
    pub const Handle_field_number: u32 = 1;
    pub const Id_field_number: u32 = 2;
    pub const Level_field_number: u32 = 5;
    pub const InstigatorId_field_number: u32 = 8;
    pub const ApplyType_field_number: u32 = 6;
    pub const ServerId_field_number: u32 = 3;
    pub const StackCount_field_number: u32 = 11;
    pub const IsActive_field_number: u32 = 13;
    pub const Reason_field_number: u32 = 12;
    pub const ConfBuffId_field_number: u32 = 7;
};
pub const ApplyGameplayEffectResponse = struct {
    pub const msg_id: u16 = 29902;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const ApplyGameplayEffectNotify = struct {
    pub const msg_id: u16 = 17019;
    CRoundAction: ?union(enum) {
    } = null,
    Time: ?union(enum) {
    } = null,
    pub const Duration_field_number: u32 = 5;
    pub const LeftDuration_field_number: u32 = 10;
    pub const Handle_field_number: u32 = 12;
    pub const Id_field_number: u32 = 2;
    pub const Level_field_number: u32 = 7;
    pub const EntityId_field_number: u32 = 15;
    pub const InstigatorId_field_number: u32 = 6;
    pub const ApplyType_field_number: u32 = 4;
    pub const IsActive_field_number: u32 = 1;
    pub const ServerId_field_number: u32 = 11;
    pub const StackCount_field_number: u32 = 13;
    pub const ConfBuffId_field_number: u32 = 14;
};
pub const RemoveGameplayEffectRequest = struct {
    pub const msg_id: u16 = 22464;
    pub const Handle_field_number: u32 = 13;
    pub const EntityId_field_number: u32 = 12;
    pub const IsPrematureRemoval_field_number: u32 = 7;
};
pub const RemoveGameplayEffectPush = struct {
    pub const msg_id: u16 = 26179;
    pub const Handle_field_number: u32 = 2;
    pub const EntityId_field_number: u32 = 11;
    pub const IsPrematureRemoval_field_number: u32 = 4;
    pub const Reason_field_number: u32 = 13;
    pub const InstigatorId_field_number: u32 = 15;
};
pub const RemoveGameplayEffectResponse = struct {
    pub const msg_id: u16 = 16882;
    pub const ErrorCode_field_number: u32 = 7;
    pub const Handle_field_number: u32 = 1;
};
pub const RemoveGameplayEffectNotify = struct {
    pub const msg_id: u16 = 16773;
    pub const Handle_field_number: u32 = 5;
    pub const EntityId_field_number: u32 = 6;
    pub const InstigatorId_field_number: u32 = 1;
};
pub const OrderApplyBuffRequest = struct {
    pub const msg_id: u16 = 27423;
    Time: ?union(enum) {
    } = null,
    pub const Duration_field_number: u32 = 3;
    pub const Id_field_number: u32 = 4;
    pub const Level_field_number: u32 = 6;
    pub const InstigatorId_field_number: u32 = 8;
    pub const ApplyType_field_number: u32 = 15;
    pub const ServerId_field_number: u32 = 7;
    pub const StackCount_field_number: u32 = 14;
    pub const IsIterable_field_number: u32 = 12;
    pub const TransferContextId_field_number: u32 = 10;
    pub const Reason_field_number: u32 = 13;
};
pub const OrderApplyBuffResponse = struct {
    pub const msg_id: u16 = 25892;
    pub const ErrorCode_field_number: u32 = 9;
};
pub const OrderRemoveBuffRequest = struct {
    pub const msg_id: u16 = 22866;
    pub const Id_field_number: u32 = 4;
    pub const StackCount_field_number: u32 = 12;
    pub const Reason_field_number: u32 = 14;
    pub const InstigatorId_field_number: u32 = 1;
};
pub const OrderRemoveBuffResponse = struct {
    pub const msg_id: u16 = 23758;
    pub const ErrorCode_field_number: u32 = 3;
};
pub const OrderApplyBuffNotify = struct {
    pub const msg_id: u16 = 23435;
    Time: ?union(enum) {
    } = null,
    pub const Duration_field_number: u32 = 8;
    pub const Id_field_number: u32 = 14;
    pub const Level_field_number: u32 = 10;
    pub const InstigatorId_field_number: u32 = 1;
    pub const ApplyType_field_number: u32 = 4;
    pub const ServerId_field_number: u32 = 5;
    pub const StackCount_field_number: u32 = 11;
    pub const IsIterable_field_number: u32 = 6;
};
pub const OrderRemoveBuffNotify = struct {
    pub const msg_id: u16 = 17314;
    pub const Id_field_number: u32 = 3;
    pub const StackCount_field_number: u32 = 2;
};
pub const ApplyBuffS2cRequestNotify = struct {
    pub const msg_id: u16 = 22273;
    Time: ?union(enum) {
    } = null,
    pub const Duration_field_number: u32 = 5;
    pub const Id_field_number: u32 = 11;
    pub const Level_field_number: u32 = 8;
    pub const InstigatorId_field_number: u32 = 14;
    pub const ApplyType_field_number: u32 = 13;
    pub const ServerId_field_number: u32 = 2;
    pub const StackCount_field_number: u32 = 10;
    pub const IsIterable_field_number: u32 = 6;
    pub const Reason_field_number: u32 = 12;
};
pub const ApplyBuffS2cResponsePush = struct {
    pub const msg_id: u16 = 27434;
    pub const ErrorCode_field_number: u32 = 9;
    pub const Handle_field_number: u32 = 5;
    pub const IsActive_field_number: u32 = 12;
};
pub const RemoveBuffS2cRequestNotify = struct {
    pub const msg_id: u16 = 17221;
    pub const Handle_field_number: u32 = 7;
    pub const StackCount_field_number: u32 = 2;
    pub const Reason_field_number: u32 = 8;
    pub const InstigatorId_field_number: u32 = 1;
};
pub const RemoveBuffS2cResponsePush = struct {
    pub const msg_id: u16 = 26537;
    pub const ErrorCode_field_number: u32 = 12;
};
pub const RemoveBuffByIdS2cRequestNotify = struct {
    pub const msg_id: u16 = 24468;
    pub const BuffId_field_number: u32 = 2;
    pub const StackCount_field_number: u32 = 3;
    pub const Reason_field_number: u32 = 4;
    pub const InstigatorId_field_number: u32 = 15;
};
pub const RemoveBuffByIdS2cResponsePush = struct {
    pub const msg_id: u16 = 28575;
    pub const ErrorCode_field_number: u32 = 12;
};
pub const BroadcastAddBuffFailedNotify = struct {
    pub const msg_id: u16 = 23768;
    pub const BuffId_field_number: u32 = 10;
    pub const StackCount_field_number: u32 = 11;
    pub const InstigatorId_field_number: u32 = 2;
    pub const TransferContextId_field_number: u32 = 15;
};
pub const ActivateBuffRequest = struct {
    pub const msg_id: u16 = 15227;
    pub const Handle_field_number: u32 = 1;
    pub const On_field_number: u32 = 11;
};
pub const ActiveBuffPush = struct {
    pub const msg_id: u16 = 25271;
    pub const Handle_field_number: u32 = 9;
    pub const On_field_number: u32 = 15;
};
pub const ActivateBuffResponse = struct {
    pub const msg_id: u16 = 25973;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const ActivateBuffNotify = struct {
    pub const msg_id: u16 = 24594;
    pub const Handle_field_number: u32 = 12;
    pub const On_field_number: u32 = 4;
};
pub const OrderRemoveBuffByTagsRequest = struct {
    pub const msg_id: u16 = 24948;
    pub const TagIds_field_number: u32 = 1;
    pub const InstigatorId_field_number: u32 = 12;
};
pub const OrderRemoveBuffByTagsResponse = struct {
    pub const msg_id: u16 = 27151;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const OrderRemoveBuffByTagsNotify = struct {
    pub const msg_id: u16 = 24782;
    pub const TagIds_field_number: u32 = 13;
    pub const InstigatorId_field_number: u32 = 12;
};
pub const AttributeEventEffectData = struct {
    pub const TriggeredActiveHandles_field_number: u32 = 1;
};
pub const FightBuffEffectContext = struct {
    dRoundAction: ?union(enum) {
    } = null,
    Effect: ?union(enum) {
    } = null,
    pub const LeftCooldown_field_number: u32 = 1;
    pub const AttributeEventEffectData_field_number: u32 = 6;
};
pub const BuffStackCountRequest = struct {
    pub const msg_id: u16 = 26325;
    pub const HandleId_field_number: u32 = 1;
    pub const NewStackCount_field_number: u32 = 11;
    pub const IsPrematureRemoval_field_number: u32 = 7;
    pub const InstigatorId_field_number: u32 = 2;
};
pub const BuffStackCountPush = struct {
    pub const msg_id: u16 = 25789;
    pub const HandleId_field_number: u32 = 9;
    pub const NewStackCount_field_number: u32 = 1;
    pub const IsPrematureRemoval_field_number: u32 = 4;
    pub const InstigatorId_field_number: u32 = 13;
    pub const NotRefreshDuration_field_number: u32 = 8;
    pub const NotRefreshPeriod_field_number: u32 = 6;
    pub const Duration_field_number: u32 = 12;
    pub const Reason_field_number: u32 = 10;
};
pub const BuffStackCountResponse = struct {
    pub const msg_id: u16 = 17439;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const BuffStackCountNotify = struct {
    pub const msg_id: u16 = 17206;
    Time: ?union(enum) {
    } = null,
    gFs: ?union(enum) {
    } = null,
    pub const Duration_field_number: u32 = 6;
    pub const LeftDuration_field_number: u32 = 13;
    pub const HandleId_field_number: u32 = 15;
    pub const NewStackCount_field_number: u32 = 12;
    pub const InstigatorId_field_number: u32 = 5;
    pub const NotRefreshDuration_field_number: u32 = 14;
    pub const NotRefreshPeriod_field_number: u32 = 8;
};
pub const BuffEffectCd = struct {
    pub const BuffId_field_number: u32 = 1;
    pub const ListCdRemaining_field_number: u32 = 2;
};
pub const BuffEffectRequest = struct {
    pub const msg_id: u16 = 15926;
    pub const HandleId_field_number: u32 = 13;
    pub const Index_field_number: u32 = 10;
};
pub const BuffEffectPush = struct {
    pub const msg_id: u16 = 17315;
    pub const HandleId_field_number: u32 = 11;
    pub const Index_field_number: u32 = 7;
};
pub const BuffEffectResponse = struct {
    pub const msg_id: u16 = 22178;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const BuffDurationNotify = struct {
    pub const msg_id: u16 = 25585;
    Time: ?union(enum) {
    } = null,
    gFs: ?union(enum) {
    } = null,
    pub const Duration_field_number: u32 = 12;
    pub const LeftDuration_field_number: u32 = 13;
    pub const HandleId_field_number: u32 = 4;
};
pub const RefreshBuffDurationPush = struct {
    pub const msg_id: u16 = 17043;
    pub const BuffIds_field_number: u32 = 6;
};
pub const BuffEffectExecutePush = struct {
    pub const msg_id: u16 = 25695;
    pub const HandleId_field_number: u32 = 3;
    pub const Index_field_number: u32 = 15;
};
pub const RemoveBuffByServerIdS2cRequestNotify = struct {
    pub const msg_id: u16 = 25836;
    pub const ServerId_field_number: u32 = 2;
    pub const StackCount_field_number: u32 = 11;
    pub const Reason_field_number: u32 = 14;
    pub const InstigatorId_field_number: u32 = 15;
};
pub const ChangeStateRequest = struct {
    pub const msg_id: u16 = 17079;
    pub const FsmId_field_number: u32 = 14;
    pub const FromState_field_number: u32 = 1;
    pub const ToState_field_number: u32 = 4;
};
pub const ChangeStateResponse = struct {
    pub const msg_id: u16 = 24498;
    pub const FsmId_field_number: u32 = 11;
    pub const Error_field_number: u32 = 10;
    pub const CurrentState_field_number: u32 = 4;
};
pub const ChangeStateNotify = struct {
    pub const msg_id: u16 = 23950;
    pub const FsmId_field_number: u32 = 5;
    pub const FromState_field_number: u32 = 8;
    pub const ToState_field_number: u32 = 3;
};
pub const ChangeStateConfirmRequest = struct {
    pub const msg_id: u16 = 22422;
    pub const FsmId_field_number: u32 = 12;
    pub const State_field_number: u32 = 9;
};
pub const ChangeStateConfirmPush = struct {
    pub const msg_id: u16 = 27062;
    pub const FsmId_field_number: u32 = 14;
    pub const State_field_number: u32 = 4;
};
pub const ChangeStateConfirmResponse = struct {
    pub const msg_id: u16 = 21653;
    pub const FsmId_field_number: u32 = 7;
    pub const State_field_number: u32 = 3;
    pub const Error_field_number: u32 = 14;
};
pub const ChangeStateConfirmNotify = struct {
    pub const msg_id: u16 = 23954;
    pub const FsmId_field_number: u32 = 4;
    pub const State_field_number: u32 = 9;
};
pub const DFsm = struct {
    pub const FsmId_field_number: u32 = 1;
    pub const CurrentState_field_number: u32 = 2;
    pub const Flag_field_number: u32 = 3;
    pub const StateElapseTime_field_number: u32 = 6;
};
pub const EntityFsmComponentPb = struct {
    pub const Fsms_field_number: u32 = 1;
    pub const HashCode_field_number: u32 = 2;
    pub const CommonHashCode_field_number: u32 = 3;
    pub const BlackBoard_field_number: u32 = 4;
    pub const FsmCustomBlackboardDatas_field_number: u32 = 5;
};
pub const FsmConditionPassRequest = struct {
    pub const msg_id: u16 = 19219;
    pub const FsmId_field_number: u32 = 14;
    pub const FromState_field_number: u32 = 13;
    pub const ToState_field_number: u32 = 11;
    pub const ConditionIndex_field_number: u32 = 3;
    pub const Value_field_number: u32 = 2;
};
pub const FsmConditionPassResponse = struct {
    pub const msg_id: u16 = 15892;
    pub const FsmId_field_number: u32 = 10;
    pub const Error_field_number: u32 = 11;
};
pub const FsmConditionPassPush = struct {
    pub const msg_id: u16 = 22624;
    pub const FsmId_field_number: u32 = 7;
    pub const FromState_field_number: u32 = 1;
    pub const ToState_field_number: u32 = 8;
    pub const ConditionIndex_field_number: u32 = 4;
    pub const Value_field_number: u32 = 3;
};
pub const FsmResetNotify = struct {
    pub const msg_id: u16 = 19920;
    pub const EntityFsmComponentPb_field_number: u32 = 2;
};
pub const FsmBlackboardNotify = struct {
    pub const msg_id: u16 = 23682;
    pub const FsmBlackBoards_field_number: u32 = 12;
};
pub const FsmCustomBlackboardDatas = struct {
    pub const BlackboardIntValues_field_number: u32 = 1;
};
pub const FsmCustomBlackboardNotify = struct {
    pub const msg_id: u16 = 24597;
    pub const FsmCustomBlackboardDatas_field_number: u32 = 10;
};
pub const DFsmBlackBoard = struct {
    pub const Key_field_number: u32 = 1;
    pub const Value_field_number: u32 = 2;
};
pub const DFsmBlackboardCustom = struct {
    pub const Key_field_number: u32 = 1;
    pub const Value_field_number: u32 = 2;
};
pub const FsmStateBehaviorRequest = struct {
    pub const msg_id: u16 = 29933;
    pub const FsmId_field_number: u32 = 2;
    pub const State_field_number: u32 = 4;
    pub const Index_field_number: u32 = 12;
    pub const Type_field_number: u32 = 6;
};
pub const FsmStateBehaviorResponse = struct {
    pub const msg_id: u16 = 18491;
    pub const FsmId_field_number: u32 = 13;
    pub const State_field_number: u32 = 5;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const FsmPlayMontageRequest = struct {
    pub const msg_id: u16 = 19301;
    pub const MontageName_field_number: u32 = 15;
    pub const MontagePathHash_field_number: u32 = 11;
    pub const SpeedRatio_field_number: u32 = 2;
    pub const StartSection_field_number: u32 = 6;
    pub const StartTimeSeconds_field_number: u32 = 9;
};
pub const FsmPlayMontagePush = struct {
    pub const msg_id: u16 = 21922;
    pub const MontageName_field_number: u32 = 11;
    pub const MontagePathHash_field_number: u32 = 5;
    pub const SpeedRatio_field_number: u32 = 2;
    pub const StartSection_field_number: u32 = 10;
    pub const StartTimeSeconds_field_number: u32 = 8;
};
pub const FsmPlayMontageResponse = struct {
    pub const msg_id: u16 = 22569;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const FsmMontageDurationNotify = struct {
    pub const msg_id: u16 = 24423;
    pub const MontageHashCode_field_number: u32 = 1;
    pub const DurationTime_field_number: u32 = 11;
};
pub const BoardGridDynamicConfig = struct {
    pub const RowIndex_field_number: u32 = 1;
    pub const ColumnIndex_field_number: u32 = 2;
    pub const Flags_field_number: u32 = 3;
};
pub const PlacementItemPb = struct {
    pub const LocatedBoardEntityConfigId_field_number: u32 = 1;
};
pub const BoardGridPositionInfo = struct {
    pub const Row_field_number: u32 = 1;
    pub const Column_field_number: u32 = 2;
    pub const RotAngle_field_number: u32 = 3;
};
pub const OccupiedBoardGridInfo = struct {
    pub const Pos_field_number: u32 = 1;
    pub const OccupyingEntityConfigId_field_number: u32 = 2;
    pub const EntityConfigType_field_number: u32 = 3;
};
pub const JigsawBaseComponentPb = struct {
    pub const MoveCount_field_number: u32 = 1;
    pub const EntityId_field_number: u32 = 2;
    pub const Winner_field_number: u32 = 3;
};
pub const SummonerComponentPb = struct {
    pub const SummonerId_field_number: u32 = 1;
    pub const SummonCfgId_field_number: u32 = 2;
    pub const SummonSkillId_field_number: u32 = 3;
    pub const PlayerId_field_number: u32 = 4;
    pub const Type_field_number: u32 = 5;
};
pub const SummonsComponentPb = struct {
    pub const Version_field_number: u32 = 1;
};
pub const FollowerList = struct {
    pub const Type_field_number: u32 = 1;
    pub const EntityId_field_number: u32 = 2;
};
pub const FollowerComponentPb = struct {
    pub const FollowerList_field_number: u32 = 1;
};
pub const FollowShooterComponentPb = struct {
    pub const PlayerEntityId_field_number: u32 = 1;
    pub const SummonConfigId_field_number: u32 = 2;
};
pub const CharacterAttachInfo = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const Pos_field_number: u32 = 2;
    pub const Rot_field_number: u32 = 3;
    pub const PartIndex_field_number: u32 = 4;
};
pub const SceneItemBlackboardParam = struct {
    Value: ?union(enum) {
    } = null,
    pub const IntValue_field_number: u32 = 3;
    pub const IntValues_field_number: u32 = 4;
    pub const LongValue_field_number: u32 = 5;
    pub const LongValues_field_number: u32 = 6;
    pub const BooleanValue_field_number: u32 = 7;
    pub const StringValue_field_number: u32 = 8;
    pub const FloatValue_field_number: u32 = 10;
    pub const FloatValues_field_number: u32 = 11;
    pub const VectorValue_field_number: u32 = 12;
    pub const RotatorValue_field_number: u32 = 13;
    pub const Key_field_number: u32 = 1;
};
pub const HackingComponentPb = struct {
    pub const EntityIds_field_number: u32 = 1;
};
pub const HackTargetComponentPb = struct {
    pub const HackTargetEntityId_field_number: u32 = 1;
};
pub const GravityFlipComponent = struct {
    pub const Direction_field_number: u32 = 1;
};
pub const EntityRewardItemPb = struct {
    pub const HasCount_field_number: u32 = 1;
    pub const NextResetTime_field_number: u32 = 2;
};
pub const RbBlockPbState = struct {
    State: ?union(enum) {
    } = null,
    pub const MovingState_field_number: u32 = 1;
    pub const IdleState_field_number: u32 = 2;
};
pub const RbBlockMovingPbState = struct {
    pub const Action_field_number: u32 = 1;
};
pub const RbBlockIdlePbState = struct {
    pub const Position_field_number: u32 = 6;
    pub const Rotation_field_number: u32 = 7;
};
pub const RbBlockMovementPbAction = struct {
    Type: ?union(enum) {
    } = null,
    pub const Roll_field_number: u32 = 1;
    pub const Jump_field_number: u32 = 2;
};
pub const RbRollMovement = struct {
    pub const Direction_field_number: u32 = 1;
};
pub const RbJumpMovement = struct {
    pub const Direction_field_number: u32 = 1;
};
pub const MotorDiyInfoRequest = struct {
    pub const msg_id: u16 = 27056;
};
pub const MotorDiyInfoResponse = struct {
    pub const msg_id: u16 = 20233;
    pub const ErrorCode_field_number: u32 = 11;
    pub const MotorDiy_field_number: u32 = 1;
};
pub const MotorUseSkinRequest = struct {
    pub const msg_id: u16 = 22022;
    pub const SkinId_field_number: u32 = 15;
};
pub const MotorUseSkinResponse = struct {
    pub const msg_id: u16 = 28777;
    pub const ErrorCode_field_number: u32 = 2;
};
pub const MotorChangeOutlookRequest = struct {
    pub const msg_id: u16 = 23455;
    pub const StickerEquipped_field_number: u32 = 7;
    pub const DecorationsEquipped_field_number: u32 = 2;
    pub const FrameEquipped_field_number: u32 = 14;
};
pub const MotorChangeOutlookResponse = struct {
    pub const msg_id: u16 = 18201;
    pub const ErrorCode_field_number: u32 = 3;
};
pub const MotorOutlookCreatePresetRequest = struct {
    pub const msg_id: u16 = 26068;
    pub const Preset_field_number: u32 = 9;
    pub const name_field_number: u32 = 12;
};
pub const MotorOutlookCreatePresetResponse = struct {
    pub const msg_id: u16 = 15857;
    pub const ErrorCode_field_number: u32 = 15;
    pub const MotorOutlookPreset_field_number: u32 = 11;
};
pub const MotorOutlookDeletePresetRequest = struct {
    pub const msg_id: u16 = 26346;
    pub const id_field_number: u32 = 5;
};
pub const MotorOutlookDeletePresetResponse = struct {
    pub const msg_id: u16 = 28577;
    pub const ErrorCode_field_number: u32 = 9;
    pub const MotorOutlookPreset_field_number: u32 = 15;
};
pub const MotorOutlookEditPresetRequest = struct {
    pub const msg_id: u16 = 22065;
    pub const PresetPlan_field_number: u32 = 1;
};
pub const MotorOutlookEditPresetResponse = struct {
    pub const msg_id: u16 = 17807;
    pub const ErrorCode_field_number: u32 = 6;
    pub const MotorOutlookPreset_field_number: u32 = 8;
};
pub const MotorOutlookEquippedChangeNotify = struct {
    pub const msg_id: u16 = 25829;
    pub const MotorDiyEquipped_field_number: u32 = 4;
    pub const LatestMotorSkinSuit_field_number: u32 = 1;
};
pub const EntityMotorOutlookChangeNotify = struct {
    pub const msg_id: u16 = 16019;
    pub const EntityId_field_number: u32 = 1;
    pub const MotorDiyEquipped_field_number: u32 = 5;
};
pub const MotorOutlookRegionInfoNotify = struct {
    pub const msg_id: u16 = 15872;
    pub const MotorOutlookRegion_field_number: u32 = 13;
};
pub const MotorDiyEquippedPb = struct {
    pub const SkinEquipped_field_number: u32 = 1;
    pub const StickerEquipped_field_number: u32 = 2;
    pub const DecorationsEquipped_field_number: u32 = 3;
    pub const FrameEquipped_field_number: u32 = 4;
};
pub const MotorDiyOnwedPb = struct {
    pub const SkinOwned_field_number: u32 = 2;
    pub const StickerOnwed_field_number: u32 = 1;
    pub const DecorationsOwned_field_number: u32 = 3;
    pub const FrameOwned_field_number: u32 = 4;
};
pub const MotorOutlookRegionPb = struct {
    pub const MotorSticker_field_number: u32 = 4;
    pub const MotorDecoration_field_number: u32 = 5;
    pub const MotorFrame_field_number: u32 = 6;
    pub const MotorStickerId_field_number: u32 = 1;
    pub const MotorDecorationId_field_number: u32 = 2;
    pub const MotorFrameId_field_number: u32 = 3;
};
pub const MotorOutlookIdTimePairPb = struct {
    pub const Id_field_number: u32 = 1;
    pub const OpenTime_field_number: u32 = 2;
};
pub const MotorOutlookPlayerPresetPb = struct {
    pub const Plan_field_number: u32 = 1;
};
pub const MotorOutlookPresetPlanPb = struct {
    pub const Preset_field_number: u32 = 1;
    pub const Mame_field_number: u32 = 2;
    pub const Id_field_number: u32 = 3;
};
pub const MotorDiyPb = struct {
    pub const MotorDiyOnwer_field_number: u32 = 1;
    pub const MotorDiyEquipped_field_number: u32 = 2;
    pub const MotorOutlookPreset_field_number: u32 = 3;
    pub const LatestMotorSkinSuit_field_number: u32 = 4;
    pub const SceneInUse_field_number: u32 = 5;
};
pub const BirthRoleSelect = struct {
    pub const Year_field_number: u32 = 1;
    pub const Role_field_number: u32 = 2;
};
pub const BirthdayInfoUpdateNotify = struct {
    pub const msg_id: u16 = 23660;
    pub const BirthDayReset_field_number: u32 = 4;
    pub const RecentRewardTime_field_number: u32 = 14;
    pub const Roles_field_number: u32 = 3;
};
pub const BuffItem = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const CdTime_field_number: u32 = 3;
};
pub const EquipBuffItem = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const Equiped_field_number: u32 = 2;
};
pub const BuffItemNotify = struct {
    pub const msg_id: u16 = 24446;
    pub const ItemBuffList_field_number: u32 = 6;
    pub const EquipItemList_field_number: u32 = 8;
};
pub const ButtonEnableResult = struct {
    pub const Type_field_number: u32 = 2;
    pub const Enabled_field_number: u32 = 3;
};
pub const BtnStateRequest = struct {
    pub const msg_id: u16 = 26012;
    pub const Type_field_number: u32 = 7;
    pub const Types_field_number: u32 = 11;
};
pub const BtnStateResponse = struct {
    pub const msg_id: u16 = 17586;
    pub const ErrorCode_field_number: u32 = 3;
    pub const Type_field_number: u32 = 9;
    pub const Enabled_field_number: u32 = 14;
    pub const Result_field_number: u32 = 7;
};
pub const CalabashDevelopConditionState = struct {
    pub const ConditionId_field_number: u32 = 1;
    pub const Rewarded_field_number: u32 = 2;
};
pub const CalabashDevelopInfo = struct {
    pub const MonsterId_field_number: u32 = 1;
    pub const UnlockConditions_field_number: u32 = 2;
};
pub const CalabashMsg = struct {
    pub const Level_field_number: u32 = 1;
    pub const Exp_field_number: u32 = 2;
    pub const UnlockedLevels_field_number: u32 = 3;
    pub const UnlockedDevelopRewards_field_number: u32 = 4;
    pub const IdentifyGuaranteeCount_field_number: u32 = 5;
    pub const LowCostGuaranteeCount_field_number: u32 = 6;
};
pub const CalabashCfg = struct {
    pub const LevelUpExp_field_number: u32 = 1;
    pub const LevelUpCondition_field_number: u32 = 3;
    pub const CatchGain_field_number: u32 = 4;
};
pub const CalabashMsgNotify = struct {
    pub const msg_id: u16 = 26332;
    pub const CalabashMsg_field_number: u32 = 8;
    pub const CalabashCfg_field_number: u32 = 6;
};
pub const CalabashLevelsRewardNotify = struct {
    pub const msg_id: u16 = 26252;
    pub const RewardedLevels_field_number: u32 = 13;
};
pub const CalabashLevelRewardRequest = struct {
    pub const msg_id: u16 = 19859;
    pub const Level_field_number: u32 = 1;
};
pub const CalabashLevelRewardResponse = struct {
    pub const msg_id: u16 = 25634;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const CalabashSkinDataRequest = struct {
    pub const msg_id: u16 = 26827;
};
pub const CalabashSkinDataResponse = struct {
    pub const msg_id: u16 = 20621;
    pub const ErrorCode_field_number: u32 = 8;
    pub const EquipedSkinId_field_number: u32 = 2;
    pub const SkinIdList_field_number: u32 = 15;
};
pub const CalabashSkinTakeOnRequest = struct {
    pub const msg_id: u16 = 21847;
    pub const SkinId_field_number: u32 = 6;
};
pub const CalabashSkinTakeOnResponse = struct {
    pub const msg_id: u16 = 27078;
    pub const ErrorCode_field_number: u32 = 12;
    pub const SkinId_field_number: u32 = 1;
};
pub const PrivateChatRequest = struct {
    pub const msg_id: u16 = 20090;
    pub const TargetUid_field_number: u32 = 11;
    pub const ChatContentType_field_number: u32 = 3;
    pub const Content_field_number: u32 = 15;
    pub const XboxBlockedPlayerIds_field_number: u32 = 2;
};
pub const PrivateChatResponse = struct {
    pub const msg_id: u16 = 28633;
    pub const TargetUid_field_number: u32 = 9;
    pub const ErrorCode_field_number: u32 = 10;
    pub const MsgId_field_number: u32 = 11;
    pub const FilterMsg_field_number: u32 = 7;
    pub const BanEndTime_field_number: u32 = 1;
};
pub const ChatContentProto = struct {
    pub const SenderUid_field_number: u32 = 1;
    pub const ChatContentType_field_number: u32 = 2;
    pub const Content_field_number: u32 = 3;
    pub const OfflineMsg_field_number: u32 = 4;
    pub const UtcTime_field_number: u32 = 5;
    pub const MsgId_field_number: u32 = 6;
    pub const PsAccountId_field_number: u32 = 7;
    pub const XboxAccountId_field_number: u32 = 8;
};
pub const PrivateMessageNotify = struct {
    pub const msg_id: u16 = 15918;
    pub const ChatContent_field_number: u32 = 12;
};
pub const PrivateChatHistoryRequest = struct {
    pub const msg_id: u16 = 23875;
    pub const TargetUid_field_number: u32 = 11;
    pub const StartIndex_field_number: u32 = 8;
};
pub const PrivateChatHistoryResponse = struct {
    pub const msg_id: u16 = 29406;
    pub const ErrorCode_field_number: u32 = 3;
    pub const Data_field_number: u32 = 12;
};
pub const PrivateChatHistoryContentProto = struct {
    pub const TargetUid_field_number: u32 = 1;
    pub const Chats_field_number: u32 = 2;
    pub const HistoryIsEnd_field_number: u32 = 3;
    pub const TotalNums_field_number: u32 = 4;
};
pub const PrivateChatHistoryNotify = struct {
    pub const msg_id: u16 = 29871;
    pub const AllChats_field_number: u32 = 11;
};
pub const PrivateChatDataRequest = struct {
    pub const msg_id: u16 = 24257;
};
pub const PrivateChatDataResponse = struct {
    pub const msg_id: u16 = 21502;
    pub const LoadSucc_field_number: u32 = 4;
};
pub const PrivateChatOperateRequest = struct {
    pub const msg_id: u16 = 19749;
    pub const OperateType_field_number: u32 = 11;
    pub const TargetPlayerId_field_number: u32 = 9;
};
pub const PrivateChatOperateResponse = struct {
    pub const msg_id: u16 = 25224;
    pub const ErrorCode_field_number: u32 = 3;
};
pub const CombatPushData = struct {
    Message: ?union(enum) {
    } = null,
    pub const ApplyBuffS2cResponsePush_field_number: u32 = 4;
    pub const RemoveBuffS2cResponsePush_field_number: u32 = 5;
    pub const RemoveBuffByIdS2cResponsePush_field_number: u32 = 6;
    pub const CreateBulletResponsePush_field_number: u32 = 7;
    pub const DestroyBulletResponsePush_field_number: u32 = 8;
    pub const ApplyGameplayEffectPush_field_number: u32 = 9;
    pub const RemoveGameplayEffectPush_field_number: u32 = 10;
    pub const HitEndPush_field_number: u32 = 11;
    pub const EndSkillPush_field_number: u32 = 12;
    pub const PartUpdatePush_field_number: u32 = 13;
    pub const MaterialPush_field_number: u32 = 14;
    pub const GameplayCuePush_field_number: u32 = 15;
    pub const EntityIsVisiblePush_field_number: u32 = 16;
    pub const SwitchCharacterStatePush_field_number: u32 = 17;
    pub const LogicStateInitPush_field_number: u32 = 18;
    pub const SwitchLogicStatePush_field_number: u32 = 19;
    pub const AnimationStateChangedPush_field_number: u32 = 20;
    pub const AnimationStateInitPush_field_number: u32 = 21;
    pub const ModifyBulletParamsPush_field_number: u32 = 22;
    pub const DrownPush_field_number: u32 = 23;
    pub const ActiveBuffPush_field_number: u32 = 24;
    pub const AiInformationPush_field_number: u32 = 25;
    pub const ToughCalcExtraRatioChangePush_field_number: u32 = 26;
    pub const BattleStateChangePush_field_number: u32 = 27;
    pub const AnimationGameplayTagPush_field_number: u32 = 28;
    pub const BoneVisibleChangePush_field_number: u32 = 29;
    pub const AiBlackboardsPush_field_number: u32 = 30;
    pub const AiBlackboardCdPush_field_number: u32 = 31;
    pub const AiHatePush_field_number: u32 = 32;
    pub const MonsterBoomPush_field_number: u32 = 33;
    pub const CaughtPush_field_number: u32 = 34;
    pub const EntityStaticHookMovePush_field_number: u32 = 35;
    pub const ChangeStateConfirmPush_field_number: u32 = 36;
    pub const BuffStackCountPush_field_number: u32 = 37;
    pub const ANStartPush_field_number: u32 = 38;
    pub const UseSkillFailPush_field_number: u32 = 39;
    pub const EnterViewDirectionPush_field_number: u32 = 40;
    pub const ExitViewDirectionPush_field_number: u32 = 41;
    pub const PassiveSkillAddPush_field_number: u32 = 42;
    pub const InterruptSkillInDelayPush_field_number: u32 = 43;
    pub const TriggerExitSkillPush_field_number: u32 = 44;
    pub const ActorVisiblePush_field_number: u32 = 45;
    pub const BuffEffectPush_field_number: u32 = 46;
    pub const RTimeStopPush_field_number: u32 = 47;
    pub const DrownEndTeleportPush_field_number: u32 = 48;
    pub const MonsterDrownPush_field_number: u32 = 49;
    pub const PassiveSkillRemovePush_field_number: u32 = 50;
    pub const RTimeStopInstPush_field_number: u32 = 51;
    pub const FsmPlayMontagePush_field_number: u32 = 52;
    pub const TsAnimNotifyStateAbsoluteTimeStopPush_field_number: u32 = 53;
    pub const RoleTagChangePush_field_number: u32 = 54;
    pub const ExecuteQtePush_field_number: u32 = 55;
    pub const ClientCurrentRoleReportPush_field_number: u32 = 56;
    pub const MontagePlayPush_field_number: u32 = 57;
    pub const CounterAttackPush_field_number: u32 = 58;
    pub const NewLinkBurstPush_field_number: u32 = 59;
    pub const RefreshBuffDurationPush_field_number: u32 = 60;
    pub const RoleGoDownPush_field_number: u32 = 61;
    pub const FsmConditionPassPush_field_number: u32 = 62;
    pub const BuffEffectExecutePush_field_number: u32 = 63;
    pub const VisionTriggerPush_field_number: u32 = 64;
    pub const MotorIsEnablePush_field_number: u32 = 65;
    pub const MotorSummonAndRidePush_field_number: u32 = 66;
    pub const BulletPatternPush_field_number: u32 = 67;
    pub const QuickHackRamVerifyPush_field_number: u32 = 68;
    pub const QuickHackOpenPush_field_number: u32 = 69;
    pub const DodgeInfoPush_field_number: u32 = 70;
    pub const CombatCommon_field_number: u32 = 1;
};
pub const CombatNotifyData = struct {
    Message: ?union(enum) {
    } = null,
    pub const CreateBulletNotify_field_number: u32 = 2;
    pub const DestroyBulletNotify_field_number: u32 = 3;
    pub const DamageExecuteNotify_field_number: u32 = 4;
    pub const ApplyGameplayEffectNotify_field_number: u32 = 5;
    pub const RemoveGameplayEffectNotify_field_number: u32 = 6;
    pub const HitNotify_field_number: u32 = 7;
    pub const SkillNotify_field_number: u32 = 8;
    pub const UseSkillNotify_field_number: u32 = 9;
    pub const EndSkillNotify_field_number: u32 = 10;
    pub const EntityLoadCompleteNotify_field_number: u32 = 11;
    pub const PartUpdateNotify_field_number: u32 = 12;
    pub const PartComponentInitNotify_field_number: u32 = 14;
    pub const MaterialNotify_field_number: u32 = 15;
    pub const GameplayCueNotify_field_number: u32 = 16;
    pub const EntityIsVisibleNotify_field_number: u32 = 17;
    pub const SwitchCharacterStateNotify_field_number: u32 = 18;
    pub const PlayerRebackSceneNotify_field_number: u32 = 19;
    pub const LogicStateInitNotify_field_number: u32 = 20;
    pub const SwitchLogicStateNotify_field_number: u32 = 21;
    pub const AttributeChangedNotify_field_number: u32 = 22;
    pub const AnimationStateChangedNotify_field_number: u32 = 23;
    pub const AnimationStateInitNotify_field_number: u32 = 24;
    pub const ModifyBulletParamsNotify_field_number: u32 = 25;
    pub const DrownNotify_field_number: u32 = 26;
    pub const OrderApplyBuffNotify_field_number: u32 = 27;
    pub const OrderRemoveBuffNotify_field_number: u32 = 28;
    pub const ActivateBuffNotify_field_number: u32 = 29;
    pub const OrderRemoveBuffByTagsNotify_field_number: u32 = 30;
    pub const AiInformationNotify_field_number: u32 = 31;
    pub const BattleStateChangeNotify_field_number: u32 = 32;
    pub const AnimationGameplayTagNotify_field_number: u32 = 33;
    pub const BoneVisibleChangeNotify_field_number: u32 = 34;
    pub const AiBlackboardCdNotify_field_number: u32 = 35;
    pub const CaughtNotify_field_number: u32 = 36;
    pub const EntityStaticHookMoveNotify_field_number: u32 = 37;
    pub const ChangeStateNotify_field_number: u32 = 38;
    pub const ChangeStateConfirmNotify_field_number: u32 = 40;
    pub const BuffStackCountNotify_field_number: u32 = 41;
    pub const MontagePlayNotify_field_number: u32 = 42;
    pub const ANStartNotify_field_number: u32 = 43;
    pub const FsmResetNotify_field_number: u32 = 44;
    pub const DamageRecordNotify_field_number: u32 = 45;
    pub const AiHateNotify_field_number: u32 = 46;
    pub const FsmBlackboardNotify_field_number: u32 = 47;
    pub const CharacterBattleStateChangeNotify_field_number: u32 = 48;
    pub const ApplyBuffS2cRequestNotify_field_number: u32 = 53;
    pub const RemoveBuffS2cRequestNotify_field_number: u32 = 54;
    pub const ActorVisibleNotify_field_number: u32 = 57;
    pub const RecoverPropChangedNotify_field_number: u32 = 58;
    pub const RemoveBuffByIdS2cRequestNotify_field_number: u32 = 59;
    pub const ShieldUpdateNotify_field_number: u32 = 61;
    pub const PlayerBattleStateChangeNotify_field_number: u32 = 62;
    pub const FsmCustomBlackboardNotify_field_number: u32 = 63;
    pub const PassiveSkillAddNotify_field_number: u32 = 64;
    pub const PassiveSkillRemoveNotify_field_number: u32 = 65;
    pub const ExecuteQteNotify_field_number: u32 = 66;
    pub const ModifyEntityCampNotify_field_number: u32 = 69;
    pub const AddCombineEntitiesRelationNotify_field_number: u32 = 70;
    pub const RemoveCombineRelationNotify_field_number: u32 = 71;
    pub const TestDamageRecordNotify_field_number: u32 = 72;
    pub const BuffDurationNotify_field_number: u32 = 73;
    pub const EntityLivingStatusNotify_field_number: u32 = 74;
    pub const NewLinkStateNotify_field_number: u32 = 75;
    pub const BroadcastAddBuffFailedNotify_field_number: u32 = 76;
    pub const PackAnimChangedNotify_field_number: u32 = 77;
    pub const VisionTriggerNotify_field_number: u32 = 78;
    pub const RemoveBuffByServerIdS2cRequestNotify_field_number: u32 = 79;
    pub const TransformBuffStackNotify_field_number: u32 = 80;
    pub const MotorSummonAndRideNotify_field_number: u32 = 81;
    pub const BulletPatternNotify_field_number: u32 = 82;
    pub const FsmMontageDurationNotify_field_number: u32 = 83;
    pub const CombatDataMaxNotify_field_number: u32 = 100;
    pub const CombatCommon_field_number: u32 = 1;
};
pub const CombatDataMaxNotify = struct {
    pub const msg_id: u16 = 26218;
};
pub const CombatRequestData = struct {
    Message: ?union(enum) {
    } = null,
    pub const CreateBulletRequest_field_number: u32 = 3;
    pub const DestroyBulletRequest_field_number: u32 = 4;
    pub const DamageExecuteRequest_field_number: u32 = 5;
    pub const ApplyGameplayEffectRequest_field_number: u32 = 6;
    pub const RemoveGameplayEffectRequest_field_number: u32 = 7;
    pub const HitRequest_field_number: u32 = 8;
    pub const HitEndRequest_field_number: u32 = 9;
    pub const SkillRequest_field_number: u32 = 10;
    pub const UseSkillRequest_field_number: u32 = 11;
    pub const EndSkillRequest_field_number: u32 = 12;
    pub const PartUpdateRequest_field_number: u32 = 13;
    pub const MaterialRequest_field_number: u32 = 14;
    pub const GameplayCueRequest_field_number: u32 = 15;
    pub const EntityIsVisibleRequest_field_number: u32 = 16;
    pub const SwitchCharacterStateRequest_field_number: u32 = 17;
    pub const LogicStateInitRequest_field_number: u32 = 18;
    pub const SwitchLogicStateRequest_field_number: u32 = 19;
    pub const AnimationStateChangedRequest_field_number: u32 = 20;
    pub const AnimationStateInitRequest_field_number: u32 = 21;
    pub const ModifyBulletParamsRequest_field_number: u32 = 22;
    pub const DrownRequest_field_number: u32 = 23;
    pub const OrderApplyBuffRequest_field_number: u32 = 24;
    pub const OrderRemoveBuffRequest_field_number: u32 = 25;
    pub const ActivateBuffRequest_field_number: u32 = 26;
    pub const OrderRemoveBuffByTagsRequest_field_number: u32 = 27;
    pub const AiInformationRequest_field_number: u32 = 28;
    pub const ToughCalcExtraRatioChangeRequest_field_number: u32 = 29;
    pub const BattleStateChangeRequest_field_number: u32 = 30;
    pub const AnimationGameplayTagRequest_field_number: u32 = 31;
    pub const BoneVisibleChangeRequest_field_number: u32 = 32;
    pub const AiBlackboardsRequest_field_number: u32 = 33;
    pub const AiBlackboardCdRequest_field_number: u32 = 34;
    pub const AiHateRequest_field_number: u32 = 35;
    pub const MonsterBoomRequest_field_number: u32 = 36;
    pub const CaughtRequest_field_number: u32 = 37;
    pub const EntityStaticHookMoveRequest_field_number: u32 = 38;
    pub const ChangeStateRequest_field_number: u32 = 39;
    pub const ChangeStateConfirmRequest_field_number: u32 = 40;
    pub const FsmConditionPassRequest_field_number: u32 = 41;
    pub const BuffStackCountRequest_field_number: u32 = 42;
    pub const ANStartRequest_field_number: u32 = 43;
    pub const UseSkillFailRequest_field_number: u32 = 44;
    pub const EnterViewDirectionRequest_field_number: u32 = 45;
    pub const ExitViewDirectionRequest_field_number: u32 = 46;
    pub const PassiveSkillAddRequest_field_number: u32 = 47;
    pub const InterruptSkillInDelayRequest_field_number: u32 = 49;
    pub const TriggerExitSkillRequest_field_number: u32 = 50;
    pub const ActorVisibleRequest_field_number: u32 = 55;
    pub const BuffEffectRequest_field_number: u32 = 56;
    pub const FragileChangeRequest_field_number: u32 = 57;
    pub const RTimeStopRequest_field_number: u32 = 58;
    pub const DrownEndTeleportRequest_field_number: u32 = 59;
    pub const MonsterDrownRequest_field_number: u32 = 60;
    pub const PassiveSkillRemoveRequest_field_number: u32 = 61;
    pub const RTimeStopInstRequest_field_number: u32 = 62;
    pub const FsmStateBehaviorRequest_field_number: u32 = 63;
    pub const FsmPlayMontageRequest_field_number: u32 = 64;
    pub const TsAnimNotifyStateAbsoluteTimeStopRequest_field_number: u32 = 65;
    pub const SwitchRoleRequest_field_number: u32 = 66;
    pub const RoleTagChangeRequest_field_number: u32 = 67;
    pub const ExecuteQteRequest_field_number: u32 = 68;
    pub const CharacterAttachRequest_field_number: u32 = 69;
    pub const CharacterDetachRequest_field_number: u32 = 70;
    pub const ClientCurrentRoleReportRequest_field_number: u32 = 71;
    pub const GaSwitchCommonEnemyProCampRequest_field_number: u32 = 72;
    pub const CombatMaxCaseMessageRequest_field_number: u32 = 99;
    pub const CombatCommon_field_number: u32 = 1;
    pub const RequestId_field_number: u32 = 2;
};
pub const CombatResponseData = struct {
    Message: ?union(enum) {
    } = null,
    pub const CreateBulletResponse_field_number: u32 = 3;
    pub const DestroyBulletResponse_field_number: u32 = 4;
    pub const DamageExecuteResponse_field_number: u32 = 5;
    pub const ApplyGameplayEffectResponse_field_number: u32 = 6;
    pub const RemoveGameplayEffectResponse_field_number: u32 = 7;
    pub const HitResponse_field_number: u32 = 8;
    pub const HitEndResponse_field_number: u32 = 9;
    pub const SkillResponse_field_number: u32 = 10;
    pub const UseSkillResponse_field_number: u32 = 11;
    pub const EndSkillResponse_field_number: u32 = 12;
    pub const PartUpdateResponse_field_number: u32 = 13;
    pub const MaterialResponse_field_number: u32 = 14;
    pub const GameplayCueResponse_field_number: u32 = 15;
    pub const EntityIsVisibleResponse_field_number: u32 = 16;
    pub const SwitchCharacterStateResponse_field_number: u32 = 17;
    pub const LogicStateInitResponse_field_number: u32 = 18;
    pub const SwitchLogicStateResponse_field_number: u32 = 19;
    pub const AnimationStateChangedResponse_field_number: u32 = 20;
    pub const AnimationStateInitResponse_field_number: u32 = 21;
    pub const ModifyBulletParamsResponse_field_number: u32 = 22;
    pub const DrownResponse_field_number: u32 = 23;
    pub const OrderApplyBuffResponse_field_number: u32 = 24;
    pub const OrderRemoveBuffResponse_field_number: u32 = 25;
    pub const ActivateBuffResponse_field_number: u32 = 26;
    pub const OrderRemoveBuffByTagsResponse_field_number: u32 = 27;
    pub const AiInformationResponse_field_number: u32 = 28;
    pub const ToughCalcExtraRatioChangeResponse_field_number: u32 = 29;
    pub const BattleStateChangeResponse_field_number: u32 = 30;
    pub const AnimationGameplayTagResponse_field_number: u32 = 31;
    pub const BoneVisibleChangeResponse_field_number: u32 = 32;
    pub const AiBlackboardsResponse_field_number: u32 = 33;
    pub const AiBlackboardCdResponse_field_number: u32 = 34;
    pub const AiHateResponse_field_number: u32 = 35;
    pub const MonsterBoomResponse_field_number: u32 = 36;
    pub const CaughtResponse_field_number: u32 = 37;
    pub const EntityStaticHookMoveResponse_field_number: u32 = 38;
    pub const ChangeStateResponse_field_number: u32 = 39;
    pub const ChangeStateConfirmResponse_field_number: u32 = 40;
    pub const FsmConditionPassResponse_field_number: u32 = 41;
    pub const BuffStackCountResponse_field_number: u32 = 42;
    pub const ANStartResponse_field_number: u32 = 43;
    pub const UseSkillFailResponse_field_number: u32 = 44;
    pub const EnterViewDirectionResponse_field_number: u32 = 45;
    pub const ExitViewDirectionResponse_field_number: u32 = 46;
    pub const PassiveSkillAddResponse_field_number: u32 = 47;
    pub const InterruptSkillInDelayResponse_field_number: u32 = 49;
    pub const TriggerExitSkillResponse_field_number: u32 = 50;
    pub const ActorVisibleResponse_field_number: u32 = 55;
    pub const BuffEffectResponse_field_number: u32 = 56;
    pub const FragileChangeResponse_field_number: u32 = 57;
    pub const RTimeStopResponse_field_number: u32 = 58;
    pub const DrownEndTeleportResponse_field_number: u32 = 59;
    pub const MonsterDrownResponse_field_number: u32 = 60;
    pub const PassiveSkillRemoveResponse_field_number: u32 = 61;
    pub const RTimeStopInstResponse_field_number: u32 = 62;
    pub const FsmStateBehaviorResponse_field_number: u32 = 63;
    pub const FsmPlayMontageResponse_field_number: u32 = 64;
    pub const TsAnimNotifyStateAbsoluteTimeStopResponse_field_number: u32 = 65;
    pub const SwitchRoleResponse_field_number: u32 = 66;
    pub const RoleTagChangeResponse_field_number: u32 = 67;
    pub const ExecuteQteResponse_field_number: u32 = 68;
    pub const CharacterAttachResponse_field_number: u32 = 69;
    pub const CharacterDetachResponse_field_number: u32 = 70;
    pub const ClientCurrentRoleReportResponse_field_number: u32 = 71;
    pub const GaSwitchCommonEnemyProCampResponse_field_number: u32 = 72;
    pub const CombatDataMaxResponse_field_number: u32 = 100;
    pub const CombatCommon_field_number: u32 = 1;
    pub const RequestId_field_number: u32 = 2;
};
pub const CombatDataMaxResponse = struct {
};
pub const CombatSendData = struct {
    Message: ?union(enum) {
    } = null,
    pub const Push_field_number: u32 = 2;
    pub const Request_field_number: u32 = 3;
};
pub const CombatReceiveData = struct {
    Message: ?union(enum) {
    } = null,
    pub const CombatNotifyData_field_number: u32 = 2;
    pub const CombatResponseData_field_number: u32 = 3;
};
pub const CombatSendPackRequest = struct {
    pub const msg_id: u16 = 21430;
    pub const Data_field_number: u32 = 6;
    pub const HostPlayerId_field_number: u32 = 4;
};
pub const CombatSendPackResponse = struct {
    pub const msg_id: u16 = 29680;
    pub const ErrorCode_field_number: u32 = 4;
    pub const ReceivePackNotify_field_number: u32 = 3;
};
pub const CombatReceivePackNotify = struct {
    pub const msg_id: u16 = 27783;
    pub const Data_field_number: u32 = 14;
};
pub const CombatMaxCaseMessageRequest = struct {
    pub const msg_id: u16 = 26975;
};
pub const EntityLoadCompleteNotify = struct {
    pub const msg_id: u16 = 22803;
    pub const PlayerId_field_number: u32 = 14;
    pub const EntityIds_field_number: u32 = 12;
    pub const EntityIdsUnload_field_number: u32 = 3;
};
pub const MaterialRequest = struct {
    pub const msg_id: u16 = 20595;
    pub const MaterialInfo_field_number: u32 = 5;
    pub const CombatCommon_field_number: u32 = 3;
};
pub const MaterialPush = struct {
    pub const msg_id: u16 = 26588;
    pub const MaterialInfo_field_number: u32 = 6;
    pub const CombatCommon_field_number: u32 = 7;
};
pub const MaterialInfo = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const AssetName_field_number: u32 = 2;
    pub const IsGroup_field_number: u32 = 3;
};
pub const MaterialResponse = struct {
    pub const msg_id: u16 = 29768;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const MaterialNotify = struct {
    pub const msg_id: u16 = 24215;
    pub const MaterialInfo_field_number: u32 = 12;
    pub const CombatCommon_field_number: u32 = 13;
};
pub const DynamicEntityInformation = struct {
    pub const Id_field_number: u32 = 1;
    pub const EntityType_field_number: u32 = 2;
    pub const ConfigId_field_number: u32 = 3;
    pub const PlayerId_field_number: u32 = 4;
    pub const OwnerId_field_number: u32 = 5;
    pub const MovementInformation_field_number: u32 = 6;
    pub const GameAttributes_field_number: u32 = 7;
    pub const InitAttribute_field_number: u32 = 8;
    pub const IsVisible_field_number: u32 = 9;
    pub const AnimationStates_field_number: u32 = 10;
    pub const InitGameplayTag_field_number: u32 = 11;
    pub const GameplayTags_field_number: u32 = 12;
    pub const Level_field_number: u32 = 13;
    pub const BlackboardParams_field_number: u32 = 14;
    pub const Tags_field_number: u32 = 15;
    pub const PrivateTags_field_number: u32 = 16;
    pub const DeathStatus_field_number: u32 = 17;
    pub const HardnessModeId_field_number: u32 = 19;
    pub const PartLifeInfos_field_number: u32 = 20;
    pub const VisionSkillInfos_field_number: u32 = 21;
    pub const FightBuffInfos_field_number: u32 = 22;
    pub const CreatureGroup_field_number: u32 = 23;
    pub const ListenInformation_field_number: u32 = 24;
    pub const SysBuffInfos_field_number: u32 = 25;
    pub const LivingStatus_field_number: u32 = 26;
    pub const EntityCommonTags_field_number: u32 = 27;
    pub const WeaponConfId_field_number: u32 = 28;
    pub const DurabilityValue_field_number: u32 = 29;
    pub const InitLocation_field_number: u32 = 30;
    pub const SummonInfo_field_number: u32 = 31;
    pub const ComponentPbs_field_number: u32 = 32;
};
pub const EntityLivingStatusNotify = struct {
    pub const msg_id: u16 = 28600;
    pub const Id_field_number: u32 = 8;
    pub const LivingStatus_field_number: u32 = 15;
    pub const DropVisionItem_field_number: u32 = 4;
};
pub const DropVisionItemResult = struct {
    pub const PlayerId_field_number: u32 = 1;
    pub const Drop_field_number: u32 = 2;
};
pub const ListenInformation = struct {
    pub const Id_field_number: u32 = 1;
    pub const Range_field_number: u32 = 2;
};
pub const ScenePlayerInformation = struct {
    pub const PlayerId_field_number: u32 = 1;
    pub const PlayerName_field_number: u32 = 2;
    pub const PlayerIcon_field_number: u32 = 3;
    pub const Level_field_number: u32 = 4;
    pub const GuildName_field_number: u32 = 5;
    pub const GuildIntro_field_number: u32 = 6;
    pub const Location_field_number: u32 = 7;
    pub const IsOffline_field_number: u32 = 8;
    pub const PlayerPrefix_field_number: u32 = 9;
    pub const PlayerGEIncHandle_field_number: u32 = 10;
    pub const FightRoleInfos_field_number: u32 = 11;
    pub const Rotation_field_number: u32 = 13;
    pub const GroupType_field_number: u32 = 14;
    pub const CurRole_field_number: u32 = 15;
    pub const VehiclePlayerData_field_number: u32 = 16;
    pub const Gravity_field_number: u32 = 17;
    pub const AreaId_field_number: u32 = 18;
};
pub const GroupFormation = struct {
    pub const PlayerId_field_number: u32 = 1;
    pub const FightRoleInfos_field_number: u32 = 2;
    pub const CurrentGroupType_field_number: u32 = 3;
};
pub const FightRoleInfo = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const EntityId_field_number: u32 = 2;
    pub const OnStageWithoutControl_field_number: u32 = 3;
};
pub const FightRoleInfos = struct {
    pub const GroupType_field_number: u32 = 1;
    pub const FightRoleInfos_field_number: u32 = 2;
    pub const CurRole_field_number: u32 = 3;
    pub const LivingStatus_field_number: u32 = 4;
    pub const IsFixedLocation_field_number: u32 = 5;
};
pub const UpdateGroupFormationNotify = struct {
    pub const msg_id: u16 = 17867;
    pub const GroupFormation_field_number: u32 = 2;
};
pub const SceneInformation = struct {
    pub const SceneId_field_number: u32 = 1;
    pub const InstanceId_field_number: u32 = 2;
    pub const OwnerId_field_number: u32 = 3;
    pub const PlayerInfos_field_number: u32 = 4;
    pub const DynamicEntityList_field_number: u32 = 5;
    pub const BlackboardParams_field_number: u32 = 6;
    pub const EndTime_field_number: u32 = 8;
    pub const AoiData_field_number: u32 = 11;
    pub const OwnerFinishMingSuGens_field_number: u32 = 12;
    pub const Mode_field_number: u32 = 13;
    pub const TimeInfo_field_number: u32 = 14;
    pub const HostFogIds_field_number: u32 = 15;
    pub const LoadedSubLevels_field_number: u32 = 16;
    pub const AreaStates_field_number: u32 = 17;
    pub const ResetPointEntityId_field_number: u32 = 18;
    pub const DataLayers_field_number: u32 = 19;
    pub const AreaMpc_field_number: u32 = 20;
    pub const CurContextId_field_number: u32 = 21;
    pub const AudioState_field_number: u32 = 23;
    pub const SceneBulletOwnerId_field_number: u32 = 24;
    pub const SceneTraceId_field_number: u32 = 25;
    pub const HideSubLevels_field_number: u32 = 26;
    pub const LastHighLevelArea_field_number: u32 = 27;
    pub const EnableRoads_field_number: u32 = 28;
};
pub const SceneAreaState = struct {
    pub const AreaId_field_number: u32 = 1;
    pub const State_field_number: u32 = 2;
};
pub const HostTeleportUnlockNotify = struct {
    pub const msg_id: u16 = 19715;
    pub const HostPlayerId_field_number: u32 = 9;
    pub const HostTeleportId_field_number: u32 = 4;
};
pub const SceneTimeInfo = struct {
    pub const Hour_field_number: u32 = 1;
    pub const Minute_field_number: u32 = 2;
    pub const OwnerTimeClockTimeSpan_field_number: u32 = 3;
};
pub const JoinSceneNotify = struct {
    pub const msg_id: u16 = 24702;
    pub const SceneInfo_field_number: u32 = 11;
    pub const MaxEntityId_field_number: u32 = 14;
    pub const TransitionOption_field_number: u32 = 9;
};
pub const SceneTraceRequest = struct {
    pub const msg_id: u16 = 22453;
    pub const SceneTraceId_field_number: u32 = 5;
};
pub const SceneTraceResponse = struct {
    pub const msg_id: u16 = 20031;
};
pub const AfterJoinSceneNotify = struct {
    pub const msg_id: u16 = 21950;
};
pub const LeaveSceneNotify = struct {
    pub const msg_id: u16 = 21946;
    pub const PlayerId_field_number: u32 = 4;
    pub const SceneId_field_number: u32 = 1;
    pub const TransitionOption_field_number: u32 = 13;
};
pub const MovingEntityData = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const Originator_field_number: u32 = 2;
    pub const MoveInfos_field_number: u32 = 3;
    pub const ForcePush_field_number: u32 = 4;
};
pub const MovePackagePush = struct {
    pub const msg_id: u16 = 17573;
    pub const MovingEntities_field_number: u32 = 8;
    pub const SceneOwnerId_field_number: u32 = 11;
};
pub const MovePackageNotify = struct {
    pub const msg_id: u16 = 23017;
    pub const MovingEntities_field_number: u32 = 8;
};
pub const EntitySimplyMoveInfoPackagePush = struct {
    pub const msg_id: u16 = 22126;
    pub const MoveInfos_field_number: u32 = 2;
    pub const SceneOwnerId_field_number: u32 = 10;
};
pub const RemoveSummonEntityRequest = struct {
    pub const msg_id: u16 = 23132;
    pub const SummonerId_field_number: u32 = 13;
    pub const SkillId_field_number: u32 = 6;
    pub const RemoveType_field_number: u32 = 14;
    pub const RemoveENtityIds_field_number: u32 = 4;
};
pub const RemoveSummonEntityResponse = struct {
    pub const msg_id: u16 = 21424;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const EntityOnLandedRequest = struct {
    pub const msg_id: u16 = 29272;
    pub const EntityId_field_number: u32 = 3;
};
pub const EntityOnLandedResponse = struct {
    pub const msg_id: u16 = 29410;
};
pub const AttributeChangedRequest = struct {
    pub const msg_id: u16 = 17525;
    pub const Id_field_number: u32 = 15;
    pub const Attributes_field_number: u32 = 14;
};
pub const AttributeChangedResponse = struct {
    pub const msg_id: u16 = 19459;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const AttributeChangedNotify = struct {
    pub const msg_id: u16 = 27104;
    pub const Attributes_field_number: u32 = 10;
};
pub const AnimationStateInitRequest = struct {
    pub const msg_id: u16 = 29564;
    pub const CombatCommon_field_number: u32 = 13;
    pub const Id_field_number: u32 = 9;
    pub const States_field_number: u32 = 3;
    pub const SpecialStates_field_number: u32 = 14;
    pub const ModelId_field_number: u32 = 8;
};
pub const AnimationStateInitPush = struct {
    pub const msg_id: u16 = 15019;
    pub const CombatCommon_field_number: u32 = 15;
    pub const Id_field_number: u32 = 1;
    pub const States_field_number: u32 = 7;
    pub const SpecialStates_field_number: u32 = 10;
    pub const ModelId_field_number: u32 = 4;
};
pub const AnimationStateInitResponse = struct {
    pub const msg_id: u16 = 25726;
    pub const ErrorCode_field_number: u32 = 4;
};
pub const AnimationStateInitNotify = struct {
    pub const msg_id: u16 = 29050;
    pub const CombatCommon_field_number: u32 = 15;
    pub const Id_field_number: u32 = 3;
    pub const States_field_number: u32 = 11;
    pub const TimeStamp_field_number: u32 = 12;
    pub const SpecialStates_field_number: u32 = 13;
    pub const ModelId_field_number: u32 = 8;
};
pub const AnimationStateChangedRequest = struct {
    pub const msg_id: u16 = 15115;
    pub const CombatCommon_field_number: u32 = 10;
    pub const Id_field_number: u32 = 14;
    pub const States_field_number: u32 = 12;
    pub const SpecialStates_field_number: u32 = 8;
    pub const ModelId_field_number: u32 = 2;
};
pub const AnimationStateChangedPush = struct {
    pub const msg_id: u16 = 29396;
    pub const CombatCommon_field_number: u32 = 1;
    pub const Id_field_number: u32 = 10;
    pub const States_field_number: u32 = 15;
    pub const SpecialStates_field_number: u32 = 5;
    pub const ModelId_field_number: u32 = 12;
};
pub const AnimationStateChangedResponse = struct {
    pub const msg_id: u16 = 19053;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const AnimationStateChangedNotify = struct {
    pub const msg_id: u16 = 16544;
    pub const CombatCommon_field_number: u32 = 11;
    pub const Id_field_number: u32 = 9;
    pub const States_field_number: u32 = 14;
    pub const TimeStamp_field_number: u32 = 13;
    pub const SpecialStates_field_number: u32 = 15;
    pub const ModelId_field_number: u32 = 3;
};
pub const AnimStateChangeInfo = struct {
    pub const AnimationStates_field_number: u32 = 1;
    pub const SpecialAnimationStates_field_number: u32 = 2;
    pub const ModelId_field_number: u32 = 3;
};
pub const AnimStateChangeInfoList = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const AnimStateChangeInfo_field_number: u32 = 2;
};
pub const PackAnimChangedNotify = struct {
    pub const msg_id: u16 = 22007;
    pub const EntityAnimState_field_number: u32 = 14;
};
pub const EntityCommonTagNotify = struct {
    pub const msg_id: u16 = 27236;
    pub const Id_field_number: u32 = 5;
    pub const Tags_field_number: u32 = 8;
};
pub const SummonRequestInfo = struct {
    pub const SummonEntityId_field_number: u32 = 1;
    pub const SkillId_field_number: u32 = 2;
    pub const SummonConfigId_field_number: u32 = 3;
    pub const Pos_field_number: u32 = 4;
    pub const Rot_field_number: u32 = 5;
    pub const IsVisible_field_number: u32 = 6;
};
pub const SummonRequest = struct {
    pub const msg_id: u16 = 17249;
    pub const SummonerEntityId_field_number: u32 = 15;
    pub const SummonInfo_field_number: u32 = 7;
};
pub const SummonResponse = struct {
    pub const msg_id: u16 = 28242;
    pub const ErrorCode_field_number: u32 = 3;
};
pub const Summon3Request = struct {
    pub const msg_id: u16 = 26738;
    pub const SummonerEntityId_field_number: u32 = 13;
    pub const SummonInfo_field_number: u32 = 3;
};
pub const Summon3Response = struct {
    pub const msg_id: u16 = 28474;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const SummonEntityNotify = struct {
    pub const msg_id: u16 = 22558;
    pub const SummonerId_field_number: u32 = 6;
    pub const SummonIds_field_number: u32 = 2;
};
pub const UpdateSceneDateRequest = struct {
    pub const msg_id: u16 = 28810;
    pub const AddDays_field_number: u32 = 3;
    pub const Hour_field_number: u32 = 9;
    pub const Minute_field_number: u32 = 12;
    pub const Reason_field_number: u32 = 1;
};
pub const UpdateSceneDateResponse = struct {
    pub const msg_id: u16 = 17269;
    pub const ErrorCode_field_number: u32 = 15;
    pub const CurrDate_field_number: u32 = 11;
};
pub const PlayerSceneAoiData = struct {
    pub const DynamicEntityList_field_number: u32 = 1;
    pub const GenIds_field_number: u32 = 2;
    pub const Entities_field_number: u32 = 3;
};
pub const SummonInfo = struct {
    pub const SummonCfgId_field_number: u32 = 1;
    pub const SummonerId_field_number: u32 = 2;
    pub const SummonSkillId_field_number: u32 = 3;
};
pub const WeatherControlInfoWithoutCheckAsyncRequest = struct {
    pub const msg_id: u16 = 16268;
};
pub const WeatherControlInfoWithoutCheckAsyncResponse = struct {
    pub const msg_id: u16 = 27291;
    pub const UnlockedWeatherSwitchConfigIdList_field_number: u32 = 13;
};
pub const EntityFollowTrackRequest = struct {
    pub const msg_id: u16 = 16415;
    pub const EntityId_field_number: u32 = 6;
};
pub const EntityFollowTrackResponse = struct {
    pub const msg_id: u16 = 27755;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const PlayerRebackSceneNotify = struct {
    pub const msg_id: u16 = 22786;
    pub const EntityId_field_number: u32 = 14;
};
pub const DrownRequest = struct {
    pub const msg_id: u16 = 19185;
};
pub const DrownPush = struct {
    pub const msg_id: u16 = 18025;
};
pub const DrownResponse = struct {
    pub const msg_id: u16 = 28206;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const DrownNotify = struct {
    pub const msg_id: u16 = 19577;
};
pub const DrownEndTeleportRequest = struct {
    pub const msg_id: u16 = 16593;
};
pub const DrownEndTeleportPush = struct {
    pub const msg_id: u16 = 18456;
    ycu: ?union(enum) {
    } = null,
    pub const TeleportPos_field_number: u32 = 15;
};
pub const DrownEndTeleportResponse = struct {
    pub const msg_id: u16 = 29224;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const MonsterDrownRequest = struct {
    pub const msg_id: u16 = 19568;
    pub const Pos_field_number: u32 = 10;
};
pub const MonsterDrownPush = struct {
    pub const msg_id: u16 = 17504;
    pub const Pos_field_number: u32 = 9;
};
pub const MonsterDrownResponse = struct {
    pub const msg_id: u16 = 20244;
    pub const ErrorCode_field_number: u32 = 5;
};
pub const SceneLoadingFinishRequest = struct {
    pub const msg_id: u16 = 18077;
    pub const SceneId_field_number: u32 = 2;
};
pub const SceneLoadingFinishResponse = struct {
    pub const msg_id: u16 = 23226;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const UpdateVoxelEnvRequest = struct {
    pub const msg_id: u16 = 21822;
    pub const ServerCaveMode_field_number: u32 = 11;
};
pub const UpdateVoxelEnvResponse = struct {
    pub const msg_id: u16 = 27036;
    pub const ErrorCode_field_number: u32 = 8;
    pub const ServerCaveMode_field_number: u32 = 3;
};
pub const SceneRoadSyncNotify = struct {
    pub const msg_id: u16 = 26641;
    pub const SceneId_field_number: u32 = 6;
    pub const InstanceId_field_number: u32 = 13;
    pub const EnabledRoads_field_number: u32 = 15;
};
pub const MontageContext = struct {
    pub const SkillId_field_number: u32 = 1;
    pub const MontageIndex_field_number: u32 = 2;
    pub const ConstateId_field_number: u32 = 3;
};
pub const HitInformation = struct {
    pub const Originator_field_number: u32 = 1;
    pub const Id_field_number: u32 = 2;
    pub const TargetId_field_number: u32 = 3;
    pub const BulletId_field_number: u32 = 4;
    pub const HasBeHitData_field_number: u32 = 5;
    pub const HitEffectPos_field_number: u32 = 6;
    pub const HitEffectRotate_field_number: u32 = 7;
    pub const IsShake_field_number: u32 = 8;
    pub const HitPos_field_number: u32 = 9;
    pub const EnterFk_field_number: u32 = 10;
    pub const IsHitWeakness_field_number: u32 = 11;
    pub const IsTriggerCounterattack_field_number: u32 = 12;
    pub const VictimRotation_field_number: u32 = 13;
    pub const IsChangeVictimRotation_field_number: u32 = 14;
    pub const HitPart_field_number: u32 = 15;
    pub const IsTriggerVisionCounterAttack_field_number: u32 = 16;
    pub const SkillId_field_number: u32 = 17;
    pub const FightState_field_number: u32 = 18;
    pub const BeHitAnim_field_number: u32 = 19;
    pub const Source_field_number: u32 = 20;
    pub const PhantomSkillIdentify_field_number: u32 = 21;
};
pub const CounterAttackInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const FightState_field_number: u32 = 2;
    pub const TriggerCounterType_field_number: u32 = 3;
    pub const CounterAnIndex_field_number: u32 = 4;
};
pub const SkillNodeInfo = struct {
    pub const SubProtocol_field_number: u32 = 1;
    pub const MontageIndex_field_number: u32 = 2;
    pub const SpeedRatio_field_number: u32 = 3;
    pub const SkillSingleId_field_number: u32 = 4;
    pub const SkillIndex_field_number: u32 = 5;
    pub const StartSection_field_number: u32 = 6;
    pub const StartTimeSeconds_field_number: u32 = 7;
};
pub const SkillRequest = struct {
    pub const msg_id: u16 = 16541;
    pub const UseSkillInfo_field_number: u32 = 4;
    pub const SkillNodeInfos_field_number: u32 = 15;
};
pub const SkillResponse = struct {
    pub const msg_id: u16 = 26642;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const SkillNotify = struct {
    pub const msg_id: u16 = 25519;
    pub const UseSkillInfo_field_number: u32 = 12;
    pub const SkillNodeInfos_field_number: u32 = 9;
};
pub const UseSkillRequest = struct {
    pub const msg_id: u16 = 17540;
    pub const CombatCommon_field_number: u32 = 3;
    pub const UseSkillInfo_field_number: u32 = 1;
    pub const SkillSingleId_field_number: u32 = 5;
    pub const BattleFlags_field_number: u32 = 10;
};
pub const UseSkillResponse = struct {
    pub const msg_id: u16 = 17977;
    pub const UseSkillInfo_field_number: u32 = 8;
    pub const SkillSingleId_field_number: u32 = 4;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const UseSkillNotify = struct {
    pub const msg_id: u16 = 18004;
    pub const CombatCommon_field_number: u32 = 11;
    pub const UseSkillInfo_field_number: u32 = 9;
    pub const SkillSingleId_field_number: u32 = 10;
};
pub const InterruptSkillInfo = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const SkillId_field_number: u32 = 2;
    pub const BulletId_field_number: u32 = 3;
};
pub const EndSkillRequest = struct {
    pub const msg_id: u16 = 21923;
    pub const CombatCommon_field_number: u32 = 7;
    pub const UseSkillInfo_field_number: u32 = 2;
    pub const SkillSingleId_field_number: u32 = 6;
    pub const Reason_field_number: u32 = 8;
    pub const InterruptSkillInfo_field_number: u32 = 13;
};
pub const EndSkillPush = struct {
    pub const msg_id: u16 = 20417;
    pub const CombatCommon_field_number: u32 = 4;
    pub const UseSkillInfo_field_number: u32 = 8;
    pub const SkillSingleId_field_number: u32 = 6;
    pub const Reason_field_number: u32 = 12;
    pub const InterruptSkillInfo_field_number: u32 = 13;
};
pub const EndSkillResponse = struct {
    pub const msg_id: u16 = 17824;
    pub const UseSkillInfo_field_number: u32 = 13;
    pub const SkillSingleId_field_number: u32 = 7;
    pub const ErrorCode_field_number: u32 = 9;
};
pub const EndSkillNotify = struct {
    pub const msg_id: u16 = 24698;
    pub const CombatCommon_field_number: u32 = 1;
    pub const UseSkillInfo_field_number: u32 = 10;
    pub const SkillSingleId_field_number: u32 = 11;
};
pub const InterruptSkillInDelayRequest = struct {
    pub const msg_id: u16 = 26516;
    pub const SkillId_field_number: u32 = 8;
};
pub const InterruptSkillInDelayPush = struct {
    pub const msg_id: u16 = 20045;
    pub const SkillId_field_number: u32 = 15;
};
pub const InterruptSkillInDelayResponse = struct {
    pub const msg_id: u16 = 18325;
    pub const SkillId_field_number: u32 = 8;
    pub const ErrorCode_field_number: u32 = 2;
};
pub const UseSkillFailRequest = struct {
    pub const msg_id: u16 = 20384;
    pub const SkillId_field_number: u32 = 9;
};
pub const UseSkillFailPush = struct {
    pub const msg_id: u16 = 26026;
    pub const SkillId_field_number: u32 = 5;
};
pub const UseSkillFailResponse = struct {
    pub const msg_id: u16 = 23723;
    pub const SkillId_field_number: u32 = 13;
    pub const Error_field_number: u32 = 5;
};
pub const CounterAttackPush = struct {
    pub const msg_id: u16 = 15091;
    pub const CounterAttackInfo_field_number: u32 = 3;
};
pub const HitRequest = struct {
    pub const msg_id: u16 = 17801;
    pub const CombatCommon_field_number: u32 = 1;
    pub const HitInfo_field_number: u32 = 3;
    pub const SkillMessageId_field_number: u32 = 12;
};
pub const HitResponse = struct {
    pub const msg_id: u16 = 22229;
    pub const HitInfo_field_number: u32 = 10;
    pub const ErrorCode_field_number: u32 = 7;
};
pub const HitNotify = struct {
    pub const msg_id: u16 = 22832;
    pub const CombatCommon_field_number: u32 = 5;
    pub const HitInfo_field_number: u32 = 2;
};
pub const HitEndRequest = struct {
    pub const msg_id: u16 = 28975;
    pub const CombatCommon_field_number: u32 = 2;
    pub const TargetId_field_number: u32 = 15;
};
pub const HitEndPush = struct {
    pub const msg_id: u16 = 19045;
    pub const CombatCommon_field_number: u32 = 10;
    pub const TargetId_field_number: u32 = 8;
};
pub const HitEndResponse = struct {
    pub const msg_id: u16 = 18488;
    pub const ErrorCode_field_number: u32 = 2;
};
pub const CaughtInfo = struct {
    pub const Attacker_field_number: u32 = 1;
    pub const CaughtInfoId_field_number: u32 = 2;
    pub const IsEnd_field_number: u32 = 3;
    pub const FightState_field_number: u32 = 4;
};
pub const CaughtRequest = struct {
    pub const msg_id: u16 = 29690;
    pub const Info_field_number: u32 = 6;
};
pub const CaughtPush = struct {
    pub const msg_id: u16 = 21930;
    pub const Info_field_number: u32 = 10;
};
pub const CaughtResponse = struct {
    pub const msg_id: u16 = 26880;
    pub const ErrorCode_field_number: u32 = 7;
};
pub const CaughtNotify = struct {
    pub const msg_id: u16 = 23930;
    pub const Info_field_number: u32 = 6;
};
pub const ActiveBulletHandle = struct {
    pub const PlayerId_field_number: u32 = 1;
    pub const HandleId_field_number: u32 = 2;
};
pub const CreateBulletRequest = struct {
    pub const msg_id: u16 = 20984;
    ParentHandle: ?union(enum) {
    } = null,
    pub const BulletHandle_field_number: u32 = 13;
    pub const CombatCommon_field_number: u32 = 10;
    pub const Handle_field_number: u32 = 14;
    pub const OwnerEntityId_field_number: u32 = 5;
    pub const BulletId_field_number: u32 = 6;
    pub const SkillId_field_number: u32 = 11;
    pub const Location_field_number: u32 = 1;
    pub const Rotation_field_number: u32 = 7;
    pub const TargetId_field_number: u32 = 15;
    pub const SpawnEntityId_field_number: u32 = 4;
    pub const SpawnVelocityEntityId_field_number: u32 = 9;
    pub const IsLocal_field_number: u32 = 3;
    pub const DtType_field_number: u32 = 2;
    pub const RandomPosOffset_field_number: u32 = 12;
    pub const RandomInitSpeedOffset_field_number: u32 = 8;
};
pub const CreateBulletResponsePush = struct {
    pub const msg_id: u16 = 23111;
    ParentHandle: ?union(enum) {
    } = null,
    pub const BulletHandle_field_number: u32 = 12;
    pub const CombatCommon_field_number: u32 = 3;
    pub const Handle_field_number: u32 = 6;
    pub const OwnerEntityId_field_number: u32 = 7;
    pub const BulletId_field_number: u32 = 11;
    pub const SkillId_field_number: u32 = 10;
    pub const Location_field_number: u32 = 2;
    pub const Rotation_field_number: u32 = 13;
    pub const TargetId_field_number: u32 = 9;
    pub const SpawnEntityId_field_number: u32 = 8;
    pub const SpawnVelocityEntityId_field_number: u32 = 5;
    pub const IsLocal_field_number: u32 = 1;
    pub const DtType_field_number: u32 = 4;
    pub const RandomPosOffset_field_number: u32 = 15;
    pub const RandomInitSpeedOffset_field_number: u32 = 14;
};
pub const CreateBulletResponse = struct {
    pub const msg_id: u16 = 18324;
    pub const ErrorCode_field_number: u32 = 7;
};
pub const CreateBulletNotify = struct {
    pub const msg_id: u16 = 24878;
    ParentHandle: ?union(enum) {
    } = null,
    LocationId: ?union(enum) {
    } = null,
    pub const BulletHandle_field_number: u32 = 214;
    pub const LocationEntityId_field_number: u32 = 60;
    pub const CombatCommon_field_number: u32 = 126;
    pub const Handle_field_number: u32 = 211;
    pub const OwnerEntityId_field_number: u32 = 29;
    pub const BulletId_field_number: u32 = 244;
    pub const SkillId_field_number: u32 = 55;
    pub const Location_field_number: u32 = 67;
    pub const Rotation_field_number: u32 = 239;
    pub const TargetId_field_number: u32 = 114;
    pub const SpawnEntityId_field_number: u32 = 167;
    pub const SpawnVelocityEntityId_field_number: u32 = 24;
    pub const TarLocation_field_number: u32 = 227;
    pub const DtType_field_number: u32 = 26;
    pub const Size_field_number: u32 = 134;
    pub const RandomPosOffset_field_number: u32 = 212;
    pub const RandomInitSpeedOffset_field_number: u32 = 76;
    pub const HitCase_field_number: u32 = 200;
};
pub const DestroyBulletRequest = struct {
    pub const msg_id: u16 = 24707;
    pub const CombatCommon_field_number: u32 = 15;
    pub const Handle_field_number: u32 = 9;
};
pub const DestroyBulletResponsePush = struct {
    pub const msg_id: u16 = 22024;
    pub const CombatCommon_field_number: u32 = 2;
    pub const Handle_field_number: u32 = 8;
};
pub const DestroyBulletResponse = struct {
    pub const msg_id: u16 = 21020;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const DestroyBulletNotify = struct {
    pub const msg_id: u16 = 26875;
    pub const CombatCommon_field_number: u32 = 15;
    pub const Handle_field_number: u32 = 2;
    pub const IsCreateSubBullet_field_number: u32 = 7;
};
pub const ModifyBulletParams = struct {
    pub const CombatCommon_field_number: u32 = 1;
    pub const Handle_field_number: u32 = 2;
    pub const TargetId_field_number: u32 = 3;
};
pub const ModifyBulletParamsRequest = struct {
    pub const msg_id: u16 = 17397;
    pub const ModifyBulletParams_field_number: u32 = 14;
};
pub const ModifyBulletParamsPush = struct {
    pub const msg_id: u16 = 20730;
    pub const ModifyBulletParams_field_number: u32 = 8;
};
pub const ModifyBulletParamsResponse = struct {
    pub const msg_id: u16 = 26453;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const ModifyBulletParamsNotify = struct {
    pub const msg_id: u16 = 18305;
    pub const ModifyBulletParams_field_number: u32 = 13;
};
pub const DamageContext = struct {
    Source: ?union(enum) {
    } = null,
    Bullet: ?union(enum) {
    } = null,
    Skill: ?union(enum) {
    } = null,
    SkillMessage: ?union(enum) {
    } = null,
    pub const SourceType_field_number: u32 = 1;
    pub const BulletId_field_number: u32 = 2;
    pub const SkillId_field_number: u32 = 4;
    pub const SkillMessageId_field_number: u32 = 5;
    pub const BulletTags_field_number: u32 = 3;
};
pub const DamageExecuteRequest = struct {
    pub const msg_id: u16 = 23274;
    pub const DamageId_field_number: u32 = 3;
    pub const SkillLevel_field_number: u32 = 15;
    pub const AttackerEntityId_field_number: u32 = 13;
    pub const TargetEntityId_field_number: u32 = 6;
    pub const IsAddEnergy_field_number: u32 = 10;
    pub const IsCounterAttack_field_number: u32 = 5;
    pub const ForceCritical_field_number: u32 = 2;
    pub const IsBlocked_field_number: u32 = 1;
    pub const PartIndex_field_number: u32 = 14;
    pub const CounterSkillMessageId_field_number: u32 = 9;
    pub const DamageContext_field_number: u32 = 8;
    pub const RandomSeed_field_number: u32 = 7;
    pub const IsBreakWeakness_field_number: u32 = 11;
};
pub const DamageExecuteResponse = struct {
    pub const msg_id: u16 = 22365;
    pub const ErrorCode_field_number: u32 = 6;
    pub const AttackerEntityId_field_number: u32 = 15;
    pub const TargetEntityId_field_number: u32 = 4;
    pub const Damage_field_number: u32 = 3;
    pub const PartIndex_field_number: u32 = 1;
    pub const IsCrit_field_number: u32 = 14;
    pub const KilledTarget_field_number: u32 = 11;
    pub const ShieldCoverDamage_field_number: u32 = 2;
    pub const ImmuneType_field_number: u32 = 13;
    pub const ElementType_field_number: u32 = 9;
    pub const ChangeLife_field_number: u32 = 8;
    pub const ChangeWeakness_field_number: u32 = 7;
};
pub const DamageExecuteNotify = struct {
    pub const msg_id: u16 = 15695;
    pub const DamageId_field_number: u32 = 14;
    pub const AttackerEntityId_field_number: u32 = 13;
    pub const TargetEntityId_field_number: u32 = 2;
    pub const Damage_field_number: u32 = 9;
    pub const PartIndex_field_number: u32 = 3;
    pub const IsCrit_field_number: u32 = 10;
    pub const KilledTarget_field_number: u32 = 1;
    pub const ShieldCoverDamage_field_number: u32 = 12;
    pub const SkillLevel_field_number: u32 = 8;
    pub const DamageContext_field_number: u32 = 5;
    pub const ImmuneType_field_number: u32 = 7;
    pub const ElementType_field_number: u32 = 15;
    pub const ChangeLife_field_number: u32 = 6;
    pub const ChangeWeakness_field_number: u32 = 4;
    pub const Bop_field_number: u32 = 11;
};
pub const PassiveSkillAddRequest = struct {
    pub const msg_id: u16 = 25127;
    pub const PassiveSkillId_field_number: u32 = 12;
    pub const TargetEntityId_field_number: u32 = 7;
};
pub const PassiveSkillAddPush = struct {
    pub const msg_id: u16 = 27373;
    pub const PassiveSkillId_field_number: u32 = 15;
    pub const TargetEntityId_field_number: u32 = 9;
};
pub const PassiveSkillAddResponse = struct {
    pub const msg_id: u16 = 25044;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const PassiveSkillRemoveRequest = struct {
    pub const msg_id: u16 = 17981;
    pub const PassiveSkillId_field_number: u32 = 4;
    pub const TargetEntityId_field_number: u32 = 15;
};
pub const PassiveSkillRemovePush = struct {
    pub const msg_id: u16 = 27845;
    pub const PassiveSkillId_field_number: u32 = 15;
    pub const TargetEntityId_field_number: u32 = 4;
};
pub const PassiveSkillRemoveResponse = struct {
    pub const msg_id: u16 = 26405;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const PassiveSkillAddNotify = struct {
    pub const msg_id: u16 = 21022;
    pub const EntityId_field_number: u32 = 12;
    pub const PassiveSkillItemPbList_field_number: u32 = 4;
};
pub const PassiveSkillRemoveNotify = struct {
    pub const msg_id: u16 = 18426;
    pub const EntityId_field_number: u32 = 3;
    pub const SkillIdList_field_number: u32 = 12;
};
pub const EnterViewDirectionRequest = struct {
    pub const msg_id: u16 = 26251;
};
pub const EnterViewDirectionPush = struct {
    pub const msg_id: u16 = 28335;
};
pub const EnterViewDirectionResponse = struct {
    pub const msg_id: u16 = 21062;
    pub const ErrorCode_field_number: u32 = 14;
};
pub const ExitViewDirectionRequest = struct {
    pub const msg_id: u16 = 15700;
};
pub const ExitViewDirectionPush = struct {
    pub const msg_id: u16 = 18304;
};
pub const ExitViewDirectionResponse = struct {
    pub const msg_id: u16 = 19929;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const TriggerExitSkillRequest = struct {
    pub const msg_id: u16 = 18090;
    pub const EnterEntityId_field_number: u32 = 2;
    pub const LeaveEntityId_field_number: u32 = 13;
};
pub const TriggerExitSkillPush = struct {
    pub const msg_id: u16 = 17172;
    pub const EnterEntityId_field_number: u32 = 13;
    pub const LeaveEntityId_field_number: u32 = 2;
};
pub const TriggerExitSkillResponse = struct {
    pub const msg_id: u16 = 26246;
    pub const ErrorCode_field_number: u32 = 5;
};
pub const MonsterInfo = struct {
    pub const MonsterId_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
    pub const GenId_field_number: u32 = 3;
};
pub const SwitchBattleModeNotify = struct {
    pub const msg_id: u16 = 23796;
    pub const ServerControllerModules_field_number: u32 = 10;
    pub const ClientControllerModules_field_number: u32 = 6;
};
pub const EntityIsVisibleRequest = struct {
    pub const msg_id: u16 = 25818;
    pub const Id_field_number: u32 = 11;
    pub const IsVisible_field_number: u32 = 13;
    pub const CombatCommon_field_number: u32 = 14;
};
pub const EntityIsVisiblePush = struct {
    pub const msg_id: u16 = 19102;
    pub const Id_field_number: u32 = 3;
    pub const IsVisible_field_number: u32 = 13;
    pub const CombatCommon_field_number: u32 = 8;
};
pub const EntityIsVisibleResponse = struct {
    pub const msg_id: u16 = 28946;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const EntityIsVisibleNotify = struct {
    pub const msg_id: u16 = 20105;
    pub const Id_field_number: u32 = 5;
    pub const IsVisible_field_number: u32 = 9;
    pub const CombatCommon_field_number: u32 = 11;
};
pub const MotorIsEnablePush = struct {
    pub const msg_id: u16 = 20155;
    pub const Id_field_number: u32 = 1;
    pub const IsEnable_field_number: u32 = 4;
    pub const CombatCommon_field_number: u32 = 2;
};
pub const ActorVisibleRequest = struct {
    pub const msg_id: u16 = 17738;
    pub const Id_field_number: u32 = 15;
    pub const IsActorVisible_field_number: u32 = 7;
};
pub const ActorVisiblePush = struct {
    pub const msg_id: u16 = 17010;
    pub const Id_field_number: u32 = 11;
    pub const IsActorVisible_field_number: u32 = 5;
};
pub const ActorVisibleResponse = struct {
    pub const msg_id: u16 = 22884;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const ActorVisibleNotify = struct {
    pub const msg_id: u16 = 20661;
    pub const Id_field_number: u32 = 9;
    pub const IsActorVisible_field_number: u32 = 15;
};
pub const SwitchCharacterStateRequest = struct {
    pub const msg_id: u16 = 18632;
    pub const CombatCommon_field_number: u32 = 3;
    pub const Id_field_number: u32 = 10;
    pub const OldState_field_number: u32 = 15;
    pub const NewState_field_number: u32 = 13;
};
pub const SwitchCharacterStatePush = struct {
    pub const msg_id: u16 = 18523;
    pub const CombatCommon_field_number: u32 = 7;
    pub const Id_field_number: u32 = 3;
    pub const OldState_field_number: u32 = 10;
    pub const NewState_field_number: u32 = 8;
};
pub const SwitchCharacterStateResponse = struct {
    pub const msg_id: u16 = 21244;
    pub const ErrorCode_field_number: u32 = 9;
};
pub const SwitchCharacterStateNotify = struct {
    pub const msg_id: u16 = 17151;
    pub const CombatCommon_field_number: u32 = 8;
    pub const Id_field_number: u32 = 10;
    pub const OldState_field_number: u32 = 6;
    pub const NewState_field_number: u32 = 12;
};
pub const BattleStateChangeRequest = struct {
    pub const msg_id: u16 = 28011;
    pub const EntityId_field_number: u32 = 3;
    pub const InBattle_field_number: u32 = 8;
};
pub const BattleStateChangePush = struct {
    pub const msg_id: u16 = 15902;
    pub const EntityId_field_number: u32 = 1;
    pub const InBattle_field_number: u32 = 10;
};
pub const BattleStateChangeResponse = struct {
    pub const msg_id: u16 = 20194;
    pub const ErrorCode_field_number: u32 = 9;
};
pub const BattleStateChangeNotify = struct {
    pub const msg_id: u16 = 24642;
    pub const EntityId_field_number: u32 = 3;
    pub const InBattle_field_number: u32 = 9;
};
pub const ToughCalcExtraRatioChangeRequest = struct {
    pub const msg_id: u16 = 17701;
    pub const Id_field_number: u32 = 12;
    pub const Duration_field_number: u32 = 8;
};
pub const ToughCalcExtraRatioChangePush = struct {
    pub const msg_id: u16 = 21213;
    pub const Id_field_number: u32 = 12;
    pub const Duration_field_number: u32 = 4;
};
pub const ToughCalcExtraRatioChangeResponse = struct {
    pub const msg_id: u16 = 20600;
    pub const ErrorCode_field_number: u32 = 8;
};
pub const MonsterBoomRequest = struct {
    pub const msg_id: u16 = 29006;
    pub const Delay_field_number: u32 = 9;
};
pub const MonsterBoomPush = struct {
    pub const msg_id: u16 = 29973;
    pub const Delay_field_number: u32 = 3;
};
pub const MonsterBoomResponse = struct {
    pub const msg_id: u16 = 27210;
    pub const ErrorCode_field_number: u32 = 8;
};
pub const MontagePlayNotify = struct {
    pub const msg_id: u16 = 18893;
    pub const SkillId_field_number: u32 = 3;
    pub const MontageIndex_field_number: u32 = 5;
};
pub const ANStartRequest = struct {
    pub const msg_id: u16 = 29586;
    pub const SkillId_field_number: u32 = 15;
    pub const MontageIndex_field_number: u32 = 14;
    pub const AnIndex_field_number: u32 = 1;
};
pub const ANStartPush = struct {
    pub const msg_id: u16 = 29839;
    pub const SkillId_field_number: u32 = 7;
    pub const MontageIndex_field_number: u32 = 13;
    pub const AnIndex_field_number: u32 = 2;
};
pub const ANStartResponse = struct {
    pub const msg_id: u16 = 23265;
    pub const SkillId_field_number: u32 = 2;
    pub const MontageIndex_field_number: u32 = 5;
    pub const AnIndex_field_number: u32 = 9;
    pub const Error_field_number: u32 = 6;
};
pub const ANStartNotify = struct {
    pub const msg_id: u16 = 15832;
    pub const SkillId_field_number: u32 = 12;
    pub const MontageIndex_field_number: u32 = 6;
    pub const AnIndex_field_number: u32 = 7;
};
pub const CharacterBattleStateInfo = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const InBattle_field_number: u32 = 2;
};
pub const PushContextIdNotify = struct {
    pub const msg_id: u16 = 27862;
    pub const Id_field_number: u32 = 3;
};
pub const CharacterBattleStateChangeNotify = struct {
    pub const msg_id: u16 = 21986;
    pub const CharacterBattleStateInfo_field_number: u32 = 2;
};
pub const PlayerBattleStateChangeNotify = struct {
    pub const msg_id: u16 = 25868;
    pub const PlayerId_field_number: u32 = 8;
    pub const InBattle_field_number: u32 = 11;
};
pub const ShieldUpdateInfo = struct {
    pub const Handle_field_number: u32 = 1;
    pub const ConfigId_field_number: u32 = 2;
    pub const ShieldValue_field_number: u32 = 3;
    pub const UpdateType_field_number: u32 = 4;
};
pub const ShieldUpdateNotify = struct {
    pub const msg_id: u16 = 25263;
    pub const Shields_field_number: u32 = 10;
};
pub const RoleTagChangeRequest = struct {
    pub const msg_id: u16 = 16227;
    pub const TagId_field_number: u32 = 14;
    pub const TagCount_field_number: u32 = 7;
};
pub const RoleTagChangePush = struct {
    pub const msg_id: u16 = 28115;
    pub const TagId_field_number: u32 = 5;
    pub const TagCount_field_number: u32 = 13;
};
pub const RoleTagChangeResponse = struct {
    pub const msg_id: u16 = 17680;
    pub const ErrorCode_field_number: u32 = 6;
};
pub const GameplayCueRequest = struct {
    pub const msg_id: u16 = 21164;
    pub const GameplayCueId_field_number: u32 = 10;
};
pub const GameplayCuePush = struct {
    pub const msg_id: u16 = 21482;
    pub const GameplayCueId_field_number: u32 = 8;
};
pub const GameplayCueResponse = struct {
    pub const msg_id: u16 = 23404;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const GameplayCueNotify = struct {
    pub const msg_id: u16 = 23053;
    pub const GameplayCueId_field_number: u32 = 12;
};
pub const ExecuteQteNotify = struct {
    pub const msg_id: u16 = 27341;
    pub const DownEntityId_field_number: u32 = 8;
    pub const UpEntityId_field_number: u32 = 13;
    pub const FnvHash_field_number: u32 = 10;
};
pub const ExecuteQteRequest = struct {
    pub const msg_id: u16 = 26045;
    pub const DownEntityId_field_number: u32 = 12;
    pub const UpEntityId_field_number: u32 = 4;
    pub const FnvHash_field_number: u32 = 10;
};
pub const ExecuteQtePush = struct {
    pub const msg_id: u16 = 23998;
    pub const DownEntityId_field_number: u32 = 12;
    pub const UpEntityId_field_number: u32 = 4;
    pub const FnvHash_field_number: u32 = 15;
};
pub const ExecuteQteResponse = struct {
    pub const msg_id: u16 = 26083;
    pub const ErrorCode_field_number: u32 = 12;
};
pub const NewLinkStateNotify = struct {
    pub const msg_id: u16 = 25621;
    pub const LinkConfigId_field_number: u32 = 10;
    pub const Current_field_number: u32 = 1;
    pub const PlayerId_field_number: u32 = 15;
};
pub const NewLinkBurstPush = struct {
    pub const msg_id: u16 = 29774;
};
pub const CharacterAttachRequest = struct {
    pub const msg_id: u16 = 21700;
    pub const CharacterAttachInfo_field_number: u32 = 9;
    pub const TargetEntity_field_number: u32 = 2;
};
pub const AddCombineEntitiesRelationNotify = struct {
    pub const msg_id: u16 = 23953;
    pub const CharacterAttachInfo_field_number: u32 = 11;
    pub const TargetEntity_field_number: u32 = 6;
};
pub const RemoveCombineRelationNotify = struct {
    pub const msg_id: u16 = 23757;
    pub const CombineEntity_field_number: u32 = 5;
    pub const TargetEntity_field_number: u32 = 15;
};
pub const CharacterAttachResponse = struct {
    pub const msg_id: u16 = 29140;
    pub const ErrorCode_field_number: u32 = 8;
};
pub const CharacterDetachRequest = struct {
    pub const msg_id: u16 = 24875;
    pub const EntityA_field_number: u32 = 7;
    pub const EntityB_field_number: u32 = 8;
};
pub const CharacterDetachResponse = struct {
    pub const msg_id: u16 = 25523;
    pub const ErrorCode_field_number: u32 = 8;
};
pub const ModifyEntityCampNotify = struct {
    pub const msg_id: u16 = 23862;
    pub const TargetEntityId_field_number: u32 = 5;
    pub const Camp_field_number: u32 = 10;
};
pub const MontagePlayPush = struct {
    pub const msg_id: u16 = 27045;
    pub const Name_field_number: u32 = 7;
    pub const Path_field_number: u32 = 8;
    pub const SpeedRatio_field_number: u32 = 1;
    pub const StartSection_field_number: u32 = 13;
    pub const StartTimeSeconds_field_number: u32 = 12;
};
pub const VisionTriggerPush = struct {
    pub const msg_id: u16 = 23489;
    pub const VisionId_field_number: u32 = 9;
};
pub const VisionTriggerNotify = struct {
    pub const msg_id: u16 = 29084;
    pub const VisionId_field_number: u32 = 2;
};
pub const TransformBuffStackNotify = struct {
    pub const msg_id: u16 = 15366;
    pub const BuffHandle_field_number: u32 = 5;
    pub const BuffId_field_number: u32 = 13;
    pub const BuffStackModifier_field_number: u32 = 15;
};
pub const MotorSummonAndRidePush = struct {
    pub const msg_id: u16 = 27271;
    pub const EntityId_field_number: u32 = 7;
    pub const VehicleIncId_field_number: u32 = 11;
    pub const Transform_field_number: u32 = 9;
};
pub const MotorSummonAndRideNotify = struct {
    pub const msg_id: u16 = 15635;
    pub const PlayerId_field_number: u32 = 4;
    pub const EntityId_field_number: u32 = 13;
    pub const VehicleIncId_field_number: u32 = 10;
    pub const Transform_field_number: u32 = 9;
};
pub const GaSwitchCommonEnemyProCampRequest = struct {
    pub const msg_id: u16 = 24385;
};
pub const GaSwitchCommonEnemyProCampResponse = struct {
    pub const msg_id: u16 = 26298;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const BulletPatternPush = struct {
    pub const msg_id: u16 = 26393;
    pub const BulletPatternHandleId_field_number: u32 = 9;
    pub const BulletPatternId_field_number: u32 = 12;
};
pub const BulletPatternNotify = struct {
    pub const msg_id: u16 = 23009;
    pub const BulletPatternHandleId_field_number: u32 = 6;
    pub const BulletPatternId_field_number: u32 = 11;
};
pub const QuickHackOpenPush = struct {
    pub const msg_id: u16 = 20498;
    pub const DeviceId_field_number: u32 = 15;
    pub const OwnerEntityId_field_number: u32 = 1;
};
pub const QuickHackRamVerifyPush = struct {
    pub const msg_id: u16 = 18127;
    pub const DeviceId_field_number: u32 = 8;
    pub const QuickHackSkillIdList_field_number: u32 = 2;
    pub const OpenQuickHackPreMessageId_field_number: u32 = 12;
};
pub const DodgeInfoPush = struct {
    pub const msg_id: u16 = 26215;
    pub const BulletOwnerId_field_number: u32 = 1;
    pub const BulletId_field_number: u32 = 8;
};
pub const FormationAttr = struct {
    pub const AttrId_field_number: u32 = 1;
    pub const Ratio_field_number: u32 = 2;
    pub const BaseMaxValue_field_number: u32 = 3;
    pub const MaxValue_field_number: u32 = 4;
    pub const CurrentValue_field_number: u32 = 5;
};
pub const FormationAttrNotify = struct {
    pub const msg_id: u16 = 18969;
    pub const Duration_field_number: u32 = 14;
    pub const FormationAttrs_field_number: u32 = 6;
};
pub const FormationAttrRequest = struct {
    pub const msg_id: u16 = 26954;
    pub const Duration_field_number: u32 = 12;
    pub const FormationAttrs_field_number: u32 = 10;
};
pub const FormationAttrResponse = struct {
    pub const msg_id: u16 = 27295;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const RecoverPropFromServer = struct {
    pub const AttrId_field_number: u32 = 1;
    pub const Ratio_field_number: u32 = 2;
    pub const MaxValue_field_number: u32 = 4;
    pub const ValueIncrement_field_number: u32 = 5;
};
pub const RecoverPropChangedNotify = struct {
    pub const msg_id: u16 = 21270;
    pub const Attributes_field_number: u32 = 6;
    pub const Duration_field_number: u32 = 4;
};
pub const FragileChangeRequest = struct {
    pub const msg_id: u16 = 27454;
    pub const EntityId_field_number: u32 = 15;
    pub const Flag_field_number: u32 = 3;
};
pub const FragileChangeResponse = struct {
    pub const msg_id: u16 = 23596;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const DamageRecordEntity = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const BuffIds_field_number: u32 = 2;
    pub const Attr_field_number: u32 = 3;
    pub const AttrSnapshot_field_number: u32 = 4;
};
pub const DamageCalculationDetails = struct {
    pub const ABaseAttackValue_field_number: u32 = 1;
    pub const VEffectiveDefense_field_number: u32 = 2;
    pub const ADamageFactor_field_number: u32 = 3;
    pub const ADamageBonusRate_field_number: u32 = 4;
    pub const ACritChance_field_number: u32 = 5;
    pub const AWeaknessMasteryCoefficient_field_number: u32 = 6;
    pub const VMonsterTypeRate_field_number: u32 = 7;
    pub const ARate_field_number: u32 = 8;
    pub const VDefFactor_field_number: u32 = 9;
    pub const VResistanceFactor_field_number: u32 = 10;
    pub const VbDamageReduce_field_number: u32 = 11;
    pub const VbElementReduce_field_number: u32 = 12;
    pub const AEnergyChange_field_number: u32 = 13;
    pub const WeaknessLvValue_field_number: u32 = 14;
    pub const VWeaknessBuffStack_field_number: u32 = 15;
    pub const HitDamageBonusRate_field_number: u32 = 16;
    pub const WeakDamageBonusRate_field_number: u32 = 17;
    pub const ExceptedDamageValue_field_number: u32 = 18;
};
pub const DamageRecordNotify = struct {
    pub const msg_id: u16 = 20320;
    pub const TimestampMs_field_number: u32 = 1;
    pub const DamageConfId_field_number: u32 = 13;
    pub const DamageValue_field_number: u32 = 12;
    pub const SkillId_field_number: u32 = 4;
    pub const SkillLevel_field_number: u32 = 8;
    pub const BulletId_field_number: u32 = 15;
    pub const DamageSourceType_field_number: u32 = 7;
    pub const IsCritical_field_number: u32 = 2;
    pub const Attacker_field_number: u32 = 11;
    pub const Victim_field_number: u32 = 9;
    pub const DamageCalculationDetails_field_number: u32 = 3;
    pub const IsWeakness_field_number: u32 = 6;
};
pub const TestDamageRecordEntity = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const ConfigId_field_number: u32 = 2;
    pub const BuffIds_field_number: u32 = 3;
    pub const Attr_field_number: u32 = 4;
};
pub const TestDamageRecordNotify = struct {
    pub const msg_id: u16 = 28891;
    pub const TimestampMs_field_number: u32 = 2;
    pub const Entities_field_number: u32 = 7;
};
pub const TimeStopPush = struct {
    pub const msg_id: u16 = 29732;
    pub const TimeDilation_field_number: u32 = 2;
};
pub const TsAnimNotifyStateAbsoluteTimeStopRequest = struct {
    pub const msg_id: u16 = 21590;
    pub const Duration_field_number: u32 = 3;
    pub const Dilation_field_number: u32 = 1;
};
pub const TsAnimNotifyStateAbsoluteTimeStopPush = struct {
    pub const msg_id: u16 = 24520;
    pub const Duration_field_number: u32 = 5;
    pub const Dilation_field_number: u32 = 3;
};
pub const TsAnimNotifyStateAbsoluteTimeStopResponse = struct {
    pub const msg_id: u16 = 22524;
    pub const ErrorCode_field_number: u32 = 8;
};
pub const RTimeStopRequest = struct {
    pub const msg_id: u16 = 22962;
    pub const IsStopCharacter_field_number: u32 = 13;
    pub const Duration_field_number: u32 = 14;
};
pub const RTimeStopPush = struct {
    pub const msg_id: u16 = 26196;
    pub const IsStopCharacter_field_number: u32 = 7;
    pub const Duration_field_number: u32 = 13;
    pub const Dilation_field_number: u32 = 15;
};
pub const RTimeStopResponse = struct {
    pub const msg_id: u16 = 26617;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const EntityTimeDilationPush = struct {
    pub const msg_id: u16 = 16779;
    pub const EntityId_field_number: u32 = 9;
    pub const TimeDilation_field_number: u32 = 11;
};
pub const RTimeStopInstRequest = struct {
    pub const msg_id: u16 = 25664;
    pub const Flag_field_number: u32 = 9;
    pub const Duration_field_number: u32 = 7;
};
pub const RTimeStopInstPush = struct {
    pub const msg_id: u16 = 19708;
    pub const Flag_field_number: u32 = 9;
    pub const Duration_field_number: u32 = 6;
};
pub const RTimeStopInstResponse = struct {
    pub const msg_id: u16 = 22922;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const TimeCheckRequest = struct {
    pub const msg_id: u16 = 18687;
    pub const ClientTime_field_number: u32 = 10;
    pub const TimeDilation_field_number: u32 = 8;
    pub const FlowTimeDilation_field_number: u32 = 6;
};
pub const TimeCheckNotify = struct {
    pub const msg_id: u16 = 25753;
    pub const ClientTime_field_number: u32 = 9;
    pub const ServerTime_field_number: u32 = 13;
    pub const ServerCombatTime_field_number: u32 = 5;
    pub const ServerStopTime_field_number: u32 = 6;
    pub const ServerFlowTimestamp_field_number: u32 = 3;
};
pub const TimeCheckResponse = struct {
    pub const msg_id: u16 = 27958;
    pub const ErrorCode_field_number: u32 = 1;
    pub const ClientTime_field_number: u32 = 8;
    pub const ServerTime_field_number: u32 = 6;
    pub const ServerCombatTime_field_number: u32 = 2;
    pub const ServerStopTime_field_number: u32 = 10;
    pub const ServerFlowTimestamp_field_number: u32 = 5;
};
pub const FormationRoleInfo = struct {
    pub const roleId_field_number: u32 = 1;
    pub const MaxHp_field_number: u32 = 2;
    pub const CurHp_field_number: u32 = 3;
    pub const Level_field_number: u32 = 4;
    pub const RoleSkinId_field_number: u32 = 5;
    pub const SkillBranchId_field_number: u32 = 6;
    pub const WeaponId_field_number: u32 = 7;
    pub const WeaponBreachLevel_field_number: u32 = 8;
    pub const WeaponSkinId_field_number: u32 = 9;
    pub const DressList_field_number: u32 = 10;
};
pub const FightFormationNotifyInfo = struct {
    pub const FormationId_field_number: u32 = 1;
    pub const CurRole_field_number: u32 = 2;
    pub const RoleInfos_field_number: u32 = 3;
    pub const IsCurrent_field_number: u32 = 4;
};
pub const FightFormation = struct {
    pub const FormationId_field_number: u32 = 1;
    pub const CurRole_field_number: u32 = 2;
    pub const RoleIds_field_number: u32 = 3;
    pub const IsCurrent_field_number: u32 = 4;
};
pub const SwitchRoleRequest = struct {
    pub const msg_id: u16 = 23252;
    transform: ?union(enum) {
    } = null,
    pub const Transform_field_number: u32 = 7;
    pub const RoleId_field_number: u32 = 9;
    pub const SwitchType_field_number: u32 = 13;
    pub const OnStageWithoutControl_field_number: u32 = 4;
};
pub const SwitchRoleResponse = struct {
    pub const msg_id: u16 = 26956;
    pub const ErrorCode_field_number: u32 = 11;
    pub const RoleId_field_number: u32 = 10;
};
pub const RoleGoDownPush = struct {
    pub const msg_id: u16 = 15459;
};
pub const UpdateFormationRequest = struct {
    pub const msg_id: u16 = 17332;
    pub const Formations_field_number: u32 = 5;
};
pub const UpdateFormationResponse = struct {
    pub const msg_id: u16 = 21849;
    pub const ErrorCode_field_number: u32 = 7;
    pub const Formation_field_number: u32 = 1;
};
pub const PlayerFightFormations = struct {
    pub const PlayerId_field_number: u32 = 1;
    pub const Formations_field_number: u32 = 2;
};
pub const UpdateFormationNotify = struct {
    pub const msg_id: u16 = 16356;
    pub const PlayersFormations_field_number: u32 = 12;
};
pub const GetFormationDataRequest = struct {
    pub const msg_id: u16 = 20044;
};
pub const GetFormationDataResponse = struct {
    pub const msg_id: u16 = 24981;
    pub const ErrorCode_field_number: u32 = 14;
    pub const Formations_field_number: u32 = 1;
};
pub const ClientCurrentRoleReportRequest = struct {
    pub const msg_id: u16 = 27745;
    pub const PlayerId_field_number: u32 = 2;
    pub const CurrentRoleId_field_number: u32 = 1;
    pub const CurrentEntityId_field_number: u32 = 8;
};
pub const ClientCurrentRoleReportPush = struct {
    pub const msg_id: u16 = 24919;
    pub const PlayerId_field_number: u32 = 2;
    pub const CurrentRoleId_field_number: u32 = 11;
    pub const CurrentEntityId_field_number: u32 = 13;
};
pub const ClientCurrentRoleReportResponse = struct {
    pub const msg_id: u16 = 21407;
    pub const PlayerId_field_number: u32 = 3;
    pub const CurrentEntityId_field_number: u32 = 15;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const ControlTemporaryTeleportParam = struct {
    pub const TemporaryTeleportIds_field_number: u32 = 1;
};
pub const ControlParam = struct {
    Param: ?union(enum) {
    } = null,
    pub const TemporaryTeleportParam_field_number: u32 = 2;
    pub const ControlType_field_number: u32 = 1;
};
pub const ControlInfoNotify = struct {
    pub const msg_id: u16 = 22988;
    pub const ForbidList_field_number: u32 = 15;
};
pub const DirectTrainGetPlayerIdRequest = struct {
    pub const msg_id: u16 = 29824;
};
pub const DirectTrainGetPlayerIdResponse = struct {
    pub const msg_id: u16 = 29505;
    MU1: ?union(enum) {
    } = null,
    pub const Activities_field_number: u32 = 6;
    pub const Activitys_field_number: u32 = 14;
};
pub const EnergyInfo = struct {
    pub const EnergyCount_field_number: u32 = 1;
    pub const LastRenewEnergyTime_field_number: u32 = 2;
    pub const EnergyType_field_number: u32 = 3;
};
pub const EnergyUpdateNotify = struct {
    pub const msg_id: u16 = 27552;
    pub const UpdateInfo_field_number: u32 = 7;
};
pub const EnergySyncRequest = struct {
    pub const msg_id: u16 = 23091;
    pub const EnergyTypes_field_number: u32 = 10;
};
pub const EnergySyncResponse = struct {
    pub const msg_id: u16 = 17149;
    pub const ErrorCode_field_number: u32 = 9;
    pub const SyncInfo_field_number: u32 = 11;
};
pub const ExploreProgressRequest = struct {
    pub const msg_id: u16 = 20987;
    pub const AreaIds_field_number: u32 = 11;
};
pub const AreaExploreInfo = struct {
    pub const AreaId_field_number: u32 = 1;
    pub const ExploreProgress_field_number: u32 = 2;
    pub const ExplorePercent_field_number: u32 = 3;
};
pub const OneExploreItem = struct {
    pub const ExploreProgressId_field_number: u32 = 1;
    pub const ExplorePercent_field_number: u32 = 2;
    pub const CurCount_field_number: u32 = 3;
    pub const TotalCount_field_number: u32 = 4;
    pub const IsLocked_field_number: u32 = 5;
};
pub const ExploreProgressResponse = struct {
    pub const msg_id: u16 = 28268;
    pub const AreaProgress_field_number: u32 = 14;
};
pub const MultiExploreScoreRewardRequest = struct {
    pub const msg_id: u16 = 21383;
    pub const nBs_field_number: u32 = 4;
};
pub const MultiExploreScoreRewardResponse = struct {
    pub const msg_id: u16 = 19735;
    pub const ErrorCode_field_number: u32 = 14;
};
pub const CountryExploreScoreInfoRequest = struct {
    pub const msg_id: u16 = 22253;
    pub const CountryId_field_number: u32 = 10;
};
pub const CountryExploreScoreInfoResponse = struct {
    pub const msg_id: u16 = 27413;
    pub const ExploreScore_field_number: u32 = 6;
    pub const CountryExploreScoreReceived_field_number: u32 = 7;
};
pub const CountryExploreScoreReceived = struct {
    pub const AreaId_field_number: u32 = 1;
    pub const ExploreProgress_field_number: u32 = 2;
};
pub const CountryExploreLevel = struct {
    pub const CountryId_field_number: u32 = 1;
    pub const ExploreLevel_field_number: u32 = 2;
};
pub const ExploreLevelNotify = struct {
    pub const msg_id: u16 = 25479;
    pub const CountryExploreLevel_field_number: u32 = 3;
};
pub const ReceiveAreaStageRewardAsyncRequest = struct {
    pub const msg_id: u16 = 17449;
    pub const AreaStageRewardDataList_field_number: u32 = 7;
};
pub const ReceiveAreaStageRewardAsyncResponse = struct {
    pub const msg_id: u16 = 17012;
    pub const AreaStageRewardDataList_field_number: u32 = 2;
};
pub const ExploreProgressRewardIdsNotify = struct {
    pub const msg_id: u16 = 21703;
    pub const AreaStageRewardDataList_field_number: u32 = 8;
};
pub const ExploreToolAllNotify = struct {
    pub const msg_id: u16 = 29842;
    pub const SkillList_field_number: u32 = 4;
    pub const ExploreSkill_field_number: u32 = 14;
    pub const NewUnlock_field_number: u32 = 9;
};
pub const ExploreSkillRouletteUpdateNotify = struct {
    pub const msg_id: u16 = 25654;
    pub const RouletteInfo_field_number: u32 = 6;
};
pub const VisionExploreSkillSetRequest = struct {
    pub const msg_id: u16 = 18340;
    pub const SkillId_field_number: u32 = 11;
    pub const IsAutoChange_field_number: u32 = 3;
    pub const RouletteType_field_number: u32 = 15;
};
pub const VisionExploreSkillSetResponse = struct {
    pub const msg_id: u16 = 15328;
    pub const ErrorCode_field_number: u32 = 7;
    pub const SkillId_field_number: u32 = 12;
};
pub const VisionExploreSkillNotify = struct {
    pub const msg_id: u16 = 22748;
    pub const ExploreSkill_field_number: u32 = 1;
};
pub const ExploreSkillRoulette = struct {
    pub const SkillIds_field_number: u32 = 1;
    pub const ExtraItemId_field_number: u32 = 2;
    pub const ExploreSkill_field_number: u32 = 3;
};
pub const ExploreSkillRouletteSetRequest = struct {
    pub const msg_id: u16 = 27804;
    pub const SkillRoulette_field_number: u32 = 2;
    pub const RouletteType_field_number: u32 = 4;
    pub const SkillRoulettes_field_number: u32 = 15;
};
pub const ExploreSkillRouletteSetResponse = struct {
    pub const msg_id: u16 = 26388;
    pub const ErrorCode_field_number: u32 = 7;
    pub const SkillRoulette_field_number: u32 = 14;
    pub const RouletteType_field_number: u32 = 9;
    pub const SkillRoulettes_field_number: u32 = 11;
};
pub const UnlockIllustratedPhantom = struct {
    pub const MonsterId_field_number: u32 = 1;
    pub const SkinIds_field_number: u32 = 2;
    pub const EqupiedSkin_field_number: u32 = 3;
    pub const IsSpecial_field_number: u32 = 4;
};
pub const PhantomInteractionUnlockNotify = struct {
    pub const msg_id: u16 = 17651;
    pub const UnlockIllustratedPhantoms_field_number: u32 = 3;
    pub const EquipedMonsterIds_field_number: u32 = 8;
};
pub const PhantomInteractionInfoUpdateNotify = struct {
    pub const msg_id: u16 = 26989;
    pub const UnlockIllustratedPhantom_field_number: u32 = 8;
};
pub const PhantomInteractionEquipRequest = struct {
    pub const msg_id: u16 = 26392;
    pub const EquipedMonsterIds_field_number: u32 = 11;
};
pub const PhantomInteractionEquipResponse = struct {
    pub const msg_id: u16 = 20467;
    pub const ErrorCode_field_number: u32 = 2;
};
pub const SkinChangeInfo = struct {
    pub const MonsterId_field_number: u32 = 1;
    pub const SkinId_field_number: u32 = 2;
};
pub const PhantomInteractionSkinChangeRequest = struct {
    pub const msg_id: u16 = 15087;
    pub const SkinChangeInfos_field_number: u32 = 2;
};
pub const PhantomInteractionSkinChangeResponse = struct {
    pub const msg_id: u16 = 25282;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const FavorQuest = struct {
    pub const Chapter_field_number: u32 = 1;
    pub const Status_field_number: u32 = 2;
};
pub const FavorItem = struct {
    pub const Id_field_number: u32 = 1;
    pub const Status_field_number: u32 = 2;
};
pub const RoleFavor = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const Level_field_number: u32 = 2;
    pub const Exp_field_number: u32 = 3;
    pub const WordIds_field_number: u32 = 4;
    pub const StoryIds_field_number: u32 = 5;
    pub const GoodsIds_field_number: u32 = 6;
    pub const FavorQuest_field_number: u32 = 7;
};
pub const RoleFavorListRequest = struct {
    pub const msg_id: u16 = 27723;
};
pub const RoleFavorListResponse = struct {
    pub const msg_id: u16 = 26093;
    pub const ErrorCode_field_number: u32 = 8;
    pub const FavorList_field_number: u32 = 9;
};
pub const RoleFavorListNotify = struct {
    pub const msg_id: u16 = 21057;
    pub const FavorList_field_number: u32 = 11;
    pub const RoleConditionInfoMap_field_number: u32 = 10;
};
pub const ItemFinishList = struct {
    pub const ConditionIdList_field_number: u32 = 1;
};
pub const ConditionItem = struct {
    pub const ItemFinishMap_field_number: u32 = 1;
};
pub const ConditionInfo = struct {
    pub const FinishConditionMap_field_number: u32 = 2;
};
pub const RoleMotion = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const MotionIds_field_number: u32 = 2;
};
pub const RoleMotionListNotify = struct {
    pub const msg_id: u16 = 22867;
    pub const MotionList_field_number: u32 = 10;
    pub const RoleConditionInfoMap_field_number: u32 = 5;
};
pub const FishingDataRequest = struct {
    pub const msg_id: u16 = 18671;
};
pub const FishingDataResponse = struct {
    pub const msg_id: u16 = 24415;
    pub const FishingData_field_number: u32 = 8;
};
pub const FishingData = struct {
    pub const Entrusts_field_number: u32 = 3;
    pub const TraceEntrusts_field_number: u32 = 4;
    pub const FishingTech_field_number: u32 = 5;
    pub const ShipInfo_field_number: u32 = 6;
    pub const IllustratedInfo_field_number: u32 = 7;
    pub const SceneCages_field_number: u32 = 8;
    pub const SceneFishPoints_field_number: u32 = 9;
    pub const NoticeIds_field_number: u32 = 10;
    pub const HandInInfo_field_number: u32 = 11;
    pub const UnlockPortId_field_number: u32 = 12;
    pub const PhantomSkinList_field_number: u32 = 13;
    pub const EntrustRefreshRatio_field_number: u32 = 14;
};
pub const FishingTechInfo = struct {
    pub const NodeId_field_number: u32 = 1;
    pub const Level_field_number: u32 = 2;
    pub const CanUnlock_field_number: u32 = 3;
};
pub const FishingShipInfo = struct {
    pub const SkinId_field_number: u32 = 1;
    pub const SailingTime_field_number: u32 = 6;
    pub const IsSailing_field_number: u32 = 7;
    pub const CabinInfo_field_number: u32 = 8;
    pub const EntityId_field_number: u32 = 10;
    pub const IsInPort_field_number: u32 = 11;
    pub const PortId_field_number: u32 = 12;
    pub const LastPortId_field_number: u32 = 13;
};
pub const FishingIllustratedInfo = struct {
    pub const IllustratedList_field_number: u32 = 1;
    pub const RewardedId_field_number: u32 = 2;
    pub const UnlockDetections_field_number: u32 = 3;
};
pub const OneFishingIllustratedData = struct {
    pub const Id_field_number: u32 = 1;
    pub const MaxSize_field_number: u32 = 2;
    pub const MinSize_field_number: u32 = 3;
};
pub const FishingItemInfo = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const IncrId_field_number: u32 = 2;
    pub const Rotate_field_number: u32 = 4;
    pub const Pos_field_number: u32 = 5;
    pub const Size_field_number: u32 = 6;
    pub const Cup_field_number: u32 = 7;
    pub const Quality_field_number: u32 = 8;
    pub const Price_field_number: u32 = 9;
};
pub const IntVector2D = struct {
    pub const X_field_number: u32 = 1;
    pub const Y_field_number: u32 = 2;
};
pub const CabinInfo = struct {
    pub const FishingItem_field_number: u32 = 1;
    pub const CabinShape_field_number: u32 = 2;
    pub const QuickSellShape_field_number: u32 = 3;
    pub const NetCabinItems_field_number: u32 = 4;
    pub const TempCabinItems_field_number: u32 = 5;
    pub const QuickSellRatio_field_number: u32 = 6;
};
pub const SceneFishCageInfo = struct {
    pub const Cages_field_number: u32 = 1;
};
pub const SceneFishCageData = struct {
    pub const Id_field_number: u32 = 5;
    pub const EntityConfigId_field_number: u32 = 1;
    pub const MaxCount_field_number: u32 = 2;
    pub const Items_field_number: u32 = 3;
    pub const LastUpdateTime_field_number: u32 = 4;
    pub const NextUpdateTime_field_number: u32 = 6;
    pub const RefreshTime_field_number: u32 = 7;
};
pub const SceneFishPointInfo = struct {
    pub const FishPoints_field_number: u32 = 1;
    pub const TempFishPoints_field_number: u32 = 2;
};
pub const SceneFishPointData = struct {
    pub const Id_field_number: u32 = 5;
    pub const EntityConfigId_field_number: u32 = 1;
    pub const CurCount_field_number: u32 = 2;
    pub const MaxCount_field_number: u32 = 3;
    pub const LastUpdateTime_field_number: u32 = 4;
    pub const NextUpdateTime_field_number: u32 = 6;
    pub const RefreshTime_field_number: u32 = 7;
    pub const GamePlayId_field_number: u32 = 8;
    pub const Interacted_field_number: u32 = 9;
};
pub const TempFishPointInfo = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const CurCount_field_number: u32 = 2;
    pub const MaxCount_field_number: u32 = 3;
    pub const ConfigId_field_number: u32 = 4;
    pub const GamePlayId_field_number: u32 = 5;
};
pub const FishingIllustratedRewardInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const CurrentProgress_field_number: u32 = 2;
    pub const TargetProgress_field_number: u32 = 3;
    pub const HasPassed_field_number: u32 = 4;
    pub const IsTaken_field_number: u32 = 5;
};
pub const HandInInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const FishingItem_field_number: u32 = 2;
};
pub const FlowStartNotify = struct {
    pub const msg_id: u16 = 17347;
    pub const FlowIncId_field_number: u32 = 14;
    pub const FlowListName_field_number: u32 = 2;
    pub const FlowId_field_number: u32 = 15;
    pub const StateId_field_number: u32 = 1;
    pub const GameCtx_field_number: u32 = 10;
    pub const PlotMode_field_number: u32 = 6;
    pub const aAsync_field_number: u32 = 8;
    pub const IsSkip_field_number: u32 = 4;
    pub const HasPlotPos_field_number: u32 = 3;
    pub const PlotCoordinates_field_number: u32 = 7;
};
pub const FlowEndRequest = struct {
    pub const msg_id: u16 = 19567;
    pub const FlowIncId_field_number: u32 = 11;
    pub const IsSkip_field_number: u32 = 13;
    pub const OptionInfos_field_number: u32 = 4;
};
pub const FlowOptionInfoList = struct {
    pub const OptionIndexList_field_number: u32 = 1;
};
pub const FlowOptionInfo = struct {
    pub const TalkId_field_number: u32 = 1;
    pub const OptionIndex_field_number: u32 = 2;
};
pub const FlowEndResponse = struct {
    pub const msg_id: u16 = 21796;
    pub const ErrorCode_field_number: u32 = 13;
};
pub const FlySkinEquipData = struct {
    pub const SkinId_field_number: u32 = 1;
    pub const RoleIds_field_number: u32 = 2;
};
pub const RoleFlyEquipNotify = struct {
    pub const msg_id: u16 = 24499;
    pub const FlySkinEquipData_field_number: u32 = 13;
};
pub const FlySkinWearRequest = struct {
    pub const msg_id: u16 = 22754;
    pub const RoleId_field_number: u32 = 1;
    pub const SkinId_field_number: u32 = 14;
};
pub const FlySkinWearResponse = struct {
    pub const msg_id: u16 = 28448;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const EquipFlySkinData = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const SkinId_field_number: u32 = 2;
};
pub const FlySkinWearAllRoleRequest = struct {
    pub const msg_id: u16 = 28161;
    pub const SkinId_field_number: u32 = 10;
};
pub const FlySkinWearAllRoleResponse = struct {
    pub const msg_id: u16 = 26368;
    pub const ErrorCode_field_number: u32 = 7;
    pub const FlySkinData_field_number: u32 = 2;
};
pub const RoleFlyEquipChangeNotify = struct {
    pub const msg_id: u16 = 19968;
    pub const FlySkinData_field_number: u32 = 15;
};
pub const FlySkinConfigData = struct {
    pub const SkinId_field_number: u32 = 1;
    pub const FlySkinId_field_number: u32 = 2;
};
pub const EntityFlySkinChangeData = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const FlySkinConfigData_field_number: u32 = 2;
};
pub const SoarWingOrParaglidingSkinChangeNotify = struct {
    pub const msg_id: u16 = 23570;
    pub const FlySkinData_field_number: u32 = 15;
};
pub const FlyEquipAddNotify = struct {
    pub const msg_id: u16 = 22611;
    pub const UnlockFlySkinIds_field_number: u32 = 10;
};
pub const ForgeInfoRequest = struct {
    pub const msg_id: u16 = 27432;
};
pub const ForgeInfoResponse = struct {
    pub const msg_id: u16 = 18525;
    pub const ErrorCode_field_number: u32 = 12;
    pub const ForgeInfoList_field_number: u32 = 11;
    pub const ForgeConfigs_field_number: u32 = 7;
    pub const LimitRefreshTime_field_number: u32 = 5;
};
pub const OneForgeInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const LastRoleId_field_number: u32 = 3;
    pub const LimitTotalCount_field_number: u32 = 4;
    pub const LimitForgeCount_field_number: u32 = 5;
    pub const StartTime_field_number: u32 = 6;
    pub const EndTime_field_number: u32 = 7;
};
pub const OneForgeConfig = struct {
    pub const Id_field_number: u32 = 1;
    pub const StartTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
};
pub const Formation = struct {
    pub const Id_field_number: u32 = 1;
    pub const RoleIndex_field_number: u32 = 2;
    pub const Role_field_number: u32 = 3;
    pub const IsCurrent_field_number: u32 = 4;
};
pub const FriendInfo = struct {
    pub const Info_field_number: u32 = 1;
    pub const Remark_field_number: u32 = 2;
};
pub const FriendApply = struct {
    pub const Info_field_number: u32 = 1;
    pub const CreatedTime_field_number: u32 = 2;
};
pub const FriendAllRequest = struct {
    pub const msg_id: u16 = 15309;
};
pub const FriendAllResponse = struct {
    pub const msg_id: u16 = 24093;
    pub const FriendInfoList_field_number: u32 = 2;
    pub const FriendApplyList_field_number: u32 = 8;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const Function = struct {
    pub const Id_field_number: u32 = 1;
    pub const Flag_field_number: u32 = 5;
};
pub const FuncOpenNotify = struct {
    pub const msg_id: u16 = 25723;
    pub const Func_field_number: u32 = 5;
};
pub const GachaConsume = struct {
    pub const Times_field_number: u32 = 1;
    pub const Consume_field_number: u32 = 2;
};
pub const GachaDiscountInfo = struct {
    pub const Times_field_number: u32 = 1;
    pub const LimitTimes_field_number: u32 = 2;
    pub const DiscountConsume_field_number: u32 = 3;
    pub const UsedTimes_field_number: u32 = 4;
};
pub const GachaPoolInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const BeginTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
    pub const Title_field_number: u32 = 4;
    pub const Description_field_number: u32 = 5;
    pub const UiType_field_number: u32 = 6;
    pub const ThemeColor_field_number: u32 = 7;
    pub const ShowIdList_field_number: u32 = 8;
    pub const UpList_field_number: u32 = 9;
    pub const PreviewIdList_field_number: u32 = 10;
    pub const ComplianceDetail_field_number: u32 = 11;
};
pub const GachaInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const TodayTimes_field_number: u32 = 2;
    pub const TotalTimes_field_number: u32 = 3;
    pub const ItemId_field_number: u32 = 4;
    pub const GachaConsumes_field_number: u32 = 5;
    pub const UsePoolId_field_number: u32 = 6;
    pub const Pools_field_number: u32 = 7;
    pub const BeginTime_field_number: u32 = 8;
    pub const EndTime_field_number: u32 = 9;
    pub const DailyLimitTimes_field_number: u32 = 10;
    pub const TotalLimitTimes_field_number: u32 = 11;
    pub const ResourcesId_field_number: u32 = 12;
    pub const GachaAccumulateId_field_number: u32 = 13;
    pub const GachaDiscountInfos_field_number: u32 = 14;
    pub const OnlyViewDiscount_field_number: u32 = 15;
    pub const IsShowProgress_field_number: u32 = 16;
    pub const DiscountTagDetails_field_number: u32 = 17;
};
pub const GachaReward = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const ItemCount_field_number: u32 = 2;
};
pub const GachaResult = struct {
    Bottom: ?union(enum) {
    } = null,
    pub const BottomExtraReward_field_number: u32 = 3;
    pub const GachaReward_field_number: u32 = 1;
    pub const ExtraRewards_field_number: u32 = 2;
    pub const TransformRewards_field_number: u32 = 4;
};
pub const GachaInfoRequest = struct {
    pub const msg_id: u16 = 23116;
    pub const Language_field_number: u32 = 13;
};
pub const GachaInfoResponse = struct {
    pub const msg_id: u16 = 15380;
    pub const ErrorCode_field_number: u32 = 11;
    pub const GachaInfos_field_number: u32 = 1;
    pub const DailyTotalLeftTimes_field_number: u32 = 5;
    pub const RecordId_field_number: u32 = 10;
};
pub const GachaRequest = struct {
    pub const msg_id: u16 = 23981;
    pub const GachaId_field_number: u32 = 14;
    pub const GachaTimes_field_number: u32 = 8;
};
pub const GachaResponse = struct {
    pub const msg_id: u16 = 16966;
    pub const ErrorCode_field_number: u32 = 2;
    pub const GachaResults_field_number: u32 = 5;
};
pub const GachaUsePoolRequest = struct {
    pub const msg_id: u16 = 16528;
    pub const GachaId_field_number: u32 = 10;
    pub const PoolId_field_number: u32 = 6;
};
pub const GachaUsePoolResponse = struct {
    pub const msg_id: u16 = 28808;
    pub const ErrorCode_field_number: u32 = 5;
};
pub const GachaItem = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const IsUp_field_number: u32 = 2;
};
pub const GachaPoolDetail = struct {
    pub const Text_field_number: u32 = 1;
    pub const FiveStarRoles_field_number: u32 = 2;
    pub const FiveStarWeapons_field_number: u32 = 3;
    pub const FourStarRoles_field_number: u32 = 4;
    pub const FourStarWeapons_field_number: u32 = 5;
    pub const ThreeStarRoles_field_number: u32 = 6;
    pub const FiveStarTitle_field_number: u32 = 7;
    pub const FileStarDetail_field_number: u32 = 8;
    pub const FourStarTitle_field_number: u32 = 9;
    pub const FourStarDetail_field_number: u32 = 10;
    pub const ThreeStarTitle_field_number: u32 = 11;
    pub const ThreeStarDetail_field_number: u32 = 12;
};
pub const GachaPoolDetailRequest = struct {
    pub const msg_id: u16 = 24316;
    pub const PoolId_field_number: u32 = 1;
};
pub const GachaPoolDetailResponse = struct {
    pub const msg_id: u16 = 26534;
    pub const ErrorCode_field_number: u32 = 7;
    pub const GachaPoolDetail_field_number: u32 = 2;
};
pub const GivebackInfoRequest = struct {
    pub const msg_id: u16 = 18802;
};
pub const GivebackInfoResponse = struct {
    pub const msg_id: u16 = 16402;
    pub const ErrorCode_field_number: u32 = 10;
};
pub const GuideInfoRequest = struct {
    pub const msg_id: u16 = 23491;
};
pub const GuideInfoResponse = struct {
    pub const msg_id: u16 = 18765;
    pub const GuideGroupFinishList_field_number: u32 = 2;
};
pub const GuideTriggerRequest = struct {
    pub const msg_id: u16 = 18262;
    pub const GroupId_field_number: u32 = 2;
};
pub const GuideTriggerResponse = struct {
    pub const msg_id: u16 = 29786;
    pub const ErrorCode_field_number: u32 = 4;
    pub const ErrorParams_field_number: u32 = 1;
};
pub const GuideFinishRequest = struct {
    pub const msg_id: u16 = 29779;
    pub const GroupId_field_number: u32 = 5;
};
pub const GuideFinishResponse = struct {
    pub const msg_id: u16 = 20283;
    pub const ErrorCode_field_number: u32 = 3;
    pub const ErrorParams_field_number: u32 = 10;
};
pub const HeartbeatRequest = struct {
    pub const msg_id: u16 = 1650;
    pub const AntiData_field_number: u32 = 1;
};
pub const HeartbeatResponse = struct {
    pub const msg_id: u16 = 1651;
};
pub const IllustratedEntry = struct {
    SubType: ?union(enum) {
    } = null,
    pub const PhotographSubType_field_number: u32 = 5;
    pub const Id_field_number: u32 = 1;
    pub const CreateTime_field_number: u32 = 2;
    pub const Num_field_number: u32 = 3;
    pub const IsRead_field_number: u32 = 4;
};
pub const IllustratedClass = struct {
    pub const Type_field_number: u32 = 1;
    pub const IllustratedEntryList_field_number: u32 = 2;
};
pub const IllustratedInfoRequest = struct {
    pub const msg_id: u16 = 17767;
    pub const TypeList_field_number: u32 = 13;
};
pub const IllustratedInfoResponse = struct {
    pub const msg_id: u16 = 21722;
    pub const ErrorCode_field_number: u32 = 15;
    pub const ErrorParams_field_number: u32 = 10;
    pub const IllustratedClassList_field_number: u32 = 7;
};
pub const RoleIllustratedInfoRequest = struct {
    pub const msg_id: u16 = 18736;
};
pub const RoleIllustratedInfoResponse = struct {
    pub const msg_id: u16 = 16392;
    pub const Roles_field_number: u32 = 10;
    pub const Weapons_field_number: u32 = 15;
};
pub const RoleHandbookInfo = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
};
pub const WeaponHandbookInfo = struct {
    pub const WeaponId_field_number: u32 = 1;
    pub const UnlockTime_field_number: u32 = 2;
};
pub const InfluenceInfoRequest = struct {
    pub const msg_id: u16 = 17295;
};
pub const InfluenceInfoResponse = struct {
    pub const msg_id: u16 = 21948;
    pub const InfluenceInfos_field_number: u32 = 14;
};
pub const InfluenceInfo = struct {
    pub const InfluenceId_field_number: u32 = 1;
    pub const RewardIndex_field_number: u32 = 2;
    pub const Relation_field_number: u32 = 3;
};
pub const InfrInfoRequest = struct {
    pub const msg_id: u16 = 21566;
};
pub const InfrInfoResponse = struct {
    pub const msg_id: u16 = 17052;
    pub const ErrorCode_field_number: u32 = 9;
    pub const InfrInfo_field_number: u32 = 4;
};
pub const InfrRoadUpdateNotify = struct {
    pub const msg_id: u16 = 29738;
    pub const RoadInfo_field_number: u32 = 14;
};
pub const InfrPb = struct {
    pub const FireInfo_field_number: u32 = 1;
    pub const RoadInfo_field_number: u32 = 2;
    pub const LibraryInfo_field_number: u32 = 3;
};
pub const InfrLibraryPb = struct {
    pub const ArchiveTasks_field_number: u32 = 1;
    pub const PhoneTasks_field_number: u32 = 2;
    pub const UnreadArchives_field_number: u32 = 3;
};
pub const InfrTaskPb = struct {
    pub const TaskId_field_number: u32 = 1;
    pub const Target_field_number: u32 = 2;
    pub const status_field_number: u32 = 3;
};
pub const InfrFirePb = struct {
    pub const FireExp_field_number: u32 = 1;
    pub const FireLevel_field_number: u32 = 2;
    pub const FireLevelReachTime_field_number: u32 = 3;
    pub const FireStatus_field_number: u32 = 4;
};
pub const InfrRoadPb = struct {
    pub const Roads_field_number: u32 = 1;
    pub const Notices_field_number: u32 = 2;
    pub const ManualTraceRoad_field_number: u32 = 3;
    pub const RecommendRoad_field_number: u32 = 4;
};
pub const InfrOneRoad = struct {
    pub const RoadId_field_number: u32 = 1;
    pub const status_field_number: u32 = 2;
    pub const CompleteTime_field_number: u32 = 3;
    pub const TotalGiftCount_field_number: u32 = 4;
    pub const LastGiftTime_field_number: u32 = 5;
};
pub const InfrNotice = struct {
    pub const RoadId_field_number: u32 = 1;
    pub const PasserId_field_number: u32 = 2;
    pub const GiftCount_field_number: u32 = 3;
    pub const CreateTime_field_number: u32 = 4;
};
pub const InfrV2Pb = struct {
    pub const FireInfo_field_number: u32 = 1;
    pub const TreeInfo_field_number: u32 = 2;
    pub const RewardScoreIds_field_number: u32 = 3;
    pub const ConditionTasks_field_number: u32 = 4;
    pub const TreeFinishCond_field_number: u32 = 5;
};
pub const InfrV2InfoRequest = struct {
    pub const msg_id: u16 = 24789;
};
pub const InfrV2InfoResponse = struct {
    pub const msg_id: u16 = 24146;
    pub const ErrorCode_field_number: u32 = 1;
    pub const InfrInfo_field_number: u32 = 13;
};
pub const InfrV2FirePb = struct {
    pub const FireExp_field_number: u32 = 1;
    pub const FireLevel_field_number: u32 = 2;
    pub const FireLevelReachTime_field_number: u32 = 3;
    pub const FireStatus_field_number: u32 = 4;
};
pub const InfrV2TreePb = struct {
    pub const Trees_field_number: u32 = 1;
    pub const ManualTraceTree_field_number: u32 = 3;
};
pub const InfrV2OneTree = struct {
    pub const TreeId_field_number: u32 = 1;
    pub const status_field_number: u32 = 2;
    pub const CompleteTime_field_number: u32 = 3;
    pub const TotalGiftCount_field_number: u32 = 4;
    pub const LastGiftTime_field_number: u32 = 5;
};
pub const InstDataNotify = struct {
    pub const msg_id: u16 = 23938;
    pub const EnterInfos_field_number: u32 = 15;
};
pub const InstEnterInfoPb = struct {
    pub const Id_field_number: u32 = 1;
    pub const ChallengedTimes_field_number: u32 = 2;
};
pub const CreateInstanceDungeonNotify = struct {
    pub const msg_id: u16 = 23078;
    pub const LevelPlayId_field_number: u32 = 7;
};
pub const ExchangeRewardRequest = struct {
    pub const msg_id: u16 = 24210;
};
pub const ExchangeRewardResponse = struct {
    pub const msg_id: u16 = 20131;
    pub const ExchangeShareData_field_number: u32 = 15;
    pub const ExchangeRewardData_field_number: u32 = 11;
};
pub const ItemExchangeInfo = struct {
    pub const ItemId_field_number: u32 = 1;
    pub const TodayTimes_field_number: u32 = 2;
    pub const TotalTimes_field_number: u32 = 3;
    pub const DailyLimit_field_number: u32 = 4;
    pub const TotalLimit_field_number: u32 = 5;
};
pub const ItemExchangeInfoRequest = struct {
    pub const msg_id: u16 = 25367;
};
pub const ItemExchangeInfoResponse = struct {
    pub const msg_id: u16 = 23692;
    pub const ItemExchangeInfos_field_number: u32 = 7;
};
pub const SimpleCombatEntityAttributePbInfo = struct {
    pub const AttributeMap_field_number: u32 = 1;
    pub const LockedAttributeMap_field_number: u32 = 2;
};
pub const LevelPlayInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const IsFirst_field_number: u32 = 2;
    pub const State_field_number: u32 = 3;
    pub const UpdateTime_field_number: u32 = 4;
    pub const GetRewardCount_field_number: u32 = 5;
};
pub const LevelPlayInfoNotify = struct {
    pub const msg_id: u16 = 21617;
    pub const LevelPlayInfo_field_number: u32 = 13;
};
pub const SimpleTrackReportAsyncRequest = struct {
    pub const msg_id: u16 = 22812;
};
pub const SimpleTrackReportAsyncResponse = struct {
    pub const msg_id: u16 = 24540;
    pub const ErrorCode_field_number: u32 = 4;
    pub const SimpleTrackReportMsgs_field_number: u32 = 8;
};
pub const SimpleTrackReportMsg = struct {
    pub const InstId_field_number: u32 = 1;
    pub const LevelPlayId_field_number: u32 = 2;
    pub const GainTreasureCount_field_number: u32 = 3;
};
pub const LevelPlayVarAsyncRequest = struct {
    pub const msg_id: u16 = 15401;
    pub const InstId_field_number: u32 = 9;
    pub const LevelPlayId_field_number: u32 = 11;
};
pub const LevelPlayVarAsyncResponse = struct {
    pub const msg_id: u16 = 25835;
    pub const ErrorCode_field_number: u32 = 10;
    pub const Vars_field_number: u32 = 2;
};
pub const PlayPointStateAsyncRequest = struct {
    pub const msg_id: u16 = 21677;
    pub const InstId_field_number: u32 = 14;
    pub const ArenaId_field_number: u32 = 13;
};
pub const PlayPointStateAsyncResponse = struct {
    pub const msg_id: u16 = 25158;
    pub const ErrorCode_field_number: u32 = 4;
    pub const LevelPlayStateDict_field_number: u32 = 2;
};
pub const LevelPlayStateMsg = struct {
    pub const LevelPlayEntityId_field_number: u32 = 1;
    pub const ExploratoryType_field_number: u32 = 2;
    pub const StateType_field_number: u32 = 3;
    pub const CompleteNumber_field_number: u32 = 4;
    pub const IsHide_field_number: u32 = 5;
    pub const HideGroupInfo_field_number: u32 = 6;
    pub const IsUnlocked_field_number: u32 = 7;
    pub const LevelPlayMarkUnlock_field_number: u32 = 8;
};
pub const LivenessInfo = struct {
    pub const LivenessCount_field_number: u32 = 1;
    pub const RewardedLiveness_field_number: u32 = 2;
    pub const Tasks_field_number: u32 = 3;
    pub const DayEnd_field_number: u32 = 4;
    pub const AreaId_field_number: u32 = 5;
};
pub const LivenessTask = struct {
    pub const Id_field_number: u32 = 1;
    pub const Current_field_number: u32 = 2;
    pub const Target_field_number: u32 = 3;
    pub const IsFinished_field_number: u32 = 4;
    pub const IsTaken_field_number: u32 = 5;
    pub const ConditionFinishState_field_number: u32 = 6;
};
pub const LivenessRequest = struct {
    pub const msg_id: u16 = 29540;
};
pub const LivenessResponse = struct {
    pub const msg_id: u16 = 17543;
    pub const LivenessInfo_field_number: u32 = 12;
};
pub const LivenessTakeRequest = struct {
    pub const msg_id: u16 = 18185;
    pub const Ids_field_number: u32 = 3;
};
pub const LivenessTakeResponse = struct {
    pub const msg_id: u16 = 24855;
    pub const Ids_field_number: u32 = 5;
    pub const ErrorCode_field_number: u32 = 4;
};
pub const RoleLoadEquipData = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const Pos_field_number: u32 = 2;
    pub const EquipIncId_field_number: u32 = 3;
};
pub const LoadEquipData = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const SkinId_field_number: u32 = 2;
};
pub const WeaponSkinRequest = struct {
    pub const msg_id: u16 = 23225;
};
pub const WeaponSkinResponse = struct {
    pub const msg_id: u16 = 24572;
    pub const ErrorCode_field_number: u32 = 7;
    pub const EquipList_field_number: u32 = 14;
};
pub const EquipTakeOnRequest = struct {
    pub const msg_id: u16 = 29929;
    pub const Data_field_number: u32 = 12;
};
pub const EquipTakeOnResponse = struct {
    pub const msg_id: u16 = 26033;
    pub const ErrorCode_field_number: u32 = 7;
    pub const DataList_field_number: u32 = 1;
};
pub const EquipTakeOnNotify = struct {
    pub const msg_id: u16 = 27175;
    pub const DataList_field_number: u32 = 14;
};
pub const UnlockSkinDataNotify = struct {
    pub const msg_id: u16 = 26126;
    pub const PhantomSkinList_field_number: u32 = 13;
    pub const IsLogin_field_number: u32 = 12;
};
pub const WeaponSkinDeleteNotify = struct {
    pub const msg_id: u16 = 20828;
    pub const RoleId_field_number: u32 = 14;
    pub const SkinId_field_number: u32 = 6;
};
pub const EquipWeaponSkinRequest = struct {
    pub const msg_id: u16 = 23583;
    pub const Data_field_number: u32 = 1;
};
pub const EquipWeaponSkinResponse = struct {
    pub const msg_id: u16 = 21170;
    pub const ErrorCode_field_number: u32 = 3;
    pub const DataList_field_number: u32 = 14;
};
pub const SendEquipSkinRequest = struct {
    pub const msg_id: u16 = 15297;
    pub const RoleId_field_number: u32 = 2;
};
pub const SendEquipSkinResponse = struct {
    pub const msg_id: u16 = 29003;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const AceBlackProductAccountInfo = struct {
    pub const TdmDeviceId_field_number: u32 = 1;
    pub const IsRoot_field_number: u32 = 2;
    pub const IsSimulator_field_number: u32 = 3;
};
pub const DevLoginCheckData = struct {
    pub const ProtoVersion_field_number: u32 = 1;
    pub const ProtoMD5_field_number: u32 = 2;
    pub const ConfigVersion_field_number: u32 = 3;
    pub const ConfigMD5_field_number: u32 = 4;
    pub const BranchName_field_number: u32 = 5;
    pub const ProtoSeedMD5_field_number: u32 = 6;
};
pub const LoginRequest = struct {
    pub const msg_id: u16 = 103;
    DevLoginCheck: ?union(enum) {
    } = null,
    pub const DevLoginCheckData_field_number: u32 = 9;
    pub const Id_field_number: u32 = 1;
    pub const Account_field_number: u32 = 2;
    pub const LoginTraceId_field_number: u32 = 3;
    pub const Token_field_number: u32 = 4;
    pub const AppVersion_field_number: u32 = 5;
    pub const LauncherVersion_field_number: u32 = 6;
    pub const ResourceVersion_field_number: u32 = 7;
    pub const ClientBasicInfo_field_number: u32 = 8;
    pub const PublicResourceVersionInfo_field_number: u32 = 10;
    pub const AceBlackProductAccountInfo_field_number: u32 = 11;
    pub const PushNotificationsEnabled_field_number: u32 = 12;
    pub const ClientId_field_number: u32 = 13;
    pub const SdkUserId_field_number: u32 = 14;
    pub const SdkOnlineId_field_number: u32 = 15;
    pub const SdkAccountId_field_number: u32 = 16;
    pub const PackageClientFightConfig_field_number: u32 = 17;
    pub const LimitState_field_number: u32 = 18;
    pub const FsmVersion_field_number: u32 = 19;
    pub const ConfirmQuestResource_field_number: u32 = 20;
    pub const QuestReourceState_field_number: u32 = 21;
    pub const IsLowMemorePlatform_field_number: u32 = 22;
    pub const BlockState_field_number: u32 = 23;
    pub const downloadResourceQuestId_field_number: u32 = 24;
    pub const XboxUserId_field_number: u32 = 25;
    pub const XboxOnlineId_field_number: u32 = 26;
    pub const XboxAccountId_field_number: u32 = 27;
    pub const XboxSocialState_field_number: u32 = 28;
    pub const XstsToken_field_number: u32 = 30;
};
pub const LoginResponse = struct {
    pub const msg_id: u16 = 104;
    pub const ErrorCode_field_number: u32 = 1;
    pub const ReconnectToken_field_number: u32 = 2;
    pub const Timestamp_field_number: u32 = 3;
    pub const Platform_field_number: u32 = 4;
    pub const ClientWaitingMode_field_number: u32 = 5;
    pub const ClientWaitingTime_field_number: u32 = 6;
    pub const ClientAutoInInterval_field_number: u32 = 7;
    pub const ClientDisplayTime_field_number: u32 = 8;
};
pub const EnterGameRequest = struct {
    pub const msg_id: u16 = 105;
    pub const SingleInstanceId_field_number: u32 = 1;
    pub const MultiInstanceId_field_number: u32 = 2;
    pub const Mode_field_number: u32 = 3;
    pub const Pos_field_number: u32 = 4;
};
pub const EnterGameResponse = struct {
    pub const msg_id: u16 = 106;
    pub const ErrorCode_field_number: u32 = 1;
    pub const ClientWaitingMode_field_number: u32 = 2;
    pub const ClientWaitingTime_field_number: u32 = 3;
    pub const ClientAutoInInterval_field_number: u32 = 4;
};
pub const ReconnectRequest = struct {
    pub const msg_id: u16 = 107;
    pub const PlayerId_field_number: u32 = 1;
    pub const LastSvrSeqNo_field_number: u32 = 2;
    pub const ReconnectToken_field_number: u32 = 3;
    pub const ReconnectTraceId_field_number: u32 = 4;
};
pub const ReconnectResponse = struct {
    pub const msg_id: u16 = 108;
    pub const ErrorCode_field_number: u32 = 1;
    pub const LastRecvSeqNo_field_number: u32 = 2;
    pub const Timestamp_field_number: u32 = 3;
    pub const IsPermittedSilentLogin_field_number: u32 = 4;
};
pub const LogoutNotify = struct {
    pub const msg_id: u16 = 110;
    Ban: ?union(enum) {
    } = null,
    pub const BanInfo_field_number: u32 = 3;
    pub const ErrorCode_field_number: u32 = 1;
    pub const logoutReason_field_number: u32 = 2;
};
pub const ProtoKeyRequest = struct {
    pub const msg_id: u16 = 111;
    pub const IsLogin_field_number: u32 = 1;
    pub const TraceId_field_number: u32 = 2;
};
pub const ProtoKeyResponse = struct {
    pub const msg_id: u16 = 112;
    pub const ErrorCode_field_number: u32 = 1;
    pub const Type_field_number: u32 = 2;
    pub const Key_field_number: u32 = 3;
};
pub const PushDataCompleteNotify = struct {
    pub const msg_id: u16 = 113;
};
pub const VersionInfoPush = struct {
    pub const msg_id: u16 = 116;
    pub const AppVersion_field_number: u32 = 1;
    pub const LauncherVersion_field_number: u32 = 2;
    pub const ResourceVersion_field_number: u32 = 3;
};
pub const LoadingConfigRequest = struct {
    pub const msg_id: u16 = 23899;
};
pub const LoadingConfigResponse = struct {
    pub const msg_id: u16 = 19069;
    pub const LoadingConfig_field_number: u32 = 6;
};
pub const LoadingConfig = struct {
    pub const Id_field_number: u32 = 1;
    pub const BeginTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
};
pub const PublicResourceVersionInfo = struct {
    pub const PublicJsonVersion_field_number: u32 = 1;
    pub const PublicMiscVersion_field_number: u32 = 2;
    pub const PublicUniverseEditorVersion_field_number: u32 = 3;
};
pub const PbMailAttachment = struct {
    pub const Id_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
};
pub const PbMailInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const ReceivedTime_field_number: u32 = 2;
    pub const ReadTime_field_number: u32 = 3;
    pub const State_field_number: u32 = 4;
    pub const Level_field_number: u32 = 5;
    pub const Title_field_number: u32 = 6;
    pub const Content_field_number: u32 = 7;
    pub const Sender_field_number: u32 = 8;
    pub const ValidTime_field_number: u32 = 9;
    pub const ReadValidTime_field_number: u32 = 10;
    pub const Attachments_field_number: u32 = 11;
    pub const ConfigId_field_number: u32 = 12;
    pub const ExpiryTime_field_number: u32 = 13;
    pub const IsIntervalMail_field_number: u32 = 14;
};
pub const MailInfosNotify = struct {
    pub const msg_id: u16 = 23473;
    pub const MailInfos_field_number: u32 = 14;
};
pub const MailBindInfoRequest = struct {
    pub const msg_id: u16 = 25484;
};
pub const MailBindInfoResponse = struct {
    pub const msg_id: u16 = 16403;
    pub const MailBind_field_number: u32 = 2;
};
pub const MailBind = struct {
    pub const IsBind_field_number: u32 = 1;
    pub const IsReward_field_number: u32 = 2;
    pub const CloseTime_field_number: u32 = 3;
};
pub const MarkPointInfo = struct {
    pub const PosX_field_number: u32 = 1;
    pub const PosY_field_number: u32 = 2;
    pub const PosZ_field_number: u32 = 3;
    pub const ConfigId_field_number: u32 = 4;
    pub const MarkId_field_number: u32 = 5;
    pub const IsTrace_field_number: u32 = 6;
    pub const MarkType_field_number: u32 = 7;
    pub const MapId_field_number: u32 = 8;
    pub const IsServerDisable_field_number: u32 = 9;
    pub const MarkPointState_field_number: u32 = 10;
};
pub const MarkPointRequestInfo = struct {
    pub const PosX_field_number: u32 = 1;
    pub const PosY_field_number: u32 = 2;
    pub const PosZ_field_number: u32 = 3;
    pub const ConfigId_field_number: u32 = 4;
    pub const MarkType_field_number: u32 = 5;
    pub const MarkInfo_field_number: u32 = 6;
    pub const IsTrace_field_number: u32 = 7;
    pub const MapId_field_number: u32 = 8;
};
pub const TreasureBoxParam = struct {
    pub const TreasureBox_field_number: u32 = 1;
    pub const DetectionSlotId_field_number: u32 = 2;
};
pub const MarkTreasureBoxInfo = struct {
    pub const MarkPointInfo_field_number: u32 = 1;
};
pub const AttachMarkInfo = struct {
    pub const MarkPointInfo_field_number: u32 = 1;
};
pub const MapUnlockFieldInfoRequest = struct {
    pub const msg_id: u16 = 26550;
};
pub const MapUnlockFieldInfoResponse = struct {
    pub const msg_id: u16 = 18332;
    pub const ErrorCode_field_number: u32 = 2;
    pub const FieldId_field_number: u32 = 11;
};
pub const MapMarkShowInfo = struct {
    pub const MarkId_field_number: u32 = 1;
    pub const ShowFlag_field_number: u32 = 2;
};
pub const TemporaryTeleportParam = struct {
    pub const temporaryTeleportId_field_number: u32 = 1;
};
pub const MapMarkRequest = struct {
    pub const msg_id: u16 = 27039;
    Params: ?union(enum) {
    } = null,
    pub const TemporaryTeleportParam_field_number: u32 = 14;
    pub const TreasureBoxParam_field_number: u32 = 12;
    pub const MarkPointRequestInfo_field_number: u32 = 13;
};
pub const MapMarkResponse = struct {
    pub const msg_id: u16 = 26086;
    pub const ErrorCode_field_number: u32 = 10;
    pub const Info_field_number: u32 = 9;
};
pub const RemoveMapMarkRequest = struct {
    pub const msg_id: u16 = 18447;
    pub const MarkList_field_number: u32 = 9;
};
pub const RemoveMapMarkResponse = struct {
    pub const msg_id: u16 = 26046;
    pub const ErrorCode_field_number: u32 = 12;
    pub const MarkList_field_number: u32 = 10;
};
pub const MapUnlockFieldNotify = struct {
    pub const msg_id: u16 = 26718;
    pub const FieldId_field_number: u32 = 9;
};
pub const MapTraceInfoRequest = struct {
    pub const msg_id: u16 = 18875;
};
pub const MapTraceInfoResponse = struct {
    pub const msg_id: u16 = 28077;
    pub const ErrorCode_field_number: u32 = 3;
    pub const MarkIdList_field_number: u32 = 12;
};
pub const MapTraceRequest = struct {
    pub const msg_id: u16 = 25924;
    pub const MarkId_field_number: u32 = 2;
};
pub const MapTraceResponse = struct {
    pub const msg_id: u16 = 18528;
    pub const ErrorCode_field_number: u32 = 2;
    pub const MarkId_field_number: u32 = 10;
};
pub const MapCancelTraceRequest = struct {
    pub const msg_id: u16 = 29099;
    pub const MarkId_field_number: u32 = 7;
};
pub const MapCancelTraceResponse = struct {
    pub const msg_id: u16 = 25962;
    pub const ErrorCode_field_number: u32 = 7;
    pub const MarkId_field_number: u32 = 4;
};
pub const MapMarkInfoNotify = struct {
    pub const msg_id: u16 = 19625;
    pub const InfoList_field_number: u32 = 10;
    pub const ShowMarkIds_field_number: u32 = 9;
    pub const UnlockMarkIds_field_number: u32 = 13;
    pub const EntityMapMarkInfo_field_number: u32 = 8;
    pub const SystemMarkHideInfo_field_number: u32 = 7;
    pub const CompleteMarkIds_field_number: u32 = 4;
};
pub const MapMarkAddNotify = struct {
    pub const msg_id: u16 = 15177;
    pub const Info_field_number: u32 = 3;
    pub const TreasureBoxMarkInfo_field_number: u32 = 6;
    pub const AttackMark_field_number: u32 = 8;
};
pub const MapUnlockDataNotify = struct {
    pub const msg_id: u16 = 18606;
    pub const UnlockMultiMapIds_field_number: u32 = 4;
    pub const UnlockMapBlockIds_field_number: u32 = 3;
};
pub const EntityMapMarkInfoPb = struct {
    pub const InstId_field_number: u32 = 1;
    pub const TemplateId_field_number: u32 = 2;
    pub const Pos_field_number: u32 = 3;
};
pub const SystemMarkHideInfoPb = struct {
    pub const Id_field_number: u32 = 1;
    pub const MapId_field_number: u32 = 2;
    pub const HideInfo_field_number: u32 = 3;
};
pub const MonthCardRequest = struct {
    pub const msg_id: u16 = 29887;
};
pub const MonthCardResponse = struct {
    pub const msg_id: u16 = 26034;
    pub const Days_field_number: u32 = 10;
    pub const IsDailyGot_field_number: u32 = 15;
    pub const ErrorCode_field_number: u32 = 5;
};
pub const MonthCardDailyRewardNotify = struct {
    pub const msg_id: u16 = 25210;
    pub const ItemId_field_number: u32 = 11;
    pub const Count_field_number: u32 = 8;
    pub const Days_field_number: u32 = 14;
};
pub const MotorTaskProcessPb = struct {
    pub const Current_field_number: u32 = 1;
    pub const Target_field_number: u32 = 2;
};
pub const MotorTaskRewardPb = struct {
    pub const Rewarded_field_number: u32 = 1;
    pub const WaitReward_field_number: u32 = 2;
    pub const MaxReward_field_number: u32 = 3;
};
pub const MotorTaskPb = struct {
    pub const Id_field_number: u32 = 1;
    pub const Type_field_number: u32 = 2;
    pub const Process_field_number: u32 = 3;
    pub const Reward_field_number: u32 = 4;
    pub const EndTime_field_number: u32 = 5;
    pub const StartTime_field_number: u32 = 6;
};
pub const MotorInfoRequest = struct {
    pub const msg_id: u16 = 26961;
};
pub const MotorInfoResponse = struct {
    pub const msg_id: u16 = 27581;
    pub const ErrorCode_field_number: u32 = 7;
    pub const Motor_field_number: u32 = 12;
};
pub const MotorTechLevelUpRequest = struct {
    pub const msg_id: u16 = 28622;
    pub const TechId_field_number: u32 = 3;
};
pub const MotorTechLevelUpResponse = struct {
    pub const msg_id: u16 = 19362;
    pub const ErrorCode_field_number: u32 = 11;
    pub const Tree_field_number: u32 = 13;
};
pub const MotorTechTreeSwitchRequest = struct {
    pub const msg_id: u16 = 25231;
    pub const TreeId_field_number: u32 = 1;
};
pub const MotorTechTreeSwitchResponse = struct {
    pub const msg_id: u16 = 23652;
    pub const ErrorCode_field_number: u32 = 5;
    pub const TreeInUse_field_number: u32 = 8;
};
pub const MotorLevelOneKeyRewardRequest = struct {
    pub const msg_id: u16 = 16527;
};
pub const MotorLevelOneKeyRewardResponse = struct {
    pub const msg_id: u16 = 19868;
    pub const ErrorCode_field_number: u32 = 5;
    pub const MotorRewardedLvMax_field_number: u32 = 14;
};
pub const MotorTaskOneKeyRewardRequest = struct {
    pub const msg_id: u16 = 22052;
    pub const TaskIds_field_number: u32 = 11;
};
pub const MotorTaskOneKeyRewardResponse = struct {
    pub const msg_id: u16 = 27415;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const MotorTaskUpdateNotify = struct {
    pub const msg_id: u16 = 22563;
    pub const Task_field_number: u32 = 4;
};
pub const MotorLockedTechUpdateNotify = struct {
    pub const msg_id: u16 = 26485;
    pub const TreeId_field_number: u32 = 4;
    pub const Tech_field_number: u32 = 12;
};
pub const MotorTechPb = struct {
    pub const Id_field_number: u32 = 1;
    pub const Level_field_number: u32 = 2;
    pub const Unlock_field_number: u32 = 3;
    pub const Current_field_number: u32 = 10;
    pub const Target_field_number: u32 = 11;
};
pub const MotorTechOneTreePb = struct {
    pub const TreeId_field_number: u32 = 1;
    pub const Tech_field_number: u32 = 2;
};
pub const MotorPb = struct {
    pub const MotorLevel_field_number: u32 = 1;
    pub const MotorExp_field_number: u32 = 2;
    pub const MotorRewardedLvMax_field_number: u32 = 3;
    pub const UnlockedTree_field_number: u32 = 4;
    pub const TreeInUse_field_number: u32 = 5;
    pub const TaskTrees_field_number: u32 = 6;
    pub const MotorExpLimitGainDaily_field_number: u32 = 7;
    pub const MotorExpMonsterDropDailyLimit_field_number: u32 = 8;
};
pub const MotorTaskTreePb = struct {
    pub const TreeId_field_number: u32 = 1;
    pub const Tasks_field_number: u32 = 2;
    pub const TpRewarded_field_number: u32 = 3;
};
pub const MotorCreateRequest = struct {
    pub const msg_id: u16 = 25453;
    pub const IsCreate_field_number: u32 = 8;
};
pub const MotorCreateResponse = struct {
    pub const msg_id: u16 = 24369;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const OrnamentInfo = struct {
    pub const UnlockOrnamentIds_field_number: u32 = 1;
    pub const OrnamentDressInfos_field_number: u32 = 2;
    pub const RedPointOrnamentIds_field_number: u32 = 3;
};
pub const OrnamentDressInfo = struct {
    pub const RoleSkinId_field_number: u32 = 1;
    pub const DressOrnamentIds_field_number: u32 = 2;
};
pub const OrnamentInfoNotify = struct {
    pub const msg_id: u16 = 24275;
    pub const OrnamentInfo_field_number: u32 = 12;
};
pub const OrnamentDressInfoUpdateNotify = struct {
    pub const msg_id: u16 = 19829;
    pub const OrnamentDressInfos_field_number: u32 = 15;
};
pub const ChangeOrnamentRequest = struct {
    pub const msg_id: u16 = 23269;
    pub const RoleSkinId_field_number: u32 = 3;
    pub const OrnamentId_field_number: u32 = 4;
    pub const IsDress_field_number: u32 = 10;
};
pub const ChangeOrnamentResponse = struct {
    pub const msg_id: u16 = 29379;
    pub const ErrorCode_field_number: u32 = 12;
};
pub const PayItemInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const PayId_field_number: u32 = 2;
    pub const ItemId_field_number: u32 = 3;
    pub const ItemCount_field_number: u32 = 4;
    pub const BonusItemCount_field_number: u32 = 5;
    pub const SpecialBonusItemCount_field_number: u32 = 6;
    pub const CanSpecialBonus_field_number: u32 = 7;
    pub const StageImage_field_number: u32 = 8;
    pub const ProductId_field_number: u32 = 9;
    pub const Amount_field_number: u32 = 10;
    pub const ComplianceDetail_field_number: u32 = 11;
    pub const Quality_field_number: u32 = 12;
};
pub const PayGiftInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const PayId_field_number: u32 = 2;
    pub const ItemId_field_number: u32 = 3;
    pub const ItemCount_field_number: u32 = 4;
    pub const Sort_field_number: u32 = 5;
    pub const BuyLimit_field_number: u32 = 6;
    pub const BoughtCount_field_number: u32 = 7;
    pub const StageImage_field_number: u32 = 8;
    pub const BeginTime_field_number: u32 = 9;
    pub const EndTime_field_number: u32 = 10;
    pub const ProductId_field_number: u32 = 11;
    pub const Amount_field_number: u32 = 12;
    pub const TabId_field_number: u32 = 13;
    pub const Type_field_number: u32 = 14;
    pub const Locked_field_number: u32 = 15;
    pub const IsCanBuy_field_number: u32 = 16;
    pub const IsRemind_field_number: u32 = 17;
    pub const BuyCondition_field_number: u32 = 18;
    pub const CloudGameTime_field_number: u32 = 19;
    pub const CloudGameIcon_field_number: u32 = 20;
    pub const Desc_field_number: u32 = 21;
    pub const UpdateType_field_number: u32 = 22;
    pub const UpdateTime_field_number: u32 = 23;
    pub const LastUpdateTime_field_number: u32 = 24;
    pub const Tag_field_number: u32 = 25;
    pub const PromotionShow_field_number: u32 = 26;
    pub const ShowStageImage_field_number: u32 = 27;
    pub const CurrencyDiscountTags_field_number: u32 = 28;
    pub const ComplianceDetail_field_number: u32 = 29;
    pub const Quality_field_number: u32 = 30;
    pub const VersionId_field_number: u32 = 31;
    pub const ShopId_field_number: u32 = 32;
    pub const NeedConsoleRulePrompt_field_number: u32 = 33;
};
pub const PayInfoRequest = struct {
    pub const msg_id: u16 = 27640;
    pub const Version_field_number: u32 = 10;
};
pub const PayInfoResponse = struct {
    pub const msg_id: u16 = 27137;
    pub const Infos_field_number: u32 = 14;
    pub const Version_field_number: u32 = 13;
    pub const ErrorCode_field_number: u32 = 8;
};
pub const PayShopPrice = struct {
    pub const Id_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
    pub const PromotionCount_field_number: u32 = 3;
};
pub const PayShopItem = struct {
    pub const Id_field_number: u32 = 1;
    pub const ItemId_field_number: u32 = 3;
    pub const ItemCount_field_number: u32 = 4;
    pub const Locked_field_number: u32 = 5;
    pub const BuyLimit_field_number: u32 = 6;
    pub const BoughtCount_field_number: u32 = 7;
    pub const Price_field_number: u32 = 8;
    pub const BeginTime_field_number: u32 = 9;
    pub const EndTime_field_number: u32 = 10;
    pub const BeginPromotionTime_field_number: u32 = 11;
    pub const EndPromotionTime_field_number: u32 = 12;
    pub const UpdateType_field_number: u32 = 13;
    pub const UpdateTime_field_number: u32 = 14;
    pub const ShopItemType_field_number: u32 = 15;
    pub const TagBeginTime_field_number: u32 = 17;
    pub const TagEndTime_field_number: u32 = 18;
    pub const CanBuyGoods_field_number: u32 = 22;
    pub const IsRemind_field_number: u32 = 23;
    pub const BuyLimitConditionId_field_number: u32 = 24;
    pub const Coupons_field_number: u32 = 25;
    pub const LastUpdateTime_field_number: u32 = 26;
    pub const StageImage_field_number: u32 = 27;
    pub const ShowStageImage_field_number: u32 = 28;
    pub const TabId_field_number: u32 = 29;
    pub const ShopId_field_number: u32 = 30;
    pub const Tag_field_number: u32 = 31;
    pub const Sort_field_number: u32 = 32;
    pub const PromotionShow_field_number: u32 = 33;
    pub const SoldOut_field_number: u32 = 34;
    pub const ActivityId_field_number: u32 = 35;
    pub const Show_field_number: u32 = 36;
    pub const ComplianceDetail_field_number: u32 = 37;
    pub const Quality_field_number: u32 = 38;
    pub const DiscountSort_field_number: u32 = 39;
    pub const OnceBuyLimit_field_number: u32 = 40;
    pub const IsRecommend_field_number: u32 = 41;
    pub const IsShowHaveNum_field_number: u32 = 42;
    pub const IsBuyMaxButton_field_number: u32 = 43;
    pub const ConfirmLimitCount_field_number: u32 = 44;
};
pub const PayShopInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const Items_field_number: u32 = 2;
    pub const UpdateTime_field_number: u32 = 3;
    pub const LastUpdateTime_field_number: u32 = 4;
    pub const ShopTabViewType_field_number: u32 = 5;
    pub const DynamicTabId_field_number: u32 = 6;
    pub const Sort_field_number: u32 = 7;
    pub const Money_field_number: u32 = 8;
    pub const SortRule_field_number: u32 = 9;
    pub const PayShopTabTogContent_field_number: u32 = 10;
};
pub const PayGiftShopInfo = struct {
    pub const Gifts_field_number: u32 = 1;
    pub const Version_field_number: u32 = 2;
};
pub const PayShopInfoRequest = struct {
    pub const msg_id: u16 = 29434;
    pub const Version_field_number: u32 = 5;
};
pub const PayShopInfoResponse = struct {
    pub const msg_id: u16 = 29687;
    pub const Infos_field_number: u32 = 1;
    pub const Version_field_number: u32 = 5;
    pub const ErrorCode_field_number: u32 = 10;
    pub const PayGiftShopInfo_field_number: u32 = 3;
    pub const PayShopTabData_field_number: u32 = 2;
    pub const PayShopRecommendData_field_number: u32 = 14;
};
pub const ShopTab = struct {
    pub const ShopId_field_number: u32 = 1;
    pub const TabId_field_number: u32 = 2;
    pub const Sort_field_number: u32 = 3;
    pub const name_field_number: u32 = 4;
    pub const Logic_field_number: u32 = 5;
    pub const Enable_field_number: u32 = 6;
    pub const BeginTime_field_number: u32 = 7;
    pub const EndTime_field_number: u32 = 8;
    pub const TabSelectSpritePath_field_number: u32 = 9;
    pub const TabContentPath_field_number: u32 = 10;
    pub const Money_field_number: u32 = 11;
};
pub const ShopRecommend = struct {
    pub const Id_field_number: u32 = 1;
    pub const RecommendType_field_number: u32 = 2;
    pub const RecommendId_field_number: u32 = 3;
    pub const TabName_field_number: u32 = 4;
    pub const PrefabPath_field_number: u32 = 5;
    pub const Sort_field_number: u32 = 6;
    pub const Show_field_number: u32 = 7;
    pub const TabImage_field_number: u32 = 8;
};
pub const PhBaPlanAttr = struct {
    pub const AttrId_field_number: u32 = 1;
    pub const Deal_field_number: u32 = 2;
};
pub const PhBaOneCostPlan = struct {
    pub const CostType_field_number: u32 = 1;
    pub const AttrList_field_number: u32 = 2;
};
pub const PhBaOneSuitPlan = struct {
    pub const SuitId_field_number: u32 = 1;
    pub const OneCostList_field_number: u32 = 2;
    pub const IsOpen_field_number: u32 = 3;
};
pub const PhBaOneAllSuitPlan = struct {
    pub const SuitPlanList_field_number: u32 = 1;
    pub const Name_field_number: u32 = 2;
};
pub const PhBaPlanUsePlanRequest = struct {
    pub const msg_id: u16 = 24029;
};
pub const PhBaPlanUsePlanResponse = struct {
    pub const msg_id: u16 = 27839;
    pub const ErrorCode_field_number: u32 = 1;
    pub const SelfPlanCode_field_number: u32 = 7;
    pub const UsePlan_field_number: u32 = 3;
    pub const FiveStarSwitch_field_number: u32 = 9;
    pub const TowPlanSame_field_number: u32 = 2;
};
pub const PhBaPlanSaveUsePlanRequest = struct {
    pub const msg_id: u16 = 19819;
    pub const UsePlan_field_number: u32 = 13;
};
pub const PhBaPlanSaveUsePlanResponse = struct {
    pub const msg_id: u16 = 23276;
    pub const ErrorCode_field_number: u32 = 12;
    pub const SelfPlanCode_field_number: u32 = 5;
    pub const TowPlanSame_field_number: u32 = 9;
};
pub const PhBaPlanFindPlanRequest = struct {
    pub const msg_id: u16 = 28642;
    pub const TargetCode_field_number: u32 = 7;
};
pub const PhBaPlanFindPlanResponse = struct {
    pub const msg_id: u16 = 23396;
    pub const ErrorCode_field_number: u32 = 11;
    pub const Plan_field_number: u32 = 15;
    pub const TowPlanSame_field_number: u32 = 8;
};
pub const PhBaPlanSetStatusInfo = struct {
    pub const Open_field_number: u32 = 1;
    pub const Suit_field_number: u32 = 2;
};
pub const PhBaPlanSetPlanStatusRequest = struct {
    pub const msg_id: u16 = 15279;
    pub const SetInfo_field_number: u32 = 4;
};
pub const PhBaPlanSetPlanStatusResponse = struct {
    pub const msg_id: u16 = 20350;
    pub const ErrorCode_field_number: u32 = 8;
    pub const TowPlanSame_field_number: u32 = 6;
};
pub const PhBaPlanUpdatePlanRequest = struct {
    pub const msg_id: u16 = 21412;
};
pub const PhBaPlanUpdatePlanResponse = struct {
    pub const msg_id: u16 = 29895;
    pub const ErrorCode_field_number: u32 = 6;
    pub const SelfPlanCode_field_number: u32 = 11;
};
pub const PhBaPlanSetFiveStarSwitchRequest = struct {
    pub const msg_id: u16 = 26311;
    pub const Open_field_number: u32 = 4;
};
pub const PhBaPlanSetFiveStarSwitchResponse = struct {
    pub const msg_id: u16 = 20974;
    pub const ErrorCode_field_number: u32 = 2;
};
pub const PhBaPlanBatchOper = struct {
    pub const Oper_field_number: u32 = 1;
    pub const IncrId_field_number: u32 = 2;
};
pub const PhBaPlanBatchOperRequest = struct {
    pub const msg_id: u16 = 15088;
    pub const BatchOper_field_number: u32 = 4;
};
pub const PhBaPlanBatchOperResponse = struct {
    pub const msg_id: u16 = 19616;
    pub const errCode_field_number: u32 = 13;
};
pub const PhantomConsumeItem = struct {
    pub const IncId_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
    pub const ItemId_field_number: u32 = 3;
};
pub const PhantomLevelUpRequest = struct {
    pub const msg_id: u16 = 29915;
    pub const IncId_field_number: u32 = 12;
    pub const ConsumeList_field_number: u32 = 6;
    pub const SlotCount_field_number: u32 = 11;
};
pub const PhantomLevelUpResponse = struct {
    pub const msg_id: u16 = 24219;
    pub const ErrorCode_field_number: u32 = 14;
    pub const UpdateInfo_field_number: u32 = 8;
    pub const ItemMap_field_number: u32 = 2;
};
pub const PhantomPutOnNotify = struct {
    pub const msg_id: u16 = 20066;
    pub const EquipInfoList_field_number: u32 = 2;
};
pub const PhantomPutOnRequest = struct {
    pub const msg_id: u16 = 27019;
    pub const IncId_field_number: u32 = 7;
    pub const RoleId_field_number: u32 = 5;
    pub const Pos_field_number: u32 = 8;
};
pub const PhantomPutOnResponse = struct {
    pub const msg_id: u16 = 18225;
    pub const ErrorCode_field_number: u32 = 1;
    pub const EquipInfoList_field_number: u32 = 8;
};
pub const PhantomAutoPutRequest = struct {
    pub const msg_id: u16 = 19258;
    pub const RoleId_field_number: u32 = 8;
    pub const PhantomItemIncrId_field_number: u32 = 15;
};
pub const PhantomAutoPutResponse = struct {
    pub const msg_id: u16 = 24247;
    pub const ErrorCode_field_number: u32 = 7;
    pub const EquipInfoList_field_number: u32 = 9;
};
pub const PhantomItemUpdateNotify = struct {
    pub const msg_id: u16 = 25512;
    pub const UpdateInfo_field_number: u32 = 2;
};
pub const RolePhantomPropUpdateNotify = struct {
    pub const msg_id: u16 = 27391;
    pub const PropInfo_field_number: u32 = 3;
};
pub const PhantomIdentifyRequest = struct {
    pub const msg_id: u16 = 25175;
    pub const IncrId_field_number: u32 = 6;
    pub const Count_field_number: u32 = 2;
};
pub const PhantomIdentifyResponse = struct {
    pub const msg_id: u16 = 23012;
    pub const ErrorCode_field_number: u32 = 3;
    pub const UpdateInfo_field_number: u32 = 2;
};
pub const PhantomSkinUnlockNotify = struct {
    pub const msg_id: u16 = 19840;
    pub const PhantomSkinList_field_number: u32 = 7;
};
pub const PhantomSkinChangeRequest = struct {
    pub const msg_id: u16 = 29315;
    pub const IncrId_field_number: u32 = 4;
    pub const SkinId_field_number: u32 = 15;
    pub const ChangeDefault_field_number: u32 = 14;
};
pub const PhantomSkinChangeResponse = struct {
    pub const msg_id: u16 = 15410;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const PhantomRefiningRequest = struct {
    pub const msg_id: u16 = 19552;
    pub const IncrIdList_field_number: u32 = 4;
};
pub const PhantomRefiningResponse = struct {
    pub const msg_id: u16 = 15082;
    pub const ErrorCode_field_number: u32 = 2;
    pub const Items_field_number: u32 = 11;
    pub const ExtraItems_field_number: u32 = 1;
    pub const CostPhantoms_field_number: u32 = 7;
};
pub const CalabashBatchRefiningRequest = struct {
    pub const msg_id: u16 = 17707;
    pub const IncrIdList_field_number: u32 = 1;
};
pub const CalabashBatchRefiningResponse = struct {
    pub const msg_id: u16 = 23668;
    pub const ErrorCode_field_number: u32 = 5;
    pub const Items_field_number: u32 = 1;
    pub const ExtraItems_field_number: u32 = 13;
    pub const CostPhantoms_field_number: u32 = 14;
};
pub const PhantomBatchDirectRefiningRequest = struct {
    pub const msg_id: u16 = 15644;
    pub const IncrIdList_field_number: u32 = 9;
    pub const TargetFetterGroupId_field_number: u32 = 13;
};
pub const PhantomBatchDirectRefiningResponse = struct {
    pub const msg_id: u16 = 17669;
    pub const ErrorCode_field_number: u32 = 8;
    pub const Items_field_number: u32 = 9;
    pub const CostPhantoms_field_number: u32 = 11;
    pub const DirectRefineWeekTimes_field_number: u32 = 10;
};
pub const PhantomPolishRequest = struct {
    pub const msg_id: u16 = 17878;
    pub const IncrId_field_number: u32 = 1;
    pub const PhantomMainPropItemId_field_number: u32 = 15;
};
pub const PhantomPolishResponse = struct {
    pub const msg_id: u16 = 22869;
    pub const ErrorCode_field_number: u32 = 15;
    pub const UpdateInfo_field_number: u32 = 1;
};
pub const PhantomManageConfigUpdateRequest = struct {
    pub const msg_id: u16 = 24693;
    pub const Setting_field_number: u32 = 6;
    pub const SettingType_field_number: u32 = 14;
};
pub const PhantomManageConfigUpdateResponse = struct {
    pub const msg_id: u16 = 21618;
    pub const ErrorCode_field_number: u32 = 11;
    pub const Setting_field_number: u32 = 12;
};
pub const PhantomSettingInfo = struct {
    pub const Setting_field_number: u32 = 1;
    pub const SettingType_field_number: u32 = 2;
};
pub const PhantomSettingBatchUpdateRequest = struct {
    pub const msg_id: u16 = 18296;
    pub const Settings_field_number: u32 = 4;
};
pub const PhantomSettingBatchUpdateResponse = struct {
    pub const msg_id: u16 = 24032;
    pub const ErrorCode_field_number: u32 = 5;
    pub const Settings_field_number: u32 = 10;
};
pub const PhantomManageConfigRequest = struct {
    pub const msg_id: u16 = 29137;
};
pub const PhantomManageConfigResponse = struct {
    pub const msg_id: u16 = 24076;
    pub const AutoLock_field_number: u32 = 13;
    pub const AutoDisuse_field_number: u32 = 3;
};
pub const PhantomManageConfig = struct {
    pub const Index_field_number: u32 = 1;
    pub const IsOn_field_number: u32 = 2;
    pub const Name_field_number: u32 = 3;
    pub const PhantomRule_field_number: u32 = 4;
};
pub const PhantomRuleMap = struct {
    pub const RuleId_field_number: u32 = 1;
    pub const ValueList_field_number: u32 = 2;
};
pub const PhantomFuncValueBatchRequest = struct {
    pub const msg_id: u16 = 19893;
    pub const FuncValue_field_number: u32 = 15;
    pub const IncrId_field_number: u32 = 1;
};
pub const PhantomFuncValueBatchResponse = struct {
    pub const msg_id: u16 = 15157;
    pub const ErrorCode_field_number: u32 = 11;
};
pub const PhantomBatchPolishRequest = struct {
    pub const msg_id: u16 = 23281;
    pub const IncrIds_field_number: u32 = 9;
    pub const PhantomMainPropItemId_field_number: u32 = 1;
};
pub const PhantomBatchPolishResponse = struct {
    pub const msg_id: u16 = 21278;
    pub const ErrorCode_field_number: u32 = 1;
    pub const UpdateInfos_field_number: u32 = 3;
};
pub const PhantomVicePolishRequest = struct {
    pub const msg_id: u16 = 24159;
    pub const IncrId_field_number: u32 = 12;
    pub const LockPropIndex_field_number: u32 = 8;
};
pub const PhantomVicePolishResponse = struct {
    pub const msg_id: u16 = 16787;
    pub const ErrorCode_field_number: u32 = 9;
    pub const PhantomSubProp_field_number: u32 = 3;
};
pub const PhantomVicePolishAckRequest = struct {
    pub const msg_id: u16 = 15598;
    pub const IncrId_field_number: u32 = 4;
    pub const Ack_field_number: u32 = 6;
};
pub const PhantomVicePolishAckResponse = struct {
    pub const msg_id: u16 = 25917;
    pub const ErrorCode_field_number: u32 = 12;
    pub const UpdateInfo_field_number: u32 = 2;
};
pub const RefreshVisionEquipGroupData = struct {
    pub const IncId_field_number: u32 = 1;
    pub const Name_field_number: u32 = 2;
};
pub const VisionEquipGroupInfoRequest = struct {
    pub const msg_id: u16 = 25243;
};
pub const VisionEquipGroupInfoResponse = struct {
    pub const msg_id: u16 = 21324;
    pub const ErrorCode_field_number: u32 = 10;
    pub const VisionEquipList_field_number: u32 = 8;
};
pub const AddVisionEquipGroupRequest = struct {
    pub const msg_id: u16 = 25994;
    pub const RoleId_field_number: u32 = 10;
    pub const Name_field_number: u32 = 11;
};
pub const AddVisionEquipGroupResponse = struct {
    pub const msg_id: u16 = 23202;
    pub const ErrorCode_field_number: u32 = 4;
    pub const VisionEquipList_field_number: u32 = 1;
};
pub const DeleteVisionEquipGroupRequest = struct {
    pub const msg_id: u16 = 23109;
    pub const Index_field_number: u32 = 6;
};
pub const DeleteVisionEquipGroupResponse = struct {
    pub const msg_id: u16 = 26003;
    pub const ErrorCode_field_number: u32 = 13;
    pub const VisionEquipList_field_number: u32 = 4;
};
pub const PutVisionGroupToTopRequest = struct {
    pub const msg_id: u16 = 23121;
    pub const Index_field_number: u32 = 8;
};
pub const PutVisionGroupToTopResponse = struct {
    pub const msg_id: u16 = 18781;
    pub const ErrorCode_field_number: u32 = 8;
    pub const VisionEquipList_field_number: u32 = 10;
};
pub const ChangeVisionGroupNameRequest = struct {
    pub const msg_id: u16 = 18634;
    pub const Index_field_number: u32 = 8;
    pub const Name_field_number: u32 = 15;
};
pub const ChangeVisionGroupNameResponse = struct {
    pub const msg_id: u16 = 22084;
    pub const ErrorCode_field_number: u32 = 2;
    pub const VisionEquipList_field_number: u32 = 4;
};
pub const ApplyVisionGroupRequest = struct {
    pub const msg_id: u16 = 23152;
    pub const Index_field_number: u32 = 13;
    pub const RoleId_field_number: u32 = 7;
};
pub const ApplyVisionGroupResponse = struct {
    pub const msg_id: u16 = 20670;
    pub const ErrorCode_field_number: u32 = 8;
    pub const EquipInfoList_field_number: u32 = 2;
};
pub const GetMusicInfoRequest = struct {
    pub const msg_id: u16 = 21085;
};
pub const GetMusicInfoResponse = struct {
    pub const msg_id: u16 = 27484;
    pub const CurMusicId_field_number: u32 = 15;
    pub const ErrorCode_field_number: u32 = 8;
    pub const AlbumTimeInfos_field_number: u32 = 1;
    pub const TotalMusicIds_field_number: u32 = 11;
    pub const CollectMusicIds_field_number: u32 = 5;
};
pub const FavoriteMusicMotorCycleUpdateRequest = struct {
    pub const msg_id: u16 = 27306;
    pub const FavoriteMusicList_field_number: u32 = 13;
};
pub const FavoriteMusicMotorCycleUpdateResponse = struct {
    pub const msg_id: u16 = 28833;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const PhonographAlbumTimeInfo = struct {
    pub const AlbumId_field_number: u32 = 1;
    pub const BeginTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
    pub const MusicIds_field_number: u32 = 4;
    pub const CollectMusicIds_field_number: u32 = 5;
};
pub const FragmentMemoryData = struct {
    pub const Id_field_number: u32 = 1;
    pub const Flag_field_number: u32 = 2;
    pub const FinishTime_field_number: u32 = 3;
};
pub const FragmentMemoryItem = struct {
    pub const Id_field_number: u32 = 1;
    pub const Data_field_number: u32 = 2;
    pub const IsUnlock_field_number: u32 = 3;
};
pub const PhotoMemoryRequest = struct {
    pub const msg_id: u16 = 15846;
};
pub const PhotoMemoryResponse = struct {
    pub const msg_id: u16 = 27200;
    pub const Item_field_number: u32 = 12;
};
pub const VisionFetterRecommendInfo = struct {
    pub const Usage_field_number: u32 = 2;
    pub const RecommendFetterGroupInfos_field_number: u32 = 3;
    pub const CostCombinationInfos_field_number: u32 = 4;
};
pub const RecommendFetterGroupInfo = struct {
    pub const RecommendFetterGroupId_field_number: u32 = 1;
    pub const CountNeed_field_number: u32 = 2;
};
pub const CostCombinationInfo = struct {
    pub const CostId_field_number: u32 = 1;
    pub const Usage_field_number: u32 = 2;
};
pub const VisionAttrRecommendInfo = struct {
    pub const AttrType_field_number: u32 = 1;
    pub const AddType_field_number: u32 = 2;
    pub const Usage_field_number: u32 = 3;
};
pub const CostVisionAttrRecommendInfo = struct {
    pub const Cost_field_number: u32 = 1;
    pub const GetMainAttrRecommendInfo_field_number: u32 = 2;
    pub const GetSubAttrRecommendInfo_field_number: u32 = 3;
};
pub const RoleVisionRecommendDataRequest = struct {
    pub const msg_id: u16 = 24976;
    pub const RoleId_field_number: u32 = 11;
};
pub const RoleVisionRecommendDataResponse = struct {
    pub const msg_id: u16 = 26801;
    pub const ErrorCode_field_number: u32 = 4;
    pub const VisionFetterRecommendInfo_field_number: u32 = 11;
};
pub const RoleVisionRecommendAttrRequest = struct {
    pub const msg_id: u16 = 26830;
    pub const RoleId_field_number: u32 = 10;
};
pub const RoleVisionRecommendAttrResponse = struct {
    pub const msg_id: u16 = 21509;
    pub const ErrorCode_field_number: u32 = 3;
    pub const VisionAttrRecommendInfos_field_number: u32 = 7;
};
pub const MainPhantomRecommendInfo = struct {
    pub const Usage_field_number: u32 = 1;
    pub const MonsterId_field_number: u32 = 2;
    pub const FetterGroupId_field_number: u32 = 3;
};
pub const RoleVisionMainPhantomRequest = struct {
    pub const msg_id: u16 = 20399;
    pub const RoleId_field_number: u32 = 13;
};
pub const RoleVisionMainPhantomResponse = struct {
    pub const msg_id: u16 = 26939;
    pub const ErrorCode_field_number: u32 = 12;
    pub const RecommendInfo_field_number: u32 = 7;
};
pub const PassiveSkillInfo = struct {
    pub const SkillId_field_number: u32 = 1;
    pub const SkillCdEndTime_field_number: u32 = 2;
};
pub const RolePassiveSkillInfo = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const PassiveSkillInfoList_field_number: u32 = 2;
};
pub const PassiveSkillNotify = struct {
    pub const msg_id: u16 = 23150;
    pub const RolePassiveSkillInfoList_field_number: u32 = 13;
};
pub const PlayerTitleData = struct {
    pub const PlayerTitleId_field_number: u32 = 1;
    pub const IsUnlock_field_number: u32 = 2;
    pub const UnlockTime_field_number: u32 = 3;
    pub const StarLevel_field_number: u32 = 4;
    pub const ActivityServerRewardItemData_field_number: u32 = 5;
};
pub const SetDressedPlayerTitleNotify = struct {
    pub const msg_id: u16 = 17570;
    pub const PlayerTitleId_field_number: u32 = 4;
    pub const CurPlayerTitleId_field_number: u32 = 7;
};
pub const PlayerTitleDataRequest = struct {
    pub const msg_id: u16 = 29113;
};
pub const PlayerTitleDataResponse = struct {
    pub const msg_id: u16 = 29735;
    pub const PlayerTitleData_field_number: u32 = 2;
    pub const ErrorCode_field_number: u32 = 8;
    pub const PlayerTitleLimitInfos_field_number: u32 = 14;
};
pub const PlayerTitleLimitInfo = struct {
    pub const PlayerTitleId_field_number: u32 = 1;
    pub const BeginTime_field_number: u32 = 2;
    pub const EndTime_field_number: u32 = 3;
};
pub const ChangePlayerTitleRequest = struct {
    pub const msg_id: u16 = 16235;
    pub const PlayerTitleId_field_number: u32 = 2;
};
pub const ChangePlayerTitleResponse = struct {
    pub const msg_id: u16 = 25847;
    pub const ErrorCode_field_number: u32 = 4;
};
pub const PlayerVarNotify = struct {
    pub const msg_id: u16 = 21874;
    pub const VarInfos_field_number: u32 = 6;
};
pub const PlayerMotionRequest = struct {
    pub const msg_id: u16 = 23967;
    pub const Motion_field_number: u32 = 9;
};
pub const PlayerMotionResponse = struct {
    pub const msg_id: u16 = 21656;
    pub const ErrorId_field_number: u32 = 8;
};
pub const JSPatchNotify = struct {
    pub const msg_id: u16 = 24958;
    pub const Content_field_number: u32 = 3;
};
pub const QuestInfo = struct {
    pub const QuestId_field_number: u32 = 1;
    pub const Status_field_number: u32 = 2;
};
pub const QuestListNotify = struct {
    pub const msg_id: u16 = 25474;
    pub const Quests_field_number: u32 = 11;
};
pub const TraceQuestNotify = struct {
    pub const msg_id: u16 = 21168;
    pub const QuestId_field_number: u32 = 4;
};
pub const TraceQuestRequest = struct {
    pub const msg_id: u16 = 27549;
    pub const TraceType_field_number: u32 = 6;
    pub const QuestId_field_number: u32 = 5;
    pub const Operate_field_number: u32 = 15;
};
pub const TraceQuestResponse = struct {
    pub const msg_id: u16 = 20341;
    pub const ErrorId_field_number: u32 = 10;
};
pub const QuestReadyListNotify = struct {
    pub const msg_id: u16 = 20130;
    pub const QuestId_field_number: u32 = 7;
};
pub const QuestShowListNotify = struct {
    pub const msg_id: u16 = 21274;
    pub const QuestId_field_number: u32 = 5;
};
pub const QuestFinishListNotify = struct {
    pub const msg_id: u16 = 27820;
    pub const QuestId_field_number: u32 = 15;
};
pub const QuestRedDotRequest = struct {
    pub const msg_id: u16 = 20525;
    pub const QuestId_field_number: u32 = 7;
    pub const Operate_field_number: u32 = 14;
};
pub const QuestRedDotResponse = struct {
    pub const msg_id: u16 = 24256;
    pub const ErrorId_field_number: u32 = 13;
};
pub const QuestRedDotNotify = struct {
    pub const msg_id: u16 = 16468;
    pub const QuestId_field_number: u32 = 12;
};
pub const ConfirmQuestResourceRequest = struct {
    pub const msg_id: u16 = 19981;
    pub const QuestIds_field_number: u32 = 1;
};
pub const ConfirmQuestResourceResponse = struct {
    pub const msg_id: u16 = 26227;
    pub const ErrorId_field_number: u32 = 13;
};
pub const SetQuestFocusModeRequest = struct {
    pub const msg_id: u16 = 23532;
    pub const QuestId_field_number: u32 = 10;
};
pub const SetQuestFocusModeResponse = struct {
    pub const msg_id: u16 = 20414;
    pub const ErrorCode_field_number: u32 = 15;
};
pub const CancelQuestFocusModeRequest = struct {
    pub const msg_id: u16 = 22143;
    pub const QuestId_field_number: u32 = 4;
};
pub const CancelQuestFocusModeResponse = struct {
    pub const msg_id: u16 = 15535;
    pub const ErrorCode_field_number: u32 = 12;
};
pub const AcceptFocusWaitQuestRequest = struct {
    pub const msg_id: u16 = 23689;
    pub const QuestId_field_number: u32 = 7;
};
pub const AcceptFocusWaitQuestResponse = struct {
    pub const msg_id: u16 = 27817;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const FocusQuestSetNotify = struct {
    pub const msg_id: u16 = 26564;
    pub const FocusQuestId_field_number: u32 = 15;
    pub const Reason_field_number: u32 = 12;
};
pub const FocusQuestChangeNotify = struct {
    pub const msg_id: u16 = 22946;
    pub const FocusQuestId_field_number: u32 = 4;
};
pub const SetFocusModeDeterConditionRequest = struct {
    pub const msg_id: u16 = 21629;
    pub const DisableId_field_number: u32 = 12;
};
pub const SetFocusModeDeterConditionResponse = struct {
    pub const msg_id: u16 = 20065;
    pub const ErrorCode_field_number: u32 = 14;
};
pub const ClientPullResourcePackageRequest = struct {
    pub const msg_id: u16 = 29373;
    pub const Holder_field_number: u32 = 4;
};
pub const ClientPullResourcePackageResponse = struct {
    pub const msg_id: u16 = 22049;
    pub const ErrorId_field_number: u32 = 5;
    pub const FinishMp4QuestIds_field_number: u32 = 3;
    pub const NeedConfirmQuestIds_field_number: u32 = 12;
};
pub const QuestReviewDataRequest = struct {
    pub const msg_id: u16 = 22457;
};
pub const QuestReviewDataResponse = struct {
    pub const msg_id: u16 = 22672;
    pub const ErrorCode_field_number: u32 = 1;
};
pub const QuestBranchInfo = struct {
    pub const QuestBranchInfos_field_number: u32 = 1;
    pub const UnlockTimePoints_field_number: u32 = 2;
    pub const UnlockBranchComponentsGroup_field_number: u32 = 3;
};
pub const OneQuestBranchPageInfo = struct {
    pub const id_field_number: u32 = 1;
    pub const CurBranch_field_number: u32 = 2;
    pub const CompleteBranches_field_number: u32 = 3;
};
pub const QuestBranchRequest = struct {
    pub const msg_id: u16 = 23494;
};
pub const QuestBranchResponse = struct {
    pub const msg_id: u16 = 26678;
    pub const errorCode_field_number: u32 = 6;
    pub const QuestBranchInfo_field_number: u32 = 14;
};
pub const EntityAccessInfo = struct {
    pub const EntityId_field_number: u32 = 1;
    pub const RangeType_field_number: u32 = 2;
    pub const AcessRangeResults_field_number: u32 = 3;
};
pub const EntityAccessRangeRequest = struct {
    pub const msg_id: u16 = 17555;
    pub const EntityId_field_number: u32 = 1;
    pub const EntitiesToCheck_field_number: u32 = 10;
    pub const RangeType_field_number: u32 = 2;
};
pub const EntityAccessRangeResponse = struct {
    pub const msg_id: u16 = 15504;
    pub const ErrorCode_field_number: u32 = 13;
    pub const EntityId_field_number: u32 = 6;
    pub const Info_field_number: u32 = 11;
};
pub const PlayerAccessEffectAreaRequest = struct {
    pub const msg_id: u16 = 23423;
    pub const EntityId_field_number: u32 = 12;
    pub const RangeType_field_number: u32 = 1;
};
pub const PlayerAccessEffectAreaResponse = struct {
    pub const msg_id: u16 = 29362;
    pub const ErrorCode_field_number: u32 = 8;
    pub const EntityId_field_number: u32 = 12;
    pub const Info_field_number: u32 = 9;
};
pub const InitRangeRequest = struct {
    pub const msg_id: u16 = 29177;
    pub const EntityId_field_number: u32 = 13;
    pub const EntitiesToRequest_field_number: u32 = 8;
    pub const IsPlayerInRange_field_number: u32 = 15;
};
pub const InitRangeResponse = struct {
    pub const msg_id: u16 = 15432;
    pub const ErrorCode_field_number: u32 = 1;
    pub const EntityId_field_number: u32 = 15;
    pub const Info_field_number: u32 = 9;
    pub const PlayerAccessRangeResult_field_number: u32 = 2;
};
pub const ExtraDeadInfo = struct {
    Message: ?union(enum) {
    } = null,
    pub const BtBloodBathedModeInfo_field_number: u32 = 1;
};
pub const PlayerDeadNotify = struct {
    pub const msg_id: u16 = 25670;
    pub const PlayerId_field_number: u32 = 13;
    pub const DelaySeconds_field_number: u32 = 10;
    pub const IsAutoRevive_field_number: u32 = 1;
    pub const ReviveId_field_number: u32 = 2;
    pub const IsLogin_field_number: u32 = 5;
    pub const IsShowRevive_field_number: u32 = 4;
    pub const ExtraDeadInfos_field_number: u32 = 11;
};
pub const DeathStatusInfo = struct {
    pub const GroupType_field_number: u32 = 1;
    pub const LivingStatus_field_number: u32 = 2;
};
pub const AliveStatusNotify = struct {
    pub const msg_id: u16 = 15458;
    pub const PlayerId_field_number: u32 = 11;
    pub const Info_field_number: u32 = 7;
};
pub const BtBloodBathedModeInfo = struct {
    pub const BtType_field_number: u32 = 1;
    pub const BtObjId_field_number: u32 = 2;
    pub const BtObjSetting_field_number: u32 = 3;
};
pub const RoguelikeCurrencyNotify = struct {
    pub const msg_id: u16 = 18382;
    pub const V2s_field_number: u32 = 5;
};
pub const SceneBlockSplitPlayerNeedBlockPush = struct {
    pub const msg_id: u16 = 29426;
    pub const PlayerNeedBlockId_field_number: u32 = 11;
};
pub const GetRewardTreasureBoxRequest = struct {
    pub const msg_id: u16 = 24690;
    pub const EntityId_field_number: u32 = 12;
};
pub const GetRewardTreasureBoxResponse = struct {
    pub const msg_id: u16 = 17694;
    pub const ErrorCode_field_number: u32 = 7;
};
pub const MobileButtonSetting = struct {
    pub const Id_field_number: u32 = 1;
    pub const Size_field_number: u32 = 2;
    pub const Transparency_field_number: u32 = 3;
    pub const ScreenX_field_number: u32 = 4;
    pub const ScreenY_field_number: u32 = 5;
    pub const ButtonLevel_field_number: u32 = 6;
    pub const PanelLevel_field_number: u32 = 7;
};
pub const SettingNotify = struct {
    pub const msg_id: u16 = 26279;
    pub const MobileButtonSettings_field_number: u32 = 1;
};
pub const LanguageSettingUpdateRequest = struct {
    pub const msg_id: u16 = 18438;
    pub const Language_field_number: u32 = 8;
};
pub const LanguageSettingUpdateResponse = struct {
    pub const msg_id: u16 = 17563;
    pub const ErrorCode_field_number: u32 = 5;
};
pub const ServerPlayStationPlayOnlyStateRequest = struct {
    pub const msg_id: u16 = 29952;
};
pub const ServerPlayStationPlayOnlyStateResponse = struct {
    pub const msg_id: u16 = 20560;
    pub const CrossPlayEnabled_field_number: u32 = 15;
};
pub const CombinationKey = struct {
    pub const KeyNameList_field_number: u32 = 1;
};
pub const InputAction = struct {
    pub const ActionName_field_number: u32 = 1;
    pub const KeyNameList_field_number: u32 = 2;
    pub const Version_field_number: u32 = 3;
    pub const InputType_field_number: u32 = 4;
};
pub const InputAxis = struct {
    pub const AxisName_field_number: u32 = 1;
    pub const KeyScaleMap_field_number: u32 = 2;
    pub const Version_field_number: u32 = 3;
    pub const InputType_field_number: u32 = 4;
};
pub const CombinationAction = struct {
    pub const ActionName_field_number: u32 = 1;
    pub const CombinationKeyList_field_number: u32 = 2;
    pub const Version_field_number: u32 = 3;
    pub const InputType_field_number: u32 = 4;
};
pub const CombinationAxis = struct {
    pub const AxisName_field_number: u32 = 1;
    pub const CombinationKeyList_field_number: u32 = 2;
    pub const Version_field_number: u32 = 3;
    pub const InputType_field_number: u32 = 4;
};
pub const InputSettingData = struct {
    pub const InputSettings_field_number: u32 = 1;
};
pub const DeviceInputSetting = struct {
    pub const Device_field_number: u32 = 5;
    pub const DeviceSubType_field_number: u32 = 6;
    pub const InputAction_field_number: u32 = 7;
    pub const InputAxis_field_number: u32 = 8;
    pub const InputCombinationAction_field_number: u32 = 9;
    pub const InputCombinationAxis_field_number: u32 = 10;
};
pub const InputSettingRequest = struct {
    pub const msg_id: u16 = 21665;
};
pub const InputSettingResponse = struct {
    pub const msg_id: u16 = 21942;
    pub const InputSettingData_field_number: u32 = 13;
};
pub const InputSettingUpdateRequest = struct {
    pub const msg_id: u16 = 19722;
    pub const InputSettingData_field_number: u32 = 4;
};
pub const InputSettingUpdateResponse = struct {
    pub const msg_id: u16 = 16181;
    pub const ErrorCode_field_number: u32 = 8;
};
pub const XboxSettingRequest = struct {
    pub const msg_id: u16 = 16406;
};
pub const XboxSettingResponse = struct {
    pub const msg_id: u16 = 29066;
    pub const MatchXboxUser_field_number: u32 = 15;
};
pub const SheriffCriminalInfo = struct {
    pub const CriminalId_field_number: u32 = 1;
    pub const state_field_number: u32 = 2;
    pub const IdentityId_field_number: u32 = 3;
};
pub const SheriffAnomalyInfo = struct {
    pub const AnomalyId_field_number: u32 = 1;
    pub const ClueIds_field_number: u32 = 2;
    pub const ProgressIds_field_number: u32 = 3;
    pub const EndingId_field_number: u32 = 4;
    pub const CompleteTime_field_number: u32 = 5;
    pub const IsActivated_field_number: u32 = 6;
    pub const IsUnlocked_field_number: u32 = 7;
};
pub const SheriffZoneInfo = struct {
    pub const ZoneId_field_number: u32 = 1;
    pub const AnomalyInfos_field_number: u32 = 2;
    pub const CriminalInfos_field_number: u32 = 3;
    pub const ItemCount_field_number: u32 = 4;
};
pub const SheriffZoneInfoRequest = struct {
    pub const msg_id: u16 = 28956;
    pub const ZoneIds_field_number: u32 = 12;
};
pub const SheriffZoneInfoResponse = struct {
    pub const msg_id: u16 = 29617;
    pub const errorCode_field_number: u32 = 11;
    pub const ZoneInfos_field_number: u32 = 5;
};
pub const ShortMessageInfo = struct {
    pub const ConfigId_field_number: u32 = 1;
    pub const LastConfigId_field_number: u32 = 2;
    pub const IsRead_field_number: u32 = 3;
    pub const IsReceived_field_number: u32 = 4;
    pub const Options_field_number: u32 = 5;
    pub const UnlockTime_field_number: u32 = 6;
    pub const IsFinish_field_number: u32 = 7;
};
pub const AllMsgRequest = struct {
    pub const msg_id: u16 = 28440;
};
pub const AllMsgResponse = struct {
    pub const msg_id: u16 = 21036;
    pub const ShortMessageInfos_field_number: u32 = 5;
    pub const BubbleIds_field_number: u32 = 14;
    pub const BubbleId_field_number: u32 = 1;
    pub const ChatBgIds_field_number: u32 = 3;
    pub const ChatBgId_field_number: u32 = 13;
    pub const ErrCode_field_number: u32 = 9;
    pub const PartnerChange_field_number: u32 = 15;
};
pub const BattleFormation = struct {
    pub const SelectRoles_field_number: u32 = 1;
    pub const BuffSelect_field_number: u32 = 2;
    pub const SkillBranchIds_field_number: u32 = 3;
};
pub const SlashLevelPlayInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const IsLocked_field_number: u32 = 2;
    pub const FirstScore_field_number: u32 = 3;
    pub const SecondScore_field_number: u32 = 4;
    pub const FirstBattle_field_number: u32 = 5;
    pub const SecondBattle_field_number: u32 = 6;
    pub const IsPassed_field_number: u32 = 7;
    pub const IsEasyPass_field_number: u32 = 8;
};
pub const SlashAndTowerInfoRequest = struct {
    pub const msg_id: u16 = 17493;
};
pub const SlashAndTowerInfoResponse = struct {
    pub const msg_id: u16 = 18229;
    pub const ErrorCode_field_number: u32 = 5;
    pub const SlashLevelPlayInfo_field_number: u32 = 4;
    pub const RewardsReceived_field_number: u32 = 6;
    pub const CurSeasonEndTime_field_number: u32 = 10;
    pub const UpdateSeason_field_number: u32 = 9;
    pub const CurIsHaveRecord_field_number: u32 = 14;
    pub const BuffCache_field_number: u32 = 2;
};
pub const TowerInfo = struct {
    pub const CurrentSeason_field_number: u32 = 1;
    pub const DataSeason_field_number: u32 = 2;
    pub const TowerDifficulties_field_number: u32 = 3;
    pub const BeginTime_field_number: u32 = 4;
    pub const EndTime_field_number: u32 = 5;
    pub const MaxUnlockDifficulty_field_number: u32 = 6;
    pub const QuickPassId_field_number: u32 = 7;
};
pub const TowerDifficultyPb = struct {
    pub const Difficulty_field_number: u32 = 1;
    pub const RewardIndex_field_number: u32 = 2;
    pub const TowerAreas_field_number: u32 = 3;
    pub const MaxStar_field_number: u32 = 4;
};
pub const TowerAreaPb = struct {
    pub const AreaNum_field_number: u32 = 1;
    pub const TowerFloors_field_number: u32 = 2;
};
pub const TowerFloorPb = struct {
    pub const TowerConfigId_field_number: u32 = 1;
    pub const Star_field_number: u32 = 2;
    pub const Formation_field_number: u32 = 4;
    pub const StarIndex_field_number: u32 = 5;
    pub const IsQuickPass_field_number: u32 = 6;
};
pub const TowerRolePb = struct {
    pub const RoleId_field_number: u32 = 1;
    pub const LeaveSkillId_field_number: u32 = 2;
    pub const SkillBranchId_field_number: u32 = 3;
};
pub const TowerRequest = struct {
    pub const msg_id: u16 = 25227;
};
pub const TowerResponse = struct {
    pub const msg_id: u16 = 21232;
    pub const TowerInfo_field_number: u32 = 12;
};
pub const TowerSeasonUpdateRequest = struct {
    pub const msg_id: u16 = 19054;
};
pub const TowerSeasonUpdateResponse = struct {
    pub const msg_id: u16 = 23170;
    Towers: ?union(enum) {
    } = null,
    pub const TowerInfo_field_number: u32 = 9;
    pub const MaxUnlockDifficulty_field_number: u32 = 12;
};
pub const MoonChasingTrackMoonHandbookRewardNotify = struct {
    pub const msg_id: u16 = 23897;
    pub const Ids_field_number: u32 = 8;
};
pub const MoonChasingTargetGetCountNotify = struct {
    pub const msg_id: u16 = 29671;
    pub const TargetGetCount_field_number: u32 = 5;
};
pub const TutorialInfo = struct {
    pub const Id_field_number: u32 = 1;
    pub const CreateTime_field_number: u32 = 2;
    pub const GetAward_field_number: u32 = 3;
};
pub const TutorialInfoRequest = struct {
    pub const msg_id: u16 = 21281;
};
pub const TutorialInfoResponse = struct {
    pub const msg_id: u16 = 25064;
    pub const UnlockList_field_number: u32 = 11;
};
pub const TutorialReceiveRequest = struct {
    pub const msg_id: u16 = 24252;
    pub const Id_field_number: u32 = 14;
};
pub const TutorialReceiveResponse = struct {
    pub const msg_id: u16 = 22731;
    pub const ErrorCode_field_number: u32 = 5;
    pub const ErrorParams_field_number: u32 = 10;
    pub const ItemMap_field_number: u32 = 12;
};
pub const TutorialUnlockRequest = struct {
    pub const msg_id: u16 = 23137;
    pub const Id_field_number: u32 = 7;
};
pub const TutorialUnlockResponse = struct {
    pub const msg_id: u16 = 26171;
    pub const ErrorCode_field_number: u32 = 11;
    pub const ErrorParams_field_number: u32 = 14;
    pub const UnLockInfo_field_number: u32 = 10;
};
pub const WeaponConsumeItem = struct {
    pub const IncId_field_number: u32 = 1;
    pub const Count_field_number: u32 = 2;
    pub const ItemId_field_number: u32 = 3;
};
pub const WeaponLevelUpRequest = struct {
    pub const msg_id: u16 = 19280;
    pub const IncId_field_number: u32 = 14;
    pub const ConsumeList_field_number: u32 = 11;
};
pub const WeaponLevelUpResponse = struct {
    pub const msg_id: u16 = 21421;
    pub const ErrorCode_field_number: u32 = 10;
    pub const IncId_field_number: u32 = 13;
    pub const WeaponLevel_field_number: u32 = 2;
    pub const WeaponExp_field_number: u32 = 3;
    pub const ItemMap_field_number: u32 = 5;
};
pub const WeaponBreachRequest = struct {
    pub const msg_id: u16 = 19109;
    pub const IncId_field_number: u32 = 4;
};
pub const WeaponBreachResponse = struct {
    pub const msg_id: u16 = 27219;
    pub const ErrorCode_field_number: u32 = 5;
    pub const IncId_field_number: u32 = 12;
    pub const WeaponBreach_field_number: u32 = 3;
};
pub const WeaponResonUpRequest = struct {
    pub const msg_id: u16 = 20804;
    pub const IncId_field_number: u32 = 2;
    pub const ConsumeList_field_number: u32 = 8;
    pub const ConsumeItemList_field_number: u32 = 7;
};
pub const WeaponResonUpResponse = struct {
    pub const msg_id: u16 = 20680;
    pub const ErrorCode_field_number: u32 = 1;
    pub const IncId_field_number: u32 = 12;
    pub const ResonLevel_field_number: u32 = 4;
};
pub const WeeklyFrameworkInfoRequest = struct {
    pub const msg_id: u16 = 24197;
};
pub const WeeklyFrameworkInfoResponse = struct {
    pub const msg_id: u16 = 16309;
    pub const ErrorCode_field_number: u32 = 6;
    pub const FrameworkInfo_field_number: u32 = 11;
};
pub const WeeklyFrameworkInfo = struct {
    pub const ConfigId_field_number: u32 = 1;
    pub const BeginTime_field_number: u32 = 3;
    pub const EndTime_field_number: u32 = 4;
    pub const ScoreTasks_field_number: u32 = 5;
    pub const WeeklyPlayDatas_field_number: u32 = 6;
    pub const WorldLevel_field_number: u32 = 7;
};
pub const WeeklyPlayData = struct {
    qWp: ?union(enum) {
    } = null,
    pub const RogueWeeklyPlayData_field_number: u32 = 10000;
    pub const FloroFarmPlayData_field_number: u32 = 10001;
    pub const id_field_number: u32 = 1;
    pub const type_field_number: u32 = 2;
};
pub const RogueWeeklyPlayData = struct {
    pub const HasRecord_field_number: u32 = 1;
};
pub const FloroFarmPlayData = struct {
    pub const HasRecord_field_number: u32 = 1;
};
pub const LobbyListRequest = struct {
    pub const msg_id: u16 = 17638;
    pub const IsFriend_field_number: u32 = 8;
};
pub const LobbyListResponse = struct {
    pub const msg_id: u16 = 20257;
    pub const ErrorCode_field_number: u32 = 7;
    pub const ItemList_field_number: u32 = 1;
};
