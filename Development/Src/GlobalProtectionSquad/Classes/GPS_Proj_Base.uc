class GPS_Proj_Base extends UTProj_LinkPlasma;

/* Init()
 * Overwritten to ask the weapon for projectile modifications
*/
function Init( Vector Direction )
{
	if( Instigator != none &&
		GPS_Weap_Base(Instigator.Weapon) != none )
	{
		GPS_Weap_Base(Instigator.Weapon).ModifyProjectileProperties( self );
	}

	super.Init( Direction );
}

simulated function bool HurtRadius( float DamageAmount,
								    float InDamageRadius,
				    class<DamageType> DamageType,
									float Momentum,
									vector HurtOrigin,
									optional actor IgnoredActor,
									optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
									optional bool bDoFullDamage
									)
{
	DoBreakFracturedMeshes( HurtOrigin, InDamageRadius, Momentum, DamageType);

	return super.HurtRadius( DamageAmount, InDamageRadius, DamageType, MomentumTransfer, HurtOrigin, IgnoredActor, InstigatedByController, bDoFullDamage );	
}

/** Look for FSMAs in radius and break parts off. */
protected simulated function DoBreakFracturedMeshes(vector ExploOrigin, float InDamageRadius, float RBStrength, class<DamageType> DmgType)
{
	local FracturedStaticMeshActor FracActor;
	local byte bWantPhysChunksAndParticles;

	foreach CollidingActors(class'FracturedStaticMeshActor', FracActor, DamageRadius, ExploOrigin, TRUE)
	{
		if ( (FracActor.Physics == PHYS_None)
			  && FracActor.IsFracturedByDamageType(DmgType))
		{
			// Make sure the impacted fractured mesh is visually relevant
			if( FracActor.FractureEffectIsRelevant( false, Instigator, bWantPhysChunksAndParticles ) )
			{
				FracActor.BreakOffPartsInRadius(
					ExploOrigin,
					InDamageRadius,
					RBStrength,
					bWantPhysChunksAndParticles == 1 ? true : false);
			}
		}
	}
}
DefaultProperties
{
	bRotationFollowsVelocity=true
	MyDamageType=class'GPS_DmgType_Base'
}
