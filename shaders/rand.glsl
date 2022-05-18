#include "config.glsl"

float rand(float n){return fract(sin(n) * 43758.5453123);}

float rand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}


float noise(float p){
	float fl = floor(p);
  float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}

float noise(vec2 n) {
	const vec2 d = vec2(0.0, 1.0);
  vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
	return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}



float hash(vec2 p) {return fract(sin(p.x * 1e2 + p.y) * 1e5 + sin(p.y * 1e3) * 1e3 + sin(p.x * 735. + p.y * 11.1) * 1.5e2); }

// GLSL smootherstep [smthrstp] from http://graphicscodex.com for reference
float smootherstep(float start, float end, float t) {
   t = max(0.0, min(1.0, (t - start) / (end - start)));
   return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}


// Returns three values on [-1, +1]:
// vec3(d noise(x,y) / dx, d noise(x, y) / dy, noise(x,y));
//
// This noise function can be combined in octaves to produce derivatives at multiple
// scales as well.
vec3 noised(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = hash(p);
    float b = hash(p + vec2(1.0, 0.0));
    float c = hash(p + vec2(0.0, 1.0));
    float d = hash(p + vec2(1.0, 1.0));

    // Simple 2D lerp using smoothstep envelope between the values. This is the underlying
	// "noise" function that is being differentiated.
	//
	// return vec3(mix(
	//               mix(a, b, smootherstep(0.0, 1.0, f.x)),
	//		         mix(c, d, smootherstep(0.0, 1.0, f.x)),
	//			     smootherstep(0.0, 1.0, f.y)));

	// Inigo's version with the derivatives, expanded and refactored.  This stores the bilinear
	// [smoothstep weighted] interpolated value noise in z and the derivatives in x and y.

    // Definition of smootherstep on a unit interval, applied in two dimensions simultaneously.
	vec2 v = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

	float noiseValue =
	    // Inigo's smoothstep approximation of smootherstep, which is slightly blurrier and
		// less expensive, but doesn't match the function being differentiated below:
	    // mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;

		// Full smootherstep version:
	 	mix(mix(a, b, v.x), mix(c, d, v.x), v.y);

	// Definition of smoothstep, which appears as a common subexpression below in the derivative terms.
    vec2 u = f * f * (3.0 - 2.0 * f);
	return vec3((30.0 * f * f * (f * (f - 2.0) + 1.0)) *
				(vec2(b, c) + (a - b - c + d) * u.yx - a),
				noiseValue);
}

vec3 proceduralNoise(vec3 wPos, float dist) {
    const float avg_scale = 0.001;
    const float fade = 1.0 / 5000.0;

    vec2 level_scales = max(vec2(floor(dist * avg_scale), ceil(dist * avg_scale)) / vec2(avg_scale), vec2(0.00001));
    float merge = fract(dist * avg_scale);
    return mix(
        noised(wPos.xy * 600.0 / level_scales.x),
        noised(wPos.xy * 600.0 / level_scales.y),
        vec3(merge)
    );
}

void proceduralNormal(vec3 wPos, float dist, inout vec3 normal) {
    const float fade = 1.0 / 5000.0;
    const float min_dist = 5000.0;

    vec3 nz = proceduralNoise(wPos, dist) * clamp((dist - min_dist) * fade, 0.0, 1.0);

    float level = dot(normal, vec3(0.0, 0.0, 1.0));
    normal = normalize(normal + nz * procedural_detail_level * level * level * level);
}

void proceduralUV(vec3 wPos, float dist, inout vec2 uv) {
    const float fade = 1.0 / 20000.0;
    const float min_dist = 5000.0;

    /*
    vec3 nz = proceduralNoise(wPos, dist * 10.0) * clamp((dist - min_dist) * fade, 0.0, 1.0);

    uv += nz.xy * sqrt(dist) * 0.0001;
    */

    uv += vec2(
        noise(wPos.xy * 0.004),
        noise(wPos.xy * 0.004 + 0.5)
    )
        * 0.03
        * min((1.0 - abs(uv - 0.5) * 2.0) * 25.0, vec2(1.0))
        * clamp((dist - min_dist) * fade, 0.0, 1.0);
}

/*
// from http://www.java-gaming.org/index.php?topic=35123.0
vec4 cubic(float v){
    vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
    vec4 s = n * n * n;
    float x = s.x;
    float y = s.y - 4.0 * s.x;
    float z = s.z - 4.0 * s.y + 6.0 * s.x;
    float w = 6.0 - x - y - z;
    return vec4(x, y, z, w) * (1.0/6.0);
}

vec4 textureBicubic(sampler2D sampler, vec2 texCoords){

   vec2 texSize = textureSize(sampler, 0) / 16.0;
   vec2 invTexSize = 1.0 / texSize;

   texCoords = texCoords * texSize - 0.5;


    vec2 fxy = fract(texCoords);
    texCoords -= fxy;

    vec4 xcubic = cubic(fxy.x);
    vec4 ycubic = cubic(fxy.y);

    vec4 c = texCoords.xxyy + vec2 (-0.5, +1.5).xyxy;

    vec4 s = vec4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
    vec4 offset = c + vec4 (xcubic.yw, ycubic.yw) / s;

    offset *= invTexSize.xxyy;

    vec4 sample0 = texture(sampler, offset.xz);
    vec4 sample1 = texture(sampler, offset.yz);
    vec4 sample2 = texture(sampler, offset.xw);
    vec4 sample3 = texture(sampler, offset.yw);

    float sx = s.x / (s.x + s.y);
    float sy = s.z / (s.z + s.w);

    return mix(
       mix(sample3, sample2, sx), mix(sample1, sample0, sx)
    , sy);
}
*/
