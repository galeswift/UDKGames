

class GPS_GFxMovie extends GFxMoviePlayer;

var bool bReloadTimerHidden;

/*
 * Initialization method for HUD.
 * 
 * Caches all the references to MovieClips that will be updated throughout
 * the HUD's lifespan.
 * 
 * For the record, GetVariableObject is not as fast as GFxObject::GetObject() but
 * nevertheless is used here for convenience.
 * 
 */
function Init(optional LocalPlayer player)
{
    Start();
    Advance(0);
}

function HideReloadTimer()
{
	if (!bReloadTimerHidden)
	{
		ActionScriptVoid("_root.HideReloadTimer");
		bReloadTimerHidden = true;
	}
}

function SetReloadTime(float pTime, float pMaxTime)
{
    ActionScriptVoid("_root.SetReloadTime");
	bReloadTimerHidden = false;
}

DefaultProperties
{
	MovieInfo=SwfMovie'GPS_Flash.GPS_Hud'

	bAllowInput=FALSE;
	bAllowFocus=FALSE;

	bReloadTimerHidden=true;
}
