class GUIScrollBoxButtonComponent extends GUIInteractiveComponent;;

var() GUIScrollBoxComponent ScrollBoxBase;
var() bool bNext;

event InitializeComponent()
{
    super.InitializeComponent();

    if(ScrollBoxBase == none && GUIScrollBoxComponent(Outer) != None)
        ScrollBoxBase = GUIScrollBoxComponent(Outer);
    if (ScrollBoxBase != None)
    {
        if(bNext)
            ScrollBoxBase.NextBtn = self;
        else
            ScrollBoxBase.PreviousBtn = self;
    }
}

event MouseReleased(optional byte ButtonNum)
{
    super.MouseReleased(ButtonNum);

    if(ScrollBoxBase != none)
    {
        if(bNext)
            ScrollBoxBase.NextItem();
        else
            ScrollBoxBase.PreviousItem();
    }
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
            ScrollBoxBase.NextItem();
            return True;
        }
        if(Key == 'Left')
        {
            ScrollBoxBase.PreviousItem();
            return True;
        }
    }
    return super.InputKey(ControllerID,Key,Event,AmountDepressed,bGamepad);
}

event DeleteGUIComp()
{
    super.DeleteGUIComp();

    ScrollBoxBase = none;
}

DefaultProperties
{
}