# Chooser for xdg-desktop-portal-wlr (chooser_type = simple).
#
# Shows a wofi menu with one "Full screen" entry per active output and one
# entry per window, then prints the choice in the form the portal expects
# ("Monitor: <output>" or "Window: <identifier>"). Printing nothing declines
# the screen share. Sharing a single window requires a compositor with
# toplevel capture (sway 1.12 or newer), so windows are only listed when the
# compositor advertises it.

labels=()
values=()

while IFS= read -r output; do
  labels+=("Full screen ($output)")
  values+=("Monitor: $output")
done < <(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name')

if wayland-info 2>/dev/null | grep -q ext_foreign_toplevel_image_capture_source_manager_v1; then
  while IFS=$'\t' read -r identifier app title; do
    labels+=("Window: [$app] $title")
    values+=("Window: $identifier")
  done < <(lswt -j | jq -r '.toplevels[] | [.identifier, (."app-id" // "?"), (.title // "")] | @tsv')
fi

# Number the entries so that two windows with the same title stay distinct.
menu=""
for i in "${!labels[@]}"; do
  menu+="$((i + 1))  ${labels[$i]}"$'\n'
done

choice=$(printf '%s' "$menu" | wofi --dmenu --insensitive --prompt "Share which screen or window?") || exit 0
index=${choice%% *}
case "$index" in
  '' | *[!0-9]*) exit 0 ;;
esac
if [ "$index" -ge 1 ] && [ "$index" -le "${#values[@]}" ]; then
  printf '%s\n' "${values[$((index - 1))]}"
fi
