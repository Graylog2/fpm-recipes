#!/bin/sh

set -e

GRAYLOG_WEB_HTTP_ADDRESS="0.0.0.0"
GRAYLOG_WEB_HTTP_PORT="9000"

# For Debian/Ubuntu based systems.
if [ -f "/etc/default/graylog-web" ]; then
    . "/etc/default/graylog-web"
fi

# For RedHat/Fedora based systems.
if [ -f "/etc/sysconfig/graylog-web" ]; then
    . "/etc/sysconfig/graylog-web"
fi

JAVA_OPTS="-Dconfig.file=/etc/graylog/web/web.conf"
JAVA_OPTS="$JAVA_OPTS -Dlogger.file=/etc/graylog/web/logback.xml"
JAVA_OPTS="$JAVA_OPTS -Dpidfile.path=/dev/null"
JAVA_OPTS="$JAVA_OPTS -Dhttp.address=$GRAYLOG_WEB_HTTP_ADDRESS"
JAVA_OPTS="$JAVA_OPTS -Dhttp.port=$GRAYLOG_WEB_HTTP_PORT"

export JAVA_OPTS="$JAVA_OPTS $GRAYLOG_WEB_JAVA_OPTS"

$GRAYLOG_COMMAND_WRAPPER /usr/share/graylog-web/bin/graylog-web-interface $GRAYLOG_WEB_ARGS
