require_relative '../tools'

class Graylog2Radio < FPM::Cookery::Recipe
  include Tools

  description 'Graylog2 radio'

  name     'graylog2-radio'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  config_files '/etc/graylog2-radio.conf',
               '/etc/graylog2/radio/log4j.xml'

  platforms [:ubuntu, :debian] do
    section 'net'
    depends 'java7-runtime-headless | openjdk-7-jre-headless', 'uuid-runtime'

    config_files '/etc/default/graylog2-radio'

    post_install "files/#{platform}/post-install"
    post_uninstall "files/#{platform}/post-uninstall"
  end

  platforms [:ubuntu] do
    config_files '/etc/init/graylog2-radio.conf'
  end

  platforms [:debian] do
    config_files '/etc/init.d/graylog2-radio',
                 '/etc/logrotate.d/graylog2-radio'
  end

  platforms [:centos] do
    depends 'java >= 1:1.7.0', 'util-linux-ng'

    config_files '/etc/init.d/graylog2-radio',
                 '/etc/sysconfig/graylog2-radio'

    post_install 'files/centos/post-install'
    pre_uninstall 'files/centos/pre-uninstall'
  end

  def build
    patch(workdir('patches/graylog2-radio.conf.patch'))
  end

  def install
    etc.install 'graylog2-radio.conf.example', 'graylog2-radio.conf'
    etc('graylog2/radio').install file('log4j.xml')

    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog2-radio.conf'
      etc('default').install osfile('default'), 'graylog2-radio'
    when :debian
      etc('init.d').install osfile('init.d'), 'graylog2-radio'
      etc('init.d/graylog2-radio').chmod(0755)
      etc('default').install osfile('default'), 'graylog2-radio'
      etc('logrotate.d').install osfile('logrotate'), 'graylog2-radio'
    when :centos
      etc('init.d').install osfile('init.d'), 'graylog2-radio'
      etc('init.d/graylog2-radio').chmod(0755)
      etc('sysconfig').install osfile('sysconfig'), 'graylog2-radio'
    end

    share('graylog2-radio').install 'graylog2-radio.jar'
  end
end
