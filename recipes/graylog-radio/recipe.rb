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

  config_files '/etc/graylog/radio/radio.conf',
               '/etc/graylog/radio/log4j.xml'

  platforms [:ubuntu, :debian] do
    section 'net'
    depends 'java7-runtime-headless | openjdk-7-jre-headless', 'uuid-runtime'

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
    depends 'java >= 1:1.7.0', 'util-linux-ng'

    config_files '/etc/init.d/graylog-radio',
                 '/etc/sysconfig/graylog-radio'

    post_install 'files/centos/post-install'
    pre_uninstall 'files/centos/pre-uninstall'
  end

  def build
    patch(workdir('patches/graylog-radio.conf.patch'))
  end

  def install
    etc('graylog/radio').install 'graylog2-radio.conf.example', 'radio.conf'
    etc('graylog/radio').install file('log4j.xml')

    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog-radio.conf'
      etc('default').install osfile('default'), 'graylog-radio'
    when :debian
      etc('init.d').install osfile('init.d'), 'graylog-radio'
      etc('init.d/graylog-radio').chmod(0755)
      etc('default').install osfile('default'), 'graylog-radio'
      etc('logrotate.d').install osfile('logrotate'), 'graylog-radio'
    when :centos
      etc('init.d').install osfile('init.d'), 'graylog-radio'
      etc('init.d/graylog-radio').chmod(0755)
      etc('sysconfig').install osfile('sysconfig'), 'graylog-radio'
    end

    share('graylog-radio/plugin').mkpath
    share('graylog-radio').install 'graylog2.jar', 'graylog.jar'
    share('graylog-radio').install 'lib'

    # Remove unused sigar libs.
    sigar_cleanup(share('graylog-radio/lib/sigar'))
  end
end
