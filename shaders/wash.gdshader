shader_type canvas_item;
// A foe's hurt flash and attack tell (design bible 7): everything it draws is
// washed toward white, so the flash follows its own silhouette.

uniform float amount : hint_range(0.0, 1.0) = 0.72;

void fragment() {
	COLOR = vec4(mix(COLOR.rgb, vec3(1.0), amount), COLOR.a);
}
