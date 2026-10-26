shader_type canvas_item;
// Cloak dyes (pass 136, design bible 10): the player sheet's cloak is the only
// green in it, so every green texel is recolored to the dye, keeping its
// shading. `dye` is the dye's lit tone; a texel as bright as LIT takes it in
// full. With `glow` (the Lord's Gold) a band of light runs down the cloth.

uniform vec4 dye : source_color = vec4(1.0);
uniform bool glow = false;

const float HUE_LO = 0.25;
const float HUE_HI = 0.55;
const float SAT_MIN = 0.15;
const float LIT = 0.3;

vec3 hsv(vec3 c) {
	vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 1e-10)), d / (q.x + 1e-10), q.x);
}

void fragment() {
	// COLOR comes in as the texel times the draw's tint.
	vec3 h = hsv(COLOR.rgb);
	if (h.x >= HUE_LO && h.x <= HUE_HI && h.y > SAT_MIN) {
		vec3 c = dye.rgb * clamp(h.z / LIT, 0.0, 1.4);
		if (glow) {
			float band = 0.5 + 0.5 * sin(TIME * 4.0 - UV.y * 300.0);
			c = mix(c, vec3(1.0, 0.96, 0.78), 0.25 + 0.35 * band * band);
		}
		COLOR.rgb = c;
	}
}
