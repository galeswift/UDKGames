// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAct_SetRBVelocity extends SequenceAction;

var() Vector VelocityDir;
var() float  VelocityMag;
/** If TRUE given velocity is relative to actor rotation. Otherwise, velocity is in world space. */
var() bool	bVelocityRelativeToActorRotation;
var() bool bAddForce;
event Activated()
{	
	local int i;
	local vector V;
	local float	 Mag;

	Super.Activated();

	PublishLinkedVariableValues();

	for( i=0 ; i<Targets.Length; i++ )
	{
		if( Actor(Targets[i]) != none )
		{
			Mag = VelocityMag;
			if( Mag <= 0.f )
			{
				Mag = VSize( VelocityDir);
			}
			V = Normal(VelocityDir) * Mag;
			if( bVelocityRelativeToActorRotation )
			{
				V = V >> Actor(Targets[i]).Rotation;
			}			
			
			if( Actor(Targets[i]).Physics == PHYS_RigidBody && Actor(Targets[i]).CollisionComponent != None )
			{
				if( bAddForce )
				{
					Actor(Targets[i]).CollisionComponent.AddForce( V );
				}
				else
				{
					Actor(Targets[i]).CollisionComponent.SetRBLinearVelocity( V );
				}
			}			
		}
	}
}

defaultproperties
{
	ObjName="Set RB Velocity"
	ObjCategory="Actor"
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Velocity Dir",PropertyName=VelocityDir)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Float',LinkDesc="Velocity Mag",PropertyName=VelocityMag)
}
