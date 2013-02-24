//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LoTrap_Proj extends UTProjectile;

/* Assigned immediately after firing, so that we can tell the weapon when we hit the wall */
var Weap_LoTrap m_MyWeapon;

/* Specified inside the default properties of each projectile */
var byte m_iMyFireMode;

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Super.Explode( HitLocation, HitNormal );

	if( m_MyWeapon != none )
	{
 		m_MyWeapon.ProcessPortalHit( m_iMyFireMode, HitLocation, HitNormal );
	}
}

DefaultProperties
{
	m_iMyFireMode=0
	Damage0
	DamageRadius=0
	speed=6000
}