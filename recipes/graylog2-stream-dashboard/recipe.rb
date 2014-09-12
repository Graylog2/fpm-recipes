require_relative '../tools'

class Graylog2StreamDashboard < FPM::Cookery::Recipe
  include Tools

  description 'Graylog2 Stream Dashboard'
  name 'graylog2-stream-dashboard'

  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  platforms [:ubuntu, :debian] do
    section 'utils'
  end

  def build
  end

  def install
    case FPM::Cookery::Facts.platform
    when :ubuntu, :debian
      doc("graylog2-stream-dashboard").install file('README.Debian')
    end

    share("graylog2-stream-dashboard").install Dir['app/*']
  end

end
