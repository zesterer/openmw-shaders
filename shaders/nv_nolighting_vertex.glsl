#version 120

uniform mat4 projectionMatrix;

#if @diffuseMap
varying vec2 diffuseMapUV;
#endif

#if @radialFog
varying float euclideanDepth;
#else
varying float linearDepth;
#endif

uniform bool useFalloff;
uniform vec4 falloffParams;

varying vec3 passViewPos;
varying float passFalloff;

uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ModelViewMatrix;
uniform sampler2D diffuseMap;

#include "vertexcolors.glsl"
#include "depth.glsl"
#include "sway.glsl"

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

    vec4 viewPos = (gl_ModelViewMatrix * gl_Vertex);
    gl_ClipVertex = viewPos;
#if @radialFog
    euclideanDepth = length(viewPos.xyz);
#else
    linearDepth = getLinearDepth(gl_Position.z, viewPos.z);
#endif

    passColor = gl_Color;
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
}
