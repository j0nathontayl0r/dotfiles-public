-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

-- VictorMono for text; MesloLGS NF as fallback so Powerlevel10k / Nerd glyphs
-- always resolve (P10k is designed around MesloLGS NF).
config.font = wezterm.font_with_fallback({
  "VictorMono Nerd Font Mono",
  "MesloLGS Nerd Font",
})
config.font_size = 13

config.enable_tab_bar = true

-- Kitty keyboard protocol: lets Claude Code (and other TUIs) distinguish
-- Shift+Enter from Enter, including over SSH to a remote Claude Code. Off by
-- default in WezTerm. Open a NEW window after changing (negotiates at startup).
config.enable_kitty_keyboard = true

-- Also bind Shift+Enter to send the CSI-u newline (ESC[13;2u) explicitly, so it
-- works even when kitty-protocol negotiation doesn't complete across an SSH hop
-- to a remote Claude Code. utf8.char(0x1b) is the ESC byte.
config.keys = {
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString(utf8.char(0x1b) .. '[13;2u') },
}

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.85
config.macos_window_background_blur = 10

-- For example, changing the color scheme:
config.color_scheme = 'AdventureTime'

-- and finally, return the configuration to wezterm
return config