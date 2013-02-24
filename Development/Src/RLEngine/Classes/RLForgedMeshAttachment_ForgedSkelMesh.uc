class RLForgedMeshAttachment_ForgedSkelMesh extends RLForgedMeshAttachment;

var() RLForgedSkelMeshData ForgedSkelMesh;

simulated function ActorComponent Create(ActorComponent NewOwner)
{
	local RLForgedSkelMeshComponent MeshComp;

	MeshComp = RLForgedSkelMeshComponent(super.Create(NewOwner));
	if( MeshComp != none )
	{
		MeshComp.ForgedMeshData = ForgedSkelMesh;
		MeshComp.DoSetup();
		MeshComp.SetHidden(!bActiveOnStartup);
	}

	return MeshComp;
}

DefaultProperties
{
	ComponentClass=class'RLForgedSkelMeshComponent'
}
