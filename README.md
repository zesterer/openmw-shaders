# Zesterer's OpenMW Shaders

Play Morrowind with PBR shaders like it's 2022, not 2002.

[![A warrior and a guar](https://i.imgur.com/YoKDhJc.png)](https://i.imgur.com/YoKDhJc.png)
[![Light attenuation in water](https://i.imgur.com/2CvUPkp.png)](https://i.imgur.com/2CvUPkp.png)
[![Night in Balmora](https://i.imgur.com/1XX2RVG.png)](https://i.imgur.com/1XX2RVG.png)
[![The early morning sun reflects off the flagstones of Balmora's canal](https://i.imgur.com/UYHzEDP.png)](https://i.imgur.com/UYHzEDP.png)

## Recommendations

- This mod works well with my [Volumetric Clouds & Mist Mod](https://github.com/zesterer/openmw-volumetric-clouds).
- Use high-resolution textures, normal maps, etc. where possible
- Enable [per-pixel lighting](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#force-per-pixel-lighting)
- Disable [light clamping](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#clamp-lighting)

## Features

- Relatively cheap: should run well on all but the most underpowered hardware
- PBR lighting
- Tweaking lighting
- Underwater light attenuation
- Leaves and other thin objects move in the wind
- Improved leaf and groundcover shading (sub-surface scattering, normal map support, etc.)

## Installing

See [here](https://modding-openmw.com/tips/custom-shaders/#installing) for instructions.

## Configuration

- You can change the `const float saturation = ...` line in `pbr.glsl` to change the appearance of in-game colours

*TODO: More detail*
