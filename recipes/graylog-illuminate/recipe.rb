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

  config_files [
    'graylog_illuminate_core',
    'graylog_illuminate_windows',
    'graylog_illuminate_okta',
    'graylog_illuminate_paloalto',
    'graylog_illuminate_o365',
    'illuminate_elastic_template',
    'illuminate'
  ].map {|type|
    Dir["#{type}/*"].map {|f|
      File.join("/etc/graylog/#{type}", File.basename(f))
    }
  }.flatten

  post_install   'files/post-install'
  post_uninstall 'files/post-uninstall'

  def build
    system("tar -xvzf graylog_illuminate_server_files*.tar.gz")
  end

  def install
    # Server files
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

    etc('graylog/illuminate/sysmon').install Dir['illuminate/sysmon/*']
    etc('graylog/illuminate').chmod(0755)
    etc('graylog/illuminate/sysmon').chmod(0755)

    # Content packs
    share('graylog-illuminate/content_packs/illuminate_core').install Dir['illuminate_core/*']
    share('graylog-illuminate/content_packs/illuminate_core').chmod(0755)

    share('graylog-illuminate/content_packs/illuminate_events').install Dir['illuminate_events/*']
    share('graylog-illuminate/content_packs/illuminate_events').chmod(0755)

    share('graylog-illuminate/content_packs/illuminate_o365').install Dir['illuminate_o365/*']
    share('graylog-illuminate/content_packs/illuminate_o365').chmod(0755)

    share('graylog-illuminate/content_packs/illuminate_okta').install Dir['illuminate_okta/*']
    share('graylog-illuminate/content_packs/illuminate_okta').chmod(0755)

    share('graylog-illuminate/content_packs/illuminate_paloalto').install Dir['illuminate_paloalto/*']
    share('graylog-illuminate/content_packs/illuminate_paloalto').chmod(0755)

    share('graylog-illuminate/content_packs/illuminate_windows').install Dir['illuminate_windows/*']
    share('graylog-illuminate/content_packs/illuminate_windows').chmod(0755)

    share('graylog-illuminate/content_packs/illuminate_elastic_template').install Dir['illuminate_elastic_template/*']
    share('graylog-illuminate/content_packs/illuminate_elastic_template').chmod(0755)

    share('graylog-illuminate/content_packs/illuminate_sysmon').install Dir['illuminate_sysmon/*']
    share('graylog-illuminate/content_packs/illuminate_sysmon').chmod(0755)

    # Install scripts
    share('graylog-illuminate').install 'upload-content-packs.sh'
    share('graylog-illuminate/upload-content-packs.sh').chmod(0755)
  end
end
