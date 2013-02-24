//=============================================================================
// GUICheckButtonComponent
//
// $wotgreal_dt: 26.10.2012 16:04:56$
//
// A button that can display one of two states and is generally used to
// represent boolean values.
//=============================================================================
class GUICheckButtonComponent extends GUIInteractiveComponent;;

// If True, the component is checked and DrawInfoChecked will be drawn
var() bool bChecked;
// If True, both the DrawInfo and the DrawInfoChecked will be drawn when it is checked
var() bool bAddChecked;
// Images to draw when the component is checked
var() editinline instanced array<GUITextureDrawInfo> DrawInfoChecked;

event InitializeComponent()
{
    local GUITextureDrawInfo Cur;

    foreach DrawInfo(Cur)
    {
        Cur.InitializeInfo();
    }

    super.InitializeComponent();
}

function PrecacheComponentTextures(Canvas C)
{
    local int i;
    local vector2D Zero, Max;

    Max.X = 1024;
    Max.Y = 768;

    for (i = 0; i < DrawInfo.Length; i++)
    {
        if (DrawInfo[i] != None)
            DrawInfo[i].DrawTexture(C, Zero, Max);
    }

    for (i = 0; i < DrawInfoChecked.Length; i++)
    {
        if (DrawInfoChecked[i] != None)
            DrawInfoChecked[i].DrawTexture(C, Zero, Max);
    }
}

function DrawVisuals(Canvas C, optional byte DrawIndex)
{
    local vector2d Start, End;

    Start = GetComponentStartPos(C);
    End = GetComponentEndPos(C);

    if (!bChecked || bChecked && bAddChecked)
        super.DrawVisuals(C, DrawIndex);

    if (bChecked)
    {
        C.SetPos(Start.X, Start.Y);
        C.DrawColor = DrawInfoChecked[DrawIndex].DrawColor;

        if (DrawInfoChecked[DrawIndex].bUseMaterial)
        {
            if (DrawInfoChecked[DrawIndex].ComponentMaterial == None)
                return;

            C.DrawMaterialTile(DrawInfoChecked[DrawIndex].ComponentMaterial,
                            End.X - Start.X, End.Y - Start.Y,
                            DrawInfoChecked[DrawIndex].SubUVStart.X, DrawInfoChecked[DrawIndex].SubUVStart.Y,
                            DrawInfoChecked[0].SubUVEnd.X, DrawInfoChecked[DrawIndex].SubUVEnd.Y,
                            True);
        }
        else
        {
            if (DrawInfoChecked[DrawIndex].ComponentTexture == None)
                return;

            if (!bFitComponentToTexture || DrawIndex != 0)
            {
                C.DrawTileStretched(DrawInfoChecked[DrawIndex].ComponentTexture,
                                    End.X - Start.X, End.Y - Start.Y,
                                    DrawInfoChecked[DrawIndex].SubUVStart.X, DrawInfoChecked[DrawIndex].SubUVStart.Y,
                                    DrawInfoChecked[DrawIndex].SubUVEnd.X, DrawInfoChecked[DrawIndex].SubUVEnd.Y, ,
                                    DrawInfoChecked[DrawIndex].bStretchHorizontally, DrawInfoChecked[DrawIndex].bStretchVertically,
                                    DrawInfoChecked[DrawIndex].TextureScale);
            }
            else
            {
                C.DrawTile(DrawInfoChecked[DrawIndex].ComponentTexture,
                        End.X - Start.X, End.Y - Start.Y,
                        DrawInfoChecked[DrawIndex].SubUVStart.X, DrawInfoChecked[DrawIndex].SubUVStart.Y,
                        DrawInfoChecked[0].SubUVEnd.X, DrawInfoChecked[DrawIndex].SubUVEnd.Y, ,
                        True);
            }
        }
    }
}

event MouseReleased(optional byte ButtonNum)
{
    bChecked = !bChecked;
    OnPropertyChanged(); // Notify about changed checkbox value.

    super.MouseReleased(ButtonNum);
}

// Returns a numerical representation of the value that the component represents.
function float GetComponentValue()
{
    return bChecked ? 1.f : 0.f;
}

event DeleteGUIComp()
{
    local GUITextureDrawInfo CurInfo;

    foreach DrawInfoChecked(CurInfo)
    {
        CurInfo.DeleteInfo();
    }

    DrawInfoChecked.Remove(0, DrawInfoChecked.Length);

    super.DeleteGUIComp();
}

DefaultProperties
{
}
