FROM almalinux:9

MAINTAINER Graylog, Inc. <hello@graylog.com>

RUN yum install -y --allowerasing rubygems ruby-devel make gcc tar rpm-build curl git && \
    gem install dotenv -v 2.8.1 --no-document && \
    gem install fpm-cookery -v 0.35.1 --no-document && \
    yum clean all
