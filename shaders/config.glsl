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
    // See below for an explanation of each parameter
    #define SATURATION_FACTOR 1.0
    #define NORMAL_MAP_INTENSITY 0.3
    #define SUNLIGHT_STRENGTH 0.8
    #define AMBIANCE_STRENGTH 1.25
#elif (PRESET == VANILLA)
    #define SATURATION_FACTOR 1.0
    #define NORMAL_MAP_INTENSITY 0.3
    #define SUNLIGHT_STRENGTH 0.8
    #define AMBIANCE_STRENGTH 1.25
#elif (PRESET == ZESTERER)
    #define SATURATION_FACTOR 2.0
    #define NORMAL_MAP_INTENSITY 0.5
    #define SUNLIGHT_STRENGTH 1.25
    #define AMBIANCE_STRENGTH 0.8
#elif (PRESET == MGE_XE)
    #define SATURATION_FACTOR 1.5
    #define NORMAL_MAP_INTENSITY 0.25
    #define SUNLIGHT_STRENGTH 0.35
    #define AMBIANCE_STRENGTH 1.5
#else
    #error "Invalid shader preset selected!"
#endif

// Change this to alter the saturation of albedo (i.e: base color).
// Recommended values:
// 0.8 => Very desaturated (looks like Vvardenfell is in the UK)
// 1.0 => Desaturated (close to the original vanilla colors of Morrowind)
// 1.5 => Mildly desaturated (most realistic)
// 2.5 => Bright, fun colours (I prefer this)
// 3.5 => Oversaturated (more Alice in Wonderland than Morrowind)
const float saturation_factor = SATURATION_FACTOR;

// Normal map mods for Morrowind can often be very extreme and may need toning down.
// Recommended values:
// 0.0 => Normal maps have no effect
// 0.5 => Less intense (smoother surfaces)
// 1.0 => Default
// 2.0 => Very intense (rougher surfaces)
const float normal_map_intensity = NORMAL_MAP_INTENSITY;

// The intensity of direct sunlight
// Recommended values:
// 1.0 => Weak, closer to the original game
// 1.25 => Bright, but not overpowering
// 1.5 => Solar flare, take cover!
const float sunlight_strength = SUNLIGHT_STRENGTH;

// The intensity of ambient light
// Recommended values:
// 0.5 => Low, like being in space
// 0.75 => Medium, more realistic
// 1.0 => Strong, closer to the original game
// 1.5 => Very strong, very low-contrast shadows
const float ambiance_strength = AMBIANCE_STRENGTH;

// Extra settings

// Enable procedural detailing on distant terrain, adding detail and depth
// Possible values: 1 (enabled), 0 (disabled)
#define PROCEDURAL_DETAIL 1

#endif
