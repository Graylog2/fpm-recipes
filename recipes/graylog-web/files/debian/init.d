#! /bin/sh
### BEGIN INIT INFO
# Provides:          graylog-web
# Required-Start:    $network $named $remote_fs $syslog
# Required-Stop:     $network $named $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Graylog Web Interface
# Description:       Graylog Open Source syslog implementation that stores
#                    your logs in ElasticSearch
### END INIT INFO

# Author: Jonas Genannt <jonas.genannt@capi2name.de>
# Contributor: Bernd Ahlers <bernd@graylog.com>

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Graylog Web Interface"
NAME=graylog-web
DAEMON=/usr/share/graylog-web/bin/graylog-web-interface
PIDFILE=/var/run/graylog-web/application.pid
SCRIPTNAME=/etc/init.d/$NAME
RUN=yes
GRAYLOG_WEB_HTTP_ADDRESS="0.0.0.0"
GRAYLOG_WEB_HTTP_PORT="9000"

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

[ -r /etc/default/$NAME ] && . /etc/default/$NAME

. /lib/init/vars.sh

. /lib/lsb/init-functions

JAVA_OPTS="-Dconfig.file=/etc/graylog/web/web.conf"
JAVA_OPTS="$JAVA_OPTS -Dlogger.file=/etc/graylog/web/logback.xml"
JAVA_OPTS="$JAVA_OPTS -Dpidfile.path=$PIDFILE"
JAVA_OPTS="$JAVA_OPTS -Dhttp.address=$GRAYLOG_WEB_HTTP_ADDRESS"
JAVA_OPTS="$JAVA_OPTS -Dhttp.port=$GRAYLOG_WEB_HTTP_PORT"

DAEMON="$GRAYLOG_COMMAND_WRAPPER $DAEMON"


running()
{
	[ ! -f "$PIDFILE" ] && return 1
	status="0"
	pidofproc -p $PIDFILE "play.core.server.NettyServer" >/dev/null || status="$?"
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
	if [ "$RUN" != "yes" ] ; then
		log_progress_msg "(disabled)"
		log_end_msg 0

		exit 0
	fi
	test -e /var/run/graylog-web || mkdir /var/run/graylog-web ; chown graylog-web:graylog-web /var/run/graylog-web
	if running ; then
		log_progress_msg "apparently already running"
		return 1
	else
		touch /var/log/graylog-web/console.log
		chown graylog-web:graylog-web /var/log/graylog-web/console.log

		export JAVA_OPTS="$JAVA_OPTS $GRAYLOG_WEB_JAVA_OPTS"
		start-stop-daemon --start --quiet --oknodo --pidfile $PIDFILE \
			--user graylog-web --chuid graylog-web \
			--background --startas /bin/bash -- \
			-c "exec $DAEMON $GRAYLOG_WEB_ARGS >> /var/log/graylog-web/console.log 2>&1"
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
	start-stop-daemon --stop --quiet --oknodo --user graylog-web \
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
