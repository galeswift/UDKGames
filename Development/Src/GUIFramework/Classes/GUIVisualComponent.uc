//=============================================================================
// GUIVisualComponent
//
// $wotgreal_dt: 26.10.2012 16:03:53$
//
// Base class for all components that draw Textures or Materials on the screen.
//=============================================================================
class GUIVisualComponent extends GUIComponent;

// Use the Texture as reference size instead matching it to the component.
// Only takes the first DrawInfo into account.
var() bool bFitComponentToTexture;

var() byte ForcedDrawInfo; // If not 255, always use this DrawIndex.

var() editinline instanced array<GUITextureDrawInfo> DrawInfo;


event InitializeComponent()
{
    local GUITextureDrawInfo CurInfo;

    foreach DrawInfo(CurInfo)
    {
        CurInfo.InitializeInfo();
    }

    if (DrawInfo[0] != None && !DrawInfo[0].bUseMaterial && bFitComponentToTexture)
    {
        if (Texture2D(DrawInfo[0].ComponentTexture) != None)
        {
            PosXEnd = PosX + Texture2D(DrawInfo[0].ComponentTexture).SizeX;
            PosYEnd = PosY + Texture2D(DrawInfo[0].ComponentTexture).SizeY;
        }
        else if (TextureRenderTarget2D(DrawInfo[0].ComponentTexture) != None)
        {
            PosXEnd = PosX + TextureRenderTarget2D(DrawInfo[0].ComponentTexture).SizeX;
            PosYEnd = PosY + TextureRenderTarget2D(DrawInfo[0].ComponentTexture).SizeY;
        }
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
}


event DrawComponent(Canvas C)
{
    if (!bEnabled)
        return;

    super.DrawComponent(C);

    DrawVisuals(C, 0);
}

function DrawVisuals(Canvas C, optional byte DrawIndex)
{
    local vector2d Start, End;

    if (ForcedDrawInfo < 255)
        DrawIndex = ForcedDrawInfo;

    if (DrawInfo.Length - 1 < DrawIndex)
        return;

    Start = GetComponentStartPos(C);
    End = GetComponentEndPos(C);


    if (DrawInfo[DrawIndex] != None)
        DrawInfo[DrawIndex].DrawTexture(C, Start, End);
}


event MousePressed(optional byte ButtonNum)
{
    super.MousePressed(ButtonNum);

    // handles dragging
    if (bCanDrag)
    {
        bDragging = True;
        InitialX = PosX;
        InitialY = PosY;

        if(bRelativePosX)
            MouseDiffX = (ParentScene.MousePos.X / ClipX) - PosX;
        else
            MouseDiffX = ParentScene.MousePos.X - PosX;
        if(bRelativePosY)
            MouseDiffY = (ParentScene.MousePos.Y / ClipY) - PosY;
        else
            MouseDiffY = ParentScene.MousePos.Y - PosY;
    }
}

event MouseReleased(optional byte ButtonNum)
{
    super.MouseReleased(ButtonNum);

    //handles dragging
    if (bCanDrag)
    {
        bDragging= False;
    }

    // adjustments for pressed texture
    bIsPressed = false;
}

event DeleteGUIComp()
{
    local GUITextureDrawInfo CurInfo;

    foreach DrawInfo(CurInfo)
    {
        CurInfo.DeleteInfo();
    }

    DrawInfo.Remove(0, DrawInfo.Length);

    super.DeleteGUIComp();
}

DefaultProperties
{
    ForcedDrawInfo = 255
}