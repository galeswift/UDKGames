class ActorFactoryPTEnemy extends ActorFactory;

/** Allows script to modify new actor */
simulated event PostCreateActor(Actor NewActor, optional const SeqAct_ActorFactory ActorFactoryData)
{
	local PT_Enemy_Base newEnemy;

	newEnemy = PT_Enemy_Base(NewActor);

	if( newEnemy != none )
	{
		newEnemy.Init(vector(newEnemy.Rotation));
	}
}

DefaultProperties
{
	MenuName="Add Projectile Tactics Enemy"
}
