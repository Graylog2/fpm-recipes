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
    'core',
    'windows',
    'okta',
    'paloalto',
    'o365',
    'template',
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
    etc('graylog/illuminate/core').install Dir['illuminate/core/*']
    etc('graylog/illuminate/core').chmod(0755)

    etc('graylog/illuminate/windows').install Dir['illuminate/windows/*']
    etc('graylog/illuminate/windows').chmod(0755)

    etc('graylog/illuminate/okta').install Dir['illuminate/okta/*']
    etc('graylog/illuminate/okta').chmod(0755)

    etc('graylog/illuminate/paloalto').install Dir['illuminate/paloalto/*']
    etc('graylog/illuminate/paloalto').chmod(0755)

    etc('graylog/illuminate/o365').install Dir['illuminate/o365/*']
    etc('graylog/illuminate/o365').chmod(0755)

    etc('graylog/illuminate/sysmon').install Dir['illuminate/sysmon/*']
    etc('graylog/illuminate').chmod(0755)
    etc('graylog/illuminate/sysmon').chmod(0755)

    etc('graylog/illuminate/elastic_template').install Dir['illuminate/elastic_template/*']
    etc('graylog/illuminate/elastic_template').chmod(0755)

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

    share('graylog-illuminate/content_packs/illuminate_sysmon').install Dir['illuminate_sysmon/*']
    share('graylog-illuminate/content_packs/illuminate_sysmon').chmod(0755)

    # Install scripts
    share('graylog-illuminate').install 'upload-content-packs.sh'
    share('graylog-illuminate/upload-content-packs.sh').chmod(0755)
  end
end
