#! /bin/sh
### BEGIN INIT INFO
# Provides:          graylog-radio
# Required-Start:    $network $named $remote_fs $syslog
# Required-Stop:     $network $named $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Graylog Radio
# Description:       Graylog Open Source syslog implementation that stores
#                    your logs in ElasticSearch
### END INIT INFO

# Author: Jonas Genannt <jonas.genannt@capi2name.de>
# Contributor: Bernd Ahlers <bernd@torch.sh>

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Graylog Radio"
NAME=graylog-radio
JAR_FILE=/usr/share/graylog-radio/graylog.jar
PIDDIR=/var/run/graylog-radio
PIDFILE=$PIDDIR/$NAME.pid
DAEMON_LOG_OPTION="-Dlog4j.configuration=file:///etc/graylog/radio/log4j.xml"
SCRIPTNAME=/etc/init.d/$NAME
GRAYLOG_USER=graylog-radio
RUN=yes

# Exit if the package is not installed
[ -e "$JAR_FILE" ] || exit 0

[ -r /etc/default/$NAME ] && . /etc/default/$NAME

DAEMON=${JAVA:=/usr/bin/java}
DAEMON_ARGS="$GRAYLOG_RADIO_JAVA_OPTS $DAEMON_LOG_OPTION -Djava.library.path=/usr/share/graylog-radio/lib/sigar -jar $JAR_FILE radio -p $PIDFILE -f /etc/graylog/radio/radio.conf $GRAYLOG_RADIO_ARGS"

[ -x "$DAEMON" ] || exit 0

DAEMON="$GRAYLOG_COMMAND_WRAPPER $DAEMON"

. /lib/init/vars.sh

. /lib/lsb/init-functions

running()
{
	[ ! -f "$PIDFILE" ] && return 1
	status="0"
	pidofproc -p $PIDFILE $JAR_FILE >/dev/null || status="$?"
	if [ "$status" = 0 ]; then
		return 0
	fi

	return 1
}

do_start()
{
	if [ "$RUN" != "yes" ] ; then
		log_progress_msg "(disabled)"
		log_end_msg 0

		exit 0
	fi
	if [ ! -e $PIDDIR ]; then
		mkdir $PIDDIR
		chown ${GRAYLOG_USER}:${GRAYLOG_USER} $PIDDIR
	fi
	if running ; then
		[ "$VERBOSE" != no ] && log_progress_msg "apparently already running"
		return 1
	else
		start-stop-daemon --start --quiet --oknodo --pidfile $PIDFILE \
			--user $GRAYLOG_USER --chuid $GRAYLOG_USER \
			--background --startas /bin/bash -- \
			-c "exec $DAEMON $DAEMON_ARGS >> /var/log/graylog-radio/console.log 2>&1"
		sleep 2
		if running ; then
			return 0
		else
			return 2
		fi
	fi
}

do_stop()
{
	start-stop-daemon --stop --quiet --oknodo --user $GRAYLOG_USER \
		--retry=TERM/60/KILL/5 --pidfile $PIDFILE
	rm -f $PIDFILE
	return "0"
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
       status_of_proc -p "${PIDFILE}" "$DAEMON" "$NAME" && exit 0 || exit $?
       ;;
  restart|force-reload)
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
		# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac

:
