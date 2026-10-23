class_name Shop
extends RefCounted
## Buying from a shop (data/shops.json). Pure logic, so the menu and the tests
## share it.

## Elixirs you can carry at once (design bible 10.2).
const ELIXIR_MAX := 1
## Ointments you can carry at once.
const OINTMENT_MAX := 3


## Why an entry can't be bought right now: "" (it can), "owned", "full", "sold out",
## "locked" (a second temper before the first) or "gold".
static func status(shop_id: String, index: int, p: Player) -> String:
	var entry: Dictionary = GameData.shop(shop_id).stock[index]
	var item := GameData.item(entry.item)
	if entry.get("once", false) and GameState.is_collected(_once_id(shop_id, index)):
		return "sold out"
	match item.kind:
		"blade", "armor", "shield":
			var current := GameData.item(GameState.data.equipment[item.kind])
			if not current.is_empty() and int(current.get("tier", 0)) >= int(item.get("tier", 0)):
				return "owned"
		"elixir":
			if p.elixirs >= ELIXIR_MAX:
				return "owned"
		"ointment":
			if p.ointments >= OINTMENT_MAX:
				return "full"
		"temper":
			var level := GameState.temper_level(String(GameState.data.equipment.blade))
			if level >= int(item.level):
				return "owned"
			if level < int(item.level) - 1:
				return "locked"
		"chart":
			if GameState.has_chart(String(item.zone)):
				return "owned"
	if p.gold < int(entry.price):
		return "gold"
	return ""


static func buy(shop_id: String, index: int, p: Player) -> bool:
	if status(shop_id, index, p) != "":
		return false
	var entry: Dictionary = GameData.shop(shop_id).stock[index]
	var item := GameData.item(entry.item)
	p.gold -= int(entry.price)
	match item.kind:
		"blade", "armor", "shield":
			GameState.data.equipment[item.kind] = entry.item
			GameState.refresh_stats(p)
		"key":
			GameState.add_key(String(entry.item).trim_suffix("_key"))
		"stat":
			GameState.grant_stat_item(entry.item, p)
		"elixir":
			p.elixirs += 1
		"ointment":
			p.ointments += 1
		"temper":
			var tempers: Dictionary = GameState.data.get("tempers", {})
			tempers[String(GameState.data.equipment.blade)] = int(item.level)
			GameState.data.tempers = tempers
			GameState.refresh_stats(p)
		"chart":
			GameState.data.charts[String(item.zone)] = true
	if entry.get("once", false):
		GameState.collect(_once_id(shop_id, index))
	GameState.capture(p)
	return true


static func _once_id(shop_id: String, index: int) -> String:
	return "shop:%s:%d" % [shop_id, index]
