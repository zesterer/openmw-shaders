#version 120

uniform mat4 projectionMatrix;

varying vec4  position;
varying float linearDepth;

#include "shadows_vertex.glsl"
#include "depth.glsl"
#include "wave.glsl"

void main(void)
{
    vec4 mpos = gl_Vertex;
    //mpos.z += doWave();

    gl_Position = projectionMatrix * (gl_ModelViewMatrix * mpos);

    position = mpos;

    vec4 viewPos = gl_ModelViewMatrix * mpos;
    linearDepth = getLinearDepth(gl_Position.z, viewPos.z);

    setupShadowCoords(viewPos, normalize((gl_NormalMatrix * gl_Normal).xyz));
}
