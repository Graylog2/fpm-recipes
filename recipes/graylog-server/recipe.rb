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
    depends 'java7-runtime-headless | openjdk-7-jre-headless', 'uuid-runtime'

    config_files '/etc/default/graylog-server'

    post_install "files/#{platform}/post-install"
    post_uninstall "files/#{platform}/post-uninstall"
  end

  platforms [:ubuntu] do
    config_files '/etc/init/graylog-server.conf'
  end

  platforms [:debian] do
    config_files '/etc/init.d/graylog-server',
                 '/etc/logrotate.d/graylog-server'
  end

  platforms [:centos] do
    depends 'java >= 1:1.7.0', 'util-linux-ng'

    config_files '/etc/init.d/graylog-server',
                 '/etc/sysconfig/graylog-server'

    post_install 'files/centos/post-install'
    pre_uninstall 'files/centos/pre-uninstall'
  end

  def build
    patch(workdir('patches/graylog-server.conf.patch'))
    patch(workdir('patches/graylog-es-timestamp-fixup.patch'))
  end

  def install
    etc('graylog/server').install 'graylog.conf.example', 'server.conf'
    etc('graylog/server').install file('log4j.xml')

    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog-server.conf'
      etc('default').install osfile('default'), 'graylog-server'
    when :debian
      etc('init.d').install osfile('init.d'), 'graylog-server'
      etc('init.d/graylog-server').chmod(0755)
      etc('default').install osfile('default'), 'graylog-server'
      etc('logrotate.d').install osfile('logrotate'), 'graylog-server'
    when :centos
      etc('init.d').install osfile('init.d'), 'graylog-server'
      etc('init.d/graylog-server').chmod(0755)
      etc('sysconfig').install osfile('sysconfig'), 'graylog-server'
    end

    share('graylog-server').install 'graylog.jar'
    share('graylog-server/plugin').mkpath
    share('graylog-server/bin').install 'bin/graylog-es-timestamp-fixup'
    share('graylog-server').install 'lib'

    # Remove unused sigar libs.
    sigar_cleanup(share('graylog-server/lib/sigar'))
  end
end
