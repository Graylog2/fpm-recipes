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

  config_files   Dir['graylog_illuminate_core/*'],
                 Dir['graylog_illuminate_windows/*'],
                 Dir['graylog_illuminate_okta/*'],
                 Dir['graylog_illuminate_paloalto/*'],
                 Dir['graylog_illuminate_o365/*'],
                 Dir['illuminate_elastic_template/*']

  fpm_attributes rpm_os: 'linux'

  post_install   'files/post-install'
  post_uninstall 'files/post-uninstall'

  def build
    system("tar -xvzf graylog_illuminate_server_files*.tar.gz")
  end

  def install
    etc('graylog/graylog_illuminate_core').install Dir['graylog_illuminate_core/*']
    etc('graylog/graylog_illuminate_core').chmod(0755)

    etc('graylog/graylog_illuminate_windows').install Dir['graylog_illuminate_windows/*']
    etc('graylog/graylog_illuminate_windows').chmod(0755)

    etc('graylog/graylog_illuminate_okta').install Dir['graylog_illuminate_okta/*']
    etc('graylog/graylog_illuminate_okta').chmod(0755)

    etc('graylog/graylog_illuminate_paloalto').install Dir['graylog_illuminate_paloalto/*']
    etc('graylog/graylog_illuminate_paloalto').chmod(0755)

    etc('graylog/graylog_illuminate_o365').install Dir['graylog_illuminate_o365/*']
    etc('graylog/graylog_illuminate_o365').chmod(0755)

    etc('graylog/illuminate_elastic_template').install Dir['illuminate_elastic_template/*']
    etc('graylog/illuminate_elastic_template').chmod(0755)
  end
end
