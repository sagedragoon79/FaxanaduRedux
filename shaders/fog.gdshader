shader_type canvas_item;
// The Mist's fog (design bible 3.2): a grey-green murk over the room with clear
// pockets around the player and every light. Fog.visibility_at mirrors the
// falloff on the CPU, so keep the two in step.

const int MAX_LIGHTS = 48;

uniform vec4 fog_color : source_color = vec4(0.47, 0.53, 0.48, 1.0);
uniform vec4 deep_color : source_color = vec4(0.07, 0.09, 0.09, 1.0);
uniform float density = 0.82;
uniform int light_count = 0;
// x, y in world pixels; z is the clear radius.
uniform vec3 lights[MAX_LIGHTS];

// Tileable random lattice (Fog.drift_texture); sampled with linear filtering it
// is value noise for a texture fetch, far cheaper than hashing per fragment.
uniform sampler2D drift_tex : repeat_enable, filter_linear;

// World position of the fog texture's top-left pixel: the fog is drawn one
// texel per world pixel in its own small viewport (see Fog) and scaled up.
uniform vec2 origin = vec2(0.0);

varying vec2 world_pos;

void vertex() {
	world_pos = origin + VERTEX;
}

void fragment() {
	// Snap to world pixels so the fog stays pixel art.
	vec2 p = floor(world_pos);
	float clear = 0.0;
	for (int i = 0; i < MAX_LIGHTS; i++) {
		if (i >= light_count) {
			break;
		}
		vec2 dv = p - lights[i].xy;
		float r = lights[i].z;
		float d2 = dot(dv, dv);
		// Most lights are far from most fragments: skip the sqrt and smoothstep.
		if (d2 < r * r) {
			clear = max(clear, 1.0 - smoothstep(r * 0.45, r, sqrt(d2)));
		}
	}
	// Banded steps, like dithered fog, rather than a smooth gradient.
	clear = floor(clear * 4.0 + 0.5) / 4.0;
	float drift = texture(drift_tex, (p / 40.0 + vec2(TIME * 0.15, TIME * 0.05)) / 64.0).r * 0.6
		+ texture(drift_tex, (p / 13.0 - vec2(TIME * 0.3, 0.0)) / 64.0).r * 0.4;
	float thick = density * (1.0 - clear) * (0.85 + 0.15 * drift);
	vec3 col = mix(fog_color.rgb, deep_color.rgb, 0.55 + 0.25 * drift);
	COLOR = vec4(col, thick);
}
