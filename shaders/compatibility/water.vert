#version 120

#include "lib/core/vertex.h.glsl"

varying vec4  position;
varying float linearDepth;

#include "shadows_vertex.glsl"
#include "lib/zesterer/warp.glsl"
#include "lib/view/depth.glsl"
#include "lib/zesterer/wave.glsl"

void main(void)
{
    vec4 modelPos = gl_Vertex;
    //mpos.z += doWave();

    gl_Position = modelToClip(modelPos);

    position = modelPos;

    vec4 viewPos = modelToView(modelPos);

    gl_Position = warp_position(viewPos.xyz);

    linearDepth = getLinearDepth(gl_Position.z, viewPos.z);

    setupShadowCoords(viewPos, normalize((gl_NormalMatrix * gl_Normal).xyz));
}
