//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GB_FamilyInfo_Gir extends UTFamilyInfo_Human;

DefaultProperties
{
	Faction="GirFaction"

	NonTeamEmissiveColor=(R=10.0,G=10.0,B=2.0)
	NonTeamTintColor=(R=3.0,G=2.0,B=1.0)

	FamilyID="GBGir"

	ArmMeshPackageName="CH_IronGuard_Arms"
	ArmMeshName="CH_IronGuard_Arms.Mesh.SK_CH_IronGuard_Arms_MaleB_1P"
	ArmSkinPackageName="CH_IronGuard_Arms"
	RedArmSkinName="CH_IronGuard_Arms.Materials.M_CH_IronG_Arms_FirstPersonArm_VRed"
	BlueArmSkinName="CH_IronGuard_Arms.Materials.M_CH_IronG_Arms_FirstPersonArm_VBlue"

	NeckStumpName="SK_CH_IronG_Male_NeckStump01"

	PhysAsset=PhysicsAsset'GB_CH_Gir.Meshes.SK_Gir_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

	BaseMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_IronG_Base'
	BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_IronG_BioDeath'

	MasterSkeleton=SkeletalMesh'CH_All.Mesh.SK_Master_Skeleton_Human_Male'
	CharEditorIdleAnimName="CC_Human_Male_Idle"
}
