interface MouseInterfaceInteractionInterface;

// Called when the left mouse button is pressed
function MouseLeftPressed(Vector MouseWorldOrigin, Vector MouseWorldDirection, Vector HitLocation, Vector HitNormal);

// Called when the left mouse button is released
function MouseLeftReleased(Vector MouseWorldOrigin, Vector MouseWorldDirection);

// Called when the right mouse button is pressed
function MouseRightPressed(Vector MouseWorldOrigin, Vector MouseWorldDirection, Vector HitLocation, Vector HitNormal);

// Called when the right mouse button is released
function MouseRightReleased(Vector MouseWorldOrigin, Vector MouseWorldDirection);

// Called when the middle mouse button is pressed
function MouseMiddlePressed(Vector MouseWorldOrigin, Vector MouseWorldDirection, Vector HitLocation, Vector HitNormal);

// Called when the middle mouse button is released
function MouseMiddleReleased(Vector MouseWorldOrigin, Vector MouseWorldDirection);

// Called when the middle mouse button is scrolled up
function MouseScrollUp(Vector MouseWorldOrigin, Vector MouseWorldDirection);

// Called when the middle mouse button is scrolled down
function MouseScrollDown(Vector MouseWorldOrigin, Vector MouseWorldDirection);

// Called when the mouse is moved over the actor
function MouseOver(Vector MouseWorldOrigin, Vector MouseWorldDirection);

// Called when the mouse is moved out from the actor (when it was previously over it)
function MouseOut(Vector MouseWorldOrigin, Vector MouseWorldDirection);

// Returns the hit location of the mouse trace
function Vector GetHitLocation();

// Returns the hit normal of the mouse trace
function Vector GetHitNormal();

// Returns the mouse world origin calculated by the deprojection within the canvas
function Vector GetMouseWorldOrigin();

// Returns the mouse world direction calculated by the deprojection within the canvas
function Vector GetMouseWorldDirection();