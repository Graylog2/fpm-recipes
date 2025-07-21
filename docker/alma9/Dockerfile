FROM almalinux:9

MAINTAINER Graylog, Inc. <hello@graylog.com>

RUN yum install -y --allowerasing rubygems ruby-devel make gcc tar rpm-build curl git && \
    gem install dotenv -v 2.8.1 --no-document && \
    gem install public_suffix -v 5.1.1 --no-document && \
    gem install multi_json -v 1.15.0 && \
    gem install fpm-cookery -v 0.37.0 --no-document && \
    yum clean all
