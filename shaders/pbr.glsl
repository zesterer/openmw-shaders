#include "lighting_util.glsl"
#include "config.glsl"

const vec3 normal_map_scale = vec3(1.0, 1.0, 1.0 / max(normal_map_intensity, 0.01));

const float PI = 3.1416;
const float INV_PI = 0.31830;

float normGgx(float nDotH, float k) {
    float denom = mix(1.0, k, nDotH * nDotH);
    return k / (PI * denom * denom);
}

float geomSchlick(float nDotV, float k) {
    return nDotV / mix(k, 1.0, nDotV);
}

float fresnelSchlick(float hDotV, float baseRefl) {
    // Faster form of pow(1.0 - hDotV, 4)
    float revHDotV = 1.0 - hDotV;
    revHDotV *= revHDotV;
    return mix(baseRefl, 1.0, revHDotV * revHDotV);
}

const float MAT_DEFAULT = 0.0;
const float MAT_LEAF = 1.0;

vec3 getLightPbr(
    vec3 surfPos,
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
    float shadowFadeStart,
    float subsurface,
    float ao,
    float mat
) {
    vec3 viewDir = -camDir;

    vec3 halfVec = normalize(lightDir + viewDir);

    if (mat > 0.0) {
        surfNorm = viewDir;
    }

    float nDotV = max(dot(surfNorm, viewDir), 0.0);
    float nDotL = max(dot(surfNorm, lightDir), 0.0);

    float nDotH = max(dot(surfNorm, halfVec), 0.0);
    float hDotV = max(dot(halfVec, viewDir), 0.0);
    float glare = dot(-lightDir, viewDir);

    float k = roughness * roughness;
    vec3 radiance = lightColor;
    // How well-aligned the surface is with the incoming light
    float lambert = nDotL;

    // Normal Distribution Function (proportion of microfacets aligned with the half vector)
    float ndf = normGgx(nDotH, k);
    // Geometry Function (proportion of microfacets not self-shadowed by the surface)
    float gf = geomSchlick(nDotV, k) * geomSchlick(nDotL, k);
    // Fresnel term (how close we are to a 'grazing' light ray, which approaches perfect reflection)
    float f = fresnelSchlick(hDotV, baseRefl);
    // Cook-Torrance BRDF, combination of above factors
    float specular = ndf * gf / (4.0 * nDotL * nDotV + 0.0001);

    // Rough surfaces are more diffuse
    float kDiff = roughness;
    // Any light not reflected not diffused by the surface gets reflected specularly
    float kSpec = 1.0 - kDiff;
    // Metals don't emit light diffusely
    kDiff *= 1.0 - metalness;

    // Color of specular reflections is determined by metalness and surface alignment and angle of incidence
    vec3 specular_albedo = mix(vec3(1.0), albedo, metalness);

    // The final diffuse and specular reflectance of the surface
    vec3 brdf = kDiff * albedo * INV_PI + kSpec * specular * specular_albedo;

    // Some surfaces scatter light internally. This models that effect, but non-physically
    float max_scatter_dist_inv = 1.0 / shadowFadeStart;
    float scatter_factor = max(1.0 - length(surfPos) * max_scatter_dist_inv, 0.0);
    vec3 subsurfaceScatter = ((subsurface == 0.0) ? 0.0 : (ao * isShadow * subsurface * pow(max(glare, 0.0), 4.0) * 0.5 * scatter_factor)) * albedo;

    // How occluded is the light by other shadow casters (isShadow), the object itself (ao), or the surface angle?
    float occlusion = isShadow * ao;

    vec3 solidLight = brdf * occlusion;
    vec3 leafLight = mix(solidLight * 0.3, (glare * 0.25 + 0.75) * 0.2 * ao * isShadow * albedo, scatter_factor); // Non-physical

    // Combine reflected light and sub-surface scattering together with the incoming radiance to find the final light
    // reflected/emitted
    return radiance * (mix(solidLight * lambert, leafLight, mat) + subsurfaceScatter);
}

vec3 getSunColor(float sunLightLevel, float isntDusk, float isInterior) {
    const vec3 interiorSunColor = vec3(1.8, 1.6, 1.3);
    return (isInterior == 1.0) ? (interiorSunColor * interior_strength) : (mix(
        mix(
            vec3(0.25, 1.0, 2.0),
            // TODO: Actually detect time of day and make dawn/dusk more red
            vec3(6.0, 5.0, 0.5),
            clamp(sunLightLevel * 10.0 - 3.0, 0.0, 1.0)
        ),
        vec3(8.0, 7.0, 6.0),
        isntDusk
    ) * sunlight_strength);
}

vec3 getAmbientColor(float isntDusk, float isInterior) {
    const vec3 interiorAmbientColor = vec3(0.3, 0.25, 0.2);
    return (isInterior == 1.0) ? (interiorAmbientColor * interior_strength) : (mix(
        vec3(0.15, 0.2, 0.4),
        vec3(1.2, 1.5, 2.5),
        isntDusk
    ) * ambiance_strength);
}

vec3 getPbr(
    mat4 osg_ViewMatrixInverse,
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
    float shadowFadeStart,
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

    // Emissive light, eminating from the object itself (non-physical)
    light += emission * 3.0 * max(dot(surfNorm, -camDir), 0.5);

    vec3 sunPos = lcalcPosition(0);
    vec3 sunDir = normalize(sunPos);
    float sunLightLevel = lcalcDiffuse(0).r;
    // If this seems silly, that's because it is. We use this to approximate how close we are to dusk
    // pow(sunLightLevel, 4)
    vec3 sunWDir = (osg_ViewMatrixInverse * vec4(sunDir, 0.0)).xyz;
    float isntDusk = clamp(lcalcDiffuse(0).r * 2.0 - 0.25, 0.0, 1.0);

    // Extremely silly hack to determine whether we're indoors or not
    float isInterior = step(0.9, dot(sunWDir, vec3(0.0, 0.0, 1.0))) * step(lcalcDiffuse(0).b, 0.2);

    // Linear RGB, attenuation coefficients for water at roughly R, G, B wavelengths.
    // See https://en.wikipedia.org/wiki/Electromagnetic_absorption_by_water
    const vec3 MU_WATER = vec3(0.6, 0.04, 0.01);
    const float unitsToMetres = 0.014;
    // Light attenuation in water
    vec3 attenuation = (waterDepth == 0.0 || isInterior == 1.0) ? vec3(1.0) : exp(-MU_WATER * waterDepth * unitsToMetres);

    // Direct sunlight
    vec3 sunColor = getSunColor(sunLightLevel, isntDusk, isInterior) /* * lcalcDiffuse(0)*/ * attenuation;
    light += getLightPbr(surfPos, surfNorm, camDir, sunDir, sunColor, albedo, roughness, baseRefl, metalness, sunShadow, shadowFadeStart, subsurface, ao, mat);

    // Sky (ambient)
    // TODO: Better ambiance
    float ambientFresnel = mix(max(dot(surfNorm, -camDir), 0.0) * 0.5 + 0.5, 1.0, subsurface);
    vec3 skyColor = getAmbientColor(isntDusk, isInterior) /* * lcalcDiffuse(0)*/ * attenuation;
    // Even ambient light has some directionality, favouring surfaces facing toward the sky. Account for that.
    float ambientDirectionalBias = (max(dot(surfNorm, sunDir), 0.0) * 0.5 + 0.5) * 1.5;
    light += albedo * ao * baseRefl * skyColor * ambientFresnel * ambientDirectionalBias;

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
            * lcalcIllumination(lightIdx, lightDist) * 20.0
            // Make lights less powerful during the day (otherwise, they're a bit overpowering)
            * max(1.0 - sunLightLevel, 0.5)
            // Final cap to make sure that lights don't abruptly cut off beyond the maximum light distance
            * min((1.0 - lightDist / lightMaxRadius) * 3.0, 1.0);

        light += getLightPbr(surfPos, surfNorm, camDir, lightDir, lightColor, albedo, roughness, baseRefl, metalness, 1.0, 1.0, subsurface, ao, mat);
    }

    return light;
}

void untonemap(inout vec3 color) {
    const float k = 1.5;
    color = -log2(1.0 - color);
    color = vec3(1.0) - exp2(color * -k);
}

// We need to derive PBR inputs from Morrowind's extremely ad-hoc, non-PBR textures.
// As a result, this entire thing is an enormous hack that lets us do that!
void colorToPbr(vec3 color, out vec3 albedo, out float ao) {
    untonemap(color);
    ao = min(length(color) * 0.58, 1.0);
    float saturation = mix(1.0, saturation_factor, ao);
    albedo = clamp(pow(normalize(color), vec3(saturation)) * mix(saturation, 1.5, 0.5) - 0.25, vec3(0.0), vec3(1.0));
}

// Derive PBR parameters from coloured specular, if possible. If not, old values will be used.
void matSpecToPbr(vec3 specMat, inout float roughness, inout float reflectance, inout float metalness) {
    // The only thing we can do is to look at the magnitude of the specular element and use that as 1 - roughness
    roughness = mix(0.8, 0.5, length(specMat) * 0.58);
}
