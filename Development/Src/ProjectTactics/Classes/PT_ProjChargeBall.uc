class PT_ProjChargeBall extends UTProj_ShockBall;

var float ChargeAmount;
var float MaxHits;

/**
 * Explode this Projectile
 */
simulated function Explode(vector HitLocation, vector HitNormal)
{
	SetChargeAmount(ChargeAmount - (1.0/MaxHits) );

	if (Damage>0 && DamageRadius>0)
	{
		if ( Role == ROLE_Authority )
			MakeNoise(1.0);
		if ( !bShuttingDown )
		{
			ProjectileHurtRadius(HitLocation, HitNormal );
		}
	}
	SpawnExplosionEffects(HitLocation, HitNormal);
	
	if( ChargeAmount <= 0.0001f )
	{
		ShutDown();
	}
}

simulated function SetChargeAmount( float value )
{
	ChargeAmount = FMax(0.0,value);
	ProjEffects.SetFloatParameter('ChargeAmount',value);
}

DefaultProperties
{
	ProjFlightTemplate=ParticleSystem'PT_FX.Particles.P_WP_ShockRifle_Ball'
	MaxHits = 5.0
}
