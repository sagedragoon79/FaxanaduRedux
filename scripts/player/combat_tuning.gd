class_name CombatTuning
extends Resource
## Combat, resource and death numbers (design bible section 5). Tests assert these.

@export_group("Melee")
@export var slash_damage := 8
@export var heavy_damage := 14
## Seconds after a swing starts in which the next press continues the combo.
@export var combo_window := 0.40
## Cooldown after combo hits 1, 2 and 3. The heavy third hit recovers slower.
@export var combo_cooldowns: Array[float] = [0.20, 0.20, 0.38]
@export var ground_combo_length := 3
@export var air_combo_length := 2
@export var attack_buffer := 0.15
## The Rune Dagger's Throw is buffered like Attack (pass 192).
@export var throw_buffer := 0.15
@export var heavy_hitstop := 0.09
@export var hit_hitstop := 0.05
## An up-slash that connects in midair holds you up: a fall is turned into
## this much rise (px/s), about 7 px. Once per swing; it never adds to a jump.
@export var up_slash_pop := 150.0

@export_group("Shield")
@export var parry_window := 0.12
@export var parry_hitstop := 0.14
@export var parry_mp_gain := 6.0
@export var guard_reduction := 0.5
@export var guard_mp_cost := 8.0
@export var guard_move_multiplier := 0.4

@export_group("Taking damage")
@export var hurt_knockback := Vector2(160, 220)
@export var hurt_control_lock := 0.18
@export var hazard_damage := 20
## At or below this much health (one mask) the heart beats and the screen's edge pulses red.
@export var low_health := 20
@export var heartbeat_interval := 0.85
## Threat (design bible 5.5, pass 194): every blow a foe or a foe's shot lands
## is multiplied by its zone's threat, so the deep zones hit as hard against the
## armor you will have by then as the Trunk does against Leather. Boss arenas
## and zones not listed (Eolis, the gym, the trials) stay at 1.
const ZONE_THREAT := {
	"trunk": 1.0, "tower": 1.0, "mist": 1.4, "branches": 1.5,
	"daybreak": 1.6, "dartmoor": 2.0, "sunken": 2.0, "zenis": 2.0,
}

@export_group("Magic")
@export var max_mp := 60.0
@export var mp_regen_per_second := 2.0
@export var mp_per_melee_hit := 4.0
@export var cast_cooldown := 0.35

@export_group("Red Potion")
@export var flask_charges := 2
@export var flask_heal := 40
@export var drink_time := 0.7

@export_group("Thrust")
## Thrust (Blade skill, pass 149; design bible 9): hold Attack this long and
## let go for a charged lunge. Damage is the heavy hit times thrust_mult.
@export var thrust_charge := 0.4
@export var thrust_mult := 1.5
## On the floor the lunge drives you this fast (px/s) for thrust_time, about
## 50 px. In the air the thrust strikes where you are and carries you nowhere.
@export var thrust_speed := 320.0
@export var thrust_time := 0.16
@export var thrust_cooldown := 0.35

@export_group("Executioner")
## Executioner (Blade skill, pass 163; design bible 9): melee blows on a boss
## in its opening (Enemy.punishable) land for this much more.
@export var executioner_mult := 1.35

@export_group("War Glove")
## The original's Glove, a rare drop (design bible 7, pass 147): for this long
## every blade hit deals this much more.
@export var war_glove_mult := 1.5
@export var war_glove_time := 15.0

@export_group("Death")
@export var death_gold_fraction := 0.6
@export var respawn_delay := 1.2
