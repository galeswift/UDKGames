//------------------------------------------------------------------------------
// Defines how to draw a given tooltip.
//------------------------------------------------------------------------------
class GUITooltipDrawInfo extends GUIInfo
    abstract;

var() float TooltipDelay; // How long the same hoverselection needs to be focused before tooltip is shown.

/**
 * @param  - C: reference to the Canvas
 * @param  - PosX/Y: mouse coordinates
 * @param  - DrawString: text to draw
 */
function DrawTooltip(Canvas C, float PosX, float PosY, string DrawString);

DefaultProperties
{

}