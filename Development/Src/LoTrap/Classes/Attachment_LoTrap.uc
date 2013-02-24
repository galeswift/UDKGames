//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Attachment_LoTrap extends UTWeaponAttachment;
//
///**
// * Spawn any effects that occur at the impact point.  It's called from the pawn.
// */
//simulated function PlayImpactEffects(vector HitLocation)
//{
//	local vector NewHitLoc, HitNormal, FireDir, WaterHitNormal;
//	local Actor HitActor;
//	local TraceHitInfo HitInfo;
//	local MaterialImpactEffect ImpactEffect;
//	local MaterialInterface MI;
//	local MaterialInstanceTimeVarying MITV_Decal;
//	local int DecalMaterialsLength;
//	local Vehicle V;
//	local UTPawn P;
//
//	P = UTPawn(Owner);
//	HitNormal = Normal(Owner.Location - HitLocation);
//	FireDir = -1 * HitNormal;
//	if ( (P != None) && EffectIsRelevant(HitLocation, false, MaxImpactEffectDistance) )
//	{
//
//		// figure out the impact sound to use
//		ImpactEffect = GetImpactEffect(HitInfo.PhysMaterial);
//
//		// Pawns handle their own hit effects
//		if ( HitActor != None &&
//			 (Pawn(HitActor) == None || Vehicle(HitActor) != None) &&
//			 AllowImpactEffects(HitActor, HitLocation, HitNormal) )
//		{
//			// if we have a decal to spawn on impact
//			DecalMaterialsLength = ImpactEffect.DecalMaterials.length;
//			if( DecalMaterialsLength > 0 )
//			{
//				MI = ImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];
//				if( MI != None )
//				{
//					WorldInfo.MyDecalManager.SpawnDecal( MI, HitLocation, rotator(-HitNormal), ImpactEffect.DecalWidth,
//						ImpactEffect.DecalHeight, 10.0, true,0.0f, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
//				}
//			}
//
//			if (ImpactEffect.ParticleTemplate != None)
//			{
//				if (!bAlignToSurfaceNormal)
//				{
//					HitNormal = normal(FireDir - ( 2 *  HitNormal * (FireDir dot HitNormal) ) ) ;
//				}
//				WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffect.ParticleTemplate, HitLocation, rotator(HitNormal), HitActor);
//			}
//		}
//	}
//
//
//}
DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_LoTrap.Meshes.SK_WP_LoTrap_MID'
	End Object

//	DefaultImpactEffect=(Sound=SoundCue'A_Weapon_BulletImpacts.Cue.A_Weapon_Impact_Stone_Cue',ParticleTemplate=none,DecalMaterials=(MaterialInterface'WP_LoTrap.Decal.DM_LoTrap_Decal'),DecalWidth=256.0,DecalHeight=256.0)
//	DefaultAltImpactEffect=(Sound=SoundCue'A_Weapon_BulletImpacts.Cue.A_Weapon_Impact_Stone_Cue',ParticleTemplate=none,DecalMaterials=(MaterialInterface'WP_LoTrap.Decal.DM_LoTrap_Decal'),DecalWidth=256.0,DecalHeight=256.0)

}