#include "config.glsl"

uniform mat4 osg_ViewMatrix;
uniform mat4 osg_ViewMatrixInverse;

vec4 warp_position(vec3 viewPos) {
    #if (MAJESTIC_WARP == 1)
        vec3 cam_wPos = (osg_ViewMatrixInverse * vec4(vec3(0), 1)).xyz;
        vec3 wPos = (osg_ViewMatrixInverse * vec4(viewPos.xyz, 1)).xyz;

        //vec3 new_wPos = wPos + vec3(0, 0, wPos.z - cam_wPos.z + 500.0) * min(distance(cam_wPos.xy, wPos.xy), 100000.0) * 0.00002;
        //vec3 new_wPos = wPos + vec3(0, 0, pow(max(abs(wPos.z - cam_wPos.z) - 0.0, 0.0), 1.5) * 0.01 * sign(wPos.z - cam_wPos.z));
        float water_z = abs(cam_wPos.z) * -sign(cam_wPos.z);
        float new_z = water_z * 0 + wPos.z * (1.0 + min(distance(cam_wPos.xy, wPos.xy), 100000.0) * 0.00002);
        vec3 new_wPos = vec3(wPos.xy, new_z);
        return mw_viewToClip(osg_ViewMatrix * vec4(new_wPos, 1));
    #else
        return mw_viewToClip(vec4(viewPos, 1));
    #endif
}
