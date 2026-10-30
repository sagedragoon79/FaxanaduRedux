shader_type canvas_item;
// The PixelLab hero sets (design bible 13.5) draw the cloak in a key green, like a
// green screen, and keep the elf's purple hair: both are recolored here. Every
// texel of the key (a saturated pure green no other part of the hero uses) takes
// the cloak dye, keeping its shading; with `glow` (the Lord's Gold) a band of
// light runs down the cloth. With `hair_on`, every texel of the hair's purple
// takes the hair color the same way. The armor's violet-tinted steel and the
// outline are too grey or too dark to count as hair.

uniform vec4 dye : source_color = vec4(0.3, 0.54, 0.3, 1.0);
uniform bool glow = false;
uniform vec4 hair : source_color = vec4(1.0);
uniform bool hair_on = false;

const float KEY_HUE_LO = 0.25;
const float KEY_HUE_HI = 0.42;
const float KEY_SAT = 0.5;
// The key's lit tone: a texel this bright takes the dye in full.
const float KEY_LIT = 0.9;
const float HAIR_HUE_LO = 0.72;
const float HAIR_HUE_HI = 0.9;
const float HAIR_SAT = 0.5;
const float HAIR_DARK = 0.35;
const float HAIR_LIT = 0.72;

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
	if (h.x >= KEY_HUE_LO && h.x <= KEY_HUE_HI && h.y > KEY_SAT) {
		vec3 c = dye.rgb * clamp(h.z / KEY_LIT, 0.0, 1.15);
		if (glow) {
			float band = 0.5 + 0.5 * sin(TIME * 4.0 - UV.y * 300.0);
			c = mix(c, vec3(1.0, 0.96, 0.78), 0.25 + 0.35 * band * band);
		}
		COLOR.rgb = c;
	} else if (hair_on && h.x >= HAIR_HUE_LO && h.x <= HAIR_HUE_HI && h.y > HAIR_SAT && h.z > HAIR_DARK) {
		COLOR.rgb = hair.rgb * clamp(h.z / HAIR_LIT, 0.0, 1.2);
	}
}
