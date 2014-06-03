#! /bin/sh
### BEGIN INIT INFO
# Provides:          graylog2-web
# Required-Start:    $network $named $remote_fs $syslog
# Required-Stop:     $network $named $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Graylog2 Web Interface
# Description:       Graylog2 Open Source syslog implementation that stores
#                    your logs in ElasticSearch
### END INIT INFO

# Author: Jonas Genannt <jonas.genannt@capi2name.de>
# Contributor: Bernd Ahlers <bernd@torch.sh>

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Graylog2 Web Interface"
NAME=graylog2-web
DAEMON=/usr/share/graylog2-web/bin/graylog2-web-interface
PIDFILE=/var/run/graylog2-web/application.pid
SCRIPTNAME=/etc/init.d/$NAME
RUN=yes
GRAYLOG2_WEB_HTTP_ADDRESS="0.0.0.0"
GRAYLOG2_WEB_HTTP_PORT="9000"

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

[ -r /etc/default/$NAME ] && . /etc/default/$NAME

. /lib/init/vars.sh

. /lib/lsb/init-functions

DAEMON_ARGS="-Dconfig.file=/etc/graylog2/web/graylog2-web-interface.conf"
DAEMON_ARGS="$DAEMON_ARGS -Dlogger.file=/etc/graylog2/web/logback.xml"
DAEMON_ARGS="$DAEMON_ARGS -Dpidfile.path=$PIDFILE"
DAEMON_ARGS="$DAEMON_ARGS -Dhttp.address=$GRAYLOG2_WEB_HTTP_ADDRESS"
DAEMON_ARGS="$DAEMON_ARGS -Dhttp.port=$GRAYLOG2_WEB_HTTP_PORT"
DAEMON_ARGS="$DAEMON_ARGS $GRAYLOG2_WEB_ARGS"


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


do_start()
{
	if [ "$RUN" != "yes" ] ; then
		log_progress_msg "(disabled)"
		log_end_msg 0

		exit 0
	fi
	test -e /var/run/graylog2-web || mkdir /var/run/graylog2-web ; chown graylog2-web:graylog2-web /var/run/graylog2-web
	if running ; then
		log_progress_msg "apparently already running"
		return 1
	else
		touch /var/log/graylog2-web/console.log
		chown graylog2-web:graylog2-web /var/log/graylog2-web/console.log
		export JAVA_OPTS="$GRAYLOG2_WEB_JAVA_OPTS"
		su -s /bin/bash -c "nohup $DAEMON $DAEMON_ARGS >> /var/log/graylog2-web/console.log 2>&1 &" graylog2-web
	fi
}

do_stop()
{
	if [ -s $PIDFILE ]; then
		kill `cat ${PIDFILE}` >/dev/null 2>&1
	fi
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
