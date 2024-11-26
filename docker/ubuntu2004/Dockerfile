FROM ubuntu:20.04

MAINTAINER Graylog, Inc. <hello@graylog.com>

RUN apt-get update && \
    apt-get install -y ruby ruby2.7 ruby2.7-dev build-essential curl lsb-release git && \
    gem install dotenv -v 2.8.1 --no-document && \
    gem install public_suffix -v 5.1.1 --no-document && \
    gem install fpm-cookery -v 0.37.0 --no-document && \
    apt-get install -y uuid-runtime && \
    apt-get clean
