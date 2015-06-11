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
  end

  platforms [:ubuntu] do
    config_files '/etc/init/graylog-web.conf'

    post_install "files/ubuntu/post-install"
    post_uninstall "files/ubuntu/post-uninstall"
  end

  platforms [:debian] do
    config_files '/etc/logrotate.d/graylog-web'

    case fact('operatingsystemmajrelease')
    when '7'
      config_files '/etc/init.d/graylog-web'

      post_install "files/debian/post-install"
      post_uninstall "files/debian/post-uninstall"
    when '8'
      post_install "files/debian/post-install-8"
      post_uninstall "files/debian/post-uninstall-8"
    end
  end

  platforms [:centos] do
    case fact('operatingsystemmajrelease')
    when '6'
      config_files '/etc/init.d/graylog-web',
                   '/etc/sysconfig/graylog-web'

      post_install 'files/centos/post-install'
      pre_uninstall 'files/centos/pre-uninstall'
    when '7'
      config_files '/etc/sysconfig/graylog-web'

      post_install 'files/centos/post-install-7'
      pre_uninstall 'files/centos/pre-uninstall-7'
    end
  end

  def build
  end

  def install
    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog-web.conf'
      etc('default').install osfile('default'), 'graylog-web'
      etc('init.d').mkpath
      safesystem "ln -sf /lib/init/upstart-job #{etc('init.d/graylog-web')}"
    when :debian
      case fact('operatingsystemmajrelease')
      when '7'
        etc('init.d').install osfile('init.d'), 'graylog-web'
        etc('init.d/graylog-web').chmod(0755)
      when '8'
        root('lib/systemd/system').install file('systemd.service'), 'graylog-web.service'
        share('graylog-web/bin').install file('graylog-web.sh'), 'graylog-web'
        share('graylog-web/bin/graylog-web').chmod(0755)
      end

      etc('logrotate.d').install osfile('logrotate'), 'graylog-web'
      etc('default').install osfile('default'), 'graylog-web'
    when :centos
      case fact('operatingsystemmajrelease')
      when '6'
        etc('init.d').install osfile('init.d'), 'graylog-web'
        etc('init.d/graylog-web').chmod(0755)
      when '7'
        lib('systemd/system').install file('systemd.service'), 'graylog-web.service'
        share('graylog-web/bin').install file('graylog-web.sh'), 'graylog-web'
        share('graylog-web/bin/graylog-web').chmod(0755)
      end

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
