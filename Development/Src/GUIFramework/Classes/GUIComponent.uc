//=============================================================================
// GUIComponent
//
// $wotgreal_dt: 26.10.2012 16:02:32$
//
// Base class for all components that are used for creating our own menus and
// buttons with UScript.
//
// Hint: Don't confuse the Events in this class with engine events, most are
// just functions that can be used as entry points and are thus named event.
//=============================================================================
class GUIComponent extends Object
    abstract
    editinlinenew
    collapsecategories
    hidecategories(Object);


// If True, process and draw this component otherwise skip it.
// PrivateWrite, so you don't forget to use the Set function for it.
var() privatewrite bool bEnabled;

// You should assign a unique Tag to eeach Component when you create it to find
// it later with GUIMenuScene.FindComponentByTag()
var() string Tag;


// Wether or not the component can be dragged when clicked on
var() bool bCanDrag;
// If True, the component is being dragged
var bool bDragging;
// If True, limits the dragging of the component
var() bool bLimitXAxis, bLimitYAxis;
// Limit relative to the starting position
var() float LimitX, LimitY;
//If True, another Component can be dropped upon this one
var() bool bCanReceiveDrop;
// Canvas Clip, used for resetting the component after a failed drag
var() float ClipX, ClipY;
// Height and Width of the Component
var float Height, Width;
// Start Position of the Component when it is clicked
var float InitialX, InitialY;
// The difference between the mouse position and the component's left-top position (Posx, PosY) when clicked
var float MouseDiffX, MouseDiffY;
// Total drag accumulated
var Vector2D AccumulatedDrag;
// If True, this component will be dropped where released, not only when there is a component below it that can receive the drop
var() bool bNoConnect;
// If this component can receive a drop, this is the class that should be dropped upon it
var() class<GUIVisualComponent> ConnectClass;

var() bool bCallCustomDraw; // If True, Component gets OnCustomDraw called.
var() bool bReceiveText;

var() float PosXAdjust, PosYAdjust;

// This tells where to render the component in the HUD.
var() float PosX, PosY;

// Width and Height are the distance from the start to the end.
var() float PosXEnd, PosYEnd;

// Use relative values instead of absolute ones.
var() bool bRelativePosX, bRelativePosY, bRelativeWidth, bRelativeHeight;

/* If no relative values for PosXEnd or PosYEnd are used, setting this to True
 * will scale those values by the HUD's HUDResolutionScale value.
 *
 * HUDResolutionScale assumes that 1024x768 is the normal HUD size with a value of 1.0
 * Any higher resolution will give you a proper scale value.
 * For instance does 1680/1024 give you 1.640625 and thus you can scale the width of the components by that.
 *
 * So by using this, you simply design your HUD with absolute values in the range of 1024x768 and the scale will do the rest.
 * However, it is highly recommended to use AnchorComponents in conjunction with this as the top left corner wont change with this.
 */
var() bool bUseHUDResScaleX, bUseHUDResScaleY;


// If these are set, the above values will take these as relative locations for ClipX and ClipY instead of the whole window.
// Hard to explain, you will see.
var() GUIComponent AnchorComponentTop, AnchorComponentLeft, AnchorComponentRight, AnchorComponentBottom;

// If True, the "other" side of the Anchor component is used to obtain the values.
// For a component on the left would that be the left side and so on.
var() bool bAnchorTopUseFarAwaySide, bAnchorLeftUseFarAwaySide, bAnchorRightUseFarAwaySide, bAnchorBottomUseFarAwaySide;

// The component with priority 0 will be drawn first and then the others in ascending order on top of it.
// Components with the same priority are drawn in the order they were created.
var() int Priority;

// This is for subclass implementation.
// If True, this component can be focused by a cursor over it / can be selected with a click / can be pressed.
var() bool bCanHaveSelection, bCanHaveClickSelection, bCanBePressed;
var   bool bIsHoverSelected, bIsClickSelected, bIsPressed;

// If True, perform enclosing checks against a circular shape rather than a box.
// This gives a more accurate representation for RadioButtons and similar.
// The diameter of the circle is the height of the Component.
var() bool bCircularComponentShape;

var() bool bDebugComponentFrame;


// A general purpose reference to other GUIComponents. Might be useful to you.
// This also acts as storage reference to temporary Components like
// the GUIComponentModifier while it moves a Component.
var() array<GUIComponent> LinkedComponents;

var() editinline GUISliderManager Window;


var GUIMenuScene ParentScene;






/* Delegates */
// Those are variables that reference functions, just in case you didn't know. ;)
// ButtonNum: 0 = LeftMouse; 1 = RightMouse; 2 = MiddleMouse; 3 = whatever you come up with

delegate OnBecomeEnabled(optional GUIComponent Component = self);
delegate OnBecomeDisabled(optional GUIComponent Component = self);
delegate OnMouseEntered(optional GUIComponent Component = self);
delegate OnMouseExited(optional GUIComponent Component = self);
delegate OnMousePressed(optional GUIComponent Component = self, optional byte ButtonNum);
delegate OnMouseReleased(optional GUIComponent Component = self, optional byte ButtonNum);
delegate OnMouseClicked(optional GUIComponent Component = self, optional byte ButtonNum);
delegate OnMouseWheelUp(optional GUIComponent Component = self);
delegate OnMouseWheelDown(optional GUIComponent Component = self);

// General purpose delegate that gets called by appropriate subclasses when their represented property changes.
// For instance when a slider gets moved or a checkbox gets ticked or a combobox gets a new member selected.
delegate OnPropertyChanged(optional GUIComponent Component = self);

// Allows to override the draw function of this component and draw something on your own.
// You probably don't want to use this in most cases and instead write a new Component for it,
// but it's also a handy entrance point to set some fresh values remotely before the drawing process
// as this is called directly before DrawComponent.
// Return True to stop the normal draw process after this.
delegate bool OnCustomDraw(Canvas C, optional GUIComponent Component = self)
{
    return False;
}

/**
 * Process an input key event routed through unrealscript from another object. This method is assigned as the value for the
 * OnRecievedNativeInputKey delegate so that native input events are routed to this unrealscript function.
 *
 * @param   ControllerId    the controller that generated this input key event
 * @param   Key             the name of the key which an event occured for (KEY_Up, KEY_Down, etc.)
 * @param   EventType       the type of event which occured (pressed, released, etc.)
 * @param   AmountDepressed for analog keys, the depression percent.
 *
 * @return  true to consume the key event, false to pass it on.
 */
delegate bool OnInputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
{
    return False;
}

/* Delegate functions */
// Actually those are not really "delegate functions", but we declare these to have a hook for forwarding the actions.
// And then we implement as default behaviour to call the delegates,
// which can also reference functions on the outside (with same parameters).
// This component is passed as parameter so you know where the call came from.


event BecomeEnabled()
{
    OnBecomeEnabled(self);
}

event BecomeDisabled()
{
    OnBecomeDisabled(self);
}

event MouseEntered()
{
    OnMouseEntered(self);

    bIsHoverSelected = True; // bCanHaveSelection is checked in CheckMouseFocus()
}

event MouseExited()
{
    OnMouseExited(self);

    bIsHoverSelected = False;
}

event MousePressed(optional byte ButtonNum)
{
    OnMousePressed(self, ButtonNum);

    if (bCanBePressed)
        bIsPressed = True;
}

event MouseReleased(optional byte ButtonNum)
{
    OnMouseReleased(self, ButtonNum);

    bIsPressed = False;
}

event MouseClicked(optional byte ButtonNum)
{
    OnMouseClicked(self ,ButtonNum);
}

event MouseWheelUp()
{
    OnMouseWheelUp(self);
}

event MouseWheelDown()
{
    OnMouseWheelDown(self);
}

/**
 * Process an input key event routed through unrealscript from another object. This method is assigned as the value for the
 * OnRecievedNativeInputKey delegate so that native input events are routed to this unrealscript function.
 *
 * @param   ControllerId    the controller that generated this input key event
 * @param   Key             the name of the key which an event occured for (KEY_Up, KEY_Down, etc.)
 * @param   EventType       the type of event which occured (pressed, released, etc.)
 * @param   AmountDepressed for analog keys, the depression percent.
 *
 * @return  true to consume the key event, false to pass it on.
 */
function bool InputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
{
    return OnInputKey(ControllerId,Key,Event,AmountDepressed,bGamepad);
}

/**
 * Process a character input event (typing) routed through unrealscript from another object. This method is assigned as the value for the
 * OnRecievedNativeInputKey delegate so that native input events are routed to this unrealscript function.
 *
 * @param   ControllerId    the controller that generated this character input event
 * @param   Unicode         the character that was typed
 *
 * @return  True to consume the character, false to pass it on.
 */
function bool InputChar( int ControllerId, string Unicode )
{
    return bReceiveText;
}

function SetEnabled(bool bNewEnabled)
{
    if (bNewEnabled == bEnabled)
        return;

    if (bNewEnabled)
    {
        bEnabled = True;
        BecomeEnabled();
    }
    else
    {
        bEnabled = False;
        BecomeDisabled();
    }
}



// Called by the HUD's PostBeginPlay() to give each Component a chance to initialize.
// The ParentScene variable is considered initialized at this point.
event InitializeComponent()
{
    Width = PosXEnd - PosX;
    Height = PosYEnd - PosY;
}

// Draw the component's texture for one frame when the menu is initialized,
// so textures are stored in memory instead of slowly being loaded with low
// resolution when their menu page is drawn for the first time.
function PrecacheComponentTextures(Canvas C);


// Returns the Component that matches the specified Tag.
// Child classes should override this if they handle their own child Components.
function GUIComponent CheckComponentTag(coerce string CompTag)
{
    if (CompTag == Tag)
        return self;

    return none;
}


final function string GetLocalizedString(string KeyName)
{
    return Localize(string(ParentScene.default.class), KeyName, ParentScene.default.LocalizationFileName);
}


// Dynamically determines the top left corner of the Component.
// Takes Canvas clipping, relative position and Anchor Components into account.
function vector2D GetComponentStartPos(Canvas C)
{
    local vector2d Result;
    local float AnchorTempPosA, AnchorTempPosB;

    // Figuring out the X position.
    if (AnchorComponentLeft != None)
    {
        if (bAnchorLeftUseFarAwaySide)
            AnchorTempPosA = AnchorComponentLeft.GetComponentStartPos(C).X;
        else
            AnchorTempPosA = AnchorComponentLeft.GetComponentEndPos(C).X;
    }
    else
        AnchorTempPosA = 0;

    if (AnchorComponentRight != None)
    {
        if (bAnchorRightUseFarAwaySide)
            AnchorTempPosB = AnchorComponentRight.GetComponentEndPos(C).X;
        else
            AnchorTempPosB = AnchorComponentRight.GetComponentStartPos(C).X;
    }
    else
        AnchorTempPosB = ClipX;

    if (bRelativePosX)
    {
        Result.X = AnchorTempPosA + (AnchorTempPosB - AnchorTempPosA) * PosX;
    }
    else
    {
        Result.X = AnchorTempPosA + PosX * bUseHUDResScaleX ? ParentScene.GetScaleX() : 1.0;
    }


    // Figuring out the Y position.
    if (AnchorComponentTop != None)
    {
        if (bAnchorTopUseFarAwaySide)
            AnchorTempPosA = AnchorComponentTop.GetComponentStartPos(C).Y;
        else
            AnchorTempPosA = AnchorComponentTop.GetComponentEndPos(C).Y;
    }
    else
        AnchorTempPosA = 0;

    if (AnchorComponentBottom != None)
    {
        if (bAnchorBottomUseFarAwaySide)
            AnchorTempPosB = AnchorComponentTop.GetComponentEndPos(C).Y;
        else
            AnchorTempPosB = AnchorComponentTop.GetComponentStartPos(C).Y;
    }
    else
        AnchorTempPosB = ClipY;

    if (bRelativePosY)
    {
        Result.Y = AnchorTempPosA + (AnchorTempPosB - AnchorTempPosA) * PosY;
    }
    else
    {
        Result.Y = AnchorTempPosA + PosY * bUseHUDResScaleY ? ParentScene.GetScaleY() : 1.0;
    }

	if(Window != none)
	{
		Result.X += Window.PosXAdjust;
		Result.Y += Window.PosYAdjust;
	}
	Result.X += PosXAdjust;
	Result.Y += PosYAdjust;

    return Result;
}

// Dynamically determines the bottom right corner of the Component.
// Takes Canvas clipping, relative position and Anchor Components into account.
function vector2D GetComponentEndPos(Canvas C)
{
    local vector2d Result;
    local float AnchorTempPosA, AnchorTempPosB;

    // Figuring out the X position.
    if (AnchorComponentLeft != None)
    {
        if (bAnchorLeftUseFarAwaySide)
            AnchorTempPosA = AnchorComponentLeft.GetComponentStartPos(C).X;
        else
            AnchorTempPosA = AnchorComponentLeft.GetComponentEndPos(C).X;
    }
    else
        AnchorTempPosA = 0;

    if (AnchorComponentRight != None)
    {
        if (bAnchorRightUseFarAwaySide)
            AnchorTempPosB = AnchorComponentRight.GetComponentEndPos(C).X;
        else
            AnchorTempPosB = AnchorComponentRight.GetComponentStartPos(C).X;
    }
    else
        AnchorTempPosB = ClipX;

    if (bRelativeWidth)
    {
        Result.X = AnchorTempPosA + (AnchorTempPosB - AnchorTempPosA) * PosXEnd;
    }
    else
    {
        Result.X = AnchorTempPosA + PosXEnd;
    }


    // Figuring out the Y position.
    if (AnchorComponentTop != None)
    {
        if (bAnchorTopUseFarAwaySide)
            AnchorTempPosA = AnchorComponentTop.GetComponentStartPos(C).Y;
        else
            AnchorTempPosA = AnchorComponentTop.GetComponentEndPos(C).Y;
    }
    else
        AnchorTempPosA = 0;

    if (AnchorComponentBottom != None)
    {
        if (bAnchorBottomUseFarAwaySide)
            AnchorTempPosB = AnchorComponentTop.GetComponentEndPos(C).Y;
        else
            AnchorTempPosB = AnchorComponentTop.GetComponentStartPos(C).Y;
    }
    else
        AnchorTempPosB = ClipY;

    if (bRelativePosY)
    {
        Result.Y = AnchorTempPosA + (AnchorTempPosB - AnchorTempPosA) * PosYEnd;
    }
    else
    {
        Result.Y = AnchorTempPosA + PosYEnd;
    }

	if(Window != none)
	{
		Result.X += Window.PosXAdjust;
		Result.Y += Window.PosYAdjust;
	}

	Result.X += PosXAdjust;
	Result.Y += PosYAdjust;

    return Result;
}

// Gets the dynamically determined width and height of the Component as 2D vector.
function vector2D GetComponentSize(Canvas C)
{
    local vector2D Start, End, Result;

    Start = GetComponentStartPos(C);
    End = GetComponentEndPos(C);

    Result.X = End.X - Start.X;
    Result.Y = End.Y - Start.Y;

    return Result;
}

function vector2D GetComponentCenter(Canvas C)
{
    local vector2D Start, End, Result;

    Start = GetComponentStartPos(C);
    End = GetComponentEndPos(C);

    Result.X = (End.X - Start.X)/2 + Start.X;
    Result.Y = (End.Y - Start.Y)/2 + Start.Y;

    return Result;
}


// Returns a numerical representation of the value that the component represents.
function float GetComponentValue();

//------------------------------------------------------------------------------
/**
 * The main function of the component that gets called by the HUD's PostRender().
 *
 * Every component should draw itself here when necessary.
 * The base implementation draws a debug frame.
 */
event DrawComponent(Canvas C)
{
    local Vector2D DraggedPos;
    if (!bEnabled)
        return;

    ClipX = C.ClipX;
    ClipY = C.ClipY;

    if (bDragging)
    {
        DraggedPos.X = ParentScene.MousePos.X;
        DraggedPos.Y = ParentScene.MousePos.Y;
        Dragged(DraggedPos);
    }
}

// Separated from normal DrawComponent so we can garantee that it's at least
// called in every subclass.
event DrawDebugComponent(Canvas C)
{
    local vector2d Start, End;

    if (!bEnabled)
        return;

    if (bDebugComponentFrame)
    {
        Start = GetComponentStartPos(C);
        End = GetComponentEndPos(C);

        C.SetPos(Start.X, Start.Y);
        C.DrawBox(End.X - Start.X, End.Y - Start.Y);
    }
}

// Gives Components a chance to draw itself or at least set some custom parameters.
// This is called immediately before DrawComponent
// if True is returned, DrawComponent is skipped after this.
event bool CustomDrawComponent(Canvas C)
{
    return OnCustomDraw(C, self);
}
//------------------------------------------------------------------------------

/**
 * Gives the components a chance to update based on mouse actions.
 *
 * @param MouseX/MouseY: the current position of the mouse cursor.
 * @param BestPriority: the best priority of all found components is passed
 *   recursively and only if the priority of the checked object is equal or higher,
 *   it will return the checked object.
 * @return value: if this component is in the focus area of the mouse cursor
 *   the function returns the topmost component on the stack by also recursively
 *   checking child components of this component.
 */
function GUIComponent CheckMouseFocus(Canvas C, int MouseX, int MouseY, out int BestPriority)
{
    local GUIComponent FocusComponent;

    if (bCanHaveSelection && Priority >= BestPriority && IsEnclosedByMe(C, MouseX, MouseY))
        FocusComponent = self;

    return FocusComponent;
}

// Returns True if X and Y form a point that is within this component.
function bool IsEnclosedByMe(Canvas C, float PointX, float PointY)
{
    local vector2d Start, End, Size;
    local vector Median, In;

    Start = GetComponentStartPos(C);
    End = GetComponentEndPos(C);

    if (!bCircularComponentShape)
    {
        if ((PointX >= Start.X && PointX <= End.X) &&
             PointY >= Start.Y && PointY <= End.Y)
             return True;

        return False;
    }
    else
    {
        Size = GetComponentSize(C);

        Median.X = Start.X + Size.X/2;
        Median.Y = Start.Y + Size.Y/2;

        In.X = PointX;
        In.Y = PointY;

        if (VSize2D(Median - In) > Size.Y)
            return False;
        return True;
    }
}

// used to give the component a new position
function SetPos(Vector2D NewPos)
{
    // make sure Width and Height are non-zero
    // else components would appear disabled
    if(Width == 0)
        Width = PosXEnd - PosX;
    if(Height == 0)
        Height = PosYEnd - PosY;
    PosY = NewPos.Y;
    PosX = NewPos.X;
    PosXEnd = PosX + Width;
    PosYEnd = PosY + Height;
}


function MoveComponent(Canvas C, float MoveTime, float NewX, float NewY, optional float NewEndX = -1, optional float NewEndY = -1, optional byte MovementType)
{
    local GUIComponent Cur;
    local GUIComponentModifier CompMod;
    local vector2D Size;

    foreach LinkedComponents(Cur)
    {
        if (GUIComponentModifier(Cur) != None)
        {
            CompMod = GUIComponentModifier(Cur);
            break;
        }
    }

    if (CompMod == None)
    {
        CompMod = new(self) class'GUIComponentModifier';
        LinkedComponents.AddItem(CompMod); // Add to keep a reference and prevent GC.
    }

    if (NewEndX == -1 || NewEndY == -1)
    {
        Size = GetComponentSize(C);

        if (NewEndX == -1)
            NewEndX = NewX + Size.X;
        if (NewEndY == -1)
            NewEndY = NewY + Size.Y;
    }

    if (MovementType == 0)
        CompMod.MoveContainerLinear(NewX, NewY, NewEndX, NewEndY, MoveTime);
    else
        CompMod.MoveContainerSine(NewX, NewY, NewEndX, NewEndY, MoveTime);
}

// Called when a Component successfully finishes a move with MoveComponent().
event ComponentMoved(GUIComponentModifier Mover)
{
    Mover.DeleteGUIComp();
    LinkedComponents.RemoveItem(Mover);
}

// The component is being dragged
event Dragged(Vector2D NewPos)
{

    if(bRelativePosX)
    {
        if(bLimitXAxis)
            PosX = Fclamp(NewPos.X / ClipX - MouseDiffX, default.PosX - LimitX, default.PosX + LimitX);
        else
            PosX = NewPos.X / ClipX - MouseDiffX;
    }
    else
    {
        if(bLimitXAxis)
            PosX = Fclamp(NewPos.X - MouseDiffX, default.PosX - LimitX, default.PosX + LimitX);
        else
            PosX = NewPos.X - MouseDiffX;
    }
    if(bRelativePosY)
    {
        if(bLimitYAxis)
            PosY = Fclamp(NewPos.Y / ClipY - MouseDiffY, default.PosY - LimitY, default.PosY + LimitY);
        else
            PosY = NewPos.Y / ClipY - MouseDiffY;
    }
    else
    {
        if(bLimitYAxis)
            PosY = Fclamp(NewPos.Y - MouseDiffY, default.PosY - LimitY, default.PosY + LimitY);
        else
            PosY = NewPos.Y - MouseDiffY;
    }

    PosXEnd = PosX + Width;
    PosYEnd = PosY + Height;

    AccumulatedDrag.X = PosX - default.PosX;
    AccumulatedDrag.Y = PosY - default.PosY;
}

// Called when a Component (DroppedComponent) is dropped upon this one
event DroppedOn(GUIComponent DroppedComponent)
{
    if (!ClassIsChildOf(DroppedComponent.Class, ConnectClass)) // Should consider child classes too, if someone wants to have more structure through derivation.
        DroppedComponent.DragFailed();
}

// Called when this Component is dropped upon another one (OnComponent)
event Dropped(GUIComponent OnComponent)
{
    if (!OnComponent.bCanReceiveDrop)
    {
        DragFailed();
    }
    else
        OnComponent.DroppedOn(self);
}

// Called when this Component is dropped and bNoConnect is True
event SpecialDrop();

// The dragging failed, return to position before dragging
event DragFailed()
{
    if (bRelativePosX)
        PosX = InitialX;
    else
        PosX = InitialX / ClipX;

    PosXEnd = PosX + Width;

    if (bRelativePosY)
        PosY = InitialY;
    else
        PosY = InitialY / ClipY;

    PosYEnd = PosY + Height;
}

// used when the component is no longer selected (from a click) because the menu has closed.
function HardClose();

// Called by the MenuScene when it's about to get unreferenced by the HUD for GC.
// Use this to clean any object references up to prevent errors.
event DeleteGUIComp()
{
    AnchorComponentTop = none;
    AnchorComponentLeft = none;
    AnchorComponentRight = none;
    AnchorComponentBottom = none;

    LinkedComponents.Remove(0, LinkedComponents.Length);

    OnBecomeEnabled = none;
    OnBecomeDisabled = none;
    OnInputKey = none;
    OnMouseClicked = none;
    OnMouseEntered = none;
    OnMouseExited = none;
    OnMousePressed = none;
    OnMouseReleased = none;
    OnMouseWheelUp = none;
    OnMouseWheelDown = none;

    ParentScene = none;
}

DefaultProperties
{
    bEnabled = True

    bRelativePosX = True // Relative means that we use the range 0.0 - 1.0.
    bRelativePosY = True // If it would be false, we would use absolute pixel values. These are the values for the top-left corner.
    bRelativeWidth = True // If it's true, the component will end at PosXYEnd(0.6) of the whole screen size in that direction.
    bRelativeHeight = True // If it would be false, the component would be PosXYEnd (0.6) pixels tall (which means it wouldn't be visible at all).

    bUseHUDResScaleX = True
    bUseHUDResScaleY = True

    Priority = 1
}