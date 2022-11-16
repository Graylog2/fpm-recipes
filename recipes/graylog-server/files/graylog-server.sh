#!/bin/sh

set -e

# For Debian/Ubuntu based systems.
if [ -f "/etc/default/graylog-server" ]; then
    . "/etc/default/graylog-server"
fi

# For RedHat/Fedora based systems.
if [ -f "/etc/sysconfig/graylog-server" ]; then
    . "/etc/sysconfig/graylog-server"
fi

if [ -f "/usr/share/graylog-server/installation-source.sh" ]; then
    . "/usr/share/graylog-server/installation-source.sh"
fi

if [ -z "$JAVA" ] && [ -d "/usr/share/graylog-server/jvm" ]; then
	JAVA="/usr/share/graylog-server/jvm/bin/java"
fi

$GRAYLOG_COMMAND_WRAPPER ${JAVA:=/usr/bin/java} $GRAYLOG_SERVER_JAVA_OPTS \
    -jar -Dlog4j.configurationFile=file:///etc/graylog/server/log4j2.xml \
    -Djava.library.path=/usr/share/graylog-server/lib/sigar \
    -Dgraylog2.installation_source=${GRAYLOG_INSTALLATION_SOURCE:=unknown} \
    /usr/share/graylog-server/graylog.jar server -f /etc/graylog/server/server.conf -np \
    $GRAYLOG_SERVER_ARGS
