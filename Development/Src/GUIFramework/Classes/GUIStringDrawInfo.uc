//------------------------------------------------------------------------------
// Defines the look of a string to draw in the menu. Not the actual string message.
//------------------------------------------------------------------------------
class GUIStringDrawInfo extends GUIInfo;

var() Font Font; // if no Font specified, will use GUICompatibleHUD.PlayerFont
var() Color DrawColor;
var() float ScaleX, ScaleY;
var() bool bCarriageReturn; // If true, start in a new line if string exceeds clipping limit.

var() bool bLimitTextToBounds; // If True, text will be scaled to be always inside the bounds.
                               // Useful for localized text, since some languages have longer words than others.

var() IntPoint FontShadowOffset; // If > 0, draws a shadow of this pixel size below the actual string. Keep it reasonably low, 1 pixel is actually enough already.
var() byte FontShadowAlpha; // How dark the shadow is. 255 = complete blackness.


function DrawString(Canvas C, float PosX, float PosY, string DrawString, optional vector2D BoundScale)
{
    if (BoundScale.X ~= 0.f)
        BoundScale.X = 1.f;

    if (BoundScale.Y ~= 0.f)
        BoundScale.Y = 1.f;

    if (FontShadowOffset.X != 0 || FontShadowOffset.Y != 0)
    {
        C.SetPos(PosX+FontShadowOffset.X, PosY+FontShadowOffset.Y);
        C.SetDrawColor(0,0,0, FontShadowAlpha);
        C.DrawText(DrawString, bCarriageReturn, ScaleX * BoundScale.X, ScaleY * BoundScale.Y);
    }

    C.SetPos(PosX, PosY);
    C.SetDrawColorStruct(DrawColor);
    // Caller takes care of setting font.

    C.DrawText(DrawString, bCarriageReturn, ScaleX * BoundScale.X, ScaleY * BoundScale.Y);
}

// Returns a scale for the string to keep it inside the BoundSize, if required.
final function vector2D GetBoundScale(Canvas C, string DrawString, vector2D BoundSize)
{
    local vector2D Result;

    if (!bLimitTextToBounds || BoundSize.X ~= 0 || BoundSize.Y ~= 0)
    {
        Result.X = 1.f;
        Result.Y = 1.f;
    }
    else
    {
        C.TextSize(DrawString, Result.X, Result.Y, ScaleX, ScaleY);
        if (Result.X != 0.f)
        {
            Result.X = FMin(BoundSize.X/Result.X, 1.f);
        }
        else
        {
            Result.X = 1.f;
        }

        if (Result.Y != 0.f)
        {
            Result.Y = FMin(BoundSize.Y/Result.Y, 1.f);
        }
        else
        {
            Result.Y = 1.f;
        }
    }

    return Result;
}


event DeleteInfo()
{
    Font = None;
}

DefaultProperties
{
    DrawColor=(R=255,G=255,B=255,A=255) // White
    ScaleX = 1.f
    ScaleY = 1.f
    bCarriageReturn = True
    bLimitTextToBounds = True
    FontShadowAlpha = 255
}