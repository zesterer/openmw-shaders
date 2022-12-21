#ifndef CONFIG_GLSL
#define CONFIG_GLSL

// This file contains various configuration parameters for the mod's shaders.
// Ensure that you restart OpenMW after making a change to this file: it will not reload automatically!

// Here is a list of lighting 'presets' you can try to avoid spending ages tweaking values:
#define CUSTOM 0 // You can use this present to customise things as you like
#define VANILLA 1 // Designed to emulate the feel of vanilla Morrowind
#define ZESTERER 2 // Colorful and intense fantasy lighting
#define MGE_XE 3 // An attempt at emulating the soft lighting of MGE XE

// IMPORTANT: Change this variable to quickly switch presets
//            ,--------.
#define PRESET ZESTERER
//            '------- '

#if (PRESET == CUSTOM)
    // IMPORTANT: For these settings to have an effect, the 'PRESET' variable above must be set to 'CUSTOM'
    //
    // Change these values to edit your custom preset
    // Each value comes with an explanation, and recommended values.

    // Change this to alter the saturation of albedo (i.e: base color).
    // Recommended values:
    // 0.8  => Very desaturated (looks like Vvardenfell is in the UK)
    // 1.0  => Desaturated (close to the original vanilla colors of Morrowind)
    // 1.2  => Mildly desaturated (most realistic)
    // 1.4  => Bright, fun colours (I prefer this)
    // 1.75 => Oversaturated (more Alice in Wonderland than Morrowind)
    #define SATURATION_FACTOR 1.2

    // Normal map mods for Morrowind can often be very extreme and may need toning down.
    // Recommended values:
    // 0.0 => Normal maps have no effect
    // 0.5 => Less intense (smoother surfaces)
    // 1.0 => Default
    // 2.0 => Very intense (rougher surfaces)
    #define NORMAL_MAP_INTENSITY 0.3

    // The intensity of direct sunlight
    // Recommended values:
    // 0.4 => Weak, closer to the original game
    // 0.7 => Bright, but not overpowering
    // 1.0 => Solar flare, take cover!
    #define SUNLIGHT_STRENGTH 0.6

    // The intensity of ambient light
    // Recommended values:
    // 0.3 => Low, like being in space
    // 0.5 => Medium, more realistic
    // 0.7 => Strong, well-lit shadows
    // 1.0 => Shadows? What shadows?
    #define AMBIANCE_STRENGTH 0.5

    // The intensity of interior light (applies for buildings and underground spaces)
    // Recommended values:
    // 0.4 => Low, very dark interiors
    // 0.6 => Medium, dingy interiors
    // 0.8 => Normal, well-lit interiors
    // 1.1 => Bright, very well-lit interiors
    #define INTERIOR_STRENGTH 0.8

    // The extent of procedural detailing on distant terrain (increasing this doesn't impact performance)
    // Recommended values:
    // 0.0 => Disabled entirely (slightly better for performance)
    // 0.25 => Very low, almost too subtle to notice
    // 0.5 => Medium, nice with vanilla textures
    // 0.75 => Moderate, looks better if you have a normal map mod for near terrain too
    // 1.0 => Strong, harsh craggs and details
    #define PROCEDURAL_DETAIL_LEVEL 0.75

    // The amplitude of wind swaying applied to leaves
    // Recommended values:
    // 0.0 => Disabled entirely (slightly better for performance)
    // 0.2 => Very subtle
    // 0.6 => Regular
    // 1.0 => Strong
    // 2.0 => Hurricane
    #define WIND_AMPLITUDE 0.5

    // Whether a wave effect is enabled for terrain near water
    // Recommended values:
    // 0 => Disabled
    // 1 => Enabled
    #define WAVES 1

    // The amplitude of waves in world units
    // Recommended values:
    // 3.0 => Makes ponds look nice and calm
    // 6.0 => Makes moderate-to-large bodies of water look good
    // 10.0 => Makes oceans look good
    #define WAVE_HEIGHT 6.0

    // Whether caustics (refractive light from waves on the water surface) are applied to underwater scenes
    // Recommended values:
    // 0 => Disabled
    // 1 => Enabled
    #define CAUSTICS 1

    // Whether tonemapping at the end of the forward pass is eanbled. This will make colour grading look slightly
    // better, with the disadvantage that post-processing shaders no longer operate upon linear light values.
    // Recommended values:
    // 0 => Disabled
    // 1 => Enabled
    #define FORWARD_TONEMAPPING 1

    // The gamma value used by the forward pass tonemapper, if enabled.
    // Recommended values:
    // 1.0 => Low contrast
    // 1.3 => Medium contrast
    // 1.5 => High contrast
    #define FORWARD_TONEMAPPING_GAMMA 1.3

    // The exposure value used by the forward pass tonemapper, if enabled.
    // Recommended values:
    // 1.0 => Dark, dingy lighting
    // 1.2 => Well-lit lighting
    // 1.4 => Bright, over-exposed lighting
    #define FORWARD_TONEMAPPING_EXPOSURE 1.25

    // Whether support for Physically-Based Rendering (PBR) textures is enabled. Even if you don't use PBR texture
    // mods, there should be no need to disable this: the shaders will generate reasonable PBR parameters for anything
    // that lacks PBR textures.
    // Recommended values:
    // 0 => Disabled
    // 1 => Enabled
    #define PBR_TEXTURES 1

    // As-yet undocumented settings. Play with them if you wish!
    #define TINT 0.5
    #define HUE_SHIFT 0.0
    #define BUILTIN_FOG 1
    #define POINT_LIGHT_MODERATION 1
    #define MAJESTIC_WARP 0
#elif (PRESET == VANILLA)
    #define SATURATION_FACTOR 1.0
    #define NORMAL_MAP_INTENSITY 0.75
    #define SUNLIGHT_STRENGTH 0.4
    #define AMBIANCE_STRENGTH 0.55
    #define INTERIOR_STRENGTH 0.75
    #define PROCEDURAL_DETAIL_LEVEL 0.5
    #define WIND_AMPLITUDE 0.2
    #define WAVES 1
    #define WAVE_HEIGHT 6.0
    #define FORWARD_TONEMAPPING 1
    #define FORWARD_TONEMAPPING_GAMMA 1.3
    #define FORWARD_TONEMAPPING_EXPOSURE 1.25
    #define PBR_TEXTURES 1
    #define TINT 0.0
    #define HUE_SHIFT 0.0
    #define CAUSTICS 1
    #define BUILTIN_FOG 1
    #define POINT_LIGHT_MODERATION 1
    #define MAJESTIC_WARP 0
#elif (PRESET == ZESTERER)
    #define SATURATION_FACTOR 1.4
    #define NORMAL_MAP_INTENSITY 1.25
    #define SUNLIGHT_STRENGTH 0.8
    #define AMBIANCE_STRENGTH 0.6
    #define INTERIOR_STRENGTH 0.5
    #define PROCEDURAL_DETAIL_LEVEL 1.0
    #define WIND_AMPLITUDE 0.75
    #define WAVES 1
    #define WAVE_HEIGHT 8.0
    #define FORWARD_TONEMAPPING 1
    #define FORWARD_TONEMAPPING_GAMMA 1.3
    #define FORWARD_TONEMAPPING_EXPOSURE 1.25
    #define PBR_TEXTURES 1
    #define TINT 1.25
    #define HUE_SHIFT -0.02
    #define CAUSTICS 1
    #define BUILTIN_FOG 1
    #define POINT_LIGHT_MODERATION 0
    #define MAJESTIC_WARP 0
#elif (PRESET == MGE_XE)
    #define SATURATION_FACTOR 1.4
    #define NORMAL_MAP_INTENSITY 0.25
    #define SUNLIGHT_STRENGTH 0.3
    #define AMBIANCE_STRENGTH 0.4
    #define INTERIOR_STRENGTH 0.7
    #define PROCEDURAL_DETAIL_LEVEL 0.4
    #define WIND_AMPLITUDE 0.4
    #define WAVES 1
    #define WAVE_HEIGHT 8.0
    #define FORWARD_TONEMAPPING 1
    #define FORWARD_TONEMAPPING_GAMMA 1.3
    #define FORWARD_TONEMAPPING_EXPOSURE 1.25
    #define PBR_TEXTURES 1
    #define TINT 0.5
    #define HUE_SHIFT -0.015
    #define CAUSTICS 1
    #define BUILTIN_FOG 1
    #define POINT_LIGHT_MODERATION 1
    #define MAJESTIC_WARP 0
#else
    #error Selected shader preset does not exist!
#endif

// Enable this to check that your texture mods are loaded correctly.
// Bands of colour correspond to material properties:
// Red = Normal maps are present
// Yellow = Parallax maps are present
// Purple = Dark maps are present
// Dark green = Bump maps are present
// Orange = Gloss maps are present
// Blue = Specular maps / PBR parameters are present
// Pink = Emissive maps are present
// Lime = Blend maps are present
#define DEBUG_MATERIALS 0

const float saturation_factor = SATURATION_FACTOR;
const float normal_map_intensity = NORMAL_MAP_INTENSITY;
const float sunlight_strength = SUNLIGHT_STRENGTH;
const float ambiance_strength = AMBIANCE_STRENGTH;
const float interior_strength = INTERIOR_STRENGTH;
const float procedural_detail_level = PROCEDURAL_DETAIL_LEVEL;

#endif
