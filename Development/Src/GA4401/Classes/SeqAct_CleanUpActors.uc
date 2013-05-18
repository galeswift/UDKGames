class SeqAct_CleanUpActors extends SequenceAction;

var() bool bIgnorePersistent;

simulated event Activated()
{
	local actor A;
	local PlayerController PC;

	foreach GetWorldInfo().DynamicActors(class'Actor', A)
	{
		if( !bIgnorePersistent || !A.IsInPersistentLevel() )
		{
			if( A.IsA('GAEntity') || A.IsA('DynamicSMActor') || A.IsA('Emitter') )
			{
				A.Destroy();
			}
		}
	}

	foreach GetWorldInfo().AllControllers(class'PlayerController', PC )
	{
		PC.myHUD.KismetTextInfo.Remove(0, PC.myHUD.KismetTextInfo.Length);
	}
}

DefaultProperties
{
	bIgnorePersistent=true
	ObjName="Clean up Actors"
	ObjCategory="Actor"
}
