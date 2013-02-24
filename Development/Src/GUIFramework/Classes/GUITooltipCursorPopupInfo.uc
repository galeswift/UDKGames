//------------------------------------------------------------------------------
// Draws a tooltip
//------------------------------------------------------------------------------
class GUITooltipCursorPopupInfo extends GUITooltipDrawInfo;

var() Font Font; // if no Font specified, will use GUICompatibleHUD.PlayerFont
var() color DrawColor;
var() float ScaleX, ScaleY;
var() bool bCarriageReturn; // If true, start in a new line if string exceeds clipping limit.

var() IntPoint FontShadowOffset; // If > 0, draws a shadow of this pixel size below the actual string. Keep it reasonably low, 1 pixel is actually enough already.
var() byte FontShadowAlpha; // How dark the shadow is. 255 = complete blackness.

var() color BackgroundColor;

var() float MaxTooltipWidth; // Maximum width of the tooltip box.

function DrawTooltip(Canvas C, float PosX, float PosY, string DrawString)
{
    local float XL, YL;


    C.Font = Font;
    C.TextSize(DrawString, XL, YL, ScaleX, ScaleY);

    //TODO: Move text box around when it's too close at the border.
    // Carriage return should only be used to limit the width of the box.

    C.SetDrawColorStruct(BackgroundColor);
    C.SetPos(PosX, PosY);
    C.DrawRect(XL, YL);

    if (FontShadowOffset.X != 0 || FontShadowOffset.Y != 0)
    {
        C.SetPos(PosX+FontShadowOffset.X, PosY+FontShadowOffset.Y);
        C.SetDrawColor(0,0,0, FontShadowAlpha);
        C.DrawText(DrawString, bCarriageReturn, ScaleX, ScaleY);
    }

    C.SetPos(PosX, PosY);
    C.SetDrawColorStruct(DrawColor);

    C.DrawText(DrawString, bCarriageReturn, ScaleX, ScaleY);
}

event DeleteInfo()
{
    Font = None;
}

DefaultProperties
{
    Font = Font'EngineFonts.SmallFont'
    DrawColor = (R=255,G=255,B=255,A=255)
    BackgroundColor = (A=255)
    bCarriageReturn = True
    ScaleX = 1.f
    ScaleY = 1.f
    MaxTooltipWidth = 200
    TooltipDelay = 0.5
}