#! /bin/sh
### BEGIN INIT INFO
# Provides:          graylog-server
# Required-Start:    $network $named $remote_fs
# Required-Stop:     $network $named $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts Graylog
# Description:       Starts Graylog using start-stop-daemon
### END INIT INFO

# Author: Jonas Genannt <jonas.genannt@capi2name.de>
# Contributor: Bernd Ahlers <bernd@graylog.com>

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Graylog Server"
NAME=graylog-server

JAR_FILE=/usr/share/graylog-server/graylog.jar
PIDDIR=/var/run/graylog
PIDFILE=$PIDDIR/$NAME.pid
DAEMON_LOG_OPTION="-Dlog4j.configurationFile=file:///etc/graylog/server/log4j2.xml"
SCRIPTNAME=/etc/init.d/$NAME
GRAYLOG_USER=graylog

if [ `id -u` -ne 0 ]; then
	echo "Superuser privileges required to run this script!"
	exit 1
fi

. /lib/init/vars.sh
. /lib/lsb/init-functions

[ -r /etc/default/$NAME ] && . /etc/default/$NAME

if [ -f "/usr/share/graylog-server/installation-source.sh" ]; then
    . "/usr/share/graylog-server/installation-source.sh"
fi

DAEMON=${JAVA:=/usr/bin/java}

[ -x "$DAEMON" ] || exit 0

# Java versions > 8 don't support UseParNewGC
if "$DAEMON" -XX:+PrintFlagsFinal 2>&1 | grep -q UseParNewGC; then
	GRAYLOG_SERVER_JAVA_OPTS="$GRAYLOG_SERVER_JAVA_OPTS -XX:+UseParNewGC"
fi

# Java versions >= 15 don't support CMS Garbage Collector
if "$DAEMON" -XX:+PrintFlagsFinal 2>&1 | grep -q UseConcMarkSweepGC; then
	GRAYLOG_SERVER_JAVA_OPTS="$GRAYLOG_SERVER_JAVA_OPTS -XX:+UseConcMarkSweepGC -XX:+CMSConcurrentMTEnabled -XX:+CMSClassUnloadingEnabled"
fi

DAEMON_ARGS="$GRAYLOG_SERVER_JAVA_OPTS $DAEMON_LOG_OPTION -Dgraylog2.installation_source=${GRAYLOG_INSTALLATION_SOURCE:=unknown} -Djava.library.path=/usr/share/graylog-server/lib/sigar -jar $JAR_FILE server -p $PIDFILE -f /etc/graylog/server/server.conf $GRAYLOG_SERVER_ARGS"

DAEMON="$GRAYLOG_COMMAND_WRAPPER $DAEMON"


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

await_running()
{
	local count=0

	# Wait max 30s until process has started.
	while ! running ; do
		count=$(($count + 1))

		if [ $count -ge 30 ]; then
			break
		fi

		sleep 1
	done
}

do_start()
{
	if [ ! -e $PIDDIR ]; then
		mkdir $PIDDIR
		chown ${GRAYLOG_USER}:${GRAYLOG_USER} $PIDDIR
	fi
	if running ; then
		[ "$VERBOSE" != no ] && log_progress_msg "apparently already running"
		return 1
	else
		ulimit -n 64000
		start-stop-daemon --start --quiet --oknodo --pidfile $PIDFILE \
			--user $GRAYLOG_USER --chuid $GRAYLOG_USER \
			--background --startas /bin/bash -- \
			-c "exec $DAEMON $DAEMON_ARGS >> /var/log/graylog-server/console.log 2>&1"
		await_running
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
