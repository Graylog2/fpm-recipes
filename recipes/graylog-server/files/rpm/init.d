#! /bin/sh
#
# graylog-server Runs Graylog server
#
# chkconfig:   - 95 5
# description: Runs the graylog-server daemon

### BEGIN INIT INFO
# Provides:          graylog-server
# Required-Start:    $network $named $remote_fs $syslog
# Required-Stop:     $network $named $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Graylog Server
# Description:       Graylog Server - Search your logs, create charts, send reports and be alerted when something happens.
### END INIT INFO

# Author: Lee Briggs <lee@leebriggs.co.uk>
# Contributor: Sandro Roth <sandro.roth@gmail.com>
# Contributor: Bernd Ahlers <bernd@graylog.com>

# Source function library.
. /etc/rc.d/init.d/functions

# Include this early so the GRAYLOG_INSTALLATION_SOURCE variable is set.
if [ -f "/usr/share/graylog-server/installation-source.sh" ]; then
    . "/usr/share/graylog-server/installation-source.sh"
fi

RETVAL=0
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Graylog Server"
NAME=graylog-server
JAR_FILE=/usr/share/graylog-server/graylog.jar
JAVA=/usr/bin/java
PID_DIR=/var/run/graylog-server
PID_FILE=$PID_DIR/$NAME.pid
JAVA_ARGS="-jar -Djava.library.path=/usr/share/graylog-server/lib/sigar -Dlog4j.configurationFile=file:///etc/graylog/server/log4j2.xml -Dgraylog2.installation_source=${GRAYLOG_INSTALLATION_SOURCE:=unknown} $JAR_FILE server -p $PID_FILE -f /etc/graylog/server/server.conf"
SCRIPTNAME=/etc/init.d/$NAME
LOCKFILE=/var/lock/subsys/$NAME
GRAYLOG_SERVER_USER=graylog
GRAYLOG_SERVER_JAVA_OPTS=""
# Pull in sysconfig settings
[ -f /etc/sysconfig/${NAME} ] && . /etc/sysconfig/${NAME}

# Exit if the package is not installed
[ -e "$JAR_FILE" ] || exit 0
[ -x "$JAVA" ] || exit 0

if [ -f "/usr/share/graylog-server/installation-source.sh" ]; then
    . "/usr/share/graylog-server/installation-source.sh"
fi

start() {
    echo -n $"Starting ${NAME}: "
    install -d -m 755 -o $GRAYLOG_SERVER_USER -g $GRAYLOG_SERVER_USER -d $PID_DIR
    ulimit -n 64000
    daemon --check $JAVA --pidfile=${PID_FILE} --user=${GRAYLOG_SERVER_USER} \
        "$GRAYLOG_COMMAND_WRAPPER $JAVA $GRAYLOG_SERVER_JAVA_OPTS $JAVA_ARGS $GRAYLOG_SERVER_ARGS &"
    RETVAL=$?
    sleep 2
    [ $RETVAL = 0 ] && touch ${LOCKFILE}
    echo
    return $RETVAL
}

stop() {
    echo -n $"Stopping ${NAME}: "
    killproc -p ${PID_FILE} -d 10 $JAVA
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
