#version 120

#include "openmw_vertex.h.glsl"

varying vec4  position;
varying float linearDepth;

#include "shadows_vertex.glsl"
#include "depth.glsl"
#include "wave.glsl"

void main(void)
{
    vec4 modelPos = gl_Vertex;
    //mpos.z += doWave();

    gl_Position = mw_modelToClip(modelPos);

    position = modelPos;

    vec4 viewPos = mw_modelToView(modelPos);
    linearDepth = getLinearDepth(gl_Position.z, viewPos.z);

    setupShadowCoords(viewPos, normalize((gl_NormalMatrix * gl_Normal).xyz));
}
