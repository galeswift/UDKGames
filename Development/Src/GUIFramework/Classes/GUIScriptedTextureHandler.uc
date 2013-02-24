//=============================================================================
// GUIScriptedTextureHandler
//
// $wotgreal_dt: 06/10/2012 9:20:05 PM$
//
// This class provides the utility to set up a GUIMenuScene to be used with a
// ScriptedTexture as a Material in the map.
// For instance can you place an interface for some door control as a console
// on some machine mesh and use it there directly. This is a good replacement
// for some of the 3D functionality that Scaleform provides.
//=============================================================================
class GUIScriptedTextureHandler extends Actor
    ClassGroup(GUI)
    placeable;

var() int MaterialMeshIndex; // Index of the Material slot on the StaticMesh that we want to assign to.
var() MaterialInterface MaterialTemplate; // Material created in UnrealEd with TextureSampleParameter2D.
var() name CanvasTextureParamName; // Name of TextureSampleParameter2D in MaterialTemplate

var MaterialInstanceConstant MaterialInstance; // new material instance to assign ScriptedTexture to.
var ScriptedTexture CanvasTexture;

var() LinearColor ClearColor; // Color that the ScriptedTexture gets cleared to.
var() Font DefaultFont; // Default Font to be used by GUIComponents unless overridden by them.
var() editinline StaticMeshComponent Mesh; // Mesh used to display the material in-game
var() IntPoint ScriptedTextureResolution; // Dimension of the ScriptedTexture that we want to create.
                                          // IMPORTANT: Make it a power of 2 !!!

var() class<GUIMenuScene> MenuSceneClass; // Menu scene to use with this ScriptedTexture!
var() editinline GUIMenuScene MenuScene; // Menu scene instanced by this

var transient float LastSceneRenderTime;
var transient float RenderDelta; // self-calculated RenderDelta.

function PostBeginPlay()
{
    super.PostBeginPlay();

    CanvasTexture = ScriptedTexture(class'ScriptedTexture'.static.Create(ScriptedTextureResolution.X, ScriptedTextureResolution.Y,, ClearColor));
    CanvasTexture.Render = OnRender; // Assign our delegate for rendering.

    if (MaterialTemplate != none)
    {
        MaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(MaterialMeshIndex);
        if (MaterialInstance != none)
        {
            MaterialInstance.SetParent(MaterialTemplate);

            if (CanvasTextureParamName != '')
            {
                MaterialInstance.SetTextureParameterValue(CanvasTextureParamName, CanvasTexture);
            }
        }
    }

    if (MenuScene == None)
        MenuScene = new(self) MenuSceneClass;

    MenuScene.InitMenuScene();
}

function OnRender(Canvas C)
{
    // Calculate our own RenderDelta, so the GUIMenuScene can link to it.
    RenderDelta = LastSceneRenderTime - WorldInfo.TimeSeconds;
    LastSceneRenderTime = WorldInfo.TimeSeconds;

    // Our HUD range is the full texture.
    C.SetOrigin(0,0);
    C.SetClip(CanvasTexture.SizeX, CanvasTexture.SizeY);

    if (MenuScene != None)
        MenuScene.RenderScene(C);

    CanvasTexture.bNeedsUpdate = true; // Redraw the texture next tick.
}

// Call this with True if you want to enable this handler as the one to receive inputs and interact with the player.
// Falls to disable inputs on it again.
function SetHandlerActive(bool bNewActive)
{
    local GUICompatiblePlayerController GUIPC;

    GUIPC = GUICompatiblePlayerController(GetALocalPlayerController());
    if (GUIPC != None)
    {
        GUIPC.SetHandlerActive(self, bNewActive);
    }
}

event Destroyed()
{
    DefaultFont = None;

    if (MenuScene != None)
    {
        MenuScene.DeleteMenuScene();
        MenuScene = none;
    }

    MaterialInstance = None;
    MaterialTemplate = None;
    CanvasTexture = None;
}


defaultproperties
{
   ClearColor=(R=0.0,G=0.0,B=0.0,A=0.0)

   Begin Object class=StaticMeshComponent Name=StaticMeshComp1
      StaticMesh=StaticMesh'dwStaticMeshes.Plane'
   End Object

   Mesh = StaticMeshComp1
   Components.Add(StaticMeshComp1)
}