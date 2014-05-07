FROM ubuntu:14.04

MAINTAINER TORCH GmbH <hello@torch.sh>

RUN apt-get update
RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev build-essential
RUN gem install fpm-cookery --no-ri --no-rdoc

# Install some package dependencies to avoid installing them every time.
RUN apt-get install -y openjdk-7-jre-headless
