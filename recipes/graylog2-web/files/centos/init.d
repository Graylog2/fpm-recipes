#! /bin/sh
### BEGIN INIT INFO
# Provides:          graylog2-web
# Required-Start:    $network $named $remote_fs $syslog
# Required-Stop:     $network $named $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Graylog2 Web
# Description:       Graylog2 Web - Search your logs, create charts, send reports and be alerted when something happens.
### END INIT INFO

# Author: Lee Briggs <lee@leebriggs.co.uk>
# Contributor: Bernd Ahlers <bernd@torch.sh>

# Some default settings.
GRAYLOG2_WEB_HTTP_ADDRESS="0.0.0.0"
GRAYLOG2_WEB_HTTP_PORT="9000"

# Source function library.
. /etc/rc.d/init.d/functions

# Pull in sysconfig settings
[ -f /etc/sysconfig/graylog2-web ] && . /etc/sysconfig/graylog2-web

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Graylog2 Web"
NAME=graylog2-web
CMD=/usr/share/graylog2-web/bin/graylog2-web-interface
PID_FILE=/var/lib/graylog2-web/application.pid
CONF_FILE=/etc/graylog2/web/graylog2-web-interface.conf
SCRIPTNAME=/etc/init.d/$NAME
LOCKFILE=/var/lock/subsys/$NAME
GRAYLOG2_WEB_USER=graylog2-web
RUN=yes

# Exit if the package is not installed
[ -e "$CMD" ] || exit 0

start() {
    echo -n $"Starting ${NAME}: "
    daemon --user=$GRAYLOG2_WEB_USER \
        nohup $CMD -Dconfig.file=${CONF_FILE} \
        -Dlogger.file=/etc/graylog2/web/logback.xml \
        -Dpidfile.path=$PID_FILE \
        -Dhttp.address=$GRAYLOG2_WEB_HTTP_ADDRESS \
        -Dhttp.port=$GRAYLOG2_WEB_HTTP_PORT \
        $GRAYLOG2_WEB_JAVA_OPTS $GRAYLOG2_WEB_ARGS > /var/log/graylog2-web/console.log 2>&1 &
    RETVAL=$?
    echo
    sleep 2
    [ $RETVAL = 0 ] && touch ${LOCKFILE}
    return $RETVAL
}

stop() {
    echo -n $"Stopping ${NAME}: "
    killproc -p ${PID_FILE} -d 10 $CMD
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f ${PID_FILE} && rm -f ${LOCKFILE}
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
