class GUIButtonGroup extends GUIContainerComponent;

var() GUIRadioButtonComponent CheckedComponent;
var() bool bHasSliderManager;

event InitializeComponent()
{
    local GUIComponent Comp;


    super(GUIComponent).InitializeComponent();

	if(ChildComponents.Length == 0)
		return;

	if(Outer.Class == class'GUISliderManager')
	{
		bHasSliderManager = True;
		foreach ChildComponents(Comp)
		{
			if(Comp.Class == Class'GUIRadioButtonComponent')
			{
				GUIRadioButtonComponent(Comp).Manager = self;
				Comp.ParentScene = ParentScene;
				Comp.InitializeComponent();
				Comp.Priority += Priority;
				GUISliderManager(Outer).ChildComponents.AddItem(Comp);
			}
		}
	}
	else
	{
		foreach ChildComponents(Comp)
		{
			if(Comp.Class != class'GUIRadioButtonComponent')
				ChildComponents.RemoveItem(Comp);
			else
			{
				GUIRadioButtonComponent(Comp).Manager = self;
				Comp.ParentScene = ParentScene;
				Comp.InitializeComponent();
				Comp.Priority += Priority;
			}
		}
	}
}

event SelectionChanged(optional GUIComponent Component)
{
	local GUIComponent Comp;

	if(Component == none)
		return;
	else
		CheckedComponent = GUIRadioButtonComponent(Component);

	foreach ChildComponents(Comp)
	{
		if(Comp != Component && GUICheckButtonComponent(Comp).bChecked)
			GUICheckButtonComponent(Comp).bChecked = False;
	}
	OnPropertyChanged(self);
}

function DrawComponent(Canvas C)
{
	if(!bHasSliderManager)
		super.DrawComponent(C);
}

function DrawDebugComponent(Canvas C)
{
	if(!bHasSliderManager)
		super.DrawDebugComponent(C);
}

function SetPos(Vector2D NewPos)
{
	local Vector2D Diff;
	local GUIComponent Comp;

	// movement is handled by slidermanager
	if(bHasSliderManager)
		return;

	// calculate difference so button can maintain relative location
	Diff.X = NewPos.X - PosX;
	Diff.Y = NewPos.Y - PosY;

	super.SetPos(NewPos);

	foreach ChildComponents(Comp)
	{
		Comp.SetPos(Vect2D(Comp.PosX + Diff.X, Comp.PosY + Diff.Y) );
	}
}

event DeleteGUIComp()
{
	if(CheckedComponent != none)
	{
		CheckedComponent.DeleteGUIComp();
		CheckedComponent = none;
	}
	super.DeleteGUIComp();
}

DefaultProperties
{
	PosX = 0
	PosY = 0
	PosXEnd = 1
	PosYEnd = 1
}
