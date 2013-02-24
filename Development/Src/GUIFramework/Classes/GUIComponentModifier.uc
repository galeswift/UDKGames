//=============================================================================
// GUIComponentModifier
//
// $wotgreal_dt: 25.05.2012 12:22:57$
//
// This handles changes in the GUIComponent it's linked to.
// Currently the only change is the position of the component.
// You specify the goal value and the transition time and this thing does the
// rest.
//=============================================================================
class GUIComponentModifier extends GUIComponent
    noteditinlinenew;

var() GUIComponent TargetComponent;



// The target position after the move.
var float FinalPosX, FinalPosY, FinalPosXEnd, FinalPosYEnd;

// How long the move should take and how long it took already.
var float FullMoveTime, CurrentMoveTime;


// How the component should move. 0 = not; 1 = linear; 2 = sine;
var byte MovementTypeIndex;


/**
 * Moves a component smoothly to a new position in a constant time.
 *
 * @param NewPos: the final destination of the component after the move
 * @param MoveTime: how fast the component moves to the new place.
 */
function MoveContainerLinear(float NewPosX, float NewPosY, float NewPosXEnd, float NewPosYEnd, float MoveTime)
{
    FinalPosX = NewPosX;
    FinalPosY = NewPosY;
    FinalPosXEnd = NewPosXEnd;
    FinalPosYEnd = NewPosYEnd;
    PosX = TargetComponent.PosX;
    PosY = TargetComponent.PosY;
    PosXEnd = TargetComponent.PosXEnd;
    PosYEnd = TargetComponent.PosYEnd;

    FullMoveTime = MoveTime;
    CurrentMoveTime = 0;

    MovementTypeIndex = 1;
}

/**
 * Moves a component to a new position in a constant time while slowly accelerating
 * and breaking at the start and end.
 * The linear solution has slightly better performance.
 *
 * @param NewPos: the final destination of the component after the move
 * @param MoveTime: how fast the component moves to the new place.
 */
function MoveContainerSine(float NewPosX, float NewPosY, float NewPosXEnd, float NewPosYEnd, float MoveTime)
{
    FinalPosX = NewPosX;
    FinalPosY = NewPosY;
    FinalPosXEnd = NewPosXEnd;
    FinalPosYEnd = NewPosYEnd;
    PosX = TargetComponent.PosX;
    PosY = TargetComponent.PosY;
    PosXEnd = TargetComponent.PosXEnd;
    PosYEnd = TargetComponent.PosYEnd;

    FullMoveTime = MoveTime;
    CurrentMoveTime = 0;

    MovementTypeIndex = 2;
}


event DrawComponent(Canvas C) // Replaces Tick.
{
    switch(MovementTypeIndex)
    {
        case 0:
            break;

        case 1:
            CurrentMoveTime += ParentScene.GetRenderDelta();

            if (CurrentMoveTime >= FullMoveTime)
            {
                TargetComponent.PosX = FinalPosX;
                TargetComponent.PosY = FinalPosY;
                TargetComponent.PosXEnd = FinalPosXEnd;
                TargetComponent.PosYEnd = FinalPosYEnd;

                MovementTypeIndex = 0;

                TargetComponent.ComponentMoved(self);
            }
            else
            {
                TargetComponent.PosX = Lerp(PosX, FinalPosX, CurrentMoveTime/FullMoveTime);
                TargetComponent.PosY = Lerp(PosY, FinalPosY, CurrentMoveTime/FullMoveTime);
                TargetComponent.PosXEnd = Lerp(PosXEnd, FinalPosXEnd, CurrentMoveTime/FullMoveTime);
                TargetComponent.PosXEnd = Lerp(PosYEnd, FinalPosYEnd, CurrentMoveTime/FullMoveTime);
            }
            break;

        case 2:
            CurrentMoveTime += ParentScene.GetRenderDelta();

            if (CurrentMoveTime >= FullMoveTime)
            {
                TargetComponent.PosX = FinalPosX;
                TargetComponent.PosY = FinalPosY;
                TargetComponent.PosXEnd = FinalPosXEnd;
                TargetComponent.PosYEnd = FinalPosYEnd;

                MovementTypeIndex = 0;

                TargetComponent.ComponentMoved(self);
            }
            else
            {
                TargetComponent.PosX = Lerp(PosX, FinalPosX, Sin((CurrentMoveTime * Pi / FullMoveTime) - (Pi*0.5)) + 1);
                TargetComponent.PosY = Lerp(PosY, FinalPosY, Sin((CurrentMoveTime * Pi / FullMoveTime) - (Pi*0.5)) + 1);
                TargetComponent.PosXEnd = Lerp(PosXEnd, FinalPosXEnd, Sin((CurrentMoveTime * Pi / FullMoveTime) - (Pi*0.5)) + 1);
                TargetComponent.PosXEnd = Lerp(PosYEnd, FinalPosYEnd, Sin((CurrentMoveTime * Pi / FullMoveTime) - (Pi*0.5)) + 1);
            }
            break;
    }
}

// Stub to prevent circular loops.
function MoveComponent(Canvas C, float MoveTime, float NewX, float NewY, optional float NewEndX, optional float NewEndY, optional byte MovementType);
event ComponentMoved(GUIComponentModifier CompMod);

event DeleteGUIComp()
{
    super.DeleteGUIComp();

    TargetComponent = none;
}

DefaultProperties
{

}