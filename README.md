# Zesterer's OpenMW Shaders

Play Morrowind with PBR shaders like it's 2022, not 2002.

![Early morning in the grasslands north-east of Vivec](https://i.imgur.com/Vi7RIiM.png)
![Dusk from the cantons of Vivec](https://i.imgur.com/CGpw7mC.png)
![A night with the guars outside Vivec](https://i.imgur.com/eZNMSha.png)
![A mid-afternoon view of Vivec, looking south](https://i.imgur.com/01WujVO.png)
![Vivec's waistworks](https://i.imgur.com/6v5QQf9.png)
![Midnight in Balmora](https://i.imgur.com/cJ94PHK.png)
![Dawn breaks in Balmora](https://i.imgur.com/Ypxz3oj.png)

## Recommendations

- This mod works well with my [Volumetric Clouds & Mist Mod](https://github.com/zesterer/openmw-volumetric-clouds).
- Use high-resolution textures, normal maps, etc. where possible
- Enable [per-pixel lighting](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#force-per-pixel-lighting)
- Disable [light clamping](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#clamp-lighting)

## Features

- Relatively cheap: should run well on all but the most underpowered hardware
- PBR direct lighting
- Improved sun light tone
- Better ambient light computation
- Brighter point lights
- Underwater light attenuation
- Leaves and other thin objects move in the wind
- Sub-surface scattering
- Easy to configure saturation (for those that prefer realism)

## Installing

See [here](https://modding-openmw.com/tips/custom-shaders/#installing) for instructions.

## Configuration

- You can change the `const float saturation = ...` line in `pbr.glsl` to change the appearance of in-game colours

*TODO: More detail*
