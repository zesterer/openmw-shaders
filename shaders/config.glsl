#ifndef CONFIG_GLSL
#define CONFIG_GLSL

// This file contains various configuration parameters for the mod's shaders.
// Ensure that you restart OpenMW after making a change to this file: it will not reload automatically!

// Here is a list of lighting 'presets' you can try to avoid spending ages tweaking values:
#define CUSTOM 0 // You can use this present to customise things as you like
#define VANILLA 1 // Designed to emulate the feel of vanilla Morrowind
#define ZESTERER 2 // Colorful and intense fantasy lighting
#define MGE_XE 3 // An attempt at emulating the soft lighting of MGE XE

// Change this value to quickly switch presets
#define PRESET ZESTERER

#if (PRESET == CUSTOM)
    // Change these values to edit your custom preset
    // Each value comes with an explanation, and recommended values.

    // Change this to alter the saturation of albedo (i.e: base color).
    // Recommended values:
    // 0.8 => Very desaturated (looks like Vvardenfell is in the UK)
    // 1.0 => Desaturated (close to the original vanilla colors of Morrowind)
    // 1.5 => Mildly desaturated (most realistic)
    // 2.5 => Bright, fun colours (I prefer this)
    // 3.5 => Oversaturated (more Alice in Wonderland than Morrowind)
    #define SATURATION_FACTOR 1.0

    // Normal map mods for Morrowind can often be very extreme and may need toning down.
    // Recommended values:
    // 0.0 => Normal maps have no effect
    // 0.5 => Less intense (smoother surfaces)
    // 1.0 => Default
    // 2.0 => Very intense (rougher surfaces)
    #define NORMAL_MAP_INTENSITY 0.3

    // The intensity of direct sunlight
    // Recommended values:
    // 1.0 => Weak, closer to the original game
    // 1.25 => Bright, but not overpowering
    // 1.5 => Solar flare, take cover!
    #define SUNLIGHT_STRENGTH 0.8

    // The intensity of ambient light
    // Recommended values:
    // 0.5 => Low, like being in space
    // 0.75 => Medium, more realistic
    // 1.0 => Strong, closer to the original game
    // 1.5 => Very strong, very low-contrast shadows
    #define AMBIANCE_STRENGTH 1.25

    // The intensity of interior light (applies for buildings and underground spaces)
    // Recommended values:
    // 0.5 => Low, very dark interiors
    // 0.75 => Medium, dingy interiors
    // 1.0 => Normal, well-lit interiors
    // 1.5 => Bright, very well-lit interiors
    #define INTERIOR_STRENGTH 1.0

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
    #define WAVE_HEIGHT 6.0

    // As-yet undocumented settings
    #define TINT 0.5
    #define HUE_SHIFT 0.0
    #define CAUSTICS 1
#elif (PRESET == VANILLA)
    #define SATURATION_FACTOR 1.2
    #define NORMAL_MAP_INTENSITY 0.3
    #define SUNLIGHT_STRENGTH 0.25
    #define AMBIANCE_STRENGTH 0.4
    #define INTERIOR_STRENGTH 0.6
    #define PROCEDURAL_DETAIL_LEVEL 0.5
    #define WIND_AMPLITUDE 0.2
    #define WAVES 1
    #define WAVE_HEIGHT 6.0
    #define TINT 0.0
    #define HUE_SHIFT 0.0
    #define CAUSTICS 1
#elif (PRESET == ZESTERER)
    #define SATURATION_FACTOR 1.65
    #define NORMAL_MAP_INTENSITY 0.75
    #define SUNLIGHT_STRENGTH 0.6
    #define AMBIANCE_STRENGTH 0.5
    #define INTERIOR_STRENGTH 0.5
    #define PROCEDURAL_DETAIL_LEVEL 1.0
    #define WIND_AMPLITUDE 0.75
    #define WAVES 1
    #define WAVE_HEIGHT 8.0
    #define TINT 1.0
    #define HUE_SHIFT -0.015
    #define CAUSTICS 1
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
    #define TINT 0.5
    #define HUE_SHIFT -0.015
    #define CAUSTICS 1
#else
    #error Selected shader preset does not exist!
#endif

const float saturation_factor = SATURATION_FACTOR;
const float normal_map_intensity = NORMAL_MAP_INTENSITY;
const float sunlight_strength = SUNLIGHT_STRENGTH;
const float ambiance_strength = AMBIANCE_STRENGTH;
const float interior_strength = INTERIOR_STRENGTH;
const float procedural_detail_level = PROCEDURAL_DETAIL_LEVEL;

#endif
