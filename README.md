Graylog2 Package Builds
=======================

This repository contains [fpm-cookery][fpm-cookery] recipes to build the
official Graylog2 packages.

The package builds are executed in isolated [Docker][docker] containers by
using the [Vagrant Docker Provider][vagrant-docker].

## Setup

* Install [Vagrant][vagrant]
* Install [Docker][docker]

### Linux

Make sure that the user that executes the package builds via
`vagrant docker-run` is a member of the `docker` group. Otherwise there will
be errors regarding the Docker socket.

### Mac OSX

Since Docker does not have native support for Mac OSX, Vagrant will
automatically use a small virtual machine to run docker. This requires
[VirtualBox][virtualbox] to be installed.

## Build Packages

For now the `fpm-cook` command to build the package has to be executed via
`vagrant docker-run`. See the example below.

### Example

The following example command builds the graylog2-server package for Ubuntu
14.04.

```
$ vagrant docker-run ubuntu1404 -- fpm-cook package /vagrant/recipes/graylog2-server/recipe.rb
==> ubuntu1404: Building the container from a Dockerfile...
    ubuntu1404: Image: 0f7af5021f9f
==> ubuntu1404: Creating the container...
    ubuntu1404:   Name: recipes_ubuntu1404_1399476701
    ubuntu1404:  Image: 0f7af5021f9f
    ubuntu1404:    Cmd: fpm-cook package /vagrant/recipes/graylog2-server/recipe.rb
    ubuntu1404: Volume: /src/graylog2-fpm-recipes:/vagrant
    ubuntu1404:
    ubuntu1404: Container is starting. Output will stream in below...
    ubuntu1404:
    ubuntu1404: ===> Starting package creation for graylog2-server-0.20.1 (ubuntu, deb)
    ubuntu1404: ===>
    ubuntu1404: ===> Verifying build_depends and depends with Puppet
    ubuntu1404: ===> Verifying package: openjdk-7-jre-headless
    ubuntu1404: ===> All build_depends and depends packages installed
    ubuntu1404: ===> Fetching source:
    ubuntu1404: ===> Using cached file /vagrant/recipes/graylog2-server/cache/graylog2-server-0.20.1.tgz
    ubuntu1404: ===> Building in /vagrant/recipes/graylog2-server/tmp-build/graylog2-server-0.20.1
    ubuntu1404: ===> Installing into /vagrant/recipes/graylog2-server/tmp-dest
    ubuntu1404: ===> [FPM] Converting dir to deb {}
    ubuntu1404: ===> Removing existing package file: graylog2-server_0.20.1_all.deb
    ubuntu1404: ===> [FPM] No deb_installed_size set, calculating now. {}
    ubuntu1404: ===> [FPM] Reading template {"path":"/var/lib/gems/1.9.1/gems/fpm-1.0.2/templates/deb.erb"}
    ubuntu1404: ===> [FPM] Creating {"path":"/tmp/package-deb-build20140507-1-32jt4z/control.tar.gz","from":"/tmp/package-deb-build20140507-1-32jt4z/control"}
    ubuntu1404: ===> [FPM] Created deb package {"path":"graylog2-server_0.20.1_all.deb"}
    ubuntu1404: ===> Created package: /vagrant/recipes/graylog2-server/pkg/graylog2-server_0.20.1_all.deb
$
```

## Available Operating Systems

| Name       | VM Name          |
|------------|------------------|
| ubuntu1404 | Ubuntu 14.04 LTS |
| centos6    | CentOS 6.5       |



[fpm-cookery]: https://github.com/bernd/fpm-cookery
[vagrant]: http://www.vagrantup.com/
[vagrant-docker]: http://docs.vagrantup.com/v2/docker/index.html
[docker]: http://docker.io/
[virtualbox]: https://www.virtualbox.org/
