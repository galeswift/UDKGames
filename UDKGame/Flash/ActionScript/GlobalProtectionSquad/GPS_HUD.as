

/**
 * ...
 * @author John Plou
 */
package {
	
	//import gfx.core.UIComponent;
	import scaleform.clik.core.UIComponent;

	public class GPS_HUD extends UIComponent
	{
		public function GPS_HUD() 
		{
			HideReloadTimer();
		}
		
		public function SetReloadTime(time:Number, maxTime:Number):void
		{
			ReloadProgressBar.txtReloadTime.text = "" + int((time)*10)/10;
			ReloadProgressBar.txtReloadTimeShadow.text = "" + int((time)*10)/10;
			ReloadProgressBar.imgForeground.width = ReloadProgressBar.imgBackground.width * (time/maxTime);
			ReloadProgressBar.visible = true;
		}
		
		public function HideReloadTimer()
		{
			ReloadProgressBar.visible = false;
		}
	}
}