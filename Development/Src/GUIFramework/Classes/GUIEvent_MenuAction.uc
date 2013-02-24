//------------------------------------------------------------------------------
// A SeqEvent that can get assigned a Tag and then get activated from a MenuScene.
//------------------------------------------------------------------------------
class GUIEvent_MenuAction extends SequenceEvent;

// The MenuScene will identify specific events by their tag.
var()   string              ActivationTag<autocomment=true>;

DefaultProperties
{
    ObjName="MenuScene Action"
    ObjCategory="GFx UI"

    VariableLinks.Empty
    bPlayerOnly=false
    MaxTriggerCount=0
    bSuppressAutoComment=false
}