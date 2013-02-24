class RLForgedStaticMeshData extends RLForgedMeshData;

struct StaticMeshSocket
{
	var() name SocketName;
	var() Vector SocketTranslation;
	var() Rotator SocketRotation;
	var() Vector SocketScale;

	structdefaultproperties
	{
		SocketScale=(X=1,Y=1,Z=1);
	}
};

var() array<StaticMeshSocket> Sockets;

var() StaticMesh StaticMesh;

DefaultProperties
{
}
