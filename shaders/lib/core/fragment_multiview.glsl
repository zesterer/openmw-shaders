#version 330

#extension GL_OVR_multiview : require
#extension GL_OVR_multiview2 : require
#extension GL_EXT_texture_array : require

#include "lib/core/fragment.h.glsl"

uniform sampler2DArray reflectionMap;

vec4 sampleReflectionMap(vec2 uv)
{
    return texture2DArray(reflectionMap, vec3((uv), gl_ViewID_OVR));
}

#if @refraction_enabled

uniform sampler2DArray refractionMap;
uniform sampler2DArray refractionDepthMap;

vec4 sampleRefractionMap(vec2 uv)
{
    return texture2DArray(refractionMap, vec3((uv), gl_ViewID_OVR));
}

float sampleRefractionDepthMap(vec2 uv)
{
    return texture2DArray(refractionDepthMap, vec3((uv), gl_ViewID_OVR)).x;
}

#endif

uniform sampler2DArray omw_SamplerLastShader;

vec4 samplerLastShader(vec2 uv)
{
    return texture2DArray(omw_SamplerLastShader, vec3((uv), gl_ViewID_OVR));
}

#if @skyBlending
uniform sampler2DArray sky;

vec3 sampleSkyColor(vec2 uv)
{
    return texture2DArray(sky, vec3((uv), gl_ViewID_OVR)).xyz;
}
#endif
