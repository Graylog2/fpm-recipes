require_relative '../tools'

class GraylogIlluminate < FPM::Cookery::Recipe
  description 'Graylog Illuminate'

  name     'graylog-illuminate'
  version  data.version
  revision data.revision
  homepage 'https://graylog.org'
  arch     'amd64'

  source data.source
  sha256 data.sha256

  maintainer 'Graylog, Inc. <hello@graylog.org>'
  vendor     'graylog'
  license    data.license

  #config_files '/etc/graylog/sidecar/sidecar.yml'

  fpm_attributes rpm_os: 'linux'

  def build
    system("tar -xvzf graylog_illuminate_server_files*.tar.gz")
  end

  def install
    etc('graylog/illuminate').install 'README.txt'
    etc('graylog/illuminate').install Dir['graylog_illuminate_*/', 'illuminate_elastic_template']
  end
end
