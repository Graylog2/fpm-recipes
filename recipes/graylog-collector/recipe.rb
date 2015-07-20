require_relative '../tools'

class GraylogCollector < FPM::Cookery::Recipe
  include Tools

  description 'Graylog collector'

  name     'graylog-collector'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  config_files '/etc/graylog/collector/collector.conf',
               '/etc/graylog/collector/log4j2.xml'

  platforms [:ubuntu, :debian] do
    section 'net'
    depends 'uuid-runtime'

    fpm_attributes[:deb_recommends_given?] = true
    fpm_attributes[:deb_recommends] = [
      'java7-runtime-headless | openjdk-7-jre-headless'
    ]

    config_files '/etc/default/graylog-collector'
  end

  platforms [:ubuntu] do
    config_files '/etc/init/graylog-collector.conf'

    post_install "files/ubuntu/post-install"
    post_uninstall "files/ubuntu/post-uninstall"
  end

  platforms [:debian] do
    case fact('operatingsystemmajrelease')
    #when '7'
      #config_files '/etc/init.d/graylog-collector'

      #post_install "files/debian/post-install"
      #post_uninstall "files/debian/post-uninstall"
    when '8'
      post_install "files/debian/post-install-systemd"
      post_uninstall "files/debian/post-uninstall-systemd"
    end
  end

  platforms [:centos] do
    case fact('operatingsystemmajrelease')
    #when '6'
      #depends 'util-linux-ng'

      #config_files '/etc/init.d/graylog-collector',
      #             '/etc/sysconfig/graylog-collector'

      #post_install 'files/centos/post-install'
      #pre_uninstall 'files/centos/pre-uninstall'
    when '7'
      depends 'util-linux'

      config_files '/etc/sysconfig/graylog-collector'

      post_install 'files/centos/post-install-systemd'
      pre_uninstall 'files/centos/pre-uninstall-systemd'
    end
  end

  def build
    patch(workdir('patches/collector.conf.patch'))
    patch(workdir('patches/graylog-collector-script-config.sh.patch'))
  end

  def install
    etc('graylog/collector').install 'config/collector.conf.example', 'collector.conf'
    etc('graylog/collector').install file('log4j2.xml')

    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog-collector.conf'
      etc('default').install file('default.sysconfig'), 'graylog-collector'
      etc('init.d').mkpath
      safesystem "ln -sf /lib/init/upstart-job #{etc('init.d/graylog-collector')}"
    when :debian
      case fact('operatingsystemmajrelease')
      #when '7'
        #etc('init.d').install osfile('init.d'), 'graylog-collector'
        #etc('init.d/graylog-collector').chmod(0755)
      when '8'
        root('lib/systemd/system').install file('systemd.service'), 'graylog-collector.service'
      end

      etc('default').install file('default.sysconfig'), 'graylog-collector'
    when :centos
      case fact('operatingsystemmajrelease')
      #when '6'
        #etc('init.d').install osfile('init.d'), 'graylog-collector'
        #etc('init.d/graylog-collector').chmod(0755)
      when '7'
        lib('systemd/system').install file('systemd.service'), 'graylog-collector.service'
      end

      etc('sysconfig').install file('default.sysconfig'), 'graylog-collector'
    end

    share('graylog-collector/bin').install 'bin/graylog-collector'
    share('graylog-collector').install 'bin/graylog-collector-script-config.sh'
    share('graylog-collector').install 'graylog-collector.jar'
    share('graylog-collector').install 'lib'

    # Remove unused sigar libs.
    sigar_cleanup(share('graylog-collector/lib/sigar'))
  end
end
