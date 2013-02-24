//TODO: Check if merge with GUIContainerComponent makes sense.
// It would seem much more convenient to just link this to a large GUIContainerComponent that holds all child components.
class GUISliderManager extends GUIPage;

// sliders that can be used, horizontal and vertical. Must be set in defaultproperties.
var() editinline instanced GUIBaseSliderComponent HSlider,VSlider;


//values used to determine the outer limits of the ChildComponents
var() float MaxX, MaxY, MinX, MinY;
// the difference between the outer limits and this components bounds
var() float YDiff, XDiff;


event InitializeComponent()
{
	local GUIComponent Comp;

	super(GUIComponent).InitializeComponent();   

	foreach ChildComponents(Comp)
    {
        Comp.ParentScene = ParentScene;
		Comp.Window = self;
        Comp.InitializeComponent();
        Comp.Priority += Priority;
		
    }

    if (VSlider != none)
    {
        VSlider.Manager = self;
        // add the Vertical slider to the childcomponents
        // so it will be drawn and can be used
        ChildComponents.AddItem(VSlider);

		VSlider.ParentScene = ParentScene;
		VSlider.InitializeComponent();
		VSlider.Priority += Priority;
    }
    if(HSlider != none)
    {
        // make sure the slider is actually horizontal
        if(!HSlider.bHorizontalSlider)
            HSlider.bHorizontalSlider = True;
        HSlider.Manager = self;
        // same as for the vertical slider
        ChildComponents.AddItem(HSlider);

		HSlider.ParentScene = ParentScene;
		HSlider.InitializeComponent();
		HSlider.Priority += Priority;
    }

    
}

function CheckVertical()
{
    local GUIComponent Comp;
    local float InitialProgress; // inital progress of the slider

    MaxY = PosYEnd;
    MinY = PosY;

    foreach ChildComponents(Comp)
    {
        if( !(VSlider != none && Comp == VSlider || HSlider != none && Comp == HSlider ))
        {
            if(Comp.PosYEnd > PosYEnd)
            {
                // disable component since it is outside my range
                //if(Comp.PosY > PosYEnd)
                    //Comp.SetEnabled(False);

                // adjust maximum value since it is higher
                if(Comp.PosYEnd > MaxY)
                    MaxY = Comp.PosYEnd;
            }
            if(Comp.PosY < PosY)
            {
                // disable component since it is outside my range
                //if(Comp.PosYEnd < PosY)
                   // Comp.SetEnabled(False);

                // adjust minimum value since it is lower
                if(Comp.PosY < MinY)
                    MinY = Comp.PosY;
            }
        }
    }


    YDiff = FMax(0, (MaxY - PosYEnd) + (PosY - MinY) );


    // calculate progress, used when components start outside this component
    if(PosY - MinY > 0)
    {
        InitialProgress = (PosY - MinY) / (YDiff + Height);
        VSlider.SetProgress(InitialProgress);
    }
    else
        VSlider.SetProgress(0);

    // disable the slider if it is not needed
    if(MaxY - PosYEnd <= 0)
        VSlider.SetEnabled(False);
    else
        VSlider.SetEnabled(True);
}

function CheckHorizontal()
{
    local GUIComponent Comp;
	local float InitialProgress; // inital progress of the slider

    MaxX = PosXEnd;
    MinX = PosX;

    foreach ChildComponents(Comp)
    {
        if( !(VSlider != none && Comp == VSlider || HSlider != none && Comp == HSlider ))
        {
            if(Comp.PosXEnd > PosXEnd)
            {
                // disable component
                //if(Comp.PosX > PosXEnd)
                    //Comp.SetEnabled(False);

                if(Comp.PosXEnd > MaxX)
                    MaxX = Comp.PosXEnd;
            }
            if(Comp.PosX < PosX)
            {
                // disable component
                //if(Comp.PosXEnd < PosX)
                    //Comp.SetEnabled(False);

                if(Comp.PosX < MinX)
                {
                    MinX = Comp.PosX;
                }
            }
        }
    }

    XDiff = (MaxX - PosXEnd) + (PosX - MinX);

	// calculate progress, used when components start outside this component
    if(PosX - MinX > 0)
    {
        InitialProgress = (PosX - MinX) / (XDiff + Width);
        HSlider.SetProgress(InitialProgress);
    }
    else
        HSlider.SetProgress(0);



    if(MaxX - PosXEnd <= 0)
        HSlider.SetEnabled(False);
    else
        HSlider.SetEnabled(True);
}

function UpdateProgress()
{
	if(HSlider != none)
		PosXAdjust -= (HSlider.xAxisProgress - HSlider.OldXProgress) * XDiff;
	if(VSlider != none)
		PosYAdjust -= (VSlider.yAxisProgress - VSlider.OldYProgress) * YDiff;
}


singular event DeleteGUIComp()
{
    super.DeleteGUIComp();

    if (VSlider != None)
    {
        VSlider.DeleteGUIComp();
        VSlider = none;
    }
    if (HSlider != None)
    {
        HSlider.DeleteGUIComp();
        HSlider = none;
    }
}

function PrecacheComponentTextures(Canvas C)
{
	super.PrecacheComponentTextures(C);
	xDiff *= C.ClipX;
	yDiff *= C.ClipY;
}

DefaultProperties
{
    PosXEnd = 1.0
    PosYEnd = 1.0
}
