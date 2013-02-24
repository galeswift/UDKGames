class RLForgedSkeletalMeshActor extends SkeletalMeshActor;

var() RLForgedSkelMeshData ForgedMeshData;

var RLForgedSkelMeshComponent ForgedMeshComp;

simulated function PostBeginPlay()
{
	ForgedMeshComp.ForgedMeshData = ForgedMeshData;
	ForgedMeshComp.DoSetup();

	super.PostBeginPlay();
}

simulated function HandleMessage(name Message)
{
	ForgedMeshComp.HandleMessage(Message);
}

DefaultProperties
{
	Begin Object Class=RLForgedSkelMeshComponent Name=ForgedSkelMesh
	End Object

	CollisionComponent=ForgedSkelMesh
	SkeletalMeshComponent=ForgedSkelMesh
	ForgedMeshComp=ForgedSkelMesh
	Components.Add(ForgedSkelMesh)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.BadPylon'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)
}
