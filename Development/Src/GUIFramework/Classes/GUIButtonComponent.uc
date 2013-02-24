//=============================================================================
// GUIButtonComponent
//
// $wotgreal_dt: 09/11/2012 6:49:57 PM$
//
// A clickable component with a caption.
//
// @ slots:
// 0 = normal
// 1 = hover-selected
// 2 = click-selected
// 3 = pressed
//=============================================================================
class GUIButtonComponent extends GUIInteractiveComponent;

var() editinline instanced array<GUIStringDrawInfo> CaptionInfo;

var() byte ForcedCaptionInfo; // If not 255, always use this DrawIndex.

var() array<string> Caption; // Caption to draw or just a keyname to lookup the localized version.
var() bool bDrawCaption; // Wether or not the Caption should be drawn

var() bool bLocalizeCaption;
/* Wether or not the Caption is localized.
 * if it's localized, the Caption string is just a key to look up the actual
 * string in the localization file.
 * The file name is specified in the ParentScene.
 * The section name is the name of the ParentScene's class.
 */

var() GFxMoviePlayer.GFxAlign Alignment; // Caption Alignment


event InitializeComponent()
{
    local GUIStringDrawInfo CurInfo;

    super.InitializeComponent();

    if (ParentScene != None)
    {
        foreach CaptionInfo(CurInfo)
        {
            CurInfo.InitializeInfo();

            if (CurInfo.Font == None)
            {
                CurInfo.Font = ParentScene.GetDefaultFont();
            }
        }
    }
}

event DrawComponent(Canvas C)
{
    local int Index;

    if (!bEnabled)
        return;

    super(GUIComponent).DrawComponent(C);

    if (bIsPressed)
        Index = 3;
    else if (bIsClickSelected)
        Index = 2;
    else if (bIsHoverSelected)
        Index = 1;
    else
        Index = 0;

    DrawVisuals(C, Index);
    if (bDrawCaption)
        DrawCaption(C, Index);
}

function DrawCaption(Canvas C, optional byte DrawIndex)
{
    local float X,Y,XL,YL;
    local string DrawString;
    local vector2D BoundScale;

    if (ForcedCaptionInfo < 255)
        DrawIndex = ForcedCaptionInfo;

    if (Caption[DrawIndex] != "")
    {
        // If a custom font is specified use that, else go to default one.
        if (DrawIndex < CaptionInfo.Length && CaptionInfo[DrawIndex] != None)
        {
            if (CaptionInfo[DrawIndex].Font != None)
                C.Font = CaptionInfo[DrawIndex].Font;

            // Wether or not we want to use localized text to be displayed
            if (bLocalizeCaption)
                DrawString = GetLocalizedString(Caption[DrawIndex]);
            else
                DrawString = Caption[DrawIndex];

            C.TextSize(DrawString, XL, YL, CaptionInfo[DrawIndex].ScaleX, CaptionInfo[DrawIndex].ScaleY);
            BoundScale = CaptionInfo[DrawIndex].GetBoundScale(C, DrawString, GetComponentSize(C));
            GetTextLocation(C, X, Y, XL * BoundScale.X, YL * BoundScale.Y);

            // Let the CaptionInfo take care of drawing, so it can be easily modified.
            CaptionInfo[DrawIndex].DrawString(C, X, Y, DrawString, BoundScale);
        }
        else
        {
            C.Font = ParentScene.GetDefaultFont();

            // Wether or not we want to use localized text to be displayed
            if (bLocalizeCaption)
                DrawString = GetLocalizedString(Caption[DrawIndex]);
            else
                DrawString = Caption[DrawIndex];

            C.TextSize(DrawString, XL, YL);
            GetTextLocation(C, X, Y, XL, YL);

            C.SetPos(X, Y);
            C.SetDrawColor(255, 255, 255);
            C.DrawText(DrawString);
        }
    }
}

function GetTextLocation(Canvas C, out float X,out float Y,float XL,float YL)
{
	local vector2d Start, Size, End;
	Start = GetComponentStartPos(C);
	Size = GetComponentSize(C);
	End = GetComponentEndPos(C);
    switch(Alignment)
    {
        Case Align_Center:

			X = Start.X + (Size.X / 2);
			Y = Start.Y + (Size.Y / 2);

            X -= XL / 2;
            Y -= YL / 2;
            break;

        Case Align_CenterLeft:
            X = Start.X;
            Y = Start.Y + (Size.Y / 2);

            Y -= YL / 2;
            break;

        Case Align_CenterRight:
                X = End.X;
                Y = Start.Y + (Size.Y / 2);

            X -= XL;
            Y -= YL / 2;
            break;

        Case Align_TopLeft:
                X = Start.X;
                Y = Start.Y;

            break;

        Case Align_TopCenter:
                X = Start.X + ( Size.X / 2);
                Y = Start.Y;

            X -= XL / 2;
            break;

        Case Align_TopRight:
                X = End.X;
                Y = Start.Y;

            X -= XL;
            break;

        Case Align_BottomLeft:
                X = Start.X;
                Y = End.Y;

            Y -= YL;
            break;

        Case Align_BottomCenter:
                X = Start.X + ( Size.X / 2);
                Y = End.Y;

            X -= XL / 2;
            Y -= YL;
            break;

        Case Align_BottomRight:
                X = End.X;
                Y = End.Y;

            X -= XL;
            Y -= YL;
            break;
    }
}

event DeleteGUIComp()
{
    local GUIStringDrawInfo CurInfo;

    foreach CaptionInfo(CurInfo)
    {
        CurInfo.DeleteInfo();
    }

    CaptionInfo.Remove(0, CaptionInfo.Length);

    super.DeleteGUIComp();
}


DefaultProperties
{
    bCanHaveSelection = true // This means hover selection
    bCanBePressed = True
    bLocalizeCaption = True
    bDrawCaption = True

    Alignment = Align_Center

    ForcedCaptionInfo = 255
}