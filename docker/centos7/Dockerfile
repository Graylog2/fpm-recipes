FROM centos:centos7

MAINTAINER TORCH GmbH <hello@torch.sh>

# Install required packages to install the fpm-cookery gem.
RUN yum clean all
RUN yum install -y rubygems ruby-devel make gcc tar rpm-build curl

# Install the fpm-cookery gem from rubygems.org.
RUN gem install fpm-cookery --no-ri --no-rdoc --version 0.25.0

# Install some package dependencies to avoid installing them every time.
RUN yum install -y java-1.7.0-openjdk util-linux-ng

# Remove cached packages and metadata to keep images small.
RUN yum clean all
