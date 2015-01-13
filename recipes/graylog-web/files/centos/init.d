#! /bin/sh
#
# graylog-web Starts/stop the "graylog-web" application
#
# chkconfig:   - 99 1
# description: Runs the graylog-web application

### BEGIN INIT INFO
# Provides:          graylog-web
# Required-Start:    $network $named $remote_fs $syslog
# Required-Stop:     $network $named $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Graylog Web
# Description:       Graylog Web - Search your logs, create charts, send reports and be alerted when something happens.
### END INIT INFO

# Author: Lee Briggs <lee@leebriggs.co.uk>
# Contributor: Bernd Ahlers <bernd@torch.sh>

# Some default settings.
GRAYLOG_WEB_HTTP_ADDRESS="0.0.0.0"
GRAYLOG_WEB_HTTP_PORT="9000"
GRAYLOG_WEB_USER="graylog-web"

# Source function library.
. /etc/rc.d/init.d/functions

RETVAL=0
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Graylog Web"
NAME=graylog-web
CMD=/usr/share/graylog-web/bin/graylog-web-interface
PID_FILE=/var/lib/graylog-web/application.pid
CONF_FILE=/etc/graylog/web/web.conf
SCRIPTNAME=/etc/init.d/$NAME
LOCKFILE=/var/lock/subsys/$NAME
RUN=yes

# Pull in sysconfig settings
[ -f /etc/sysconfig/graylog-web ] && . /etc/sysconfig/graylog-web

# Exit if the package is not installed
[ -e "$CMD" ] || exit 0

start() {
    echo -n $"Starting ${NAME}: "
    daemon --user=$GRAYLOG_WEB_USER --pidfile=${PID_FILE} \
        "nohup $GRAYLOG_COMMAND_WRAPPER $CMD -Dconfig.file=${CONF_FILE} \
        -Dlogger.file=/etc/graylog/web/logback.xml \
        -Dpidfile.path=$PID_FILE \
        -Dhttp.address=$GRAYLOG_WEB_HTTP_ADDRESS \
        -Dhttp.port=$GRAYLOG_WEB_HTTP_PORT \
        $GRAYLOG_WEB_JAVA_OPTS $GRAYLOG_WEB_ARGS > /var/log/graylog-web/console.log 2>&1 &"
    RETVAL=$?
    sleep 2
    [ $RETVAL = 0 ] && touch ${LOCKFILE}
    echo
    return $RETVAL
}

stop() {
    echo -n $"Stopping ${NAME}: "
    killproc -p ${PID_FILE} -d 10 $CMD
    RETVAL=$?
    [ $RETVAL = 0 ] && rm -f ${PID_FILE} && rm -f ${LOCKFILE}
    echo
    return $RETVAL
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status -p ${PID_FILE} $NAME
        RETVAL=$?
        ;;
    restart|force-reload)
        stop
        start
        ;;
    *)
        N=/etc/init.d/${NAME}
        echo "Usage: $N {start|stop|status|restart|force-reload}" >&2
        RETVAL=2
        ;;
esac

exit $RETVAL
