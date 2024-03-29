require_relative '../tools'

class GraylogSidecar < FPM::Cookery::Recipe
  description 'Graylog collector sidecar'

  name     'graylog-sidecar'
  version  data.version
  revision data.revision
  homepage 'https://graylog.org'
  arch     'i386'

  source data.source
  sha256 data.sha256

  maintainer 'Graylog, Inc. <hello@graylog.org>'
  vendor     'graylog'
  license    data.license

  config_files '/etc/graylog/sidecar/sidecar.yml'

  fpm_attributes rpm_os: 'linux'

  def build
  end

  def install
    bin.install "#{version}/linux/386/graylog-sidecar"
    etc('graylog/sidecar').install workdir('sidecar-example.yml'), 'sidecar.yml'
    etc('graylog/sidecar/sidecar.yml').chmod(0600)
    var('lib/graylog-sidecar/generated').mkdir
    var('log/graylog-sidecar').mkdir
    var('run/graylog-sidecar').mkdir
  end
end
