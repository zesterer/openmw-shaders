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

uniform float osg_SimulationTime;
uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ModelViewMatrix;
uniform sampler2D diffuseMap;

#include "vertexcolors.glsl"
#include "depth.glsl"

void main(void)
{
    vec4 pos = gl_Vertex;
    if (texture2D(diffuseMap, vec2(1)).a < 1 && dot(gl_FrontMaterial.emission.rgb, vec3(1)) == 0) {
        //vec3 wpos = (osg_ViewMatrixInverse * osg_ModelViewMatrix * gl_Vertex).xyz;
        pos.xyz += sin(osg_SimulationTime + gl_Vertex.yzx * 0.01)
            * 0.01
            * gl_Vertex.z
        ;
    }
    gl_Position = projectionMatrix * (gl_ModelViewMatrix * pos);

    vec4 viewPos = (gl_ModelViewMatrix * gl_Vertex);
    gl_ClipVertex = viewPos;
#if @radialFog
    euclideanDepth = length(viewPos.xyz);
#else
    linearDepth = getLinearDepth(gl_Position.z, viewPos.z);
#endif

#if @diffuseMap
    diffuseMapUV = (gl_TextureMatrix[@diffuseMapUV] * gl_MultiTexCoord@diffuseMapUV).xy;
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
