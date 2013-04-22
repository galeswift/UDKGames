class SeqAct_PT_SpawnEnemy extends SeqAct_Latent;

// Enemy archetype
var() Actor EnemyTemplate;

// Where to spawn, also inherits this point's rotation
var() Actor SpawnPoint;

// Result of what spawned
var() Actor SpawnedEnemy;

// How many we should spawn
var() int SpawnCount;

// How long to wait between spawns
var() float SpawnDelay;

// How many spawns we still have left to process
var int SpawnRemaining;

// How much time left until we perform another spawn
var float SpawnDelayRemaining;

event Activated()
{
	Super.Activated();
	SpawnRemaining = SpawnCount;
}

function PT_Enemy_Base SpawnEnemy()
{
	local PT_Enemy_Base Enemy;

	Enemy = GetWorldInfo().Spawn(class'PT_Enemy_Base',,, SpawnPoint.Location, SpawnPoint.Rotation, EnemyTemplate);
	Enemy.Init(vector(Enemy.Rotation));

	return Enemy;
}

/** script tick interface
 * the action deactivates when this function returns false and LatentActors is empty
 * @return whether the action needs to keep ticking
 */
event bool Update(float DeltaTime)
{
	Super.Update(DeltaTime);
	SpawnDelayRemaining -= DeltaTime;

	if( SpawnDelayRemaining <= 0 )
	{		
		SpawnedEnemy = SpawnEnemy();
		SpawnDelayRemaining = SpawnDelay;
		SpawnRemaining--;
	}
	return (SpawnRemaining > 0);
}

DefaultProperties
{
	ObjName="Enemy Spawner"
	ObjCategory="Projectile Tactics"
	VariableLinks.Empty()
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawn Location",PropertyName=SpawnPoint)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawned Actor",PropertyName=SpawnedEnemy)
	SpawnDelay=0.5
	SpawnCount=1
}
