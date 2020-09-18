# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'pathname'

ROOT = Pathname.new(__FILE__).expand_path.dirname

Vagrant.configure('2') do |config|
  config.vm.define 'ubuntu2004' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/ubuntu2004')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/ubuntu:20.04']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'ubuntu1604' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/ubuntu1604')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/ubuntu:16.04']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'ubuntu1404' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/ubuntu1404')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/ubuntu:14.04']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'ubuntu1204' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/ubuntu1204')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/ubuntu:12.04']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'debian7' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/debian7')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/debian:7']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'debian8' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/debian8')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/debian:8']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'centos6' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/centos6')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/centos:6']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'centos7' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/centos7')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/centos:7']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'centos8' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/centos8')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/centos:8']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end
end
