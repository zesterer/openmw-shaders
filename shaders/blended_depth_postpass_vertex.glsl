#version 140

uniform mat4 projectionMatrix;

varying vec2 diffuseMapUV;
varying float alphaPassthrough;

uniform mat4 osg_ViewMatrixInverse;
uniform sampler2D diffuseMap;

#include "openmw_vertex.h.glsl"
#include "vertexcolors.glsl"
#include "sway.glsl"

void main()
{
    diffuseMapUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    vec4 modelPos = gl_Vertex;
    float leafiness;
    doSway(diffuseMap, diffuseMapUV, modelPos.xyz, leafiness);
    gl_Position = mw_modelToClip(modelPos);

    if (colorMode == 2)
        alphaPassthrough = gl_Color.a;
    else
        alphaPassthrough = gl_FrontMaterial.diffuse.a;
}
