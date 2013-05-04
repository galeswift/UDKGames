class MouseInterfaceHUD extends HUD;

// The texture which represents the cursor on the screen
var const Texture2D CursorTexture;
// The color of the cursor
var const Color CursorColor;
// Pending left mouse button pressed event
var bool PendingLeftPressed;
// Pending left mouse button released event
var bool PendingLeftReleased;
// Pending right mouse button pressed event
var bool PendingRightPressed;
// Pending right mouse button released event
var bool PendingRightReleased;
// Pending middle mouse button pressed event
var bool PendingMiddlePressed;
// Pending middle mouse button released event
var bool PendingMiddleReleased;
// Pending mouse wheel scroll up event
var bool PendingScrollUp;
// Pending mouse wheel scroll down event
var bool PendingScrollDown;
// Cached mouse world origin
var Vector CachedMouseWorldOrigin;
// Cached mouse world direction
var Vector CachedMouseWorldDirection;
// Last mouse interaction interface
var Actor LastMouseInteractionActor;
// Use ScaleForm?
var bool UsingScaleForm;
// Scaleform mouse movie
var MouseInterfaceGFx MouseInterfaceGFx;

// Save this off in case we don't have a canvas
var vector LastMouseLocation;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// If we are using ScaleForm, then create the ScaleForm movie
	if (UsingScaleForm)
	{
		MouseInterfaceGFx = new () class'MouseInterfaceGFx';
		if (MouseInterfaceGFx != None)
		{
			MouseInterfaceGFx.MouseInterfaceHUD = Self;
			MouseInterfaceGFx.SetTimingMode(TM_Game);

			MouseInterfaceGFx.Init(class'Engine'.static.GetEngine().GamePlayers[MouseInterfaceGFx.LocalPlayerOwnerIndex]);
		}
	}
}

simulated event Destroyed()
{
	Super.Destroyed();
	
	// If the ScaleForm movie exists, then destroy it
	if (MouseInterfaceGFx != None)
	{
		MouseInterfaceGFx.Close(true);
		MouseInterfaceGFx = None;
	}
}

function PreCalcValues()
{
	Super.PreCalcValues();

	// If the ScaleForm movie exists, then reset it's viewport, scale mode and alignment to match the
	// screen resolution
	if (MouseInterfaceGFx != None)
	{
		MouseInterfaceGFx.SetViewport(0, 0, SizeX, SizeY);
		MouseInterfaceGFx.SetViewScaleMode(SM_NoScale);
		MouseInterfaceGFx.SetAlignment(Align_TopLeft);	
	}
}

event PostRender()
{
	local MouseInterfacePlayerInput MouseInterfacePlayerInput;
	local Actor MouseInteractionActor;
	local Vector HitLocation, HitNormal;

	Super.PostRender();

	// Ensure that we aren't using ScaleForm and that we have a valid cursor
	if (!UsingScaleForm && CursorTexture != None)
	{
		// Ensure that we have a valid PlayerOwner
		if (PlayerOwner != None)
		{
			// Cast to get the MouseInterfacePlayerInput
			MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

			// If we're not using scale form and we have a valid cursor texture, render it
			if (MouseInterfacePlayerInput != None)
			{
				// Set the canvas position to the mouse position
				Canvas.SetPos(MouseInterfacePlayerInput.MousePosition.X, MouseInterfacePlayerInput.MousePosition.Y);
				// Set the cursor color
				Canvas.DrawColor = CursorColor;
				// Draw the texture on the screen
				Canvas.DrawTile(CursorTexture, CursorTexture.SizeX, CursorTexture.SizeY, 0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, true);
			}
		}
	}

	// Get the current mouse interaction interface
	MouseInteractionActor = GetMouseActor(HitLocation, HitNormal);

	// Handle mouse over and mouse out
	// Did we previously had a mouse interaction interface?
	if (LastMouseInteractionActor != None)
	{
		// If the last mouse interaction interface differs to the current mouse interaction
		if (LastMouseInteractionActor != MouseInteractionActor)
		{
			// Call the mouse out function
			//LastMouseInteractionActor.MouseOut(CachedMouseWorldOrigin, CachedMouseWorldDirection);
			TriggerMouseEvent(LastMouseInteractionActor, 11, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);

			// Assign the new mouse interaction interface
			LastMouseInteractionActor = MouseInteractionActor; 

			// If the last mouse interaction interface is not none
			if (LastMouseInteractionActor != None)
			{
				// Call the mouse over function
				//LastMouseInteractionActor.MouseOver(CachedMouseWorldOrigin, CachedMouseWorldDirection); // Call mouse over
				TriggerMouseEvent(LastMouseInteractionActor, 10, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
			}
		}
	}
	else if (MouseInteractionActor != None)
	{
		// Assign the new mouse interaction interface
		LastMouseInteractionActor = MouseInteractionActor; 
		// Call the mouse over function
		//LastMouseInteractionActor.MouseOver(CachedMouseWorldOrigin, CachedMouseWorldDirection); 
		TriggerMouseEvent(LastMouseInteractionActor, 10, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
	}


	// Handle left mouse button
	if (PendingLeftPressed)
	{
		if (PendingLeftReleased)
		{
			// This is a left click, so discard
			PendingLeftPressed = false;
			PendingLeftReleased = false;
		}
		else
		{
			// Left is pressed
			PendingLeftPressed = false;
			//LastMouseInteractionActor.MouseLeftPressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
			TriggerMouseEvent(MouseInteractionActor,0, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
		}
	}
	else if (PendingLeftReleased)
	{
		// Left is released
		PendingLeftReleased = false;
		//LastMouseInteractionActor.MouseLeftReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
		TriggerMouseEvent(MouseInteractionActor,1, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
	}

	// Handle right mouse button
	if (PendingRightPressed)
	{
		if (PendingRightReleased)
		{
			// This is a right click, so discard
			PendingRightPressed = false;
			PendingRightReleased = false;
		}
		else
		{
			// Right is pressed
			PendingRightPressed = false;
			//LastMouseInteractionActor.MouseRightPressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
			TriggerMouseEvent(MouseInteractionActor,2, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
		}
	}
	else if (PendingRightReleased)
	{
		// Right is released
		PendingRightReleased = false;
		//LastMouseInteractionActor.MouseRightReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
		TriggerMouseEvent(MouseInteractionActor,3, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
	}

	// Handle middle mouse button
	if (PendingMiddlePressed)
	{
		if (PendingMiddleReleased)
		{
			// This is a middle click, so discard 
			PendingMiddlePressed = false;
			PendingMiddleReleased = false;
		}
		else
		{
			// Middle is pressed
			PendingMiddlePressed = false;
			//LastMouseInteractionActor.MouseMiddlePressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
			TriggerMouseEvent(MouseInteractionActor,4, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
		}
	}
	else if (PendingMiddleReleased)
	{
		PendingMiddleReleased = false;
		//LastMouseInteractionActor.MouseMiddleReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
		TriggerMouseEvent(MouseInteractionActor,5, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
	}

	// Handle middle mouse button scroll up
	if (PendingScrollUp)
	{
		PendingScrollUp = false;
		//LastMouseInteractionActor.MouseScrollUp(CachedMouseWorldOrigin, CachedMouseWorldDirection);
		TriggerMouseEvent(MouseInteractionActor,6, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
	}

	// Handle middle mouse button scroll down
	if (PendingScrollDown)
	{
		PendingScrollDown = false;
		//LastMouseInteractionActor.MouseScrollDown(CachedMouseWorldOrigin, CachedMouseWorldDirection);
		TriggerMouseEvent(MouseInteractionActor,7, CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
	}

	// Used to cache the current mouse location
	GetMouseWorldLocation();
}

function bool TriggerMouseEvent(Actor HitActor, int Type, Vector MouseWorldOrigin, Vector MouseWorldDirection, Vector HitLocation = vect(0,0,0), Vector HitNormal = vect(0,0,0))
{
	local array<SequenceObject> EventsToActivate;
	local array<int> ActivateIndices;
	local SeqEvent_MouseInput MouseInputEvent;
	local Sequence GameSeq;
	local bool bResult;
	local int i;

	ActivateIndices[0] = Type;

	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != None)
	{
		GameSeq.FindSeqObjectsByClass(class'SeqEvent_MouseInput', true, EventsToActivate);
		for (i = 0; i < EventsToActivate.length; i++)
		{
			MouseInputEvent = SeqEvent_MouseInput(EventsToActivate[i]);
			MouseInputEvent.HitActor = HitActor;
			MouseInputEvent.HitLocation = HitLocation;
			MouseInputEvent.HitNormal = HitNormal;
			MouseInputEvent.MouseWorldDirection = MouseWorldDirection;
			MouseInputEvent.MouseWorldOrigin = MouseWorldOrigin;

			if (MouseInputEvent.CheckActivate(self, HitActor,, ActivateIndices))
			{					
				bResult = true;
			}
		}
	}

	return bResult;
}

function Actor GetMouseActor(optional out Vector HitLocation, optional out Vector HitNormal)
{
	local MouseInterfacePlayerInput MouseInterfacePlayerInput;
	local Vector2D MousePosition;
	local Actor HitActor;

	// Ensure that we have a valid canvas and player owner
	if (Canvas == None || PlayerOwner == None)
	{
		return None;
	}

	// Type cast to get the new player input
	MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

	// Ensure that the player input is valid
	if (MouseInterfacePlayerInput == None)
	{
		return None;
	}

	// We stored the mouse position as an IntPoint, but it's needed as a Vector2D
	MousePosition.X = MouseInterfacePlayerInput.MousePosition.X;
	MousePosition.Y = MouseInterfacePlayerInput.MousePosition.Y;
	// Deproject the mouse position and store it in the cached vectors
	Canvas.DeProject(MousePosition, CachedMouseWorldOrigin, CachedMouseWorldDirection);

	// Perform a trace actor interator. An interator is used so that we get the top most mouse interaction
	// interface. This covers cases when other traceable objects (such as static meshes) are above mouse
	// interaction interfaces.
	ForEach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, CachedMouseWorldOrigin + CachedMouseWorldDirection * 65536.f, CachedMouseWorldOrigin,,, TRACEFLAG_Bullet)
	{
		if (HitActor != None)
		{
			return HitActor;
		}
	}
	HitLocation = CachedMouseWorldOrigin + CachedMouseWorldDirection * 65536.f;
	HitNormal = -CachedMouseWorldDirection;
	return None;
}

function Vector GetMouseWorldLocation()
{
  local MouseInterfacePlayerInput MouseInterfacePlayerInput;
  local Vector2D MousePosition;
  local Vector MouseWorldOrigin, MouseWorldDirection, HitLocation, HitNormal;

  // Ensure that we have a valid canvas and player owner
  if (Canvas == None || PlayerOwner == None)
  {
    return LastMouseLocation;
  }

  // Type cast to get the new player input
  MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

  // Ensure that the player input is valid
  if (MouseInterfacePlayerInput == None)
  {
    return LastMouseLocation;
  }

  // We stored the mouse position as an IntPoint, but it's needed as a Vector2D
  MousePosition.X = MouseInterfacePlayerInput.MousePosition.X;
  MousePosition.Y = MouseInterfacePlayerInput.MousePosition.Y;
  // Deproject the mouse position and store it in the cached vectors
  Canvas.DeProject(MousePosition, MouseWorldOrigin, MouseWorldDirection);

  // Perform a trace to get the actual mouse world location.
  if( Trace(HitLocation, HitNormal, MouseWorldOrigin + MouseWorldDirection * 65536.f, MouseWorldOrigin , true,,, TRACEFLAG_Bullet) != none )
  {
	  LastMouseLocation = HitLocation;
  }
  else
  {
	LastMouseLocation = MouseWorldOrigin + MouseWorldDirection * 65536.f;
  }
  return LastMouseLocation;
}

defaultproperties
{
	// Set to false if you wish to use Unreal's player input to retrieve the mouse coordinates
	UsingScaleForm=true
	CursorColor=(R=255,G=255,B=255,A=255)
	CursorTexture=Texture2D'EngineResources.Cursors.Arrow'
}
