//------------------------------------------------------------------------------
// Displays the tooltip as text of a predefined GUILabelComponent
//------------------------------------------------------------------------------
class GUITooltipLabelTextInfo extends GUITooltipDrawInfo;

var() GUILabelComponent LabelComponent;
var() byte LabelIndex;

function DrawTooltip(Canvas C, float PosX, float PosY, string DrawString)
{
    if (LabelComponent != None)
    {
        LabelComponent.SetLabelText(DrawString, LabelIndex, true);
    }
}

event DeleteInfo()
{
    LabelComponent = None;
}

DefaultProperties
{

}