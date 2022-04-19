#version 120

varying vec2 diffuseMapUV;

varying float alphaPassthrough;

uniform int colorMode;
uniform bool useDiffuseMapForShadowAlpha = true;
uniform bool alphaTestShadows = true;

uniform float osg_SimulationTime;
uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ModelViewMatrix;
uniform sampler2D diffuseMap;

void main(void)
{
    vec4 pos = gl_Vertex;
    if (texture2D(diffuseMap, vec2(1)).a < 1 && dot(gl_FrontMaterial.emission.rgb, vec3(1)) == 0) {
        //vec3 wpos = (osg_ViewMatrixInverse * osg_ModelViewMatrix * gl_Vertex).xyz;
        pos.xyz += sin(osg_SimulationTime + gl_Vertex.yzx * 0.01)
            * 0.01
            * gl_Vertex.z
        ;
    }
    gl_Position = gl_ModelViewProjectionMatrix * pos;

    vec4 viewPos = (gl_ModelViewMatrix * gl_Vertex);
    gl_ClipVertex = viewPos;

    if (useDiffuseMapForShadowAlpha)
        diffuseMapUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    else
        diffuseMapUV = vec2(0.0); // Avoid undefined behaviour if running on hardware predating the concept of dynamically uniform expressions
    if (colorMode == 2)
        alphaPassthrough = gl_Color.a;
    else
        // This is uniform, so if it's too low, we might be able to put the position/clip vertex outside the view frustum and skip the fragment shader and rasteriser
        alphaPassthrough = gl_FrontMaterial.diffuse.a;
}
