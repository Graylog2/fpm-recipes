#! /bin/sh
### BEGIN INIT INFO
# Provides:          graylog2-radio
# Required-Start:    $network $named $remote_fs $syslog
# Required-Stop:     $network $named $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Graylog2 Radio
# Description:       Graylog2 Radio - Search your logs, create charts, send reports and be alerted when something happens.
### END INIT INFO

# Author: Lee Briggs <lee@leebriggs.co.uk>
# Contributor: Sandro Roth <sandro.roth@gmail.com>
# Contributor: Bernd Ahlers <bernd@torch.sh>

# Source function library.
. /etc/rc.d/init.d/functions

RETVAL=0
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Graylog2 Radio"
NAME=graylog2-radio
JAR_FILE=/usr/share/graylog2-radio/graylog2-radio.jar
JAVA=/usr/bin/java
PID_DIR=/var/run/graylog2-radio
PID_FILE=$PID_DIR/$NAME.pid
JAVA_ARGS="-jar -Dlog4j.configuration=file:///etc/graylog2/radio/log4j.xml $JAR_FILE -p $PID_FILE -f /etc/graylog2-radio.conf"
SCRIPTNAME=/etc/init.d/$NAME
LOCKFILE=/var/lock/subsys/$NAME
GRAYLOG2_RADIO_USER=graylog2-radio
GRAYLOG2_RADIO_JAVA_OPTS=""
# Pull in sysconfig settings
[ -f /etc/sysconfig/${NAME} ] && . /etc/sysconfig/${NAME}

# Exit if the package is not installed
[ -e "$JAR_FILE" ] || exit 0
[ -x "$JAVA" ] || exit 0

start() {
    echo -n $"Starting ${NAME}: "
    install -d -m 755 -o $GRAYLOG2_RADIO_USER -g $GRAYLOG2_RADIO_USER -d $PID_DIR
    daemon --check $JAVA --pidfile=${PID_FILE} --user=${GRAYLOG2_RADIO_USER} \
        "$JAVA $GRAYLOG2_RADIO_JAVA_OPTS $JAVA_ARGS $GRAYLOG2_RADIO_ARGS &"
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
