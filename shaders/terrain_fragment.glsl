#version 130

#if @useUBO
    #extension GL_ARB_uniform_buffer_object : require
#endif

#if @useGPUShader4
    #extension GL_EXT_gpu_shader4: require
#endif

varying vec2 uv;

uniform sampler2D diffuseMap;

#if @normalMap
uniform sampler2D normalMap;
#endif

#if @blendMap
uniform sampler2D blendMap;
#endif

varying float euclideanDepth;
varying float linearDepth;

uniform mat4 osg_ViewMatrixInverse;

#define PER_PIXEL_LIGHTING (@normalMap || @forcePPL)

#if !PER_PIXEL_LIGHTING
centroid varying vec3 passLighting;
centroid varying vec3 shadowDiffuseLighting;
#endif
varying vec3 passViewPos;
varying vec3 passNormal;

#include "vertexcolors.glsl"
#include "shadows_fragment.glsl"
#include "lighting.glsl"
#include "parallax.glsl"
#include "rand.glsl"

void main()
{
    vec2 adjustedUV = (gl_TextureMatrix[0] * vec4(uv, 0.0, 1.0)).xy;

#if @normalMap
    vec4 normalTex = texture2D(normalMap, adjustedUV);

    vec3 normalizedNormal = normalize(passNormal);
    vec3 tangent = vec3(1.0, 0.0, 0.0);
    vec3 binormal = normalize(cross(tangent, normalizedNormal));
    tangent = normalize(cross(normalizedNormal, binormal)); // note, now we need to re-cross to derive tangent again because it wasn't orthonormal
    mat3 tbnTranspose = mat3(tangent, binormal, normalizedNormal);

    vec3 viewNormal = normalize(gl_NormalMatrix * (tbnTranspose * normalize((normalTex.xyz * 2.0 - 1.0) * normal_map_scale)));
#endif

#if (!@normalMap && (@parallax || @forcePPL))
    vec3 viewNormal = gl_NormalMatrix * normalize(passNormal);
#endif

#if @parallax
    vec3 cameraPos = (gl_ModelViewMatrixInverse * vec4(0,0,0,1)).xyz;
    vec3 objectPos = (gl_ModelViewMatrixInverse * vec4(passViewPos, 1)).xyz;
    vec3 eyeDir = normalize(cameraPos - objectPos);
    adjustedUV += getParallaxOffset(eyeDir, tbnTranspose, normalTex.a, 1.f);

    // update normal using new coordinates
    normalTex = texture2D(normalMap, adjustedUV);
    viewNormal = normalize(gl_NormalMatrix * (tbnTranspose * normalize((normalTex.xyz * 2.0 - 1.0) * normal_map_scale)));
#endif

    vec3 wPos = (osg_ViewMatrixInverse * vec4(passViewPos, 1)).xyz;
    vec3 wPosModel = (gl_ModelViewMatrixInverse * vec4(passViewPos, 1)).xyz;
    float waterDepth = max(-wPosModel.z, 0);

    if (PROCEDURAL_DETAIL_LEVEL > 0.0) {
        //proceduralUV(wPos, length(passViewPos), adjustedUV);
    }

    vec4 diffuseTex = texture2D(diffuseMap, adjustedUV);//textureBicubic(diffuseMap, adjustedUV);
    gl_FragData[0] = vec4(diffuseTex.xyz, 1.0);

#if @blendMap
    vec2 blendMapUV = (gl_TextureMatrix[1] * vec4(uv, 0.0, 1.0)).xy;
    gl_FragData[0].a *= texture2D(blendMap, blendMapUV).a;
#endif

    vec4 diffuseColor = getDiffuseColor();
    gl_FragData[0].a *= diffuseColor.a;

    float roughness = 0.5;
    float reflectance = 1.0;
    float metalness = 0.0;

    float shininess = clamp(gl_FrontMaterial.shininess * 0.0039 * 30, 0.0, 1.0);

#if @specularMap
    vec3 matSpec = vec3(diffuseTex.a);
    matSpecToPbr(matSpec, roughness, metalness, reflectance);
    roughness *= mix(1.0, 0.3, shininess * specTex.a);
#else
    vec3 matSpec = getSpecularColor().xyz;
    matSpecToPbr(matSpec, roughness, metalness, reflectance);
    roughness *= 0.75;
    shininess = min(shininess * 20.0, 1.0); // Why the hell is this necessary?!
    roughness *= mix(0.9, 0.1, shininess);
    metalness *= mix(0.0, 0.75, shininess);
#endif

    float shadowing = unshadowedLightRatio(linearDepth);
    vec3 lighting;
#if !PER_PIXEL_LIGHTING
    lighting = passLighting + shadowDiffuseLighting * shadowing;
    gl_FragData[0].xyz *= lighting;
#else
    vec3 color = gl_FragData[0].rgb * mix(vec3(1.0), diffuseColor.rgb, noise(wPos.xy * 0.005));

    vec3 albedo; float ao;
    colorToPbr(color, albedo, ao);

    if (PROCEDURAL_DETAIL_LEVEL > 0.0) {
        // Apply procedural detail to distant terrain
        proceduralNormal(wPos, length(passViewPos), viewNormal);
    }

    gl_FragData[0].xyz = getPbr(
        osg_ViewMatrixInverse,
        passViewPos,
        viewNormal,
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
        getEmissionColor().rgb,
        0.0,
        waterDepth,
        MAT_DEFAULT
    );
    //gl_FragData[0].xyz = matSpec;
#endif

#if @radialFog
    float fogValue = clamp((euclideanDepth - gl_Fog.start) * gl_Fog.scale, 0.0, 1.0);
#else
    float fogValue = clamp((linearDepth - gl_Fog.start) * gl_Fog.scale, 0.0, 1.0);
#endif
    gl_FragData[0].xyz = mix(gl_FragData[0].xyz, gl_Fog.color.xyz, fogValue);

    applyShadowDebugOverlay();
}
