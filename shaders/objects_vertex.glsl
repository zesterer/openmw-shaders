#version 120

#if @useUBO
    #extension GL_ARB_uniform_buffer_object : require
#endif

#if @useGPUShader4
    #extension GL_EXT_gpu_shader4: require
#endif

uniform mat4 projectionMatrix;

#if @diffuseMap
varying vec2 diffuseMapUV;
#endif

#if @darkMap
varying vec2 darkMapUV;
#endif

#if @detailMap
varying vec2 detailMapUV;
#endif

#if @decalMap
varying vec2 decalMapUV;
#endif

#if @emissiveMap
varying vec2 emissiveMapUV;
#endif

#if @normalMap
varying vec2 normalMapUV;
varying vec4 passTangent;
#endif

#if @envMap
varying vec2 envMapUV;
#endif

#if @bumpMap
varying vec2 bumpMapUV;
#endif

#if @specularMap
varying vec2 specularMapUV;
#endif

#if @glossMap
varying vec2 glossMapUV;
#endif

varying vec4 modelPos;

#define PER_PIXEL_LIGHTING (@normalMap || @forcePPL)

#if !PER_PIXEL_LIGHTING
centroid varying vec3 passLighting;
centroid varying vec3 shadowDiffuseLighting;
uniform float emissiveMult;
#endif
varying vec3 passViewPos;
varying vec3 passNormal;
varying float normZ;
varying float normZ2;

uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ModelViewMatrix;
uniform sampler2D diffuseMap;

varying float leafiness;

#include "vertexcolors.glsl"
#include "shadows_vertex.glsl"

#include "lighting.glsl"
#include "depth.glsl"
#include "sway.glsl"

void main(void)
{
    #if @diffuseMap
        diffuseMapUV = (gl_TextureMatrix[@diffuseMapUV] * gl_MultiTexCoord@diffuseMapUV).xy;
    #endif

    // Waving in the wind
    modelPos = gl_Vertex;
    leafiness = 0.0;
    #if @diffuseMap
        doSway(diffuseMap, diffuseMapUV, modelPos.xyz, leafiness);
    #endif
    gl_Position = projectionMatrix * (gl_ModelViewMatrix * modelPos);

    vec4 viewPos = (gl_ModelViewMatrix * modelPos);
    gl_ClipVertex = viewPos;

#if (@envMap || !PER_PIXEL_LIGHTING || @shadows_enabled)
    vec3 viewNormal = normalize((gl_NormalMatrix * gl_Normal).xyz);
#endif

#if @envMap
    vec3 viewVec = normalize(viewPos.xyz);
    vec3 r = reflect( viewVec, viewNormal );
    float m = 2.0 * sqrt( r.x*r.x + r.y*r.y + (r.z+1.0)*(r.z+1.0) );
    envMapUV = vec2(r.x/m + 0.5, r.y/m + 0.5);
#endif

#if @darkMap
    darkMapUV = (gl_TextureMatrix[@darkMapUV] * gl_MultiTexCoord@darkMapUV).xy;
#endif

#if @detailMap
    detailMapUV = (gl_TextureMatrix[@detailMapUV] * gl_MultiTexCoord@detailMapUV).xy;
#endif

#if @decalMap
    decalMapUV = (gl_TextureMatrix[@decalMapUV] * gl_MultiTexCoord@decalMapUV).xy;
#endif

#if @emissiveMap
    emissiveMapUV = (gl_TextureMatrix[@emissiveMapUV] * gl_MultiTexCoord@emissiveMapUV).xy;
#endif

#if @normalMap
    normalMapUV = (gl_TextureMatrix[@normalMapUV] * gl_MultiTexCoord@normalMapUV).xy;
    passTangent = gl_MultiTexCoord7.xyzw;
#endif

#if @bumpMap
    bumpMapUV = (gl_TextureMatrix[@bumpMapUV] * gl_MultiTexCoord@bumpMapUV).xy;
#endif

#if @specularMap
    specularMapUV = (gl_TextureMatrix[@specularMapUV] * gl_MultiTexCoord@specularMapUV).xy;
#endif

#if @glossMap
    glossMapUV = (gl_TextureMatrix[@glossMapUV] * gl_MultiTexCoord@glossMapUV).xy;
#endif

    passColor = gl_Color;
    passViewPos = viewPos.xyz;
    passNormal = gl_Normal.xyz;

#if !PER_PIXEL_LIGHTING
    vec3 diffuseLight, ambientLight;
    doLighting(viewPos.xyz, viewNormal, diffuseLight, ambientLight, shadowDiffuseLighting);
    vec3 emission = getEmissionColor().xyz * emissiveMult;
    passLighting = getDiffuseColor().xyz * diffuseLight + getAmbientColor().xyz * ambientLight + emission;
    clampLightingResult(passLighting);
    shadowDiffuseLighting *= getDiffuseColor().xyz;
#endif

#if (@shadows_enabled)
    // This is an extremely silly hack. A lot of tree models 'lie' about their normal, and this result in very bizarre
    // shadows because shadow-mapping relies on the normal actually pertaining to the real position of the polygon. To
    // resolve this, and because we really don't care about the exact normal of leaves, we force the shadows to believe
    // that the normal is pointing towards the sun, thereby ensuring correct shadow casting. We *only* do this if the
    // vertex is part of a leaf.
    setupShadowCoords(viewPos, (leafiness > 0.0) ? -lcalcPosition(0) : viewNormal);
#endif
}
