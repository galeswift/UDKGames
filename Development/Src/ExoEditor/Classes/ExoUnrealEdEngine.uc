// Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.

class ExoUnrealEdEngine extends UnrealEdEngine
	native
	transient;

cpptext
{
	virtual void GameStatsRender(FEditorLevelViewportClient* ViewportClient, const FSceneView* View, FCanvas* Canvas, ELevelViewportType ViewportType);
	void ExecuteMonsterGroupCSV();
	UBOOL Exec(const TCHAR* Cmd, FOutputDevice& Ar = *GLog);
}
