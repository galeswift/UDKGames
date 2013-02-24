class RLForgedMeshAttachment extends Object
	abstract
	editinlinenew
	hidecategories(Object)
	collapsecategories;

var() name AttachmentName;

struct RLForgedMeshMessage
{
	var() name Message;
	var() instanced RLForgedMeshAction Action;
};

var() editinline array<RLForgedMeshMessage> Messages;

var() bool bActiveOnStartup;

var class<ActorComponent> ComponentClass;

simulated function ActorComponent Create(ActorComponent NewOwner)
{
	local ActorComponent Comp;

	Comp = new(NewOwner.Outer) ComponentClass;
	Actor(NewOwner.Outer).AttachComponent(Comp);

	return Comp;
}

DefaultProperties
{
	bActiveOnStartup=true
}
