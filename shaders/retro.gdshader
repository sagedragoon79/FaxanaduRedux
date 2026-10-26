shader_type canvas_item;
// Eolis of Old (design bible 11, pass 152): the screen as a cartridge drew it.
// Everything drawn below this layer is read back, cut into blocks of `block`
// world pixels, framed 4:3 like a television of the day, and each block is
// matched to the nearest colour of the NES's own palette (the 2C02's 55
// distinct colours; the duplicate blacks are left out). RetroFilter draws it.

const int COLOURS = 55;
const vec3 PALETTE[COLOURS] = vec3[](
	vec3(0.4863, 0.4863, 0.4863), vec3(0.0000, 0.0000, 0.9882), vec3(0.0000, 0.0000, 0.7373), vec3(0.2667, 0.1569, 0.7373),
	vec3(0.5804, 0.0000, 0.5176), vec3(0.6588, 0.0000, 0.1255), vec3(0.6588, 0.0627, 0.0000), vec3(0.5333, 0.0784, 0.0000),
	vec3(0.3137, 0.1882, 0.0000), vec3(0.0000, 0.4706, 0.0000), vec3(0.0000, 0.4078, 0.0000), vec3(0.0000, 0.3451, 0.0000),
	vec3(0.0000, 0.2510, 0.3451), vec3(0.0000, 0.0000, 0.0000), vec3(0.7373, 0.7373, 0.7373), vec3(0.0000, 0.4706, 0.9725),
	vec3(0.0000, 0.3451, 0.9725), vec3(0.4078, 0.2667, 0.9882), vec3(0.8471, 0.0000, 0.8000), vec3(0.8941, 0.0000, 0.3451),
	vec3(0.9725, 0.2196, 0.0000), vec3(0.8941, 0.3608, 0.0627), vec3(0.6745, 0.4863, 0.0000), vec3(0.0000, 0.7216, 0.0000),
	vec3(0.0000, 0.6588, 0.0000), vec3(0.0000, 0.6588, 0.2667), vec3(0.0000, 0.5333, 0.5333), vec3(0.9725, 0.9725, 0.9725),
	vec3(0.2353, 0.7373, 0.9882), vec3(0.4078, 0.5333, 0.9882), vec3(0.5961, 0.4706, 0.9725), vec3(0.9725, 0.4706, 0.9725),
	vec3(0.9725, 0.3451, 0.5961), vec3(0.9725, 0.4706, 0.3451), vec3(0.9882, 0.6275, 0.2667), vec3(0.9725, 0.7216, 0.0000),
	vec3(0.7216, 0.9725, 0.0941), vec3(0.3451, 0.8471, 0.3294), vec3(0.3451, 0.9725, 0.5961), vec3(0.0000, 0.9098, 0.8471),
	vec3(0.4706, 0.4706, 0.4706), vec3(0.9882, 0.9882, 0.9882), vec3(0.6431, 0.8941, 0.9882), vec3(0.7216, 0.7216, 0.9725),
	vec3(0.8471, 0.7216, 0.9725), vec3(0.9725, 0.7216, 0.9725), vec3(0.9725, 0.6431, 0.7529), vec3(0.9412, 0.8157, 0.6902),
	vec3(0.9882, 0.8784, 0.6588), vec3(0.9725, 0.8471, 0.4706), vec3(0.8471, 0.9725, 0.4706), vec3(0.7216, 0.9725, 0.7216),
	vec3(0.7216, 0.9725, 0.8471), vec3(0.0000, 0.9882, 0.9882), vec3(0.9725, 0.8471, 0.9725)
);

uniform sampler2D screen : hint_screen_texture, filter_nearest;
// World pixels per NES pixel: 2 gives 240 x 180 in the 4:3 frame.
uniform float block = 2.0;
// Render pixels per world pixel: the world view draws at GameCamera.DETAIL
// (RetroFilter sets it from its viewport), so a block is block * detail.
uniform float detail = 2.0;
uniform float frame_aspect = 1.33333;

// The nearest palette colour, by the "redmean" weighting so that greens and
// skin tones land where an eye would put them.
vec3 nearest(vec3 c) {
	vec3 best = PALETTE[0];
	float best_d = 1e9;
	for (int i = 0; i < COLOURS; i++) {
		vec3 p = PALETTE[i];
		vec3 d = c - p;
		float r = (c.r + p.r) * 0.5;
		float dist = (2.0 + r) * d.r * d.r + 4.0 * d.g * d.g + (3.0 - r) * d.b * d.b;
		if (dist < best_d) {
			best_d = dist;
			best = p;
		}
	}
	return best;
}

void fragment() {
	vec2 size = 1.0 / SCREEN_PIXEL_SIZE;
	// Blocks are whole render pixels laid from the view's corner, where the
	// world's pixels start, so each block covers exactly block x block of them.
	float cell = block * detail;
	vec2 pos = SCREEN_UV * size;
	// The 4:3 frame, its edges on the block grid.
	float mid = floor(size.x * 0.5 / cell + 0.5) * cell;
	float half_width = floor(size.y * frame_aspect * 0.5 / cell) * cell;
	if (abs(pos.x - mid) > half_width) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		vec2 centre = (floor(pos / cell) + 0.5) * cell;
		vec3 c = textureLod(screen, centre * SCREEN_PIXEL_SIZE, 0.0).rgb;
		COLOR = vec4(nearest(c), 1.0);
	}
}
