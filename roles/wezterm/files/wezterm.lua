local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

-- local default_font_family = "DankMono Nerd Font"
local default_font_family = "Monaspace Neon"
local default_font_size = 16.0
local tab_text_color = "#f0f0f0"

config.color_scheme = "Catppuccin Mocha" -- or Macchiato, Frappe, Latte
config.font = wezterm.font(default_font_family)
config.font_size = default_font_size
config.scrollback_lines = 3500
config.show_new_tab_button_in_tab_bar = false

-- Enable all ligatures
config.harfbuzz_features = {
	"calt=1",
	"ss01=1",
	"ss02=1",
	"ss03=1",
	"ss04=1",
	"ss05=1",
	"ss06=1",
	"ss07=1",
	"ss08=1",
	"ss09=1",
	"liga=1",
}

config.window_frame = {
	inactive_titlebar_bg = "#353535",
	active_titlebar_bg = "#2b2042",
	inactive_titlebar_fg = "#cccccc",
	active_titlebar_fg = "#ffffff",
	inactive_titlebar_border_bottom = "#2b2042",
	active_titlebar_border_bottom = "#2b2042",
	button_fg = "#cccccc",
	button_bg = "#2b2042",
	button_hover_fg = "#ffffff",
	button_hover_bg = "#3b3052",
}

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, _max_width)
	-- Return the explicitly set title, if one has been set
	if tab.tab_title and #tab.tab_title > 0 then
		return tab.tab_title
	end

	local cwd_url = tab.active_pane.current_working_dir
	cwd_url = cwd_url.path or ""
	local basename = string.gsub(cwd_url, "(.*[/\\])(.*)", "%2")
	local zoomed = tab.active_pane.is_zoomed and "*" or ""
	local tab_title = basename .. zoomed

	local curr_tab_text_color = tab.is_active and tab_text_color or "#808080"
	-- local active_tab_attr = tab.is_active and "Bold" or "Normal"

	return {
		{ Foreground = { AnsiColor = "Navy" } },
		{ Text = (tab.tab_index + 1) .. " " },
		{ Foreground = { Color = curr_tab_text_color } },
		{ Text = tab_title },
	}
end)

-- Mappings
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1500 }
config.keys = {
	{ key = "a", mods = "LEADER|CTRL", action = wezterm.action({ SendString = "\x01" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "\\", mods = "LEADER", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = "s", mods = "LEADER", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "v", mods = "LEADER", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = "o", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "c", mods = "LEADER", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
	{ key = "j", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
	{ key = "k", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
	{ key = "l", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
	{ key = "H", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }) },
	{ key = "J", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }) },
	{ key = "K", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }) },
	{ key = "L", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }) },
	{ key = "1", mods = "LEADER", action = wezterm.action({ ActivateTab = 0 }) },
	{ key = "2", mods = "LEADER", action = wezterm.action({ ActivateTab = 1 }) },
	{ key = "3", mods = "LEADER", action = wezterm.action({ ActivateTab = 2 }) },
	{ key = "4", mods = "LEADER", action = wezterm.action({ ActivateTab = 3 }) },
	{ key = "5", mods = "LEADER", action = wezterm.action({ ActivateTab = 4 }) },
	{ key = "6", mods = "LEADER", action = wezterm.action({ ActivateTab = 5 }) },
	{ key = "7", mods = "LEADER", action = wezterm.action({ ActivateTab = 6 }) },
	{ key = "8", mods = "LEADER", action = wezterm.action({ ActivateTab = 7 }) },
	{ key = "9", mods = "LEADER", action = wezterm.action({ ActivateTab = 8 }) },
	{ key = "&", mods = "LEADER|SHIFT", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
	{ key = "d", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
	{ key = "x", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
	{
		key = "r",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Rename tab:",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{ key = "N", mods = "SHIFT|CMD", action = act.RotatePanes("Clockwise") },
	{ key = "P", mods = "SHIFT|CMD", action = act.RotatePanes("CounterClockwise") },
	{ key = "O", mods = "SHIFT|CMD", action = "ShowTabNavigator" },
	{ key = "[", mods = "LEADER", action = act.ActivateCopyMode },
	-- SHIFT-CMD-C :: opens wezterm debug overlay. used to test cfg changes
	{ key = "C", mods = "SHIFT|CMD", action = wezterm.action.ShowDebugOverlay },
}

return config
