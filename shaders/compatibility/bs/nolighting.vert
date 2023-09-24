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

varying vec3 passNormal;
varying float euclideanDepth;
varying float linearDepth;
varying float passFalloff;

uniform bool useFalloff;
uniform vec4 falloffParams;

varying vec3 passViewPos;
varying float passFalloff;

uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ModelViewMatrix;
uniform sampler2D diffuseMap;

#include "vertexcolors.glsl"
#include "lib/view/depth.glsl"
#include "lib/zesterer/sway.glsl"

void main(void)
{
    #if @diffuseMap
        diffuseMapUV = (gl_TextureMatrix[@diffuseMapUV] * gl_MultiTexCoord@diffuseMapUV).xy;
    #endif

    vec4 modelPos = gl_Vertex;
    #if @diffuseMap
    doSway(diffuseMap, diffuseMapUV, modelPos.xyz, leafiness);
    #endif
    gl_Position = projectionMatrix * (gl_ModelViewMatrix * modelPos);

    vec4 viewPos = (gl_ModelViewMatrix * modelPos);
    gl_ClipVertex = viewPos;
    euclideanDepth = length(viewPos.xyz);
    linearDepth = getLinearDepth(gl_Position.z, viewPos.z);

    passColor = gl_Color;
    passNormal = gl_Normal.xyz;
    if (useFalloff)
    {
        vec3 viewNormal = gl_NormalMatrix * normalize(gl_Normal.xyz);
        vec3 viewDir = normalize(viewPos.xyz);
        float viewAngle = abs(dot(viewNormal, viewDir));
        passFalloff = smoothstep(falloffParams.y, falloffParams.x, viewAngle);
    }
    else
    {
        passFalloff = 1.0;
    }

#if @shadows_enabled
    vec3 viewNormal = normalize((gl_NormalMatrix * gl_Normal).xyz);
    setupShadowCoords(viewPos, viewNormal);
#endif
}
