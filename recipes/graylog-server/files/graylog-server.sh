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

# Java versions > 8 don't support UseParNewGC
if ${JAVA:=/usr/bin/java} -XX:+PrintFlagsFinal 2>&1 | grep -q UseParNewGC; then
	GRAYLOG_SERVER_JAVA_OPTS="$GRAYLOG_SERVER_JAVA_OPTS -XX:+UseParNewGC"
fi

# Java versions >= 15 don't support CMS Garbage Collector
if ${JAVA:=/usr/bin/java} -XX:+PrintFlagsFinal 2>&1 | grep -q UseConcMarkSweepGC; then
	GRAYLOG_SERVER_JAVA_OPTS="$GRAYLOG_SERVER_JAVA_OPTS -XX:+UseConcMarkSweepGC -XX:+CMSConcurrentMTEnabled -XX:+CMSClassUnloadingEnabled"
fi

$GRAYLOG_COMMAND_WRAPPER ${JAVA:=/usr/bin/java} $GRAYLOG_SERVER_JAVA_OPTS \
    -jar -Dlog4j.configurationFile=file:///etc/graylog/server/log4j2.xml \
    -Djava.library.path=/usr/share/graylog-server/lib/sigar \
    -Dgraylog2.installation_source=${GRAYLOG_INSTALLATION_SOURCE:=unknown} \
    /usr/share/graylog-server/graylog.jar server -f /etc/graylog/server/server.conf -np \
    $GRAYLOG_SERVER_ARGS
