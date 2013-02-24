class PT_WeapLinkGun extends UTWeap_LinkGun;

simulated function AddBeamEmitter()
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (BeamEmitter[CurrentFireMode] == None)
		{
			if (BeamTemplate[CurrentFireMode] != None)
			{
				BeamEmitter[CurrentFireMode] = new(Outer) class'UTParticleSystemComponent';
				BeamEmitter[CurrentFireMode].SetDepthPriorityGroup(SDPG_Foreground);
				BeamEmitter[CurrentFireMode].SetTemplate(BeamTemplate[CurrentFireMode]);
				BeamEmitter[CurrentFireMode].SetHidden(true);
				BeamEmitter[CurrentFireMode].SetTickGroup( TG_PostUpdateWork );
				BeamEmitter[CurrentFireMode].bUpdateComponentInTick = true;
				BeamEmitter[CurrentFireMode].SetIgnoreOwnerHidden(TRUE);
				`log("Instigator"@Instigator@"mesh is "@Instigator.Mesh@Instigator.Mesh.SkeletalMesh);
				`log("Getting socket "@Instigator.Mesh.GetSocketByName(BeamSockets[CurrentFireMode]));
				Instigator.Mesh.AttachComponentToSocket( BeamEmitter[CurrentFireMode],BeamSockets[CurrentFireMode] );
				//Instigator.AttachComponent(BeamEmitter[CurrentFireMode]);
			}
		}
		else
		{
			BeamEmitter[CurrentFireMode].ActivateSystem();
		}
	}
}

simulated function UpdateBeamEmitter(vector FlashLocation, vector HitNormal, actor HitActor)
{
	local color BeamColor;
	local ParticleSystem BeamSystem, BeamEndpointTemplate, MuzzleFlashTemplate;
	local byte TeamNum;
	local LinearColor LinColor;

	if (LinkedTo != None)
	{
		FlashLocation = GetLinkedToLocation();
	}

	if (BeamEmitter[CurrentFireMode] != none)
	{
		SetBeamEmitterHidden( false );
		BeamEmitter[CurrentFireMode].SetVectorParameter(EndPointParamName,FlashLocation);
	}

	if (LinkedTo != None && WorldInfo.GRI.GameClass.Default.bTeamGame)
	{
		TeamNum = Instigator.GetTeamNum();
		LinkAttachmentClass.static.GetTeamBeamInfo(TeamNum, BeamColor, BeamSystem, BeamEndpointTemplate);
		MuzzleFlashTemplate = GetTeamMuzzleFlashTemplate(TeamNum);
	}
	else if ( (LinkStrength > 1) || (Instigator.DamageScaling >= 2.0) )
	{
		BeamColor = LinkAttachmentClass.default.HighPowerBeamColor;
		BeamSystem = LinkAttachmentClass.default.HighPowerSystem;
		BeamEndpointTemplate = LinkAttachmentClass.default.HighPowerBeamEndpointTemplate;
		MuzzleFlashTemplate = HighPowerMuzzleFlashTemplate;
	}
	else
	{
		LinkAttachmentClass.static.GetTeamBeamInfo(255, BeamColor, BeamSystem, BeamEndpointTemplate);

		MuzzleFlashTemplate = GetTeamMuzzleFlashTemplate(255);
	}

	if ( BeamLight != None )
	{
		if ( HitNormal == vect(0,0,0) )
		{
			BeamLight.Beamlight.Radius = 48;
			if ( FastTrace(FlashLocation, FlashLocation-vect(0,0,32)) )
				BeamLight.SetLocation(FlashLocation - vect(0,0,32));
			else
				BeamLight.SetLocation(FlashLocation);
		}
		else
		{
			BeamLight.Beamlight.Radius = 32;
			BeamLight.SetLocation(FlashLocation + 16*HitNormal);
		}
		BeamLight.BeamLight.SetLightProperties(, BeamColor);
	}

	if (BeamEmitter[CurrentFireMode] != None)
	{
		BeamEmitter[CurrentFireMode].SetColorParameter('Link_Beam_Color', BeamColor);
		if (BeamEmitter[CurrentFireMode].Template != BeamSystem)
		{
			BeamEmitter[CurrentFireMode].SetTemplate(BeamSystem);
		}
	}

	if (MuzzleFlashPSC != None)
	{
		MuzzleFlashPSC.SetColorParameter('Link_Beam_Color', BeamColor);
		if (MuzzleFlashTemplate != MuzzleFlashPSC.Template)
		{
			MuzzleFlashPSC.SetTemplate(MuzzleFlashTemplate);
		}
	}
	if (UTLinkGunMuzzleFlashLight(MuzzleFlashLight) != None)
	{
		UTLinkGunMuzzleFlashLight(MuzzleFlashLight).SetTeam((LinkedTo != None && WorldInfo.GRI.GameClass.Default.bTeamGame) ? Instigator.GetTeamNum() : byte(255));
	}

	if (WeaponMaterialInstance != None)
	{
		LinColor = ColorToLinearColor(BeamColor);
		WeaponMaterialInstance.SetVectorParameterValue('TeamColor', LinColor);
	}

	if (WorldInfo.NetMode != NM_DedicatedServer && Instigator != None && Instigator.IsFirstPerson())
	{
		if (BeamEndpointEffect != None && !BeamEndpointEffect.bDeleteMe)
		{
			BeamEndpointEffect.SetLocation(FlashLocation);
			BeamEndpointEffect.SetRotation(rotator(HitNormal));
			if (BeamEndpointEffect.ParticleSystemComponent.Template != BeamEndpointTemplate)
			{
				BeamEndpointEffect.SetTemplate(BeamEndpointTemplate, true);
			}
		}
		else
		{
			BeamEndpointEffect = Spawn(class'UTEmitter', self,, FlashLocation, rotator(HitNormal));
			BeamEndpointEffect.SetTemplate(BeamEndpointTemplate, true);
			BeamEndpointEFfect.LifeSpan = 0.0;
		}
		if(BeamEndpointEffect != none)
		{
			if(HitActor != none && UTPawn(HitActor) == none)
			{
				BeamEndpointEffect.SetFloatParameter('Touch',1);
			}
			else
			{
				BeamEndpointEffect.SetFloatParameter('Touch',0);
			}
		}
	}
}

/**
 * This function aligns the gun model in the world
 */
simulated event SetPosition(UDKPawn Holder)
{
	SetLocation(Instigator.GetPawnViewLocation());
}

DefaultProperties
{
	BeamTemplate[1]=ParticleSystem'PT_FX.Effects.P_WP_Linkgun_Altbeam'
	BeamSockets[1]=MussleFlashSocket02
}
