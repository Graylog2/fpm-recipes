# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'pathname'

ROOT = Pathname.new(__FILE__).expand_path.dirname

Vagrant.configure('2') do |config|
  config.vm.define 'ubuntu1404' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/ubuntu')

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end

  config.vm.define 'centos6' do |machine|
    machine.vm.provider 'docker' do |docker|
      docker.build_dir = ROOT.join('docker/centos')

      # Avoid leaving unused containers behind.
      docker.create_args = ['--rm=true']
    end
  end
end
