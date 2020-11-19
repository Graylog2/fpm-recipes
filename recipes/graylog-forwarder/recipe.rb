require_relative '../tools'

class GraylogForwarder < FPM::Cookery::Recipe
  include Tools

  description 'Graylog Forwarder'

  name     'graylog-forwarder'
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
    config_files '/etc/graylog/forwarder/forwarder.conf', '/etc/graylog/forwarder/jvm.options'
  end

  targets :rpm do
    config_files '/etc/graylog/forwarder/forwarder.conf', '/etc/graylog/forwarder/jvm.options'
  end

  pre_install    'files/pre-install'
  post_install   'files/post-install'
  pre_uninstall  'files/pre-uninstall'
  post_uninstall 'files/post-uninstall'

  def build
  end

  def install
    etc('graylog/forwarder').install file('forwarder.conf'), 'forwarder.conf'
    etc('graylog/forwarder').install Dir['config/jvm.options']

    share('graylog-forwarder').install 'graylog-cloud-forwarder.jar'

    share('graylog-forwarder').install 'bin'
    share('graylog-forwarder/bin').install Dir['bin/*']
    share('graylog-forwarder').install file('LICENSE')

    Dir['plugin/*.jar'].each {|jar| mv(jar, jar.gsub('-SNAPSHOT', "-#{revision}")) }
    share('graylog-forwarder').install 'plugin'
    share('graylog-forwarder/plugin').install Dir['plugin/*.jar']

    lib('systemd/system').install file('graylog-forwarder.service'), 'graylog-forwarder.service'
  end
end
