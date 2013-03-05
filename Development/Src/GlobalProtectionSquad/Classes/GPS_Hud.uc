class GPS_Hud extends UTHud;
/**
 * PostRender is the main draw loop.
 */
event PostRender()
{
	local int i;
	local int currentX;
	local float strXL, strYL;
	local string currentStr;

	Super.PostRender();

	// Draw the cheats
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(20,Canvas.SizeY - 20);

	currentX=0;
	for(i=0 ;i<CF_MAX ; i++ )
	{
		if( GPS_CheatManager(PlayerOwner.CheatManager).IsCheatOn(CheatFlags(i)) )
		{
			currentStr="[Cheat:"$GetEnum(Enum'CheatFlags',i)$"]";		
			DrawMobileDebugString(currentX,0,currentStr);

			Canvas.StrLen(currentStr, strXL, strYL);
			currentX+=strXL + 10;
		}
	}
}

DefaultProperties
{
}
