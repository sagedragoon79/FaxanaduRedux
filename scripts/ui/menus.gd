class_name Menus
extends RefCounted
## Opens the shop, Guru and skill tree menus on the scene's ListMenu. Each
## returns false when there is no menu (tests, headless runs).

## How far from the Guru the Mantra Path sets you down, in pixels.
const MANTRA_STEP := 32.0


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
		for i in Shop.shelf(shop_id):
			var entry: Dictionary = shop.stock[i]
			var item := GameData.item(entry.item)
			var st := Shop.status(shop_id, i, p)
			var right := "%d g" % int(entry.price)
			if st == "owned":
				right = "Owned"
			elif st == "full":
				right = "Full"
			elif st == "sold out":
				right = "Sold out"
			elif st == "locked":
				right = "Needs I"
			elif st == "shards":
				right = "Needs shard"
			elif st == "worn":
				right = "Worn"
			elif item.kind == "dye" and GameState.owns_dye(String(entry.item)):
				right = "Wear"
			var detail: String = item.desc
			if item.kind == "key":
				detail += "  You have %d." % GameState.key_count(String(entry.item).trim_suffix("_key"))
			elif item.kind == "ointment":
				detail += "  You have %d." % p.ointments
			elif item.kind == "temper":
				var blade := String(GameState.data.equipment.blade)
				detail += "  Your %s: tempered %d of 2." % [GameData.item(blade).get("name", "blade"), GameState.temper_level(blade)]
				if Shop.shards(entry) > 0:
					detail += "  Costs a Meteor Shard too: you carry %d." % int(GameState.data.get("meteor_shards", 0))
			out.append({"label": item.name, "right": right, "detail": detail, "enabled": st == ""})
		return out
	var on_select := func(row: int) -> void:
		var i: int = Shop.shelf(shop_id)[row]
		var wearing: bool = GameData.item(shop.stock[i].item).kind == "dye" and GameState.owns_dye(String(shop.stock[i].item))
		var dye: bool = GameData.item(shop.stock[i].item).kind == "dye"
		if Shop.buy(shop_id, i, p):
			# A dye rustles on (pass 137); worn again for free, it costs no coin.
			if not wearing:
				Sfx.play("coin", 0.0, 2.0)
			if dye:
				Sfx.play("cloth", 0.0)
			GameState.toast.emit(("Wearing: " if wearing else "Bought: ") + String(GameData.item(shop.stock[i].item).name))
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
		var rows := [
			{"label": "Rest and save", "detail": "Restore health, magic and potions, and record your journey. " + rank_line},
			{"label": "Learn skills", "right": "%d pt" % pts, "detail": "Spend skill points. You earn them from ranks, bosses and Mantra Shards."},
			{"label": "Unlearn skills", "right": "%d g" % Skills.respec_cost(), "detail": "Forget every skill and get the points back, for a price that rises each time.",
				"enabled": not GameState.data.skills.is_empty() and p.gold >= Skills.respec_cost()},
			_mantra_row(tree),
			{"label": "Leave", "detail": "Walk in the light, wanderer."},
		]
		if _here(tree) == Trials.TEMPLE:
			rows.insert(4, _trials_row())
		return rows
	var on_select := func(i: int) -> void:
		if _here(tree) == Trials.TEMPLE and i >= 4:
			# The Guru Trials row sits before Leave in the temple.
			if i == 4:
				open_trials(tree, p)
				return
			i -= 1
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
				open_mantra_path(tree, p)
			4:
				menu.close()
	menu.open("Guru", greeting, provider, on_select, _gold_footer(p))
	return true


static func _trials_row() -> Dictionary:
	var row := {"label": "Guru Trials", "detail": "Walk a mantra made of nothing but footholds.",
		"enabled": Trials.springs_flowing() > 0 and not Trials.built().is_empty()}
	var done := 0
	for t: Dictionary in Trials.built():
		if Trials.cleared(t.id):
			done += 1
	row.right = "%d/%d" % [done, Trials.built().size()]
	if Trials.springs_flowing() == 0:
		row.detail = "The mantra-space is dry. Restore a spring and the Guru will open it."
	return row


## The Guru Trials (design bible 3.1): pick an open trial and the mantra carries
## you to its start; you come back here when it ends.
static func open_trials(tree: SceneTree, p: Player) -> bool:
	var menu := _menu(tree)
	var world := tree.get_first_node_in_group("world") as World
	if menu == null or world == null:
		return false
	var list := Trials.built()
	var provider := func() -> Array:
		var out := []
		for t: Dictionary in list:
			var row := {"label": String(t.name), "detail": String(t.desc), "enabled": Trials.is_open(t)}
			if not Trials.is_open(t):
				row.right = "Sealed"
				row.detail = "Restore %d springs to open it." % int(t.springs)
			elif Trials.cleared(t.id):
				row.right = Trials.format_time(Trials.best(t.id))
				row.detail += "  Best %s." % Trials.format_time(Trials.best(t.id))
			else:
				row.right = "Open"
				row.detail += "  Clear it for a Mantra Shard."
			out.append(row)
		return out
	var on_select := func(i: int) -> void:
		var t: Dictionary = list[i]
		if not Trials.is_open(t):
			return
		menu.close()
		start_trial(world, p, t)
	menu.open("Guru Trials", "The trial begins the moment you arrive. Hazards cost time, not health.", provider, on_select)
	return true


static func start_trial(world: World, p: Player, t: Dictionary) -> void:
	Trials.begin(t.id, world.room.id, p.global_position)
	Sfx.play("trial_begin", 0.0)
	GameState.flash.emit(0.2)
	world.travel(t.room, Trials.start_pos(world.room_text(t.room)))
	p.velocity = Vector2.ZERO


static func _here(tree: SceneTree) -> String:
	var world := tree.get_first_node_in_group("world") as World
	return world.room.id if world != null and world.room != null else ""


static func _mantra_row(tree: SceneTree) -> Dictionary:
	var row := {"label": "Mantra Path", "detail": "Walk the mantra to another Guru you have met.",
		"enabled": GameState.mantra_path_open() and not GameState.mantra_stops(_here(tree)).is_empty()}
	if not GameState.mantra_path_open():
		row.detail = "The path between Gurus is dry. Restore a spring to walk it."
	elif not row.enabled:
		row.detail = "You have met no other Guru yet."
	return row


## Guru-to-Guru travel (design bible 3.3). You arrive a step from the Guru.
static func open_mantra_path(tree: SceneTree, p: Player) -> bool:
	var menu := _menu(tree)
	var world := tree.get_first_node_in_group("world") as World
	if menu == null or world == null:
		return false
	var stops := GameState.mantra_stops(_here(tree))
	var provider := func() -> Array:
		var out := []
		for id: String in stops:
			var info: Dictionary = world.catalog.get(id, {})
			out.append({"label": String(info.get("name", id)), "right": String(info.get("zone", "")).capitalize(),
				"detail": "Close your eyes and speak the mantra."})
		return out
	var on_select := func(i: int) -> void:
		menu.close()
		var at: Array = GameState.data.gurus[stops[i]]
		Sfx.play("save", 0.0)
		GameState.flash.emit(0.2)
		world.travel(stops[i], Vector2(float(at[0]) + MANTRA_STEP, float(at[1])))
		p.velocity = Vector2.ZERO
	menu.open("Mantra Path", "Every Guru hears every other.", provider, on_select)
	return true


## The lift's stops: pick one and the cage carries you there.
static func open_lift(tree: SceneTree, p: Player, cage: LiftCage) -> bool:
	var menu := _menu(tree)
	if menu == null:
		return false
	var stops := cage.other_stops()
	var provider := func() -> Array:
		var out := []
		for stop: Array in stops:
			out.append({"label": String(stop[1]), "detail": "Haul the lever and ride the chain."})
		return out
	var on_select := func(i: int) -> void:
		menu.close()
		cage.ride(p, String(stops[i][0]))
	menu.open("Forepaw Lift", "The dwarves' chain runs the length of the trunk.", provider, on_select)
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


## The pause menu. `p` may be null (no game running). `on_quit` runs on Quit.
static func open_pause(tree: SceneTree, p: Player, on_quit: Callable) -> bool:
	var menu := _menu(tree)
	if menu == null:
		return false
	var provider := func() -> Array:
		var oint := {"label": "Use Ointment", "right": "x%d" % p.ointments,
			"detail": "Nothing can hurt you for %d seconds." % int(Player.OINTMENT_TIME),
			"enabled": p.ointments > 0 and p.ointment_left <= 0.0}
		if p.ointment_left > 0.0:
			oint.detail = "One is already on: %d seconds left." % ceili(p.ointment_left)
		elif p.ointments <= 0:
			oint.detail = "You carry none. The item shops in Eolis and Apolune sell them."
		return [
			{"label": "Resume", "detail": "Back to the Tree."},
			oint,
			{"label": "Options", "detail": "Screen shake, flashes, rumble, damage numbers, volume and game speed."},
			{"label": "Controls", "detail": "Rebind the keyboard."},
			{"label": "Quit game", "detail": "Anything since your last rest at a shrine is lost."},
		] + ([{"label": "Leave the trial", "detail": "Stop the clock and return to the Guru."}] if Trials.active() else [])
	var reopen := func() -> void: open_pause(tree, p, on_quit)
	var on_select := func(i: int) -> void:
		match i:
			0:
				menu.close()
			1:
				if p.use_ointment():
					menu.close()
			2:
				open_options(tree, reopen)
			3:
				open_controls(tree, reopen)
			4:
				menu.close()
				Trials.abandon()
				on_quit.call()
			5:
				menu.close()
				leave_trial(tree)
	menu.open("Paused", "%s. Rank %s." % [_room_title(tree), GameState.rank_name()], provider, on_select, _gold_footer(p))
	return true


static func leave_trial(tree: SceneTree) -> void:
	var world := tree.get_first_node_in_group("world") as World
	if not Trials.active() or world == null:
		return
	var back_room: String = Trials.run.back_room
	var back_pos: Vector2 = Trials.run.back_pos
	Trials.abandon()
	world.travel(back_room, back_pos)


static func _room_title(tree: SceneTree) -> String:
	var w := tree.get_first_node_in_group("world")
	return String(w.get("room").title) if w != null and w.get("room") != null else "The World Tree"


const OPTIONS := [
	["shake", "Screen shake", "How hard the screen shakes on hits and slams."],
	["flashes", "Screen flashes", "The white flash on boss kills and the Elixir."],
	["rumble", "Rumble", "Controller vibration."],
	["numbers", "Damage numbers", "Show the damage each blow deals, over what it strikes."],
	["music", "Music volume", ""],
	["sound", "Sound volume", ""],
	["speed", "Game speed", "Slow the whole game down if the action is too fast. Everything slows evenly."],
]


## Options. `back` reopens the menu this came from.
static func open_options(tree: SceneTree, back: Callable) -> bool:
	var menu := _menu(tree)
	if menu == null:
		return false
	var provider := func() -> Array:
		var out := []
		for o: Array in OPTIONS:
			out.append({"label": o[1], "right": Settings.value_text(o[0]), "detail": o[2] + ("  " if o[2] != "" else "") + "Left and Right change it."})
		out.append({"label": "Back", "detail": ""})
		return out
	var on_select := func(i: int) -> void:
		if i < OPTIONS.size():
			Settings.adjust(OPTIONS[i][0], 1)
		else:
			back.call()
	menu.open("Options", "Saved as you change them.", provider, on_select)
	menu.on_adjust = func(i: int, step: int) -> void:
		if i < OPTIONS.size():
			Settings.adjust(OPTIONS[i][0], step)
	menu.on_back = back
	return true


const ACTION_NAMES := {
	"move_left": "Move left", "move_right": "Move right", "move_up": "Look up / enter", "move_down": "Crouch / drop",
	"jump": "Jump", "attack": "Attack", "dash": "Dash", "block": "Block / parry", "spell": "Cast spell", "spell_next": "Next spell",
	"heal": "Drink potion", "hourglass": "Hour Glass", "map": "Map",
}


## Keyboard rebinding: choose an action, then press its new key.
static func open_controls(tree: SceneTree, back: Callable) -> bool:
	var menu := _menu(tree)
	if menu == null:
		return false
	var provider := func() -> Array:
		var out := []
		for action: String in Settings.REBINDABLE:
			var listening := menu.capture.is_valid() and menu.rows.size() > out.size() and menu.cursor == out.size()
			out.append({"label": ACTION_NAMES[action], "right": "..." if listening else Controls.key_name(action),
				"detail": "Jump to rebind, then press the new key. A key taken from another action swaps with it."})
		out.append({"label": "Reset to defaults", "detail": "Put every key back the way it was."})
		out.append({"label": "Back", "detail": "The gamepad layout stays as it is."})
		return out
	var on_select := func(i: int) -> void:
		var n := Settings.REBINDABLE.size()
		if i < n:
			menu.capture = func(event: InputEventKey) -> void:
				if event.physical_keycode == KEY_ESCAPE:
					return
				Settings.bind_key(Settings.REBINDABLE[i], int(event.physical_keycode))
				Sfx.play("blip", 0.0, -4.0)
		elif i == n:
			Settings.reset_keys()
			GameState.toast.emit("Keys reset.")
		else:
			back.call()
	menu.open("Controls", "Keyboard keys. Esc always pauses.", provider, on_select)
	menu.on_back = back
	return true
