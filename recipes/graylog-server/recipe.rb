require_relative '../tools'

class GraylogServer < FPM::Cookery::Recipe
  include Tools

  description 'Graylog server'

  name     'graylog-server'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     pkg_arch

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  replaces 'graylog2-server', 'graylog-integrations-plugins'
  conflicts 'graylog2-web', 'graylog-web', 'graylog',
            'graylog-integrations-plugins',
            'graylog-enterprise-plugins',
            'graylog-enterprise-integrations-plugins',
            'graylog-enterprise'

  config_files '/etc/graylog/server/server.conf',
               '/etc/graylog/server/log4j2.xml',
               '/etc/init.d/graylog-server'

  targets :deb do
    section 'net'
    config_files '/etc/default/graylog-server',
                 '/etc/init/graylog-server.conf',
                 '/etc/logrotate.d/graylog-server'
    depends 'uuid-runtime'
  end

  targets :rpm do
    config_files '/etc/sysconfig/graylog-server'
  end

  pre_install    'files/pre-install'
  post_install   'files/post-install'
  pre_uninstall  'files/pre-uninstall'
  post_uninstall 'files/post-uninstall'

  def build
    patch(workdir('patches/graylog-server.conf.patch'))
  end

  def install
    case target
    when :deb
      etc('default').install file('environment'), 'graylog-server'
      etc('init').install file('deb/upstart.conf'), 'graylog-server.conf'
      etc('logrotate.d').install file('deb/logrotate'), 'graylog-server'
    when :rpm
      etc('sysconfig').install file('environment'), 'graylog-server'
    end

    etc('graylog/server').install 'graylog.conf.example', 'server.conf'
    etc('graylog/server').install file('log4j2.xml')

    etc('init.d').install file("#{target}/init.d"), 'graylog-server'
    etc('init.d/graylog-server').chmod(0755)

    lib('systemd/system').install file('systemd.service'), 'graylog-server.service'

    share('graylog-server/bin').install file('graylog-server.sh'), 'graylog-server'
    share('graylog-server/bin/graylog-server').chmod(0755)
    share('graylog-server').install file("installation-source.#{target}.sh"), 'installation-source.sh'

    share('graylog-server').install 'graylog.jar'
    share('graylog-server').install 'jvm'
    share('graylog-server').install 'plugin'
    share('graylog-server').install 'LICENSE'
  end
end
