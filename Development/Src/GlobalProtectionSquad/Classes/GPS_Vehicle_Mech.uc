class GPS_Vehicle_Mech extends UTVehicle_Manta;

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=40.0
		CollisionRadius=100.0
		Translation=(X=-40.0,Y=0.0,Z=40.0)
	End Object

	Begin Object Name=SVehicleMesh
		PhysicsAsset=PhysicsAsset'CH_Mech.Mesh.SK_Mech_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
		AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_Mech.Mesh.SK_Mech'
	End Object

	DrawScale=3.0

	Seats(0)={( GunClass=class'UTVWeap_MantaGun',
				GunSocket=(Gun_Socket_01,Gun_Socket_02),
				TurretControls=(gun_rotate_lt,gun_rotate_rt),
				CameraTag="",
				CameraOffset=-180,
				SeatIconPos=(X=0.46,Y=0.45),
				DriverDamageMult=0.75,
				bSeatVisible=false,
				CameraBaseOffset=(X=-20,Y=0,Z=125),
				CameraSafeOffset=(X=-200,Y=0,Z=100),
				SeatOffset=(X=-30,Y=0,Z=-5),
				WeaponEffects=((SocketName=Gun_Socket_01,Offset=(X=-35,Y=-3),Scale3D=(X=3.0,Y=6.0,Z=6.0)),(SocketName=Gun_Socket_02,Offset=(X=-35,Y=-3),Scale3D=(X=3.0,Y=6.0,Z=6.0)))
				)}


	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=MantaEngineSound
	End Object
	EngineSound=MantaEngineSound
	Components.Add(MantaEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Start'
	ExitVehicleSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Stop'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	JumpSound=SoundCue'A_Vehicle_Manta.Sounds.A_Vehicle_Manta_JumpCue'
	DuckSound=SoundCue'A_Vehicle_Manta.Sounds.A_Vehicle_Manta_CrouchCue'

	// Initialize sound parameters.
	EngineStartOffsetSecs=0.5
	EngineStopOffsetSecs=1.0

//	VehicleEffects(0)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Exhaust_Smoke',EffectSocket=Tailpipe_1)
//	VehicleEffects(1)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Exhaust_Smoke',EffectSocket=Tailpipe_2)

	VehicleEffects(2)=(EffectStartTag=BoostStart,EffectEndTag=BoostStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.PS_Manta_Up_Boost_Jump',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(3)=(EffectStartTag=BoostStart,EffectEndTag=BoostStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.PS_Manta_Up_Boost_Jump',EffectSocket=Wing_Rt_Socket)

	VehicleEffects(4)=(EffectStartTag=CrushStart,EffectEndTag=CrushStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Down_Boost',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(5)=(EffectStartTag=CrushStart,EffectEndTag=CrushStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Down_Boost',EffectSocket=Wing_Rt_Socket)

	VehicleEffects(6)=(EffectStartTag=MantaWeapon01,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Gun_MuzzleFlash',EffectSocket=Gun_Socket_02)
	VehicleEffects(7)=(EffectStartTag=MantaWeapon02,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Gun_MuzzleFlash',EffectSocket=Gun_Socket_01)

	VehicleEffects(8)=(EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Up_Boost',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(9)=(EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Up_Boost',EffectSocket=Wing_Rt_Socket)

	VehicleEffects(10)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Manta',EffectSocket=DamageSmoke01)

	VehicleEffects(11)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.P_FX_Manta_Blades_Blurred',EffectSocket=BladeSocket)

	VehicleEffects(12)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.PS_Manta_Ground_FX',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(13)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.PS_Manta_Ground_FX',EffectSocket=Wing_rt_socket)

//	VehicleEffects(14)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.P_VH_Manta_Exhaust',EffectSocket=ExhaustPort)

	VehicleEffects(14)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(15)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=Wing_Rt_Socket)
	VehicleEffects(16)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=Gun_Socket_01)
	VehicleEffects(17)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=Gun_Socket_02)
	VehicleEffects(18)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=ExhaustPort)

	//Viper..(Special Case)........................................VH_NecrisManta.Effects.PS_Viper_Ground_FX............(this effect is in but needs a param set.  This will be the same effect for all surfaces except water which will use the same Param just swap PS to ...( Envy_Level_Effects_2.Vehicle_Water_Effects.PS_Viper_Water_Ground_FX )   (Param Name: Direction,  MinINPUT: -5  MaxINPUT: 5)  0 is when the Vh is still, positive X=forward movemet 5 being max forward movement.  -X is backwards.  Y is same thing but side to side

	// guess we can just have a water effect name here and then check for water and then then add and && to use only this named VehicleEffects index data


	FanEffectIndex=11

	GroundEffectIndices=(12,13)
	WaterGroundEffect=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.PS_Manta_Water_Effects'

	FanEffectParameterName=MantaFanSpin
	FlameJetEffectParameterName=Jet

	IconCoords=(U=859,UL=36,V=0,VL=27)

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Near')
	BigExplosionSocket=VH_Death
	ExplosionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Explode'

	TeamMaterials[0]=MaterialInstanceConstant'VH_Manta.Materials.MI_VH_Manta_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Manta.Materials.MI_VH_Manta_Blue'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Manta.Materials.MI_VH_Manta_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Manta.Materials.MI_VH_Manta_Spawn_Blue'))

	DrivingPhysicalMaterial=PhysicalMaterial'VH_Manta.physmat_mantadriving'
	DefaultPhysicalMaterial=PhysicalMaterial'VH_Manta.physmat_manta'

	BurnOutMaterial[0]=MaterialInterface'VH_Manta.Materials.MITV_VH_Manta_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Manta.Materials.MITV_VH_Manta_Blue_BO'

	DamageMorphTargets(0)=(InfluenceBone=Damage_LtCanard,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=70,DamagePropNames=(Damage2))
	DamageMorphTargets(1)=(InfluenceBone=Damage_RtRotor,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=70,DamagePropNames=(Damage3))
	DamageMorphTargets(2)=(InfluenceBone=Damage_LtRotor,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=70,DamagePropNames=(Damage3))
	DamageMorphTargets(3)=(InfluenceBone=Hatch,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=70,DamagePropNames=(Damage1))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.5)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.5)

	HudCoords=(U=228,V=143,UL=-119,VL=106)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_Reaper.BotStatus.A_BotStatus_Reaper_EnemyManta'

	Health=200
	MeleeRange=-100.0
	ExitRadius=160.0
	bTakeWaterDamageWhileDriving=false

	COMOffset=(x=0.0,y=0.0,z=0.0)
	UprightLiftStrength=30.0
	UprightTorqueStrength=30.0
	bCanFlip=true
	JumpForceMag=7000.0
	JumpDelay=3.0
	MaxJumpZVel=900.0
	DuckForceMag=-350.0
	JumpCheckTraceDist=175.0
	FullWheelSuspensionTravel=145
	CrouchedWheelSuspensionTravel=100
	FullWheelSuspensionStiffness=20.0
	CrouchedWheelSuspensionStiffness=40.0
	SuspensionTravelAdjustSpeed=100
	BoneOffsetZAdjust=45.0
	CustomGravityScaling=0.8

	AirSpeed=1800.0
	GroundSpeed=1500.0
	CrouchedAirSpeed=1200.0
	FullAirSpeed=1800.0
	bCanCarryFlag=false
	bFollowLookDir=True
	bTurnInPlace=True
	bScriptedRise=True
	bCanStrafe=True
	ObjectiveGetOutDist=750.0
	MaxDesireability=0.6
	SpawnRadius=125.0
	MomentumMult=3.2

	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=450
	StayUprightDamping=20

	bRagdollDriverOnDarkwalkerHorn=true

	Begin Object Name=SimObject
		WheelSuspensionStiffness=20.0
		WheelSuspensionDamping=1.0
		WheelSuspensionBias=0.0
		MaxThrustForce=325.0
		MaxReverseForce=250.0
		LongDamping=0.3
		MaxStrafeForce=260.0
		DirectionChangeForce=375.0
		LatDamping=0.3
		MaxRiseForce=0.0
		UpDamping=0.0
		TurnTorqueFactor=2500.0
		TurnTorqueMax=1000.0
		TurnDamping=0.25
		MaxYawRate=100000.0
		PitchTorqueFactor=200.0
		PitchTorqueMax=18.0
		PitchDamping=0.1
		RollTorqueTurnFactor=1000.0
		RollTorqueStrafeFactor=110.0
		RollTorqueMax=500.0
		RollDamping=0.2
		MaxRandForce=20.0
		RandForceInterval=0.4
		bAllowZThrust=false
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	Begin Object Name=RThruster
		BoneName="b_Root"
		BoneOffset=(X=-50.0,Y=100.0,Z=-200.0)
		//BoneOffset=(X=-50.0,Y=100.0,Z=-100.0)
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(0)=RThruster

	Begin Object Name=LThruster
		BoneName="b_Root"
		BoneOffset=(X=-50.0,Y=-100.0,Z=-200.0)
		//BoneOffset=(X=-50.0,Y=-100.0,Z=-100.0)
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(1)=LThruster

	Begin Object Class=UTHoverWheel Name=FLThruster
		BoneName="b_Root"
		BoneOffset=(X=80.0,Y=-100.0,Z=-200.0)
		//BoneOffset=(X=80.0,Y=0.0,Z=-100.0)
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(2)=FLThruster

	Begin Object Class=UTHoverWheel Name=FRThruster
		BoneName="b_Root"
		BoneOffset=(X=80.0,Y=100.0,Z=-200.0)
		//BoneOffset=(X=80.0,Y=0.0,Z=-100.0)
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(3)=FRThruster

	bAttachDriver=true
	bDriverIsVisible=false

	bHomingTarget=true

	BaseEyeheight=110
	Eyeheight=110

	DefaultFOV=90
	CameraLag=0.02
	bCanBeBaseForPawns=true
	bEjectKilledBodies=true

	HornIndex=0
}
