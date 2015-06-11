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

export JAVA_OPTS="$GRAYLOG_WEB_JAVA_OPTS"

$GRAYLOG_COMMAND_WRAPPER /usr/share/graylog-web/bin/graylog-web-interface \
    -Dlogger.file=/etc/graylog/web/logback.xml \
    -Dconfig.file=/etc/graylog/web/web.conf \
    -Dpidfile.path=/dev/null \
    -Dhttp.address=$GRAYLOG_WEB_HTTP_ADDRESS \
    -Dhttp.port=$GRAYLOG_WEB_HTTP_PORT \
    $GRAYLOG_WEB_ARGS
