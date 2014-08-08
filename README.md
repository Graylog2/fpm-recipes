Graylog2 Package Builds
=======================

This repository contains [fpm-cookery][fpm-cookery] recipes to build the
official Graylog2 packages.

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

To build the graylog2-server package on CentOS 6 only the VM name needs to
be exchanged.

```
$ vagrant docker-run centos6 -- fpm-cook package /vagrant/recipes/graylog2-server/recipe.rb
==> centos6: Building the container from a Dockerfile...
    centos6: Image: ca5e4f877dac
==> centos6: Creating the container...
    centos6:   Name: graylog2-fpm-recipes_centos6_1399484675
    centos6:  Image: ca5e4f877dac
    centos6:    Cmd: fpm-cook package /vagrant/recipes/graylog2-server/recipe.rb
    centos6: Volume: /src/graylog2-fpm-recipes:/vagrant
    centos6:
    centos6: Container is starting. Output will stream in below...
    centos6:
    centos6: ===> Starting package creation for graylog2-server-0.20.1 (centos, rpm)
    centos6: ===>
    centos6: ===> Verifying build_depends and depends with Puppet
    centos6: ===> Verifying package: java-1.7.0-openjdk
    centos6: ===> All build_depends and depends packages installed
    centos6: ===> Fetching source:
    centos6: ===> Using cached file /vagrant/recipes/graylog2-server/cache/graylog2-server-0.20.1.tgz
    centos6: ===> Building in /vagrant/recipes/graylog2-server/tmp-build/graylog2-server-0.20.1
    centos6: ===> Installing into /vagrant/recipes/graylog2-server/tmp-dest
    centos6: ===> [FPM] Converting dir to rpm {}
    centos6: ===> Removing existing package file: graylog2-server-0.20.1-1.noarch.rpm
    centos6: ===> [FPM] Reading template {"path":"/usr/lib/ruby/gems/1.8/gems/fpm-1.0.2/templates/rpm.erb"}
    centos6: ===> [FPM] Running rpmbuild {"args":["rpmbuild","-bb","--define","buildroot /tmp/package-rpm-build20140507-1-ttb91c/BUILD","--define","_topdir /tmp/package-rpm-build20140507-1-ttb91c","--define","_sourcedir /tmp/package-rpm-build20140507-1-ttb91c","--define","_rpmdir /tmp/package-rpm-build20140507-1-ttb91c/RPMS","/tmp/package-rpm-build20140507-1-ttb91c/SPECS/graylog2-server.spec"]}
    centos6: ===> [FPM] Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.PiGYv6 {}
    centos6: ===> [FPM] Executing(%build): /bin/sh -e /var/tmp/rpm-tmp.14unGZ {}
    centos6: ===> [FPM] Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.8xL6QS {}
    centos6: ===> [FPM] Processing files: graylog2-server-0.20.1-1.noarch {}
    centos6: ===> [FPM] Wrote: /tmp/package-rpm-build20140507-1-ttb91c/RPMS/noarch/graylog2-server-0.20.1-1.noarch.rpm {}
    centos6: ===> [FPM] Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.M2OieO {}
    centos6: ===> [FPM] Created rpm {"path":"graylog2-server-0.20.1-1.noarch.rpm"}
    centos6: ===> Created package: /vagrant/recipes/graylog2-server/pkg/graylog2-server-0.20.1-1.noarch.rpm
$
```

## Available Operating Systems

| Name             | VM Name    |
|------------------|------------|
| Ubuntu 14.04 LTS | ubuntu1404 |
| CentOS 6.5       | centos6    |
| Debian 7         | debian7    |

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
