-- TODO: convert to return inline dictionary: see https://github.com/miki725/.dotfiles/blob/fe507b4d7e42b2c425020f611d477b5c56d0e106/.config/wezterm/wezterm.lua#L21
local wezterm = require("wezterm")
local commands = require("commands")
local config = wezterm.config_builder()

-- History
config.scrollback_lines = 1000000

-- Font settings
config.font_size = 12
config.line_height = 1
-- config.font = wezterm.font("Hack Nerd Font", { weight = "Regular" })
-- config.font = wezterm.font_with_fallback({ "Hack Nerd Font", "Menlo" })
-- config.font_rules = {
-- 	{
-- 		italic = true,
-- 		font = wezterm.font_with_fallback({ "Hack Nerd Font", "Menlo" }, { italic = true }),
-- 	},
-- 	{
-- 		italic = true,
-- 		intensity = "Bold",
-- 		font = wezterm.font_with_fallback({ "Hack Nerd Font", "Menlo" }, { bold = true, italic = true }),
-- 	},
-- 	{
-- 		intensity = "Bold",
-- 		font = wezterm.font_with_fallback({ "Hack Nerd Font", "Menlo" }, { bold = true }),
-- 	},
-- }

-- Colors
config.color_scheme = "Catppuccin Mocha"

-- Appearance
-- config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

local act = wezterm.action

config.keys = {
	-- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
	{
		key = "LeftArrow",
		mods = "OPT",
		action = act.SendKey({
			key = "b",
			mods = "ALT",
		}),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = act.SendKey({ key = "f", mods = "ALT" }),
	},
}

-- Rendering
config.max_fps = 120
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
-- config.prefer_egl = true  -- deprecated, replaced by WebGpu frontend

-- Transparency settings (default to transparent)
config.window_background_opacity = 1.0
config.text_background_opacity = 1.0

-- Custom Commands
config.macos_window_background_blur = 40
wezterm.on("augment-command-palette", function()
	return commands
end)

return config
