#!/usr/bin/env bash
export ENABLE_LAYER_MESA_ANTI_LAG=1
export vblank_mode=0

# old version patches (if running as non-steam game)
export STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/322170" # forces compatdata path to where real gd puts it
export SteamAppId=322170 # stops force exits based on app id

# Wayland
if [ $XDG_SESSION_TYPE == "wayland" ]; then
	export PROTON_ENABLE_WAYLAND=1
	export SDL_VIDEO_DRIVER=wayland
	export SDL_VIDEODRIVER=wayland
fi

# Proton
export PROTON_USE_NTSYNC=1
export WINEDLLOVERRIDES="xinput1_4=n,b"

# Proton 11 fix
LIBEVDEV=$(ldconfig -p | awk '/libevdev\.so/{print $NF; exit}')
if [[ -n "$LIBEVDEV" ]]; then
	export LD_PRELOAD="${LD_PRELOAD:+$LD_PRELOAD:}$LIBEVDEV" #append
else
	mkdir ~/gd-low-linux-latency-logs
	echo "No libevdev file found, you should install libevdev" >> ~/gd-low-linux-latency-logs/log.txt
fi

# Launch the game
exec "$@"
