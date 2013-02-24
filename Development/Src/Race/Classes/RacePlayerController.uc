//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RacePlayerController extends UTPlayerController;

// Stamina that runs out and replenishes over time, controls our sprint
var int m_fStamina;
var int m_fMaxStamina;

// stamina that is recovered per second
var float m_fStaminaRecoveryRate;

// stamina that is drained per second
var float m_fStaminaDrainRate;

// How much stamina it costs to start a sprint
var float m_fSprintStartCost;

// True if we are sprinting
var repnotify bool m_bIsSprinting;

// How much we will multiply your speed by
var float m_fSprintMultiplier;

// The motion blur effect for unreal's post process chain
var PostProcessEffect m_MotionBlur;

// true if we are spectating
var bool bIsSpectating;

replication
{
	if( bNetDirty && Role==ROLE_Authority )
		m_bIsSprinting, m_fStamina;
}

simulated event ReplicatedEvent( name VarName )
{
	Super.ReplicatedEvent( VarName );

	if( VarName == 'm_bIsSprinting' )
	{
		if (m_MotionBlur != None)
		{
			m_MotionBlur.bShowInGame = m_bIsSprinting;
		}
	}
}

event InitInputSystem()
{
	Super.InitInputSystem();

	// Bind our alt key to the RUN command
	PlayerInput.SetBind( 'LeftShift', "Sprint_Start | OnRelease Sprint_Stop" );
}

function Restart(bool bVehicleTransition)
{
	Super.Restart(bVehicleTransition);

	if( Role == ROLE_Authority )
	{
		m_bIsSprinting = false;
		m_fStamina = m_fMaxStamina;
	}
}

/**
 * Hook called from HUD actor. Gives access to HUD and Canvas
 */
function DrawHUD( HUD H )
{
	local Canvas Canvas;
	local font OldFont;

	Super.DrawHUD( H );

 	Canvas = H.Canvas;

	OldFont = Canvas.Font;

	Canvas.Font = Font'UI_Fonts_Final.Menus.Fonts_Positec';

	Canvas.SetPos( 10.0f, 100);
	Canvas.DrawText( "Stamina" );

	// Sprinting, so make it yellow
	if( m_bIsSprinting )
	{
		Canvas.SetDrawColor(100,255,100);
	}
	else if( m_fStamina < m_fMaxStamina && !m_bIsSprinting )
	{
		if( m_fStamina < m_fSprintStartCost )
		{
			// Unable to start sprint, but recharging
			Canvas.SetDrawColor(255,100,100);
		}
		else
		{
			// Recharging
			Canvas.SetDrawColor(255,255,100);
		}
	}
	else if( m_fStamina == m_fMaxStamina )
	{
		// Full charge
		Canvas.SetDrawColor(255,255,255);
	}

	// Draw the current stamina
	Canvas.SetPos( 10.0f, 120 );
	Canvas.DrawText( string( m_fStamina ) );

	Canvas.Font = OldFont;
}

reliable client function ClientSetHUD( class<HUD> newHUDType, class<Scoreboard> newScoringType )
{
	Super.ClientSetHUD( newHUDType, newScoringType );

	m_MotionBlur = LocalPlayer(Player).PlayerPostProcess.FindPostProcessEffect('MotionBlur');
}

exec function Sprint_Start()
{
	Server_Sprint_Start();
}

unreliable server function Server_Sprint_Start()
{
	`log(" Sprint Start" );
	if( m_fStamina >= m_fSprintStartCost && Pawn != none )
	{
		m_fStamina -= m_fSprintStartCost;

		m_bIsSprinting = true;

		Pawn.GroundSpeed *= m_fSprintMultiplier;
		Pawn.AirSpeed *= m_fSprintMultiplier;

		if (m_MotionBlur != None)
		{
			m_MotionBlur.bShowInGame = false;
		}
	}
}

exec function Sprint_Stop()
{
	Server_Sprint_Stop();
}

reliable server function Server_Sprint_Stop()
{
	`log(" Sprint Stop ");

	if( Pawn != none )
	{
		m_bIsSprinting = false;

		Pawn.GroundSpeed = Pawn.default.GroundSpeed;
		Pawn.AirSpeed = Pawn.default.AirSpeed;;

		if (m_MotionBlur != None)
		{
			m_MotionBlur.bShowInGame = false;
		}
	}
}

state PlayerWalking
{
	// Seriously, this is the only way to get a tick?
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		Super.ProcessMove( DeltaTime,NewAccel,DoubleClickMove, DeltaRot );

		if( Role == ROLE_Authority )
		{

			if( m_bIsSprinting )
			{
				m_fStamina -= m_fStaminaDrainRate * DeltaTime;
			}
			else
			{
				m_fStamina += m_fStaminaRecoveryRate * DeltaTime;
			}

			m_fStamina = FClamp( m_fStamina, 0, m_fMaxStamina );

			if( m_fStamina <= 0 )
			{
				Server_Sprint_Stop();
			}
		}
	}
}

/** Play Camera Shake */
function PlayCameraShake( RaceScreenShakeStruct ScreenShake, optional bool bTryForceFeedback )
{
	if( Race_PlayerCamera(PlayerCamera) != None )
	{
		Race_PlayerCamera(PlayerCamera).PlayCameraShake( ScreenShake );
	}

	if ( bTryForceFeedback )
	{
		TryForceFeedback( ScreenShake );
	}
}

/**
 *  Play forcefeedback if needed
 */
simulated function TryForceFeedback( RaceScreenShakeStruct ShakeData )
{
	if( ShakeData.FOVAmplitude > 5 )
	{
		if( ShakeData.TimeDuration <= 1 )
		{
			//ClientPlayForceFeedbackWaveform(class'WarWaveForms'.default.CameraShakeBigShort);
		}
		else
		{
			//ClientPlayForceFeedbackWaveform(class'WarWaveForms'.default.CameraShakeBigLong);
		}
	}
	else
	{
		if( ShakeData.TimeDuration <= 1 )
		{
			//ClientPlayForceFeedbackWaveform(class'WarWaveForms'.default.CameraShakeMediumShort);
		}
		else
		{
			//ClientPlayForceFeedbackWaveform(class'WarWaveForms'.default.CameraShakeMediumLong);
		}
	}
}

DefaultProperties
{
	m_fStamina = 1000
	m_fMaxStamina = 1000

	m_fStaminaRecoveryRate = 333
	m_fStaminaDrainRate = 200
	m_fSprintStartCost = 100
	m_fSprintMultiplier = 2.0

	CameraClass=class'Race_PlayerCamera'
}