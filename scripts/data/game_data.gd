class_name GameData
extends RefCounted
## Loads the balance tables in res://data/*.json (items, shops, skills, NPCs),
## so numbers and text can change without touching code.

static var _cache := {}


static func table(table_name: String) -> Dictionary:
	if not _cache.has(table_name):
		var res := load("res://data/%s.json" % table_name) as JSON
		assert(res != null and res.data is Dictionary, "Bad data table: " + table_name)
		_cache[table_name] = res.data
	return _cache[table_name]


static func item(id: String) -> Dictionary:
	return table("items").get(id, {})


## Every item id of one kind ("dye", "blade"...), in the table's order.
static func items_of_kind(kind: String) -> Array[String]:
	var out: Array[String] = []
	var items := table("items")
	for id: String in items:
		if String(items[id].get("kind", "")) == kind:
			out.append(id)
	return out


static func shop(id: String) -> Dictionary:
	return table("shops").get(id, {})


static func npc(id: String) -> Dictionary:
	return table("npcs").get(id, {})


static func skill(id: String) -> Dictionary:
	for node: Dictionary in table("skills").nodes:
		if node.id == id:
			return node
	return {}
