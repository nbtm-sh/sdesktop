#!/bin/bash
set -x

# Set NVIDIA options
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export LIBGL_ALWAYS_INDIRECT=0

# Get VNC Display ID
# This will only allow a max of 100 display sessions at once before we start running into potential issues
NEXT_ID=$((SLURM_JOB_ID % 100))

# Set VNC settings
export DISPLAY=:${NEXT_ID}
VNC_PORT=$((5900 + NEXT_ID))

# Create XDG runtime environment
USER_ID=$(whoami)
export XDG_RUNTIME_DIR="/tmp/runtime-${SLURM_JOB_ID}-${USER_ID}"
export XAUTHORITY="/tmp/runtime-${SLURM_JOB_ID}-${USER_ID}/Xauthority"
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR
touch $XAUTHORITY
chmod 600 $XAUTHORITY

# Disable systemd integration
unset XDG_SESSION_ID
unset XDG_SESSION_TYPE
export DESKTOP_SESSION=""
export GDMSESSION=""

# Set up VNC directory
VNC_DIR="${HOME}/.vnc"

# Start VNC Server
vncserver ${DISPLAY} -geometry 1920x1080 -depth 24 -localhost no & VNC_PID=$!
#Xvnc :2 \
#	-geometry 1920x1080 \
#	-depth 24 \
#	-rfbport $VNC_PORT \
#	-rfbauth "$VNC_DIR/passwd" \
#	-config "$VNC_DIR/xorg.conf.nvidia" \
#	-SecurityTypes VncAuth &
wait ${VNC_PID}
