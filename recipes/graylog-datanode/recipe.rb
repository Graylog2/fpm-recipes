require_relative '../tools'

class GraylogDataNode < FPM::Cookery::Recipe
  include Tools

  description 'Graylog data node'

  name     'graylog-datanode'
  version  data.version
  revision data.revision
  homepage data.homepage
  arch     pkg_arch

  source data.source
  sha256 data.sha256

  maintainer data.maintainer
  vendor     data.vendor
  license    data.license

  config_files '/etc/graylog/datanode/datanode.conf',
               '/etc/graylog/datanode/jvm.options',
               '/etc/graylog/datanode/log4j2.xml'

  targets :deb do
    section 'net'
    config_files '/etc/default/graylog-datanode'
    depends 'uuid-runtime'
  end

  targets :rpm do
    # Digest required to make packages work on FIPS enabled RedHat systems
    rpm_digest_algo 'sha256'
    config_files '/etc/sysconfig/graylog-datanode'
  end

  pre_install    'files/pre-install'
  post_install   'files/post-install'
  pre_uninstall  'files/pre-uninstall'
  post_uninstall 'files/post-uninstall'

  def build
    patch(workdir('patches/datanode.conf.patch'))
    patch(workdir('patches/log4j2.xml.patch'))
  end

  def install
    case target
    when :deb
      etc('default').install file('environment'), 'graylog-datanode'
    when :rpm
      etc('sysconfig').install file('environment'), 'graylog-datanode'
    end

    etc('graylog/datanode').install 'datanode.conf.example', 'datanode.conf'
    etc('graylog/datanode').install 'config/log4j2.xml', 'log4j2.xml'
    etc('graylog/datanode').install 'config/jvm.options', 'jvm.options'

    lib('systemd/system').install file('systemd.service'), 'graylog-datanode.service'

    share('graylog-datanode').install file("installation-source.#{target}.sh"), 'installation-source.sh'

    share('graylog-datanode').install 'bin'
    share('graylog-datanode').install 'dist'
    share('graylog-datanode').install 'graylog-datanode.jar'
    share('graylog-datanode').install 'jvm'
    share('graylog-datanode').install 'lib'
    share('graylog-datanode').install 'LICENSE'
  end
end
