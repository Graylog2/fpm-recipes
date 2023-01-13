require_relative '../tools'

class GraylogSidecarRepository < FPM::Cookery::Recipe
  include Tools

  name       "graylog-sidecar-repository"
  VERSION = data.version_major

  description "Package to install Graylog Sidecar GPG key and repository"

  version    '1'
  revision   5
  source     '', :with => :noop
  arch       'all'
  homepage   data.homepage
  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  targets :rpm do
    # Digest required to make packages work on FIPS enabled RedHat systems
    rpm_digest_algo 'sha256'
  end

  def build
  end

  def install
    case target
    when :deb
      install_deb
    when :rpm
      install_rpm
    else
      raise "Unknown OS target: #{target} (#{os})"
    end
  end

  def install_deb
    File.open('graylog-sidecar.list', 'w') do |file|
      file.puts "deb https://packages.graylog2.org/repo/debian/ sidecar-stable #{VERSION}"
    end

    etc('apt/trusted.gpg.d').install workdir('files/deb/graylog-sidecar-keyring.gpg')
    etc('apt/sources.list.d').install 'graylog-sidecar.list'
  end

  def install_rpm
    File.open('graylog-sidecar.repo', 'w') do |file|
      file.puts "[graylog-sidecar]"
      file.puts "name=graylog-sidecar"
      file.puts "baseurl=https://packages.graylog2.org/repo/el/sidecar-stable/#{VERSION}/$basearch/"
      file.puts "gpgcheck=1"
      file.puts "repo_gpgcheck=0"
      file.puts "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-graylog-sidecar"
    end

    etc('pki/rpm-gpg').install workdir('files/rpm/RPM-GPG-KEY-graylog-sidecar')
    etc('yum.repos.d').install 'graylog-sidecar.repo'
  end

  def after_build_package(package)
    Dir.chdir(pkgdir) do
      ext = File.extname(package.to_s)
      target = "graylog-sidecar-#{VERSION}-repository_latest#{ext}"

      FPM::Cookery::Log.info("Copy #{package.to_s} to #{target}")

      cp(package.to_s, target)
    end
  end
end
