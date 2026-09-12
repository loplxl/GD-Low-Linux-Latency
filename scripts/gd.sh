#!/usr/bin/env bash

export ENABLE_LAYER_MESA_ANTI_LAG=1
export vblank_mode=0

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
export LD_PRELOAD=$(ldconfig -p | awk '/libevdev\.so/{print $NF; exit}')
if [[ -z "$LD_PRELOAD" ]]; then
	mkdir ~/gd-low-linux-latency-logs
	echo "No libevdev file found, you should install libevdev" >> ~/gd-low-linux-latency-logs/log.txt
fi
# Launch the game
exec "$@"
