require_relative '../tools'

class Graylog2Repository < FPM::Cookery::Recipe
  include Tools

  VERSION = data.version_major

  description "Package to install Graylog2 #{VERSION} GPG key and repository"

  name       "graylog2-#{VERSION}-repository-#{os}#{osrel}"
  version    '1.0.0'
  revision   2
  source     '', :with => :noop
  arch       'all'
  homepage   data.homepage
  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  def build
  end

  def install
    case os
    when 'debian', 'ubuntu'
      install_deb
    when 'centos'
      install_rpm
    else
      raise "Unknown OS: #{os}"
    end
  end

  def install_deb
    dist = fact('lsbdistcodename').downcase

    File.open('graylog2.list', 'w') do |file|
      file.puts "deb http://packages.graylog2.org/repo/debian/ #{dist} #{VERSION}"
    end

    etc('apt/trusted.gpg.d').install workdir('files/deb/graylog2-keyring.gpg')
    etc('apt/sources.list.d').install 'graylog2.list'
  end

  def install_rpm
    File.open('graylog2.repo', 'w') do |file|
      file.puts "[graylog2]"
      file.puts "name=graylog2"
      file.puts "baseurl=http://packages.graylog2.org/repo/el/$releasever/#{VERSION}/$basearch/"
      file.puts "gpgcheck=1"
      file.puts "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-graylog2"
    end

    etc('pki/rpm-gpg').install workdir('files/rpm/RPM-GPG-KEY-graylog2')
    etc('yum.repos.d').install 'graylog2.repo'
  end

  def after_build_package(package)
    Dir.chdir(pkgdir) do
      ext = File.extname(package.to_s)
      target = "graylog2-#{VERSION}-repository-#{os}#{osrel}_latest#{ext}"

      FPM::Cookery::Log.info("Copy #{package.to_s} to #{target}")

      cp(package.to_s, target)
    end
  end
end
