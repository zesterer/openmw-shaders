#version 120
#pragma import_defines(FORCE_OPAQUE)

#if @useUBO
    #extension GL_ARB_uniform_buffer_object : require
#endif

#if @useGPUShader4
    #extension GL_EXT_gpu_shader4: require
#endif

#if @diffuseMap
uniform sampler2D diffuseMap;
varying vec2 diffuseMapUV;
#endif

#if @emissiveMap
uniform sampler2D emissiveMap;
varying vec2 emissiveMapUV;
#endif

#if @normalMap
uniform sampler2D normalMap;
varying vec2 normalMapUV;
varying vec4 passTangent;
#endif

varying float euclideanDepth;
varying float linearDepth;

#define PER_PIXEL_LIGHTING 1

varying vec3 passViewPos;
varying vec3 passNormal;

uniform vec2 screenRes;

uniform mat4 osg_ViewMatrixInverse;

#include "vertexcolors.glsl"
#include "shadows_fragment.glsl"
#include "lighting.glsl"
#include "alpha.glsl"
#include "fog.glsl"

uniform float emissiveMult;
uniform float specStrength;

void main()
{
#if @diffuseMap
    gl_FragData[0] = texture2D(diffuseMap, diffuseMapUV);
    gl_FragData[0].a *= coveragePreservingAlphaScale(diffuseMap, diffuseMapUV);
#else
    gl_FragData[0] = vec4(1.0);
#endif

    vec4 diffuseColor = getDiffuseColor();
    gl_FragData[0].a *= diffuseColor.a;
    alphaTest();

#if @normalMap
    vec4 normalTex = texture2D(normalMap, normalMapUV);

    vec3 normalizedNormal = normalize(passNormal);
    vec3 normalizedTangent = normalize(passTangent.xyz);
    vec3 binormal = cross(normalizedTangent, normalizedNormal) * passTangent.w;
    mat3 tbnTranspose = mat3(normalizedTangent, binormal, normalizedNormal);

    vec3 viewNormal = gl_NormalMatrix * normalize(tbnTranspose * (normalTex.xyz * 2.0 - 1.0));
#else
    vec3 viewNormal = gl_NormalMatrix * normalize(passNormal);
#endif

    float shadowing = unshadowedLightRatio(linearDepth);
    /*
    vec3 diffuseLight, ambientLight;
    doLighting(passViewPos, normalize(viewNormal), shadowing, diffuseLight, ambientLight, 0, false);
    vec3 emission = getEmissionColor().xyz * emissiveMult;
    vec3 lighting = diffuseColor.xyz * diffuseLight + getAmbientColor().xyz * ambientLight + emission;
    clampLightingResult(lighting);
    gl_FragData[0].xyz *= lighting;
    */

    vec3 emission = getEmissionColor().xyz * emissiveMult;
#if @emissiveMap
    emission += texture2D(emissiveMap, emissiveMapUV).xyz;
#endif

    vec3 color = gl_FragData[0].rgb;

    vec3 albedo; float ao;
    colorToPbr(color, albedo, ao);

    gl_FragData[0].xyz = getPbr(
        osg_ViewMatrixInverse,
        passViewPos,
        normalize(viewNormal),
        albedo,
        0.65, // roughness
        1.0, // base reflectance
        0.0, // metalness
        shadowing,
        #if SHADOWS
            shadowFadeStart,
        #else
            3500.0,
        #endif
        ao,
        emission * color,
        0.0,
        0.0,
        MAT_DEFAULT
    );

    float shininess = gl_FrontMaterial.shininess;
    vec3 matSpec = getSpecularColor().xyz * specStrength;
#if @normalMap
    matSpec *= normalTex.a;
#endif

    if (matSpec != vec3(0.0))
        gl_FragData[0].xyz += getSpecular(normalize(viewNormal), normalize(passViewPos.xyz), shininess, matSpec) * shadowing;

    gl_FragData[0] = applyFogAtDist(gl_FragData[0], euclideanDepth, linearDepth);

#if defined(FORCE_OPAQUE) && FORCE_OPAQUE
    // having testing & blending isn't enough - we need to write an opaque pixel to be opaque
    gl_FragData[0].a = 1.0;
#endif

    applyShadowDebugOverlay();
}
