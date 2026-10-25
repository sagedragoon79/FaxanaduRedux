class_name Spells
extends RefCounted
## Spell registry. Each spell has an MP cost, damage and a projectile factory.
## Spells are unlocked through `Player.abilities` (the key matches the spell id).

const DATA := {
	"deluge": {"name": "Deluge", "cost": 15.0, "damage": 12, "speed": 300.0, "color": Color("4aa3df")},
	"thunder": {"name": "Thunder", "cost": 18.0, "damage": 16, "speed": 380.0, "color": Color("b8a8ff")},
	"fire": {"name": "Fire", "cost": 20.0, "damage": 18, "speed": 170.0, "lift": 150.0, "color": Color("f08a2a")},
	"tilte": {"name": "Tilte", "cost": 22.0, "damage": 14, "swarm_damage": 10, "color": Color("9cf0d8")},
}
## The order the Next Spell button cycles through.
const ORDER := ["deluge", "thunder", "fire", "tilte"]
## How far apart (radians) Tilte Swarm fans its three orbs.
const SWARM_SPREAD := 0.5


static func cost(id: String) -> float:
	return DATA[id]["cost"]


static func color(id: String) -> Color:
	return DATA.get(id, DATA.deluge)["color"]


## The spell after `current` that the player owns, or `current` if there is none.
static func next_owned(current: String, abilities: Dictionary) -> String:
	var start := ORDER.find(current)
	for i in range(1, ORDER.size() + 1):
		var id: String = ORDER[(start + i) % ORDER.size()]
		if abilities.get(id, false):
			return id
	return current


## Everything one cast throws: one projectile, or Tilte Swarm's three orbs.
static func cast_all(id: String, caster: Player) -> Array[Node2D]:
	var out: Array[Node2D] = []
	if id == "tilte" and caster.tilte_swarm:
		for i in 3:
			var orb := cast(id, caster) as TilteOrb
			orb.damage = DATA[id]["swarm_damage"]
			orb.heading = orb.heading.rotated((i - 1) * SWARM_SPREAD * caster.facing)
			out.append(orb)
	else:
		var one := cast(id, caster)
		if one != null:
			out.append(one)
	return out


static func cast(id: String, caster: Player) -> Node2D:
	match id:
		"deluge":
			var bolt := DelugeBolt.new()
			bolt.damage = DATA[id]["damage"]
			bolt.velocity = Vector2(caster.facing * DATA[id]["speed"], 0)
			bolt.pierce = caster.spell_pierce
			return bolt
		"fire":
			var ball := Fireball.new()
			ball.damage = DATA[id]["damage"]
			ball.velocity = Vector2(caster.facing * DATA[id]["speed"], -DATA[id]["lift"])
			return ball
		"tilte":
			var orb := TilteOrb.new()
			orb.damage = DATA[id]["damage"]
			# It leaves the hand drifting up and forward.
			orb.heading = Vector2(caster.facing, -0.6).normalized()
			return orb
		"thunder":
			var bolt := ThunderBolt.new()
			bolt.damage = DATA[id]["damage"]
			bolt.chain = ThunderBolt.CHAIN_JUMPS if caster.chain_thunder else 0
			bolt.velocity = Vector2(caster.facing * DATA[id]["speed"], 0)
			return bolt
	return null
