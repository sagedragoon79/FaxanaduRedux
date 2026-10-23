shader_type canvas_item;
// Sharp bilinear upscaling for the world image: crisp nearest-neighbor pixels
// at integer scales, and only a one-screen-pixel blend along pixel edges at
// fractional ones (a 2x render shown at 1080p is a 1.5x scale), so pixels
// never come out uneven. Needs a linear texture filter.

void fragment() {
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 px = UV * size;
	vec2 seam = floor(px + 0.5);
	vec2 d = max(fwidth(px), vec2(1e-4));
	px = seam + clamp((px - seam) / d, -0.5, 0.5);
	COLOR = texture(TEXTURE, px / size);
}
