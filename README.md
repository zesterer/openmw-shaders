# Zesterer's OpenMW Shader Pack

Play Morrowind with beautiful shaders like it's 2022, not 2002.

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

## Status

Sadly, core shaders for OpenMW are a hack, with no compatibility guarantees. That means that almost every OpenMW release results in the shaders breaking
in some manner. I don't find myself with enough time in my life to keep the shaders up to date with these changes. Occasionally some kind soul sends me a
patch that updates them, but no guarantees are provided about these shaders work with the current version of OpenMW.

I've noticed that several people have confused this mod with my [Volumetric Clouds & Mist Mod](https://github.com/zesterer/openmw-volumetric-clouds).
The latter is a properly supported mod, and should continue to work with OpenMW for the forseeable future.

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

## Installation Guide

1. [Download the shader pack](#download).

2. Locate your [`resources/`](https://modding-openmw.com/tips/custom-shaders/#installing) directory.

3. Copy the extracted shader pack into `resources/` (make sure to back up anything that was in there
before doing this, should something go wrong). This should result in the following directory structure:

```
resources/
  |-- shaders/
  |    |-- compatibility/
  |    |-- core/
  |    |-- lib/
  '-- README.md
```

4. Enable required settings

- Enable [per-pixel lighting](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#force-per-pixel-lighting)
- Disable [light clamping](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#clamp-lighting)
- Set [lighting method](https://openmw.readthedocs.io/en/latest/reference/modding/settings/shaders.html#lighting-method) to 'shaders'

5. Start OpenMW and have fun!

See the [OpenMW Modding Guide](https://modding-openmw.com/tips/custom-shaders/#installing) for more detailed information
about installing custom shader packs.

## Download

This shader pack currently supports both [development builds]((https://openmw.org/downloads/)) of OpenMW and OpenMW
0.48 (still in pre-release). I recommend using a development build of OpenMW if you can to get access to all of the
latest funky features of both OpenMW and this shader pack.

- [For OpenMW Development](https://github.com/zesterer/openmw-shaders/archive/refs/heads/main.zip)

- [For OpenMW 0.48](https://github.com/zesterer/openmw-shaders/archive/refs/heads/openmw-0.48.zip)

## Configuration

There are various presets and parameters that can be changed via
[`shaders/lib/zesterer/config.glsl`](https://github.com/zesterer/openmw-shaders/blob/main/shaders/lib/zesterer/config.glsl).

## Recommendations

This mod works best with:

- My [Volumetric Clouds & Mist Mod](https://github.com/zesterer/openmw-volumetric-clouds).
- High-resolution textures, normal maps, etc. where possible
- Wazabear's [post-processing shader effects](https://gitlab.com/glassmancody.info/omwfx-shaders/-/tree/main/)
- Enabled [per-pixel lighting](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#force-per-pixel-lighting)
- Disabled [light clamping](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#clamp-lighting)
- Enabled [sky blending](https://openmw.readthedocs.io/en/latest/reference/modding/settings/fog.html#sky-blending)

## Known Issues

- Morrowind's assets don't differentiate between 'leaves' and 'not leaves'. As a result, the shaders use a primitive
  heuristic to determine what is and is not a leaf for the wind sway effect. This can sometimes cause some objects that
  are not leaves (candle flames, banners, baskets, etc.) to exhibit strange swaying behaviour too. If this is too
  distracting for you, you can disable wind sway by setting `WIND_AMPLITUDE` to `0.0` in
  [`shaders/config.glsl`](https://github.com/zesterer/openmw-shaders/blob/main/shaders/config.glsl).

- On the version of the mod for OpenMW 0.48, objects reflected in water can have incorrect tinting applied to them. This
  is fixed in the version of the mod for OpenMW development builds.

## Getting Help & Feedback

Got a question or a suggestion? Feel free to [open a discussion topic](https://github.com/zesterer/openmw-shaders/discussions/new).

Please note that I'm not responsible for whatever happens if you use this mod. Pretty much all settings in `config.glsl`
are safe to play around with, but if you somehow manage to make your graphics card explode by plugging in stupid
numbers, that's on you.

## License

The code in this repository is derived from the OpenMW vanilla shaders. Accordingly, the code in this repository is similarly licensed under GPL v3.
