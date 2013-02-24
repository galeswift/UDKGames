//-----------------------------------------------------------
// 
//-----------------------------------------------------------
class GUIMenuPageOptionScreen extends GUIPage;


var CustomSystemSettings MySystemSettings;

event InitializeComponent()
{
    MySystemSettings = class'WorldInfo'.static.GetWorldInfo().Spawn(class'CustomSystemSettings');

    super.InitializeComponent();

    FindComponentByTag("CancelButton").OnMouseReleased = CancelReleased;
	FindComponentByTag("ApplyButton").OnMouseReleased = ApplyReleased;

    FindComponentByTag("BloomCheck").OnPropertyChanged = BloomChanged;
    FindComponentByTag("FSCheck").OnPropertyChanged = FullscreenChanged;
    FindComponentByTag("DOFCheck").OnPropertyChanged = DOFChanged;
    FindComponentByTag("ACCheck").OnPropertyChanged = ACChanged;
    FindComponentByTag("VSCheck").OnPropertyChanged = VSChanged;
    FindComponentByTag("DetailScrollBox").OnPropertyChanged = DetailChanged;

	GUICheckButtonComponent(FindComponentByTag("BloomCheck")).bChecked = MySystemSettings.Bloom;
    GUICheckButtonComponent(FindComponentByTag("FSCheck")).bChecked = MySystemSettings.Fullscreen;
    GUICheckButtonComponent(FindComponentByTag("DOFCheck")).bChecked = MySystemSettings.DepthOfField;
    GUICheckButtonComponent(FindComponentByTag("ACCheck")).bChecked = MySystemSettings.AmbientOcclusion;
    GUICheckButtonComponent(FindComponentByTag("VSCheck")).bChecked = MySystemSettings.UseVsync;
    GUIScrollBoxComponent(FindComponentByTag("DetailScrollBox")).CurrentIndex = MySystemSettings.DetailMode;
	GUILabelComponent(FindComponentByTag("MaxAnisLabel2")).SetLabelText(String(MySystemSettings.MaxAnisotropy),0);

	AddResolutions();
}

function AddResolutions()
{
	local array<String> SupportedResolutions;
	local String CurrentResolution;
	local int Index;
	local GUIDynamicLabelPlacer DLP;
	local GUISliderManager GUISM;
	local GUIDynamicRadioButtonPlacer GUIDRBP;
	local GUIButtonGroup GUIBG;

	SupportedResolutions = GetSupportedResolutions();
	CurrentResolution = GetCurrentResolution();

	CurrentResolution = Repl(CurrentResolution,".0000","");

	Index = SupportedResolutions.Find(CurrentResolution) + 1;

	DLP = GUIDynamicLabelPlacer(FindComponentByTag("ResolutionComponent_L"));
	GUISM = GUISliderManager(FindComponentByTag("SliderManager_Options"));
	GUIDRBP = GUIDynamicRadioButtonPlacer(FindComponentByTag("ResolutionComponent_RB"));
	GUIBG = GUIButtonGroup(FindComponentByTag("ButtonGroup_Res"));

	if(DLP != none && GUISM != none && GUIDRBP != none && GUIBG != none)
	{
		DLP.Text = SupportedResolutions;
		DLP.PageTag = GUISM.Tag;
		DLP.InitializeComponent();

		GUIDRBP.ButtonGroupTag = GUIBG.Tag;
		GUIDRBP.ItemChecked = Index;
		GUIDRBP.Tags = SupportedResolutions;
		GUIDRBP.InitializeComponent();
		GUIBG.InitializeComponent();

		GUISM.CheckHorizontal();
		GUISM.CheckVertical();

		DLP.DeleteGUIComp();
		GUIDRBP.DeleteGUIComp();
	}	
}

function array<string> GetSupportedResolutions()
{
	local array<string> TheStrings;
	local string TempString;
	local int i;

	TempString = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ConsoleCommand("DUMPAVAILABLERESOLUTIONS", false);
	ParseStringIntoArray(TempString, TheStrings, "\n", true);

	for(i=TheStrings.Length-1; i >= 0; i--)
	{
		if(i>0 && TheStrings[i] == TheStrings[i-1])
			TheStrings.Remove(i,1);
	}

	return TheStrings;
}

function string GetCurrentResolution()
{
	local PlayerController PC;
	local Vector2D VSize;

	PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();
	LocalPlayer(PC.Player).ViewportClient.GetViewportSize(VSize);
	return VSize.X  $ "x" $ VSize.Y;
}

function BloomChanged(optional GUIComponent Component)
{
    MySystemSettings.SetBloom(GUICheckButtonComponent(FindComponentByTag("BloomCheck")).bChecked);
}

function FullscreenChanged(optional GUIComponent Component)
{
    MySystemSettings.SetFullscreen(GUICheckButtonComponent(FindComponentByTag("FSCheck")).bChecked);
}

function DOFChanged(optional GUIComponent Component)
{
    MySystemSettings.SetDepthOfField(GUICheckButtonComponent(FindComponentByTag("DOFCheck")).bChecked);
}

function ACChanged(optional GUIComponent Component)
{
    MySystemSettings.SetAmbientOcclusion(GUICheckButtonComponent(FindComponentByTag("ACCheck")).bChecked);
}

function VSChanged(optional GUIComponent Component)
{
    MySystemSettings.SetUseVsync(GUICheckButtonComponent(FindComponentByTag("VSCheck")).bChecked);
}

function DetailChanged(optional GUIComponent Component)
{
    MySystemSettings.SetDetailMode(Int(GUIScrollBoxComponent(FindComponentByTag("DetailScrollBox")).ItemList[GUIScrollBoxComponent(FindComponentByTag("DetailScrollBox")).CurrentIndex]));
}

// Function header matches the layout of the OnMousePressed delegate of the button.
function CancelReleased(optional GUIComponent Component, optional byte ButtonNum)
{
    ParentScene.PopPage(FindComponentByTag("TitlePage"));
}

function ApplyReleased(optional GUIComponent Component, optional byte ButtonNum)
{
	local String Resolution;
	local array<String> SplitRes;
	if(MySystemSettings != none)
	{
		Resolution = GUIButtonGroup(FindComponentByTag("ButtonGroup_Res")).CheckedComponent.Tag;
		SplitRes = SplitString(Resolution,"x",true);
		MySystemSettings.ResX = Int(SplitRes[0]);
		MySystemSettings.ResY = Int(SplitRes[1]);
		class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ConsoleCommand("SetRes" @ MySystemSettings.ResX $"x"$ MySystemSettings.ResY);
	}
    ParentScene.PopPage(FindComponentByTag("TitlePage"));
}

DefaultProperties
{
//==============================================================================
// Define DrawInfos that we will use on multiple occasions up here.

  // Checkbox
    Begin Object class=GUITextureDrawInfo Name=CheckboxInfoDefault
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=13, Y=13)
        SubUVStart=(X=1, Y=23)
        bStretchHorizontally=true
        bStretchVertically=True
    End Object

    Begin Object class=GUITextureDrawInfo Name=CheckboxInfoHover
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=13, Y=13)
        SubUVStart=(X=15, Y=23)
        bStretchHorizontally=true
        bStretchVertically=True
    End Object

    Begin Object class=GUITextureDrawInfo Name=CheckboxInfoPressed
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=13, Y=13)
        SubUVStart=(X=29, Y=23)
        bStretchHorizontally=true
        bStretchVertically=True
    End Object

    Begin Object class=GUITextureDrawInfo Name=CheckboxInfoDefaultChecked
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=13, Y=13)
        SubUVStart=(X=43, Y=23)
        bStretchHorizontally=false
        bStretchVertically=False
    End Object

    Begin Object class=GUITextureDrawInfo Name=CheckboxInfoHoverChecked
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=13, Y=13) 
		SubUVStart=(X=57, Y=23)
        bStretchHorizontally=false
        bStretchVertically=False
    End Object

    Begin Object class=GUITextureDrawInfo Name=CheckboxInfoPressedChecked
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=13, Y=13)
        SubUVStart=(X=71, Y=23)
        bStretchHorizontally=false
        bStretchVertically=False
    End Object


  // Slider
    Begin Object class=GUITextureDrawInfo Name=SliderbuttonInfoDefault
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=14, Y=37)
        SubUVStart=(X=68, Y=100)
        bStretchHorizontally=false
        bStretchVertically=false
    End Object

    Begin Object class=GUITextureDrawInfo Name=SliderbuttonInfoHover
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=14, Y=37)
        SubUVStart=(X=87, Y=100)
        bStretchHorizontally=false
        bStretchVertically=false
    End Object

    Begin Object class=GUITextureDrawInfo Name=SliderbuttonInfoPressed
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=14, Y=37)
        SubUVStart=(X=106, Y=100)
        bStretchHorizontally=false
        bStretchVertically=false
    End Object


    Begin Object class=GUITextureDrawInfo Name=SliderBaseInfoDefault
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=1, Y=1)
        SubUVStart=(X=165, Y=25)
        DrawColor=(R=255,G=255,B=255,A=255)
    End Object


  // Scrollbox
    Begin Object class=GUITextureDrawInfo Name=ScrollboxPrevButtonInfoDefault
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=14, Y=16)
        SubUVStart=(X=68, Y=83)
        bStretchHorizontally=False
        bStretchVertically=False
    End Object

    Begin Object class=GUITextureDrawInfo Name=ScrollboxPrevButtonInfoHover
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=14, Y=16)
        SubUVStart=(X=87, Y=83)
        bStretchHorizontally=False
        bStretchVertically=False
    End Object

    Begin Object class=GUITextureDrawInfo Name=ScrollboxPrevButtonInfoPressed
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=14, Y=16)
        SubUVStart=(X=106, Y=83)
        bStretchHorizontally=False
        bStretchVertically=False
    End Object


    Begin Object class=GUITextureDrawInfo Name=ScrollboxNextButtonInfoDefault
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=14, Y=16)
        SubUVStart=(X=68, Y=138)
        bStretchHorizontally=False
        bStretchVertically=False
    End Object

    Begin Object class=GUITextureDrawInfo Name=ScrollboxNextButtonInfoHover
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=14, Y=16)
        SubUVStart=(X=87, Y=138)
        bStretchHorizontally=False
        bStretchVertically=False
    End Object

    Begin Object class=GUITextureDrawInfo Name=ScrollboxNextButtonInfoPressed
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=14, Y=16)
        SubUVStart=(X=106, Y=138)
        bStretchHorizontally=False
        bStretchVertically=False
    End Object


    Begin Object class=GUITextureDrawInfo Name=ScrollboxInfoDefault
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=100, Y=18)
        SubUVStart=(X=163, Y=24)
    End Object


  // Button
    Begin Object class=GUITextureDrawInfo Name=ButtonInfoDefault
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=74, Y=21)
        SubUVStart=(X=2, Y=164)
        bStretchHorizontally=True
        bStretchVertically=True
    End Object

    Begin Object class=GUITextureDrawInfo Name=ButtonInfoHover
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=74, Y=21)
        SubUVStart=(X=2, Y=186)
        bStretchHorizontally=True
        bStretchVertically=True
    End Object

    Begin Object class=GUITextureDrawInfo Name=ButtonInfoPressed
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=74, Y=21)
        SubUVStart=(X=2, Y=208)
        bStretchHorizontally=True
        bStretchVertically=True
    End Object




//------------------------------------------------------------------------------
// string DrawInfos

    Begin Object class=GUIStringDrawInfo Name=BackStringInfo
        DrawColor=(R=0,G=0,B=0,A=255)
    End Object


//==============================================================================
// Define the actual subobjects.

    // Add the Slider as subobject.
    Begin Object class=GUIBaseSliderComponent Name=Slider_Options

        // Add the SliderButton as subobject of the BaseSlider.
        Begin Object Class=GUISliderButtonComponent Name=SliderButton_Options
            PosX = 0.97
            PosY = 0
            PosXEnd = 1
            PosYEnd = 0.107142857

            DrawInfo(0) = SliderbuttonInfoDefault
            DrawInfo(1) = SliderbuttonInfoHover
            DrawInfo(3) = SliderbuttonInfoPressed

        End Object

        Tag = "Slider_Options"
        PosX = 0.97
        PosY = 0.00
        PosXEnd = 1
        PosYEnd = 0.55
        ForcedDrawInfo = 0

        DrawInfo(0) = SliderBaseInfoDefault
        //DrawInfo(1) = (ComponentTexture=Texture2D'GUI.GUI_Buttons_02', SubUVEnd=(X=1, Y=1), SubUVStart=(X=11, Y=4))
        //DrawInfo(3) = (ComponentTexture=Texture2D'GUI.GUI_Buttons_02', SubUVEnd=(X=1, Y=1), SubUVStart=(X=11, Y=4))

        SliderButton = SliderButton_Options

        // This is actually a vertical slider
        bHorizontalSlider = False
        // The button will start at a percentage of the BaseComponent's length/width
        bPercentageStart = True
        // The percentage at wich to start
        StartPercentage = 0
    End Object

	// adding an ugly horizontal slider
	Begin Object class=GUIBaseSliderComponent Name=HSlider_Options

        // Add the SliderButton as subobject of the BaseSlider.
        Begin Object Class=GUISliderButtonComponent Name=HSliderButton_Options
            PosX = 0.3
            PosY = 0.6
            PosXEnd = 0.4 
            PosYEnd = 0.63

            DrawInfo(0) = SliderbuttonInfoDefault
            DrawInfo(1) = SliderbuttonInfoHover
            DrawInfo(3) = SliderbuttonInfoPressed

        End Object

        Tag = "HSlider_Options"
        PosX = 0.4
        PosY = 0.55
        PosXEnd = 0.97
        PosYEnd = 0.58
        ForcedDrawInfo = 0

        DrawInfo(0) = SliderBaseInfoDefault

        SliderButton = HSliderButton_Options

        // This is actually a vertical slider
        bHorizontalSlider = True
    End Object

    Begin Object Class=GUILabelComponent Name=BloomLabel
        Tag = "BloomLabel"
        PosX = 0.3
        PosY = 0.05
        PosXEnd = 0.5
        PosYEnd = 0.1
		PosXAdjust = 30

        Alignment = Align_CenterLeft
        LabelText(0) = "BloomString"
    End Object

    Begin Object Class=GUICheckButtonComponent Name=BloomCheck
        Tag = "BloomCheck"
        PosX = 0.75
        PosY = 0.0625
        PosXEnd = 0.775
        PosYEnd = 0.0875

        DrawInfo(0) = CheckboxInfoDefault
        DrawInfoChecked(0) = CheckboxInfoDefaultChecked


        DrawInfo(1) = CheckboxInfoHover
        DrawInfoChecked(1) = CheckboxInfoHoverChecked


        DrawInfo(3) = CheckboxInfoPressed
        DrawInfoChecked(3) = CheckboxInfoPressedChecked
    End Object

    Begin Object Class=GUILabelComponent Name=FullScreenLabel
        Tag = "FullScreenLabel"
        PosX = 0.35
        PosY = 0.1
        PosXEnd = 0.5
        PosYEnd = 0.15

        Alignment = Align_CenterLeft
        bLocalizeString = False
        LabelText(0) = "FullScreen"
    End Object

    Begin Object Class=GUICheckButtonComponent Name=FSCheck
        Tag = "FSCheck"
        PosX = 0.75
        PosY = 0.1125
        PosXEnd = 0.775
        PosYEnd = 0.1375

        DrawInfo(0) = CheckboxInfoDefault
        DrawInfoChecked(0) = CheckboxInfoDefaultChecked


        DrawInfo(1) = CheckboxInfoHover
        DrawInfoChecked(1) = CheckboxInfoHoverChecked


        DrawInfo(3) = CheckboxInfoPressed
        DrawInfoChecked(3) = CheckboxInfoPressedChecked
    End Object

    Begin Object Class=GUILabelComponent Name=DOFLabel
        Tag = "DOFLabel"
        PosX = 0.35
        PosY = 0.15
        PosXEnd = 0.5
        PosYEnd = 0.2

        Alignment = Align_CenterLeft
        bLocalizeString = False
        LabelText(0) = "Depth Of Field"
    End Object

    Begin Object Class=GUICheckButtonComponent Name=DOFCheck
        Tag = "DOFCheck"
        PosX = 0.75
        PosY = 0.1625
        PosXEnd = 0.775
        PosYEnd = 0.1875

        DrawInfo(0) = CheckboxInfoDefault
        DrawInfoChecked(0) = CheckboxInfoDefaultChecked

        DrawInfo(1) = CheckboxInfoHover
        DrawInfoChecked(1) = CheckboxInfoHoverChecked

        DrawInfo(3) = CheckboxInfoPressed
        DrawInfoChecked(3) = CheckboxInfoPressedChecked

    End Object

    Begin Object Class=GUILabelComponent Name=ACLabel
        Tag = "ACLabel"
        PosX = 0.35
        PosY = 0.2
        PosXEnd = 0.5
        PosYEnd = 0.25

        Alignment = Align_CenterLeft
        bLocalizeString = False
        LabelText(0) = "Ambient Occlusion"
    End Object

    Begin Object Class=GUICheckButtonComponent Name=ACCheck
        Tag = "ACCheck"
        PosX = 0.75
        PosY = 0.2125
        PosXEnd = 0.775
        PosYEnd = 0.2375

        DrawInfo(0) = CheckboxInfoDefault
        DrawInfoChecked(0) = CheckboxInfoDefaultChecked


        DrawInfo(1) = CheckboxInfoHover
        DrawInfoChecked(1) = CheckboxInfoHoverChecked


        DrawInfo(3) = CheckboxInfoPressed
        DrawInfoChecked(3) = CheckboxInfoPressedChecked

    End Object

    Begin Object Class=GUILabelComponent Name=VSLabel
        Tag = "VSLabel"
        PosX = 0.35
        PosY = 0.25
        PosXEnd = 0.5
        PosYEnd = 0.3

        Alignment = Align_CenterLeft
        bLocalizeString = False
        LabelText(0) = "VSync"
    End Object

    Begin Object Class=GUICheckButtonComponent Name=VSCheck
        Tag = "VSCheck"
        PosX = 0.75
        PosY = 0.2625
        PosXEnd = 0.775
        PosYEnd = 0.2875

        DrawInfo(0) = CheckboxInfoDefault
        DrawInfoChecked(0) = CheckboxInfoDefaultChecked

        DrawInfo(1) = CheckboxInfoHover
        DrawInfoChecked(1) = CheckboxInfoHoverChecked

        DrawInfo(3) = CheckboxInfoPressed
        DrawInfoChecked(3) = CheckboxInfoPressedChecked

    End Object

    Begin Object Class=GUILabelComponent Name=DetailLabel
        Tag = "DetailLabel"
        PosX = 0.35
        PosY = 0.3
        PosXEnd = 0.5
        PosYEnd = 0.35

        Alignment = Align_CenterLeft
        bLocalizeString = False
        LabelText(0) = "Detail Mode"
    End Object

    // Add the scrollbox as subobject.
    Begin Object class=GUIScrollBoxComponent Name=DetailScrollBox

        Begin Object class=GUIScrollBoxButtonComponent Name=PreviousButton
            PosX = 0.8125
            PosY = 0.3
            PosXEnd = 0.85625
            PosYEnd = 0.35

            DrawInfo(0) = ScrollboxPrevButtonInfoDefault
            DrawInfo(1) = ScrollboxPrevButtonInfoHover
            DrawInfo(3) = ScrollboxPrevButtonInfoPressed

        End Object

        Begin Object class=GUIScrollBoxButtonComponent Name=NextButton
            PosX = 0.85625
            PosY = 0.3
            PosXEnd = 0.9
            PosYEnd = 0.35
            bNext = true //This is the Next button

            DrawInfo(0) = ScrollboxNextButtonInfoDefault
            DrawInfo(1) = ScrollboxNextButtonInfoHover
            DrawInfo(3) = ScrollboxNextButtonInfoPressed

        End Object

        Tag = "DetailScrollBox"
        PosX = 0.75
        PosY = 0.3
        PosXEnd = 0.9
        PosYEnd = 0.35
        bDrawCaption = True // We want the text to be drawn

        DrawInfo(0) = ScrollboxInfoDefault
		CaptionInfo(0) = BackStringInfo
        DrawInfo(1) = ScrollboxInfoDefault
		CaptionInfo(1) = BackStringInfo
        DrawInfo(3) = ScrollboxInfoDefault
		CaptionInfo(3) = BackStringInfo

        PreviousBtn = PreviousButton
        NextBtn = NextButton

        bLocalizeCaption = False // False by default, but just a reminder that it can be localized
        ItemList(0) = "1"
        ItemList(1) = "2"
        ItemList(2) = "3"
        Alignment = Align_CenterLeft

    End Object

    Begin Object Class=GUILabelComponent Name=MaxAnisLabel
        Tag = "MaxAnisLabel"
        PosX = 0.35
        PosY = 0.35
        PosXEnd = 0.5
        PosYEnd = 0.4

        Alignment = Align_CenterLeft
        bLocalizeString = False
        LabelText(0) = "Anisotropy"
    End Object

    Begin Object Class=GUILabelComponent Name=MaxAnisLabel2
        Tag = "MaxAnisLabel2"
        PosX = 1.75
        PosY = 0.35
        PosXEnd = 1.8
        PosYEnd = 0.4

        Alignment = Align_BottomCenter
        bLocalizeString = False
		StringInfo(0) = BackStringInfo
		StringInfo(1) = BackStringInfo
		StringInfo(3) = BackStringInfo
    End Object

	Begin Object Class=GUIButtonGroup Name=ButtonGroup
		// hack here, since we are using a SliderManager, place this component anywhere inside the SliderManager's bounds
		PosX = 0.5
		PosY = 0.5
		PosXEnd = 0.5
		PosYend = 0.5
		Tag = "ButtonGroup_Res"
	End Object

	Begin Object Class=GUIDynamicLabelPlacer Name=ResolutionComponent_L
		Tag = "ResolutionComponent_L"
		PosX = 0.35
		PosY = 0.4
		PosXEnd = 1
		PosYEnd = 1
		ComponentHeight = 0.05
		ComponentWidth = 0.2
		YSpacing = 0.05
		Alignment = Align_CenterLeft
		bLocalizeStrings = false
	End Object
	

	Begin Object Class=GUIRadioButtonComponent Name=DefaultRadioButton_1
        Tag = "DefaultRadioButton"
        PosX = 0.75
        PosY = 0.2625
        PosXEnd = 0.775
        PosYEnd = 0.2875

        DrawInfo(0) = CheckboxInfoDefault
        DrawInfoChecked(0) = CheckboxInfoDefaultChecked

        DrawInfo(1) = CheckboxInfoHover
        DrawInfoChecked(1) = CheckboxInfoHoverChecked

        DrawInfo(3) = CheckboxInfoPressed
        DrawInfoChecked(3) = CheckboxInfoPressedChecked

    End Object

	Begin Object Class=GUIDynamicRadioButtonPlacer Name=ResolutionComponent_RB
		Tag = "ResolutionComponent_RB"
		PosX = 0.75
		PosY = 0.4
		ComponentHeight = 0.025
		ComponentWidth = 0.025
		YSpacing = 0.05
		DefaultRadioButton = DefaultRadioButton_1
	End Object
	

    Begin Object Class=GUISliderManager Name=SliderManager_1
		Tag="SliderManager_Options"
        VSlider = Slider_Options
		HSlider = HSlider_Options
		// it is no longer necessary to add the components to the GUIPage, this manager is all you need.
        ChildComponents.Add(BloomLabel)
        ChildComponents.Add(BloomCheck)
        ChildComponents.Add(FullscreenLabel)
        ChildComponents.Add(FSCheck)
        ChildComponents.Add(DOFLabel)
        ChildComponents.Add(DOFCheck)
        ChildComponents.Add(ACLabel)
        ChildComponents.Add(ACCheck)
        ChildComponents.Add(VSLabel)
        ChildComponents.Add(VSCheck)
        ChildComponents.Add(DetailLabel)
        ChildComponents.Add(DetailScrollBox)
        ChildComponents.Add(MaxAnisLabel)
        ChildComponents.Add(MaxAnisLabel2)
		ChildComponents.Add(ButtonGroup)
		ChildComponents.Add(ResolutionComponent_RB)
		ChildComponents.Add(ResolutionComponent_L)
		// this is the area where the above components will be shown
		PosX = 0.4
		PosY = 0.05
		PosYEnd = 0.55
		PosXEnd = 0.97
    End Object
    ChildComponents.Add(SliderManager_1)

    Begin Object class=GUIButtonComponent Name=CancelButton
        Tag = "CancelButton"
        PosX = 0.50
        PosY = 0.8
        PosXEnd = 0.65
        PosYEnd = 0.85
        bDrawCaption = True
        ForcedCaptionInfo = 0

        DrawInfo(0) = ButtonInfoDefault
        CaptionInfo(0) = BackStringInfo
		Caption(0) = "CancelString"

        DrawInfo(1) = ButtonInfoHover

        DrawInfo(3) = ButtonInfoPressed
    End Object
    ChildComponents.Add(CancelButton)

	Begin Object class=GUIButtonComponent Name=ApplyButton
        Tag = "ApplyButton"
        PosX = 0.30
        PosY = 0.8
        PosXEnd = 0.45
        PosYEnd = 0.85
        bDrawCaption = True
        ForcedCaptionInfo = 0

        DrawInfo(0) = ButtonInfoDefault
        CaptionInfo(0) = BackStringInfo
		Caption(0) = "ApplyString"

        DrawInfo(1) = ButtonInfoHover

        DrawInfo(3) = ButtonInfoPressed
    End Object
    ChildComponents.Add(ApplyButton)
}