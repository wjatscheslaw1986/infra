#!/bin/bash

set -e
set -x

# check a user is root
if [ "$(id -u)" != 0 ]; then
  echo Please, run the script as root: \"sudo ./snd.sh\"
  exit 1
fi

apt install -y alsa-utils alsa-tools

touch /etc/asound.conf

cat > /etc/asound.conf <<EOF
pcm.!default{
type hw
card SB
}
ctl.!default{
type hw
card SB
}
EOF

chmod 755 /dev/dsp*
chmod 755 /dev/audio*
chmod 755 /dev/mixer*
chmod 777 /dev/snd/*
