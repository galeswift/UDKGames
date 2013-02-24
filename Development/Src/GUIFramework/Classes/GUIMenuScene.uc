//=============================================================================
// GUIMenuScene
//
// $wotgreal_dt: 10/11/2012 2:05:15 AM$
//
// Holds references for all GUIComponents and wraps more of the GUI-related
// functionality to separate it a bit from the HUD class.
//=============================================================================
class GUIMenuScene extends Object
    editinlinenew
    abstract;

/* GUI Components */

// Holds all GUIComponents that will be drawn.
var() editinline instanced array<GUIComponent> GUIComponents;

// Keeps track of GUIPage order to allow pushing and popping of them to handle automated disabling and enabling.
var() privatewrite array<GUIPage> GUIPageStack;
var() bool bAlwaysKeepLastStackPage;

// If True, let each GUIComponent draw itself onto the Canvas.
// Disable this if you are ingame and don't need the Components to save some performance.
var() bool bDrawGUIComponents;

// A reference to the topmost GUIComponent under the cursor or none if the cursor doesn't hit any.
var() GUIComponent HoverSelection;

// Last time the hover selection changed.
var   float LastHoverUpdateTime;

// A reference to the GUIComponent where the cursor was when the mouse button was pressed.
// This can be used to check if a click on the component was performed or if the button was released somewhere else.
var() GUIComponent ClickedSelection;

// A reference to the component that will receive the key input when there is no clicked selection.
var GUIComponent DefaultInputComponent;


var string LocalizationFileName;


/* Mouse cursor */

// This is a major variable! It affects whether mouse inputs are passed to either the HUD cursor or the player in the game.
// When this is False does the mouse affect the cursor location and the mouse wheel and buttons are interpreted by the HUD,
// when it is True does the mouse affect the camera rotation and mouse wheel and buttons will perform the usual player actions.
var() bool bCaptureMouseInput;

var Texture2D CursorTexture, SelectionCursorTexture;
var() Color CursorColor, SelectionCursorColor, TooltipBackgroundColor;

// The current coordinates of the mouse cursor.
var IntPoint MousePos, LastMouse;

// Don't draw the cursor. Mabye because the player uses keys for menu navigation atm.
var() bool bHideCursor;
var() bool bUnhideCursorOnMouseMove;


var() bool bDragDebug; // Shows additional drag information for testing.


/* Mouse input handling */

// Pending left mouse button pressed event
var bool PendingLeftPressed;
// Pending left mouse button released event
var bool PendingLeftReleased;
// Pending right mouse button pressed event
var bool PendingRightPressed;
// Pending right mouse button released event
var bool PendingRightReleased;
// Pending middle mouse button pressed event
var bool PendingMiddlePressed;
// Pending middle mouse button released event
var bool PendingMiddleReleased;
// Pending mouse wheel scroll up event
var bool PendingScrollUp;
// Pending mouse wheel scroll down event
var bool PendingScrollDown;


/* Key input handling */

// Hardcoded keys that will act as confirm or abort on the menu and are intercepted by it.
var() array<name> MenuConfirmKeys, MenuAbortKeys, MenuUpKeys, MenuDownKeys, MenuLeftKeys, MenuRightKeys;

// If True, capture the MenuKeys mentioned above and direct them to the Key Input.
var() bool bCaptureKeyInput;

var bool bPrecachedTextures; // True after precaching textures once.

var vector2D CachedViewportSize; // Cached screen resolution from GameViewportClient.

var GUICompatibleHUD OwnerHUD; // The HUD that holds this MenuScene.'
                               // Easier to access for GUIComponents than the "Outer".

var GUIScriptedTextureHandler GUISTH; // Reference to the ScriptedTextureHandler, as opposed to the HUD.


var bool bIsScriptedTextureMenuScene; // If True, this MenuScene is used in a ScriptedTexture and not in a HUD.
                                            // Set in DefaultProperties.



// Returns a component that has been created as subobject with matching name.
final function GUIComponent FindComponentByTag(string ComponentTag)
{
    local GUIComponent Comp, Result;

    if (ComponentTag == "")
        return None;

    foreach GUIComponents(Comp)
    {
        Result = Comp.CheckComponentTag(ComponentTag);
        if (Result != None)
            return Result;
    }

    return none;
}

// Triggers all GUIEvent_MenuAction events in Kismet that have their ActivationTag set to this EventTag.
final static function TriggerMenuKismetEvents(string EventTag)
{
    local array<SequenceObject> EventsToActivate;
    local Sequence GameSeq;
    local int i;

    GameSeq = class'WorldInfo'.static.GetWorldInfo().GetGameSequence();
    if (GameSeq != None)
    {
        GameSeq.FindSeqObjectsByClass(class'GUIEvent_MenuAction', true, EventsToActivate);
        for (i = 0; i < EventsToActivate.length; i++)
        {
            if (GUIEvent_MenuAction(EventsToActivate[i]).ActivationTag ~= EventTag)
            {
                GUIEvent_MenuAction(EventsToActivate[i]).ForceActivateOutput(0);
            }
        }
    }
}

final function PushPage(GUIPage Page, optional bool bUseAsDefaultInput = True)
{
    if (Page != None)
    {
        if (GUIPageStack.Length > 0)
            GUIPageStack[GUIPageStack.Length - 1].SetEnabled(false); // Disable old top.
        GUIPageStack.AddItem(Page); // Push new page to top.
        Page.SetEnabled(True); // Enable new top.
        if(bUseAsDefaultInput)
            DefaultInputComponent = Page;
    }
}

final function PopPage(optional GUIComponent NewDefaultInputComponent)
{
    if (GUIPageStack.Length > (bAlwaysKeepLastStackPage ? 1 : 0))
    {
        GUIPageStack[GUIPageStack.Length - 1].SetEnabled(false); // Disable old top.
        GUIPageStack.Remove(GUIPageStack.Length - 1, 1); // Remove old top.

        if (GUIPageStack.Length > 0)
            GUIPageStack[GUIPageStack.Length - 1].SetEnabled(true); // Enable what was below the old top.
    }
    else
    {
        PoppedLastPage();
    }

    if (NewDefaultInputComponent != none)
        DefaultInputComponent = NewDefaultInputComponent;
}

// If bAlwaysKeepLastStackPage is True, this is called when PopPage is called
// and only one page is left on the stack.
// If it is False, this is called when no page is left on the stack and PopPage
// is called.
event PoppedLastPage();

event InitMenuScene()
{
    local GUIComponent Comp;

    if (bIsScriptedTextureMenuScene)
    {
        GUISTH = GUIScriptedTextureHandler(Outer);
    }
    else
    {
        OwnerHUD = GUICompatibleHUD(Outer);
    }

    foreach GUIComponents(Comp)
    {
        Comp.ParentScene = self;
        Comp.InitializeComponent();

        if (Comp.bEnabled)
        {
            if (GUIPage(Comp) != None)
                PushPage(GUIPage(Comp));
            Comp.OnBecomeEnabled(Comp);
        }
    }
}


event RenderScene(Canvas C)
{
    local GUIComponent Comp;

    if (!bPrecachedTextures)
    {
        foreach GUIComponents(Comp)
        {
            Comp.PrecacheComponentTextures(C);
        }
        bPrecachedTextures = True;
    }

    if (bDragDebug && ClickedSelection != none)
    {
        //add your debug stuff here
        C.SetPos(0,0);
        C.DrawText(clickedselection.PosX $"   "$ ClickedSelection.PosY);
        C.SetPos(0,16);
        C.DrawText(MousePos.X/C.ClipX $"   "$ MousePos.Y/C.ClipY);
    }

    if (bDrawGUIComponents)
    {
        foreach GUIComponents(Comp)
        {
            Comp.DrawDebugComponent(C);
            if (!Comp.bCallCustomDraw || !Comp.CustomDrawComponent(C)) // Lazy evaluation magic.
                Comp.DrawComponent(C);
        }
    }


    // Make sure the cursor is the last thing to be drawn so it's on top of other components!
    if (bCaptureMouseInput)
    {
        UpdateMouseCoordinates();

        if (!bHideCursor)
        {
            UpdateHoverSelection(C); // Which GUIComponent is under the mouse cursor right now?

            UpdateMouseInput(); // Tell the GUIComponent under the cursor if it got clicked.

            DrawCursor(C, MousePos.X, MousePos.Y, HoverSelection != None); // Draw the cursor on top.
        }
    }
}

function UpdateMouseCoordinates()
{
    // A bit overhead but also useful to calculate the cursor speed and magnitude of a movement.
    if (MousePos.X != LastMouse.X || MousePos.Y != LastMouse.Y)
    {
        if (bUnhideCursorOnMouseMove)
            bHideCursor = False; // Player moved the mouse, so make it active again.

        LastMouse = MousePos;
    }
}


// Processes the pressed mouse buttons and routes them to the active components.
function UpdateMouseInput()
{
    if (HoverSelection != None || ClickedSelection != None)
    {
        // Handle left mouse button
        if (PendingLeftPressed)
        {
            if (PendingLeftReleased)
            {
                // This is a left click, so discard
                PendingLeftPressed = false;
                PendingLeftReleased = false;
                if (HoverSelection != none && HoverSelection.bEnabled)
                    HoverSelection.MouseClicked();
            }
            else
            {
                // Left is pressed
                PendingLeftPressed = false;
                if (HoverSelection != none && HoverSelection.bEnabled)
                {
                    ClickedSelection = HoverSelection;
                    ClickedSelection.MousePressed();
                }
            }
        }
        else if (PendingLeftReleased)
        {
            // Left is released
            PendingLeftReleased = false;
            if (ClickedSelection != None && ClickedSelection.bEnabled)
            {
                if (ClickedSelection.bDragging)
                {
                    if(ClickedSelection.bNoConnect)
                        ClickedSelection.SpecialDrop();
                    else if (HoverSelection != None)
                        ClickedSelection.Dropped(HoverSelection);
                    else
                        ClickedSelection.DragFailed();

                    ClickedSelection.MouseReleased();
                }
                if(HoverSelection == ClickedSelection)
                    ClickedSelection.MouseReleased();
                else
                    ClickedSelection.bIsPressed = False;
            }
        }

        // Handle right mouse button
        if (PendingRightPressed)
        {
            if (PendingRightReleased)
            {
                // This is a right click, so discard
                PendingRightPressed = false;
                PendingRightReleased = false;
                if(HoverSelection != none && HoverSelection.bEnabled)
                    HoverSelection.MouseClicked(1);
            }
            else
            {
                // Right is pressed
                PendingRightPressed = false;
                if (HoverSelection != none && HoverSelection.bEnabled)
                {
                    ClickedSelection = HoverSelection;
                    ClickedSelection.MousePressed(1);
                }
            }
        }
        else if (PendingRightReleased)
        {
            // Right is released
            PendingRightReleased = false;
            if (HoverSelection != None && HoverSelection.bEnabled)
            {
                HoverSelection.MouseReleased(1);

                if (ClickedSelection == HoverSelection)
                    ClickedSelection.MouseClicked(1);
            }
        }

        // Handle middle mouse button
        if (PendingMiddlePressed)
        {
            if (PendingMiddleReleased)
            {
                // This is a middle click, so discard
                PendingMiddlePressed = false;
                PendingMiddleReleased = false;
                if(HoverSelection != none && HoverSelection.bEnabled)
                    HoverSelection.MouseClicked(2);
            }
            else
            {
                // Middle is pressed
                PendingMiddlePressed = false;
                ClickedSelection = HoverSelection;
                if(ClickedSelection != none && ClickedSelection.bEnabled)
                    ClickedSelection.MousePressed(2);
            }
        }
        else if (PendingMiddleReleased)
        {
            PendingMiddleReleased = false;
            if (HoverSelection != None && HoverSelection.bEnabled)
            {
                HoverSelection.MouseReleased(2);

                if (ClickedSelection == HoverSelection)
                    ClickedSelection.MouseClicked(2);
            }
        }

        // Handle middle mouse button scroll up
        if (PendingScrollUp)
        {
            PendingScrollUp = false;
            if (HoverSelection != None && HoverSelection.bEnabled)
                HoverSelection.MouseWheelUp();
        }

        // Handle middle mouse button scroll down
        if (PendingScrollDown)
        {
            PendingScrollDown = false;
            if (HoverSelection != None && HoverSelection.bEnabled)
                HoverSelection.MouseWheelDown();
        }
    }
}


// Sets the HoverSelection to the topmost GUIComponent, taking priority of the components into account.
function UpdateHoverSelection(Canvas C)
{
    local int BestPriority;
    local GUIComponent NewSelection, Result, Comp;

    foreach GUIComponents(Comp)
    {
        if (!Comp.bEnabled)
            continue;

        Result = Comp.CheckMouseFocus(C, MousePos.X, MousePos.Y, BestPriority);
        if (Result != None)
        {
            if (ClickedSelection != None)
            {
                if (Result != ClickedSelection || !ClickedSelection.bDragging)
                    NewSelection = Result;
            }
            else
                NewSelection = Result;
        }
    }

    if (HoverSelection != NewSelection)
    {
        LastHoverUpdateTime = class'WorldInfo'.static.GetWorldInfo().TimeSeconds;

        if (HoverSelection != None)
            HoverSelection.MouseExited();

        HoverSelection = NewSelection;

        if (NewSelection != None)
            NewSelection.MouseEntered();
    }
}


//------------------------------------------------------------------------------
// Getter functions for our GUIComponents, to accomodate that we can either be
// used by a HUD or a ScriptedTexture.

// Just in case someone needs it. Although it would be better to have an average value for all the time.
final function float GetMouseSpeedPerFrame()
{
    local Vector OldPos, NewPos;

    OldPos.X = LastMouse.X;
    OldPos.Y = LastMouse.Y;
    NewPos.X = MousePos.X;
    NewPos.Y = MousePos.Y;

    return VSize2D(OldPos - NewPos);
}

// Returns the relative scale of the HUD compared to a 1024x768 HUD.
function float GetScaleX()
{
    if (!bIsScriptedTextureMenuScene && OwnerHUD != None)
        return OwnerHUD.ResolutionScaleX;

    return 1;
}

function float GetScaleY()
{
    if (!bIsScriptedTextureMenuScene && OwnerHUD != None)
        return OwnerHUD.ResolutionScale;

    return 1;
}

// Get the current width of the targeted Canvas.
function int GetScreenSizeX()
{
    if (bIsScriptedTextureMenuScene)
    {
        if (GUISTH != None)
            return GUISTH.ScriptedTextureResolution.X;
    }
    else
    {
        if (OwnerHUD != None && OwnerHUD.SizeX != 0.f)
            return OwnerHUD.SizeX;
        else
            return CachedViewportSize.X;
    }

    return 1024;
}

// Get the current height of the targeted Canvas.
function int GetScreenSizeY()
{
    if (bIsScriptedTextureMenuScene)
    {
        if (GUISTH != None)
            return GUISTH.ScriptedTextureResolution.Y;
    }
    else
    {
        if (OwnerHUD != None && OwnerHUD.SizeY != 0.f)
            return OwnerHUD.SizeY;
        else
            return CachedViewportSize.Y;
    }

    return 1024;
}

// Returns WorldInfo.TimeSeconds.
final function float GetWorldTime()
{
    return class'WorldInfo'.static.GetWorldInfo().TimeSeconds;
}

// Returns time since last render update.
final function float GetRenderDelta()
{
    if (bIsScriptedTextureMenuScene)
    {
        if (GUISTH != None)
            return GUISTH.RenderDelta;
    }
    else
    {
        if (OwnerHUD != None)
            return OwnerHUD.RenderDelta;
    }

    return 0.0166;
}

// Returns a font to be used if the Component doesn't specify one itself.
final function Font GetDefaultFont()
{
    if (bIsScriptedTextureMenuScene)
    {
        if (GUISTH != None)
            return GUISTH.DefaultFont;
    }
    else
    {
        if (OwnerHUD != None)
            return OwnerHUD.PlayerFont;
    }

    return Font'EngineFonts.SmallFont';
}

// We are an Object and can't call PlaySound ourselves, so we forward it to our Outer actors.
final function ForwardPlaySound(SoundCue InSoundCue, optional bool bNotReplicated, optional bool bNoRepToOwner, optional bool bStopWhenOwnerDestroyed, optional vector SoundLocation, optional bool bNoRepToRelevant)
{
    if (bIsScriptedTextureMenuScene)
    {
        if (GUISTH != None)
            GUISTH.PlaySound(InSoundCue, bNotReplicated, bNoRepToOwner, bStopWhenOwnerDestroyed, SoundLocation, bNoRepToRelevant);
    }
    else
    {
        if (OwnerHUD != None)
            OwnerHUD.PlaySound(InSoundCue, bNotReplicated, bNoRepToOwner, bStopWhenOwnerDestroyed, SoundLocation, bNoRepToRelevant);
    }
}



// Draws the mouse cursor.
function DrawCursor(Canvas C, float PosX, float PosY, optional bool bHasSelection)
{
    C.SetPos(PosX, PosY);

    if (bHasSelection)
    {
        // Set the cursor color
        C.DrawColor = SelectionCursorColor;
        // Draw the texture on the screen
        C.DrawTile(SelectionCursorTexture, SelectionCursorTexture.SizeX, SelectionCursorTexture.SizeY,
                   0.f, 0.f, SelectionCursorTexture.SizeX, SelectionCursorTexture.SizeY,, true);

        DrawTooltip(C, PosX, PosY);
    }
    else
    {
        // Set the cursor color
        C.DrawColor = CursorColor;
        // Draw the texture on the screen
        C.DrawTile(CursorTexture, CursorTexture.SizeX, CursorTexture.SizeY,
                   0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, true);
    }
}


// Checks if there is a tooltip to be drawn at the mouse location.
function DrawTooltip(Canvas C, float PosX, float PosY)
{
    local GUIInteractiveComponent IComp;
    local string TooltipText;

    IComp = GUIInteractiveComponent(HoverSelection);
    if (IComp != None)
    {
        if (IComp.Tooltip != "" && IComp.TooltipDrawInfo != None && class'WorldInfo'.static.GetWorldInfo().TimeSeconds - LastHoverUpdateTime > IComp.TooltipDrawInfo.TooltipDelay)
        {
            if (IComp.bLocalizeTooltip)
                TooltipText = IComp.GetLocalizedString(IComp.Tooltip);
            else
                TooltipText = IComp.Tooltip;

            IComp.TooltipDrawInfo.DrawTooltip(C, PosX, PosY, TooltipText);
        }
    }
}

event MenuOpened();

event MenuClosed()
{
    if (ClickedSelection != none)
    {
        if (ClickedSelection.bCanDrag && ClickedSelection.bDragging)
        {
            ClickedSelection.DragFailed();
            ClickedSelection.bDragging = False;
        }
        ClickedSelection.bIsPressed = False;
        ClickedSelection.HardClose();
        ClickedSelection = None;
    }
    if (HoverSelection != none)
    {
        HoverSelection.MouseExited();
        HoverSelection = None;
    }
}

// Called when one of the MenuConfirmKeys is used. (EventType specified if released or pressed)
event MenuConfirmKeyEvent(optional EInputEvent EventType)
{
    if (OwnerHUD != None && GUICompatiblePlayerController(OwnerHUD.PlayerOwner) != None)
    {
        GUICompatiblePlayerController(OwnerHUD.PlayerOwner).HandleMouseInput(LeftMouseButton, EventType);
    }
}

// Called when one of the MenuAbortKeys is used. (EventType specified if released or pressed)
event MenuAbortKeyEvent(optional EInputEvent EventType)
{
    if (EventType == IE_Released)
        PopPage();
}

event MenuUpKeyEvent(optional EInputEvent EventType);
event MenuDownKeyEvent(optional EInputEvent EventType);
event MenuLeftKeyEvent(optional EInputEvent EventType);
event MenuRightKeyEvent(optional EInputEvent EventType);


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
    local name MenuKey;
    local bool Result;

    if (!bDrawGUIComponents)
        return False;

    if (ClickedSelection != none)
    {
        Result = ClickedSelection.InputKey(ControllerID,Key,Event,AmountDepressed,bGamepad);
        if (Result)
            return True;
    }
    if (DefaultInputComponent != None && DefaultInputComponent.bEnabled)
    {
        Result = DefaultInputComponent.InputKey(ControllerID,Key,Event,AmountDepressed,bGamepad);
        if (Result)
            return True;
    }

    // We want the MenuScene to handle some special keys that are defined in the DefaultProperties.
    if (bCaptureKeyInput)
    {
        if (Event != IE_Axis)
        {
            foreach MenuConfirmKeys(MenuKey)
            {
                if (MenuKey == Key)
                {
                    MenuConfirmKeyEvent(Event);
                    return True;
                }
            }

            foreach MenuAbortKeys(MenuKey)
            {
                if (MenuKey == Key)
                {
                    MenuAbortKeyEvent(Event);
                    return True;
                }
            }

            foreach MenuUpKeys(MenuKey)
            {
                if (MenuKey == Key)
                {
                    MenuUpKeyEvent(Event);
                    return True;
                }
            }

            foreach MenuDownKeys(MenuKey)
            {
                if (MenuKey == Key)
                {
                    MenuDownKeyEvent(Event);
                    return True;
                }
            }

            foreach MenuLeftKeys(MenuKey)
            {
                if (MenuKey == Key)
                {
                    MenuLeftKeyEvent(Event);
                    return True;
                }
            }

            foreach MenuRightKeys(MenuKey)
            {
                if (MenuKey == Key)
                {
                    MenuRightKeyEvent(Event);
                    return True;
                }
            }
        }
        else
        {
            //TODO: Handle axis keys separately to derive a direction from them.
        }
    }

    return False;
}

final function NewCursor(optional Texture2D NewCursorTexture)
{
    if (NewCursorTexture != none)
        CursorTexture = NewCursorTexture;
    else
        CursorTexture = default.CursorTexture;
}

// Called by GUIHUD.Destroyed() to give the MenuScene a chance to manually
// delete references to it's Components to prevent memory leaks with the GC.
event DeleteMenuScene()
{
    local GUIComponent Cur;

    foreach GUIComponents(Cur)
    {
        Cur.DeleteGUIComp();
    }

    GUIComponents.Remove(0, GUIComponents.Length);
    GUIPageStack.Remove(0, GUIPageStack.Length);

    ClickedSelection = None;
    HoverSelection = None;
    DefaultInputComponent = none;

    CursorTexture = None;
    SelectionCursorTexture = None;

    OwnerHUD = None;
    GUISTH = None;
}

DefaultProperties
{
    bDrawGUIComponents = True
    bAlwaysKeepLastStackPage = True

    MenuConfirmKeys[0] = Enter
    MenuConfirmKeys[1] = XboxTypeS_A
    MenuConfirmKeys[2] = LeftMouseButton
    MenuAbortKeys[0] = Escape
    MenuAbortKeys[1] = XboxTypeS_B
    MenuUpKeys[0] = Up
    MenuUpKeys[1] = XboxTypeS_DPad_Up
    MenuDownKeys[0] = Down
    MenuDownKeys[1] = XboxTypeS_DPad_Down
    MenuLeftKeys[0] = Left
    MenuLeftKeys[1] = XboxTypeS_DPad_Left
    MenuRightKeys[0] = Right
    MenuRightKeys[1] = XboxTypeS_DPad_Right

    MousePos = (X=500,Y=300)
    CursorColor=(R=255,G=255,B=255,A=255)
    CursorTexture=Texture2D'EngineResources.Cursors.Arrow'
    SelectionCursorColor=(R=255,G=255,B=255,A=255)
    SelectionCursorTexture=Texture2D'EngineResources.Cursors.Arrow'
    TooltipBackgroundColor=(R=255,G=255,B=255,A=255)
}