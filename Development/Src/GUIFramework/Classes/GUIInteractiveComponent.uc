//=============================================================================
// GUIInteractiveComponent
//
// $wotgreal_dt: 10/11/2012 2:04:13 AM$
//
// Base class for all components that are clickable in some way.
//
// @ slots:
// 0 = normal
// 1 = hover-selected
// 2 = click-selected
// 3 = pressed
//=============================================================================
class GUIInteractiveComponent extends GUIVisualComponent;

var() string Tooltip; // Tooltip to display when cursor hovers over component.
var() bool bLocalizeTooltip; // Wether or not to localize the tooltip.
var() GUITooltipDrawInfo TooltipDrawInfo; // Defines how to represent the tooltip.

// If specified, a sound will play at the specific event.
var() SoundCue MouseEnteredSound, MouseExitSound, MousePressedSound, MouseReleasedSound;

event InitializeComponent()
{
    super.InitializeComponent();

    if (TooltipDrawInfo != None)
        TooltipDrawInfo.InitializeInfo();
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
}


// Play sounds for the button when specified.
event MouseEntered()
{
    super.MouseEntered();

    if (MouseEnteredSound != None)
        ParentScene.ForwardPlaySound(MouseEnteredSound, True);
}


event MouseExited()
{
    super.MouseExited();

    if (MouseExitSound != None)
        ParentScene.ForwardPlaySound(MouseExitSound, True);
}

event MousePressed(optional byte ButtonNum)
{
    super.MousePressed(ButtonNum);

    if (MousePressedSound != None)
        ParentScene.ForwardPlaySound(MousePressedSound, True);
}

event MouseReleased(optional byte ButtonNum)
{
    super.MouseReleased(ButtonNum);

    if (MouseReleasedSound != None)
        ParentScene.ForwardPlaySound(MouseReleasedSound, True);
}

event DeleteGUIComp()
{
    MouseEnteredSound = none;
    MouseExitSound = none;
    MousePressedSound = none;
    MouseReleasedSound = none;

    if (TooltipDrawInfo != None)
    {
        TooltipDrawInfo.DeleteInfo();
        TooltipDrawInfo = none;
    }

    super.DeleteGUIComp();
}


DefaultProperties
{
    bCanHaveSelection = True // This means hover selection
    bCanBePressed = True
}