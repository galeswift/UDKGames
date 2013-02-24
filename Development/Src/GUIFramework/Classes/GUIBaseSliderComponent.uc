//=============================================================================
// GUIBaseSliderComponent
//
// $wotgreal_dt: 07/10/2012 1:04:29 AM$
//
// Manages all parts of the Slider, including the button.
//=============================================================================
class GUIBaseSliderComponent extends GUIInteractiveComponent;

var() editinline instanced GUISliderButtonComponent SliderButton; // button that must be used
var() editinline instanced GUISliderManager Manager; // manager that can be used

var() float OldXProgress, OldYProgress; // previous progress
var() float xAxisProgress, yAxisProgress; // current progress of the sliderbutton on the slider
var() bool bHorizontalSlider; // If False, slider goes vertical.

var() bool bRealtimeProgress; // If True, slider value is constantly monitored for change, not only when it's clicked.

// If True, the button's start position (Note: depends on horizonal or not) is set according to a percentage between start and end of this component;
var() bool bPercentageStart;
// Note that this ranges from 0-1.
var() float StartPercentage;


event InitializeComponent()
{
    super.InitializeComponent();

    if (SliderButton != None)
    {
        SliderButton.ParentScene = ParentScene;
        SliderButton.InitializeComponent();
    }
    if (bPercentageStart)
    {
        SetProgress(StartPercentage);
    }
    UpdateProgress();
}


// Checks the SliderButton for their Tag since they are expected to be subobjects of the Slider
// and so he is responsible for them if they are not in the normal Component list.
function GUIComponent CheckComponentTag(coerce string CompTag)
{
    if (CompTag == Tag)
        return self;

    if (SliderButton != None)
        return SliderButton.CheckComponentTag(CompTag); // None is a valid return for this!

    return none;
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

    if (SliderButton != None)
    {
        SliderButton.DrawComponent(C);
        if (bRealtimeProgress)
            UpdateProgress();
    }
}


function UpdateProgress(optional bool bInitial)
{
    // Helps solve an odd Divide by zero error.
    if(Width == 0 || Height == 0)
    {
        Width = PosXEnd - PosX;
        Height = PosYEnd - PosY;
    }

    if (bHorizontalSlider)
    {
        OldXProgress = xAxisProgress;
		xAxisProgress = (SliderButton.PosX - PosX) / (Width - SliderButton.Width);
    }
    else
    {
        OldYProgress = yAxisProgress;
        yAxisProgress = (SliderButton.PosY - PosY) / (Height - SliderButton.Height);
    }

    if (OldXProgress != xAxisProgress || OldYProgress != yAxisProgress)
        OnPropertyChanged(); // Only called when the value actually changed.

	if(bInitial)
	{
		OldYProgress = yAxisProgress;
		OldXProgress = xAxisProgress;
	}

    if(Manager != none)
        Manager.UpdateProgress();

	OldYProgress = yAxisProgress;
	OldXProgress = xAxisProgress;
}

// Called when a Component (OnComponent) is dropped upon this one.
event DroppedOn(GUIComponent DroppedComponent)
{
    if (DroppedComponent == SliderButton)
        UpdateProgress();
    else
        DroppedComponent.DragFailed();
}

// Only called when this component is pressed, meaning the sliderbutton should be adjusted
event MousePressed(optional byte ButtonNum)
{
    SliderButton.bAlternativePress = True;
    ParentScene.ClickedSelection = SliderButton;
    SliderButton.MousePressed(ButtonNum);
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

    if (SliderButton.CheckMouseFocus(C,MouseX,MouseY,BestPriority) == SliderButton)
        FocusComponent = SliderButton;
    else
    {
        if (bCanHaveSelection && Priority >= BestPriority && IsEnclosedByMe(C, MouseX, MouseY))
            FocusComponent = self;
    }

    return FocusComponent;
}

function SetEnabled(bool bNewEnabled)
{
    super.SetEnabled(bNewEnabled);

    if (SliderButton != none)
    {
        SliderButton.SetEnabled(bNewEnabled);
    }
}

function float GetComponentValue()
{
    if (bHorizontalSlider)
        return xAxisProgress;
    else
        return yAxisProgress;
}

singular event DeleteGUIComp()
{
    super.DeleteGUIComp();

    if (SliderButton != None)
    {
        SliderButton.DeleteGUIComp();
        SliderButton = none;
    }

    Manager = None;
}

// Progress ranges from 0-1
function SetProgress(float Progress)
{
	// make sure it is between 0-1
	Progress = FClamp(Progress,0,1.0);
	// set position based on wether the slider is horizontal or not
	if(bHorizontalSlider)
		SliderButton.SetPos(Vect2D(PosX + Progress * (Width - SliderButton.Width),PosY));
    else
		SliderButton.SetPos(vect2d(PosX,PosY + Progress * (Height - SliderButton.Height)));

	UpdateProgress(True);
}

function SetPos(Vector2D NewPos)
{
	local Vector2D Diff;

	// calculate difference so button can maintain relative location
	Diff.X = NewPos.X - PosX;
	Diff.Y = NewPos.Y - PosY;

	super.SetPos(NewPos);

	if(SliderButton != none)
		SliderButton.SetPos(Vect2D(SliderButton.PosX + Diff.X, SliderButton.PosY + Diff.Y) );
}

DefaultProperties
{
    bCanReceiveDrop = True
	// horizontal slider by default
    bHorizontalSlider = True
}