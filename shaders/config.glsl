// This file contains various configuration parameters for the mod's shaders.
// Ensure that you restart OpenMW after making a change to this file: it will not reload automatically!

// Here is a list of 'presets' you can try to avoid spending ages tweaking values:

// Zesterer's bright & colourful present:
// saturation_factor = 2.5
// normal_map_intensity = 0.5
// sunlight_strength = 1.25
// ambiance_strength = 0.8

// Vanilla but better present:
// saturation_factor = 1.25
// normal_map_intensity = 0.3
// sunlight_strength = 0.8
// ambiance_strength = 1.25

// Change this to alter the saturation of albedo (i.e: base color).
// Recommended values:
// 0.8 => Very desaturated (looks like Vvardenfell is in the UK)
// 1.0 => Desaturated (close to the original vanilla colors of Morrowind)
// 1.5 => Mildly desaturated (most realistic)
// 2.5 => Bright, fun colours (I prefer this)
// 3.5 => Oversaturated (more Alice in Wonderland than Morrowind)
const float saturation_factor = 2.5;

// Normal map mods for Morrowind can often be very extreme and may need toning down.
// Recommended values:
// 0.0 => Normal maps have no effect
// 0.5 => Less intense (smoother surfaces)
// 1.0 => Default
// 2.0 => Very intense (rougher surfaces)
const float normal_map_intensity = 0.5;

// The intensity of direct sunlight
// Recommended values:
// 1.0 => Weak, closer to the original game
// 1.25 => Bright, but not overpowering
// 1.5 => Solar flare, take cover!
const float sunlight_strength = 1.25;

// The intensity of ambient light
// Recommended values:
// 0.5 => Low, like being in space
// 0.75 => Medium, more realistic
// 1.0 => Strong, closer to the original game
// 1.5 => Very strong, very low-contrast shadows
const float ambiance_strength = 0.8;
