class GAProjectile extends UTProjectile;

var float BounceAmount;
var float ExplosionTimer;
var float SpinRate;

var() const editconst StaticMeshComponent	StaticMeshComponent;
var()	SkeletalMeshComponent			SkeletalMeshComponent;
var() const editconst DynamicLightEnvironmentComponent LightEnvironment;

/** Used to replicate mesh to clients */
var repnotify transient StaticMesh ReplicatedMesh;
/** Used to replicate mesh to clients */
var repnotify transient SkeletalMesh ReplicatedSkelMesh;

replication
{
	if (Role == ROLE_Authority)
		ReplicatedMesh, ReplicatedSkelMesh;
}


simulated event ReplicatedEvent( name VarName )
{
	if (VarName == 'ReplicatedSkelMesh')
	{
		SkeletalMeshComponent.SetSkeletalMesh(ReplicatedSkelMesh);
	}
    else if (VarName == 'ReplicatedMesh')
	{
		StaticMeshComponent.SetStaticMesh(ReplicatedMesh);
	}

}

function OnSetDrawScale( SeqAction_SetDrawScale Action )
{
}


function OnSetMesh(SeqAct_SetMesh Action)
{
	local bool bForce;
	if( Action.MeshType == MeshType_StaticMesh )
	{
		bForce = Action.bIsAllowedToMove == StaticMeshComponent.bForceStaticDecals || Action.bAllowDecalsToReattach;

		if( (Action.NewStaticMesh != None) &&
			(Action.NewStaticMesh != StaticMeshComponent.StaticMesh || bForce) )
		{
			// Enable the light environment if it is not already
			LightEnvironment.bCastShadows = false;
			LightEnvironment.SetEnabled(TRUE);
			// Don't allow decals to reattach since we are changing the static mesh
			StaticMeshComponent.bAllowDecalAutomaticReAttach = Action.bAllowDecalsToReattach;
			StaticMeshComponent.SetStaticMesh( Action.NewStaticMesh, Action.bAllowDecalsToReattach );
			StaticMeshComponent.bAllowDecalAutomaticReAttach = true;
			StaticMeshComponent.SetActorCollision(false, false, false );
			ReplicatedMesh = Action.NewStaticMesh;
			ForceNetRelevant();
		}
	}
	else if (Action.MeshType == MeshType_SkeletalMesh)
	{
		if (Action.NewSkeletalMesh != None && Action.NewSkeletalMesh != SkeletalMeshComponent.SkeletalMesh)
		{
			SkeletalMeshComponent.SetSkeletalMesh(Action.NewSkeletalMesh);
			ReplicatedSkelMesh = Action.NewSkeletalMesh;
		}
	}
}

DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
	End Object
	CollisionComponent=StaticMeshComponent0
	StaticMeshComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)
	
	Begin Object Class=AnimNodeSequence Name=AnimNodeSeq0
	End Object

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		Animations=AnimNodeSeq0
		bUpdateSkelWhenNotRendered=FALSE
		CollideActors=TRUE //@warning: leave at TRUE until backwards compatibility code is removed (bCollideActors_OldValue, etc)
		BlockActors=FALSE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
		LightEnvironment=MyLightEnvironment
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
	End Object
	SkeletalMeshComponent=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)

}
