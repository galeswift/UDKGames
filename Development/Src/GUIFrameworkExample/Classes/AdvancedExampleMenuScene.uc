//-----------------------------------------------------------
// NOTE: Replace 'SI_GUI.ButtonTest' in the DefaultProperties with references to
// a valid texture in one of your packages. SubUVEnd should be changed to the
// dimensions of the texture then.
//-----------------------------------------------------------
class AdvancedExampleMenuScene extends GUIMenuScene;

event InitMenuScene()
{
	DefaultInputComponent = FindComponentByTag("TitlePage");

	FindComponentByTag("TitlePage").OnInputKey = TitleInput;
	FindComponentByTag("ShowPage").OnInputKey = ShowInput;
	FindComponentByTag("OptionsPage").OnInputKey = OptionsInput;

	FindComponentByTag("ResumeButton").OnMouseReleased = ResumeReleased;
	FindComponentByTag("ExitButton").OnMouseReleased = ExitReleased;
	FindComponentByTag("ShowButton").OnMouseReleased = ShowReleased;
	FindComponentByTag("ReturnButton").OnMouseReleased = ReturnReleased;
	FindComponentByTag("OptionsButton").OnMouseReleased = OptionsReleased;

	super.InitMenuScene();
}

event PoppedLastPage()
{
    GUICompatibleHUD(Outer).TogglePauseMenu();
}

// Function header matches the layout of the OnMousePressed delegate of the button.
function OptionsReleased(optional GUIComponent Component, optional byte ButtonNum)
{
    PushPage(GUIPage(FindComponentByTag("OptionsPage")));
}

// Function header matches the layout of the OnMousePressed delegate of the button.
function ReturnReleased(optional GUIComponent Component, optional byte ButtonNum)
{
    PopPage(FindComponentByTag("TitlePage"));
}

// Function header matches the layout of the OnMousePressed delegate of the button.
function ShowReleased(optional GUIComponent Component, optional byte ButtonNum)
{
    PushPage(GUIPage(FindComponentByTag("ShowPage")));
}

// Function header matches the layout of the OnMousePressed delegate of the button.
function ResumeReleased(optional GUIComponent Component, optional byte ButtonNum)
{
    GUICompatibleHUD(Outer).TogglePauseMenu();
}

// Function header matches the layout of the OnMousePressed delegate of the button.
function ExitReleased(optional GUIComponent Component, optional byte ButtonNum)
{
    Actor(Outer).ConsoleCommand("Quit");
}

function bool TitleInput(int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE)
{
    if(Event == IE_Released)
    {
		if( Key == 'Escape')
		{
			GUICompatibleHUD(Outer).TogglePauseMenu();
			return True;
		}
    }
    return False;
}

function bool ShowInput(int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE)
{
    if(Event == IE_Released)
    {
		if( Key == 'Escape')
		{
			PopPage(FindComponentByTag("TitlePage"));
			return True;
		}
    }
    return False;
}

function bool OptionsInput(int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE)
{
    if(Event == IE_Released)
    {
		if( Key == 'Escape')
		{
			PopPage(FindComponentByTag("TitlePage"));
			return True;
		}
    }
    return False;
}


DefaultProperties
{
    bDrawGUIComponents = False // We want to start without them and only draw them when TogglePauseMenu is called.
    bCaptureKeyInput=False // We want the components and the menu to use key input
    bCaptureMouseInput = False // We also want to be able to have a mouse
    LocalizationFileName = "GUIFramework"

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
        SubUVStart=(X=11, Y=4)
        DrawColor=(R=0,G=0,B=0,A=0)
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

    begin object class=GUITextureDrawInfo Name=TextBoxInfo
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=100, Y=18)
        SubUVStart=(X=163, Y=24)
    end object

    begin object class=GUITextureDrawInfo Name=Tex_Background_1
        ComponentMaterial=Material'Envy_Effects.flares.Materials.M_EFX_Flair_Multi_Color3'
        bUseMaterial=True
    end object

    begin object class=GUITextureDrawInfo Name=Tex_Background_2
        ComponentMaterial=Material'EditorLandscapeResources.LandscapeGizmo_Mat'
        bUseMaterial=True
    end object

    begin object class=GUITextureDrawInfo Name=Tex_Background_Green
        ComponentTexture=Texture2D'GUI.GUI_Buttons_02'
        SubUVEnd=(X=1, Y=1)
        SubUVStart=(X=11, Y=4)
        DrawColor=(R=0,G=0,B=0,A=150)
    end object


//------------------------------------------------------------------------------
// string DrawInfos

    Begin Object class=GUIStringDrawInfo Name=BackStringInfo
        DrawColor=(R=0,G=0,B=0,A=255)
    End Object


//==============================================================================
// Define the actual subobjects.

	// Main title screen, this is where we start
    Begin Object class=GUIPage Name=TitlePage
        Tag = "TitlePage"
        PosX = 0.0
        PosY = 0.0
        PosXEnd = 1.0
        PosYEnd = 1.0

		// Background image number 1
		Begin Object class=GUIVisualComponent Name=BackGround
	        Tag = "BackGround"
			PosX = 0
			PosY = 0
			PosXEnd = 1
			PosYEnd = 1
	 
			DrawInfo(0) = Tex_Background_1
		End Object
		ChildComponents.Add(BackGround)
	
		// Background image number 2
	    Begin Object class=GUIVisualComponent Name=BackGround2
			Tag = "BackGround2"
			PosX = 0
			PosY = 0
			PosXEnd = 1
			PosYEnd = 1
	
			DrawInfo(0) = Tex_Background_2
		End Object
		ChildComponents.Add(BackGround2)

        Begin Object class=GUIButtonComponent Name=ResumeButton
            Tag = "ResumeButton"
            PosX = 0.05
            PosY = 0.1
            PosXEnd = 0.2
            PosYEnd = 0.145
			bDrawCaption = True
			ForcedCaptionInfo = 0

			DrawInfo(0) = ButtonInfoDefault
			CaptionInfo(0) = BackStringInfo
			Caption(0) = "ResumeString"

			DrawInfo(1) = ButtonInfoHover

			DrawInfo(3) = ButtonInfoPressed
        End Object
        ChildComponents.Add(ResumeButton)

        Begin Object class=GUIButtonComponent Name=ShowButton
            Tag = "ShowButton"
            PosX = 0.05
            PosY = 0.15
            PosXEnd = 0.2
            PosYEnd = 0.195
			bDrawCaption = True
			ForcedCaptionInfo = 0

			DrawInfo(0) = ButtonInfoDefault
			CaptionInfo(0) = BackStringInfo
			Caption(0) = "ShowString"

			DrawInfo(1) = ButtonInfoHover

			DrawInfo(3) = ButtonInfoPressed
        End Object
        ChildComponents.Add(ShowButton)

        Begin Object class=GUIButtonComponent Name=OptionsButton
            Tag = "OptionsButton"
            PosX = 0.05
            PosY = 0.2
            PosXEnd = 0.2
            PosYEnd = 0.245
			bDrawCaption = True
			ForcedCaptionInfo = 0

			DrawInfo(0) = ButtonInfoDefault
			CaptionInfo(0) = BackStringInfo
			Caption(0) = "OptionsString"

			DrawInfo(1) = ButtonInfoHover

			DrawInfo(3) = ButtonInfoPressed
        End Object
        ChildComponents.Add(OptionsButton)

        Begin Object class=GUIButtonComponent Name=ExitButton
            Tag = "ExitButton"
            PosX = 0.05
            PosY = 0.25
            PosXEnd = 0.2
            PosYEnd = 0.295
			bDrawCaption = True
			ForcedCaptionInfo = 0

			DrawInfo(0) = ButtonInfoDefault
			CaptionInfo(0) = BackStringInfo
			Caption(0) = "ExitString"

			DrawInfo(1) = ButtonInfoHover

			DrawInfo(3) = ButtonInfoPressed
        End Object
        ChildComponents.Add(ExitButton)
 
    End Object
    GUIComponents.Add(TitlePage)

//=============================================================================

    Begin Object class=GUIPage Name=ShowScreen
        Tag = "ShowPage"
        PosX = 0.0
        PosY = 0.0
        PosXEnd = 1.0
        PosYEnd = 1.0
		bEnabled = False // This is the second page, start disabled.

		Begin Object Class=GUIVisualComponent Name=GreenBackGround
			Tag = "GreenBackGround"
			PosX = 0
			PosY = 0
			PosXEnd = 1
			PosYEnd = 1
			ForcedDrawInfo = 0

			DrawInfo(0) = Tex_Background_Green
		End Object
		ChildComponents.Add(GreenBackGround)

		// Add the Return button as subobject.
		Begin Object Class=GUIButtonComponent Name=ReturnButton
			Tag = "ReturnButton" // Tag used to assign delegates.
			PosX = 0.1 // Relative position on the screen, 0.0 being the left edge and 1.0 the right edge.
			PosY = 0.4 // Same, 0.0 is the top edge and 1.0 is the bottom edge.
			PosXEnd = 0.3
			PosYEnd = 0.45
			bEnabled = True // Start with an enabled component.
			bRelativePosX = True // Relative means that we use the range 0.0 - 1.0.
			bRelativePosY = True // If it would be false, we would use absolute pixel values. These are the values for the top-left corner.
			bRelativeWidth = True // If it's true, the component will end at PosXYEnd(0.6) of the whole screen size in that direction.
			bRelativeHeight = True // If it would be false, the component would be PosXYEnd (0.6) pixels tall (which means it wouldn't be visible at all).
			bFitComponentToTexture = False
			bDrawCaption = True // We want the localized text to be drawn
	
			ForcedCaptionInfo = 0

			DrawInfo(0) = ButtonInfoDefault
			CaptionInfo(0) = BackStringInfo
			Caption(0) = "ReturnString"

			DrawInfo(1) = ButtonInfoHover

			DrawInfo(3) = ButtonInfoPressed

			/**********************************************************************************************
			 * ********************************************** **********************************************
			 * NOTE on the SubUVEnd:
			 * X=74, Y=21 means the picture is 74 pixels wide as seen from the SubUVStart, so actually ends
			 *  at 76 (74+2) in the original picture. same goes for Y.
			 * ********************************************************************************************
			 * ********************************************************************************************/	
	    End Object
		ChildComponents.Add(ReturnButton)
	
		// Add the Slider as subobject.
		Begin Object Class=GUIBaseSliderComponent Name=Slider
	
			// Add the SliderButton as subobject of the BaseSlider.
			Begin Object Class=GUISliderButtonComponent Name=SliderButton
	            PosX = 0.97
				PosY = 0
				PosXEnd = 1
				PosYEnd = 0.107142857
	
				DrawInfo(0) = SliderbuttonInfoDefault
				DrawInfo(1) = SliderbuttonInfoHover
				DrawInfo(3) = SliderbuttonInfoPressed
	
			End Object
	
			Tag = "Slider"
			PosX = 0.97
			PosY = 0
			PosXEnd = 1
			PosYEnd = 1
			ForcedDrawInfo = 0

			DrawInfo(0) = SliderBaseInfoDefault
	
			SliderButton = SliderButton
	
			// This is actually a vertical slider
			bHorizontalSlider = False
			// The button will start at a percentage of the BaseComponent's length/width
			bPercentageStart = True
			// The percentage at wich to start
			StartPercentage = 0.9
		End Object
		ChildComponents.Add(Slider)
	
	    // Add the check button as subobject.
	    Begin Object Class=GUICheckButtonComponent Name=CheckButton
			Tag = "CheckButton"
			PosX = 0.05
			PosY = 0.2
			PosXEnd = 0.075
			PosYEnd = 0.225
			bEnabled = True
			bRelativePosX = True
			bRelativePosY = True
			bRelativeWidth = True
			bRelativeHeight = True
			bFitComponentToTexture = False
			bAddChecked = True
	
			DrawInfo(0) = CheckboxInfoDefault
			DrawInfoChecked(0) = CheckboxInfoDefaultChecked


			DrawInfo(1) = CheckboxInfoHover
			DrawInfoChecked(1) = CheckboxInfoHoverChecked


			DrawInfo(3) = CheckboxInfoPressed
			DrawInfoChecked(3) = CheckboxInfoPressedChecked
		End Object
		ChildComponents.Add(CheckButton)
	
	    // Add the Movable button as subobject.
	    Begin Object Class=GUIButtonComponent Name=MovableButton
			Tag = "MovableButton"
			PosX = 0.05
			PosY = 0.25
			PosXEnd = 0.15
			PosYEnd = 0.35
			bDrawCaption = True // We want the localized text to be drawn
	
			bCanDrag = True // This is a movable button, we want to be able to move it
			bNoConnect = True // Means this component will have a special drop event, else we can't just drop it anywhere we want to	

			DrawInfo(0) = ButtonInfoDefault
			CaptionInfo(0) = BackStringInfo
			Caption(0) = "MoveString_Default"

			DrawInfo(1) = ButtonInfoHover
			CaptionInfo(1) = BackStringInfo
			Caption(1) = "MoveString_Hover"

			DrawInfo(3) = ButtonInfoPressed
			CaptionInfo(3) = BackStringInfo
			Caption(3) = "MoveString_Clicked"
	
	    End Object
		ChildComponents.Add(MovableButton)
	
	    // Add the scrollbox as subobject.
	    Begin Object class=GUIScrollBoxComponent Name=ScrollBox
	
			Begin Object class=GUIScrollBoxButtonComponent Name=PreviousButton
				PosX = 0.5
	            PosY = 0.5
				PosXEnd = 0.54375
				PosYEnd = 0.55
	
				DrawInfo(0) = ScrollboxPrevButtonInfoDefault
				DrawInfo(1) = ScrollboxPrevButtonInfoHover
				DrawInfo(3) = ScrollboxPrevButtonInfoPressed
	
			End Object
	
			Begin Object class=GUIScrollBoxButtonComponent Name=NextButton
	            PosX = 0.70625
				PosY = 0.5
				PosXEnd = 0.75
				PosYEnd = 0.55
				bNext = True //This is the Next button
	
				DrawInfo(0) = ScrollboxNextButtonInfoDefault
				DrawInfo(1) = ScrollboxNextButtonInfoHover
				DrawInfo(3) = ScrollboxNextButtonInfoPressed
	
			End Object
	
			Tag = "ScrollBox"
			PosX = 0.5
			PosY = 0.5
			PosXEnd = 0.75
			PosYEnd = 0.55
			bDrawCaption = True // We want the text to be drawn
	
			DrawInfo(0) = ScrollboxInfoDefault
			CaptionInfo(0) = BackStringInfo
			DrawInfo(1) = ScrollboxInfoDefault
			CaptionInfo(1) = BackStringInfo
			DrawInfo(3) = ScrollboxInfoDefault
			CaptionInfo(2) = BackStringInfo
	
			PreviousBtn = PreviousButton
			NextBtn = NextButton
	
			// Add the Items to the list
			bLocalizeCaption = False // False by default, but just a reminder that it can be localized
			ItemList(0)="Test"
			ItemList(1)="More Testing"
			ItemList(2)="Enough Testing"
			

	    End Object
		ChildComponents.Add(ScrollBox)
	
	    // Add the exit button as subobject.
	    Begin Object Class=GUITextBox Name=TextBox
			Tag = "TextBox"
			PosX = 0.5
			PosY = 0.1
			PosXEnd = 0.638888
            PosYEnd = 0.125
            ForcedDrawInfo = 0
    
            DrawInfo(0) = TextBoxInfo

			TextColor = (R=0,G=0,B=0,A=255) // Color we draw the text in.
	
	    End Object
		ChildComponents.Add(TextBox)
	End Object
	GUIComponents.Add(ShowScreen)

//=============================================================================

    Begin Object class=GUIMenuPageOptionScreen Name=OptionsScreen
        Tag="OptionsPage"
        bEnabled=False
	End Object
	GUIComponents.Add(OptionsScreen)
}