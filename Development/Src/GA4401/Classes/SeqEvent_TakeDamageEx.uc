class SeqEvent_TakeDamageEx extends SeqEvent_TakeDamage;

var Actor ActorThatTookDamage;

function HandleDamage(Actor inOriginator, Actor inInstigator, class<DamageType> inDamageType, int inAmount)
{
	Super.HandleDamage(inOriginator, inInstigator, inDamageType, inAmount);
	ActorThatTookDamage=inOriginator;
	PopulateLinkedVariableValues();
}

DefaultProperties
{
	ObjName="Take Damage EX"
	ObjCategory="Actor"

	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Actor That Took Damage",bWriteable=true,PropertyName=ActorThatTookDamage)
}
