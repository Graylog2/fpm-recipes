FROM ubuntu:20.04

MAINTAINER Graylog, Inc. <hello@graylog.com>

RUN apt-get update && \
    apt-get install -y ruby ruby2.7 ruby2.7-dev build-essential curl lsb-release && \
    gem install fpm-cookery --no-document && \
    apt-get install -y openjdk-8-jre-headless uuid-runtime && \
    apt-get clean
