class GPS_Hud extends UTHud;

struct DamageHUDInfo
{
	var int DamageAmount;
	var Actor DamagedActor;
	var float DamageShowStartTime;
	var Vector DamageHudVelocity;
	var Vector DamageHudLocation;
	var Vector DamageHudOffset;
	var bool Initialized;
	var float DamageHudLifeTime;
	var float DamageHudScale;
};

/** The acceleration we apply to HUD damage numbers */
var Vector DamageHUDAcceleration;

/** How long to keep HUD items on screen for */
var float DamageHudDefaultLifeTime;

/** This is considered a large amount of damage */
var float DamageInfoScaleValue;

/** Current list of damage we're showing */
var array<DamageHUDInfo> DamageInfoList;

/** Main Heads Up Display Flash movie */
var GPS_GFxMovie   GfxHudMovie;

/** Class of HUD Movie object */
var class<GPS_GFxMovie> GFxHUDClass;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	CreateGFxHUDMovie();
}

/**
 * PostRender is the main draw loop.
 */
event PostRender()
{
	local int i;
	local int currentX;
	local float strXL, strYL;
	local string currentStr;
	local string expStr;
	RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;

	// Draw the cheats
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(20,Canvas.SizeY - 20);

	currentX=0;
	for(i=0 ;i<CF_MAX ; i++ )
	{
		if( PlayerOwner.CheatManager != none &&
			GPS_CheatManager(PlayerOwner.CheatManager).IsCheatOn(CheatFlags(i)) )
		{
			currentStr="[Cheat:"$GetEnum(Enum'CheatFlags',i)$"]";		
			DrawMobileDebugString(currentX,0,currentStr);

			Canvas.StrLen(currentStr, strXL, strYL);
			currentX+=strXL + 10;
		}
	}

	Canvas.Font = Font'UI_Fonts.Fonts.UI_FOnts_AmbexHeavy10';

	// Draw EXP on the screen
	expStr = "Experience: ["$GPS_PlayerController(PlayerOwner).SaveData.CurrentExp$"] Level: ["$GPS_PlayerController(PlayerOwner).GetLevel()$"]";
	Canvas.StrLen(expStr, strXL, strYL);
	Canvas.SetPos( 0, 30 );
	Canvas.DrawText(expStr);


	// Draw the mission info
	if( GPS_PlayerController(PlayerOwner).MissionManager != none )
	{
		GPS_PlayerController(PlayerOwner).MissionManager.PostRender(Canvas);
	}

	// Draw the floating damage text
	for( i=DamageInfoList.Length-1 ; i>=0; i-- )
	{
		if( GPS_GameCrowdAgent(DamageInfoList[i].DamagedActor) != none )
		{
			DamageInfoList[i].DamageHudLocation = Canvas.Project(GPS_GameCrowdAgent(DamageInfoList[i].DamagedActor).SkeletalMeshComponent.Bounds.Origin);
		}
		else
		{
			DamageInfoList[i].DamageHudLocation = Canvas.Project(DamageInfoList[i].DamagedActor.Location);
		}

		DamageInfoList[i].DamageHudVelocity += DamageHUDAcceleration * RenderDelta;
		DamageInfoList[i].DamageHudOffset += DamageInfoList[i].DamageHudVelocity * RenderDelta;
		Canvas.StrLen(DamageInfoList[i].DamageAmount, strXL, strYL);
		Canvas.SetPos(DamageInfoList[i].DamageHudOffset.X + DamageInfoList[i].DamageHudLocation.X-0.5*strXL,DamageInfoList[i].DamageHudOffset.Y + DamageInfoList[i].DamageHudLocation.Y-0.5*strYL);
		Canvas.DrawText(DamageInfoList[i].DamageAmount,,DamageInfoList[i].DamageHudScale,DamageInfoList[i].DamageHudScale);
	
		if( (WorldInfo.TimeSeconds - DamageInfoList[i].DamageShowStartTime ) >= DamageInfoList[i].DamageHudLifeTime )
		{
			DamageInfoList.Remove(i,1);
		}
	}

	Super.PostRender();
}

function AddDamageFor(Actor A, int DamageAmount)
{
	local int newDmgInfoIndex;
	local float DamageScaling;
	DamageScaling = DamageAmount/DamageInfoScaleValue;
	newDmgInfoIndex = DamageInfoList.Length;
	DamageInfoList.Add(1);
	DamageInfoList[newDmgInfoIndex].DamageAmount = DamageAmount;
	DamageInfoList[newDmgInfoIndex].DamagedActor = A;
	DamageInfoList[newDmgInfoIndex].DamageShowStartTime = WorldInfo.TimeSeconds;
	DamageInfoList[newDmgInfoIndex].DamageHudVelocity.X = Rand(240) - 120;
	DamageInfoList[newDmgInfoIndex].DamageHudVelocity.Y = -180 - 180 * DamageScaling;
	DamageInfoList[newDmgInfoIndex].DamageHudLifeTime = DamageHudDefaultLifeTime + 1 * DamageScaling;
	DamageInfoList[newDmgInfoIndex].DamageHudScale = FMin(6, 1 + 5 * DamageScaling);
}

/**
  * Create and initialize the GFxHUDMovie.
  */
function CreateGFxHUDMovie()
{
	GFxHudMovie = new GFxHUDClass;
	GFxHudMovie.SetTimingMode(TM_Real);
	GFxHudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[GFxHudMovie.LocalPlayerOwnerIndex]);
}

function SetReloadTime(float pTime, float pMaxTime)
{
	GFxHudMovie.SetReloadTime(pTime, pMaxtime);
}

function HideReloadTimer()
{
	GFxHudMovie.HideReloadTimer();
}

DefaultProperties
{
	DamageHUDAcceleration=(X=0.0,Y=520)
	DamageHudDefaultLifeTime=1.00
	DamageInfoScaleValue=1000
	GFxHUDClass=class'GPS_GFxMovie'
}
