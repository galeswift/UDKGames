class PT_Enemy_Base extends UTProjectile;

/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

var() StaticMeshComponent Mesh_Static;
var() SkeletalMeshComponent Mesh_Skeletal;
var() Rotator InitialRotationRate;
var() float InitialSpeed;
var() vector InitialAcceleration;

var bool EnteredPlaySpace;
var vector InitialSpawnLocation;

event Init(vector Direction)
{
	Speed = InitialSpeed;
	MaxSpeed = InitialSpeed;
	Acceleration = InitialAcceleration;
	Super.Init(Direction);
	RotationRate=InitialRotationRate;
	SetCollision(false, false);
	InitialSpawnLocation=Location;
}

event Tick( float DeltaTime )
{
	local vector HitLocation, HitNormal;
	local Actor HitActor;
	Super.Tick( DeltaTime );

	if( !EnteredPlaySpace )
	{
		// Trace from spawn to enemy
		HitActor = Trace( HitLocation, HitNormal, Location, InitialSpawnLocation, true );
		
		if( HitActor != none && 
			HitActor.IsA('BlockingVolume') &&
			HitNormal dot normal(Velocity) < 0 )
		{
			HitActor = Trace( HitLocation, HitNormal, Location + normal(InitialSpawnLocation - Location) * CylinderComponent.CollisionRadius * 1.1, Location, true );
			
			// Inside playspace
			if( HitActor == none )
			{
				EnteredPlaySpace = true;
				SetCollision(true, true);
			}
		}
	}
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	//local PT_Exp_Emitter ExpEmitter;
	local PT_Pickup_Exp ExpPickup;

	if( EnteredPlaySpace )
	{
		ExpPickup = Spawn(class'PT_Pickup_Exp',self,,Location);
		ExpPickup.SetCollisionType(COLLIDE_TouchAll);


		//ExpEmitter = Spawn(class'PT_Exp_Emitter',EventInstigator.Pawn,,Location);
		//ExpEmitter.ParticleSystemComponent.SetTemplate(ParticleSystem'PT_FX.P_Exp_Trail');
		//ExpEmitter.SetTarget(EventInstigator.Pawn);

		Explode(HitLocation, vect(0,0,0));
		NotifyKilled(DamageType);	
	}
}

function NotifyKilled(class<DamageType> DamageType)
{
	local PT_PC C;

	foreach WorldInfo.AllControllers(class'PT_PC', C)
	{
		C.NotifyKilledEnemy(self, DamageType);
	}
}

DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Name=CollisionCylinder
		CollisionRadius=32
		CollisionHeight=32
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object

	ProjExplosionTemplate=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_GeneralExplosion'
	ExplosionDecal=MaterialInstanceTimeVarying'WP_RocketLauncher.Decals.MITV_WP_RocketLauncher_Impact_Decal01'
	DecalWidth=128.0
	DecalHeight=128.0
	speed=250.0
	MaxSpeed=250.0
	Damage=100.0
	MomentumTransfer=85000
	MyDamageType=class'UTDmgType_Rocket'
	LifeSpan=0.0
	AmbientSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Travel_Cue'
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	bCollideWorld=false
	CheckRadius=42.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTRocketLight'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'
	bWaitForEffects=true
	bAttachExplosionToVehicles=false
	DrawScale=0.2
	bProjTarget=True

	Begin Object Class=StaticMeshComponent Name=ProjectileMesh
		//StaticMesh=StaticMesh'EditorMeshes.TexPropCube'
		CastShadow=true
		bForceDirectLightMap=true
		bCastDynamicShadow=true
		CollideActors=true
		BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
	End object
	Components.Add(ProjectileMesh)
	Mesh_Static=ProjectileMesh

	Begin Object Class=SkeletalMeshComponent Name=ProjectileMeshSK
		//SkeletalMesh=SkeletalMesh'VH_GiantSaucer.SkeletalMeshes.SK_BattleSaucer'
		CastShadow=true
		bForceDirectLightMap=true
		bCastDynamicShadow=true
		CollideActors=true
		BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
	End object
	Components.Add(ProjectileMeshSK)
	Mesh_Skeletal=ProjectileMeshSK
	InitialSpeed=250
}
