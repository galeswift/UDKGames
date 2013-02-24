class RLForgedSkelMeshComponent extends SkeletalMeshComponent;

var() RLForgedSkelMeshData ForgedMeshData;

// maps 1:1 to RLForgedMeshData::Attachments
var() array<ActorComponent> CreatedAttachments;

simulated function DoSetup()
{
	local int i;
	local ActorComponent Comp;

	// assign forged mesh stuff
	SetSkeletalMesh(ForgedMeshData.SkeletalMesh);
	SetPhysicsAsset(ForgedMeshData.PhysicsAsset);
	SetAnimTreeTemplate(ForgedMeshData.AnimTree);
	AnimSets.Length = 0;
	AnimSets = ForgedMeshData.AnimSets;

	// create components
	for(i=0; i<ForgedMeshData.Attachments.Length; i++)
	{
		Comp = ForgedMeshData.Attachments[i].Attachment.Create(self);
		CreatedAttachments[i] = Comp;
		AttachComponentToSocket(Comp, ForgedMeshData.Attachments[i].SocketName);
	}

	// reinit
	UpdateAnimations();
}

simulated function HandleMessage(name Message)
{
	ForgedMeshData.HandleMessage(Message, self, CreatedAttachments);
}

DefaultProperties
{
}
