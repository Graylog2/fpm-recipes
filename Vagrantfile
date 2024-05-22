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

  config.vm.define 'centos8' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/centos8')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/centos:8']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'alma9' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/alma9')
      docker.build_args = ['--rm=true', '--tag=fpm_cookery/alma:9']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end
end
