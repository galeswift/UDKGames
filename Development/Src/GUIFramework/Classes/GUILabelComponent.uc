//=============================================================================
// GUILabelComponent
//
// $wotgreal_dt: 27-11-2012 4:09:13 $
//
// A Label is the representation of plain text on the screen.
// No textures involved, not clickable, not editable.
//=============================================================================
class GUILabelComponent extends GUIComponent;

var() bool bLocalizeString; // If False, draw LabelText directly instead of looking for a replacement from the localization file.

var() protectedwrite byte StringIndex; // Use the LabelText and StringInfo from this index.
var() protectedwrite array<string> LabelText; // Name of the string in the specified localization file.
var() editinline instanced array<GUIStringDrawInfo> StringInfo; // Specifies the properties that the string will be drawn with.


var() GFxMoviePlayer.GFxAlign Alignment; // alignment that can be used


event DrawComponent(Canvas C)
{
    local float X,Y,XL,YL;
    local string DrawString;
    local vector2D BoundScale;

    if (!bEnabled)
        return;

    super.DrawComponent(C);



    if (LabelText[StringIndex] != "")
    {
        // If a custom font is specified use that, else go to default one.
        if (StringIndex < StringInfo.Length && StringInfo[StringIndex] != None)
        {
            if (StringInfo[StringIndex].Font != None)
                C.Font = StringInfo[StringIndex].Font;

            // Wether or not we want to use localized text to be displayed
            if (bLocalizeString)
                DrawString = GetLocalizedString(LabelText[StringIndex]);
            else
                DrawString = LabelText[StringIndex];

            C.TextSize(DrawString, XL, YL, StringInfo[StringIndex].ScaleX, StringInfo[StringIndex].ScaleY);
            BoundScale = StringInfo[StringIndex].GetBoundScale(C, DrawString, GetComponentSize(C));
            GetTextLocation(C, X, Y, XL * BoundScale.X, YL * BoundScale.Y);

            // Let the CaptionInfo take care of drawing, so it can be easily modified.
            StringInfo[StringIndex].DrawString(C, X, Y, DrawString, BoundScale);
        }
        else
        {
            C.Font = ParentScene.GetDefaultFont();

            // Wether or not we want to use localized text to be displayed
            if (bLocalizeString)
                DrawString = GetLocalizedString(LabelText[StringIndex]);
            else
                DrawString = LabelText[StringIndex];

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

final function SetStringIndex(byte Index)
{
    StringIndex = Index;

    OnPropertyChanged(self);
}

final function SetLabelText(coerce string NewText, byte IndexToChange, optional bool SetAsNewIndex)
{
    if (IndexToChange >= LabelText.Length)
        LabelText.Add(1 + LabelText.Length - IndexToChange);

    LabelText[IndexToChange] = NewText;

    if (SetAsNewIndex)
        StringIndex = IndexToChange;

    OnPropertyChanged(self);
}

function PrecacheComponentTextures(Canvas C)
{
    DrawComponent(C);

    super.PrecacheComponentTextures(C);
}


event DeleteGUIComp()
{
    local GUIStringDrawInfo CurInfo;

    foreach StringInfo(CurInfo)
    {
        CurInfo.DeleteInfo();
    }

    StringInfo.Remove(0, StringInfo.Length);

    super.DeleteGUIComp();
}

DefaultProperties
{
    Alignment = Align_Center
    bLocalizeString = True
}