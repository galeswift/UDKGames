//=============================================================================
// GUIPage
//
// $wotgreal_dt: 23/08/2012 4:32:09 PM$
//
// This doesn't introduce any new functionality over the ContainerComponent but
// is rather meant to distinguish a different concept.
// A GUIPage is a container that holds all other GUIComponents that you can see
// on the screen at that time.
// There is only ever one GUIPage rendered at a time so your main menu screen
// could be one GUIPage and if you switch to your option menu screen,
// the main menu one would disappear and the option menu one would cover it.
// When you decided to go back to your main menu screen, the option one gets
// removed again and your main menu gets brought back up from where you left it.
//
// Internally this is handled as stack by the MenuScene, so you can push and
// pop screens any time the same way you can push and pop states in Actors.
//=============================================================================
class GUIPage extends GUIContainerComponent;

DefaultProperties
{
    PosX = 0.0
    PosY = 0.0
    PosXEnd = 1.0
    PosYEnd = 1.0
}