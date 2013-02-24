//=============================================================================
// GUISliderButtonComponent
//
// $wotgreal_dt: 15.09.2012 23:58:20$
//
// Should be created within GUIBaseSliderComponent and be managed by it.
// Represents a value on a scale between a minimum and maximum.
//=============================================================================
class GUISliderButtonComponent extends GUIInteractiveComponent;;

var() GUIBaseSliderComponent SliderBase;

var() bool bAlternativePress;

event InitializeComponent()
{
    super.InitializeComponent();

    if (SliderBase != None)
        SliderBase.SliderButton = self;
    else if (GUIBaseSliderComponent(Outer) != None)
    {
        SliderBase = GUIBaseSliderComponent(Outer);
        SliderBase.SliderButton = self;
    }
}

event DragFailed();

event MousePressed(optional byte ButtonNum)
{
    super.MousePressed(ButtonNum);

    if(bAlternativePress)
    {
        MouseDiffX = Width/2;
        MouseDiffY = Height/2;
        bAlternativePress = False;
    }
    else
    {

        if(bRelativePosX)
            MouseDiffX = (ParentScene.MousePos.X / ClipX) - PosX;
        else
            MouseDiffX = ParentScene.MousePos.X - PosX;
        if(bRelativePosY)
            MouseDiffY = (ParentScene.MousePos.Y / ClipY) - PosY;
        else
            MouseDiffY = ParentScene.MousePos.Y - PosY;
    }
}

event MouseReleased(optional byte ButtonNum)
{
    super.MouseReleased(ButtonNum);

    SliderBase.MouseReleased(ButtonNum);
}

function MoveTo(IntPoint NewPos)
{
    PosX = FClamp(NewPos.X, SliderBase.PosX, SliderBase.PosXEnd - Width);
    PosXEnd = PosX + Width;
    PosY = FClamp(NewPos.Y, SliderBase.PosY, SliderBase.PosYEnd - Height);
    PosYEnd = PosY + Height;
}

// The component is being dragged
event Dragged(Vector2D NewPos)
{
    if (!bDragging)
        return;

    if(bRelativePosX)
        PosX = Fclamp(NewPos.X / ClipX - MouseDiffX, SliderBase.PosX, SliderBase.PosXEnd - Width);
    else
        PosX = Fclamp(NewPos.X - MouseDiffX, SliderBase.PosX, SliderBase.PosXEnd - Width);
    if(bRelativePosY)
        PosY = Fclamp(NewPos.Y / ClipY - MouseDiffY, SliderBase.PosY, SliderBase.PosYEnd - Height);
    else
        PosY = Fclamp(NewPos.Y - MouseDiffY, SliderBase.PosY, SliderBase.PosYEnd - Height);

    PosXEnd = PosX + Width;
    PosYEnd = PosY + Height;

    if (SliderBase != none)
        SliderBase.UpdateProgress();
}

singular event DeleteGUIComp()
{
    super.DeleteGUIComp();

    SliderBase = None;
}



DefaultProperties
{
    bCanDrag = True
}