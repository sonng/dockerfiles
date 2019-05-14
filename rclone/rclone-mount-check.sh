#!/bin/bash
# 1. Change paths
# 2. for mount and log file & create mountchek file.
# 3. Add to crontab -e (paste the line bellow, without # in front)
# * * * * *  /home/plex/scripts/rclone-mount-check.sh >/dev/null 2>&1
# Make script executable with: chmod a+x /home/plex/scripts/rclone-mount-check.sh

LOGFILE="/logs/rclone-mount-check.log"
RCLONEREMOTE="gcrypt:"
MPOINT="/drive"
CHECKFILE="mountcheck"

if pidof -o %PPID -x "$0"; then
	echo "$(date "+%d.%m.%Y %T") EXIT: Already running." | tee -a "$LOGFILE"
	exit 1
fi

if [ -f "$MPOINT/$CHECKFILE" ]; then
	echo "$(date "+%d.%m.%Y %T") INFO: Check successful, $MPOINT mounted." | tee -a "$LOGFILE"
	exit
else
	echo "$(date "+%d.%m.%Y %T") ERROR: $MPOINT not mounted, remount in progress. $MPOINT/$CHECKFILE" | tee -a "$LOGFILE"
	# Unmount before remounting
	while mount | grep "on ${MPOINT} type" > /dev/null
	do
		echo "($wi) Unmounting $mount"
		fusermount -uz $MPOINT | tee -a "$LOGFILE"
		cu=$(($cu + 1))
		if [ "$cu" -ge 5 ];then
			echo "$(date "+%d.%m.%Y %T") ERROR: Folder could not be unmounted exit" | tee -a "$LOGFILE"
			exit 1
			break
		fi
		sleep 1
	done
	echo "$(pgrep -a 'rclone')"
	pgrep -a "rclone" | awk '{ print $1 }' | xargs kill
	sleep 1
	rclone mount \
		--allow-other \
		--allow-non-empty \
		--dir-cache-time=160h \
		--drive-chunk-size 256M \
		--cache-chunk-size 32M \
		--cache-chunk-total-size 20G \
		--cache-workers 5 \
		--cache-db-path=/cache \
		--cache-tmp-wait-time 60s \
		--uid 1000 \
		--gid 1000 \
		--umask 0 \
		--buffer-size 0M \
		--rc \
		--log-file=/logs/rclone.log \
		--log-level "INFO" \
		--config=/config/rclone.conf \
		$RCLONEREMOTE $MPOINT &

		while ! mount | grep "on ${MPOINT} type" > /dev/null
		do
			echo "($wi) Waiting for mount $mount"
			c=$(($c + 1))
			if [ "$c" -ge 4 ] ; then break ; fi
			sleep 1
		done
		if [ -f "$MPOINT/$CHECKFILE" ]; then
			echo "$(date "+%d.%m.%Y %T") INFO: Remount successful." | tee -a "$LOGFILE"
			echo "$(date "+%d.%m.%Y %T") INFO: Restarting services." | tee -a "$LOGFILE"
		else
			echo "$(date "+%d.%m.%Y %T") CRITICAL: Remount failed." | tee -a "$LOGFILE"
		fi
	fi
	exit
