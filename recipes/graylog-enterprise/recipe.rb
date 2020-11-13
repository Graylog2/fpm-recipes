require_relative '../tools'

class GraylogEnterpriseServer < FPM::Cookery::Recipe
  include Tools

  description 'Graylog Enterprise Server'

  name     'graylog-enterprise'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     'all'

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  replaces 'graylog-server', 'graylog-enterprise-plugins', 'graylog-integrations-plugins', 'graylog-enterprise-integrations-plugins'
  conflicts 'graylog2-web', 'graylog-web', 'graylog', 'graylog2-server'

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

  # Use scripts from server recipe to avoid duplicating them
  pre_install    '../graylog-server/files/pre-install'
  post_install   '../graylog-server/files/post-install'
  pre_uninstall  '../graylog-server/files/pre-uninstall'
  post_uninstall '../graylog-server/files/post-uninstall'

  def build
    patch(workdir('../graylog-server/patches/graylog-server.conf.patch'))
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
    share('graylog-server').install 'lib'
    share('graylog-server').install 'plugin'

    share('graylog-server').install 'LICENSE'
    share('graylog-server/bin').install 'bin/chromedriver'
    share('graylog-server/bin').install 'bin/chromedriver_start.sh'
    share('graylog-server/bin').install 'bin/headless_shell'

    # Remove unused sigar libs.
    sigar_cleanup(share('graylog-server/lib/sigar'))
  end

  # Override inherited method to make use of files in the server recipe to
  # avoid duplicating the files in this one
  def file(path)
    if File.exists?(super(path))
      # If the requested file exists in this recipe folder, use it
      super(path)
    else
      # Otherwise use the one from the server recipe
      workdir('../graylog-server/files')/path
    end
  end
end
