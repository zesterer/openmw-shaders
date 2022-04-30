#version 120

varying vec2 diffuseMapUV;

varying float alphaPassthrough;

uniform int colorMode;
uniform bool useDiffuseMapForShadowAlpha = true;
uniform bool alphaTestShadows = true;

uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ModelViewMatrix;
uniform sampler2D diffuseMap;

#include "sway.glsl"

void main(void)
{
    vec4 modelPos = gl_Vertex;
    float leafiness;
    diffuseMapUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    doSway(diffuseMap, diffuseMapUV, modelPos.xyz, leafiness);
    gl_Position = gl_ModelViewProjectionMatrix * modelPos;

    vec4 viewPos = (gl_ModelViewMatrix * gl_Vertex);
    gl_ClipVertex = viewPos;

    if (useDiffuseMapForShadowAlpha)
        diffuseMapUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    else
        diffuseMapUV = vec2(0.0); // Avoid undefined behaviour if running on hardware predating the concept of dynamically uniform expressions
    if (colorMode == 2)
        alphaPassthrough = gl_Color.a;
    else
        // This is uniform, so if it's too low, we might be able to put the position/clip vertex outside the view frustum and skip the fragment shader and rasteriser
        alphaPassthrough = gl_FrontMaterial.diffuse.a;
}
