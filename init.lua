minetest.register_tool("hammermod:steel_hammer", {
  description = "Steel Hammer",
  short_description = "Steel Hammer",
  -- hammermod_hammer marks every variant of the hammer, including the "<name>_enchanted"
  -- copy that MineClone2/VoxeLibre/Mineclonia enchanting registers (it copies the groups).
  groups={hard=1, metal=1, tool=1, pickaxe=1, dig_speed_class=4, enchantability=14, hammermod_hammer=1 },
  inventory_image="steel_hammer.png",
  range=8,
  liquids_pointable = false,
  light_source = 3,
  tool_capabilities = {
    full_punch_interval = 0.83333333,
    max_drop_level = 4,
    groupcaps = {
      choppy = {times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
      cracky={times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
      crumbly = {times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
      snappy = {times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
      oddly_breakable_by_hand = {times = {[1] = 1.00, [2] = 1.40, [3] = 1.00},uses = 111, maxlevel = 2},
    },
    damage_groups = {fleshy=1},

  },

  -- MineClone2/VoxeLibre/Mineclonia: dig groups like an iron tool. The games derive dig times
  -- from these, and only drop a dug block if the tool's level is high enough to harvest it.
  _mcl_toollike_wield = true,
  _mcl_diggroups = {
    pickaxey = { speed = 6, level = 4, uses = 111 },
    axey = { speed = 6, level = 4, uses = 111 },
    shovely = { speed = 6, level = 4, uses = 111 },
  },
})

local function is_hammer(itemstack)
  return minetest.get_item_group(itemstack:get_name(), "hammermod_hammer") > 0
end

local ingredients
if minetest.get_modpath("mcl_core") then
    ingredients = {
        stick     = "mcl_core:stick",
        ironBlock = "mcl_core:ironblock",
        ironIngot = "mcl_core:iron_ingot",
    }
elseif minetest.get_modpath("default") then
    ingredients = {
        stick     = "default:stick",
        ironBlock = "default:steelblock",
        ironIngot = "default:steel_ingot",
    }
end

if ingredients then
    minetest.register_craft({
        output = "hammermod:steel_hammer",
        recipe = {
            {ingredients.ironIngot, ingredients.ironBlock, ingredients.ironIngot},
            {"", ingredients.stick, ""},
            {"", ingredients.stick, ""},
        },
    })
end


local steelHammerDigs = {}

minetest.register_on_dignode(
  function(pos, oldnode, digger)
    if digger == nil or not is_hammer(digger:get_wielded_item()) then
      return
    end
    
    local playerName = digger:get_player_name()
    if(playerName == ""  or steelHammerDigs[playerName]) then
      return
    end
    steelHammerDigs[playerName] = true

    local posDiff = pos.y - digger:get_pos().y
    if(posDiff < 2 and posDiff > 1) then
      if
        digger:get_look_horizontal() > math.pi / 4 and digger:get_look_horizontal() < 3 * math.pi / 4 or
        digger:get_look_horizontal() > 5 * math.pi / 4 and digger:get_look_horizontal() < 7 * math.pi / 4
      then
        pos.y = pos.y -1
        pos.z = pos.z -1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.y = pos.y +1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.y = pos.y +1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.z = pos.z +1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.z = pos.z +1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.y = pos.y -1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.y = pos.y -1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.z = pos.z -1
        minetest.node_dig(pos, minetest.get_node(pos), digger)
      else
        pos.y = pos.y -1
        pos.x = pos.x -1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.y = pos.y +1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.y = pos.y +1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.x = pos.x +1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.x = pos.x +1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.y = pos.y -1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.y = pos.y -1
        minetest.node_dig(pos, minetest.get_node(pos), digger)

        pos.x = pos.x -1
        minetest.node_dig(pos, minetest.get_node(pos), digger)
      end
    else
      pos.x = pos.x -1
      pos.z = pos.z -1
      minetest.node_dig(pos, minetest.get_node(pos), digger)

      pos.x = pos.x +1
      minetest.node_dig(pos, minetest.get_node(pos), digger)

      pos.x = pos.x +1
      minetest.node_dig(pos, minetest.get_node(pos), digger)

      pos.z = pos.z +1
      minetest.node_dig(pos, minetest.get_node(pos), digger)

      pos.z = pos.z +1
      minetest.node_dig(pos, minetest.get_node(pos), digger)

      pos.x = pos.x -1
      minetest.node_dig(pos, minetest.get_node(pos), digger)

      pos.x = pos.x -1
      minetest.node_dig(pos, minetest.get_node(pos), digger)

      pos.z = pos.z -1
      minetest.node_dig(pos, minetest.get_node(pos), digger)

    end
    steelHammerDigs[playerName] = nil
  end
)

if minetest.get_modpath("mtt") and mtt.enabled and minetest.get_modpath("fakelib") then
	dofile(minetest.get_modpath("hammermod") .. "/test/mtt.lua")
end
