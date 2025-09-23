#!/bin/bash
TEMP_VNC_PASSWD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
NEXT_ID=$((SLURM_JOB_ID % 100))
SCRIPT_DIR="$(dirname "$0")"

# Set VNC settings
VNC_PORT=$((5900 + NEXT_ID))
LISTEN_PORT=$((6080 + NEXT_ID))

echo "==============================================================="
echo "Your session is starting..."
echo "It may take up to 60 seconds for your desktop to be accessible."
echo "==============================================================="
echo "1. Navigate to:"
echo "   URL: http://$(hostname --long):${LISTEN_PORT}/vnc.html?password=${TEMP_VNC_PASSWD}"
echo "2. Click 'Connect'"
echo "3. Proffit"
echo "==============================================================="

module purge
module load apptainer/1.4.1

# Create .vnc if not exist
mkdir -p ~/.vnc

# Copy X Startup to ~
cp /apps/opt/sdesktop/0.0.1/xstartup ~/.vnc
chmod 700 ~/.vnc/xstartup

# Create vncpasswd
echo "${TEMP_VNC_PASSWD}" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

ARGS=""

if [ -z ${SLURM_GPUS_ON_NODE} ]; then
	ARGS="--nv --bind /dev/dri:/dev/dri"
fi
# The best way to do this will be to actually install slurm within the container
# Janky work around to weird bug where the script would only work correctly if it was ran from the bash CLI
echo "/opt/sdesktop/desktop.cpu.sh && /opt/novnc/noVNC-1.6.0/utils/novnc_proxy --listen [::]:${LISTEN_PORT} --vnc localhost:${VNC_PORT}" | apptainer exec ${ARGS} ${SCRIPT_DIR}/container/sdesktop.sif bash
#apptainer exec ${ARGS} ./container/sdesktop.sif bash "/opt/sdesktop/desktop.cpu.sh"
