class_name Spells
extends RefCounted
## Spell registry. Each spell has an MP cost, damage and a projectile factory.
## Spells are unlocked through `Player.abilities` (the key matches the spell id).

const DATA := {
	"deluge": {"name": "Deluge", "cost": 15.0, "damage": 12, "speed": 300.0},
}


static func cost(id: String) -> float:
	return DATA[id]["cost"]


static func cast(id: String, caster: Player) -> Node2D:
	match id:
		"deluge":
			var bolt := DelugeBolt.new()
			bolt.damage = DATA[id]["damage"]
			bolt.velocity = Vector2(caster.facing * DATA[id]["speed"], 0)
			return bolt
	return null
