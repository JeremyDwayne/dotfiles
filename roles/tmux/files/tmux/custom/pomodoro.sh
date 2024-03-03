show_pomodoro() {
	local index=$1
	local icon=$(get_tmux_option "@catppuccin_pomodoro_icon" "")
	local color=$(get_tmux_option "@catppuccin_pomodoro_color" "$thm_red")
	local text=$(get_tmux_option "@catppuccin_pomodoro_text" "#{pomodoro_status}")

	local module=$(build_status_module "$index" "$icon" "$color" "$text")

	echo "$module"
}
