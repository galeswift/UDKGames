class GUIDynamicLabelPlacer extends GUIDynamicComponentPlacer;

var() array<String> Text;
var() GFxMoviePlayer.GFxAlign Alignment;
var() bool bLocalizeStrings;
var() editinline instanced array<GUIStringDrawInfo> StringInfo;
var() string PageTag;

event InitializeComponent()
{
    local GUILabelComponent NewLabel;
    local String Component;
    local int CompNum;
    local  GUIContainerComponent Page;
    CompNum = 0;

    super.InitializeComponent();

    if(ParentScene != none && PageTag != "");
        Page = GUIContainerComponent(ParentScene.FindComponentByTag(PageTag));

    foreach Text(Component)
    {
        NewLabel = new() class'GUILabelComponent';
        NewLabel.Tag = Component;
        NewLabel.SetLabelText(Component,0,True);
        NewLabel.Alignment = Alignment;
        NewLabel.bLocalizeString = bLocalizeStrings;
        NewLabel.PosX = PosX + CompNum * XSpacing;
        NewLabel.PosXEnd = NewLabel.PosX + ComponentWidth;
        NewLabel.PosY = PosY + CompNum * YSpacing;
        NewLabel.PosYEnd = NewLabel.PosY + ComponentHeight;
        if(StringInfo.Length > 0)
            NewLabel.StringInfo = StringInfo;
        NewLabel.ParentScene = ParentScene;
		NewLabel.Window = Window;
        NewLabel.InitializeComponent();
        NewLabel.Priority += Priority;
        if(Page != none)
            Page.ChildComponents.AddItem(NewLabel);
        else if(ParentScene != none)
            ParentScene.GUIComponents.AddItem(NewLabel);

        CompNum++;
    }
}

event DeleteGUIComp()
{
    local GUIStringDrawInfo CurInfo;

    foreach StringInfo(CurInfo)
    {
        CurInfo.DeleteInfo();
    }

    StringInfo.Remove(0, StringInfo.Length);

    super.DeleteGUIComp();
}

DefaultProperties
{
}
