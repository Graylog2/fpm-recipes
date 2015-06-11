#!/bin/sh

# For Debian/Ubuntu based systems.
if [ -f "/etc/default/graylog-radio" ]; then
    source "/etc/default/graylog-radio"
fi

# For RedHat/Fedora based systems.
if [ -f "/etc/sysconfig/graylog-radio" ]; then
    source "/etc/sysconfig/graylog-radio"
fi

$GRAYLOG_COMMAND_WRAPPER ${JAVA:=/usr/bin/java} $GRAYLOG_RADIO_JAVA_OPTS \
    -jar -Dlog4j.configuration=file:///etc/graylog/radio/log4j.xml \
    -Djava.library.path=/usr/share/graylog-radio/lib/sigar \
    /usr/share/graylog-radio/graylog.jar radio -f /etc/graylog/radio/radio.conf -np \
    $GRAYLOG_RADIO_ARGS
