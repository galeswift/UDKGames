class ActorFactoryEntity extends ActorFactoryMover;

// We ignore collisions from entities on the same team
var() int EntityTeam;
var() float CollisionRadius;
var() float CollisionHeight;

/** Allows script to modify new actor */
simulated event PostCreateActor(Actor NewActor, optional const SeqAct_ActorFactory ActorFactoryData)
{
	Super.PostCreateActor(NewActor, ActorFactoryData);
	GAEntity(NewActor).EntityTeam = EntityTeam;
	GAEntity(NewActor).CylinderComponent.SetCylinderSize(CollisionRadius, CollisionHeight);
}

DefaultProperties
{
	MenuName="Add Generic Game Entity"
	NewActorClass=class'GA4401.GAEntity'
	CollisionRadius=+40.000000
	CollisionHeight=+60.000000
}
