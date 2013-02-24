class GUIScrollBoxComponent extends GUIButtonComponent;

// Holds references to the Previous and the Next button, used to scroll through the list.
var() editinline instanced GUIScrollBoxButtonComponent PreviousBtn,NextBtn;

// The list that is displayed, or the items in the localized files.
var() array<string> ItemList;

// At which item in the list it should start.
var() int StartIndex;

// Index of the currently displayed item.
var int CurrentIndex;


event InitializeComponent()
{
    super.InitializeComponent();

    if (PreviousBtn != None)
    {
        PreviousBtn.ParentScene = ParentScene;
		PreviousBtn.Window = Window;
        PreviousBtn.ScrollBoxBase = self;
        PreviousBtn.InitializeComponent();
    }
    if (NextBtn != None)
    {
        NextBtn.ParentScene = ParentScene;
		NextBtn.Window = Window;
        NextBtn.ScrollBoxBase = self;
        NextBtn.bNext = True;
        NextBtn.InitializeComponent();
    }
    if (StartIndex < ItemList.Length)
        CurrentIndex = StartIndex;
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

    // Draw the buttons last, they should be on top of the main component.
    if (PreviousBtn != None)
        PreviousBtn.DrawComponent(C);
    if(NextBtn != None)
        NextBtn.DrawComponent(C);

    // Items are displayed on top of all other things.
    if (bDrawCaption)
        DrawCaption(C, Index);
}

// Checks the SliderButton for their Tag since they are expected to be subobjects of the Slider
// and so he is responsible for them if they are not in the normal Component list.
function GUIComponent CheckComponentTag(coerce string CompTag)
{
    local GUIComponent Result;

    if (CompTag == Tag)
        return self;

    if (PreviousBtn != None)
    {
        Result = PreviousBtn.CheckComponentTag(CompTag);
        if (Result != None)
            return Result;
    }

    if (NextBtn != None)
    {
        return NextBtn.CheckComponentTag(CompTag); // None is a valid return for this!
    }

    return none;
}

function DrawCaption(Canvas C, optional byte DrawIndex)
{
    local float X,Y,XL,YL;
    local string DrawString;
    local vector2D BoundScale;

    if (ForcedCaptionInfo < 255)
        DrawIndex = ForcedCaptionInfo;

    // If a custom font is specified use that, else go to default one.
    if (DrawIndex < CaptionInfo.Length && CaptionInfo[DrawIndex] != None)
    {
        if (CaptionInfo[DrawIndex].Font != None)
            C.Font = CaptionInfo[DrawIndex].Font;

        if (CurrentIndex < ItemList.Length)
        {
            if (bLocalizeCaption)
                DrawString = GetLocalizedString(ItemList[CurrentIndex]);
            else
                DrawString = ItemList[CurrentIndex];
        }
        else
            DrawString = "";

        if (DrawString != "")
        {
            C.TextSize(DrawString, XL, YL, CaptionInfo[DrawIndex].ScaleX, CaptionInfo[DrawIndex].ScaleY);
            BoundScale = CaptionInfo[DrawIndex].GetBoundScale(C, DrawString, GetComponentSize(C));
            GetTextLocation(C, X, Y, XL * BoundScale.X, YL * BoundScale.Y);

            // Let the CaptionInfo take care of drawing, so it can be easily modified.
            CaptionInfo[DrawIndex].DrawString(C, X, Y, DrawString, BoundScale);
        }
    }
    else
    {
        C.Font = ParentScene.GetDefaultFont();

        if (CurrentIndex < ItemList.Length)
        {
            if (bLocalizeCaption)
                DrawString = GetLocalizedString(ItemList[CurrentIndex]);
            else
                DrawString = ItemList[CurrentIndex];
        }
        else
            DrawString = "";

        if (DrawString != "")
        {
            C.TextSize(DrawString, XL, YL);
            GetTextLocation(C, X, Y, XL, YL);

            C.SetPos(X, Y);
            C.SetDrawColor(255, 255, 255);
            C.DrawText(DrawString);
        }
    }
}


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

    if (PreviousBtn.CheckMouseFocus(C,MouseX,MouseY,BestPriority) == PreviousBtn)
        FocusComponent = PreviousBtn;
    else if (NextBtn.CheckMouseFocus(C,MouseX,MouseY,BestPriority) == NextBtn)
        FocusComponent = NextBtn;
    else if (bCanHaveSelection && Priority >= BestPriority && IsEnclosedByMe(C, MouseX, MouseY))
        FocusComponent = self;

    return FocusComponent;
}

function NextItem()
{
    if (CurrentIndex >= ItemList.Length - 1)
        CurrentIndex = 0;
    else
        CurrentIndex++;

    OnPropertyChanged(self);
}

function PreviousItem()
{
    if (CurrentIndex <= 0)
        CurrentIndex = ItemList.Length - 1;
    else
        CurrentIndex--;

    OnPropertyChanged(self);
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
    if(Event == IE_Released)
    {
        if(Key == 'Right')
        {
            NextItem();
            return True;
        }
        if(Key == 'Left')
        {
            PreviousItem();
            return True;
        }
    }
    return super.InputKey(ControllerID,Key,Event,AmountDepressed,bGamepad);
}

// Returns a numerical representation of the value that the component represents.
function float GetComponentValue()
{
    return CurrentIndex;
}

singular event DeleteGUIComp()
{
    super.DeleteGUIComp();

    if (PreviousBtn != None)
    {
        PreviousBtn.DeleteGUIComp();
        PreviousBtn = None;
    }
    if (NextBtn != None)
    {
        NextBtn.DeleteGUIComp();
        NextBtn = none;
    }
}

function SetEnabled(bool bNewEnabled)
{
    super.SetEnabled(bNewEnabled);

    if(PreviousBtn != none)
        PreviousBtn.SetEnabled(bNewEnabled);
    if(NextBtn != none)
        NextBtn.SetEnabled(bNewEnabled);
}

function SetPos(Vector2D NewPos)
{
    local Vector2D Diff;

    // calculate difference so buttons can maintain relative location
    Diff.X = NewPos.X - PosX;
    Diff.Y = NewPos.Y - PosY;

    super.SetPos(NewPos);

    // set button positions
    if(PreviousBtn != none)
        PreviousBtn.SetPos(Vect2D(PreviousBtn.PosX + Diff.X, PreviousBtn.PosY + Diff.Y) );

    if(NextBtn != none)
        NextBtn.SetPos(Vect2D(NextBtn.PosX + Diff.X, NextBtn.PosY + Diff.Y) );
}

DefaultProperties
{

}