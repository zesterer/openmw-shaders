#include "config.glsl"

uniform float osg_SimulationTime;

void doSway(sampler2D diffuseMap, vec2 diffuseMapUV, inout vec3 modelPos, inout float leafiness) {
    if (texture2D(diffuseMap, diffuseMapUV).a < 0.2 && dot(gl_FrontMaterial.emission.rgb, vec3(1.0)) == 0.0) {
        if (WIND_AMPLITUDE > 0.0) {
            modelPos.xyz += sin(osg_SimulationTime * (WIND_AMPLITUDE + 1.0) * 1.5 + gl_Vertex.yzx * 0.01)
                * 0.01
                * WIND_AMPLITUDE
                * gl_Vertex.z
            ;
        }
        leafiness = 1.0;
    }
}
