//=============================================================================
// GUIComboBoxComponent
//
// $wotgreal_dt: 23.11.2012 1:58:41 $
//
// A clickable component with a caption that opens a dropdown menu with multiple
// entries upon being selected.
//
// @ slots:
// 0 = normal
// 1 = hover-selected
// 2 = click-selected
// 3 = pressed
//=============================================================================
class GUIComboBoxComponent extends GUIButtonComponent;

var() array<string> ItemList; // Entries in the dropdown box.
var() color BackgroundColor, SelectedBackgroundColor; // color of the dropdown box background.
var() color SelectedItemCaptionColor; // color for the selected caption. The rest is the same as ItemCaptionInfo.
var() GUIStringDrawInfo ItemCaptionInfo; // CaptionInfo of the items in the dropdown box.

var float YExtension; // Tells us the height of a single dropdown entry.
var vector2D LastCursorPosition; // We need to remember this to check on which entry of the dropdown box the cursor is.
var int SelectedItemIndex; // Index of the currently selected item.

function DrawCaption(Canvas C, optional byte DrawIndex)
{
    local float X,Y,XL,YL, YEnd;
    local string DrawString;
    local vector2D BoundScale;
    local int i;
    local color BackupColor;

    super.DrawCaption(C, DrawIndex);

    if (bIsClickSelected && ItemList.Length > 0)
    {
        YEnd = GetComponentEndPos(C).Y;

        for (i = 0; i < ItemList.Length; i++)
        {
            // If a custom font is specified use that, else go to default one.
            if (ItemCaptionInfo != None)
            {
                if (ItemCaptionInfo.Font != None)
                    C.Font = ItemCaptionInfo.Font;

                // Wether or not we want to use localized text to be displayed
                if (bLocalizeCaption)
                    DrawString = GetLocalizedString(ItemList[i]);
                else
                    DrawString = ItemList[i];

                C.TextSize(DrawString, XL, YL, ItemCaptionInfo.ScaleX, ItemCaptionInfo.ScaleY);
                BoundScale = ItemCaptionInfo.GetBoundScale(C, DrawString, GetComponentSize(C));
                GetTextLocation(C, X, Y, XL * BoundScale.X, YL * BoundScale.Y);
                Y = YEnd + i * (YL * BoundScale.Y);

                YExtension = YL + 2; // Making it a bit bigger to have some tolerance.

                if (IsSelectedItem(X, XL, YEnd + (YExtension * i), YExtension))
                {
                    SelectedItemIndex = i;

                    C.SetPos(X, Y);
                    C.SetDrawColorStruct(SelectedBackgroundColor);
                    C.DrawRect(XL, YExtension);

                    BackupColor = ItemCaptionInfo.DrawColor;
                    ItemCaptionInfo.DrawColor = SelectedItemCaptionColor;
                    ItemCaptionInfo.DrawString(C, X, Y, DrawString, BoundScale);
                    ItemCaptionInfo.DrawColor = BackupColor;
                }
                else
                {
                    C.SetPos(X, Y);
                    C.SetDrawColorStruct(BackgroundColor);
                    C.DrawRect(XL, YExtension);

                    ItemCaptionInfo.DrawString(C, X, Y, DrawString, BoundScale);
                }
            }
            else
            {
                //TODO: Make this work.

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
}

// Returns True if X and Y form a point that is within this component.
// Modified to also take the dropdown box into account if it's open.
function bool IsEnclosedByMe(Canvas C, float PointX, float PointY)
{
    local vector2d Start, End;

    Start = GetComponentStartPos(C);
    End = GetComponentEndPos(C);
    if (bIsClickSelected)
        End.Y += (YExtension * ItemList.Length);

    if (PointX >= Start.X && PointX <= End.X && PointY >= Start.Y && PointY <= End.Y)
    {
        LastCursorPosition.X = PointX;
        LastCursorPosition.Y = PointY;
        return True;
    }

    return False;
}

// Y coordinates should be the item box and not the entire component.
final function bool IsSelectedItem(float X, float Y, float XL, float YL)
{
    return LastCursorPosition.X >= X && LastCursorPosition.X <= X + XL &&
        LastCursorPosition.Y >= Y && LastCursorPosition.Y <= Y + YL;
}

DefaultProperties
{
    bCanHaveClickSelection = true // Dropdown is activated while the component is click-selected
}