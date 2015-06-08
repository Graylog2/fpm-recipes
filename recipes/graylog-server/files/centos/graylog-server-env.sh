#!/bin/sh

# For Debian/Ubuntu based systems.
if [ -f "/etc/default/graylog-server" ]; then
    source "/etc/default/graylog-server"
fi

# For RedHat/Fedora based systems.
if [ -f "/etc/sysconfig/graylog-server" ]; then
    source "/etc/sysconfig/graylog-server"
fi

$GRAYLOG_COMMAND_WRAPPER ${JAVA:=/usr/bin/java} $GRAYLOG_SERVER_JAVA_OPTS \
    -jar -Dlog4j.configuration=file:///etc/graylog/server/log4j.xml \
    -Djava.library.path=/usr/share/graylog-server/lib/sigar \
    /usr/share/graylog-server/graylog.jar server -f /etc/graylog/server/server.conf -np \
    $GRAYLOG_SERVER_ARGS
