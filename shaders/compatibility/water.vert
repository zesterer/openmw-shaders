#version 120

#include "lib/core/vertex.h.glsl"

varying vec4  position;
varying float linearDepth;

#include "shadows_vertex.glsl"
#include "lib/zesterer/warp.glsl"
#include "lib/view/depth.glsl"
#include "lib/zesterer/wave.glsl"

uniform vec3 nodePosition;
uniform vec3 playerPos;

varying vec3 worldPos;
varying vec2 rippleMapUV;

void main(void)
{
    vec4 modelPos = gl_Vertex;
    //modelPos.z += doWave();

    gl_Position = modelToClip(modelPos);

    position = modelPos;

	vec4 viewPos = modelToView(modelPos);
    gl_Position = warp_position(viewPos.xyz);
	
	worldPos = position.xyz + nodePosition.xyz;
    rippleMapUV = (worldPos.xy - playerPos.xy + (@ripple_map_size * @ripple_map_world_scale / 2.0)) / @ripple_map_size / @ripple_map_world_scale;
	
    linearDepth = getLinearDepth(gl_Position.z, viewPos.z);

    setupShadowCoords(viewPos, normalize((gl_NormalMatrix * gl_Normal).xyz));
}
