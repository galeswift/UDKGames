class GPS_Handler_GroundAOE_CC extends GPS_Handler_GroundAOE;

// All actors we've hit
var array<Actor> PrevHitList;

function DoNextDamage()
{
	local array<Actor> CurrentTargets;
	local int i, j, m, n;
	local bool bIsPreviousTarget, bIsCurrentTarget;

	if( HitsLeft > 0 )
	{
		CurrentTargets = FindTargets();

		// Remove all targets from previous hit list that are not current targets
		for ( m = 0; m < PrevHitList.Length; m++ )
		{
			bIsCurrentTarget = false;
			for ( n = 0; n < CurrentTargets.Length; n++ )
			{
				if ( PrevHitList[m] == CurrentTargets[n] )
				{
					bIsCurrentTarget = true;
					break;
				}
			}
			if ( !bIsCurrentTarget )
			{				
				GPS_GameCrowdAgent(PrevHitList[m]).SetModifiedMovement( 0.0f );
				GPS_GameCrowdAgent(PrevHitList[m]).SetMaxSpeed();
				PrevHitList.Remove(m,1);
			}
		}

		// Slow current targets if they have not already been slowed
		for ( i = 0; i < CurrentTargets.Length; i++ )
		{
			bIsPreviousTarget = false;
			for ( j = 0; j < PrevHitList.Length; j++ )
			{
				if ( CurrentTargets[i] == PrevHitList[j] )
				{
					bIsPreviousTarget = true;
					break;
				}
			}
			if ( !bIsPreviousTarget )
			{
				GPS_GameCrowdAgent(CurrentTargets[i]).SetModifiedMovement( GPS_Weap_GrenadeLauncher_GroundAOE_CC(WeaponOwner).ModifiedMovementPercentage );
				GPS_GameCrowdAgent(CurrentTargets[i]).SetMaxSpeed();
				PrevHitList[PrevHitList.Length] = CurrentTargets[i];
			}
		}
	}

	Super.DoNextDamage();
}

function EndGroundAOE()
{
	local int i;

	for ( i = 0; i < PrevHitList.Length; i++ )
	{
		GPS_GameCrowdAgent(PrevHitList[i]).SetModifiedMovement( 0.0f );
		GPS_GameCrowdAgent(PrevHitList[i]).SetMaxSpeed();
	}

	Super.EndGroundAOE();
}

DefaultProperties
{

}
