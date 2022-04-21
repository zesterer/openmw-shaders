#include "lighting_util.glsl"

const float PI = 3.1415;

float normGgx(float nDotH, float roughness) {
    float r2 = pow(roughness, 2);
    return r2 / (PI * pow(pow(nDotH, 2) * (r2 - 1) + 1, 2));
}

float geomSchlick(float nDotV, float roughness) {
    float k = pow(roughness, 2);
    return nDotV / (nDotV * (1 - k) + k);
}

float fresnelSchlick(float hDotV, float baseRefl) {
    return baseRefl + (1 - baseRefl) * pow(1 - hDotV, 5);
}

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
    float ao
) {
    vec3 viewDir = -camDir;

    vec3 halfVec = normalize(lightDir + viewDir);

    float nDotV = max(dot(surfNorm, viewDir), 0);
    float nDotL = max(dot(surfNorm, lightDir), 0);

    float nDotH = max(dot(surfNorm, halfVec), 0);
    float hDotV = max(dot(halfVec, viewDir), 0);

    vec3 radiance = lightColor * isShadow;
    float lambert = nDotL;

    // Normal Distribution Function (proportion of microfacets aligned with the half vector)
    float ndf = normGgx(nDotH, roughness);
    // Geometry Function (proportion of microfacets not self-shadowed by the surface)
    float gf = geomSchlick(nDotV, roughness) * geomSchlick(nDotL, roughness);
    // Fresnel term
    float f = fresnelSchlick(nDotV, baseRefl); // TODO: Should be hDotV?

    // Cook-Torrance BRDF
    float specular = ndf * gf / (4 * nDotL * nDotV + 0.0001);

    float kDiff = roughness;
    float kSpec = 1 - kDiff;
    kDiff *= 1 - metalness;

    vec3 brdf = kDiff * albedo * ao / PI + kSpec * specular;

    return radiance * lambert * brdf;
}

vec3 getAmbientPbr(
    vec3 surfNorm,
    vec3 camDir,
    // Normalized
    vec3 lightColor,
    vec3 albedo,
    float roughness,
    float refl,
    float metalness,
    float ao
) {
    float reflFactor = ao * refl;
    vec3 reflDir = surfNorm; // TODO: Slerp instead?
    //float dirRefl = pow(dot(reflDir, -camDir) * 0.5 + 0.5, 2 / (1 - roughness)) / (roughness * 2);
    float dirRefl = max(dot(reflDir, -camDir), 0);

    vec3 directLight = lightColor * albedo * reflFactor * dirRefl;

    return directLight;
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
    // Distance from water surface
    float waterDepth
) {
    vec3 camDir = normalize(surfPos);

    vec3 light = vec3(0);

    // Emissive light, eminating from the object itself
    light += emission * 3 * max(dot(surfNorm, -camDir), 0.5);

    // Linear RGB, attenuation coefficients for water at roughly R, G, B wavelengths.
    // See https://en.wikipedia.org/wiki/Electromagnetic_absorption_by_water
    const vec3 MU_WATER = vec3(0.6, 0.04, 0.01);
    const float unitsToMetres = 0.014;
    // Light attenuation in water
    vec3 dayLight = vec3(lcalcDiffuse(0).r) * exp(-MU_WATER * waterDepth * unitsToMetres);

    // Sun
    vec3 sunColor = vec3(1, 0.9, 0.8) * 6 * dayLight;
    vec3 sunDir = normalize(lcalcPosition(0));
    light += getLightPbr(surfNorm, camDir, sunDir, sunColor, albedo, roughness, baseRefl, metalness, sunShadow, ao);

    // Sky (ambient)
    vec3 skyColor = vec3(0.6, 0.8, 1.0) * 1.0 * dayLight;
    //light += getAmbientPbr(surfNorm, camDir, skyColor, albedo, roughness, refl, metalness, ao);
    light += albedo * ao * baseRefl * skyColor * max(dot(surfNorm, -camDir), 0.5);

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
        vec3 lightDir = lightDelta / lightDist;

        //vec3 lightColor = lcalcDiffuse(lightIdx) * 100000 / pow(lightDist, 2);
        vec3 lightColor = lcalcDiffuse(lightIdx) * lcalcIllumination(lightIdx, lightDist) * 5;

        light += getLightPbr(surfNorm, camDir, lightDir, lightColor, albedo, roughness, baseRefl, metalness, 1, ao);
    }

    return light;
}
