#include "lighting_util.glsl"

uniform mat4 osg_ViewMatrix;

const float PI = 3.1416;
const float INV_PI = 0.31830;

float normGgx(float nDotH, float k) {
    float denom = nDotH * nDotH * (k - 1.0) + 1.0;
    return k / (PI * denom * denom);
}

float geomSchlick(float nDotV, float k) {
    return nDotV / (nDotV * (1.0 - k) + k);
}

float fresnelSchlick(float hDotV, float baseRefl) {
    return baseRefl + (1.0 - baseRefl) * pow(1.0 - hDotV, 5.0);
}

const float MAT_DEFAULT = 0.0;
const float MAT_LEAF = 1.0;

vec3 getLightPbr(
    vec3 surfNorm,
    vec3 camDir,
    // Normalized
    vec3 lightDir,
    // ~ 1 / distance^2
    vec3 lightColor,
    vec3 albedo,
    float roughness,
    float baseRefl,
    float metalness,
    // 1 if in light, 0 if not in light
    float isShadow,
    float subsurface,
    float ao,
    float mat
) {
    vec3 viewDir = -camDir;

    vec3 halfVec = normalize(lightDir + viewDir);

    float nDotV = max(dot(surfNorm, viewDir), 0.0);
    float nDotL = max(dot(surfNorm, lightDir), 0.0);

    float nDotH = max(dot(surfNorm, halfVec), 0.0);
    float hDotV = max(dot(halfVec, viewDir), 0.0);
    float glare = dot(-lightDir, viewDir);

    float k = roughness * roughness;
    vec3 radiance = lightColor;
    float lambert = nDotL;

    // Normal Distribution Function (proportion of microfacets aligned with the half vector)
    float ndf = normGgx(nDotH, k);
    // Geometry Function (proportion of microfacets not self-shadowed by the surface)
    float gf = geomSchlick(nDotV, k) * geomSchlick(nDotL, k);
    // Fresnel term
    float f = fresnelSchlick(hDotV, baseRefl);

    // Cook-Torrance BRDF
    float specular = ndf * gf / (4.0 * nDotL * nDotV + 0.0001);

    float kDiff = roughness;
    float kSpec = 1.0 - kDiff;
    kDiff *= 1.0 - metalness;

    vec3 brdf = kDiff * albedo * INV_PI + kSpec * specular;

    float subsurfaceScatter = subsurface * pow(max(glare, 0.0), 6.0) * isShadow * 0.05;

    float occlusion = min(ao, isShadow) * lambert;

    vec3 solidLight = brdf * occlusion;
    vec3 leafLight = (glare * 0.25 + 0.75) * albedo * ao * isShadow * 0.2;

    return radiance * (mix(solidLight, leafLight, mat) + subsurfaceScatter);
}

vec3 getSunColor(float dayLight, float isInterior) {
    return mix(
        mix(
            mix(
                vec3(1.0, 1.5, 2.0),
                vec3(8.0, 3.0, 0.3),
                clamp((dayLight - 0.3) * 10.0, 0.0, 1.0)
            ),
            vec3(6.0, 5.4, 4.8),
            pow(dayLight, 4.0)
        ),
        vec3(1.0, 0.85, 0.6) * 3.0,
        isInterior
    );
}

vec3 getAmbientColor(float dayLight, float isInterior) {
    return mix(
        mix(
            vec3(0.2, 0.25, 0.5),
            vec3(0.45, 0.6, 1.0),
            pow(dayLight, 4.0)
        ),
        vec3(1.0, 0.8, 0.5) * 0.25,
        isInterior
    );
}

vec3 getPbr(
    vec3 surfPos,
    vec3 surfNorm,
    // Base reflectance of the material
    vec3 albedo,
    // Rate of perfect vs diffuse reflection
    float roughness,
    // Proportion of light that is reflected from the surface
    float baseRefl,
    float metalness,
    // From shadow map, for sun
    float sunShadow,
    // Reduction in reflected light due to occlusion
    float ao,
    // Diffuse emission
    vec3 emission,
    // Sub-surface scattering factor
    float subsurface,
    // Distance from water surface
    float waterDepth,
    // Leafiness?!
    float mat
) {
    vec3 camDir = normalize(surfPos);

    vec3 light = vec3(0.0);

    // Emissive light, eminating from the object itself
    light += emission * 3.0 * max(dot(surfNorm, -camDir), 0.5);

    float sunLightLevel = lcalcDiffuse(0).r;

    // Extremely silly hack to determine whether we're indoors or not
    float isInterior = step(0.999, dot((osg_ViewMatrix * vec4(0.0, 0.0, 1.0, 0.0)).xyz, lcalcPosition(0)));

    // Linear RGB, attenuation coefficients for water at roughly R, G, B wavelengths.
    // See https://en.wikipedia.org/wiki/Electromagnetic_absorption_by_water
    const vec3 MU_WATER = vec3(0.6, 0.04, 0.01);
    const float unitsToMetres = 0.014;
    // Light attenuation in water
    vec3 attenuation = mix(exp(-MU_WATER * waterDepth * unitsToMetres), vec3(1), isInterior);

    // Sun
    vec3 sunDir = normalize(lcalcPosition(0));
    vec3 sunColor = getSunColor(sunLightLevel, isInterior) * attenuation;
    light += getLightPbr(surfNorm, camDir, sunDir, sunColor, albedo, roughness, baseRefl, metalness, sunShadow, subsurface, ao, mat);

    // Sky (ambient)
    // TODO: Better ambiance
    float ambientFresnel = mix(1.0, max(dot(surfNorm, -camDir), 0.0) * 0.5 + 0.5, 1.0 - mat);
    vec3 skyColor = getAmbientColor(sunLightLevel, isInterior) * attenuation;
    light += albedo * ao * baseRefl * skyColor * ambientFresnel;

    for (int i = @startLight; i < @endLight; ++i) {
        int lightIdx =
        #if @lightingMethodUBO
                PointLightIndex[i]
        #else
                i
        #endif
        ;

        vec3 lightDelta = lcalcPosition(lightIdx) - surfPos;
        float lightDist = length(lightDelta);
        float lightMaxRadius = lcalcRadius(lightIdx) * 3.0;

        // Skip this light if it's too far away
        if (lightDist > lightMaxRadius) { continue; }

        vec3 lightDir = lightDelta / lightDist;

        vec3 lightColor = lcalcDiffuse(lightIdx)
            // The strength of a light reduces with distance
            * lcalcIllumination(lightIdx, lightDist) * 10.0
            // Make lights less powerful during the day (otherwise, they're a bit overpowering)
            * (1.0 - sunLightLevel)
            // Final cap to make sure that lights don't abruptly cut off beyond the maximum light distance
            * min((1 - lightDist / lightMaxRadius) * 3, 1);

        light += getLightPbr(surfNorm, camDir, lightDir, lightColor, albedo, roughness, baseRefl, metalness, 1.0, subsurface, ao, mat);
    }

    return light;
}

// We need to derive PBR inputs from Morrowind's extremely ad-hoc, non-PBR textures.
// As a result, this entire thing is an enormous hack that lets us do that!
void colorToPbr(vec3 color, out vec3 albedo, out float ao) {
    // Change this to alter the saturation of albedo. Recommended values
    // 0.8 => Very desaturated (looks like Morrowind is in the UK)
    // 1.0 => Mildly desaturated (most realistic)
    // 1.5 => Bright, fun colours (I prefer this one)
    // 2.0 => Oh my god, my eyes
    const float saturation = 1.5;
    albedo = clamp(pow(normalize(color), vec3(saturation)) * mix(saturation, 1.5, 0.5) - 0.25, vec3(0.0), vec3(1.0));
    ao = min(length(color), 1.0);
}
