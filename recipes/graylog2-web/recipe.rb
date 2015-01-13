require_relative '../tools'

class Graylog2Web < FPM::Cookery::Recipe
  include Tools

  description 'Graylog2 web'

  name     'graylog2-web'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  config_files '/etc/graylog2/web/application.conf',
               '/etc/graylog2/web/web.conf',
               '/etc/graylog2/web/logback.xml',
               '/etc/graylog2/web/play.plugins'

  platforms [:ubuntu, :debian] do
    section 'net'
    depends 'java7-runtime-headless | openjdk-7-jre-headless'

    config_files '/etc/default/graylog2-web'

    post_install "files/#{platform}/post-install"
    post_uninstall "files/#{platform}/post-uninstall"
  end

  platforms [:ubuntu] do
    config_files '/etc/init/graylog2-web.conf'
  end

  platforms [:debian] do
    config_files '/etc/init.d/graylog2-web'
  end

  platforms [:centos] do
    depends 'java >= 1:1.7.0'

    config_files '/etc/init.d/graylog2-web',
                 '/etc/sysconfig/graylog2-web'

    post_install 'files/centos/post-install'
    pre_uninstall 'files/centos/pre-uninstall'
  end

  def build
  end

  def install
    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog2-web.conf'
      etc('default').install osfile('default'), 'graylog2-web'
    when :debian
      etc('init.d').install osfile('init.d'), 'graylog2-web'
      etc('init.d/graylog2-web').chmod(0755)
      etc('default').install osfile('default'), 'graylog2-web'
      etc('logrotate.d').install osfile('logrotate'), 'graylog2-web'
    when :centos
      etc('init.d').install osfile('init.d'), 'graylog2-web'
      etc('init.d/graylog2-web').chmod(0755)
      etc('sysconfig').install osfile('sysconfig'), 'graylog2-web'
    end

    etc('graylog2/web').install Dir['conf/*']
    etc('graylog2/web').install file('logback.xml')

    # Rename web interface config to be consistent with server and radio.
    mv etc('graylog2/web/graylog2-web-interface.conf'), etc('graylog2/web/web.conf')

    share('graylog2-web').install %w(README.md lib)
    share('graylog2-web/bin').install 'bin/graylog2-web-interface'

    safesystem "ln -sf /etc/graylog2/web #{share("graylog2-web/conf")}"
  end
end
