//------------------------------------------------------------------------------
// Interpolates between two colors over time, so you can create a fade-pulsing string.
//------------------------------------------------------------------------------
class GUITextureInterpDrawInfo extends GUITextureDrawInfo;

var() color DrawColorInterp; // String color at fully interpolated state.
var   color ActualDrawColor;

var() float TransitionTime; // How long it takes to go from 0 to full interpolation.
var   float AccumulatedTime;
var   bool bReverseDirection; // If True, should interpolate from full to 0 now.

function DrawTexture(Canvas C, vector2D Start, vector2D End)
{
    Interpolate();

    C.SetPos(Start.X, Start.Y);
    C.SetDrawColorStruct(ActualDrawColor);

    if (bUseMaterial)
    {
        if (ComponentMaterial == None)
            return;

        C.DrawMaterialTile(ComponentMaterial, End.X - Start.X, End.Y - Start.Y,
                           SubUVStart.X, SubUVStart.Y, SubUVEnd.X, SubUVEnd.Y, True);
    }
    else
    {
        if (ComponentTexture == None)
            return;

        C.DrawTileStretched(ComponentTexture, End.X - Start.X, End.Y - Start.Y,
                            SubUVStart.X, SubUVStart.Y, SubUVEnd.X, SubUVEnd.Y, ,
                            bStretchHorizontally, bStretchVertically, TextureScale);
    }

}

function Interpolate()
{
    local float DeltaTime, Alpha;

    if (GUIComponent(Outer) != None)
    {
        DeltaTime = GUIComponent(Outer).ParentScene.GetRenderDelta();


        AccumulatedTime += bReverseDirection ? DeltaTime : -DeltaTime;

        if (bReverseDirection)
        {
            if (AccumulatedTime < 0)
            {
                AccumulatedTime = Abs(AccumulatedTime);
                bReverseDirection = false;
            }
        }
        else
        {
            if (AccumulatedTime > TransitionTime)
            {
                AccumulatedTime -= (AccumulatedTime - TransitionTime);
                bReverseDirection = True;
            }
        }

        Alpha = AccumulatedTime/TransitionTime;

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