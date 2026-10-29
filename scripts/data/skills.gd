class_name Skills
extends RefCounted
## Learning and unlearning skill tree nodes (data/skills.json, design bible 9).
## Effects are applied by GameState.refresh_stats.

static func nodes() -> Array:
	return GameData.table("skills").nodes


## Why a skill can't be learned: "" (it can), "learned", "locked" or "points".
static func status(id: String) -> String:
	var node := GameData.skill(id)
	if GameState.has_skill(id):
		return "learned"
	if String(node.needs) != "" and not GameState.has_skill(node.needs):
		return "locked"
	if int(GameState.data.skill_points) < int(node.cost):
		return "points"
	return ""


## What a skill works through, when the player hasn't found it yet: the
## ability or spell's name ("Wing Boots"), else "". A skill can be learned
## before it, and the tree says it waits (pass 237).
static func waits_on(id: String) -> String:
	var uses := String(GameData.skill(id).get("uses", ""))
	if uses == "" or bool(GameState.data.abilities.get(uses, false)):
		return ""
	return uses_name(uses)


## The name an ability or spell id goes by in the tree.
static func uses_name(uses: String) -> String:
	match uses:
		"mattock":
			return "Mattock"
		"tilte":
			return "Tilte scroll"
		"death":
			return "Death scroll"
	return String(ItemPickup.INFO[uses].title)


static func learn(id: String, p: Player) -> bool:
	if status(id) != "":
		return false
	GameState.data.skill_points = int(GameState.data.skill_points) - int(GameData.skill(id).cost)
	GameState.data.skills.append(id)
	if p != null:
		GameState.refresh_stats(p)
	return true


static func respec_cost() -> int:
	return mini(GameState.RESPEC_BASE * (int(GameState.data.respecs) + 1), GameState.RESPEC_MAX)


## Refunds every learned skill for gold. False if nothing is learned or gold is short.
static func respec(p: Player) -> bool:
	if GameState.data.skills.is_empty() or p.gold < respec_cost():
		return false
	p.gold -= respec_cost()
	var refund := 0
	for id: String in GameState.data.skills:
		# A node this build no longer has (an older save) refunds nothing,
		# rather than stopping the respec halfway with the gold already paid.
		refund += int(GameData.skill(id).get("cost", 0))
	GameState.data.skill_points = int(GameState.data.skill_points) + refund
	GameState.data.skills = []
	GameState.data.respecs = int(GameState.data.respecs) + 1
	GameState.refresh_stats(p)
	GameState.capture(p)
	return true
