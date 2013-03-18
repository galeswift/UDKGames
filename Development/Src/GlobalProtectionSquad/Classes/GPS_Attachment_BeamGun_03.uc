class GPS_Attachment_BeamGun_03 extends UTAttachment_ShockRifle;

simulated function SpawnBeam(vector Start, vector End, bool bFirstPerson)
{
	local ParticleSystemComponent E;
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local int i;
	if ( End == Vect(0,0,0) )
	{
		if ( !bFirstPerson || (Instigator.Controller == None) )
		{
	    	return;
		}
		// guess using current viewrotation;
		End = Start + vector(Instigator.Controller.Rotation) * class'GPS_Weap_Beam_03'.default.WeaponRange;
		HitActor = Instigator.Trace(HitLocation, HitNormal, End, Start, TRUE, vect(0,0,0),, TRACEFLAG_Bullet);
		if ( HitActor != None )
		{
			End = HitLocation;
		}
	}

	E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start, rotator(End-Start), Instigator, Instigator);
	
	E.SetVectorParameter('LinkBeamEnd', End);
	for( i=0 ; i<E.EmitterInstances.Length ; i++ )
	{
		E.SetKillOnCompleted(i,true);
		E.SetKillOnDeactivate(i,true);
	}
	
	if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
	{
		E.SetDepthPriorityGroup(SDPG_Foreground);   
	}
	else
	{
		E.SetDepthPriorityGroup(SDPG_World);
	}
}


DefaultProperties
{
	WeaponClass=class'GPS_Weap_Beam_03'
	BeamTemplate=ParticleSystem'GPS_FX.Particles.P_WP_FinalBeam'
}
