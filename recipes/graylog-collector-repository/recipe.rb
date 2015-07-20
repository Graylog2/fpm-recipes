require_relative '../tools'

class GraylogCollectorRepository < FPM::Cookery::Recipe
  include Tools

  VERSION = 'latest'

  description "Package to install Graylog Collector GPG key and repository"

  name       "graylog-collector-#{VERSION}-repository-#{os}#{osrel}"
  version    '1.0.0'
  revision   1
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
    when 'centos', 'el'
      install_rpm
    else
      raise "Unknown OS: #{os}"
    end
  end

  def install_deb
    dist = fact('lsbdistcodename').downcase

    File.open('graylog-collector.list', 'w') do |file|
      file.puts "deb https://packages.graylog2.org/repo/debian/ #{dist} collector-#{VERSION}"
    end

    etc('apt/trusted.gpg.d').install workdir('files/deb/graylog-collector-keyring.gpg')
    etc('apt/sources.list.d').install 'graylog-collector.list'
  end

  def install_rpm
    File.open('graylog-collector.repo', 'w') do |file|
      file.puts "[graylog-collector]"
      file.puts "name=graylog-collector"
      file.puts "baseurl=https://packages.graylog2.org/repo/el/$releasever/collector-#{VERSION}/$basearch/"
      file.puts "gpgcheck=1"
      file.puts "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-graylog-collector"
    end

    etc('pki/rpm-gpg').install workdir('files/rpm/RPM-GPG-KEY-graylog-collector')
    etc('yum.repos.d').install 'graylog-collector.repo'
  end

  def after_build_package(package)
    Dir.chdir(pkgdir) do
      ext = File.extname(package.to_s)
      target = "graylog-collector-#{VERSION}-repository-#{os}#{osrel}_latest#{ext}"

      FPM::Cookery::Log.info("Copy #{package.to_s} to #{target}")

      cp(package.to_s, target)
    end
  end
end
