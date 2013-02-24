//------------------------------------------------------------------------------
// Interpolates between two colors over time, so you can create a fade-pulsing string.
//------------------------------------------------------------------------------
class GUIStringInterpDrawInfo extends GUIStringDrawInfo;

var() byte FontShadowAlphaInterp; // Translucency of FontShadow at fully interpolated state.
var   byte ActualFontShadowAlpha;

var() color DrawColorInterp; // String color at fully interpolated state.
var   color ActualDrawColor;

var() float TransitionTime; // How long it takes to go from 0 to full interpolation.
var   float AccumulatedTime;
var   bool bReverseDirection; // If True, should interpolate from full to 0 now.

function DrawString(Canvas C, float PosX, float PosY, string DrawString, optional vector2D BoundScale)
{
    if (BoundScale.X ~= 0.f)
        BoundScale.X = 1.f;

    if (BoundScale.Y ~= 0.f)
        BoundScale.Y = 1.f;

    Interpolate();

    if (FontShadowOffset.X != 0 || FontShadowOffset.Y != 0)
    {
        C.SetPos(PosX+FontShadowOffset.X, PosY+FontShadowOffset.Y);
        C.SetDrawColor(0,0,0, ActualFontShadowAlpha);
        C.DrawText(DrawString, bCarriageReturn, ScaleX * BoundScale.X, ScaleY * BoundScale.Y);
    }

    C.SetPos(PosX, PosY);
    C.SetDrawColorStruct(ActualDrawColor);
    // Caller takes care of setting font.

    C.DrawText(DrawString, bCarriageReturn, ScaleX * BoundScale.X, ScaleY * BoundScale.Y);
}

function Interpolate()
{
    local float DeltaTime, Alpha;

    if (GUIComponent(Outer) != None)
    {
        DeltaTime = GUIComponent(Outer).ParentScene.GetRenderDelta();


        if (bReverseDirection)
        {
            AccumulatedTime -= DeltaTime;

            if (AccumulatedTime < 0)
            {
                AccumulatedTime = Abs(AccumulatedTime);
                bReverseDirection = false;
            }
        }
        else
        {
            AccumulatedTime += DeltaTime;

            if (AccumulatedTime > TransitionTime)
            {
                AccumulatedTime -= (AccumulatedTime - TransitionTime);
                bReverseDirection = True;
            }
        }


        Alpha = AccumulatedTime/TransitionTime;

        ActualFontShadowAlpha = Lerp(FontShadowAlpha, FontShadowAlphaInterp, Alpha);

        // Need to use our own color lerp because the existing one doesn't give desired results.
        ActualDrawColor.R = BLerp(DrawColor.R, DrawColorInterp.R, Alpha);
        ActualDrawColor.G = BLerp(DrawColor.G, DrawColorInterp.G, Alpha);
        ActualDrawColor.B = BLerp(DrawColor.B, DrawColorInterp.B, Alpha);
        ActualDrawColor.A = BLerp(DrawColor.A, DrawColorInterp.A, Alpha);
    }
}

DefaultProperties
{
    DrawColorInterp = (R=255,G=255,B=255,A=0)
    TransitionTime = 1.f
}