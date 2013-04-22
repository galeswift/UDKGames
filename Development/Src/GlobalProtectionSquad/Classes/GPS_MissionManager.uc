class GPS_MissionManager extends Actor;

/* Updated as we start missions and kill enemies */
enum MissionStatus
{
	MS_NoMission,
	MS_Inactive,
	MS_InProgress,
	MS_Completed,
};

/* List of pickups the player has received during this mission */
var array<GPS_Pickup> AllPickups;

/* Currently active mission */
var GPS_Mission CurrentMission;

/* Currently active wave */
var int CurrentWave;

/* Current mission status */
var MissionStatus CurrentMissionStatus;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	CurrentMissionStatus = MS_NoMission;
}

function StartMission(GPS_Mission Mission, optional int Wave = 0)
{
	local array<SequenceObject> SpawnerActions;
	local SeqAct_UTCrowdSpawner CurrentSpawner;
	local Sequence GameSeq;
	local int Idx;
	
	CurrentMission = Mission;
	CurrentMission.EnemyList[Wave].KilledEnemyCount = 0;
	CurrentWave = 0;

	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != None)
	{
		GameSeq.FindSeqObjectsByClass(class'SeqAct_UTCrowdSpawner',TRUE,SpawnerActions);
		for (Idx = 0; Idx < SpawnerActions.Length; Idx++)
		{
			CurrentSpawner = SeqAct_UTCrowdSpawner(SpawnerActions[Idx]);
			if (CurrentSpawner != None)
			{
				CurrentSpawner.CrowdAgentList = Mission.EnemyList[Wave].EnemyType;
				CurrentSpawner.MaxAgents = Mission.EnemyList[Wave].EnemyCount;
				CurrentSpawner.ForceActivateInput(0);
				CurrentMissionStatus = MS_InProgress;
			}
		}
	}
}

function CompleteMission( GPS_Mission Mission )
{
	local array<SequenceObject> SpawnerActions;
	local SeqAct_UTCrowdSpawner CurrentSpawner;
	local Sequence GameSeq;
	local int Idx;
	
	CurrentMissionStatus = MS_Completed;

	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != None)
	{
		GameSeq.FindSeqObjectsByClass(class'SeqAct_UTCrowdSpawner',TRUE,SpawnerActions);
		for (Idx = 0; Idx < SpawnerActions.Length; Idx++)
		{
			CurrentSpawner = SeqAct_UTCrowdSpawner(SpawnerActions[Idx]);
			if (CurrentSpawner != None)
			{
				// Stop and kill is 4.  Just stop is 1
				CurrentSpawner.ForceActivateInput(4);
			}
		}
	}
}

function NotifyKilledEnemy(Actor KilledEnemy)
{
	if( CurrentMissionStatus == MS_InProgress )
	{
		CurrentMission.EnemyList[CurrentWave].KilledEnemyCount++;

		if( CurrentMission.GetEnemiesLeft(CurrentWave) <= 0 )
		{
			CompleteMission(CurrentMission);
		}
	}
}

simulated event PostRender(Canvas C)
{
	local string missionStr;
	// Draw EXP on the screen
	missionStr = "Current mission=["$CurrentMission$"] Enemies Left to kill=["$CurrentMission.GetEnemiesLeft(CurrentWave)$"] MissionStatus=["$CurrentMissionStatus$"]";
	C.SetPos( 0, 45 );
	C.DrawText(missionStr);
}

DefaultProperties
{
}
