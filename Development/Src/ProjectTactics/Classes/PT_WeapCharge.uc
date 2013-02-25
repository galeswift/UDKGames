class PT_WeapCharge extends UTWeapon;

var float ChargeAmount;
var float TimeToMaxCharge;
var ParticleSystemComponent ChargePSC;
var AudioComponent ChargeAudio;

/**
 * Fires a projectile.
 * Spawns the projectile, but also increment the flash count for remote client effects.
 * Network: Local Player and Server
 */

simulated function Projectile ProjectileFire()
{
	local Projectile proj;

	proj = Super.ProjectileFire();
	PT_ProjChargeBall(proj).SetChargeAmount( ChargeAmount);

	return proj;
}

simulated state WeaponCharge
{
	/**
	 * We override BeginFire() so that we can check for zooming and/or empty weapons
	 */

	simulated function BeginFire( Byte FireModeNum )
	{
	}

	simulated function RefireCheckTimer()
	{
		// if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			`LogInv("Weapon put down requested during fire, put it down now");
			PutDownWeapon();
			return;
		}
	}

	simulated event BeginState( Name PreviousStateName )
	{
		`LogInv("PreviousStateName:" @ PreviousStateName);
		ChargeAmount = 0.0f;
	
		if( ChargePSC == none )
		{
			ChargePSC = new(Outer) class'ParticleSystemComponent';
			ChargePSC.SetTemplate(ParticleSystem'PT_FX.Particles.P_WP_ShockRifle_Ball');
			ChargePSC.SetHidden(true);
			ChargePSC.SetTickGroup( TG_PostUpdateWork );
			ChargePSC.bUpdateComponentInTick = true;
			ChargePSC.SetIgnoreOwnerHidden(TRUE);
			Instigator.Mesh.AttachComponentToSocket( ChargePSC,'MussleFlashSocket' );
		}

		if( ChargeAudio == none )
		{
			ChargeAudio = new(self) class'AudioComponent';
			//AttachComponent(ImpactSoundComponent);
			
		}

		if( ChargePSC != none )
		{
			ChargePSC.ActivateSystem();
		}

		if( ChargeAudio != none )
		{
			ChargeAudio.SoundCue = SoundCue'PT_FX.Audio.Charge01_Cue';
			ChargeAudio.Play();
		}
	}
	
	simulated event Tick(float DeltaTime)
	{
		//`log("Charge amount is"@ChargeAmount);
		if( ChargeAmount < 1.0f && ChargeAmount + DeltaTime/TimeToMaxCharge >= 1.0)
		{
			ChargeAudio.SoundCue = SoundCue'PT_FX.Audio.ChargeLoop_Cue';
			ChargeAudio.Play();
		}

		ChargeAmount += DeltaTime/TimeToMaxCharge;
		ChargeAmount = FMin(1.0f, ChargeAmount);
		ChargePSC.SetHidden(false);
		ChargePSC.SetFloatParameter('ChargeAmount',ChargeAmount);

		// If weapon should keep on firing, then do not leave state and fire again.
		if( !StillFiring(CurrentFireMode) )
		{
			ChargePSC.SetHidden(true);
			ChargePSC.DeactivateSystem();
			ChargeAudio.Stop();
		
			FireAmmunition();
			HandleFinishedFiring(); 
		}
	}
}
/**
 * This function aligns the gun model in the world
 */
simulated event SetPosition(UDKPawn Holder)
{
	SetLocation(Instigator.GetPawnViewLocation());
}

DefaultProperties
{
	FiringStatesArray(0)=WeaponCharge

	FireInterval(0)=+1.0
	FireInterval(1)=+1.05
	
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile

	WeaponProjectiles(0)=class'PT_ProjChargeBall'
	WeaponProjectiles(1)=class'PT_ProjChargeBall'

	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0

	AmmoCount=100
	LockerAmmoCount=100
	MaxAmmoCount=100
	TimeToMaxCharge = 3.0f

	WeaponFireSnd[0]=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Fire_Cue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Fire_Cue'
	WeaponEquipSnd=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Raise_Cue'
}
