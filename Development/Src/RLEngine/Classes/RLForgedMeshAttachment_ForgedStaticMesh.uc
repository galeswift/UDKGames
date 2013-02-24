class RLForgedMeshAttachment_ForgedStaticMesh extends RLForgedMeshAttachment;

var() RLForgedStaticMeshData ForgedStaticMesh;

simulated function ActorComponent Create(ActorComponent NewOwner)
{
	local RLForgedStaticMeshComponent MeshComp;

	MeshComp = RLForgedStaticMeshComponent(super.Create(NewOwner));
	if( MeshComp != none )
	{
		MeshComp.ForgedMeshData = ForgedStaticMesh;
		MeshComp.DoSetup();
		MeshComp.SetHidden(!bActiveOnStartup);
	}

	return MeshComp;
}

DefaultProperties
{
	ComponentClass=class'RLForgedStaticMeshComponent'
}
