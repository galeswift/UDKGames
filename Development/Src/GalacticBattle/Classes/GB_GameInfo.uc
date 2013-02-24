/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class GB_GameInfo extends UTGame
	config(GalacticBattle);

defaultproperties
{
	Acronym="GB"
	MapPrefixes[0]="GB"
	DefaultEnemyRosterClass="UTGame.UTDMRoster"

	// Class used to write stats to the leaderboard
	OnlineStatsWriteClass=class'UTGame.UTLeaderboardWriteDM'
	// Default set of options to publish to the online service
	OnlineGameSettingsClass=class'UTGame.UTGameSettingsDM'

	bScoreDeaths=false

	// Deathmatch games don't care about teams for voice chat
	bIgnoreTeamForVoiceChat=true

	PlayerReplicationInfoClass=class'GalacticBattle.GB_PRI'
	PlayerControllerClass=class'GalacticBattle.GBPlayerController'
	DefaultPawnClass=class'GalacticBattle.GBPawn'
}
