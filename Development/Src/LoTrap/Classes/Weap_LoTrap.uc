//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Weap_LoTrap extends UTWeapon;

/* List of teleporters that we have currently in existence */
var LoTrap_Teleporter m_Teleporters[2];

/* The pretty particle system for this weapon */
var UTParticleSystemComponent m_ParticleSwirly;
var UTParticleSystemComponent m_ParticleLeftBlue;
var UTParticleSystemComponent m_ParticleRightOrange;

/* Keeps track of the current projectile, to make sure we only have one in the air at a time */
var LoTrap_Proj m_MyProjectile;

simulated state Active
{
	simulated function BeginState( name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );

		// Attach the system to the 1st person mesh.
		if( SkeletalMeshComponent( Mesh ) != none )
		{
			SkeletalMeshComponent( Mesh ).AttachComponentToSocket( m_ParticleSwirly, 'FX_Socket' );
			SkeletalMeshComponent( Mesh ).AttachComponentToSocket( m_ParticleLeftBlue, 'Left' );
			SkeletalMeshComponent( Mesh ).AttachComponentToSocket( m_ParticleRightOrange, 'Right' );

			m_ParticleLeftBlue.SetDepthPriorityGroup(SDPG_Foreground);
			m_ParticleLeftBlue.SetFOV(UTSkeletalMeshComponent(Mesh).FOV);

			m_ParticleRightOrange.SetDepthPriorityGroup(SDPG_Foreground);
			m_ParticleRightOrange.SetFOV(UTSkeletalMeshComponent(Mesh).FOV);

			// Activate it.
			m_ParticleLeftBlue.ActivateSystem();
			m_ParticleRightOrange.ActivateSystem();
			m_ParticleSwirly.ActivateSystem();
		}
	}
}

simulated function Projectile ProjectileFire()
{
	// Already have one in the air, destroy it.
	if( m_MyProjectile != none )
	{
		m_MyProjectile.Destroy();
	}

	m_MyProjectile = LoTrap_Proj(Super.ProjectileFire());

	if (m_MyProjectile != None )
	{
		m_MyProjectile.m_MyWeapon = self;
	}

	return m_MyProjectile;
}

function bool HitValidPortalWall( vector HitLocation, vector HitNormal )
{
	// make sure that the four corners from the hit location will be big enough to support our mesh.

	return true;
}

/**
 * When destroyed, make sure we clean up any portals that are still around
 */
simulated event Destroyed()
{
	super.Destroyed();

	CleanUpPortals();
}

/**
 * A notification call when this weapon is removed from the Inventory of a pawn
 * @see Inventory::ItemRemovedFromInvManager
 */

function ItemRemovedFromInvManager()
{
	Super.ItemRemovedFromInvManager( );
	CleanUpPortals();
}

// Cleans up any existing portals
simulated function CleanUpPortals()
{
	if( m_Teleporters[0] != none )
	{
		m_Teleporters[0].BeginClose();
	}

	if( m_Teleporters[1] != none )
	{
		m_Teleporters[1].BeginClose();
	}

	// Even if the teleporters are destroyed, they aren't garbage collected unless we clean up references to them as well
	m_Teleporters[0] = none;
	m_Teleporters[1] = none;
}

simulated function ProcessPortalHit( byte FiringMode, vector HitLocation, vector HitNormal )
{
	local byte OtherMode;

	// Server side code only
	if( Role != ROLE_Authority )
	{
		return;
	}

	// We are allowed to fire again now.
	m_MyProjectile = none;

	// Only continue if we hit a wall that is big enough for our portal
	if( HitValidPortalWall( HitLocation, HitNormal ) )
	{

		OtherMode = (FiringMode == 1 ) ? 0 : 1;

		if( m_Teleporters[FiringMode] == none )
		{
			if( FiringMode == 0 )
			{
				m_Teleporters[FiringMode] =	Spawn( class'LoTrap_Teleporter_Blue',,,HitLocation, rotator(HitNormal),,true );
			}
			else
			{
				m_Teleporters[FiringMode] =	Spawn( class'LoTrap_Teleporter_Red',,,HitLocation, rotator(HitNormal),,true );
			}
		}
		else
		{
			m_Teleporters[FiringMode].SetLocation( HitLocation);
			m_Teleporters[FiringMode].SetRotation(  rotator(HitNormal)  );
		}

		// Begins the scaling of the portal
		m_Teleporters[FiringMode].BeginOpen();

		// Update both the portals
		m_Teleporters[FiringMode].SetTargetTeleporter( m_Teleporters[OtherMode] );

		if( m_Teleporters[OtherMode] != none )
		{
			m_Teleporters[OtherMode].SetTargetTeleporter( m_Teleporters[FiringMode] );
		}

		m_Teleporters[FiringMode].UpdateRenderTarget();

		if( m_Teleporters[OtherMode] != none )
		{
			m_Teleporters[OtherMode].UpdateRenderTarget();
		}
	}
}
simulated function String GetHumanReadableName()
{
	return "LoTrap Gun";
}
DefaultProperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile
	WeaponProjectiles(0)=class'LoTrap_Proj_Primary'
	WeaponProjectiles(1)=class'LoTrap_Proj_Alt'
	InventoryGroup=1
	GroupWeight=0.7

	AttachmentClass=class'LoTrap.Attachment_LoTrap'

	ShotCost(0)=0
	ShotCost(1)=0

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_LoTrap.Meshes.SK_WP_LoTrap_MID'
	End Object

	MuzzleFlashSocket=MuzzleFlash
	MuzzleFlashPSCTemplate=ParticleSystem'WP_ShockRifle.Particles.P_ShockRifle_MF_Alt'

	WeaponEquipSnd=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_LowerCue'
	WeaponFireSnd(0)=SoundCue'A_Weapon_FlakCannon.Weapons.A_FlakCannon_FireAltCue'
	WeaponFireSnd(1)=SoundCue'A_Weapon_FlakCannon.Weapons.A_FlakCannon_FireAltCue'

	Begin Object Class=UTParticleSystemComponent Name=Particle_Swirly
		Template=ParticleSystem'WP_LoTrap.FX.FX_LoTrapSwirly'
		SecondsBeforeInactive=0.0f
	End Object
	m_ParticleSwirly = Particle_Swirly

	Begin Object Class=UTParticleSystemComponent Name=Particle_LeftBlue
		Template=ParticleSystem'WP_LoTrap.FX.FX_LeftBlue'
		SecondsBeforeInactive=0.0f
	End Object
	m_ParticleLeftBlue = Particle_LeftBlue

	Begin Object Class=UTParticleSystemComponent Name=Particle_RightOrange
		Template=ParticleSystem'WP_LoTrap.FX.FX_RightOrange'
		SecondsBeforeInactive=0.0f
	End Object
	m_ParticleRightOrange = Particle_RightOrange

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_LoTrap.Meshes.SK_WP_LoTrap'
		AnimSets(0)=AnimSet'WP_Translocator.Anims.K_WP_Translocator_1P_Base'
		Animations=MeshSequenceA
		Translation=(X=-6,Z=-4)
		Rotation=(Pitch=0,Yaw=0,Roll=0)
		FOV=60.0
	End Object

	//Animations
	WeaponFireAnim(0)=WeaponFire
	WeaponFireAnim(1)=WeaponFire
	ArmFireAnim(0)=WeaponFire
	ArmFireAnim(1)=WeaponFire
	ArmsEquipAnim=WeaponEquip

	ArmsAnimSet=AnimSet'WP_FlakCannon.Anims.K_WP_FlakCannon_1P_Arms'
}