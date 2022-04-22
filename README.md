# Zesterer's OpenMW Shaders

Play Morrowind with PBR shaders like it's 2022, not 2002.

## Features

- **Relatively cheap**: in most of my (very unscientific) tests, only a ~12% framerate hit compared to the vanilla OpenMW shaders
- **PBR (Physically-Based Rendering) lighting**: surfaces reflect light consistently and realistically
- **Improved sun light colours**: dawn/dust is red, midday is yellow, night is blue
- **Better ambient illumination**: ambient light is based on omnidirectional scattered light from the sky, not the sun directly
- **Brighter point lights**: lights in the scene emit more light, illuminating the world in a more immersive manner
- **Underwater light attenuation**: objects under the water will shift towards greens and blues with depth, adding realism
- **Leaves and other thin objects move in the wind**: unfortunately, Morrowind has no realiable way to mark leaves so detection is not always perfect
- **Sub-surface scattering**: thin objects (like grass and leaves) will allow particularly bright direct light to scatter through them
- **Easy to configure saturation**: if you prefer realism over bright colours, you can [tweak the shaders](#Configuration) accordingly!

## Screenshots

![Early morning in the grasslands north-east of Vivec](https://i.imgur.com/Vi7RIiM.png)
![Dusk from the cantons of Vivec](https://i.imgur.com/CGpw7mC.png)
![A night with the guars outside Vivec](https://i.imgur.com/eZNMSha.png)
![A mid-afternoon view of Vivec, looking south](https://i.imgur.com/01WujVO.png)
![Vivec's waistworks](https://i.imgur.com/6v5QQf9.png)
![Midnight in Balmora](https://i.imgur.com/cJ94PHK.png)
![Dawn breaks in Balmora](https://i.imgur.com/Ypxz3oj.png)
![Light attenuation in water](https://i.imgur.com/WeZGIGe.png)

## Recommendations

- This mod works well with my [Volumetric Clouds & Mist Mod](https://github.com/zesterer/openmw-volumetric-clouds).
- Use high-resolution textures, normal maps, etc. where possible
- Enable [per-pixel lighting](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#force-per-pixel-lighting)
- Disable [light clamping](https://openmw.readthedocs.io/en/stable/reference/modding/settings/shaders.html#clamp-lighting)

## Installing

See [here](https://modding-openmw.com/tips/custom-shaders/#installing) for instructions.

## Configuration

- You can change the `const float saturation = ...` line in `pbr.glsl` to change the appearance of in-game colours

*TODO: More detail*
