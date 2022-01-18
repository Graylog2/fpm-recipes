require_relative '../tools'

class GraylogEnterprisePlugins < FPM::Cookery::Recipe
  include Tools

  description 'Graylog Enterprise plugins'

  name     'graylog-enterprise-plugins'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     pkg_arch

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
    share('graylog-server').install 'bin'
    # Install all binaries except the architecture specific ones.
    share('graylog-server/bin').install Dir['bin/*'].reject {|f| f =~ /\.(amd64|arm64)$/ }

    # Install the architecture specific binaries
    share('graylog-server/bin').install "bin/chromedriver_#{pkg_arch}", 'chromedriver'
    share('graylog-server/bin').install "bin/headless_shell_#{pkg_arch}", 'headless_shell'

    share('graylog-server').install 'plugin'
    share('graylog-server/plugin').install 'LICENSE', 'LICENSE-ENTERPRISE'
    share('graylog-server/plugin').install Dir['plugin/*.jar']
  end
end
