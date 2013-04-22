class PT_PC extends UDKPlayerController;

/** Save data */
var CloudSaveData SaveData;

var int Slot1DocIndex;
var int Slot2DocIndex;

/** Cache some singletons */
var CloudStorageBase Cloud;

simulated function NotifyKilledEnemy(PT_Enemy_Base Killed, class<DamageType> DamageType)
{
	CloudGameFight();
}

simulated function NotifyPickedUp(PT_Pickup Pickup)
{
	CloudGameFight();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	Slot1DocIndex = -1;
	Slot2DocIndex = -1;

	// listen for cloud storage value changes
	//Cloud = class'PlatformInterfaceBase'.static.GetCloudStorageInterface();
	//Cloud.AddDelegate(CSD_ValueChanged, CloudValueChanged);
	//Cloud.AddDelegate(CSD_DocumentReadComplete, CloudReadDocument);
	//Cloud.AddDelegate(CSD_DocumentConflictDetected, CloudConflictDetected);

	// make a save data object
	SaveData = new class'CloudSaveData';

	// look for existing documents
	CloudGetDocs();
}

// Cleanup
event Destroyed()
{
	super.Destroyed();

	//Cloud.ClearDelegate(CSD_ValueChanged, CloudValueChanged);
	//Cloud.ClearDelegate(CSD_DocumentReadComplete, CloudReadDocument);
	//Cloud.ClearDelegate(CSD_DocumentConflictDetected, CloudConflictDetected);
}

exec function CloudGameFight()
{
	SaveData.Exp += 20;
	SaveData.Gold += 10;
}

exec function CloudGameSave(int Slot)
{
	local int DocIndex;

	Cloud = class'PlatformInterfaceBase'.static.GetCloudStorageInterface();
	DocIndex = Slot == 1 ? Slot1DocIndex : Slot2DocIndex;

	if (DocIndex == -1)
	{
		`log("Creating new save slot");
		DocIndex = Cloud.CreateCloudDocument("" $ Slot $ "_Save.bin");
	
		if (Slot == 1)
		{
			Slot1DocIndex = DocIndex;
		}
		else
		{
			Slot2DocIndex = DocIndex;
		}
	}

	// save the document
	Cloud.SaveDocumentWithObject(DocIndex, SaveData, 0);
	Cloud.WriteCloudDocument(DocIndex);
}

exec function CloudGameLoad(int Slot)
{
	local int DocIndex;
	DocIndex = Slot == 1 ? Slot1DocIndex : Slot2DocIndex;

	if (DocIndex == -1)
	{
		`log("No save data in that slot");
		return;
	}

	// read the document
	Cloud.ReadCloudDocument(DocIndex);
}

function CloudLogValue(const out PlatformInterfaceDelegateResult Result)
{
	`log("Retrieved key " $ Result.Data.DataName $ ", with value:");
	switch (Result.Data.Type)
	{
		case PIDT_Int: `log(Result.Data.IntValue); break;
		case PIDT_Float: `log(Result.Data.FloatValue); break;
		case PIDT_String: `log(Result.Data.StringValue); break;
		case PIDT_Object: `log(Result.Data.ObjectValue); break;
	}
	Cloud.ClearDelegate(CSD_KeyValueReadComplete, CloudLogValue);
}

function CloudValueChanged(const out PlatformInterfaceDelegateResult Result)
{
	local PlatformInterfaceDelegateResult ImmediateResult;
	`log("Value " $ Result.Data.StringValue $ " changed with tag " $ Result.Data.DataName $ ". Assuming Integer typewhen reading:");

	Cloud.AddDelegate(CSD_KeyValueReadComplete, CloudLogValue);
	Cloud.ReadKeyValue(Result.Data.StringValue, PIDT_Int, ImmediateResult);
}

function CloudIncrementValue(const out PlatformInterfaceDelegateResult Result)
{
	local PlatformInterfaceData WriteData;

	`log("Retrieved value " $ Result.Data.IntValue);

	WriteData = Result.Data;
	WriteData.IntValue++;
	Cloud.WriteKeyValue("CloudTestKey", WriteData);

	Cloud.ClearDelegate(CSD_KeyValueReadComplete, CloudIncrementValue);
}

exec function CloudGetAndIncrement()
{
	local PlatformInterfaceDelegateResult ImmediateResult;
	Cloud.AddDelegate(CSD_KeyValueReadComplete, CloudIncrementValue);
	Cloud.ReadKeyValue("CloudTestKey", PIDT_Int, ImmediateResult);
}

function CloudGotDocuments(const out PlatformInterfaceDelegateResult Result)
{
	local int NumDocs, i, SlotNum;

	NumDocs = Cloud.GetNumCloudDocuments();

	`log("We have found " $ NumDocs $ " documents in the cloud:");
	for (i = 0; i < NumDocs; i++)
	{
		`log("  - " $ Cloud.GetCloudDocumentName(i));
		SlotNum = int(Left(Cloud.GetCloudDocumentName(i), 1));
		if (SlotNum == 1)
		{
			Slot1DocIndex = i;
		}
		else if (SlotNum == 2)
		{
			Slot2DocIndex = i;
		}
	}
}

function CloudReadDocument(const out PlatformInterfaceDelegateResult Result)
{
	local int DocumentIndex;
	DocumentIndex = Result.Data.IntValue;
	
	if (Result.bSuccessful)
	{
		SaveData = CloudSaveData(Cloud.ParseDocumentAsObject(DocumentIndex, class'CloudSaveData', 0));
	}
	else
	{
		`log("Failed to read document index " $ DocumentIndex);
	}
}

function CloudConflictDetected(const out PlatformInterfaceDelegateResult Result)
{
	`log("Aww, there's a conflict in " $ Cloud.GetCloudDocumentName(Result.Data.IntValue) $ 
		" . There are " $ Cloud.GetNumCloudDocuments(true) $ " versions. Going to resolve to newest version");

	// this is the easy way to resolve differences - just pick the newest one
	// @todo: test reading all versions and picking largest XP version
	Cloud.ResolveConflictWithNewestDocument();
}

function CloudGetDocs()
{
	Cloud.AddDelegate(CSD_DocumentQueryComplete, CloudGotDocuments);
	Cloud.QueryForCloudDocuments();
}

state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		//local vector drawOrigin;
		
		GetAxes(ViewTarget.Rotation,X,Y,Z);
		
		//drawOrigin = ViewTarget.Location + X * 512;
		//DrawDebugSphere(drawOrigin, 25, 10, 255, 255, 255, false );
		//DrawDebugLine(drawOrigin, drawOrigin + X*500, 255, 100, 100, false);    
		//DrawDebugLine(drawOrigin, drawOrigin + Y*500, 100, 255, 100, false);
		//DrawDebugLine(drawOrigin, drawOrigin + Z*500, 100, 100, 255, false);

		Pawn.Acceleration = PlayerInput.aStrafe * Y + PlayerInput.aForward*Z;
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);
	
		if( ViewTarget != none )
		{
			if( Pawn.Base != ViewTarget )
			{
				Pawn.SetBase( ViewTarget );
			}

			if( Pawn.Acceleration == vect(0,0,0) )
			{
				Pawn.Velocity = vect(0,0,0);
			}
			else if( Pawn.Base.Velocity.Y > 0 )
			{
				Pawn.Velocity.Y = Pawn.Base.Velocity.Y;
			}
		}
		else 
		{
			Pawn.Velocity = vect(0,0,0);
		}
	
		// Update rotation.
		UpdateRotation( DeltaTime );
	}

	event BeginState(Name PreviousStateName)
	{
		Pawn.SetPhysics(PHYS_Flying);
	}
}

function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
	return Pawn.Rotation;
}

function UpdateRotation( float DeltaTime )
{
	SetRotation(Pawn.Rotation);
}

/**
* return whether viewing in first person mode
*/
function bool UsingFirstPersonCamera()
{
	return true;
}

DefaultProperties
{
}
