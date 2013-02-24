class GPS_GCB_RunTowardsActor extends GPS_GCB_Base;

var Actor ChaseFocus;

function ActivatedBy(Actor NewActionTarget)
{
	// don't pass action target to super - we don't want to look at it
	ChaseFocus = NewActionTarget; 

	// see if already heading away from danger
	if( GPS_Pawn( NewActionTarget ) != none &&
		GPS_Pawn( NewActionTarget ).MyGCD != none )
	{
		MyAgent.CurrentDestination.DecrementCustomerCount(MyAgent);
		MyAgent.SetCurrentDestination( GPS_Pawn( NewActionTarget ).MyGCD );
	}
}

function InitBehavior(GameCrowdAgent Agent)
{
	super.InitBehavior(Agent);
	
	MyAgent.SetMaxSpeed();
}

function StopBehavior()
{
	Super.StopBehavior();
	MyAgent.SetMaxSpeed();
}

event PropagateViralBehaviorTo(GameCrowdAgent OtherAgent)
{
	if ( GPS_GameCrowdAgent( OtherAgent ) != none && 
		!GPS_GameCrowdAgent( OtherAgent ).IsChasing() )
	{
	//	OtherAgent.SetChase(ChaseFocus, true);
	}
}

DefaultProperties
{
}
