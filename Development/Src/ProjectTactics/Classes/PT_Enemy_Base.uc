class PT_Enemy_Base extends UTProjectile;

/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	//local PT_Exp_Emitter ExpEmitter;
	local PT_Pickup_Exp ExpPickup;

	ExpPickup = Spawn(class'PT_Pickup_Exp',self,,Location);
	ExpPickup.SetCollisionType(COLLIDE_TouchAll);


	//ExpEmitter = Spawn(class'PT_Exp_Emitter',EventInstigator.Pawn,,Location);
	//ExpEmitter.ParticleSystemComponent.SetTemplate(ParticleSystem'PT_FX.P_Exp_Trail');
	//ExpEmitter.SetTarget(EventInstigator.Pawn);

	Explode(HitLocation, vect(0,0,0));
	NotifyKilled(DamageType);	
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

	Begin Object Class=StaticMeshComponent Name=ProjectileMesh
		StaticMesh=StaticMesh'EditorMeshes.TexPropCube'
		CastShadow=true
		bForceDirectLightMap=true
		bCastDynamicShadow=true
		CollideActors=true
		BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
	End object
	Components.Add(ProjectileMesh)

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
	RotationRate=(Pitch=10000, Roll=10000)
	bCollideWorld=false
	CheckRadius=42.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTRocketLight'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'
	bWaitForEffects=true
	bAttachExplosionToVehicles=false
	DrawScale=0.2
	bProjTarget=True
}
