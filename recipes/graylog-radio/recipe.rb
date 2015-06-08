require_relative '../tools'

class GraylogRadio < FPM::Cookery::Recipe
  include Tools

  description 'Graylog radio'

  name     'graylog-radio'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  replaces 'graylog2-radio'

  config_files '/etc/graylog/radio/radio.conf',
               '/etc/graylog/radio/log4j.xml'

  platforms [:ubuntu, :debian] do
    section 'net'
    depends 'uuid-runtime'

    fpm_attributes[:deb_recommends_given?] = true
    fpm_attributes[:deb_recommends] = [
      'java7-runtime-headless | openjdk-7-jre-headless'
    ]

    config_files '/etc/default/graylog-radio'

    post_install "files/#{platform}/post-install"
    post_uninstall "files/#{platform}/post-uninstall"
  end

  platforms [:ubuntu] do
    config_files '/etc/init/graylog-radio.conf'
  end

  platforms [:debian] do
    config_files '/etc/init.d/graylog-radio',
                 '/etc/logrotate.d/graylog-radio'
  end

  platforms [:centos] do
    case fact('operatingsystemmajrelease')
    when '6'
      depends 'util-linux-ng'

      config_files '/etc/init.d/graylog-radio',
                   '/etc/sysconfig/graylog-radio'

      post_install 'files/centos/post-install'
      pre_uninstall 'files/centos/pre-uninstall'
    when '7'
      depends 'util-linux'

      config_files '/usr/lib/systemd/system/graylog-radio.service',
                   '/usr/lib/systemd/scripts/graylog-radio-env.sh',
                   '/etc/sysconfig/graylog-radio'

      post_install 'files/centos/post-install-7'
      pre_uninstall 'files/centos/pre-uninstall-7'
    end
  end

  def build
    patch(workdir('patches/graylog-radio.conf.patch'))
  end

  def install
    etc('graylog/radio').install 'graylog-radio.conf.example', 'radio.conf'
    etc('graylog/radio').install file('log4j.xml')

    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog-radio.conf'
      etc('default').install osfile('default'), 'graylog-radio'
      etc('init.d').mkpath
      safesystem "ln -sf /lib/init/upstart-job #{etc('init.d/graylog-radio')}"
    when :debian
      etc('init.d').install osfile('init.d'), 'graylog-radio'
      etc('init.d/graylog-radio').chmod(0755)
      etc('default').install osfile('default'), 'graylog-radio'
      etc('logrotate.d').install osfile('logrotate'), 'graylog-radio'
    when :centos
      case fact('operatingsystemmajrelease')
      when '6'
        etc('init.d').install osfile('init.d'), 'graylog-radio'
        etc('init.d/graylog-radio').chmod(0755)
      when '7'
        lib('systemd/system').install osfile('systemd.service'), 'graylog-radio.service'
        lib('systemd/scripts').install osfile('graylog-radio-env.sh'), 'graylog-radio-env.sh'
        lib('systemd/scripts/graylog-radio-env.sh').chmod(0755)
      end
      etc('sysconfig').install osfile('sysconfig'), 'graylog-radio'
    end

    share('graylog-radio/plugin').mkpath
    share('graylog-radio').install 'graylog.jar'
    share('graylog-radio').install 'lib'

    # Remove unused sigar libs.
    sigar_cleanup(share('graylog-radio/lib/sigar'))
  end
end
