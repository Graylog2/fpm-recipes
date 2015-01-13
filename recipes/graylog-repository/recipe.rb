require_relative '../tools'

class GraylogRepository < FPM::Cookery::Recipe
  include Tools

  VERSION = data.version_major

  description "Package to install Graylog #{VERSION} GPG key and repository"

  name       "graylog-#{VERSION}-repository-#{os}#{osrel}"
  version    '1.2.0'
  revision   1
  source     '', :with => :noop
  arch       'all'
  homepage   data.homepage
  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  replaces %w(0.92 0.91 0.90).map {|v| "graylog2-#{v}-repository-#{os}#{osrel}" }

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

    File.open('graylog.list', 'w') do |file|
      file.puts "deb https://packages.graylog2.org/repo/debian/ #{dist} #{VERSION}"
    end

    etc('apt/trusted.gpg.d').install workdir('files/deb/graylog-keyring.gpg')
    etc('apt/sources.list.d').install 'graylog.list'
  end

  def install_rpm
    File.open('graylog.repo', 'w') do |file|
      file.puts "[graylog]"
      file.puts "name=graylog"
      file.puts "baseurl=https://packages.graylog2.org/repo/el/$releasever/#{VERSION}/$basearch/"
      file.puts "gpgcheck=1"
      file.puts "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-graylog"
    end

    etc('pki/rpm-gpg').install workdir('files/rpm/RPM-GPG-KEY-graylog')
    etc('yum.repos.d').install 'graylog.repo'
  end

  def after_build_package(package)
    Dir.chdir(pkgdir) do
      ext = File.extname(package.to_s)
      target = "graylog-#{VERSION}-repository-#{os}#{osrel}_latest#{ext}"

      FPM::Cookery::Log.info("Copy #{package.to_s} to #{target}")

      cp(package.to_s, target)
    end
  end
end
