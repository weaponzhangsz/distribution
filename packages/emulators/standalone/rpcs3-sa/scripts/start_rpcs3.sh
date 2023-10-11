#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present BrooksyTech (https://github.com/brooksytech)

. /etc/profile

# Check if rpcs3 exists in .config
if [ ! -d "/storage/.config/rpcs3" ]; then
  mkdir -p "/storage/.config/rpcs3"
  cp -r "/usr/config/rpcs3" "/storage/.config/"
fi

# Link rpcs3 dev_flash to bios folder
if [ ! -d "/storage/roms/bios/rpcs3/dev_flash" ]; then
  mkdir -p "/storage/bios/rpcs3/dev_flash"
fi
rm -rf /storage/.config/rpcs3/dev_flash
ln -sf /storage/roms/bios/rpcs3/dev_flash /storage/.config/rpcs3/dev_flash

# EmulationStation Features
GAME=$(echo "${1}" | sed "s#^/.*/##")
SUI=$(get_setting start_ui ps3 "${GAME}")

# Check if its a PSN game
GAME_PATH=""
if [[ "$GAME" == *.psn ]]; then
    while IFS= read -r line; do
        if [[ ${#line} -ge 9 ]]; then
            GAME_PATH="/storage/.config/rpcs3/dev_hdd0/game/$(echo "$line" | tr -d '\n\r' | tr '[:lower:]' '[:upper:]')/USRDIR/EBOOT.BIN"
        fi
    done < "$GAME"
else
    GAME_PATH="${GAME}/PS3_GAME/USRDIR/EBOOT.BIN"
fi

# Run rpcs3
if [ "$SUI" = "1" ]; then
  export QT_QPA_PLATFORM=wayland
  jslisten set "-9 rpcs3"
  /usr/bin/rpcs3
else
  export QT_QPA_PLATFORM=xcb
  export SDL_AUDIODRIVER=pulseaudio
  jslisten set "-9 rpcs3"
	/usr/bin/rpcs3 --no-gui "$GAME_PATH"
fi