SCRIPT_DIR="$(dirname "$0")"
srun --cpus-per-task=4 --mem=16G --gres=gpu:1 --time=04:00:00 --job-name="sdesktop" --pty ${SCRIPT_DIR}/sdesktop.sh
