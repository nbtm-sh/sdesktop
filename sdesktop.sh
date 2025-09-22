#!/bin/bash
TEMP_VNC_PASSWD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
echo Password: ${TEMP_VNC_PASSWD}

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
echo "/opt/sdesktop/desktop.cpu.sh && sleep infinity" | apptainer exec ${ARGS} ./container/sdesktop.sif bash 
#apptainer exec ${ARGS} ./container/sdesktop.sif bash "/opt/sdesktop/desktop.cpu.sh"
