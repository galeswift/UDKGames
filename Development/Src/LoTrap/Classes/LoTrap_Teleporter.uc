//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LoTrap_Teleporter extends Teleporter;

// The other teleporter
var private LoTrap_Teleporter m_TargetTeleporter;

// Our actor that captures the scene for us
var LoTrap_Portal m_CaptureComponent;

// Resolutions for the portals
var int m_iPortalResolutionX, m_iPortalResolutionY;

// A particle system component for the particle swirly bits
var ParticleSystemComponent m_EntrancePSC;

// materials for the portal effect
var MaterialInterface m_PortalMaterial;
var MaterialInstanceConstant m_PortalMaterialInstance;
var TextureRenderTarget2D m_TextureTarget;
var StaticMeshComponent m_PortalMesh;

// Interfaces into the decal manager
var DecalComponent m_MyDecal;
var int m_iMyDecalIndex;

// Replication variables for clients
var repnotify rotator	m_vTargetTeleporterRotation;
var repnotify vector	m_vTargetTeleporterLocation;

/////////////////////////////////////
// Portal opening animation vars
/////////////////////////////////////

// Whether we are in the process of opening or not
var repnotify bool	m_bOpening;
// The world time when we started opening
var float 	m_fTimeStartedOpening;
// Current scale for the portal
var vector	m_vCurrentScale;
// How long to spend actually opening it
var float	m_fPortalOpenTime;


/////////////////////////////////////
// Portal closing animation vars
/////////////////////////////////////

// Whether we are currently closing or not
var repnotify bool	m_bClosing;

// WOrld time that we started closing
var float 	m_fTimeStartedClosing;

replication
{
	if( bNetDirty && Role == ROLE_Authority )
		m_vTargetTeleporterRotation, m_vTargetTeleporterLocation, m_bOpening, m_bClosing;
}

simulated event ReplicatedEvent( name VarName )
{
	`log(self@GetFuncName()@VarName);
	Super.ReplicatedEvent( VarName );

	if( VarName == 'm_vTargetTeleporterRotation' ||  VarName == 'm_vTargetTeleporterLocation' )
	{
		`log(self$" m_vTargetTeleporterLocation "$m_vTargetTeleporterLocation);
		`log(self$" m_vTargetTeleporterRotation "$m_vTargetTeleporterRotation);

		UpdateRenderTarget();

		if( m_vTargetTeleporterLocation != vect(-1,-1,-1 ) )
		{
			// Manipulate the camera so it's positioned at that other teleporter's location
			m_CaptureComponent.SetView(m_vTargetTeleporterLocation + vector(m_vTargetTeleporterRotation) * 15.0, m_vTargetTeleporterRotation);

			// This needs to get reset every time for clients.
			m_PortalMaterialInstance.SetTextureParameterValue('RenderToTextureChange',m_TextureTarget);

			// This probably only needs to get called once, but in any case, it will assign our material to the portal static mesh
			m_PortalMesh.SetMaterial( 1, m_PortalMaterialInstance );
		}
		else
		{
			// This will only occur if we dont' have a target portal yet.
			m_PortalMaterialInstance.SetTextureParameterValue('RenderToTextureChange', Texture2D'EngineResources.Black' );
			m_PortalMesh.SetMaterial( 1, m_PortalMaterialInstance );
		}
	}
	else if( VarName == 'm_bOpening' )
	{
		if( m_bOpening )
		{
			BeginOpen();
		}
	}
	else if( VarName == 'm_bClosing' )
	{
		if( m_bClosing )
		{
			BeginClose();
		}
	}
}

// Overwritten because teleporters disable collision if there is no URL
simulated event PostBeginPlay()
{
	m_PortalMaterial = m_PortalMesh.GetMaterial(1);
}

simulated function BeginOpen()
{
	m_bOpening = true;
	m_fTimeStartedOpening = WorldInfo.TimeSeconds;
	m_vCurrentScale = vect(1,1,0);

	// Deactive the particle in case it was active before.
	m_EntrancePSC.DeactivateSystem();
	// Kill them immediately so that there aren't any residuals
	m_EntrancePSC.KillParticlesForced();
}

simulated function 	BeginClose()
{
	m_bClosing = true;
	m_fTimeStartedClosing = WorldInfo.TimeSeconds;

	// Deactive the particle in case it was active before.
	m_EntrancePSC.DeactivateSystem();
}


simulated event Tick( float DeltaTime )
{
	if( m_bOpening )
	{
		if( (WorldInfo.TimeSeconds - m_fTimeStartedOpening) >= m_fPortalOpenTime )
		{
			// Stop opening.
			m_bOpening = false;

			// Scale the size of this mesh to be at full size.
			m_PortalMesh.SetScale3D( vect(1,1,1) );

			// Activate our cool particle
			m_EntrancePSC.ActivateSystem();
		}
		else
		{
			// Calculate a new scale
			m_vCurrentScale = VLerp( m_vCurrentScale, vect(1,1,1), (WorldInfo.TimeSeconds -  m_fTimeStartedOpening ) / m_fPortalOpenTime );

			// Scale the size of this mesh
			m_PortalMesh.SetScale3D( m_vCurrentScale );
		}
	}
	else if( m_bClosing )
	{
		if( (WorldInfo.TimeSeconds - m_fTimeStartedClosing ) >= m_fPortalOpenTime )
		{
			// Stop opening.
			m_bClosing = false;

			// Scale the size of this mesh to be scaled down to 0 (Closed)
			m_PortalMesh.SetScale3D( vect(1,1,0) );

			// Destroy the mesh now.
			Destroy();
		}
		else
		{
			// Calculate a new scale
			m_vCurrentScale = VLerp( m_vCurrentScale, vect(1,1,0), (WorldInfo.TimeSeconds -  m_fTimeStartedClosing ) / m_fPortalOpenTime );

			// Scale the size of this mesh
			m_PortalMesh.SetScale3D( m_vCurrentScale );
		}
	}
}

simulated function UpdateRenderTarget()
{
	if (m_CaptureComponent != None && m_TextureTarget == none )
	{
		// Create a new MI the first time this portal is created
		m_PortalMaterialInstance = new(self) class'MaterialInstanceConstant';
		m_PortalMaterialInstance.SetParent(m_PortalMaterial);

		// Create a new TextureRenderTarget2D
		m_TextureTarget = class'TextureRenderTarget2D'.static.Create( 256, 256,, MakeLinearColor(1.0, 1.0, 1.0, 1.0), false );
		m_PortalMaterialInstance.SetTextureParameterValue('RenderToTextureChange',m_TextureTarget);

		// Attach the capture component to this actor
		AttachComponent(m_CaptureComponent);

		// Set up the capture component to pump to the TextureRenderTarget2D that we created
		m_CaptureComponent.SetCaptureParameters(m_TextureTarget);
	}

	if( Role == ROLE_Authority )
	{
		// if we have a valid taret teleporter, then we can set our view to be based from that teleporter.
		if( m_TargetTeleporter != none )
		{
			// Modify our portal material to use that new TextureRenderTarget2D we created
			// Assign this here, so that in case it was black before, we reset it again.
			m_PortalMaterialInstance.SetTextureParameterValue('RenderToTextureChange',m_TextureTarget);

			// Manipulate the camera so it's positioned at that other teleporter's location
			m_CaptureComponent.SetView(m_TargetTeleporter.Location + vector(m_TargetTeleporter.Rotation) * 15.0, m_TargetTeleporter.Rotation);

			// This probably only needs to get called once, but in any case, it will assign our material to the portal static mesh
			m_PortalMesh.SetMaterial( 1, m_PortalMaterialInstance );

			m_vTargetTeleporterRotation = m_TargetTeleporter.Rotation;
			m_vTargetTeleporterLocation = m_TargetTeleporter.Location;
		}
		else
		{
			// If we don't have a portal yet, just make it black.yetpo
			m_PortalMaterialInstance.SetTextureParameterValue('RenderToTextureChange', Texture2D'EngineResources.Black' );
			m_PortalMesh.SetMaterial( 1, m_PortalMaterialInstance );
			m_vTargetTeleporterLocation = vect(-1,-1,-1);
		}
	}
}

function SetTargetTeleporter( LoTrap_Teleporter Target )
{
	m_TargetTeleporter = Target;
}

// Overwritten to prevent a portal shot to travel THROUGH another portal.  This is to prevent any weird glitches that may occur
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if ( !bEnabled || (Other == None) || LoTrap_Proj(Other) != none )
	{
		return;
	}

	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;

}

// Accept an actor that has teleported in.
// Overwritten because rotation is incorrect
simulated event bool Accept( actor Incoming, Actor Source )
{
	local rotator NewRot;
	local vector FacingDirection;
	local vector TeleportTryLocation;
	local float EntranceSpeed;
	local float EntranceAccel;
	local Controller C;

	if ( Incoming == None )
		return false;

	// Only teleport pawns and projectiles.
	if( Pawn(Incoming) == none && Projectile(Incoming) == none )
	{
		return false;
	}

	EntranceSpeed = VSize(Incoming.Velocity);
	EntranceAccel = VSize(Incoming.Acceleration);
	// Move the actor here.
	Disable('Touch');
	NewRot = Incoming.Rotation;

	if ( Pawn(Incoming) != None )
	{
		//tell enemies about teleport
		if ( Role == ROLE_Authority )
		{
			foreach WorldInfo.AllControllers(class'Controller', C)
			{
				if ( C.Enemy == Incoming )
				{
					C.EnemyJustTeleported();
				}
			}
		}

		if ( !Pawn(Incoming).SetLocation(Location) )
		{
			// This may have been placed on the ceiling, if so, try to lower the location.

			FacingDirection = vector(Rotation);

			// Try pushing the player out towards the rotation of the portal.
			TeleportTryLocation = Location + FacingDirection * Pawn(Incoming).GetCollisionHeight();

			if( !Pawn(Incoming).SetLocation( TeleportTryLocation ) )
			{
				TeleportTryLocation = Location + FacingDirection * 2 * Pawn(Incoming).GetCollisionHeight();

				if( !Pawn(Incoming).SetLocation( TeleportTryLocation ) )
				{
					`log(" Cant teleport");
					return false;
				}
			}

		}
		if ( (Role == ROLE_Authority)
			|| (WorldInfo.TimeSeconds - LastFired > 0.5) )
		{
			LastFired = WorldInfo.TimeSeconds;
		}
		if ( Pawn(Incoming).Controller != None )
		{
			Pawn(Incoming).Controller.MoveTimer = -1.0;
			Pawn(Incoming).SetAnchor(self);
			Pawn(Incoming).SetMoveTarget(self);
		}
		Incoming.PlayTeleportEffect(false, true);
	}
	else
	{
		if ( !Incoming.SetLocation(Location) )
		{
			Enable('Touch');
			return false;
		}
	}
	Enable('Touch');

	// Speedy thing goes in, speedy thing goes out
	Incoming.Velocity = EntranceSpeed * vector(Rotation);
	Incoming.Acceleration = EntranceAccel * vector(Rotation);
	Incoming.PostTeleport(self);

	if( Role == Role_Authority && Pawn(Incoming) != none )
	{
		NewRot = Rotation;
		NewRot.Pitch = Incoming.Rotation.Pitch;
		Pawn(Incoming).SetRotation( NewRot );
		Pawn(Incoming).Controller.SetRotation( NewRot );
		Pawn(Incoming).SetViewRotation( NewRot );
		Pawn(Incoming).ClientSetRotation( NewRot );
	}
	else
	{
		Incoming.SetRotation( Rotation );
	}

	return true;
}

//Teleporter was touched by an actor.
simulated event PostTouch( actor Other )
{
	if( m_TargetTeleporter != none )
	{
		m_TargetTeleporter.Accept( Other, self );
	}
}
DefaultProperties
{
	bStatic=false
	bNoDelete=false
	bCollideWorld=false
	bCollideWhenPlacing=false
	bChangesVelocity=true
	m_iPortalResolutionX = 96
	m_iPortalResolutionY = 128

	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00070.000000
		CollisionHeight=+00080.000000
	End Object

	Begin Object class=LoTrap_Portal Name=SceneCapture2DComponent0
		FrameRate=5.0
		bSkipUpdateIfOwnerOccluded=false
		MaxUpdateDist=3000.0
		MaxStreamingUpdateDist=1000.0
		bUpdateMatrices=false
		NearPlane=10
		FarPlane=-1
	End Object
	m_CaptureComponent=SceneCapture2DComponent0

	Begin Object class=StaticMeshComponent Name=TheStaticMeshComponent
		StaticMesh=StaticMesh'WP_LoTrap.Meshes.S_RenderBox'
		CastShadow=false
	End Object
	Components.Add(TheStaticMeshComponent)
	m_PortalMesh=TheStaticMeshComponent

	bUpdateSimulatedPosition = true
	bAlwaysRelevant = true
	NetUpdateFrequency = 100

	m_fPortalOpenTime = 0.75f

	Begin Object class=ParticleSystemComponent name=EntrancePSC
		Template=ParticleSystem'WP_LoTrap.FX.FX_LoTrapENTRANCE'
		bAutoActivate=false
		Rotation=(Pitch=-16383,Yaw=0,Roll=0)
	End Object
	m_EntrancePSC = EntrancePSC
	Components.Add(EntrancePSC)
}