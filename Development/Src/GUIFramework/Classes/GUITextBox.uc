class GUITextBox extends GUIInteractiveComponent;

// If True, the component will accept input for text
var() bool bActive;

// If True, the typed input will be displayed as '*' characters
// Can be used for Passwords
var() bool bHideChars;

/** The command the user is currently typing. */
var() string TypedStr;
var() int TypedStrPos; //Current position in TypedStr

// Used to determine the change in position of the cursor
var bool bRight,bLeft,bAdd,bRemove,bDelete,bHome,bEnd;

var() string DrawString; // String that is displayed
var() int DrawStart; //starting index from TypedStr to draw.

// Font and Color used for displaying the text
var() Font TextFont;
var() Color TextColor;

var int RemoveLeft;
var float xBorder; // amount of pixels the text will start from the left side of the component

/**
 * Indicates that InputChar events should be captured to prevent them from being passed on to other interactions.  Reset
 * when the another keydown event is received.
 */
var() transient   bool bCaptureKeyInput;


// This sets the Input text, not what is actually displayed
function SetInputText( string Text )
{
    TypedStr = Text;
}

// Sets the Cursor to a new position
function SetCursorPos( int Position )
{
    TypedStrPos = Position;
}

event MouseReleased(optional byte ButtonNum)
{
    super.MouseReleased(ButtonNum);
    // Become active when clicked
    SetActive(True);
}

// Used to toggle between Active and Inactive
function SetActive(bool bStatus)
{
    bActive = bStatus;
    if(bActive)
    {
        bCaptureKeyInput = True;
    }
    else
    {
        bCaptureKeyInput = False;
    }
}

function HardClose()
{
    SetActive(False);
}

/**
 * Opens the typing bar with text already entered.
 * @param Text - The text to enter in the typing bar.
 */
function StartTyping(coerce string Text)
{
    SetInputText(Text);
    SetCursorPos(Len(Text));
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
    DrawText(C);
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
        if(!bActive)
            return False;

        if (Event == IE_Pressed)
        {
            bCaptureKeyInput=false;
        }
        else if( Key=='Enter' && Event == IE_Released )
        {
            SetActive(false);

            return true;
        }
        else if( Key=='backspace' )
        {
            if( TypedStrPos>0 )
            {
                SetInputText(Left(TypedStr,TypedStrPos-1) $ Right(TypedStr, Len(TypedStr) - TypedStrPos));
                SetCursorPos(TypedStrPos-1);
                bRemove = True;
            }

            return true;
        }
        else if ( Key=='delete' )
        {
            if ( TypedStrPos < Len(TypedStr) )
            {
                SetInputText(Left(TypedStr,TypedStrPos) $ Right(TypedStr, Len(TypedStr) - TypedStrPos - 1));
                bDelete = True;
            }
            return true;
        }
        else if ( Key=='left' )
        {
            SetCursorPos(Max(0, TypedStrPos - 1));
            bLeft = True;
            return true;
        }
        else if ( Key=='right' )
        {
            SetCursorPos(Min(Len(TypedStr), TypedStrPos + 1));
            bRight = True;
            return true;
        }
        else if ( Key=='home' )
        {
            SetCursorPos(0);
            bHome = true;
            return true;
        }
        else if ( Key=='end' )
        {
            SetCursorPos(Len(TypedStr));
            bEnd = True;
            return true;
        }

        return TRUE;
}

/**
 * Process a character input event (typing) routed through unrealscript from another object. This method is assigned as the value for the
 * OnRecievedNativeInputKey delegate so that native input events are routed to this unrealscript function.
 *
 * @param   ControllerId    the controller that generated this character input event
 * @param   Unicode         the character that was typed
 *
 * @return  True to consume the character, false to pass it on.
 */
function bool InputChar( int ControllerId, string Unicode )
{
    if ( bCaptureKeyInput )
    {
        return true;
    }

    AppendInputText(Unicode);

    return true;
}

/** appends the specified text to the string of typed text */
function AppendInputText(string Text)
{
    local int Character;

    while (Len(Text) > 0)
    {
        bAdd = True;

        Character = Asc(Left(Text, 1));
        Text = Mid(Text, 1);

        if (Character >= 0x20 && Character < 0x100)
        {
            SetInputText(Left(TypedStr, TypedStrPos) $ Chr(Character) $ Right(TypedStr, Len(TypedStr) - TypedStrPos));
            SetCursorPos(TypedStrPos + 1);
        }
    };
}

event DrawText(Canvas Canvas)
{
    local float Heightn;
    local float xl, yl,xln,X,Y;
    local int i;
    local string Temp;
    X = PosX;
    Y = PosY;

    Heightn = PosYEnd - PosY;

    if(bRelativePosX)
        X *= Canvas.ClipX;
    if(bRelativePosY)
    {
        Y *= Canvas.ClipY;
        Heightn *= Canvas.ClipY;
    }

    // Set the Font
    Canvas.Font = TextFont;

    // The text is centered in Height
    Heightn = (Heightn/2 + Y);

    SetDrawString(Canvas);
    if(bHideChars)
    {
        while(i < Len(DrawString))
        {
            Temp $= "*";
            i++;
        }
        DrawString = Temp;
    }
    // determine the Height of the text
    Canvas.StrLen(DrawString,xl,yl);

    // change the draw color
    Canvas.SetDrawColor(TextColor.R,TextColor.G,TextColor.B,TextColor.A);

    // center the pen between the two borders
    Canvas.SetPos(X + xBorder/2,Heightn-(yl/2));
    Canvas.bCenter = False;

    // render the text that is being typed
    Canvas.DrawText(DrawString,false);
    // position the pen at the cursor position
    Canvas.StrLen(Left(DrawString,TypedStrPos - DrawStart),xl,yl);
    if(Len(Left(DrawString,TypedStrPos - DrawStart)) == 0)
    {
        Canvas.StrLen("a",xln,yl);
    }
    Canvas.SetPos(X + xl + xBorder/2,Heightn-(yl/2));

    // render the cursor
    if(bActive)
        Canvas.DrawText("_");
}


// This calculates what part of the TypedStr should be displayed
function SetDrawString(Canvas C)
{
    local float XL,YL,X;
    local int i;

    X = PosXEnd - PosX;
    if(bRelativePosX)
        X *= C.ClipX;
    X -= xBorder;

    if(bRight)
    {
        if(TypedStrPos >= DrawStart + Len(DrawString) && TypedStrPos < Len(TypedStr))
        {
            DrawStart++;
            DrawString = Mid(TypedStr,DrawStart,TypedStrPos - DrawStart + 1);
            C.StrLen(DrawString,XL,YL);
            i = 1;
            while(XL > X)
            {
                DrawString = Right(DrawString,Len(DrawString) - 1);
                C.StrLen(DrawString,XL,YL);
                DrawStart++;
            }
        }
        if(TypedStrPos == Len(TypedStr) )
        {
            DrawStart = 0;
            C.StrLen("_",XL,YL);
            X -= XL;
            DrawString = TypedStr;
            C.StrLen(DrawString,XL,YL);
            while(XL > X)
            {
                DrawString = Right(DrawString,Len(DrawString) - 1);
                C.StrLen(DrawString,XL,YL);
                DrawStart++;
            }
        }
        bRight = false;
    }
    if(bLeft)
    {
        if(TypedStrPos - InStr(TypedStr,DrawString) < 2)
        {
            DrawStart = Max(0,TypedStrPos - 1);
            DrawString = Mid(TypedStr,DrawStart);
            C.StrLen(DrawString,XL,YL);
            while( XL > X)
            {
                DrawString = Mid(TypedStr,DrawStart,Len(DrawString) - 1);
                C.StrLen(DrawString,XL,YL);
            }
        }
        bLeft = False;
    }
    if(bHome)
    {
        DrawStart = 0;
        DrawString = TypedStr;
        C.StrLen(DrawString,XL,YL);
        while( XL > X)
        {
            DrawString = Left(DrawString,Len(DrawString) - 1);
            C.StrLen(DrawString,XL,YL);
        }
        bHome = false;
    }
    if(bEnd)
    {
        DrawStart = 0;
        C.StrLen("_",XL,YL);
        X -= XL;
        DrawString = TypedStr;
        C.StrLen(DrawString,XL,YL);
        while(XL > X)
        {
            DrawString = Right(DrawString,Len(DrawString) - 1);
            C.StrLen(DrawString,XL,YL);
            DrawStart++;
        }
        bEnd = False;
    }
    if(bDelete)
    {
        if(TypedStrPos != Len(TypedStr) )
        {
            DrawString = Mid(TypedStr,DrawStart);
            C.StrLen(DrawString,XL,YL);
            while(XL > X)
            {
                DrawString = Left(DrawString,Len(DrawString) - 1);
                C.StrLen(DrawString,XL,YL);
            }
        }
        bDelete = False;
    }
    if(bRemove)
    {
        if(TypedStrPos == Len(TypedStr) )
        {
            C.StrLen("_",XL,YL);
            X -= XL;
            DrawStart = Max(0,DrawStart - 1);
        }
        DrawString = Mid(TypedStr,DrawStart);
        C.StrLen(DrawString,XL,YL);
        while( XL > X)
        {
            DrawString = Mid(TypedStr,DrawStart,Len(DrawString) - 1);
            C.StrLen(DrawString,XL,YL);
        }
        bRemove = false;
    }
    if(bAdd)
    {
        if( Len(TypedStr) == TypedStrPos)
        {
            C.StrLen("_",XL,YL);
            X -= XL;
            i = 1;
            DrawString = Right(TypedStr,i);
            C.StrLen(DrawString,XL,YL);
            while( XL < X && Len(DrawString) < Len(TypedStr) )
            {
                i++;
                DrawString = Right(TypedStr,i);
                C.StrLen(DrawString,XL,YL);
            }
            while( XL > X)
            {
                DrawString = Right(TypedStr,Len(DrawSTring) - 1);
                C.StrLen(DrawString,XL,YL);
            }
            DrawStart = InStr(TypedStr,DrawString);
        }
        else
        {
            DrawString = Mid(TypedStr,DrawStart);
            C.StrLen(DrawString,XL,YL);
            while( XL > X )
            {
                DrawString = Mid(TypedStr,DrawStart,Len(DrawString) - 1);
                C.StrLen(DrawString,XL,YL);
            }
        }
        bAdd = false;
    }
}

event DeleteGUIComp()
{
    TextFont = None;

    super.DeleteGUIComp();

}

defaultproperties
{
    bReceiveText = True
    TextFont = Font'EngineFonts.SmallFont'
    TextColor = (R=255,G=255,B=240,A=255)
    xBorder = 10;
}
