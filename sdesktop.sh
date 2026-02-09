#!/bin/bash
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --gres=gpu:0
#SBATCH --time=04:00:00
#SBATCH --job-name="sdesktop"

set -x

TEMP_VNC_PASSWD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
NEXT_ID=$((SLURM_JOB_ID % 100))
SD_SCRIPT_DIR="$(dirname "$0")"

rm -rf /tmp/.X${NEXT_ID}-lock
rm -rf /tmp/.X11-unix/X${NEXT_ID}

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

CERT_PATH="${HOME}/.config/kagemori/.tmp/job-${SLURM_JOB_ID}/cert/cert.pem"
KEY_PATH="${HOME}/.config/kagemori/.tmp/job-${SLURM_JOB_ID}/cert/key.pem"

if [ ! -f ~/.config/.sdesktop-preconfigured ]; then
	echo "Configuring desktop for first use..."

	# Copy launcher files for desktop
	mkdir -p ~/Desktop
	cp /apps/opt/script/desktop/preconf/launcher/desktop/*.desktop ~/Desktop
	chmod u+x ~/Desktop/*.desktop

	# Copy launcher files for applications menu
	mkdir -p ~/.local/share/applications
	cp /apps/opt/script/desktop/preconf/launcher/applications/*.desktop ~/.local/share/applications

	# Copy configuration files for xfwm4
	mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
	cp /apps/opt/script/desktop/preconf/config/xfce4/*.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/

	# Copy configurations for Thunar
	mkdir -p ~/.config/Thunar/
	cp /apps/opt/script/desktop/preconf/config/Thunar/*.xml ~/.config/Thunar

	touch ~/.config/.sdesktop-preconfigured
fi

# Create .vnc if not exist
mkdir -p ~/.vnc

# Copy X Startup to ~
if [ ! -f ~/.vnc/xstartup ]; then
	cp /apps/opt/sdesktop/0.0.1/xstartup ~/.vnc
fi
chmod 700 ~/.vnc/xstartup

# Create vncpasswd
echo "${TEMP_VNC_PASSWD}" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

ARGS=""

if [ -z ${SLURM_GPUS_ON_NODE} ]; then
	ARGS="--nv --bind /dev/dri:/dev/dri"
fi

# Bind mounts
ARGS+=" --bind /apps:/apps --bind /data:/data --bind /programs:/programs"
ARGS+=" --bind /etc/slurm:/etc/slurm"
ARGS+=" --bind /run/munge:/run/munge"
ARGS+=" --bind /var/run/slurm:/var/run/slurm"
ARGS+=" --bind ${TMPDIR}:/tmp"

# The best way to do this will be to actually install slurm within the container
# Janky work around to weird bug where the script would only work correctly if it was ran from the bash CLI
cat > $KAGE_JOB_CONFIG << EOF
{
	"job_id": "$SLURM_JOB_ID",
	"job_node": "$(hostname --long):${LISTEN_PORT}",
	"job_url": "/vnc.html?password=${TEMP_VNC_PASSWD}"
}
EOF

## Wait for the certificate to be generated
#while : ; do
#	if [ -f ${CERT_PATH} ]; then
#		break
#	else
#		echo "Cert is not yet present"
#	fi
#	sleep 1
#done

# Sleep to avoid race condition while certificates are generated
sleep 3

echo "/opt/sdesktop/desktop.cpu.sh && /opt/novnc/noVNC-1.6.0/utils/novnc_proxy --listen [::]:${LISTEN_PORT} --vnc localhost:${VNC_PORT} --cert ${KAGE_SSL_CERT} --key ${KAGE_SSL_KEY}" | apptainer exec ${ARGS} /apps/opt/sdesktop/default/container/sdesktop.sif bash
#apptainer exec ${ARGS} ./container/sdesktop.sif bash "/opt/sdesktop/desktop.cpu.sh"
