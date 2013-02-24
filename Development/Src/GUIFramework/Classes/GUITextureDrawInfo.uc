//------------------------------------------------------------------------------
// Defines a texture or material to draw on the Canvas for a GUI component.
//------------------------------------------------------------------------------
class GUITextureDrawInfo extends GUIInfo;

// Use Material instead of texture.
var() bool bUseMaterial;

var() texture ComponentTexture;
var() Material ComponentMaterial; // Only the emissive channel is drawn!

// The texture is scaled by this factor in relation to the component boundaries. Default = 1.0
var() float TextureScale;

// Stretching means that pixels in the center of the Texture are stretched while the boarder remains untouched to fit the texture to the size of the component.
var() bool bStretchHorizontally, bStretchVertically;

// Coordinates within the actual Texture/Material that describe where the top-left and bottom-right corner are for drawing.
// Enter the value in pixel coordinates.
var() vector2d SubUVStart, SubUVEnd;

// Color and transparency that the component will be drawn with.
var() color DrawColor;

event InitializeInfo()
{
    if (bUseMaterial)
    {
        if (SubUVEnd.X > 1.0 || SubUVEnd.Y > 1.0)
            `warn(self@"has no valid SubUVEnd set for the Material");
    }
    else if (ComponentTexture != none)
    {
        if (SubUVEnd.X == 0.0 || SubUVEnd.Y == 0.0)
        {
            if (Texture2D(ComponentTexture) != None)
            {
                SubUVEnd.X = Texture2D(ComponentTexture).SizeX;
                SubUVEnd.Y = Texture2D(ComponentTexture).SizeY;
            }
            else if (TextureRenderTarget2D(ComponentTexture) != None)
            {
                SubUVEnd.X = TextureRenderTarget2D(ComponentTexture).SizeX;
                SubUVEnd.Y = TextureRenderTarget2D(ComponentTexture).SizeY;
            }
        }
    }
}

function DrawTexture(Canvas C, vector2D Start, vector2D End)
{
    C.SetPos(Start.X, Start.Y);
    C.SetDrawColorStruct(DrawColor);

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

event DeleteInfo()
{
    ComponentTexture = None;
    ComponentMaterial = none;
}


DefaultProperties
{
    TextureScale=1.0
    DrawColor=(R=255,G=255,B=255,A=255)
}