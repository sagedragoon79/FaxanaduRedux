class_name SapSpitter
extends Enemy
## A Trunk Hollows turret rooted in the floor (design bible 7). When you come
## near, its amber sac swells and glows (the telegraph), then it lobs a glob of
## sap in an arc at where you stand. The glob hurts, and where it lands it
## leaves a puddle of sap that slows you until it dries.

const SIGHT := 230.0
const WINDUP := 0.55
const RECOIL := 0.3
const COOLDOWN := 1.6
## Seconds the glob takes to reach its target; the arc is solved from this.
const FLIGHT := 0.8
const SHEET := "sap_spitter"

var _cooldown := 0.6


func _init() -> void:
	max_hp = 20
	launchable = false
	gold_min = 2
	gold_max = 5
	xp = 6
	body_size = Vector2(18, 20)
	knockback = 0.0
	contact_damage = 12


func _think(_delta: float) -> void:
	_cooldown -= _delta
	velocity.x = 0.0
	var off := player_offset()
	match state:
		"idle":
			if _cooldown <= 0.0 and off.x != INF and off.length() < SIGHT:
				face_player()
				set_state("windup")
				Sfx.play("splat", 0.1, -8.0)
		"windup":
			face_player()
			if state_time >= WINDUP:
				_spit()
				set_state("spit")
		"spit":
			if state_time >= RECOIL:
				_cooldown = COOLDOWN
				set_state("idle")
		_:
			set_state("idle")


## Where the glob leaves the spout.
func mouth() -> Vector2:
	var m: Array = Sheet.info(SHEET, "windup", 1).mouth
	return global_position + Vector2(float(m[0]) * facing, float(m[1]))


func _spit() -> void:
	var p := player()
	if p == null:
		return
	var glob := SapGlob.new()
	var from := mouth()
	var to := p.global_position + Vector2(0, -8)
	glob.velocity = SapGlob.launch(from, to, FLIGHT)
	glob.room = get_parent() as Room
	get_parent().add_child(glob)
	glob.global_position = from
	Sfx.play("pogo", 0.1, -6.0)


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var anim := "idle"
	if state == "windup":
		anim = "windup"
	elif state == "spit":
		anim = "spit"
	draw_sheet(SHEET, anim, state_time if anim != "idle" else Time.get_ticks_msec() * 0.001, white)
