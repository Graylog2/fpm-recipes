FROM centos:centos8

MAINTAINER Graylog, Inc. <hello@graylog.com>

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum install -y rubygems ruby-devel make gcc tar rpm-build curl git && \
    gem install fpm-cookery --no-document && \
    yum clean all
