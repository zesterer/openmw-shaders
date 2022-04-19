#version 120

uniform sampler2D omw_SamplerLastShader;
varying vec2 uv;

void main()
{
    gl_FragColor = texture2D(omw_SamplerLastShader, uv);
}
