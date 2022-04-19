#version 140

//#include "lighting_util.glsl"

varying vec2 uv;
uniform sampler2D sceneTex;
//uniform sampler2D sceneDepth;

void main()
{
    vec3 col = texture2D(sceneTex, uv).rgb;

    /* for (int i = @startLight; i < @endLight; ++i) { */
    /*     int lightIndex = PointLightIndex[i]; */
    /* } */
    //col = fract(texture2D(sceneDepth, uv).r * 10);
    col = vec3(1, 0, 0);

    float lum = dot(col, vec3(0.2126, 0.7152, 0.0722));

    if (lum < @epsilon)
    {
        gl_FragColor.r = 0.0;
        return;
    }

    gl_FragColor.r = clamp((log2(lum) - @minLog) * @invLogLumRange, 0.0, 1.0);
}
