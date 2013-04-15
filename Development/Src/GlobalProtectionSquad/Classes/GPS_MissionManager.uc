class GPS_MissionManager extends Actor;

/* List of pickups the player has received during this mission */
var array<GPS_Pickup> AllPickups;

/* Currently active mission */
var GPS_Mission CurrentMission;

/* Currently active wave */
var int CurrentWave;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

function StartMission(GPS_Mission Mission, optional int Wave = 0)
{
	local array<SequenceObject> SpawnerActions;
	local SeqAct_UTCrowdSpawner CurrentSpawner;
	local Sequence GameSeq;
	local int Idx;
	
	CurrentMission = Mission;
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
			}
		}
	}
}

function NotifyKilledEnemy(Actor KilledEnemy)
{
	CurrentMission.EnemyList[CurrentWave].KilledEnemyCount++;
}

simulated event PostRender(Canvas C)
{
	local string missionStr;
	// Draw EXP on the screen
	missionStr = "Current mission: ["$CurrentMission$"] Enemies Left to kill: ["$CurrentMission.EnemyList[CurrentWave].EnemyCount - CurrentMission.EnemyList[CurrentWave].KilledEnemyCount$"]";
	C.SetPos( 0, 45 );
	C.DrawText(missionStr);
}

DefaultProperties
{
}
