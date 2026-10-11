-- Integration tests (https://github.com/BuckarooBanzay/mtt), run with fakelib's fake player.
-- Reproduce https://github.com/cultom/hammermod/issues/3 in every game they run in.

local stone = core.registered_nodes["mcl_core:stone"] and "mcl_core:stone" or "default:stone"
-- Real players in MineClone-like games always hold the game's hand item in the "hand" list
-- (VoxeLibre registers one per skin, late; any survival hand will do).
local function hand_item()
	for name, def in pairs(core.registered_items) do
		if name:find("^mcl_meshhand:") and def._mcl_diggroups and not name:find("crea") then
			return name
		end
	end
	return ""
end

local function count_drops(player, center)
	local total = 0
	for _, stack in ipairs(player:get_inventory():get_list("main")) do
		total = total + stack:get_count()
	end
	for _, obj in ipairs(core.get_objects_inside_radius(center, 4)) do
		local ent = obj:get_luaentity()
		if ent and ent.name == "__builtin:item" then
			total = total + ItemStack(ent.itemstring):get_count()
		end
	end
	return total
end

-- A fakelib player that has been through the game's join callbacks, so mods with per-player
-- state (e.g. doc, which reacts to every dig) know it. Callbacks that need a real client
-- (HUDs, protocol info) may fail on a fake player; that's fine here. Unlike mtt.join_player,
-- it isn't added to the connected players, so globalsteps don't touch it.
local joined
local function tester()
	if not joined then
		joined = fakelib.create_player({
			name = "hammer_tester",
			inventory = fakelib.create_inventory({ main = 36, hand = 1 }),
		})
		local get_player_by_name = core.get_player_by_name
		function core.get_player_by_name(name)
			if name == "hammer_tester" then
				return joined
			end
			return get_player_by_name(name)
		end
		for _, fn in ipairs(core.registered_on_joinplayers) do
			pcall(fn, joined, nil)
		end
	end
	return joined
end

-- Dig the centre of a 3x3 stone layer from above with `toolname`; return dug nodes and drops.
local function dig_layer(pos1, toolname)
	local center = vector.offset(pos1, 3, 2, 3)
	for x = -2, 2 do
		for z = -2, 2 do
			for y = -1, 1 do
				core.set_node(vector.offset(center, x, y, z), { name = stone })
			end
		end
	end
	for x = -2, 2 do
		for z = -2, 2 do
			core.set_node(vector.offset(center, x, 2, z), { name = "air" })
		end
	end
	-- A fake player that went through the game's join callbacks (inventory lists, hand item,
	-- per-player data of mods like doc), as a real player would.
	local player = tester()
	local inv = player:get_inventory()
	if inv:get_size("main") == 0 then
		inv:set_size("main", 36)
	end
	inv:set_list("main", {})
	inv:set_stack("main", 1, ItemStack(toolname))
	if inv:get_size("hand") > 0 and inv:get_stack("hand", 1):is_empty() then
		inv:set_stack("hand", 1, ItemStack(hand_item()))
	end
	player:set_pos(vector.offset(center, 0, 1.5, 0))
	player:set_look_horizontal(0)
	player:set_look_vertical(math.pi / 2)
	core.node_dig(center, core.get_node(center), player)
	player:get_inventory():set_stack("main", 1, ItemStack("")) -- don't count the hammer as a drop

	local dug = 0
	for x = -1, 1 do
		for z = -1, 1 do
			if core.get_node(vector.offset(center, x, 0, z)).name == "air" then
				dug = dug + 1
			end
		end
	end
	return dug, count_drops(player, center)
end

local area = { size = { x = 7, y = 6, z = 7 }, emerged = true }

-- MineClone-like games register enchanted variants ("<tool>_enchanted") after all mods loaded.
mtt.register_with_area("hammermod: enchanted hammer still digs 3x3", area, function(pos1, _, callback)
	if not core.registered_tools["hammermod:steel_hammer_enchanted"] then
		core.log("action", "[hammermod test] no enchanted variant in this game, skipped")
		return callback()
	end
	local dug, drops = dig_layer(pos1, "hammermod:steel_hammer_enchanted")
	core.log("action", ("[hammermod test] enchanted hammer: dug %d, dropped %d"):format(dug, drops))
	assert(dug == 9, "expected a 3x3 hole with the enchanted hammer, dug " .. dug .. " node(s)")
	assert(drops >= 9, "expected the 9 dug blocks to drop, got " .. drops .. " item(s)")
	callback()
end)

mtt.register_with_area("hammermod: digs 3x3 and drops the blocks", area, function(pos1, _, callback)
	local dug, drops = dig_layer(pos1, "hammermod:steel_hammer")
	core.log("action", ("[hammermod test] plain hammer: dug %d, dropped %d"):format(dug, drops))
	assert(dug == 9, "expected a 3x3 hole, dug " .. dug .. " node(s)")
	assert(drops >= 9, "expected the 9 dug blocks to drop, got " .. drops .. " item(s)")
	callback()
end)

mtt.register("hammermod: harvests like an iron tool in MineClone-like games", function(callback)
	if not core.get_modpath("_mcl_autogroup") then
		return callback()
	end
	assert(mcl_autogroup.can_harvest("mcl_core:stone", "hammermod:steel_hammer"), "stone must drop")
	assert(mcl_autogroup.can_harvest("mcl_core:stone_with_diamond", "hammermod:steel_hammer"), "diamond ore must drop")
	assert(not mcl_autogroup.can_harvest("mcl_core:obsidian", "hammermod:steel_hammer"), "obsidian needs diamond")
	local function dig_time(tool)
		local caps = ItemStack(tool):get_tool_capabilities()
		return core.get_dig_params(core.registered_nodes["mcl_core:stone"].groups, caps).time
	end
	local hammer, pick = dig_time("hammermod:steel_hammer"), dig_time("mcl_tools:pick_iron")
	core.log("action", ("[hammermod test] stone dig time: hammer %.2fs, iron pickaxe %.2fs"):format(hammer, pick))
	assert(math.abs(hammer - pick) < 0.01, "should dig stone as fast as an iron pickaxe")
	callback()
end)

mtt.register("hammermod: the recipe uses items the game has", function(callback)
	local recipe = core.get_craft_recipe("hammermod:steel_hammer")
	if not recipe.items then
		-- No xcompat, default or mcl_core: no materials known, so no recipe.
		assert(not (core.get_modpath("xcompat") or core.get_modpath("default") or core.get_modpath("mcl_core")),
			"expected a recipe for the hammer")
		return callback()
	end
	for _, item in pairs(recipe.items) do
		assert(core.registered_items[item], "recipe ingredient isn't registered: " .. item)
	end
	core.log("action", "[hammermod test] recipe: " .. table.concat(recipe.items, " ", 1, 3)
		.. (core.get_modpath("xcompat") and " (via xcompat)" or ""))
	callback()
end)
