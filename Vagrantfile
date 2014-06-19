# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'pathname'

ROOT = Pathname.new(__FILE__).expand_path.dirname

Vagrant.configure('2') do |config|
  config.vm.define 'ubuntu1404' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/ubuntu')
      docker.build_args = ['--rm=true']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'debian7' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/debian')
      docker.build_args = ['--rm=true']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'centos6' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/centos')
      docker.build_args = ['--rm=true']

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end
end
