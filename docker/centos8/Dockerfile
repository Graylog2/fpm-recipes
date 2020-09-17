FROM centos:centos8

MAINTAINER Graylog, Inc. <hello@graylog.com>

RUN yum install -y rubygems ruby-devel make gcc tar rpm-build curl && \
    gem install fpm-cookery --no-document && \
    yum clean all
