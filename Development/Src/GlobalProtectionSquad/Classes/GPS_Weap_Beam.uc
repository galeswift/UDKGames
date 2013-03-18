class GPS_Weap_Beam extends GPS_Weap_Base
	abstract;

/** This impact is played when we hit the actor */
var ParticleSystem ImpactEffect;

/** Color of the beam emitter */
var Color BeamColor;

/**
 * Process the hit info
 */
simulated function ProcessBeamHit(vector StartTrace, vector AimDir, out ImpactInfo TestImpact, float DeltaTime)
{
	Super.ProcessBeamHit(StartTrace, AimDir, TestImpact, DeltaTime);

	if( TestImpact.HitActor != none )
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffect, TestImpact.HitLocation,,TestImpact.HitActor);
	}
}

simulated function UpdateBeamEmitter(vector FlashLocation, vector HitNormal, actor HitActor)
{
	Super.UpdateBeamEmitter(FlashLocation, HitNormal, HitActor);

	BeamEmitter[CurrentFireMode].SetColorParameter('BeamColor', BeamColor);
}

simulated function UpdateBeam(float DeltaTime)
{
	local Vector		StartTrace, EndTrace, AimDir;
	local array<ImpactInfo> ImpactList;
	local int i;

	// define range to use for CalcWeaponFire()
	StartTrace	= Instigator.GetWeaponStartTraceLocation();
	AimDir = Vector(GetAdjustedAim( StartTrace ));
	EndTrace	= StartTrace + AimDir * GetTraceRange();

	// Trace a shot
	CalcWeaponFire( StartTrace, EndTrace, ImpactList );

	for( i=0 ; i<ImpactList.Length ; i++ )
	{
		// Allow children to process the hit
		ProcessBeamHit(StartTrace, AimDir, ImpactList[i], DeltaTime);
		UpdateBeamEmitter(ImpactList[i].HitLocation, ImpactList[i].HitNormal, ImpactList[i].HitActor);
	}
}


DefaultProperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	FiringStatesArray(0)=WeaponBeamFiring
	BeamSockets[0]=MuzzleFlashSocket02
	BeamTemplate[0]=ParticleSystem'GPS_FX.Effects.P_WP_BeamGun'
	BeamPreFireAnim(0)=WeaponAltFireStart
	BeamFireAnim(0)=WeaponAltFire
	BeamPostFireAnim(0)=WeaponAltFireEnd

	// Damage is calculated off of firing mode 1
	InstantHitDamage(1)=300
	InstantHitDamageTypes(0)=class'UTDmgType_LinkBeam'
	MuzzleFlashPSCTemplate=ParticleSystem'GPS_FX.Effects.P_WP_BeamGun'
	MuzzleFlashAltPSCTemplate=ParticleSystem'GPS_FX.Effects.P_WP_BeamGun'
	AttachmentClass=class'GPS_Attachment_BeamGun'

	ImpactEffect=ParticleSystem'GPS_FX.Effects.PS_Beam_Impact'
	WeaponRange=2000

	BeamColor=(R=255, G=100, B=100)
}
