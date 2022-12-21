# Zesterer's OpenMW Shaders

Play Morrowind with PBR shaders like it's 2022, not 2002.

## Screenshots

![Early morning in Balmora](https://i.imgur.com/1Fa85UT.png)

*Note that these screenshots were taken with additional mods installed, such as [Morrowind Rebirth](https://www.nexusmods.com/morrowind/mods/37795/).*

<details>
    <summary>More screenshots</summary>
    <img src="https://i.imgur.com/2zXznGS.png" alt="An early morning view of Vivec">
    <img src="https://i.imgur.com/4g9iOHa.png" alt="The beaches and tidal pools outside Vivec">
    <img src="https://i.imgur.com/rbRCWZO.png" alt="Lanterns in the night outside Vivec">
    <img src="https://i.imgur.com/EPqGexZ.png" alt="Inside a building in Balmora">
    <img src="https://i.imgur.com/XyPXu0y.png" alt="A tavern in Pelagiad">
    <img src="https://i.imgur.com/GPPWZP1.png" alt="The grasslands outside Vivec on a misty afternoon">
</details>

## Features

- **Efficient**: in my (very unscientific) tests, only a ~12% framerate hit compared to vanilla OpenMW shaders
- **PBR (Physically-Based Rendering) lighting model**: surfaces reflect light consistently and realistically
- **Support for PBR textures (via specular maps)**: PBR texture mods correctly inform surface lighting
- **Improved sun light colours**: dawn and dusk are red, midday is yellow, night is blue
- **Better ambient illumination**: ambient light is omnidirectional scattered light from the sky, not direct sunlight
- **Brighter point lights**: lights in the scene emit more light, illuminating the world in a more immersive manner
- **Underwater light attenuation**: objects under the water shift towards blue with depth, adding realism
- **Underwater caustics**: underwater scenes experience wavy lighting caused by surface refraction
- **Leaves sway in the wind**: unfortunately, Morrowind has no realiable way to mark leaves so detection is imperfect
- **Sub-surface scattering**: thin objects like grass and leaves allow bright direct light to scatter through them
- **Procedural detail for distant land**: terrain in the distance maintains sharp details
- **Wave shader**: Dynamic waves, froth, and backwash on beaches
- **Easy to configure**: if you prefer realism over bright colours, you can [tweak the shaders](#configuration) accordingly!

## Installation

*Ensure that you have the [latest development build](https://openmw.org/downloads/) of OpenMW. If you find that the mod
does not work with the latest development build, please open an issue!*

1. [Download the shader pack](https://github.com/zesterer/openmw-shaders/archive/refs/heads/main.zip).

2. Locate your [`resources/`](https://modding-openmw.com/tips/custom-shaders/#installing) directory.

3. Copy the extracted contents of the shader pack into `resources/` (make sure to back up anything that was in there
before doing this, should something go wrong).

4. Start OpenMW and have fun!

See the [OpenMW Modding Guide](https://modding-openmw.com/tips/custom-shaders/#installing) for more detailed information
about installing custom shader packs.

## Configuration

There are various presets and parameters that can be changed via
[`shaders/config.glsl`](https://github.com/zesterer/openmw-shaders/blob/main/shaders/config.glsl).

## Recommendations

This mod works best with:

- My [Volumetric Clouds & Mist Mod](https://github.com/zesterer/openmw-volumetric-clouds).
- High-resolution textures, normal maps, etc. where possible
- Wazabear's [post-processing shader effects](https://gitlab.com/glassmancody.info/omwfx-shaders/-/tree/main/)
- [Per-pixel lighting](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#force-per-pixel-lighting) enabled
- [Light clamping](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#clamp-lighting) disabled

## Getting Help & Feedback

Got a question or a suggestion? Feel free to [open a discussion topic](https://github.com/zesterer/openmw-shaders/discussions/new).

## License

The code in this repository is derived from the OpenMW vanilla shaders. Accordingly, the code in this repository is similarly licensed under GPL v3.
