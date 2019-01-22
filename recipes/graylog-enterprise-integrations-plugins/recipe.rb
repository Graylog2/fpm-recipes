require_relative '../tools'

class GraylogEnterpriseIntegrationsPlugins < FPM::Cookery::Recipe
  include Tools

  description 'Graylog Enterprise Integrations plugins'

  name     'graylog-enterprise-integrations-plugins'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    'see https://www.graylog.org/'

  targets :deb do
    section 'net'
    depends "graylog-enterprise-plugins (>= #{data.version}-#{data.revision})"
  end

  targets :rpm do
    depends "graylog-enterprise-plugins >= #{data.version}-#{data.revision}"
  end

  def build
  end

  def install
    share('graylog-server').install 'plugin'
    share('graylog-server/plugin').install Dir['plugin/*.jar']
  end
end
