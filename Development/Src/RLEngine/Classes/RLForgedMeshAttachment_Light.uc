class RLForgedMeshAttachment_Light extends RLForgedMeshAttachment;

var() float Brightness;
var() Color LightColor;

simulated function ActorComponent Create(ActorComponent NewOwner)
{
	local PointLightComponent LightComp;

	LightComp = PointLightComponent(super.Create(NewOwner));
	if( LightComp != none )
	{
		LightComp.SetLightProperties(Brightness,LightColor);
		LightComp.SetEnabled(bActiveOnStartup);
	}

	return LightComp;
}

DefaultProperties
{
	ComponentClass=class'PointLightComponent'
	Brightness=1
	LightColor=(R=255,G=255,B=255)
}
