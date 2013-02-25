class PT_Pickup extends Trigger_Dynamic;

/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

var ParticleSystem PickupEffect;
var SoundCue PickupSound;

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);

	if( PT_Pawn(Other) != none && 
		PT_Pawn(Other).Controller != none &&
		PT_PC( PT_Pawn(Other).Controller) != none )
	{
		PT_PC( PT_Pawn(Other).Controller).NotifyPickedUp(self);
		PlaySound(PickupSound);
		WorldInfo.MyEmitterPool.SpawnEmitter(PickupEffect,Location);
		Destroy();
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

	Begin Object Class=StaticMeshComponent Name=Mesh
		StaticMesh=StaticMesh'EditorMeshes.TexPropSphere'
		CastShadow=true
		bForceDirectLightMap=true
		bCastDynamicShadow=true
		LightEnvironment=MyLightEnvironment
	End object
	Components.Add(Mesh)

	DrawScale=0.1

	RotationRate=(Pitch=5000, Roll=5000)

	bStatic=false
	bHidden=false
	bNoDelete=false

	PickupSound = SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Small_Cue_Modulated'
	PickupEffect = ParticleSystem'PT_FX.Particles.P_Pickup_Pickup'
}
