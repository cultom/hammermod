unused_args = false
max_line_length = false
-- Whitespace style of the existing code.
ignore = { "61[1-4]" }

globals = {
	"core", "minetest", -- test/mtt.lua overrides core.get_player_by_name for its fake player
}

read_globals = {
	"vector", "ItemStack",
	-- optional dependencies
	"xcompat", "mtt", "fakelib", "mcl_autogroup",
}
