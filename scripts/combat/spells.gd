class_name Spells
extends RefCounted
## Spell registry. Each spell has an MP cost, damage and a projectile factory.
## Spells are unlocked through `Player.abilities` (the key matches the spell id).

const DATA := {
	"deluge": {"name": "Deluge", "cost": 15.0, "damage": 12, "speed": 300.0, "color": Color("4aa3df")},
	"thunder": {"name": "Thunder", "cost": 18.0, "damage": 16, "speed": 380.0, "color": Color("b8a8ff")},
	"fire": {"name": "Fire", "cost": 20.0, "damage": 18, "speed": 170.0, "lift": 150.0, "color": Color("f08a2a")},
}
## The order the Next Spell button cycles through.
const ORDER := ["deluge", "thunder", "fire"]


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
		"thunder":
			var bolt := ThunderBolt.new()
			bolt.damage = DATA[id]["damage"]
			bolt.velocity = Vector2(caster.facing * DATA[id]["speed"], 0)
			return bolt
	return null
