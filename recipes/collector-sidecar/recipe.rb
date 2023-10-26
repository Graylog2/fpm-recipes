require_relative '../tools'

class GraylogSidecar < FPM::Cookery::Recipe
  include Tools

  description 'Graylog collector sidecar'

  name     'graylog-sidecar'
  version  data.version
  revision data.revision
  homepage 'https://graylog.org'
  arch     pkg_arch

  source data.source
  sha256 data.sha256

  maintainer 'Graylog, Inc. <hello@graylog.org>'
  vendor     'graylog'
  license    data.license

  config_files '/etc/graylog/sidecar/sidecar.yml'

  targets :rpm do
    fpm_attributes rpm_os: 'linux'
    # Digest required to make packages work on FIPS enabled RedHat systems
    rpm_digest_algo 'sha256'
  end

  def build
  end

  def install
    bin.install "#{version}/linux/#{pkg_arch}/graylog-sidecar"
    etc('graylog/sidecar').install workdir('sidecar-example.yml'), 'sidecar.yml'
    var('lib/graylog-sidecar/generated').mkdir
    var('log/graylog-sidecar').mkdir
    var('run/graylog-sidecar').mkdir

    %w{auditbeat filebeat}.each do |beat|
      case pkg_arch
      when 'amd64'
        # The Sidecar tarball is using x86_64 for amd64. TODO: Fix that
        lib('graylog-sidecar').install "collectors/#{beat}/linux/x86_64/#{beat}"
      else
        lib('graylog-sidecar').install "collectors/#{beat}/linux/#{pkg_arch}/#{beat}"
      end
    end
  end
end
