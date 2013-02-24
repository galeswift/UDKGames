class RLForgedStaticMeshComponent extends StaticMeshComponent;

var() RLForgedStaticMeshData ForgedMeshData;

// maps 1:1 to RLForgedMeshData::Attachments
var() array<ActorComponent> CreatedAttachments;

simulated function DoSetup()
{
	local int i;
	local ActorComponent Comp;

	// assign forged mesh stuff
	SetStaticMesh(ForgedMeshData.StaticMesh);

	// create components
	for(i=0; i<ForgedMeshData.Attachments.Length; i++)
	{
		Comp = ForgedMeshData.Attachments[i].Attachment.Create(self);
		CreatedAttachments[i] = Comp;
		AttachComponentToSocket(Comp, ForgedMeshData.Attachments[i].SocketName);
	}
}

simulated function AttachComponentToSocket(ActorComponent Comp, name SocketName)
{
	local int i;
	local PrimitiveComponent PrimComp;

	// todo: need to find a way to offset actor components
	PrimComp = PrimitiveComponent(Comp);
	if( PrimComp != none )
	{
		for(i=0; i<ForgedMeshData.Sockets.Length; i++)
		{
			if( ForgedMeshData.Sockets[i].SocketName == SocketName )
			{
				PrimComp.SetTranslation(ForgedMeshData.Sockets[i].SocketTranslation);
				PrimComp.SetRotation(ForgedMeshData.Sockets[i].SocketRotation);
				PrimComp.SetScale3D(ForgedMeshData.Sockets[i].SocketScale);
				break;
			}
		}
	}
}

simulated function HandleMessage(name Message)
{
	ForgedMeshData.HandleMessage(Message, self, CreatedAttachments);
}

DefaultProperties
{
}
