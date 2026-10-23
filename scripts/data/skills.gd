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
		refund += int(GameData.skill(id).cost)
	GameState.data.skill_points = int(GameState.data.skill_points) + refund
	GameState.data.skills = []
	GameState.data.respecs = int(GameState.data.respecs) + 1
	GameState.refresh_stats(p)
	GameState.capture(p)
	return true
