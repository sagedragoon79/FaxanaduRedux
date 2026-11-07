shader_type canvas_item;
// Atmospheric perspective on a parallax background layer (design bible 12.5):
// the further-back a layer sits, the more its colour is pulled toward grey
// (desat) and toward the dark zone haze (fade), lowering its saturation and
// contrast so the lit gameplay layer stands clear of it. GPU-only, no per-frame
// CPU cost. The maths mirror Backdrop.haze_color() exactly, which the tests drive.

uniform float desat : hint_range(0.0, 1.0) = 0.0;
uniform float fade : hint_range(0.0, 1.0) = 0.0;
uniform vec3 haze : source_color = vec3(0.0);

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float lum = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	vec3 rgb = mix(col.rgb, vec3(lum), desat);
	rgb = mix(rgb, haze, fade);
	COLOR = vec4(rgb, col.a);
}
