class RLForgedMeshAttachment_Particles extends RLForgedMeshAttachment;

var() ParticleSystem ParticleTemplate;

simulated function ActorComponent Create(ActorComponent NewOwner)
{
	local ParticleSystemComponent PSComp;

	PSComp = ParticleSystemComponent(super.Create(NewOwner));
	if( PSComp != none )
	{
		PSComp.SetTemplate(ParticleTemplate);
		if( bActiveOnStartup )
		{
			PSComp.ActivateSystem(true);
		}
		else
		{
			PSComp.DeactivateSystem();
		}
	}

	return PSComp;
}

DefaultProperties
{
	ComponentClass=class'ParticleSystemComponent'
}
