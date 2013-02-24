//=============================================================================
// GUIContainerComponent
//
// $wotgreal_dt: 07/10/2012 12:59:07 AM$
//
// This component has the purpose of holding multiple other components in order
// to form a frame for them. This allows not only to keep groups of components
// at the same place with different resolutions but also allows to create new
// windows and sections as the held components are not drawn if the container
// is not drawn. Basically it's a simple layer system besides the draw order.
//
// While the priority of the container still counts for the draw order of the
// base HUD, priority of components inside this one can start from 0 again
// as they are not directly known to the base HUD that holds the components.
// They will be all drawn when the container is drawn.
//=============================================================================
class GUIContainerComponent extends GUIComponent;

var() editinline instanced array<GUIComponent> ChildComponents;


// Watch this one carefully! If True it will set the origin and clipping end to
// the borders of this container while drawing the childs. That cuts off anything
// from the childs that goes over this border but also makes the child's location
// relative to the container.
var() bool bConstrainDrawAreaToContainer;





event InitializeComponent()
{
    local GUIComponent Comp;

    super.InitializeComponent();

    foreach ChildComponents(Comp)
    {
        Comp.ParentScene = ParentScene;
        Comp.InitializeComponent();
        Comp.Priority += Priority;
    }
}


// Returns a component that has been created as subobject with matching name.
final function GUIComponent FindComponentByTag(string ComponentTag)
{
    local GUIComponent Comp, Result;

    if (ComponentTag == "")
        return None;

    foreach ChildComponents(Comp)
    {
        Result = Comp.CheckComponentTag(ComponentTag);
        if (Result != None)
            return Result;
    }

    return None;
}


// Checks the ChildComponents for the specified Tag and returns one that matches.
// Otherwise none.
function GUIComponent CheckComponentTag(coerce string CompTag)
{
    local GUIComponent Comp, Result;

    if (CompTag == Tag)
        return self;

    foreach ChildComponents(Comp)
    {
        Result = Comp.CheckComponentTag(CompTag);
        if (Result != None)
        {
            return Result;
        }
    }

    return none;
}



/* Dirty hack here!
 * Other components will ask the container where it starts and where it ends
 * and with their default behavior they will start to draw at the end of the
 * component they asked.
 * But we want them to draw inside this component and not outside of it, so we
 * simply tell them that we end in the top left corner and start in the bottom
 * right one.
 */

function vector2d GetComponentStartPos(Canvas C)
{
    return super.GetComponentEndPos(C);
}

function vector2d GetComponentEndPos(Canvas C)
{
    return super.GetComponentStartPos(C);
}

// Keep this functional by using the unaltered version of the functions.
function vector2D GetComponentSize(Canvas C)
{
    local vector2D Start, End, Result;

    Start = super.GetComponentStartPos(C);
    End = super.GetComponentEndPos(C);

    Result.X = End.X - Start.X;
    Result.Y = End.Y - Start.Y;

    return Result;
}

function vector2D GetComponentCenter(Canvas C)
{
    local vector2D Start, End, Result;

    Start = super.GetComponentStartPos(C);
    End = super.GetComponentEndPos(C);

    Result.X = (End.X - Start.X)/2 + Start.X;
    Result.Y = (End.Y - Start.Y)/2 + Start.Y;

    return Result;
}


event DrawComponent(Canvas C)
{
    local GUIComponent Comp;
    local vector2d Start, End;
    local float TempOrgX, TempOrgY, TempClipX, TempClipY;

    if (!bEnabled)
        return;

    super.DrawComponent(C);

    if (bConstrainDrawAreaToContainer)
    {
        TempOrgX = C.OrgX;
        TempOrgY = C.OrgY;
        TempClipX = C.ClipX;
        TempClipY = C.ClipY;

        Start = super.GetComponentStartPos(C);
        End = super.GetComponentEndPos(C);

        C.SetOrigin(Start.X, Start.Y);
        C.SetClip(End.X, End.Y);
    }

    // Let all child components draw themselves.
    foreach ChildComponents(Comp)
    {
        if (!Comp.bCallCustomDraw || !Comp.CustomDrawComponent(C)) // Lazy evaluation magic.
            Comp.DrawComponent(C);
    }

    if (bConstrainDrawAreaToContainer)
    {
        C.SetOrigin(TempOrgX, TempOrgY);
        C.SetClip(TempClipX, TempClipY);
    }
}

event DrawDebugComponent(Canvas C)
{
    local GUIComponent Comp;
    local vector2d Start, End;
    local float TempOrgX, TempOrgY, TempClipX, TempClipY;

    if (!bEnabled)
        return;

    super.DrawDebugComponent(C);

    if (bConstrainDrawAreaToContainer)
    {
        TempOrgX = C.OrgX;
        TempOrgY = C.OrgY;
        TempClipX = C.ClipX;
        TempClipY = C.ClipY;

        Start = super.GetComponentStartPos(C);
        End = super.GetComponentEndPos(C);

        C.SetOrigin(Start.X, Start.Y);
        C.SetClip(End.X, End.Y);
    }

    // Let all child components draw themselves.
    foreach ChildComponents(Comp)
    {
        Comp.DrawDebugComponent(C);
    }

    if (bConstrainDrawAreaToContainer)
    {
        C.SetOrigin(TempOrgX, TempOrgY);
        C.SetClip(TempClipX, TempClipY);
    }
}

function GUIComponent CheckMouseFocus(Canvas C, int MouseX, int MouseY, out int BestPriority)
{
    local GUIComponent NewSelection, Result, Comp;

    foreach ChildComponents(Comp)
    {
        Result = Comp.CheckMouseFocus(C, MouseX, MouseY, BestPriority);
        if (Result != None)
        {
            NewSelection = Result;
        }
    }

    return NewSelection;
}

// Returns a numerical representation of the value that the component represents.
function float GetComponentValue()
{
    return ChildComponents.Length;
}

event DeleteGUIComp()
{
    local GUIComponent Cur;

    super.DeleteGUIComp();

    foreach ChildComponents(Cur)
    {
        Cur.DeleteGUIComp();
    }
}

function PrecacheComponentTextures(Canvas C)
{
	local GUIComponent Comp;

	foreach ChildComponents(Comp)
	{
		Comp.PrecacheComponentTextures(C);
	}
}

DefaultProperties
{

}