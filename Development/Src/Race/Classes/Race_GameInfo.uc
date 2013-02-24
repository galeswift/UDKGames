/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class Race_GameInfo extends UTGame
	config(Race);

var transient array<RaceCheckpointVolume> Checkpoints;

var config int NumberOfLaps;

function PostBeginPlay()
{
	local RaceCheckpointVolume Checkpoint;
	local int i;

	super.PostBeginPlay();

	// find all checkpoints
	foreach AllActors(class'RaceCheckpointVolume', Checkpoint)
	{
		for(i=0; i<Checkpoints.Length; i++)
		{
			if( Checkpoint.CheckpointNum <= Checkpoints[i].CheckpointNum )
			{
				break;
			}
		}
		Checkpoints.Insert(i,1);
		Checkpoints[i] = Checkpoint;
	}

	// tell them the direction to their next checkpoint
	for(i=0; i<Checkpoints.Length; i++)
	{
		if( i == Checkpoints.Length-1 )
		{
			// end
			Checkpoints[i].SetNextCheckpointDir(vect(0,0,-1));
		}
		else
		{
			Checkpoints[i].SetNextCheckpointDir(Checkpoints[i+1].GetCenter()-Checkpoints[i].GetCenter());
		}
	}
}

function int GetCheckpointIndex(int CheckpointNum)
{
	local int i;

	for(i=0; i<Checkpoints.Length; i++)
	{
		if( Checkpoints[i].CheckpointNum == CheckpointNum )
		{
			return i;
		}
	}

	return -1;
}

function CheckpointTouched(int CheckpointNum, Actor Other)
{
	local UTPawn OtherPawn;
	local RacePlayerReplicationInfo RacePRI;
	local int CheckpointIndex;
	local NavigationPoint BestStart;
	local rotator NewRotation;

	OtherPawn = UTPawn(Other);
	if( OtherPawn == none )
	{
		return;
	}
	else
	{
		RacePRI = RacePlayerReplicationInfo(OtherPawn.PlayerReplicationInfo);
		if( RacePRI == none )
		{
			return;
		}
		else
		{
			if( RacePRI.NextCheckpoint == CheckpointNum )
			{
				CheckpointIndex = GetCheckpointIndex(CheckpointNum);
				//RacePRI.Score += 1;
				if( CheckpointIndex == Checkpoints.Length-1 )
				{
					// lap complete!
					if( RacePRI.CurrentLap < NumberOfLaps )
					{
						// increment the lap count
						RacePRI.CurrentLap++;
						// set next checkpoint
						RacePRI.NextCheckpoint = Checkpoints[0].CheckpointNum;
						// teleport to start
						BestStart = FindPlayerStart(OtherPawn.Controller);
						NewRotation = BestStart.Rotation;
						TeleportTo(OtherPawn, BestStart.Location, NewRotation, true);
					}
					else
					{
						// the end!
						SetWinner(RacePRI);
					}
				}
				else
				{
					// set next checkpoint
					RacePRI.NextCheckpoint = Checkpoints[CheckpointIndex+1].CheckpointNum;
				}
			}
		}
	}
}

function SetWinner(PlayerReplicationInfo Winner)
{
	EndTime = WorldInfo.TimeSeconds + EndTimeDelay;
	GameReplicationInfo.Winner = Winner;

	SetEndGameFocus(Winner);
}

function TeleportTo(UTPawn OtherPawn, vector NewLocation, rotator NewRotation, bool bShowTeleport)
{
	local vector PrevPosition;

	PrevPosition = OtherPawn.Location;
	OtherPawn.SetLocation(NewLocation);
	if( bShowTeleport )
	{
		OtherPawn.DoTranslocate(PrevPosition);
	}
	NewRotation.Roll = 0;
	OtherPawn.Controller.ClientSetRotation(NewRotation);
}

function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
	RacePlayerReplicationInfo(KilledPlayer.PlayerReplicationInfo).LastDeathLocation = KilledPawn.Location;
	// dont allow 0,0,0 since we use that to check if we should teleport on spawn
	if( RacePlayerReplicationInfo(KilledPlayer.PlayerReplicationInfo).LastDeathLocation == vect(0,0,0) )
	{
		RacePlayerReplicationInfo(KilledPlayer.PlayerReplicationInfo).LastDeathLocation = vect(0,0,1);
	}
	`log(KilledPlayer@KilledPawn@"was killed at"@RacePlayerReplicationInfo(KilledPlayer.PlayerReplicationInfo).LastDeathLocation,true,'Race');

	super.Killed(Killer, KilledPlayer, KilledPawn, damageType);
}

function RestartPlayer(Controller aPlayer)
{
	local rotator NewRotation;
	local vector NewDirection;
	local RacePlayerReplicationInfo PRI;

	super.RestartPlayer(aPlayer);

	if( aPlayer.Pawn != none )
	{
		// face the next checkpoint
		PRI = RacePlayerReplicationInfo(aPlayer.PlayerReplicationInfo);
		if( PRI != none && PRI.LastDeathLocation != vect(0,0,0) )
		{
			NewDirection = Checkpoints[GetCheckpointIndex(PRI.NextCheckpoint)].Location - PRI.LastDeathLocation;
			NewRotation = rotator(NewDirection);
			`log("teleporting new pawn for"@aPlayer@"to"@PRI.LastDeathLocation,true,'Race');
			TeleportTo(UTPawn(aPlayer.Pawn), PRI.LastDeathLocation, NewRotation, true);
		}
	}
}

event Tick(float DeltaTime)
{
	local Controller P;
	local RacePlayerReplicationInfo PRI, ComparePRI;
	local array<Controller> SortedControllers;
	local int i;
	local vector CheckpointLoc, PawnLoc, OtherPawnLoc;

	super.Tick(deltaTime);

	// calculate positions
	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		PRI = RacePlayerReplicationInfo(P.PlayerReplicationInfo);
		if( PRI != none )
		{
			for(i=0; i<SortedControllers.Length; i++)
			{
				ComparePRI = RacePlayerReplicationInfo(SortedControllers[i].PlayerReplicationInfo);
				if( PRI.CurrentLap > ComparePRI.CurrentLap )
				{
					// we are ahead of them
					break;
				}
				else if( PRI.CurrentLap == ComparePRI.CurrentLap )
				{
					// compare checkpoints
					if( PRI.NextCheckpoint > ComparePRI.NextCheckpoint )
					{
						// we are ahead of them
						break;
					}
					else if( PRI.NextCheckpoint == ComparePRI.NextCheckpoint )
					{
						// compare positions
						CheckpointLoc = Checkpoints[GetCheckpointIndex(PRI.NextCheckpoint)].GetCenter();
						PawnLoc = P.Pawn != none ? P.Pawn.Location : PRI.LastDeathLocation;
						OtherPawnLoc = SortedControllers[i].Pawn != none ? SortedControllers[i].Pawn.Location : ComparePRI.LastDeathLocation;
						if( VSize(CheckpointLoc-PawnLoc) < VSize(CheckpointLoc-OtherPawnLoc) )
						{
							// we are ahead of them
							break;
						}
					}
				}
			}

			SortedControllers.Insert(i,1);
			SortedControllers[i] = P;
		}
	}

	// now we have a sorted list, assign positions to score
	for(i=0; i<SortedControllers.Length; i++)
	{
		PRI = RacePlayerReplicationInfo(SortedControllers[i].PlayerReplicationInfo);
		PRI.Score = i+1;

		if( RacePlayerController( SortedControllers[i] ) != none )
		{
			RacePlayerController(SortedControllers[i]).m_fMaxStamina = class'RacePlayerController'.default.m_fMaxStamina * (1 + 0.5f * i);
		}
	}
}

function StartMatch()
{
	local Controller C;

	super.StartMatch();

	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		C.PlayerReplicationInfo.Score = 0;
		break;
	}
}

function ScoreKill(Controller Killer, Controller Other)
{
	// no scoring from kills
	return;
}

function bool WantsPickups(UTBot B)
{
	return true;
}

/** return a value based on how much this pawn needs help */
function int GetHandicapNeed(Pawn Other)
{
	return 0;
}

function UpdateGameSettings()
{
	// set this as a custom game
	GameSettings.SetStringSettingValue(class'UTGameSearchCommon'.const.CONTEXT_GAME_MODE,
		class'UTGameSearchCommon'.const.CONTEXT_GAME_MODE_CUSTOM,
		false);

	super.UpdateGameSettings();
}

defaultproperties
{
	Acronym="RACE"
	MapPrefixes[0]="RACE"
	DefaultEnemyRosterClass="UTGame.UTDMRoster"

	// Class used to write stats to the leaderboard
	OnlineStatsWriteClass=class'UTGame.UTLeaderboardWriteDM'
	// Default set of options to publish to the online service
	OnlineGameSettingsClass=class'UTGame.UTGameSettingsDM'

	bScoreDeaths=false

	// Deathmatch games don't care about teams for voice chat
	bIgnoreTeamForVoiceChat=true

	PlayerReplicationInfoClass=class'Race.RacePlayerReplicationInfo'
	PlayerControllerClass=class'Race.RacePlayerController'
	DefaultPawnClass=class'Race.RacePawn'
}
