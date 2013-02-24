class CustomSystemSettings extends Actor
	config(SystemSetting);

// World detail settings
var() config int DetailMode; //(INT) (1-3) Current detail mode; determines whether components of actors should be updated/ ticked. Corresponds to the EDetailMode enum in Scene.uc, also set in PrimitiveComponent, and returned by WorldInfo.GetDetailMode() 
var() config bool SpeedTreeLeaves; // (UBOOL) Whether to allow rendering of SpeedTree leaves
var() config bool SpeedTreeFronds; // (UBOOL) Whether to allow rendering of SpeedTree fronds. 
var() config bool StaticDecals; // (UBOOL) Whether to allow static decals. 
var() config bool DynamicDecals; // (UBOOL) Whether to allow dynamic decals. 
var() config bool UnbatchedDecals; // (UBOOL) Whether to allow decals that have not been placed in static draw lists and have dynamic view relevance 
var() config float DecalCullDistanceScale; // (FLOAT) Scale factor for distance culling decals 
var() config bool DynamicLights; // (UBOOL) Whether to allow dynamic lights. 
var() config bool CompositeDynamicLights; // (UBOOL) Whether to composte dynamic lights into light environments. 
var() config bool DirectionalLightmaps; // (UBOOL) Whether to allow directional lightmaps, which use the material's normal and specular.
var() config bool MotionBlur; // (UBOOL) Whether to allow motion blur. 
var() config bool MotionBlurPause; // (UBOOL) Whether to allow motion blur to be paused. 
var() config bool DepthOfField; // (UBOOL) Whether to allow depth of field. 
var() config bool AmbientOcclusion; // (UBOOL) Whether to allow ambient occlusion. 
var() config bool Bloom; // (UBOOL) Whether to allow bloom.
var() config bool UseHighQualityBloom; // (UBOOL) Whether to use high quality bloom or fast versions. 
var() config bool Distortion; // (UBOOL) Whether to allow distortion.
var() config bool FilteredDistortion; // (UBOOL) Whether to allow distortion to use bilinear filtering when sampling the scene color during its apply pass 
var() config bool DropParticleDistortion; // (UBOOL) Whether to allow dropping distortion on particles based on WorldInfo::bDropDetail. 
var() config bool LensFlares; // (UBOOL) Whether to allow rendering of LensFlares. 
var() config bool FogVolumes; // (UBOOL) Whether to allow fog volumes. 
var() config bool FloatingPointRenderTargets; // (UBOOL) Whether to allow floating point render targets to be used. 
var() config bool OneFrameThreadLag; // (UBOOL) Whether to allow the rendering thread to lag one frame behind the game thread. 
var() config int SkeletalMeshLODBias; // (INT) LOD bias for skeletal meshes. 
var() config int ParticleLODBias; // (INT) LOD bias for particle systems. 
var() config bool AllowD3D10; // (UBOOL) Whether to use D3D10 when it's available. 
var() config bool AllowRadialBlur; // (UBOOL) Whether to allow radial blur effects to render. 

//Fractured detail settings
var() config bool bAllowFracturedDamage; // (UBOOL) Whether to allow fractured meshes to take damage.
var() config float NumFracturedPartsScale; // (FLOAT) Scales the game-specific number of fractured physics objects allowed. 
var() config float FractureDirectSpawnChanceScale; // (FLOAT) Percent chance of a rigid body spawning after a fractured static mesh is damaged directly. [0-1] 
var() config float FractureRadialSpawnChanceScale; // (FLOAT) Percent chance of a rigid body spawning after a fractured static mesh is damaged by radial blast. [0-1] 
var() config float FractureCullDistanceScale; // (FLOAT) Distance scale for whether a fractured static mesh should actually fracture when damaged 

//Shadow detail settings
var() config bool DynamicShadows; // (UBOOL) Whether to allow dynamic shadows. 
var() config bool LightEnvironmentShadows; // (UBOOL) Whether to allow dynamic light environments to cast shadows. 
var() config int MinShadowResolution; // (INT) min dimensions (in texels) allowed for rendering shadow subject depths 
var() config int MaxShadowResolution; // (INT) max square dimensions (in texels) allowed for rendering shadow subject depths 
var() config float ShadowTexelsPerPixel; // (FLOAT) The ratio of subject pixels to shadow texels. 
var() config bool bEnableBranchingPCFShadows; // (UBOOL) Toggle Branching PCF implementation for projected shadows
var() config bool bAllowBetterModulatedShadows; // (UBOOL) Toggle extra geometry pass needed for culling shadows on emissive and backfaces 
var() config bool bEnableForegroundShadowsOnWorld; // (UBOOL) hack to allow for foreground DPG objects to cast shadows on the world DPG 
var() config bool bEnableForegroundSelfShadowing; // (UBOOL) Whether to allow foreground DPG self-shadowing 
var() config float ShadowFilterRadius; // (FLOAT) Radius, in shadowmap texels, of the filter disk 
var() config float ShadowDepthBias; // (FLOAT) Depth bias that is applied in the depth pass for all types of projected shadows except VSM
var() config int ShadowFadeResolution; // (INT) Resolution in texel below which shadows are faded out. 
var() config float ShadowFadeExponent; // (FLOAT) Controls the rate at which shadows are faded out. 
var() config float ShadowVolumeLightRadiusThreshold; // (FLOAT) Lights with radius below threshold will not cast shadow volumes.
var() config float ShadowVolumePrimitiveScreenSpacePercentageThreshold; // (FLOAT) Primitives with screen space percantage below threshold will not cast shadow volumes. 

//Texture detail settings
var() config bool OnlyStreamInTextures; // (UBOOL) If enabled, texture will only be streamed in, not out. 
var() config int MaxAnisotropy; // (INT) Maximum level of anisotropy used.
var() config float SceneCaptureStreamingMultiplier; // (FLOAT) Scene capture streaming texture update distance scalar.
var() config float FoliageDrawRadiusMultiplier; // (FLOAT) Foliage draw distance scalar. 

//VSync settings
var() config bool UseVsync; // (UBOOL) Whether to use VSync or not. 

//Screen percentage settings
var() config float ScreenPercentage; // (FLOAT) Percentage of screen main view should take up. 
var() config bool UpscaleScreenPercentage; // (UBOOL) Whether to upscale the screen to take up the full front buffer.

//Resolution settings
var() config int ResX; // (INT) Screen X resolution 
var() config int ResY; // (INT) Screen Y resolution
var() config bool Fullscreen; // (UBOOL) Fullscreen 

//MSAA settings
var() config int MaxMultiSamples; // (INT) The maximum number of MSAA samples to use. 

//Mesh settings
var() config bool bForceCPUAccesToGPUSkinVerts; // (UBOOL) Whether to force CPU access to GPU skinned vertex data. 
var() config bool bDisableSkeletalInstanceWeights; // (UBOOL) Whether to disable instanced skeletal weights. 


function SetStaticDecals(bool bBool)
{
	StaticDecals = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set StaticDecals" @ StaticDecals);
}

function SetDynamicDecals(bool bBool)
{
	DynamicDecals = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set DynamicDecals" @ DynamicDecals);
}

function SetUnbatchedDecals(bool bBool)
{
	UnbatchedDecals = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set UnbatchedDecals" @ UnbatchedDecals);
}

function SetDecalCullDistanceScale(float fFloat)
{
	DecalCullDistanceScale = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set DecalCullDistanceScale" @ DecalCullDistanceScale);
}

function SetDynamicLights(bool bBool)
{
	DynamicLights = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set DynamicLights" @ DynamicLights);
}

function SetDynamicShadows(bool bBool)
{
	DynamicShadows = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set DynamicShadows" @ DynamicShadows);
}

function SetLightEnvironmentShadows(bool bBool)
{
	LightEnvironmentShadows = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set LightEnvironmentShadows" @ bBool);
}

function SetCompositeDynamicLights(bool bBool)
{
	CompositeDynamicLights = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set CompositeDynamicLights" @ CompositeDynamicLights);
}

function SetDirectionalLightmaps(bool bBool)
{
	DirectionalLightmaps = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set DirectionalLightmaps" @ DirectionalLightmaps);
}

function SetMotionBlur(bool bBool)
{
	MotionBlur = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set MotionBlur" @ MotionBlur);
}

function SetMotionBlurPause(bool bBool)
{
	MotionBlurPause = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set MotionBlurPause" @ MotionBlurPause);
}

function SetDepthOfField(bool bBool)
{
	DepthOfField = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set DepthOfField" @ DepthOfField);
}

function SetAmbientOcclusion(bool bBool)
{
	AmbientOcclusion = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set AmbientOcclusion" @ AmbientOcclusion);
}

function SetBloom(bool bBool)
{
	Bloom = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set Bloom" @ Bloom);
}

function SetDistortion(bool bBool)
{
	Distortion = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set Distortion" @ Distortion);
}

function SetFilteredDistortion(bool bBool)
{
	FilteredDistortion = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set FilteredDistortion" @ FilteredDistortion);
}

function SetSpeedTreeLeaves(bool bBool)
{
	SpeedTreeLeaves = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set SpeedTreeLeaves" @ SpeedTreeLeaves);
}

function SetSpeedTreeFronds(bool bBool)
{
	SpeedTreeFronds = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set SpeedTreeFronds" @ SpeedTreeFronds);
}

function SetOnlyStreamInTextures(bool bBool)
{
	OnlyStreamInTextures = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set OnlyStreamInTextures" @ OnlyStreamInTextures);
}

function SetLensFlares(bool bBool)
{
	LensFlares = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set LensFlares" @ LensFlares);
}

function SetFogVolumes(bool bBool)
{
	FogVolumes = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set FogVolumes" @ FogVolumes);
}

function SetFloatingPointRenderTargets(bool bBool)
{
	FloatingPointRenderTargets = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set FloatingPointRenderTargets" @ FloatingPointRenderTargets);
}

function SetOneFrameThreadLag(bool bBool)
{
	OneFrameThreadLag = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set OneFrameThreadLag" @ OneFrameThreadLag);
}

function SetUseVsync(bool bBool)
{
	UseVsync = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set UseVsync" @ UseVsync);
}

function SetUpscaleScreenPercentage(bool bBool)
{
	UpscaleScreenPercentage = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set UpscaleScreenPercentage" @ UpscaleScreenPercentage);
}

function SetFullscreen(bool bBool)
{
	Fullscreen = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set Fullscreen" @ Fullscreen);
}

function SetAllowRadialBlur(bool bBool)
{
	AllowRadialBlur = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set AllowRadialBlur" @ AllowRadialBlur);
}

function SetSkeletalMeshLODBias(int iInt)
{
	SkeletalMeshLODBias = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set SkeletalMeshLODBias" @ SkeletalMeshLODBias);
}

function SetParticleLODBias(int iInt) 
{
	ParticleLODBias = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set ParticleLODBias" @ ParticleLODBias);
}

function SetDetailMode(int iInt) 
{
	DetailMode = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set DetailMode" @ DetailMode);
}

function SetMaxAnisotropy(int iInt) 
{
	MaxAnisotropy = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set MaxAnisotropy" @ MaxAnisotropy);
}

function SetMaxMultiSamples(int iInt) 
{
	MaxMultiSamples = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set MaxMultiSamples" @ MaxMultiSamples);
}

function SetMinShadowResolution(int iInt) 
{
	MinShadowResolution = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set MinShadowResolution" @ MinShadowResolution);
}

function SetMaxShadowResolution(int iInt) 
{
	MaxShadowResolution = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set MaxShadowResolution" @ MaxShadowResolution);
}

function SetShadowFadeResolution(int iInt) 
{
	ShadowFadeResolution = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set ShadowFadeResolution" @ ShadowFadeResolution);
}

function SetShadowFadeExponent(float fFloat) 
{
	ShadowFadeExponent = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set ShadowFadeExponent" @ ShadowFadeExponent);
}

function SetResX(int iInt) 
{
	ResX = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set RexX" @ ResX);
}

function SetResY(int iInt) 
{
	ResY = iInt;
	SaveConfig();
	ConsoleCommand("Scale Set ResY" @ ResY);
}

function SetScreenPercentage(float fFloat) 
{
	ScreenPercentage = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set ScreenPercentage" @ ScreenPercentage);
}

function SetSceneCaptureStreamingMultiplier(float fFloat) 
{
	SceneCaptureStreamingMultiplier = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set SceneCaptureStreamingMultiplier" @ SceneCaptureStreamingMultiplier);
}

function SetShadowTexelsPerPixel(float fFloat) 
{
	ShadowTexelsPerPixel = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set ShadowTexelsPerPixel" @ ShadowTexelsPerPixel);
}


function SetbEnableBranchingPCFShadows(bool bBool) 
{
	bEnableBranchingPCFShadows = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set bEnableBranchingPCFShadows" @ bEnableBranchingPCFShadows);
}

function SetbEnableForegroundShadowsOnWorld(bool bBool) 
{
	bEnableForegroundShadowsOnWorld = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set bEnableForegroundShadowsOnWorld" @ bEnableForegroundShadowsOnWorld);
}

function SetbEnableForegroundSelfShadowing(bool bBool) 
{
	bEnableForegroundSelfShadowing = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set bEnableForegroundSelfShadowing" @ bEnableForegroundSelfShadowing);
}

function SetShadowFilterRadius(float fFloat) 
{
	ShadowFilterRadius = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set ShadowFilterRadius" @ ShadowFilterRadius);
}

function SetShadowDepthBias(float fFloat) 
{
	ShadowDepthBias = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set ShadowDepthBias" @ ShadowDepthBias);
}

function SetbAllowFracturedDamage(bool bBool) 
{
	bAllowFracturedDamage = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set bAllowFracturedDamage" @ bAllowFracturedDamage);
}

function SetNumFracturedPartsScale(float fFloat) 
{
	NumFracturedPartsScale = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set NumFracturedPartsScale" @ NumFracturedPartsScale);
}

function SetFractureDirectSpawnChanceScale(float fFloat) 
{
	FractureDirectSpawnChanceScale = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set FractureDirectSpawnChanceScale" @ FractureDirectSpawnChanceScale);
}

function SetFractureRadialSpawnChanceScale(float fFloat) 
{
	FractureDirectSpawnChanceScale = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set FractureDirectSpawnChanceScale" @ FractureDirectSpawnChanceScale);
}

function SetFractureCullDistanceScale(float fFloat) 
{
	FractureCullDistanceScale = fFloat;
	SaveConfig();
	ConsoleCommand("Scale Set FractureCullDistanceScale" @ FractureCullDistanceScale);
}

function SetbForceCPUAccesToGPUSkinVerts(bool bBool) 
{
	bForceCPUAccesToGPUSkinVerts = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set bForceCPUAccesToGPUSkinVerts" @ bForceCPUAccesToGPUSkinVerts);
}

function SetbDisableSkeletalInstanceWeights(bool bBool) 
{
	bDisableSkeletalInstanceWeights = bBool;
	SaveConfig();
	ConsoleCommand("Scale Set bDisableSkeletalInstanceWeights" @ bDisableSkeletalInstanceWeights);
}

DefaultProperties
{
}