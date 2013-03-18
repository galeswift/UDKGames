class GPS_GameCrowdAgent extends UTGameCrowdAgent;


/** Behaviors to choose from when see someone chasing the player */
var(Behavior) array<BehaviorEntry>  ChaseBehaviors;
var() ParticleSystem DeathParticleSystem;
var() SoundCue DeathSoundCue;

struct LootInfo
{
	var float Probability;
	var class<UTInventory> Loot;	
};

// When this guy dies, spawn either armor, health, or a weapon.
var array<LootInfo> LootTable;

event NotifySeePlayer(PlayerController PC)
{
	local bool bFoundBehavior;
	local int i;

	if( GPS_CheatManager( PC.CheatManager ).IsCheatOn(CF_Beastmaster) )
	{
		return;
	}
	
	`log(self@GetFuncName());
	bWantsSeePlayerNotification = false; 
	
	// FIXMESTEVE - should check if current behavior can be overwritten and/or paused, and if so just pause it (keep it in current state)
	if ( CurrentBehavior == None )
	{	
	 	if ( !PickBehaviorFrom(SeePlayerBehaviors, PC.Pawn.Location) )
		{
			`log(" Coudn't find any player behaviors");
			// maybe all behaviors have been used and can't be re-used
			for ( i=0; i<SeePlayerBehaviors.Length; i++ )
			{				
				`log(" Evaluating "$SeePlayerBehaviors[i].BehaviorArchetype);
				if ( !SeePlayerBehaviors[i].bNeverRepeat || !SeePlayerBehaviors[i].bHasBeenUsed )
				{					
					bFoundBehavior = true;
					break;
				}
			}
			if ( !bFoundBehavior )
			{
			  	// no available behaviors, so kill the see player timer
				SeePlayerInterval = 0.0;
			 }
		}
		else
		{
			if( GPS_GCB_RunTowardsActor( CurrentBehavior ) != none )
			{
				GPS_GCB_RunTowardsActor( CurrentBehavior ).ActivatedBy( PC.Pawn );
			}
		}
	}
		
	// set timer to begin requesting see player notification again
	if ( SeePlayerInterval > 0.0 )
	{
		SetTimer( (0.8+0.4*FRand())*SeePlayerInterval, false, 'ResetSeePlayer');
	}
}

function bool IsChasing()
{
	local bool Result;

	Result = false;

	if( CurrentBehavior != none &&
		GPS_GCB_RunTowardsActor(CurrentBehavior) != none )
	{
		Result = true;
	}

	return Result;
}

/** Called when we spot someone who spotted the player */
function SetChase(Actor ChaseActor, bool bNewChase )
{
	if ( bNewChase )
	{
		if ( !IsChasing() )
		{
			PickBehaviorFrom(ChaseBehaviors);
		}
		if( CurrentBehavior != none )
		{
			CurrentBehavior.ActivatedBy(ChaseActor);
		}
	}
	else if ( IsChasing() )
	{
		// stop chasing now
		StopBehavior();
	}
}

/** Stop agent moving and pay death anim */
function PlayDeath(vector KillMomentum)
{
	TryDropLoot();
	WorldInfo.MyEmitterPool.SpawnEmitter(DeathParticleSystem, SkeletalMeshComponent.Bounds.Origin,,self);
	PlaySound(DeathSoundCue,,,,SkeletalMeshComponent.Bounds.Origin);
	super.PlayDeath( KillMomentum );
}

function TryDropLoot()
{
	local float Roll;
	local int StartIdx;
	local int DropIdx;
	local int i;	
	local DroppedPickup P;
	local Inventory Loot;

	DropIdx = -1;
	StartIdx = Rand(LootTable.Length);
	
	for( i=StartIdx ; i<LootTable.Length ; i++ )
	{
		Roll = FRand();
		
		if( Roll < LootTable[i].Probability )
		{
			DropIdx = i;
			break;
		}
	}


	if( DropIdx < 0 )
	{
		for( i=0; i<StartIdx; i++ )
		{
			if( Roll < LootTable[i].Probability )
			{
				DropIdx = i;
				break;
			}
		}
	}


	if( DropIdx >= 0 )
	{		
		Loot = Spawn( LootTable[DropIdx].Loot, self );

		// if cannot spawn a pickup, then destroy and quit
		if( Loot.DroppedPickupClass == None || 
			Loot.DroppedPickupMesh == None )
		{			
			return;
		}

		P = Spawn(Loot.DroppedPickupClass,,, Location);
		if( P == None )
		{
			return;
		}

		P.SetPhysics(PHYS_Falling);
		P.Inventory	= Loot;
		P.InventoryClass = Loot.class;		
		P.SetPickupMesh(Loot.DroppedPickupMesh);
		P.SetPickupParticles(Loot.DroppedPickupParticles);
	}
}

function bool IsDead()
{
	return Health <= 0;
}

DefaultProperties
{
	LootTable.Add((Probability=0.2,Loot=class'UTBerserk'))
	LootTable.Add((Probability=0.2,Loot=class'UTUDamage'))
	DeathParticleSystem=ParticleSystem'GPS_FX.Effects.P_FX_DeathExplode'
	DeathSoundCue=SoundCue'KismetGame_Assets.Sounds.Snake_Death_Cue'
}
