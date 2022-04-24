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

void proceduralDetail(vec3 wPos, float dist, inout vec3 normal, inout vec3 albedo) {
    const float level_scale = 0.0002;
    const float min_dist = 5000.0;
    const float fade = 1.0 / 5000.0;

    float level0_scale = max(floor(dist * level_scale) / level_scale, 0.0000001);
    float level1_scale = max(ceil(dist * level_scale) / level_scale, 0.0000001);
    float merge = fract(dist * level_scale);
    vec3 nz = mix(
        noised(wPos.xy * 800.0 / level0_scale),
        noised(wPos.xy * 800.0 / level1_scale),
        vec3(merge)
    ) * clamp((dist - min_dist) * fade, 0.0, 1.0);

    normal = normalize(normal + nz * procedural_detail_level);
}
