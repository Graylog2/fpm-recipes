Graylog Package Builds
=======================

This repository contains [fpm-cookery][fpm-cookery] recipes to build the
official Graylog packages.

The package builds are executed in isolated [Docker][docker] containers by
using the [Vagrant Docker Provider][vagrant-docker].

Please open an [issue](https://github.com/Graylog2/fpm-recipes/issues) if you
run into any problems with the packages.

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

The following example command builds the graylog-server package for Ubuntu
14.04.

```
$ vagrant docker-run ubuntu2004 -- fpm-cook package /vagrant/recipes/graylog-server/recipe.rb
==> ubuntu2004: Building the container from a Dockerfile...
    ubuntu2004: Image: 0f7af5021f9f
==> ubuntu2004: Creating the container...
    ubuntu2004:   Name: recipes_ubuntu2004_1399476701
    ubuntu2004:  Image: 0f7af5021f9f
    ubuntu2004:    Cmd: fpm-cook package /vagrant/recipes/graylog-server/recipe.rb
    ubuntu2004: Volume: /src/graylog-fpm-recipes:/vagrant
    ubuntu2004:
    ubuntu2004: Container is starting. Output will stream in below...
    ubuntu2004:
    ubuntu2004: ===> Starting package creation for graylog-server-1.0.0 (ubuntu, deb)
    ubuntu2004: ===>
    ubuntu2004: ===> Verifying build_depends and depends with Puppet
    ubuntu2004: ===> Verifying package: openjdk-7-jre-headless
    ubuntu2004: ===> All build_depends and depends packages installed
    ubuntu2004: ===> Fetching source:
    ubuntu2004: ===> Using cached file /vagrant/recipes/graylog-server/cache/graylog-server-1.0.0.tgz
    ubuntu2004: ===> Building in /vagrant/recipes/graylog-server/tmp-build/graylog-server-1.0.0
    ubuntu2004: ===> Installing into /vagrant/recipes/graylog-server/tmp-dest
    ubuntu2004: ===> [FPM] Converting dir to deb {}
    ubuntu2004: ===> Removing existing package file: graylog-server_1.0.0_all.deb
    ubuntu2004: ===> [FPM] No deb_installed_size set, calculating now. {}
    ubuntu2004: ===> [FPM] Reading template {"path":"/var/lib/gems/1.9.1/gems/fpm-1.0.2/templates/deb.erb"}
    ubuntu2004: ===> [FPM] Creating {"path":"/tmp/package-deb-build20140507-1-32jt4z/control.tar.gz","from":"/tmp/package-deb-build20140507-1-32jt4z/control"}
    ubuntu2004: ===> [FPM] Created deb package {"path":"graylog-server_1.0.0_all.deb"}
    ubuntu2004: ===> Created package: /vagrant/recipes/graylog-server/pkg/graylog-server_1.0.0_all.deb
$
```

To build the graylog-server package on CentOS 6 only the VM name needs to
be exchanged.

```
$ vagrant docker-run centos8 -- fpm-cook package /vagrant/recipes/graylog-server/recipe.rb
==> centos8: Building the container from a Dockerfile...
    centos8: Image: ca5e4f877dac
==> centos8: Creating the container...
    centos8:   Name: graylog-fpm-recipes_centos8_1399484675
    centos8:  Image: ca5e4f877dac
    centos8:    Cmd: fpm-cook package /vagrant/recipes/graylog-server/recipe.rb
    centos8: Volume: /src/graylog-fpm-recipes:/vagrant
    centos8:
    centos8: Container is starting. Output will stream in below...
    centos8:
    centos8: ===> Starting package creation for graylog-server-1.0.0 (centos, rpm)
    centos8: ===>
    centos8: ===> Verifying build_depends and depends with Puppet
    centos8: ===> Verifying package: java-1.7.0-openjdk
    centos8: ===> All build_depends and depends packages installed
    centos8: ===> Fetching source:
    centos8: ===> Using cached file /vagrant/recipes/graylog-server/cache/graylog-server-1.0.0.tgz
    centos8: ===> Building in /vagrant/recipes/graylog-server/tmp-build/graylog-server-1.0.0
    centos8: ===> Installing into /vagrant/recipes/graylog-server/tmp-dest
    centos8: ===> [FPM] Converting dir to rpm {}
    centos8: ===> Removing existing package file: graylog-server-1.0.0-1.noarch.rpm
    centos8: ===> [FPM] Reading template {"path":"/usr/lib/ruby/gems/1.8/gems/fpm-1.0.2/templates/rpm.erb"}
    centos8: ===> [FPM] Running rpmbuild {"args":["rpmbuild","-bb","--define","buildroot /tmp/package-rpm-build20140507-1-ttb91c/BUILD","--define","_topdir /tmp/package-rpm-build20140507-1-ttb91c","--define","_sourcedir /tmp/package-rpm-build20140507-1-ttb91c","--define","_rpmdir /tmp/package-rpm-build20140507-1-ttb91c/RPMS","/tmp/package-rpm-build20140507-1-ttb91c/SPECS/graylog-server.spec"]}
    centos8: ===> [FPM] Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.PiGYv6 {}
    centos8: ===> [FPM] Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.14unGZ {}
    centos8: ===> [FPM] Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.8xL6QS {}
    centos8: ===> [FPM] Processing files: graylog-server-1.0.0-1.noarch {}
    centos8: ===> [FPM] Wrote: /tmp/package-rpm-build20140507-1-ttb91c/RPMS/noarch/graylog-server-1.0.0-1.noarch.rpm {}
    centos8: ===> [FPM] Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.M2OieO {}
    centos8: ===> [FPM] Created rpm {"path":"graylog-server-1.0.0-1.noarch.rpm"}
    centos8: ===> Created package: /vagrant/recipes/graylog-server/pkg/graylog-server-1.0.0-1.noarch.rpm
$
```

## Available Operating Systems

| Name             | VM Name    |
|------------------|------------|
| Ubuntu 20.04 LTS | ubuntu2004 |
| CentOS 8         | centos8    |

## Credits

Lots of scripts and config files are based on the following great repositories
maintained by the community. Thank you!

### DEB

* https://github.com/hggh/graylog2-server
* https://github.com/hggh/graylog2-web
* https://github.com/hggh/graylog2-radio
* https://github.com/hggh/graylog2-stream-dashboard

### RPM

* https://github.com/jaxxstorm/graylog2-server-rpm
* https://github.com/jaxxstorm/graylog2-web-rpm
* https://github.com/jaxxstorm/graylog2-radio-rpm
* https://build.opensuse.org/project/monitor/home:bmanojlovic:graylog


[fpm-cookery]: https://github.com/bernd/fpm-cookery
[vagrant]: http://www.vagrantup.com/
[vagrant-docker]: http://docs.vagrantup.com/v2/docker/index.html
[docker]: http://docker.io/
[virtualbox]: https://www.virtualbox.org/
