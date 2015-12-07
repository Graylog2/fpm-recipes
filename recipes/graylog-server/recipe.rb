require_relative '../tools'

class GraylogServer < FPM::Cookery::Recipe
  include Tools

  description 'Graylog server'

  name     'graylog-server'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  replaces 'graylog2-server'

  config_files '/etc/graylog/server/server.conf',
               '/etc/graylog/server/log4j.xml'

  platforms [:ubuntu, :debian] do
    section 'net'
    depends 'uuid-runtime'

    fpm_attributes[:deb_recommends_given?] = true
    fpm_attributes[:deb_recommends] = [
      'java7-runtime-headless | openjdk-7-jre-headless'
    ]

    config_files '/etc/default/graylog-server'
  end

  platforms [:ubuntu] do
    config_files '/etc/init/graylog-server.conf'

    post_install "files/ubuntu/post-install"
    post_uninstall "files/ubuntu/post-uninstall"
  end

  platforms [:debian] do
    config_files '/etc/logrotate.d/graylog-server'

    case fact('operatingsystemmajrelease')
    when '7'
      config_files '/etc/init.d/graylog-server'

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
      depends 'util-linux-ng'

      config_files '/etc/init.d/graylog-server',
                   '/etc/sysconfig/graylog-server'

      post_install 'files/centos/post-install'
      pre_uninstall 'files/centos/pre-uninstall'
    when '7'
      depends 'util-linux'

      config_files '/etc/sysconfig/graylog-server'

      post_install 'files/centos/post-install-7'
      pre_uninstall 'files/centos/pre-uninstall-7'
    end
  end

  def build
    patch(workdir('patches/graylog-server.conf.patch'))
  end

  def install
    etc('graylog/server').install 'graylog.conf.example', 'server.conf'
    etc('graylog/server').install file('log4j.xml')

    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog-server.conf'
      etc('default').install osfile('default'), 'graylog-server'
      etc('init.d').mkpath
      safesystem "ln -sf /lib/init/upstart-job #{etc('init.d/graylog-server')}"
    when :debian
      case fact('operatingsystemmajrelease')
      when '7'
        etc('init.d').install osfile('init.d'), 'graylog-server'
        etc('init.d/graylog-server').chmod(0755)
      when '8'
        root('lib/systemd/system').install file('systemd.service'), 'graylog-server.service'
        share('graylog-server/bin').install file('graylog-server.sh'), 'graylog-server'
        share('graylog-server/bin/graylog-server').chmod(0755)
      end

      etc('default').install osfile('default'), 'graylog-server'
      etc('logrotate.d').install osfile('logrotate'), 'graylog-server'
    when :centos
      case fact('operatingsystemmajrelease')
      when '6'
        etc('init.d').install osfile('init.d'), 'graylog-server'
        etc('init.d/graylog-server').chmod(0755)
      when '7'
        lib('systemd/system').install file('systemd.service'), 'graylog-server.service'
        share('graylog-server/bin').install file('graylog-server.sh'), 'graylog-server'
        share('graylog-server/bin/graylog-server').chmod(0755)
      end

      etc('sysconfig').install osfile('sysconfig'), 'graylog-server'
    end

    target = FPM::Cookery::Facts.target
    share('graylog-server').install file("installation-source.#{target}.sh"), 'installation-source.sh'

    share('graylog-server').install 'graylog.jar'
    share('graylog-server').install 'lib'
    share('graylog-server').install 'plugin'
    share('graylog-server/contentpacks').install Dir['data/contentpacks/*.json']

    # Remove unused sigar libs.
    sigar_cleanup(share('graylog-server/lib/sigar'))
  end
end
