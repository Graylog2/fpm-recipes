require_relative '../tools'

class GraylogEnterprisePlugins < FPM::Cookery::Recipe
  include Tools

  description 'Graylog Enterprise plugins'

  name     'graylog-enterprise-plugins'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    'see https://www.graylog.org/enterprise'

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
    share('graylog-server/plugin').install 'LICENSE', 'LICENSE-ENTERPRISE'
    share('graylog-server/plugin').install Dir['plugin/*.jar']
  end
end
