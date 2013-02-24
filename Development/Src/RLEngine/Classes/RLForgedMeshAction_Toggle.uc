class RLForgedMeshAction_Toggle extends RLForgedMeshAction;

var() bool bOn;

simulated function Perform(ActorComponent Comp)
{
	local ParticleSystemComponent PSComp;
	local LightComponent LightComp;

	PSComp = ParticleSystemComponent(Comp);
	LightComp = LightComponent(Comp);
	if( PSComp != none )
	{
		if( bOn )
		{
			PSComp.ActivateSystem(true);
		}
		else
		{
			PSComp.DeactivateSystem();
		}
	}
	else if( LightComp != none )
	{
		LightComp.SetEnabled(bOn);
	}
}

DefaultProperties
{
}
