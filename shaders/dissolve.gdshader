shader_type canvas_item;
// An enemy's death (design bible 7): a white flash, then the body breaks up
// into motes pixel by pixel, each one glowing as it goes. `progress` runs 0 to 1.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge : source_color = vec4(1.0, 0.9, 0.62, 1.0);

varying vec2 local;

void vertex() {
	local = VERTEX;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	// One world pixel per cell (two art pixels), the top breaking up a little first.
	vec2 cell = floor(local);
	float n = hash(cell) * 0.85 + 0.075 + clamp(local.y / 160.0, -0.15, 0.15);
	float t = progress * 1.2 - 0.05;
	if (n < t) {
		discard;
	}
	vec3 col = mix(COLOR.rgb, vec3(1.0), clamp(1.0 - progress * 5.0, 0.0, 1.0));
	col = mix(col, edge.rgb, step(n, t + 0.1));
	COLOR = vec4(col, COLOR.a);
}
