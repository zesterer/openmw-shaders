#version 120

uniform mat4 projectionMatrix;

varying vec2 diffuseMapUV;
varying float alphaPassthrough;

uniform float osg_SimulationTime;
uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ModelViewMatrix;
uniform sampler2D diffuseMap;

#include "vertexcolors.glsl"

void main()
{
    diffuseMapUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    vec4 pos = gl_Vertex;
    if (texture2D(diffuseMap, diffuseMapUV).a < 0.2 && dot(gl_FrontMaterial.emission.rgb, vec3(1)) == 0) {
        //vec3 wpos = (osg_ViewMatrixInverse * osg_ModelViewMatrix * gl_Vertex).xyz;
        pos.xyz += sin(osg_SimulationTime + gl_Vertex.yzx * 0.01)
            * 0.01
            * gl_Vertex.z
        ;
    }
    gl_Position = projectionMatrix * (gl_ModelViewMatrix * pos);

    if (colorMode == 2)
        alphaPassthrough = gl_Color.a;
    else
        alphaPassthrough = gl_FrontMaterial.diffuse.a;
}
