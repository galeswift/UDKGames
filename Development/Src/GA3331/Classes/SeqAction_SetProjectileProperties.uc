// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAction_SetProjectileProperties extends SequenceAction;

var() ParticleSystem ProjFlightTemplate;
var() ParticleSystem ProjExplosionTemplate;
var() class<UDKExplosionLight> ExplosionLightClass;
var() float Speed;
var() float MaxSpeed;	
var() float Damage;
var() float DamageRadius;
var() float MomentumTransfer;
var() class<DamageType> MyDamageType;
var() float LifeSpan;
var() SoundCue ExplosionSound;
var() MaterialInterface ExplosionDecal;
var() float DecalWidth;
var() float DecalHeight;
var() bool bCollideWorld;
var() bool bBounce;
var() float TossZ;
var() EPhysics Physics;
var() float CheckRadius;
var() SoundCue ImpactSound;
var() float CustomGravityScaling;
var() float BounceAmount;
var() float ExplosionTimer;
var() float SpinRate;

/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 2;
}

event Activated()
{
	local int i;
	local UTProjectile p;
	Super.Activated();

	PublishLinkedVariableValues();

	for( i=0 ; i<Targets.Length; i++ )
	{
		p = UTProjectile(Targets[i]);
		if( p != none )
		{
			p.ProjFlightTemplate = ProjFlightTemplate;
			p.ProjExplosionTemplate = ProjExplosionTemplate;
			p.ExplosionLightClass = ExplosionLightClass;
			p.Speed = Speed;
			p.MaxSpeed = MaxSpeed;	
			p.Damage = Damage;
			p.DamageRadius = DamageRadius;
			p.MomentumTransfer = MomentumTransfer;
			p.MyDamageType = MyDamageType;
			p.LifeSpan = LifeSpan;
			p.ExplosionSound = ExplosionSound;
			p.ExplosionDecal = ExplosionDecal;
			p.DecalWidth = DecalWidth;
			p.DecalHeight = DecalHeight;
			p.bCollideWorld = bCollideWorld;
			p.bBounce = bBounce;
			p.TossZ = TossZ;
			p.SetPhysics( Physics );
			p.CheckRadius = CheckRadius;
			p.ImpactSound = ImpactSound;
			p.CustomGravityScaling = CustomGravityScaling;

			if( GAProjectile(P) != none )
			{
				GAProjectile(P).BounceAmount = BounceAmount;
				GAProjectile(P).ExplosionTimer = ExplosionTimer;
				GAProjectile(P).SpinRate = SpinRate;
			}

			p.Init( vector(p.Rotation) );
		}
	}
}

defaultproperties
{
	ObjName="Set Projectile Properties"
	ObjCategory="Projectile"

	ProjFlightTemplate=none
	ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'

	speed=700
	MaxSpeed=1000.0
	Damage=100.0
	DamageRadius=200
	MomentumTransfer=50000  
	MyDamageType=class'UTDmgType_Grenade'
	LifeSpan=0.0
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	ExplosionDecal=MaterialInstanceTimeVarying'WP_RocketLauncher.Decals.MITV_WP_RocketLauncher_Impact_Decal01'
	DecalWidth=128.0
	DecalHeight=128.0
	bCollideWorld=true
	bBounce=true
	TossZ=+245.0
	Physics=PHYS_Falling
	CheckRadius=36.0

	ImpactSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_GrenadeFloor_Cue'

	CustomGravityScaling=0.5
	BounceAmount=.7
	SpinRate = 100000
	ExplosionTimer = 2.5

	bCallHandler=false
}
