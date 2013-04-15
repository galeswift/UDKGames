class GPS_Mission extends Object;

struct MissionEnemyInfo
{
	// Point to a GameCrowd_ListOfAgents reference in the editor
	var() GameCrowd_ListOfAgents EnemyType;

	// How many enemies will be spawned
	var() int EnemyCount;

	// How many enemies have been killed alrady
	var int KilledEnemyCount;
};

/** Filled in from the editor, fills out the enemy list per wave*/
var() array<MissionEnemyInfo> EnemyList;

function int GetEnemiesLeft( int Wave )
{
	return EnemyList[Wave].EnemyCount - EnemyList[Wave].KilledEnemyCount;
}

DefaultProperties
{
}
