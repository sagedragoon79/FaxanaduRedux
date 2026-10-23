class_name Menus
extends RefCounted
## Opens the shop, Guru and skill tree menus on the scene's ListMenu. Each
## returns false when there is no menu (tests, headless runs).

static func _menu(tree: SceneTree) -> ListMenu:
	return tree.get_first_node_in_group("list_menu") as ListMenu


static func _gold_footer(p: Player) -> Callable:
	return func() -> String: return "Gold %d" % p.gold


static func open_shop(tree: SceneTree, shop_id: String, p: Player) -> bool:
	var menu := _menu(tree)
	if menu == null:
		return false
	var shop := GameData.shop(shop_id)
	var provider := func() -> Array:
		var out := []
		for i in shop.stock.size():
			var entry: Dictionary = shop.stock[i]
			var item := GameData.item(entry.item)
			var st := Shop.status(shop_id, i, p)
			var right := "%d g" % int(entry.price)
			if st == "owned":
				right = "Owned"
			elif st == "sold out":
				right = "Sold out"
			var detail: String = item.desc
			if item.kind == "key":
				detail += "  You have %d." % GameState.key_count(String(entry.item).trim_suffix("_key"))
			out.append({"label": item.name, "right": right, "detail": detail, "enabled": st == ""})
		return out
	var on_select := func(i: int) -> void:
		if Shop.buy(shop_id, i, p):
			Sfx.play("coin", 0.0, 2.0)
			GameState.toast.emit("Bought: " + String(GameData.item(shop.stock[i].item).name))
	menu.open(shop.name, shop.greeting, provider, on_select, _gold_footer(p))
	return true


static func open_guru(tree: SceneTree, greeting: String, p: Player, shrine: Node2D) -> bool:
	var menu := _menu(tree)
	if menu == null:
		return false
	var provider := func() -> Array:
		var pts := int(GameState.data.skill_points)
		var rank_line := "Rank: %s. XP %d" % [GameState.rank_name(), int(GameState.data.xp)]
		if GameState.next_rank_xp() > 0:
			rank_line += " of %d for the next rank." % GameState.next_rank_xp()
		return [
			{"label": "Rest and save", "detail": "Restore health, magic and potions, and record your journey. " + rank_line},
			{"label": "Learn skills", "right": "%d pt" % pts, "detail": "Spend skill points. You earn them from ranks, bosses and Mantra Shards."},
			{"label": "Unlearn skills", "right": "%d g" % Skills.respec_cost(), "detail": "Forget every skill and get the points back, for a price that rises each time.",
				"enabled": not GameState.data.skills.is_empty() and p.gold >= Skills.respec_cost()},
			{"label": "Leave", "detail": "Walk in the light, wanderer."},
		]
	var on_select := func(i: int) -> void:
		match i:
			0:
				menu.close()
				if shrine != null and shrine.has_method("rest"):
					shrine.call("rest", p)
			1:
				menu.close()
				open_skills(tree, p)
			2:
				if Skills.respec(p):
					Sfx.play("heal", 0.0)
					GameState.toast.emit("Skills forgotten. Points returned.")
			3:
				menu.close()
	menu.open("Guru", greeting, provider, on_select, _gold_footer(p))
	return true


static func open_skills(tree: SceneTree, p: Player) -> bool:
	var menu := _menu(tree)
	if menu == null:
		return false
	var ids: Array[String] = []
	var provider := func() -> Array:
		var out := []
		ids.clear()
		var branch := ""
		for node: Dictionary in Skills.nodes():
			if node.branch != branch:
				branch = node.branch
				out.append({"label": branch, "header": true})
				ids.append("")
			var st := Skills.status(node.id)
			var right := "%d pt" % int(node.cost)
			if st == "learned":
				right = "Learned"
			var detail: String = node.desc
			if st == "locked":
				detail += "  Needs " + String(GameData.skill(node.needs).name) + " first."
			out.append({"label": node.name, "right": right, "detail": detail, "enabled": st == ""})
			ids.append(node.id)
		return out
	var on_select := func(i: int) -> void:
		if Skills.learn(ids[i], p):
			Sfx.play("rank", 0.0)
			GameState.toast.emit("Learned: " + String(GameData.skill(ids[i]).name))
	var footer := func() -> String: return "Skill points %d" % int(GameState.data.skill_points)
	menu.open("Skills", "Each branch deepens in order. Choose well: points are scarce.", provider, on_select, footer)
	return true
