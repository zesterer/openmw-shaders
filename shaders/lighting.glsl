#include "pbr.glsl"

float getFresnelSpecular(vec3 viewDir, vec3 viewNormal, vec3 lightDir) {
    const float lift = 0.0;
    return (0.0
        + max((dot(viewDir, reflect(lightDir, viewNormal)) + lift) / (1.0 + lift), .0)
    ) * 1.75;
}

float getFresnelDiffuse(vec3 viewDir, vec3 viewNormal, vec3 lightDir) {
    const float lift = 0.0;
    return (0.0
        + max((dot(-viewDir, viewNormal) + lift) / (1.0 + lift), 0.0)
    ) * 1.75;
}

void perLightSun(out vec3 diffuseOut, out vec3 ambientOut, vec3 viewPos, vec3 viewNormal, float roughness, float shadowing, bool isBack)
{
    vec3 lightDir = normalize(lcalcPosition(0));
    vec3 viewDir = normalize(viewPos);
    viewNormal = normalize(viewNormal);

    float lambert;
    #ifdef GROUNDCOVER
        lambert = dot(viewNormal, lightDir) * shadowing;
    #else
    // Leaves
    if (roughness > 0.5) {
        //viewNormal = viewDir;
        lambert = max(0.0, dot(viewDir, -lightDir) * 0.5 + 0.5) * shadowing;
        #ifdef GROUNDCOVER
            // Hacky
            lambert = (lambert + pow(max(0.0, (dot(viewDir, lightDir) * 0.5 + 0.5)), 3.0) * shadowing * 0.75) * 0.5;
        #endif
        // Sub-surface scattering
        //if (dot(viewNormal, lightDir) < 0 /*isBack*/) { // TODO: Make this work for front faces too!
        //    lambert += pow(max(dot(viewDir, lightDir), 0), 4) * shadowing;
        //}
    } else {
        lambert = dot(viewNormal, lightDir);
    }
    #endif

    float fresnelSpecular = 1.0;
    float fresnelDiffuse = 1.0;

#ifndef GROUNDCOVER
    lambert = max(lambert, 0.0);
    fresnelSpecular = getFresnelSpecular(viewDir, viewNormal, lightDir);
    fresnelDiffuse = getFresnelDiffuse(viewDir, viewNormal, lightDir);
#else
    float eyeCosine = dot(viewDir, viewNormal.xyz);
    if (lambert < 0.0)
    {
        lambert = -lambert;
        eyeCosine = -eyeCosine;
    }
    lambert *= clamp(-8.0 * (1.0 - 0.3) * eyeCosine + 1.0, 0.3, 1.0);
#endif

    const float intensity = 1.0;
    vec3 direct_light = lcalcDiffuse(0).xyz * vec3(2.2, 2.0, 1.6) * intensity;
    vec3 indirect_light = gl_LightModel.ambient.xyz * vec3(0.7, 0.85, 1.1) / intensity;

    diffuseOut = mix(
        mix(fresnelSpecular, 1.0, max(0.35, roughness)) * pow(lambert, 0.5),
        lambert,
    0.5) * direct_light;
//#ifndef GROUNDCOVER // TODO: Make groundcover behave correctly with ambiance
    ambientOut = indirect_light * mix(fresnelDiffuse, 1.0, max(0.0, roughness));
//#endif
}

void perLightPoint(out vec3 diffuseOut, out vec3 ambientOut, int lightIndex, vec3 viewPos, vec3 viewNormal, float roughness)
{
    vec3 lightPos = lcalcPosition(lightIndex) - viewPos;
    float lightDistance = length(lightPos);
    vec3 viewDir = normalize(viewPos);

// cull non-FFP point lighting by radius, light is guaranteed to not fall outside this bound with our cutoff
#if !@lightingMethodFFP
    float radius = lcalcRadius(lightIndex);

    if (lightDistance > radius * 2.0)
    {
        ambientOut = vec3(0.0);
        diffuseOut = vec3(0.0);
        return;
    }
#endif

    lightPos = normalize(lightPos);

    float illumination = lcalcIllumination(lightIndex, lightDistance);
    ambientOut = lcalcAmbient(lightIndex) * illumination;
    float lambert = dot(viewNormal.xyz, lightPos);
    float fresnelSpecular = 1.0;
    float fresnelDiffuse = 1.0;

#ifndef GROUNDCOVER
    lambert = max(lambert, 0.0);
    fresnelSpecular = getFresnelSpecular(viewDir, viewNormal, lightPos);
    fresnelDiffuse = getFresnelDiffuse(viewDir, viewNormal, lightPos);
#else
    float eyeCosine = dot(normalize(viewPos), viewNormal.xyz);
    if (lambert < 0.0)
    {
        lambert = -lambert;
        eyeCosine = -eyeCosine;
    }
    lambert *= clamp(-8.0 * (1.0 - 0.3) * eyeCosine + 1.0, 0.3, 1.0);
#endif

    vec3 directLight = illumination * lcalcDiffuse(lightIndex) * 4.5 / (vec3(1.0) + lcalcDiffuse(0).r * 2.5);
    vec3 indirectLight = directLight * 0.5;

    diffuseOut = mix(
        mix(fresnelSpecular, 1.0, max(0.5, roughness)) * pow(lambert, 0.5),
        lambert,
    0.5) * directLight;
//#ifndef GROUNDCOVER // TODO: Make groundcover behave correctly with ambiance
    ambientOut = indirectLight * gl_LightModel.ambient.xyz * mix(fresnelDiffuse, 1.0, max(0.0, roughness));
//#endif
}

#if PER_PIXEL_LIGHTING
void doLighting(vec3 viewPos, vec3 viewNormal, float shadowing, out vec3 diffuseLight, out vec3 ambientLight, float roughness, bool isBack)
#else
void doLighting(vec3 viewPos, vec3 viewNormal, out vec3 diffuseLight, out vec3 ambientLight, out vec3 shadowDiffuse)
#endif
{
    vec3 ambientOut, diffuseOut;

#if !PER_PIXEL_LIGHTING
    float roughness = 0.0;
    float shadowing = 1.0;
    bool isBack = false;
#endif

    #if SHADOWS
        perLightSun(diffuseOut, ambientOut, viewPos, viewNormal, roughness, shadowing, isBack);
    #endif

#if PER_PIXEL_LIGHTING
    diffuseLight = diffuseOut * mix(shadowing, 1.0, roughness);
    ambientLight = ambientOut;
#else
    shadowDiffuse = diffuseOut * shadowing;
    ambientLight = ambientOut;
    diffuseLight = vec3(0.0);
#endif

    for (int i = @startLight; i < @endLight; ++i)
    {
#if @lightingMethodUBO
        perLightPoint(diffuseOut, ambientOut, PointLightIndex[i], viewPos, viewNormal, roughness);
#else
        perLightPoint(diffuseOut, ambientOut, i, viewPos, viewNormal, roughness);
#endif
        ambientLight += ambientOut;
        diffuseLight += diffuseOut;
    }
}

vec3 getSpecular(vec3 viewNormal, vec3 viewDirection, float shininess, vec3 matSpec)
{
    return vec3(0.0); // TODO: Use specularity
    vec3 lightDir = normalize(lcalcPosition(0));
    float NdotL = dot(viewNormal, lightDir);
    if (NdotL <= 0.0)
        return vec3(0.0);
    vec3 halfVec = normalize(lightDir - viewDirection);
    float NdotH = dot(viewNormal, halfVec);
    return pow(max(NdotH, 0.0), max(1e-4, shininess)) * lcalcSpecular(0).xyz * matSpec;
}
