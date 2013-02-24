class RLForgedStaticMeshActor extends InterpActor;

var() RLForgedStaticMeshData ForgedMeshData;

var RLForgedStaticMeshComponent ForgedMeshComp;

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
	Begin Object Class=RLForgedStaticMeshComponent Name=ForgedStaticMesh
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
	End Object

	CollisionComponent=ForgedStaticMesh
	StaticMeshComponent=ForgedStaticMesh
	ForgedMeshComp=ForgedStaticMesh
	Components.Add(ForgedStaticMesh)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.BadPylon'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)
}