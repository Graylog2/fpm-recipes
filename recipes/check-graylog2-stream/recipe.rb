require_relative '../tools'

class CheckGraylog2Stream < FPM::Cookery::Recipe
  include Tools

  description 'Icinga/Nagios check plugin for Graylog2 stream alerts'
  name 'check-graylog2-stream'

  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'x86_64'

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
    lib("nagios/plugins").install 'check-graylog2-stream'
  end
end
