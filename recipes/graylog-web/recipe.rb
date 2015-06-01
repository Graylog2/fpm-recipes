require_relative '../tools'

class GraylogWeb < FPM::Cookery::Recipe
  include Tools

  description 'Graylog web'

  name     'graylog-web'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  replaces 'graylog2-web'

  config_files '/etc/graylog/web/application.conf',
               '/etc/graylog/web/web.conf',
               '/etc/graylog/web/logback.xml',
               '/etc/graylog/web/play.plugins'

  platforms [:ubuntu, :debian] do
    section 'net'

    fpm_attributes[:deb_recommends_given?] = true
    fpm_attributes[:deb_recommends] = [
      'java7-runtime-headless | openjdk-7-jre-headless'
    ]

    config_files '/etc/default/graylog-web'

    post_install "files/#{platform}/post-install"
    post_uninstall "files/#{platform}/post-uninstall"
  end

  platforms [:ubuntu] do
    config_files '/etc/init/graylog-web.conf'
  end

  platforms [:debian] do
    config_files '/etc/init.d/graylog-web'
  end

  platforms [:centos] do
    config_files '/etc/init.d/graylog-web',
                 '/etc/sysconfig/graylog-web'

    post_install 'files/centos/post-install'
    pre_uninstall 'files/centos/pre-uninstall'
  end

  def build
  end

  def install
    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog-web.conf'
      etc('default').install osfile('default'), 'graylog-web'
    when :debian
      etc('init.d').install osfile('init.d'), 'graylog-web'
      etc('init.d/graylog-web').chmod(0755)
      etc('default').install osfile('default'), 'graylog-web'
      etc('logrotate.d').install osfile('logrotate'), 'graylog-web'
    when :centos
      etc('init.d').install osfile('init.d'), 'graylog-web'
      etc('init.d/graylog-web').chmod(0755)
      etc('sysconfig').install osfile('sysconfig'), 'graylog-web'
    end

    etc('graylog/web').install Dir['conf/*']
    etc('graylog/web').install file('logback.xml')

    # Rename web interface config to be consistent with server and radio.
    mv etc('graylog/web/graylog-web-interface.conf'), etc('graylog/web/web.conf')

    share('graylog-web').install %w(README.md lib)
    share('graylog-web/bin').install 'bin/graylog-web-interface'

    safesystem "ln -sf /etc/graylog/web #{share("graylog-web/conf")}"
  end
end
