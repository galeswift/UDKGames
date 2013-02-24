//------------------------------------------------------------------------------
// We can't read system settings directly, so we need to store them somewhere
// else for now.
//------------------------------------------------------------------------------
class SystemSettingsHandler extends Actor
    dependsOn(UberPostProcessEffect)
    config(Engine);

var() config byte BucketSetting; // The last Bucket the player chose. 0 = custom.

// NORMAL SETTINGS
var() bool StaticDecals; // Whether to allow static decals.
var() bool DynamicDecals; // Whether to allow dynamic decals.
var() bool UnbatchedDecals; // Whether to allow decals that have not been placed in static draw lists and have dynamic view relevance.
var() float DecalCullDistanceScale; // Scale factor for distance culling decals.
var() bool DynamicShadows; // Whether to allow dynamic shadows.
var() bool LightEnvironmentShadows; // Whether to allow dynamic light environments to cast shadows.
var() bool MotionBlur; // Whether to allow motion blur.
var() bool DepthOfField; // Whether to allow depth of field.
var() bool AmbientOcclusion; // Whether to allow ambient occlusion.
var() bool Bloom; // Whether to allow bloom.
var() bool bAllowLightShafts; // Whether to allow light shafts.
var() bool Distortion; // Whether to allow distortion.
var() bool DropParticleDistortion; // Whether to allow dropping distortion on particles based on WorldInfo::bDropDetail.
var() bool LensFlares; // Whether to allow lens flares.
var() bool AllowRadialBlur; // Whether to allow radial blur effects to render.
var() bool bAllowSeparateTranslucency; // Whether to keep separate translucency (for better Depth of Field), experimental.
var() bool bAllowPostprocessMLAA; // Whether to allow post process MLAA to render. requires extra memory.
var() bool bAllowHighQualityMaterials; // Whether to use high quality materials when low quality exist.
var() int MaxFilterBlurSampleCount; // Max filter sample count.
var() int SkeletalMeshLODBias; // LOD bias for skeletal meshes.
var() int DetailMode; // Current detail mode; determines whether components of actors should be updated/ ticked.
var() float MaxDrawDistanceScale; // Scale applied to primitive's MaxDrawDistance.
var() int MaxAnisotropy; // Maximum level of anisotropy used.
var() bool bAllowD3D9MSAA;
var() int MinShadowResolution; // min dimensions (in texels) allowed for rendering shadow subject depths.
var() int MinPreShadowResolution; // min dimensions (in texels) allowed for rendering preshadow depths.
var() int MaxShadowResolution; // max square dimensions (in texels) allowed for rendering shadow subject depths.
var() int MaxWholeSceneDominantShadowResolution; // max square dimensions (in texels) allowed for rendering whole scene shadow depths.
var() float ShadowTexelsPerPixel; // The ratio of subject pixels to shadow texels.
var() bool bEnableBranchingPCFShadows; // Toggle Branching PCF implementation for projected shadows.
var() bool bAllowWholeSceneDominantShadows; // Whether to allow whole scene dominant shadows.
var() bool bUseConservativeShadowBounds; // Whether to use safe and conservative shadow frustum creation that wastes some shadowmap space.
var() bool bAllowFracturedDamage; // Whether to allow fractured meshes to take damage.
var() float FractureCullDistanceScale; // Distance scale for whether a fractured static mesh should actually fracture when damaged.
var() bool bApexClothingAsyncFetchResults; // If TRUE, allow APEX skinning to occur without blocking fetch results. bEnableParallelApexClothingFetch must be enabled for this to work.

// MOBILE SETTINGS
var() bool AllowPerFrameSleep; // TRUE if the application is allowed to sleep once a frame to smooth out CPU usage
var() bool AllowPerFrameYield; // TRUE if the application is allowed to yield once a frame to give other processes time to run. Note that bAllowPerFrameSleep takes precedence
var() int MobileFeatureLevel; // The baseline feature level of the device
var() bool MobileFog; // Whether to allow fog on mobile.
var() bool MobileHeightFog; // Whether to use height-fog on mobile, or simple gradient fog.
var() bool MobileSpecular; // Whether to allow vertex specular on mobile.
var() bool MobileBumpOffset; // Whether to allow bump offset on mobile
var() bool MobileNormalMapping; // Whether to allow normal mapping on mobile.
var() bool MobileEnvMapping; // Whether to allow environment mapping on mobile.
var() bool MobileRimLighting; // Whether to allow rim lighting on mobile.
var() bool MobileColorBlending; // Whether to allow color blending on mobile.
var() bool MobileVertexMovement; //Whether to allow vertex movement on mobile.
var() bool MobileEnableMSAA; // Whether to enable MSAA, if the OS supports it.
var() bool MobileModShadows; // TRUE if we try to support mobile modulated shadow.
var() bool MobileTiltShift; // TRUE to enable the mobile tilt shift effect.
var() bool bMobileUsingHighResolutionTiming; // TRUE if high resolution timing is enabled for this device
var() bool MobileColorGrading; // Whether to allow color grading on mobile.
var() int MobileLODBias; // How much to bias all texture mip levels on mobile (usually 0 or negative).
var() float MobileContentScaleFactor; // The default global content scale factor to use on device (largely iOS specific).

// PREFERENCE SETTINGS
var() bool UseVsync; // Whether to use VSync or not.
var() bool Fullscreen; // Fullscreen.
var() int ResX; // Screen X resolution.
var() int ResY; // Screen Y resolution.

// DEBUG SETTINGS
var() bool DynamicLights; // Whether to allow dynamic lights.
var() bool CompositeDynamicLights; // Whether to composte dynamic lights into light environments.
var() bool DirectionalLightmaps; // Whether to allow directional lightmaps, which use the material's normal and specular.
var() bool SpeedTreeLeaves; // Whether to allow rendering of SpeedTree leaves.
var() bool SpeedTreeFronds; // Whether to allow rendering of SpeedTree fronds.
var() bool OnlyStreamInTextures; // If enabled, texture will only be streamed in, not out.
var() bool OneFrameThreadLag; // Whether to allow the rendering thread to lag one frame behind the game thread.
var() bool UpscaleScreenPercentage; // Whether to upscale the screen to take up the full front buffer.
var() bool AllowOpenGL; // Whether to use OpenGL when it's available.
var() bool AllowSubsurfaceScattering; // Whether to allow sub-surface scattering to render.
var() bool AllowImageReflections; // Whether to allow image reflections to render.
var() bool AllowImageReflectionShadowing; // Whether to allow image reflections to be shadowed.
var() int ParticleLODBias; // LOD bias for particle systems.
var() int MaxMultiSamples; // The maximum number of MSAA samples to use.
var() bool bAllowTemporalAA;
var() int TemporalAA_MinDepth;
var() float TemporalAA_StartDepthVelocityScale;
var() float ScreenPercentage; // Percentage of screen main view should take up.
var() bool MobileOcclusionQueries; // Whether to allow occlusion queries on mobile.
var() bool MobileGlobalGammaCorrection;
var() bool MobileAllowGammaCorrectionWorldOverride;
var() bool MobileGfxGammaCorrection; // Whether to include gamma correction in the scaleform shaders.
var() bool MobileSceneDepthResolveForShadows;
var() bool MobileUsePreprocessedShaders; // Whether to use preprocessed shaders on mobile.
var() bool MobileFlashRedForUncachedShaders; // Whether to flash the screen red (non-final release only) when a cached shader is not found at runtime.
var() bool MobileWarmUpPreprocessedShaders; // Whether to issue a 'warm-up' draw call for mobile shaders as they are compiled.
var() bool MobileCachePreprocessedShaders; // Whether to dump out preprocessed shaders for mobile as they are encountered/compiled.
var() bool MobileProfilePreprocessedShaders; // Whether to run dumped out preprocessed shaders through the shader profiler.
var() bool MobileUseCPreprocessorOnShaders; // Whether to run the C preprocessor on shaders.
var() bool MobileLoadCPreprocessedShaders; // Whether to load the C preprocessed source.
var() bool MobileSharePixelShaders; // Whether to share pixel shaders across multiple unreal shaders.
var() bool MobileShareVertexShaders; // Whether to share vertex shaders across multiple unreal shaders.
var() bool MobileShareShaderPrograms; // Whether to share shaders program across multiple unreal shaders.
var() int MobileMaxMemory; // Value (in MB) to declare for maximum mobile memory on this device.
var() bool MobileClearDepthBetweenDPG; // Whether to clear the depth buffer between DPGs.
var() int MobileBoneCount; // The maximum number of bones supported for skinning.
var() int MobileBoneWeightCount; // The maximum number of bones influences per vertex supported for skinning.

// UNCATEGORIZED SETTINGS
var() bool SHSecondaryLighting; // Whether to allow light environments to use SH lights for secondary lighting.
var() bool MotionBlurPause; // Whether to allow motion blur to be paused.
var() int MotionBlurSkinning; // State of the console variable MotionBlurSkinning.
var() bool FilteredDistortion; // Whether to allow distortion to use bilinear filtering when sampling the scene color during its apply pass.
var() bool bAllowDownsampledTranslucency; // Whether to allow downsampled transluency.
var() bool FogVolumes; // Whether to allow fog volumes.
var() bool FloatingPointRenderTargets; // Whether to allow floating point render targets to be used.
var() int ShadowFilterQualityBias; // Quality bias for projected shadow buffer filtering. Higher values use better quality filtering.
var() int ShadowFadeResolution; // Resolution in texel below which shadows are faded out.
var() int PreShadowFadeResolution; // Resolution in texel below which preshadows are faded out.
var() float ShadowFadeExponent; // Controls the rate at which shadows are faded out.
var() float SceneCaptureStreamingMultiplier; // Scene capture streaming texture update distance scalar.
var() float PreShadowResolutionFactor;
var() bool bAllowHardwareShadowFiltering; // Whether to allow hardware filtering optimizations like hardware PCF and Fetch4.
var() int TessellationAdaptivePixelsPerTriangle; // Global tessellation factor multiplier.
var() bool bEnableForegroundShadowsOnWorld; // hack to allow for foreground DPG objects to cast shadows on the world DPG.
var() bool bEnableForegroundSelfShadowing; // Whether to allow foreground DPG self-shadowing.
var() int ShadowFilterRadius; // Radius, in shadowmap texels, of the filter disk.
var() float ShadowDepthBias; // Depth bias that is applied in the depth pass for all types of projected shadows except VSM.
var() int PerObjectShadowTransition; // Higher values make the per object soft shadow comparison sharper, lower values make the transition softer.
var() int PerSceneShadowTransition; // Higher values make the per scene soft shadow comparison sharper, lower values make the transition softer.
var() float CSMSplitPenumbraScale; // Scale applied to the penumbra size of Cascaded Shadow Map splits, useful for minimizing the transition between splits.
var() float CSMSplitSoftTransitionDistanceScale; // Scale applied to the soft comparison transition distance of Cascaded Shadow Map splits, useful for minimizing the transition between splits.
var() float CSMSplitDepthBiasScale; // Scale applied to the depth bias of Cascaded Shadow Map splits, useful for minimizing the transition between splits.
var() int CSMMinimumFOV; // Minimum camera FOV for CSM, this is used to prevent shadow shimmering when animating the FOV lower than the min, for example when zooming.
var() float CSMFOVRoundFactor; // The FOV will be rounded by this factor for the purposes of CSM, which turns shadow shimmering into discrete jumps.
var() float UnbuiltWholeSceneDynamicShadowRadius; // WholeSceneDynamicShadowRadius to use when using CSM to preview unbuilt lighting from a directional light.
var() int UnbuiltNumWholeSceneDynamicShadowCascades; // NumWholeSceneDynamicShadowCascades to use when using CSM to preview unbuilt lighting from a directional light.
var() int WholeSceneShadowUnbuiltInteractionThreshold; // How many unbuilt light-primitive interactions there can be for a light before the light switches to whole scene shadows.
var() float NumFracturedPartsScale; // Scales the game-specific number of fractured physics objects allowed.
var() float FractureDirectSpawnChanceScale; // Percent chance of a rigid body spawning after a fractured static mesh is damaged directly.  [0-1]
var() float FractureRadialSpawnChanceScale; // Percent chance of a rigid body spawning after a fractured static mesh is damaged by radial blast.  [0-1]
var() bool bForceCPUAccessToGPUSkinVerts; // Whether to force CPU access to GPU skinned vertex data.
var() bool bDisableSkeletalInstanceWeights; // Whether to disable instanced skeletal weights.
var() bool HighPrecisionGBuffers; // Whether to use high-precision GBuffers.
var() bool AllowSecondaryDisplays; // Whether to allow independent, external displays.
var() int SecondaryDisplayMaximumWidth; // The maximum width of any potentially allowed secondary displays (requires bAllowSecondaryDisplays == TRUE)
var() int SecondaryDisplayMaximumHeight; // The maximum height of any potentially allowed secondary displays (requires bAllowSecondaryDisplays == TRUE)
var() int MobileVertexScratchBufferSize; // The size of the scratch buffer for vertices (in kB).
var() int MobileIndexScratchBufferSize; // The size of the scratch buffer for indices (in kB).
var() int MobileShadowTextureResolution;
var() float MobileTiltShiftPosition; // Position of the focused center of the tilt shift effect (in percent of the screen height).
var() float MobileTiltShiftFocusWidth; // Width of focused area in the tilt shift effect (in percent of the screen height).
var() float MobileTiltShiftTransitionWidth; // Width of transition area in the tilt shift effect, where it transitions from full focus to full blur (in percent of the screen height).
var() float MobileLightShaftScale;
var() float MobileLightShaftFirstPass;
var() float MobileLightShaftSecondPass;
var() float MobileMaxShadowRange;
var() int MobileLandscapeLodBias; // LOD bias for mobile landscape rendering on this device (in addition to any per-landscape bias set).
var() bool MobileUseShaderGroupForStartupObjects; // Whether to automatically put cooked startup objects in the StartupPackages shader group
var() bool MobileMinimizeFogShaders; // Whether to disable generating both fog shader permutations on mobile.  When TRUE, it decreases load times but increases GPU cost for materials/levels with fog enabled
var() float ApexLODResourceBudget; // Resource budget for APEX LOD. Higher values indicate the system can handle more APEX load.
var() int ApexDestructionMaxChunkIslandCount; // The maximum number of active PhysX actors which represent dynamic groups of chunks (islands).
var() int ApexDestructionMaxShapeCount; // The maximum number of PhysX shapes which represent destructible chunks.
var() int ApexDestructionMaxChunkSeparationLOD; // Every destructible asset defines a min and max lifetime, and maximum separation distance for its chunks.
var() int ApexDestructionMaxFracturesProcessedPerFrame; // Lets the user throttle the number of fractures processed per frame (per scene) due to destruction, as this can be quite costly. The default is 0xffffffff (unlimited).
var() float ApexClothingAvgSimFrequencyWindow; // Average Simulation Frequency is estimated with the last n frames. This is used in Clothing when bAllowAdaptiveTargetFrequency is enabled.
var() bool ApexDestructionSortByBenefit; // If set to true, destructible chunks with the lowest benefit would get removed first instead of the oldest.
var() bool ApexGRBEnable; // Whether or not to use GPU Rigid Bodies.
var() int ApexGRBGPUMemSceneSize; // Amount (in MB) of GPU memory to allocate for GRB scene data (shapes, actors etc).
var() int ApexGRBGPUMemTempDataSize; // Amount (in MB) of GPU memory to allocate for GRB temporary data (broadphase pairs, contacts etc).
var() float ApexGRBMeshCellSize; // The size of the cells to divide the world into for GPU collision detection.
var() int ApexGRBNonPenSolverPosIterCount; // Number of non-penetration solver iterations.
var() int ApexGRBFrictionSolverPosIterCount; // Number of friction solver position iterations.
var() int ApexGRBFrictionSolverVelIterCount; // Number of friction solver velocity iterations.
var() float ApexGRBSkinWidth; // Collision skin width, as in PhysX.
var() float ApexGRBMaxLinearAcceleration; // Maximum linear acceleration.
var() bool bEnableParallelApexClothingFetch; // If TRUE, allow APEX clothing fetch (skinning etc) to be done on multiple threads.
var() bool ApexClothingAllowAsyncCooking; // ClothingActors will cook in a background thread to speed up creation time.
var() bool ApexClothingAllowApexWorkBetweenSubsteps; // Allow APEX SDK to interpolate clothing matrices between the substeps.
var() int ApexDestructionMaxActorCreatesPerFrame;

// Reads scalable System Settings directly from the INI and populates
// the variables in this class with the results.
// If they are not needed, you can omit mobile settings for better performance.
final function PopulateSystemSettings(optional bool IgnoreMobileSettings)
{
    local string DumpString;
    local array<string> Settings;
    local int i;
    local PlayerController PC;

    PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();
    if (PC == None)
        return;

    DumpString = PC.ConsoleCommand("SCALE Dump", false);
    Settings = SplitString(DumpString, "    ", true);

    for (i = 1; i < Settings.Length; i++)
    {
        ParseSetting(Settings[i]);
    }

    if (!IgnoreMobileSettings)
    {
        DumpString = PC.ConsoleCommand("SCALE DumpMobile", false);
        Settings = SplitString(DumpString, "    ", true);

        for (i = 1; i < Settings.Length; i++)
        {
            ParseSetting(Settings[i]);
        }
    }

    DumpString = PC.ConsoleCommand("SCALE DumpPrefs", false);
    Settings = SplitString(DumpString, "    ", true);

    for (i = 1; i < Settings.Length; i++)
    {
        if (IgnoreMobileSettings && Left(Settings[i], 6) != "Mobile")
            continue;

        ParseSetting(Settings[i]);
    }

    DumpString = PC.ConsoleCommand("SCALE DumpDebug", false);
    Settings = SplitString(DumpString, "    ", true);

    for (i = 1; i < Settings.Length; i++)
    {
        if (IgnoreMobileSettings && Left(Settings[i], 6) != "Mobile")
            continue;

        ParseSetting(Settings[i]);
    }

    DumpString = PC.ConsoleCommand("SCALE DumpUnknown", false);
    Settings = SplitString(DumpString, "    ", true);

    for (i = 1; i < Settings.Length; i++)
    {
        if (IgnoreMobileSettings && Left(Settings[i], 6) != "Mobile")
            continue;

        ParseSetting(Settings[i]);
    }
}

final function ParseSetting(string Setting)
{
    local int Pos;
    local string Cleaned;

    Pos = InStr(Setting, "(");
    Cleaned = Left(Setting, Pos); // string without descriptive comment.
    if (InStr(Cleaned, "TRUE", True, True) != -1)
    {
        Pos = InStr(Cleaned, "=");
        ParseBoolSetting(Left(Cleaned, Pos - 1), true);
    }
    else if (InStr(Cleaned, "FALSE", True, True) != -1)
    {
        Pos = InStr(Cleaned, "=");
        ParseBoolSetting(Left(Cleaned, Pos - 1), false);
    }
    else
    {
        Pos = InStr(Cleaned, "=");
        ParseNumericalSetting(Left(Cleaned, Pos - 1), Right(Cleaned, Len(Cleaned) - (Pos + 2)));
    }
}

final function ParseBoolSetting(string Key, bool Value)
{
    switch (Key)
    {
        case "AllowImageReflections":
            AllowImageReflections = Value;
            break;
        case "AllowImageReflectionShadowing":
            AllowImageReflectionShadowing = Value;
            break;
        case "AllowOpenGL":
            AllowOpenGL = Value;
            break;
        case "AllowPerFrameSleep":
            AllowPerFrameSleep = Value;
            break;
        case "AllowPerFrameYield":
            AllowPerFrameYield = Value;
            break;
        case "AllowRadialBlur":
            AllowRadialBlur = Value;
            break;
        case "AllowSecondaryDisplays":
            AllowSecondaryDisplays = Value;
            break;
        case "AllowSubsurfaceScattering":
            AllowSubsurfaceScattering = Value;
            break;
        case "AmbientOcclusion":
            AmbientOcclusion = Value;
            break;
        case "ApexClothingAllowApexWorkBetweenSubsteps":
            ApexClothingAllowApexWorkBetweenSubsteps = Value;
            break;
        case "ApexClothingAllowAsyncCooking":
            ApexClothingAllowAsyncCooking = Value;
            break;
        case "ApexDestructionSortByBenefit":
            ApexDestructionSortByBenefit = Value;
            break;
        case "ApexGRBEnable":
            ApexGRBEnable = Value;
            break;
        case "bAllowD3D9MSAA":
            bAllowD3D9MSAA = Value;
            break;
        case "bAllowDownsampledTranslucency":
            bAllowDownsampledTranslucency = Value;
            break;
        case "bAllowFracturedDamage":
            bAllowFracturedDamage = Value;
            break;
        case "bAllowHardwareShadowFiltering":
            bAllowHardwareShadowFiltering = Value;
            break;
        case "bAllowHighQualityMaterials":
            bAllowHighQualityMaterials = Value;
            break;
        case "bAllowLightShafts":
            bAllowLightShafts = Value;
            break;
        case "bAllowPostprocessMLAA":
            bAllowPostprocessMLAA = Value;
            break;
        case "bAllowSeparateTranslucency":
            bAllowSeparateTranslucency = Value;
            break;
        case "bAllowTemporalAA":
            bAllowTemporalAA = Value;
            break;
        case "bAllowWholeSceneDominantShadows":
            bAllowWholeSceneDominantShadows = Value;
            break;
        case "bApexClothingAsyncFetchResults":
            bApexClothingAsyncFetchResults = Value;
            break;
        case "bDisableSkeletalInstanceWeights":
            bDisableSkeletalInstanceWeights = Value;
            break;
        case "bEnableBranchingPCFShadows":
            bEnableBranchingPCFShadows = Value;
            break;
        case "bEnableForegroundSelfShadowing":
            bEnableForegroundSelfShadowing = Value;
            break;
        case "bEnableForegroundShadowsOnWorld":
            bEnableForegroundShadowsOnWorld = Value;
            break;
        case "bEnableParallelApexClothingFetch":
            bEnableParallelApexClothingFetch = Value;
            break;
        case "bForceCPUAccessToGPUSkinVerts":
            bForceCPUAccessToGPUSkinVerts = Value;
            break;
        case "Bloom":
            Bloom = Value;
            break;
        case "bMobileUsingHighResolutionTiming":
            bMobileUsingHighResolutionTiming = Value;
            break;
        case "bUseConservativeShadowBounds":
            bUseConservativeShadowBounds = Value;
            break;
        case "CompositeDynamicLights":
            CompositeDynamicLights = Value;
            break;
        case "DepthOfField":
            DepthOfField = Value;
            break;
        case "Distortion":
            Distortion = Value;
            break;
        case "DirectionalLightmaps":
            DirectionalLightmaps = Value;
            break;
        case "Distortion":
            Distortion = Value;
            break;
        case "DropParticleDistortion":
            DropParticleDistortion = Value;
            break;
        case "DynamicDecals":
            DynamicDecals = Value;
            break;
        case "DynamicLights":
            DynamicLights = Value;
            break;
        case "DynamicShadows":
            DynamicShadows = Value;
            break;
        case "FilteredDistortion":
            FilteredDistortion = Value;
            break;
        case "FloatingPointRenderTargets":
            FloatingPointRenderTargets = Value;
            break;
        case "FogVolumes":
            FloatingPointRenderTargets = Value;
            break;
        case "Fullscreen":
            Fullscreen = Value;
            break;
        case "HighPrecisionGBuffers":
            HighPrecisionGBuffers = Value;
            break;
        case "LensFlares":
            LensFlares = Value;
            break;
        case "LightEnvironmentShadows":
            LightEnvironmentShadows = Value;
            break;
        case "MobileAllowGammaCorrectionWorldOverride":
            MobileAllowGammaCorrectionWorldOverride = Value;
            break;
        case "MobileBumpOffset":
            MobileBumpOffset = Value;
            break;
        case "MobileCachePreprocessedShaders":
            MobileCachePreprocessedShaders = Value;
            break;
        case "MobileClearDepthBetweenDPG":
            MobileClearDepthBetweenDPG = Value;
            break;
        case "MobileColorBlending":
            MobileColorBlending = Value;
            break;
        case "MobileColorGrading":
            MobileColorGrading = Value;
            break;
        case "MobileEnableMSAA":
            MobileEnableMSAA = Value;
            break;
        case "MobileEnvMapping":
            MobileEnvMapping = Value;
            break;
        case "MobileFlashRedForUncachedShaders":
            MobileFlashRedForUncachedShaders = Value;
            break;
        case "MobileFog":
            MobileFog = Value;
            break;
        case "MobileGfxGammaCorrection":
            MobileGfxGammaCorrection = Value;
            break;
        case "MobileGlobalGammaCorrection":
            MobileGlobalGammaCorrection = Value;
            break;
        case "MobileHeightFog":
            MobileHeightFog = Value;
            break;
        case "MobileLoadCPreprocessedShaders":
            MobileLoadCPreprocessedShaders = Value;
            break;
        case "MobileMinimizeFogShaders":
            MobileMinimizeFogShaders = Value;
            break;
        case "MobileModShadows":
            MobileModShadows = Value;
            break;
        case "MobileNormalMapping":
            MobileNormalMapping = Value;
            break;
        case "MobileOcclusionQueries":
            MobileOcclusionQueries = Value;
            break;
        case "MobileProfilePreprocessedShaders":
            MobileProfilePreprocessedShaders = Value;
            break;
        case "MobileRimLighting":
            MobileRimLighting = Value;
            break;
        case "MobileSceneDepthResolveForShadows":
            MobileSceneDepthResolveForShadows = Value;
            break;
        case "MobileSharePixelShaders":
            MobileSharePixelShaders = Value;
            break;
        case "MobileShareShaderPrograms":
            MobileShareShaderPrograms = Value;
            break;
        case "MobileShareVertexShaders":
            MobileShareVertexShaders = Value;
            break;
        case "MobileSpecular":
            MobileSpecular = Value;
            break;
        case "MobileTiltShift":
            MobileTiltShift = Value;
            break;
        case "MobileUseCPreprocessorOnShaders":
            MobileUseCPreprocessorOnShaders = Value;
            break;
        case "MobileUsePreprocessedShaders":
            MobileUsePreprocessedShaders = Value;
            break;
        case "MobileUseShaderGroupForStartupObjects":
            MobileUseShaderGroupForStartupObjects = Value;
            break;
        case "MobileVertexMovement":
            MobileVertexMovement = Value;
            break;
        case "MobileWarmUpPreprocessedShaders":
            MobileWarmUpPreprocessedShaders = Value;
            break;
        case "MotionBlur":
            MotionBlur = Value;
            break;
        case "MotionBlurPause":
            MotionBlurPause = Value;
            break;
        case "OneFrameThreadLag":
            OneFrameThreadLag = Value;
            break;
        case "OnlyStreamInTextures":
            OnlyStreamInTextures = Value;
            break;
        case "SHSecondaryLighting":
            SHSecondaryLighting = Value;
            break;
        case "SpeedTreeFronds":
            SpeedTreeFronds = Value;
            break;
        case "SpeedTreeLeaves":
            SpeedTreeLeaves = Value;
            break;
        case "StaticDecals":
            StaticDecals = Value;
            break;
        case "UnbatchedDecals":
            UnbatchedDecals = Value;
            break;
        case "UpscaleScreenPercentage":
            UpscaleScreenPercentage = Value;
            break;
        case "UseVSync":
            UseVSync = Value;
            break;
        default:
            `warn(self@Key@"is unparsed boolean system setting!");
    }
}

final function ParseNumericalSetting(string Key, string Value)
{
    switch(Key)
    {
        case "ApexClothingAvgSimFrequencyWindow":
            ApexClothingAvgSimFrequencyWindow = float(Value);
            break;
        case "ApexDestructionMaxActorCreatesPerFrame":
            ApexDestructionMaxActorCreatesPerFrame = float(Value);
            break;
        case "ApexDestructionMaxChunkIslandCount":
            ApexDestructionMaxChunkIslandCount = float(Value);
            break;
        case "ApexDestructionMaxChunkSeparationLOD":
            ApexDestructionMaxChunkSeparationLOD = float(Value);
            break;
        case "ApexDestructionMaxFracturesProcessedPerFrame":
            ApexDestructionMaxFracturesProcessedPerFrame = float(Value);
            break;
        case "ApexDestructionMaxShapeCount":
            ApexDestructionMaxShapeCount = float(Value);
            break;
        case "ApexGRBFrictionSolverPosIterCount":
            ApexGRBFrictionSolverPosIterCount = float(Value);
            break;
        case "ApexGRBFrictionSolverVelIterCount":
            ApexGRBFrictionSolverVelIterCount = float(Value);
            break;
        case "ApexGRBGPUMemSceneSize":
            ApexGRBGPUMemSceneSize = float(Value);
            break;
        case "ApexGRBGPUMemTempDataSize":
            ApexGRBGPUMemTempDataSize = float(Value);
            break;
        case "ApexGRBMaxLinearAcceleration":
            ApexGRBMaxLinearAcceleration = float(Value);
            break;
        case "ApexGRBMeshCellSize":
            ApexGRBMeshCellSize = float(Value);
            break;
        case "ApexGRBNonPenSolverPosIterCount":
            ApexGRBNonPenSolverPosIterCount = float(Value);
            break;
        case "ApexGRBSkinWidth":
            ApexGRBSkinWidth = float(Value);
            break;
        case "ApexLODResourceBudget":
            ApexLODResourceBudget = float(Value);
            break;
        case "CSMFOVRoundFactor":
            CSMFOVRoundFactor = float(Value);
            break;
        case "CSMMinimumFOV":
            CSMMinimumFOV = float(Value);
            break;
        case "CSMSplitDepthBiasScale":
            CSMSplitDepthBiasScale = float(Value);
            break;
        case "CSMSplitDepthBiasScale":
            CSMSplitDepthBiasScale = float(Value);
            break;
        case "CSMSplitSoftTransitionDistanceScale":
            CSMSplitSoftTransitionDistanceScale = float(Value);
            break;
        case "CSMSplitPenumbraScale":
            CSMSplitPenumbraScale = float(Value);
            break;
        case "DecalCullDistanceScale":
            DecalCullDistanceScale = float(Value);
            break;
        case "DetailMode":
            DetailMode = float(Value);
            break;
        case "FractureCullDistanceScale":
            FractureCullDistanceScale = float(Value);
            break;
        case "FractureDirectSpawnChanceScale":
            FractureDirectSpawnChanceScale = float(Value);
            break;
        case "FractureRadialSpawnChanceScale":
            FractureRadialSpawnChanceScale = float(Value);
            break;
        case "MaxAnisotropy":
            MaxAnisotropy = float(Value);
            break;
        case "MaxDrawDistanceScale":
            MaxDrawDistanceScale = float(Value);
            break;
        case "MaxFilterBlurSampleCount":
            MaxFilterBlurSampleCount = float(Value);
            break;
        case "MaxMultiSamples":
            MaxMultiSamples = float(Value);
            break;
        case "MaxShadowResolution":
            MaxShadowResolution = float(Value);
            break;
        case "MaxWholeSceneDominantShadowResolution":
            MaxWholeSceneDominantShadowResolution = float(Value);
            break;
        case "MinPreShadowResolution":
            MinPreShadowResolution = float(Value);
            break;
        case "MinShadowResolution":
            MinShadowResolution = float(Value);
            break;
        case "MobileBoneCount":
            MobileBoneCount = float(Value);
            break;
        case "MobileBoneWeightCount":
            MobileBoneWeightCount = float(Value);
            break;
        case "MobileContentScaleFactor":
            MobileContentScaleFactor = float(Value);
            break;
        case "MobileFeatureLevel":
            MobileFeatureLevel = float(Value);
            break;
        case "MobileIndexScratchBufferSize":
            MobileIndexScratchBufferSize = float(Value);
            break;
        case "MobileLandscapeLODBias":
            MobileLandscapeLODBias = float(Value);
            break;
        case "MobileLightShaftFirstPass":
            MobileLightShaftFirstPass = float(Value);
            break;
        case "MobileLightShaftScale":
            MobileLightShaftScale = float(Value);
            break;
        case "MobileLightShaftSecondPass":
            MobileLightShaftSecondPass = float(Value);
            break;
        case "MobileLODBias":
            MobileLODBias = float(Value);
            break;
        case "MobileMaxMemory":
            MobileMaxMemory = float(Value);
            break;
        case "MobileMaxShadowRange":
            MobileMaxShadowRange = float(Value);
            break;
        case "MobileShadowTextureResolution":
            MobileShadowTextureResolution = float(Value);
            break;
        case "MobileTiltShiftFocusWidth":
            MobileTiltShiftFocusWidth = float(Value);
            break;
        case "MobileTiltShiftPosition":
            MobileTiltShiftPosition = float(Value);
            break;
        case "MobileTiltShiftTransitionWidth":
            MobileTiltShiftTransitionWidth = float(Value);
            break;
        case "MobileVertexScratchBufferSize":
            MobileVertexScratchBufferSize = float(Value);
            break;
        case "MotionBlurSkinning":
            MotionBlurSkinning = float(Value);
            break;
        case "NumFracturedPartsScale":
            NumFracturedPartsScale = float(Value);
            break;
        case "ParticleLODBias":
            ParticleLODBias = float(Value);
            break;
        case "PerObjectShadowTransition":
            PerObjectShadowTransition = float(Value);
            break;
        case "PerSceneShadowTransition":
            PerSceneShadowTransition = float(Value);
            break;
        case "PreShadowFadeResolution":
            PreShadowFadeResolution = float(Value);
            break;
        case "PreShadowResolutionFactor":
            PreShadowResolutionFactor = float(Value);
            break;
        case "ResX":
            ResX = float(Value);
            break;
        case "ResY":
            ResY = float(Value);
            break;
        case "SceneCaptureStreamingMultiplier":
            SceneCaptureStreamingMultiplier = float(Value);
            break;
        case "ScreenPercentage":
            ScreenPercentage = float(Value);
            break;
        case "SecondaryDisplayMaximumHeight":
            SecondaryDisplayMaximumHeight = float(Value);
            break;
        case "SecondaryDisplayMaximumWidth":
            SecondaryDisplayMaximumWidth = float(Value);
            break;
        case "ShadowDepthBias":
            ShadowDepthBias = float(Value);
            break;
        case "ShadowFadeExponent":
            ShadowFadeExponent = float(Value);
            break;
        case "ShadowFadeResolution":
            ShadowFadeResolution = float(Value);
            break;
        case "ShadowFilterQualityBias":
            ShadowFilterQualityBias = float(Value);
            break;
        case "ShadowFilterRadius":
            ShadowFilterRadius = float(Value);
            break;
        case "ShadowTexelsPerPixel":
            ShadowTexelsPerPixel = float(Value);
            break;
        case "SkeletalMeshLODBias":
            SkeletalMeshLODBias = float(Value);
            break;
        case "TemporalAA_MinDepth":
            TemporalAA_MinDepth = float(Value);
            break;
        case "TemporalAA_StartDepthVelocityScale":
            TemporalAA_StartDepthVelocityScale = float(Value);
            break;
        case "TessellationAdaptivePixelsPerTriangle":
            self.TessellationAdaptivePixelsPerTriangle = float(Value);
            break;
        case "UnbuiltNumWholeSceneDynamicShadowCascades":
            UnbuiltNumWholeSceneDynamicShadowCascades = float(Value);
            break;
        case "UnbuiltWholeSceneDynamicShadowRadius":
            UnbuiltWholeSceneDynamicShadowRadius = float(Value);
            break;
        case "WholeSceneShadowUnbuiltInteractionThreshold":
            WholeSceneShadowUnbuiltInteractionThreshold = float(Value);
            break;

        default:
            `warn(self@Key@"is unparsed numerical system setting!");
    }
}

/*
 Returns a string array with each index representing a resolution available on this system.
*/
final function array<string> GetAvailableResolutions()
{
    local array<string> TheStrings;
    local string TempString;
    local int i, j;

    TempString = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ConsoleCommand("DUMPAVAILABLERESOLUTIONS", false);
    ParseStringIntoArray(TempString, TheStrings, "\n", true);

    // Need to make sure that there are no duplicate entries.
    for (i = 0; i < TheStrings.Length; i++)
    {
        for (j = i+1; j < TheStrings.Length; j++)
        {
            if (TheStrings[i] == TheStrings[j])
            {
                TheStrings.Remove(j, 1);
                j--;
            }
        }
    }

    return TheStrings;
}


/*
 Sets all system settings to one pre-defined settings group.
 By default these are:
 0 = Custom
 1 = Minimum
 2 = Low
 3 = Medium
 4 = high
 5 = Maximum
*/
final function SetQualityBucket(byte BucketNum)
{
    if (BucketNum > 5)
        return;
    if (BucketNum != 0)
        ConsoleCommand("scale Bucket Bucket"$BucketNum);
    BucketSetting = BucketNum;
    SaveConfig();
}


/* Sets the Anti-Aliasing type to use.
 *
 * 0 = off
 * 1 = FXAA0 - NVIDIA 1 pass LQ PS3 and Xbox360 specific optimizations
 * 2 = FXAA1 - NVIDIA 1 pass LQ
 * 3 = FXAA2 - NVIDIA 1 pass LQ
 * 4 = FXAA3 - NVIDIA 1 pass HQ
 * 5 = FXAA4 - NVIDIA 1 pass HQ
 * 6 = FXAA5 - NVIDIA 1 pass HQ
 * 7 = MLAA - AMD 3 pass, requires extra render targets
 *
final function SetAAType(int iInt)
{
    local PostProcessChain Chain;
    local PostProcessEffect Effect;

    Chain = WorldInfo.WorldPostProcessChain;

    if (Chain != None && iInt < 7)
    {
        foreach Chain.Effects(Effect)
        {
            if (UberPostProcessEffect(Effect) != None)
            {
                switch(iInt)
                {
                    case 0:
                        UberPostProcessEffect(Effect).PostProcessAAType = PostProcessAA_Off;
                        break;
                    case 1:
                        UberPostProcessEffect(Effect).PostProcessAAType = PostProcessAA_FXAA0;
                        break;
                    case 2:
                        UberPostProcessEffect(Effect).PostProcessAAType = PostProcessAA_FXAA1;
                        break;
                    case 3:
                        UberPostProcessEffect(Effect).PostProcessAAType = PostProcessAA_FXAA2;
                        break;
                    case 4:
                        UberPostProcessEffect(Effect).PostProcessAAType = PostProcessAA_FXAA3;
                        break;
                    case 5:
                        UberPostProcessEffect(Effect).PostProcessAAType = PostProcessAA_FXAA4;
                        break;
                    case 6:
                        UberPostProcessEffect(Effect).PostProcessAAType = PostProcessAA_FXAA5;
                        break;
                    case 7:
                        UberPostProcessEffect(Effect).PostProcessAAType = PostProcessAA_MLAA;
                        break;
                }
                AAType = iInt;

            }
        }
    }
}*/


final function SetStaticDecals(bool bBool)
{
    StaticDecals = bBool;
    ConsoleCommand("scale Set StaticDecals" @ StaticDecals);
}

final function SetDynamicDecals(bool bBool)
{
    DynamicDecals = bBool;
    ConsoleCommand("scale Set DynamicDecals" @ DynamicDecals);
}

final function SetBatchedDecals(bool bBool)
{
    UnbatchedDecals = bBool;
    ConsoleCommand("scale Set UnbatchedDecals" @ UnbatchedDecals);
}

final function SetDecalCullDistanceScale(float fFloat)
{
    DecalCullDistanceScale = fFloat;
    ConsoleCommand("scale Set DecalCullDistanceScale" @ DecalCullDistanceScale);
}

final function SetDynamicLights(bool bBool)
{
    DynamicLights = bBool;
    ConsoleCommand("scale Set DynamicLights" @ DynamicLights);
}

final function SetDynamicShadows(bool bBool)
{
    DynamicShadows = bBool;
    ConsoleCommand("scale Set DynamicShadows" @ DynamicShadows);
}

final function SetLightEnvironmentShadows(bool bBool)
{
    LightEnvironmentShadows = bBool;
    ConsoleCommand("scale Set LightEnvironmentShadows" @ bBool);
}

final function SetCompositeDynamicLights(bool bBool)
{
    CompositeDynamicLights = bBool;
    ConsoleCommand("scale Set CompositeDynamicLights" @ CompositeDynamicLights);
}

final function SetSHSecondaryLighting(bool bBool)
{
    SHSecondaryLighting = bBool;
    ConsoleCommand("scale Set SHSecondaryLighting" @ SHSecondaryLighting);
}

final function SetDirectionalLightmaps(bool bBool)
{
    DirectionalLightmaps = bBool;
    ConsoleCommand("scale Set DirectionalLightmaps" @ DirectionalLightmaps);
}

final function SetMotionBlur(bool bBool)
{
    MotionBlur = bBool;
    ConsoleCommand("scale Set MotionBlur" @ MotionBlur);
}

final function SetMotionBlurPause(bool bBool)
{
    MotionBlurPause = bBool;
    ConsoleCommand("scale Set MotionBlurPause" @ MotionBlurPause);
}

final function SetMotionBlurSkinning(int Iint)
{
    MotionBlurSkinning = Iint;
    ConsoleCommand("scale Set MotionBlurSkinning" @ MotionBlurSkinning);
}

final function SetDepthOfField(bool bBool)
{
    DepthOfField = bBool;
    ConsoleCommand("scale Set DepthOfField" @ DepthOfField);
}

final function SetAmbientOcclusion(bool bBool)
{
    AmbientOcclusion = bBool;
    ConsoleCommand("scale Set AmbientOcclusion" @ AmbientOcclusion);
}

final function SetBloom(bool bBool)
{
    Bloom = bBool;
    ConsoleCommand("scale Set Bloom" @ Bloom);
}

final function SetbAllowLightShafts(bool bBool)
{
    bAllowLightShafts = bBool;
    ConsoleCommand("scale Set bAllowLightShafts" @ bAllowLightShafts);
}

final function SetDistortion(bool bBool)
{
    Distortion = bBool;
    ConsoleCommand("scale Set Distortion" @ Distortion);
}

final function SetFilteredDistortion(bool bBool)
{
    FilteredDistortion = bBool;
    ConsoleCommand("scale Set FilteredDistortion" @ FilteredDistortion);
}

final function SetbAllowDownsampledTranslucency(bool bBool)
{
    bAllowDownsampledTranslucency = bBool;
    ConsoleCommand("scale Set bAllowDownsampledTranslucency" @ bAllowDownsampledTranslucency);
}

final function SetSpeedTreeLeaves(bool bBool)
{
    SpeedTreeLeaves = bBool;
    ConsoleCommand("scale Set SpeedTreeLeaves" @ SpeedTreeLeaves);
}

final function SetSpeedTreeFronds(bool bBool)
{
    SpeedTreeFronds = bBool;
    ConsoleCommand("scale Set SpeedTreeFronds" @ SpeedTreeFronds);
}

final function SetOnlyStreamInTextures(bool bBool)
{
    OnlyStreamInTextures = bBool;
    ConsoleCommand("scale Set OnlyStreamInTextures" @ OnlyStreamInTextures);
}

final function SetLensFlares(bool bBool)
{
    LensFlares = bBool;
    ConsoleCommand("scale Set LensFlares" @ LensFlares);
}

final function SetFogVolumes(bool bBool)
{
    FogVolumes = bBool;
    ConsoleCommand("scale Set FogVolumes" @ FogVolumes);
}

final function SetFloatingPointRenderTargets(bool bBool)
{
    FloatingPointRenderTargets = bBool;
    ConsoleCommand("scale Set FloatingPointRenderTargets" @ FloatingPointRenderTargets);
}

final function SetOneFrameThreadLag(bool bBool)
{
    OneFrameThreadLag = bBool;
    ConsoleCommand("scale Set OneFrameThreadLag" @ OneFrameThreadLag);
}

final function SetUseVsync(bool bBool)
{
    UseVsync = bBool;
    ConsoleCommand("scale Set UseVsync" @ UseVsync);
}

final function SetUpscaleScreenPercentage(bool bBool)
{
    UpscaleScreenPercentage = bBool;
    ConsoleCommand("scale Set UpscaleScreenPercentage" @ UpscaleScreenPercentage);
}


final function SetFullscreen(bool bBool)
{
    Fullscreen = bBool;
    ConsoleCommand("scale Set Fullscreen" @ Fullscreen);
}

/*
final function SetAllowD3D11(bool bBool)
{
    AllowD3D11 = bBool;
    ConsoleCommand("scale Set AllowD3D11" @ AllowD3D11);
}
*/

final function SetAllowOpenGL(bool bBool)
{
    AllowOpenGL = bBool;
    ConsoleCommand("scale Set AllowOpenGL" @ AllowOpenGL);
}

final function SetAllowRadialBlur(bool bBool)
{
    AllowRadialBlur = bBool;
    ConsoleCommand("scale Set AllowRadialBlur" @ AllowRadialBlur);
}

final function SetAllowSubsurfaceScattering(bool bBool)
{
    AllowSubsurfaceScattering = bBool;
    ConsoleCommand("scale Set AllowSubsurfaceScattering" @ AllowSubsurfaceScattering);
}

final function SetAllowImageReflections(bool bBool)
{
    AllowImageReflections = bBool;
    ConsoleCommand("scale Set AllowImageReflections" @ AllowImageReflections);
}

final function SetAllowImageReflectionShadowing(bool bBool)
{
    AllowImageReflectionShadowing = bBool;
    ConsoleCommand("scale Set AllowImageReflectionShadowing" @ AllowImageReflectionShadowing);
}

final function SetbAllowSeparateTranslucency(bool bBool)
{
    bAllowSeparateTranslucency = bBool;
    ConsoleCommand("scale Set bAllowSeparateTranslucency" @ bAllowSeparateTranslucency);
}

final function SetbAllowPostprocessMLAA(bool bBool)
{
    bAllowPostprocessMLAA = bBool;
    ConsoleCommand("scale Set bAllowPostprocessMLAA" @ bAllowPostprocessMLAA);
}

final function SetbAllowHighQualityMaterials(bool bBool)
{
    bAllowHighQualityMaterials = bBool;
    ConsoleCommand("scale Set bAllowHighQualityMaterials" @ bAllowHighQualityMaterials);
}

final function SetSkeletalMeshLODBias(int iInt)
{
    SkeletalMeshLODBias = iInt;
    ConsoleCommand("scale Set SkeletalMeshLODBias" @ SkeletalMeshLODBias);
}

final function SetParticleLODBias(int iInt)
{
    ParticleLODBias = iInt;
    ConsoleCommand("scale Set ParticleLODBias" @ ParticleLODBias);
}

final function SetDetailMode(int iInt)
{
    DetailMode = iInt;
    ConsoleCommand("scale Set DetailMode" @ DetailMode);
}

final function SetMaxDrawDistanceScale(float fFloat)
{
    MaxDrawDistanceScale = fFloat;
    ConsoleCommand("scale Set MaxDrawDistanceScale" @ MaxDrawDistanceScale);
}

final function SetShadowFilterQualityBias(int iInt)
{
    ShadowFilterQualityBias = iInt;
    ConsoleCommand("scale Set ShadowFilterQualityBias" @ ShadowFilterQualityBias);
}

final function SetMaxAnisotropy(int iInt)
{
    MaxAnisotropy = iInt;
    ConsoleCommand("scale Set MaxAnisotropy" @ MaxAnisotropy);
}

final function SetMaxMultiSamples(int iInt)
{
    MaxMultiSamples = iInt;
    ConsoleCommand("scale Set MaxMultiSamples" @ MaxMultiSamples);
}

final function SetbAllowD3D9MSAA(bool bBool)
{
    bAllowD3D9MSAA = bBool;
    ConsoleCommand("scale Set bAllowD3D9MSAA" @ bAllowD3D9MSAA);
}

final function SetbAllowTemporalAA(bool bBool)
{
    bAllowTemporalAA = bBool;
    ConsoleCommand("scale Set bAllowTemporalAA" @ bAllowTemporalAA);
}

final function SetTemporalAA_MinDepth(float fFloat)
{
    TemporalAA_MinDepth = fFloat;
    ConsoleCommand("scale Set TemporalAA_MinDepth" @ TemporalAA_MinDepth);
}

final function SetTemporalAA_StartDepthVelocityScale(float fFloat)
{
    TemporalAA_StartDepthVelocityScale = fFloat;
    ConsoleCommand("scale Set TemporalAA_StartDepthVelocityScale" @ TemporalAA_StartDepthVelocityScale);
}

final function SetMinShadowResolution(int iInt)
{
    MinShadowResolution = iInt;
    ConsoleCommand("scale Set MinShadowResolution" @ MinShadowResolution);
}

final function SetMinPreShadowResolution(int iInt)
{
    MinPreShadowResolution = iInt;
    ConsoleCommand("scale Set MinPreShadowResolution" @ MinPreShadowResolution);
}

final function SetMaxShadowResolution(int iInt)
{
    MaxShadowResolution = iInt;
    ConsoleCommand("scale Set MaxShadowResolution" @ MaxShadowResolution);
}

final function SetMobileShadowTextureResolution(int iInt)
{
    MobileShadowTextureResolution = iInt;
    ConsoleCommand("scale Set MobileShadowTextureResolution" @ MobileShadowTextureResolution);
}

final function SetMaxWholeSceneDominantShadowResolution(int iInt)
{
    MaxWholeSceneDominantShadowResolution = iInt;
    ConsoleCommand("scale Set MaxWholeSceneDominantShadowResolution" @ MaxWholeSceneDominantShadowResolution);
}

final function SetShadowFadeResolution(int iInt)
{
    ShadowFadeResolution = iInt;
    ConsoleCommand("scale Set ShadowFadeResolution" @ ShadowFadeResolution);
}

final function SetPreShadowFadeResolution(int iInt)
{
    PreShadowFadeResolution = iInt;
    ConsoleCommand("scale Set PreShadowFadeResolution" @ PreShadowFadeResolution);
}

final function SetShadowFadeExponent(float fFloat)
{
    ShadowFadeExponent = fFloat;
    ConsoleCommand("scale Set ShadowFadeExponent" @ ShadowFadeExponent);
}

final function SetResX(int iInt)
{
    ResX = iInt;
    ConsoleCommand("scale Set ResX" @ ResX);
}

final function SetResY(int iInt)
{
    ResY = iInt;
    ConsoleCommand("scale Set ResY" @ ResY);
}

final function SetScreenPercentage(float fFloat)
{
    ScreenPercentage = fFloat;
    ConsoleCommand("scale Set ScreenPercentage" @ ScreenPercentage);
}

final function SetSceneCaptureStreamingMultiplier(float fFloat)
{
    SceneCaptureStreamingMultiplier = fFloat;
    ConsoleCommand("scale Set SceneCaptureStreamingMultiplier" @ SceneCaptureStreamingMultiplier);
}

final function SetShadowTexelsPerPixel(float fFloat)
{
    ShadowTexelsPerPixel = fFloat;
    ConsoleCommand("scale Set ShadowTexelsPerPixel" @ ShadowTexelsPerPixel);
}

final function SetPreShadowResolutionFactor(float fFloat)
{
    PreShadowResolutionFactor = fFloat;
    ConsoleCommand("scale Set PreShadowResolutionFactor" @ PreShadowResolutionFactor);
}

/*
final function SetbEnableVSMShadows(bool bBool)
{
    bEnableVSMShadows = bBool;
    ConsoleCommand("scale Set bEnableVSMShadows" @ bEnableVSMShadows);
}
*/

final function SetbEnableBranchingPCFShadows(bool bBool)
{
    bEnableBranchingPCFShadows = bBool;
    ConsoleCommand("scale Set bEnableBranchingPCFShadows" @ bEnableBranchingPCFShadows);
}

final function SetbAllowHardwareShadowFiltering(bool bBool)
{
    bAllowHardwareShadowFiltering = bBool;
    ConsoleCommand("scale Set bAllowHardwareShadowFiltering" @ bAllowHardwareShadowFiltering);
}

final function SetTessellationAdaptivePixelsPerTriangle(float fFloat)
{
    TessellationAdaptivePixelsPerTriangle = fFloat;
    ConsoleCommand("scale Set TessellationAdaptivePixelsPerTriangle" @ TessellationAdaptivePixelsPerTriangle);
}

final function SetbEnableForegroundShadowsOnWorld(bool bBool)
{
    bEnableForegroundShadowsOnWorld = bBool;
    ConsoleCommand("scale Set bEnableForegroundShadowsOnWorld" @ bEnableForegroundShadowsOnWorld);
}

final function SetbEnableForegroundSelfShadowing(bool bBool)
{
    bEnableForegroundSelfShadowing = bBool;
    ConsoleCommand("scale Set bEnableForegroundSelfShadowing" @ bEnableForegroundSelfShadowing);
}

final function SetbAllowWholeSceneDominantShadows(bool bBool)
{
    bAllowWholeSceneDominantShadows = bBool;
    ConsoleCommand("scale Set bAllowWholeSceneDominantShadows" @ bAllowWholeSceneDominantShadows);
}

final function SetbUseConservativeShadowBounds(bool bBool)
{
    bUseConservativeShadowBounds = bBool;
    ConsoleCommand("scale Set bUseConservativeShadowBounds" @ bUseConservativeShadowBounds);
}

final function SetShadowFilterRadius(float fFloat)
{
    ShadowFilterRadius = fFloat;
    ConsoleCommand("scale Set ShadowFilterRadius" @ ShadowFilterRadius);
}

final function SetShadowDepthBias(float fFloat)
{
    ShadowDepthBias = fFloat;
    ConsoleCommand("scale Set ShadowDepthBias" @ ShadowDepthBias);
}

final function SetPerObjectShadowTransition(float fFloat)
{
    PerObjectShadowTransition = fFloat;
    ConsoleCommand("scale Set PerObjectShadowTransition" @ PerObjectShadowTransition);
}

final function SetPerSceneShadowTransition(float fFloat)
{
    PerSceneShadowTransition = fFloat;
    ConsoleCommand("scale Set PerSceneShadowTransition" @ PerSceneShadowTransition);
}

final function SetCSMSplitPenumbraScale(float fFloat)
{
    CSMSplitPenumbraScale = fFloat;
    ConsoleCommand("scale Set CSMSplitPenumbraScale" @ CSMSplitPenumbraScale);
}

final function SetCSMSplitSoftTransitionDistanceScale(float fFloat)
{
    CSMSplitSoftTransitionDistanceScale = fFloat;
    ConsoleCommand("scale Set CSMSplitSoftTransitionDistanceScale" @ CSMSplitSoftTransitionDistanceScale);
}

final function SetCSMSplitDepthBiasScale(float fFloat)
{
    CSMSplitDepthBiasScale = fFloat;
    ConsoleCommand("scale Set CSMSplitDepthBiasScale" @ CSMSplitDepthBiasScale);
}

final function SetCSMMinimumFOV(float fFloat)
{
    CSMMinimumFOV = fFloat;
    ConsoleCommand("scale Set CSMMinimumFOV" @ CSMMinimumFOV);
}

final function SetCSMFOVRoundFactor(float fFloat)
{
    CSMFOVRoundFactor = fFloat;
    ConsoleCommand("scale Set CSMFOVRoundFactor" @ CSMFOVRoundFactor);
}

final function SetUnbuiltWholeSceneDynamicShadowRadius(float fFloat)
{
    UnbuiltWholeSceneDynamicShadowRadius = fFloat;
    ConsoleCommand("scale Set UnbuiltWholeSceneDynamicShadowRadius" @ UnbuiltWholeSceneDynamicShadowRadius);
}

final function SetUnbuiltNumWholeSceneDynamicShadowCascades(int iInt)
{
    UnbuiltNumWholeSceneDynamicShadowCascades = iInt;
    ConsoleCommand("scale Set UnbuiltNumWholeSceneDynamicShadowCascades" @ UnbuiltNumWholeSceneDynamicShadowCascades);
}

final function SetWholeSceneShadowUnbuiltinteractionThreshold(int iInt)
{
    WholeSceneShadowUnbuiltInteractionThreshold = iInt;
    ConsoleCommand("scale Set WholeSceneShadowUnbuiltInteractionThreshold" @ WholeSceneShadowUnbuiltInteractionThreshold);
}

final function SetbAllowFracturedDamage(bool bBool)
{
    bAllowFracturedDamage = bBool;
    ConsoleCommand("scale Set bAllowFracturedDamage" @ bAllowFracturedDamage);
}

final function SetNumFracturedPartsScale(float fFloat)
{
    NumFracturedPartsScale = fFloat;
    ConsoleCommand("Scale Set NumFracturedPartsScale" @ NumFracturedPartsScale);
}

final function SetFractureDirectSpawnChanceScale(float fFloat)
{
    FractureDirectSpawnChanceScale = fFloat;
    ConsoleCommand("scale Set FractureDirectSpawnChanceScale" @ FractureDirectSpawnChanceScale);
}

final function SetFractureRadialSpawnChanceScale(float fFloat)
{
    FractureDirectSpawnChanceScale = fFloat;
    ConsoleCommand("scale Set FractureDirectSpawnChanceScale" @ FractureDirectSpawnChanceScale);
}

final function SetFractureCullDistanceScale(float fFloat)
{
    FractureCullDistanceScale = fFloat;
    ConsoleCommand("scale Set FractureCullDistanceScale" @ FractureCullDistanceScale);
}

final function SetbForceCPUAccesToGPUSkinVerts(bool bBool)
{
    bForceCPUAccessToGPUSkinVerts = bBool;
    ConsoleCommand("scale Set bForceCPUAccesToGPUSkinVerts" @ bForceCPUAccessToGPUSkinVerts);
}

final function SetbDisableSkeletalInstanceWeights(bool bBool)
{
    bDisableSkeletalInstanceWeights = bBool;
    ConsoleCommand("scale Set bDisableSkeletalInstanceWeights" @ bDisableSkeletalInstanceWeights);
}

final function SetHighPrecisionGBuffers(bool bBool)
{
    HighPrecisionGBuffers = bBool;
    ConsoleCommand("scale Set HighPrecisionGBuffers" @ HighPrecisionGBuffers);
}

final function SetAllowSecondaryDisplays(bool bBool)
{
    AllowSecondaryDisplays = bBool;
    ConsoleCommand("scale Set AllowSecondaryDisplays" @ AllowSecondaryDisplays);
}

final function SetSecondaryDisplayMaximumWidth(int iInt)
{
    SecondaryDisplayMaximumWidth = iInt;
    ConsoleCommand("scale Set SecondaryDisplayMaximumWidth" @ SecondaryDisplayMaximumWidth);
}

final function SetSecondaryDisplayMaximumHeight(int iInt)
{
    SecondaryDisplayMaximumHeight = iInt;
    ConsoleCommand("scale Set SecondaryDisplayMaximumHeight" @ SecondaryDisplayMaximumHeight);
}

/*
final function SetMobileFeatureLevel()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileFog()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileHeightFog()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileSpecular()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileBumpOffSet()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileNormalMapping()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileEnvMapping()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileRimLighting()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileColorBlending()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileColorGrading()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileVertexMovement()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileOcclusionQueries()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileLODBias()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileBoneCount()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileBoneWeightCount()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileUsePreprocessedShaders()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileFlashRedForUncachedShaders()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileWarmUpPreprocessedShaders()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileCachePreprocessedShaders()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileProfilePreprocessedShaders()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileUseCPreprocessorOnShaders()
{

    ConsoleCommand("scale Set " @ );
}
final function SetMobileLoadCPreprocessedShaders()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileSharePixelShaders()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileShareVertexShaders()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileShareShaderPrograms()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileEnableMSAA()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileContentScaleFactor()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileVertexScratchBufferSize()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileIndexScratchBufferSize()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileModShadows()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileTiltShift()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileTiltShiftPosition()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileTiltShiftTransitionWidth()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileMaxShadowRange()
{

    ConsoleCommand("Scale Set " @ );
}
final function SetMobileClearDepthBetweenDPG()
{

    ConsoleCommand("Scale Set " @ );
}*/

final function SetApexLODResourceBudget(float fFloat)
{
    ApexLODResourceBudget = fFloat;
    ConsoleCommand("scale Set ApexLODResourceBudget" @ ApexLODResourceBudget);
}

final function SetApexDestructionMaxChunkIslandCount(int iInt)
{
    ApexDestructionMaxChunkIslandCount = iInt;
    ConsoleCommand("scale Set ApexDestructionMaxChunkIslandCount" @ ApexDestructionMaxChunkIslandCount);
}

final function SetApexDestructionMaxShapeCount(int iInt)
{
    ApexDestructionMaxShapeCount = iInt;
    ConsoleCommand("scale Set ApexDestructionMaxShapeCount" @ ApexDestructionMaxShapeCount);
}

final function SetApexDestructionMaxChunkSeparationLOD(float fFloat)
{
    ApexDestructionMaxChunkSeparationLOD = fFloat;
    ConsoleCommand("scale Set ApexDestructionMaxChunkSeparationLOD" @ ApexDestructionMaxChunkSeparationLOD);
}

final function SetApexDestructionMaxActorCreatesPerFrame(int iInt)
{
    ApexDestructionMaxActorCreatesPerFrame = iInt;
    ConsoleCommand("scale Set ApexDestructionMaxActorCreatesPerFrame" @ ApexDestructionMaxActorCreatesPerFrame);
}

final function SetApexDestructionMaxFracturesProcessedPerFrame(int iInt)
{
    ApexDestructionMaxFracturesProcessedPerFrame = iInt;
    ConsoleCommand("scale Set ApexDestructionMaxFracturesProcessedPerFrame" @ ApexDestructionMaxFracturesProcessedPerFrame);
}

final function SetApexDestructionSortByBenefit(bool bBool)
{
    ApexDestructionSortByBenefit = bBool;
    ConsoleCommand("scale Set ApexDestructionSortByBenefit" @ ApexDestructionSortByBenefit);
}

final function SetApexGRBEnable(bool bBool)
{
    ApexGRBEnable = bBool;
    ConsoleCommand("scale Set ApexGRBEnable" @ ApexGRBEnable);
}

final function SetApexGRBGPUMemSceneSize(int iInt)
{
    ApexGRBGPUMemSceneSize = iInt;
    ConsoleCommand("scale Set ApexGRBGPUMemSceneSize" @ ApexGRBGPUMemSceneSize);
}

final function SetApexGRBGPUMemTempDataSize(int iInt)
{
    ApexGRBGPUMemTempDataSize = iInt;
    ConsoleCommand("scale Set ApexGRBGPUMemTempDataSize" @ ApexGRBGPUMemTempDataSize);
}

final function SetApexGRBMeshCellSize(float fFloat)
{
    ApexGRBMeshCellSize = fFloat;
    ConsoleCommand("scale Set ApexGRBMeshCellSize" @ ApexGRBMeshCellSize);
}

final function SetApexGRBNonPenSolverPosIterCount(int iInt)
{
    ApexGRBNonPenSolverPosIterCount = iInt;
    ConsoleCommand("scale Set ApexGRBNonPenSolverPosIterCount" @ ApexGRBNonPenSolverPosIterCount);
}

final function SetApexGRBFrictionSolverPosIterCount(int iInt)
{
    ApexGRBFrictionSolverPosIterCount = iInt;
    ConsoleCommand("scale Set ApexGRBFrictionSolverPosIterCount" @ ApexGRBFrictionSolverPosIterCount);
}

final function SetApexGRBFrictionSolverVelIterCount(int iInt)
{
    ApexGRBFrictionSolverVelIterCount = iInt;
    ConsoleCommand("scale Set ApexGRBFrictionSolverVelIterCount" @ ApexGRBFrictionSolverVelIterCount);
}

final function SetApexGRBSkinWidth(float fFloat)
{
    ApexGRBSkinWidth = fFloat;
    ConsoleCommand("scale Set ApexGRBSkinWidth" @ ApexGRBSkinWidth);
}

final function SetApexGRBMaxLinearAcceleration(float fFloat)
{
    ApexGRBMaxLinearAcceleration = fFloat;
    ConsoleCommand("scale Set ApexGRBMaxLinearAcceleration" @ ApexGRBMaxLinearAcceleration);
}

final function SetbEnableParallelAPEXClothingFetch(bool bBool)
{
    bEnableParallelAPEXClothingFetch = bBool;
    ConsoleCommand("scale Set bEnableParallelAPEXClothingFetch" @ bEnableParallelAPEXClothingFetch);
}

final function SetApexClothingAvgSimFrequencyWindow(int iInt)
{
    ApexClothingAvgSimFrequencyWindow = iInt;
    ConsoleCommand("scale Set ApexClothingAvgSimFrequencyWindow" @ ApexClothingAvgSimFrequencyWindow);
}

final function SetApexClothingAllowAsyncCooking(bool bBool)
{
    ApexClothingAllowAsyncCooking = bBool;
    ConsoleCommand("scale Set ApexClothingAllowAsyncCooking" @ ApexClothingAllowAsyncCooking);
}

final function SetApexClothingAllowApexWorkBetweenSubsteps(bool bBool)
{
    ApexClothingAllowApexWorkBetweenSubsteps = bbool;
    ConsoleCommand("scale Set ApexClothingAllowApexWorkBetweenSubsteps" @ ApexClothingAllowApexWorkBetweenSubsteps);
}

DefaultProperties
{
}