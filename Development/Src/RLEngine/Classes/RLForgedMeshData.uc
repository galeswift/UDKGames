class RLForgedMeshData extends Object;

var() editinline array<RLForgedMeshMessage> Messages;

struct RLForgedMeshAttachedComponent
{
	var() name SocketName;
	var() instanced RLForgedMeshAttachment Attachment;
};

var() editinline array<RLForgedMeshAttachedComponent> Attachments;

simulated function HandleMessage(name Message, ActorComponent MainObject, array<ActorComponent> CreatedAttachments)
{
	local int i, j;

	// see if the main object handles this message
	for(i=0; i<Messages.Length; i++)
	{
		if( Messages[i].Message == Message )
		{
			Messages[i].Action.Perform(MainObject);
		}
	}

	// check its created attachments
	for(j=0; j<CreatedAttachments.Length; j++)
	{
		for(i=0; i<Attachments[j].Attachment.Messages.Length; i++)
		{
			if( Attachments[j].Attachment.Messages[i].Message == Message )
			{
				Attachments[j].Attachment.Messages[i].Action.Perform(CreatedAttachments[j]);
			}
		}
	}
}

DefaultProperties
{
}
