require_relative '../tools'

class GraylogIntegrationsPlugins < FPM::Cookery::Recipe
  include Tools

  description 'Graylog Integrations plugins'

  name     'graylog-integrations-plugins'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  targets :deb do
    section 'net'
    depends "graylog-server (>= #{data.version}-#{data.revision})"
  end

  targets :rpm do
    depends "graylog-server >= #{data.version}-#{data.revision}"
  end

  def build
  end

  def install
    share('graylog-server').install 'plugin'
    share('graylog-server/plugin').install Dir['plugin/*.jar']
  end
end
