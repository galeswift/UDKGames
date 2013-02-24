//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RaceCheckpointVolume extends TriggerVolume;

var() int CheckpointNum;
var repnotify vector NextCheckpointDir;
var transient vector ArrowBaseLocation;
var() StaticMeshComponent NextCheckpointArrow;
var() StaticMeshComponent CheckpointVolumeMesh;
var() float ArrowAnimateAmount;
var() float ArrowAnimateRate;
var transient private vector Center;

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'NextCheckpointDir')
	{
		SetNextCheckpointDir(NextCheckpointDir);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function PostBeginPlay()
{
	local box ActorBox;
	local vector Size, Translation;

	super.PostBeginPlay();

	// scale our volumemesh (16x16x16 cube with pivot bottom center)
	GetComponentsBoundingBox(ActorBox);
	Size = (ActorBox.Max - ActorBox.Min) / 16.0f;
	Translation = GetCenter();
	Translation.Z = ActorBox.Min.Z;

	//`log(self@"setting size to"@Size,true,'Race');
	CheckpointVolumeMesh.SetAbsolute(true,,true);
	CheckpointVolumeMesh.SetScale3D(Size);
	CheckpointVolumeMesh.SetTranslation(Translation);
}

simulated function vector GetCenter()
{
	local box ActorBox;
	if( Center == vect(0,0,0) )
	{
		GetComponentsBoundingBox(ActorBox);
		// save our center point
		Center = ActorBox.Min + (ActorBox.Max-ActorBox.Min) * 0.5f;
	}

	return Center;
}

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	super.Touch(Other,OtherComp,HItLocation,HitNormal);

	// let the game info know
	if( Role == ROLE_Authority )
	{
		Race_GameInfo(WorldInfo.Game).CheckpointTouched(CheckpointNum,Other);
	}
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	// animate in the direction of the next checkpoint
	if( ArrowBaseLocation != vect(0,0,0) )
	{
		NextCheckpointArrow.SetTranslation(ArrowBaseLocation + sin(WorldInfo.TimeSeconds*ArrowAnimateRate) * NextCheckpointDir * ArrowAnimateAmount);
	}
}

simulated function SetNextCheckpointDir(vector Direction)
{
	local box ActorBox;
	local vector HalfBox;

	GetComponentsBoundingBox(ActorBox);
	HalfBox = (ActorBox.Max-ActorBox.Min)*0.5f;
	// arrow should be centered 3/4 of the way up the volume
	ArrowBaseLocation = ActorBox.Min + HalfBox + HalfBox*vect(0,0,0.5f);

	NextCheckpointDir = Normal(Direction);
	NextCheckpointArrow.SetAbsolute(true,true,);
	NextCheckpointArrow.SetTranslation(ArrowBaseLocation);
	NextCheckpointArrow.SetRotation(rotator(Direction));

	//DrawDebugSphere(Location,10,8,255,0,0,true);
	//DrawDebugLine(Location,Location+NextCheckpointDir*30,255,0,0,true);
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=NextCheckpoint
		//StaticMesh=StaticMesh'Envy_Effects.mesh.S_MuzzleFlash'
		StaticMesh=StaticMesh'GP_RaceStuff.Meshes.S_RaceArrow'
		HiddenEditor=false
		HiddenGame=false
	End Object
	NextCheckpointArrow=NextCheckpoint
	Components.Add(NextCheckpoint)

	ArrowAnimateAmount=20
	ArrowAnimateRate=4

	Begin Object class=StaticMeshComponent Name=CheckpointVolume
		//StaticMesh=StaticMesh'Envy_Effects.mesh.S_MuzzleFlash'
		StaticMesh=StaticMesh'GP_RaceStuff.Meshes.S_RaceVolume'
		HiddenEditor=false
		HiddenGame=false
	End Object
	CheckpointVolumeMesh=CheckpointVolume
	Components.Add(CheckpointVolume)

	bHidden=false
	bStatic=false
 	bSkipActorPropertyReplication=false

	bAlwaysRelevant=true
 	RemoteRole=ROLE_SimulatedProxy
 	NetUpdateFrequency=1
}