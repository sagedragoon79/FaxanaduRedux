extends TestSuite
## Backdrop: atmospheric perspective on the parallax back layers (design bible
## 12.5). These cover the pure colour maths that the atmosphere shader runs, and
## the per-layer depth ordering, so the GPU effect is driven by tested logic.

const BRIGHT := Color(0.42, 0.72, 0.30)  # a saturated leaf green, like a lit backdrop


func _haze_dist(a: Color) -> float:
	var h := Backdrop.HAZE
	return absf(a.r - h.r) + absf(a.g - h.g) + absf(a.b - h.b)


func test_no_atmosphere_leaves_a_pixel_untouched() -> void:
	var out := Backdrop.haze_color(BRIGHT, 0.0, 0.0, Backdrop.HAZE)
	check(out.is_equal_approx(BRIGHT), "desat 0, fade 0 returns the source colour")


func test_full_fade_reaches_the_haze() -> void:
	var out := Backdrop.haze_color(BRIGHT, 0.0, 1.0, Backdrop.HAZE)
	check(out.is_equal_approx(Color(Backdrop.HAZE.r, Backdrop.HAZE.g, Backdrop.HAZE.b, BRIGHT.a)),
		"fade 1 lands on the haze colour")


func test_desaturation_lowers_saturation() -> void:
	var out := Backdrop.haze_color(BRIGHT, 0.5, 0.0, Backdrop.HAZE)
	check(out.s < BRIGHT.s, "pulling toward grey lowers saturation")
	var lum_before := BRIGHT.r * 0.299 + BRIGHT.g * 0.587 + BRIGHT.b * 0.114
	var lum_after := out.r * 0.299 + out.g * 0.587 + out.b * 0.114
	check_near(lum_after, lum_before, 0.01, "pulling toward luminance keeps perceived brightness")


func test_fade_pulls_a_bright_pixel_toward_the_dark_haze() -> void:
	var out := Backdrop.haze_color(BRIGHT, 0.0, 0.5, Backdrop.HAZE)
	check(_haze_dist(out) < _haze_dist(BRIGHT), "fading moves a bright pixel toward the haze")
	check(out.v < BRIGHT.v, "the haze is darker than a lit backdrop, so fading darkens it")


func test_far_recedes_further_than_mid() -> void:
	var far: Dictionary = Backdrop.ATMOS["far"]
	var mid: Dictionary = Backdrop.ATMOS["mid"]
	check(far["desat"] > mid["desat"], "the far layer is desaturated more than the mid layer")
	check(far["fade"] > mid["fade"], "the far layer is faded more than the mid layer")
	check(mid["desat"] > 0.0 and mid["fade"] > 0.0, "both layers get some atmosphere")
	check(far["desat"] <= 1.0 and far["fade"] <= 1.0, "the knobs stay in range")

	var far_out := Backdrop.haze_color(BRIGHT, far["desat"], far["fade"], Backdrop.HAZE)
	var mid_out := Backdrop.haze_color(BRIGHT, mid["desat"], mid["fade"], Backdrop.HAZE)
	check(far_out.s < mid_out.s, "a bright pixel ends up less saturated on the far layer")
	check(_haze_dist(far_out) < _haze_dist(mid_out), "and closer to the haze on the far layer")


func test_the_haze_is_a_dark_tone() -> void:
	check(Backdrop.HAZE.v < 0.3, "the haze is dark, so atmosphere means receding into shadow")


func test_atmos_material_carries_the_layer_parameters() -> void:
	var mat := Backdrop.atmos_material("far")
	check(mat != null, "the far layer gets an atmosphere material")
	check(mat.shader == Backdrop.ATMOS_SHADER, "it uses the atmosphere shader")
	check(is_equal_approx(mat.get_shader_parameter("desat"), Backdrop.ATMOS["far"]["desat"]),
		"its desat uniform matches the far config")
	check(is_equal_approx(mat.get_shader_parameter("fade"), Backdrop.ATMOS["far"]["fade"]),
		"its fade uniform matches the far config")
	check((mat.get_shader_parameter("haze") as Color).is_equal_approx(Backdrop.HAZE),
		"its haze uniform matches the palette haze")
	check(Backdrop.atmos_material("unknown") == null, "a layer with no atmosphere config gets no material")
