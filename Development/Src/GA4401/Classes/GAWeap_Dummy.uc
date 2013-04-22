class GAWeap_Dummy extends UTWeapon;

var bool bFiredEvent;
simulated function BeginFire(Byte FireModeNum)
{
	DoDummyBehavior();
	Super.BeginFire(FireModeNum);
}
/**
 * Detach weapon components from instigator. Perform any clean up.
 * Should be subclassed.
 */
simulated function DetachWeapon()
{
	DoDummyBehavior();
	Super.DetachWeapon();
}

reliable server function DoDummyBehavior()
{
	if( Role == ROLE_Authority )
	{
		if( !bFiredEvent)
		{
			bFiredEvent = true;
			TriggerGlobalEventClass(class'SeqEvent_FiredDummyWeapon', Instigator);
			Destroy();
			SwitchToDifferent();
		}
	}
}
simulated reliable client function SwitchToDifferent()
{
	InvManager.PrevWeapon();
}

/**
 * This Inventory Item has just been given to this Pawn
 * (server only)
 *
 * @param	thisPawn			new Inventory owner
 * @param	bDoNotActivate		If true, this item will not try to activate
 */
function GivenTo( Pawn thisPawn, optional bool bDoNotActivate )
{
	Super.GivenTo(thisPawn, false);
	InvManager.ClientWeaponSet(self, false, false);
}


/**
 * Consumes some of the ammo
 */
function ConsumeAmmo( byte FireModeNum )
{

}


/**
 * Returns a weight reflecting the desire to use the
 * given weapon, used for AI and player best weapon
 * selection.
 *
 * @return	weapon rating (range -1.f to 1.f)
 */
simulated function float GetWeaponRating()
{
	return 1000.0f;
}


DefaultProperties
{
	WeaponColor=(R=255,G=255,B=128,A=255)
	FireInterval(0)=+1.0
	FireInterval(1)=+1.0
	PlayerViewOffset=(X=0.0,Y=7.0,Z=-9.0)

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit

	FireOffset=(X=16,Y=10)

	AIRating=+0.75
	CurrentRating=+0.75
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0
	bCanThrow=false

	InventoryGroup=999
	GroupWeight=1

	AmmoCount=1
	LockerAmmoCount=99
	MaxAmmoCount=1

	bExportMenuData=false

	bFiredEvent = false
	SupportedEvents.Add(class'SeqEvent_FiredDummyWeapon')
}
