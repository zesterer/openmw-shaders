#version 120

#if @useUBO
    #extension GL_ARB_uniform_buffer_object : require
#endif

#if @useGPUShader4
    #extension GL_EXT_gpu_shader4: require
#endif

varying vec2 diffuseMapUV;
varying float alphaPassthrough;

uniform mat4 osg_ViewMatrixInverse;
uniform sampler2D diffuseMap;

#include "lib/core/vertex.h.glsl"
#include "vertexcolors.glsl"
#include "lib/zesterer/sway.glsl"

void main()
{
    vec4 modelPos = gl_Vertex;
    float leafiness;
    doSway(diffuseMap, diffuseMapUV, modelPos.xyz, leafiness);

    gl_Position = modelToClip(modelPos);

    vec4 viewPos = modelToView(modelPos);
    gl_ClipVertex = viewPos;

    if (colorMode == 2)
        alphaPassthrough = gl_Color.a;
    else
        alphaPassthrough = gl_FrontMaterial.diffuse.a;

    diffuseMapUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
