FROM centos:centos7

MAINTAINER Graylog, Inc. <hello@graylog.com>

# Install required packages to install the fpm-cookery gem.
RUN yum clean all
RUN yum install -y rubygems ruby-devel make gcc tar rpm-build curl git

# Install the fpm-cookery gem from rubygems.org.
RUN gem install "rubygems-update:<3.0.0" --no-document
RUN update_rubygems
RUN gem install public_suffix -v 2.0.5
RUN gem install facter -v 2.5.7
RUN gem install fast_gettext -v 1.1.2
RUN gem install puppet -v 5.5.19
RUN gem install ffi -v 1.12.2
RUN gem install git -v 1.7.0
RUN gem install fpm-cookery --no-ri --no-rdoc --version 0.25.0

# Remove cached packages and metadata to keep images small.
RUN yum clean all
