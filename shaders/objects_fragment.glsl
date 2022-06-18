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

#if @darkMap
uniform sampler2D darkMap;
varying vec2 darkMapUV;
#endif

#if @detailMap
uniform sampler2D detailMap;
varying vec2 detailMapUV;
#endif

#if @decalMap
uniform sampler2D decalMap;
varying vec2 decalMapUV;
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

#if @envMap
uniform sampler2D envMap;
varying vec2 envMapUV;
uniform vec4 envMapColor;
#endif

#if @specularMap
uniform sampler2D specularMap;
varying vec2 specularMapUV;
#endif

#if @bumpMap
uniform sampler2D bumpMap;
varying vec2 bumpMapUV;
uniform vec2 envMapLumaBias;
uniform mat2 bumpMapMatrix;
#endif

#if @glossMap
uniform sampler2D glossMap;
varying vec2 glossMapUV;
#endif

uniform vec2 screenRes;
varying float leafiness;
varying vec4 modelPos;

#define PER_PIXEL_LIGHTING (@normalMap || @forcePPL)

#if !PER_PIXEL_LIGHTING
centroid varying vec3 passLighting;
centroid varying vec3 shadowDiffuseLighting;
#else
uniform float emissiveMult;
#endif
uniform float specStrength;
varying vec3 passViewPos;
varying vec3 passNormal;

uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ViewMatrix;
uniform mat4 osg_ModelViewMatrix;

uniform mat4 projectionMatrix;

#include "vertexcolors.glsl"
#include "shadows_fragment.glsl"
#include "lighting.glsl"
#include "parallax.glsl"
#include "alpha.glsl"
#include "fog.glsl"

#if @softParticles
#include "softparticles.glsl"
#endif

void main()
{
#if @diffuseMap
    vec2 adjustedDiffuseUV = diffuseMapUV;
#endif

#if @normalMap
    vec4 normalTex = texture2D(normalMap, normalMapUV);

    vec3 normalizedNormal = normalize(passNormal);
    vec3 normalizedTangent = normalize(passTangent.xyz);
    vec3 binormal = cross(normalizedTangent, normalizedNormal) * passTangent.w;
    mat3 tbnTranspose = mat3(normalizedTangent, binormal, normalizedNormal);

    vec3 viewNormal = gl_NormalMatrix * normalize(tbnTranspose * normalize((normalTex.xyz * 2.0 - 1.0) * normal_map_scale));
#endif

#if (!@normalMap && (@parallax || @forcePPL))
    vec3 viewNormal = gl_NormalMatrix * normalize(passNormal);
#endif

#if @parallax
    vec3 cameraPos = (gl_ModelViewMatrixInverse * vec4(0,0,0,1)).xyz;
    vec3 objectPos = (gl_ModelViewMatrixInverse * vec4(passViewPos, 1)).xyz;
    vec3 eyeDir = normalize(cameraPos - objectPos);
    vec2 offset = getParallaxOffset(eyeDir, tbnTranspose, normalTex.a, (passTangent.w > 0.0) ? -1.f : 1.f);
    adjustedDiffuseUV += offset; // only offset diffuse for now, other textures are more likely to be using a completely different UV set

    // TODO: check not working as the same UV buffer is being bound to different targets
    // if diffuseMapUV == normalMapUV
#if 1
    // fetch a new normal using updated coordinates
    normalTex = texture2D(normalMap, adjustedDiffuseUV);
    viewNormal = gl_NormalMatrix * normalize(tbnTranspose * (normalTex.xyz * 2.0 - 1.0));
#endif

#endif

#if @diffuseMap
    gl_FragData[0] = texture2D(diffuseMap, adjustedDiffuseUV);
    gl_FragData[0].a *= coveragePreservingAlphaScale(diffuseMap, adjustedDiffuseUV);
#else
    gl_FragData[0] = vec4(1.0);
#endif

    vec4 diffuseColor = getDiffuseColor();
    gl_FragData[0].a *= diffuseColor.a;

    vec3 wPos = (osg_ViewMatrixInverse * vec4(passViewPos, 1)).xyz;
    bool inMinimap = projectionMatrix[0][3] == 0.0 && projectionMatrix[1][3] == 0.0 && projectionMatrix[2][3] == 0.0;
    float waterDepth = inMinimap ? 0.0 : max(-wPos.z, 0);

#if @darkMap
    gl_FragData[0].a *= coveragePreservingAlphaScale(darkMap, darkMapUV);
#endif

    alphaTest();

#if @detailMap
    gl_FragData[0].xyz *= texture2D(detailMap, detailMapUV).xyz * 2.0;
#endif

#if @decalMap
    vec4 decalTex = texture2D(decalMap, decalMapUV);
    gl_FragData[0].xyz = mix(gl_FragData[0].xyz, decalTex.xyz, decalTex.a * diffuseColor.a);
#endif

#if @envMap

    vec2 envTexCoordGen = envMapUV;
    float envLuma = 1.0;

#if @normalMap
    // if using normal map + env map, take advantage of per-pixel normals for envTexCoordGen
    vec3 viewVec = normalize(passViewPos.xyz);
    vec3 r = reflect( viewVec, viewNormal );
    float m = 2.0 * sqrt( r.x*r.x + r.y*r.y + (r.z+1.0)*(r.z+1.0) );
    envTexCoordGen = vec2(r.x/m + 0.5, r.y/m + 0.5);
#endif

#if @bumpMap
    vec4 bumpTex = texture2D(bumpMap, bumpMapUV);
    envTexCoordGen += bumpTex.rg * bumpMapMatrix;
    envLuma = clamp(bumpTex.b * envMapLumaBias.x + envMapLumaBias.y, 0.0, 1.0);
#endif

    vec3 envEffect = texture2D(envMap, envTexCoordGen).xyz * envMapColor.xyz * envLuma;

#if @glossMap
    envEffect *= texture2D(glossMap, glossMapUV).xyz;
#endif

#if @preLightEnv
    gl_FragData[0].xyz += envEffect;
#endif
#else
    vec3 envEffect = vec3(0);
#endif

    float roughness = 0.6;
    float reflectance = 1.0;
    float metalness = 0.0;

    float shininess = clamp(gl_FrontMaterial.shininess * 0.0039, 0.0, 1.0);

#if @specularMap
    vec4 specTex = texture2D(specularMap, specularMapUV);
    vec3 matSpec = specTex.xyz;
    matSpecToPbr(matSpec, roughness, metalness, reflectance);
    roughness *= mix(1.0, 0.3, shininess * specTex.a);
#else
    vec3 matSpec = getSpecularColor().xyz;
    matSpecToPbr(matSpec, roughness, metalness, reflectance);
    //shininess = min(shininess * 20.0, 1.0); // Why the hell is this necessary?!
    roughness *= mix(0.9, 0.1, shininess);
    metalness *= mix(0.0, 0.75, shininess);
#endif

    float shadowing = unshadowedLightRatio(passViewPos.z);
    vec3 lighting;
#if !PER_PIXEL_LIGHTING
    lighting = passLighting + shadowDiffuseLighting * shadowing;
    #if @darkMap
        lighting *= texture2D(darkMap, darkMapUV).rgb;
    #endif
    gl_FragData[0].xyz *= lighting;
#else
    vec3 emission = getEmissionColor().rgb * emissiveMult;
    #if @emissiveMap
        emission += texture2D(emissiveMap, emissiveMapUV).rgb;
    #endif

    #if @darkMap
        emission *= texture2D(darkMap, darkMapUV).rgb;
    #endif

    vec3 color = gl_FragData[0].rgb * diffuseColor.rgb;

    vec3 albedo; float ao;
    colorToPbr(color, albedo, ao);

    gl_FragData[0].xyz = getPbr(
        osg_ViewMatrixInverse,
        passViewPos,
        normalize(viewNormal),
        albedo,
        roughness,
        reflectance,
        metalness,
        shadowing,
        #if SHADOWS
            shadowFadeStart,
        #else
            3500.0,
        #endif
        ao,
        emission * color,
        leafiness,
        waterDepth,
        leafiness
    );
#endif

#if @envMap && !@preLightEnv
    gl_FragData[0].xyz += envEffect;
#endif

    clampLightingResult(gl_FragData[0].xyz);

    gl_FragData[0] = applyFogAtPos(gl_FragData[0], passViewPos);

#if !defined(FORCE_OPAQUE) && @softParticles
    gl_FragData[0].a *= calcSoftParticleFade();
#endif

#if defined(FORCE_OPAQUE) && FORCE_OPAQUE
    // having testing & blending isn't enough - we need to write an opaque pixel to be opaque
    gl_FragData[0].a = 1.0;
#endif

    applyShadowDebugOverlay();
}
