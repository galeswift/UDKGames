class RLForgedMeshAttachment_StaticMesh extends RLForgedMeshAttachment;

var() StaticMesh StaticMesh;

simulated function ActorComponent Create(ActorComponent NewOwner)
{
	local StaticMeshComponent MeshComp;

	MeshComp = StaticMeshComponent(super.Create(NewOwner));
	if( MeshComp != none )
	{
		MeshComp.SetStaticMesh(StaticMesh);
		MeshComp.SetHidden(!bActiveOnStartup);
	}

	return MeshComp;
}

DefaultProperties
{
	ComponentClass=class'StaticMeshComponent'
}
