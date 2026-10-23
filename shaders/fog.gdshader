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

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	// Snap to world pixels so the fog stays pixel art.
	vec2 p = floor(world_pos);
	float clear = 0.0;
	for (int i = 0; i < MAX_LIGHTS; i++) {
		if (i >= light_count) {
			break;
		}
		float d = distance(p, lights[i].xy);
		float r = lights[i].z;
		clear = max(clear, 1.0 - smoothstep(r * 0.45, r, d));
	}
	// Banded steps, like dithered fog, rather than a smooth gradient.
	clear = floor(clear * 4.0 + 0.5) / 4.0;
	float drift = noise(p / 40.0 + vec2(TIME * 0.15, TIME * 0.05)) * 0.6 + noise(p / 13.0 - vec2(TIME * 0.3, 0.0)) * 0.4;
	float thick = density * (1.0 - clear) * (0.85 + 0.15 * drift);
	vec3 col = mix(fog_color.rgb, deep_color.rgb, 0.55 + 0.25 * drift);
	COLOR = vec4(col, thick);
}
