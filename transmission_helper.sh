#!/bin/bash

set -e

print_help() {
	echo "Usage: ./transmission_helper.sh <start | stop | attach> -d <destination directory> -t <torrent file>"
	echo "To detach from running session, press <Ctrl-b> then d"
}



case "$1" in
	start)
		echo "Starting transmission session...n"
		OPERATION=$1
		shift;;
	stop)
		echo "Stopping transmission session..."
		OPERATION=$1
		shift;;
	attach)
		echo "Attaching transmission session..."
		OPERATION=$1
		shift;;
	-h) print_help; exit 0;;
	*) echo "Invalid operation $1"; exit 1;;
esac


while getopts d:t:p:h flag
do
	case "${flag}" in
		d) DEST_DIR=${OPTARG};;
		t) TOR_FILE=${OPTARG};;
		p) PORT=${OPTARG};;
		h) print_help; exit 0;;
		\?) echo "Invalid option: -${OPTARG}" >&2;;
	esac
done

HASH=$(echo -n "${TOR_FILE}" | sha256sum)
SHORT_HASH=${HASH:0:7}
SESSION_NAME="transmission_${SHORT_HASH}"

# Set default port
if [[ ! -n "${PORT}" ]]; then
	PORT=51413
fi

case "$OPERATION" in
	start)
		if [[ ! -n "${DEST_DIR}" ]]; then
			echo "Missing destination directory path"
			exit 1
		fi

		if [[ ! -n "${TOR_FILE}" ]]; then
			echo "Missing torrent file path"
			exit 1
		fi

		echo "Destination directory set to: ${DEST_DIR}"
		echo "Torrent file path: ${TOR_FILE}"


		tmux new-session -d -s ${SESSION_NAME} "transmission-cli -w ${DEST_DIR} -p ${PORT} '${TOR_FILE}'"
		tmux attach-session -t ${SESSION_NAME}

		echo "Started session ${SESSION_NAME}"

		exit 0;;
	stop)
		if [[ ! -n "${TOR_FILE}" ]]; then
			echo "Missing torrent file path"
			exit 1
		fi

		tmux kill-session -t ${SESSION_NAME}

		echo "Ended session ${SESSION_NAME}"

		exit 0;;
	attach)
		if [[ ! -n "${TOR_FILE}" ]]; then
			echo "Missing torrent file path"
			exit 1
		fi

		tmux attach-session -t ${SESSION_NAME}

		echo "Attached session ${SESSION_NAME}"
		exit 0;;

esac


