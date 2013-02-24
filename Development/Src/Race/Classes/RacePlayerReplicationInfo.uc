//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RacePlayerReplicationInfo extends UTPlayerReplicationInfo;

var int NextCheckpoint;
var int CurrentLap;
var vector LastDeathLocation;

DefaultProperties
{
	CurrentLap=1
}