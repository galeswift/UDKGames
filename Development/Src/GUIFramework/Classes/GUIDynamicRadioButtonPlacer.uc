class GUIDynamicRadioButtonPlacer extends GUIDynamicComponentPlacer;

var() string PageTag,ButtonGroupTag;
var() GUIRadioButtonComponent DefaultRadioButton;
var() int ItemChecked;
var() array<String> Tags;


event InitializeComponent()
{
	local GUIRadioButtonComponent NewRB;
	local int CompNum;
	local  GUIContainerComponent Page;
	local GUIButtonGroup BG;
	CompNum = 0;

	if(Tags.Length == 0)
		return;

	super.InitializeComponent();

	if(ParentScene != none && PageTag != "");
		Page = GUIContainerComponent(ParentScene.FindComponentByTag(PageTag));
	if(ParentScene != none && ButtonGroupTag != "")
		BG = GUIButtonGroup(ParentScene.FindComponentByTag(ButtonGroupTag));

	while(CompNum < Tags.Length)
	{
		NewRB = new() class'GUIRadioButtonComponent' (DefaultRadioButton);
		NewRB.Tag = Tags[CompNum];

		NewRB.PosX = PosX + CompNum * XSpacing;
		NewRB.PosXEnd = NewRB.PosX + ComponentWidth;
		NewRB.PosY = PosY + CompNum * YSpacing;
		NewRB.PosYEnd = NewRB.PosY + ComponentHeight;

		NewRB.bChecked = False;
		if(ItemChecked - 1 == CompNum)
		{
			NewRB.bChecked = True;
			BG.CheckedComponent = NewRB;
		}

		NewRB.ParentScene = ParentScene;
		NewRB.Window = Window;
        NewRB.InitializeComponent();
        NewRB.Priority += Priority;
		
		
		if(BG != none)
		{
			NewRB.Manager = BG;
			BG.ChildComponents.AddItem(NewRB);
		}
		else if(Page != none)
		{
			Page.ChildComponents.AddItem(NewRB);			
		}
		else if(ParentScene != none)
			ParentScene.GUIComponents.AddItem(NewRB);
		
		CompNum++;
	}
}

event DeleteGUIComp()
{
    if(DefaultRadioButton != none)
    {
		DefaultRadioButton.DeleteGUIComp();
		DefaultRadioButton = none;
    }

    super.DeleteGUIComp();
}

DefaultProperties
{
}
