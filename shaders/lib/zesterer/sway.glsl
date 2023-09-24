#include "lib/zesterer/config.glsl"

uniform float osg_SimulationTime;

#include "lib/light/lighting_util.glsl"

void doSway(sampler2D diffuseMap, vec2 diffuseMapUV, inout vec3 modelPos, inout float leafiness) {
    if (texture2D(diffuseMap, diffuseMapUV).a < 0.2
        && dot(gl_FrontMaterial.emission.rgb, vec3(1.0)) == 0.0
        //&& abs(abs(gl_Normal.z) - 0.5) < 0.4
        // Only enable swaying in exteriors, for now
        && step(0.0, (osg_ViewMatrixInverse * vec4(lcalcPosition(0), 0.0)).y) == 0.0
    ) {
        if (WIND_AMPLITUDE > 0.0) {
            modelPos.xyz += sin(osg_SimulationTime * (WIND_AMPLITUDE + 1.0) * 1.5 + modelPos.yzx * 0.01)
                * 0.01
                * WIND_AMPLITUDE
                * modelPos.z
            ;
        }
        leafiness = 1.0;
    }
}
