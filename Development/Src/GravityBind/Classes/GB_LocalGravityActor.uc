class GB_LocalGravityActor extends Actor;

// The component we will be pushing
var PrimitiveComponent GravityComponent;

// Every frame, we will push the actor towards this direction
var vector GravityDir;

// Can be overriden to provide faster/slower gravity, represents acceleration
var float GravityMag;

// True, we are pushing
var bool bActive;

// True,we should highlight
var bool bSelected;

// Applied to our mesh we choosing
var MaterialInterface GlowMaterial;

// Our glow mesh
var StaticMeshComponent GlowComponent;

event Destroyed()
{
	super.Destroyed();
	GravityComponent.Owner.DetachComponent(GlowComponent);
}

function SetGravityComponent(PrimitiveComponent InComponent )
{
	GravityComponent = InComponent;
	
	if( GravityComponent != none )
	{
		// Create an overlay mesh
		if( StaticMeshComponent(InComponent) != none )
		{
			if( GlowComponent == none )
			{
				// Actually create the StaticMeshComponent
				GlowComponent = new(self) class'StaticMeshComponent';
			}

			GlowComponent.SetStaticMesh( StaticMeshComponent(InComponent).StaticMesh);
			GlowComponent.SetActorCollision(FALSE, FALSE);
			GlowComponent.SetScale(1.1);
			GlowComponent.SetLightEnvironment(InComponent.LightEnvironment);
			GlowComponent.SetMaterial(0,GlowMaterial);
			GravityComponent.Owner.AttachComponent(GlowComponent);
		}
	}
}

function SetLocalGravityVec(vector InDir)
{
	GravityDir = normal(InDir);
}

simulated function bool IsSelected()
{
	return bSelected;
}

simulated function Select(bool bValue)
{
	bSelected = bValue;
	GlowComponent.SetHidden(!bValue);
}

simulated function SetActive(bool bValue)
{
	bActive = bValue;
}

// Every frame, modify our component
simulated function Tick(float DeltaTime)
{
	local vector CurrentVel;

	Super.Tick( DeltaTime );

	if( GravityComponent != none && bActive )
	{
		CurrentVel = GravityComponent.Owner.Velocity;	
		CurrentVel += GravityDir * GravityMag;

		GravityComponent.SetRBLinearVelocity(CurrentVel, false);
	}
}

DefaultProperties
{
	GravityMag = 50
	bActive = false
	bSelected = false
	GlowMaterial = Material'GravityBindMeshes.M_Bound_Overlay'
}
