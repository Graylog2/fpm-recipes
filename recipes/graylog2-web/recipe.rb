class Graylog2Web < FPM::Cookery::Recipe
  description 'Graylog2 web'

  name     'graylog2-web'
  version  '0.20.2'
  revision 2
  homepage 'http://graylog2.org/'
  arch     'all'

  source "https://github.com/Graylog2/graylog2-web-interface/releases/download/#{version}/graylog2-web-interface-#{version}.tgz"
  sha256 'a2e9a456f3a7c2de48de3b9f32254fb6861376f52721a1967c38b7debebff64c'

  maintainer 'TORCH GmbH <hello@torch.sh>'
  vendor     'torch'
  license    'GPLv3'

  config_files '/etc/graylog2/web/application.conf',
               '/etc/graylog2/web/graylog2-web-interface.conf',
               '/etc/graylog2/web/logback.xml',
               '/etc/graylog2/web/play.plugins'

  platforms [:ubuntu, :debian] do
    section 'net'
    depends 'openjdk-7-jre-headless'

    config_files '/etc/default/graylog2-web'

    post_install "files/#{platform}/post-install"
    post_uninstall "files/#{platform}/post-uninstall"
  end

  platforms [:ubuntu] do
    config_files '/etc/init/graylog2-web.conf'
  end

  platforms [:debian] do
    config_files '/etc/init.d/graylog2-web'
  end

  platforms [:centos] do
    depends 'java-1.7.0-openjdk'

    config_files '/etc/init.d/graylog2-web',
                 '/etc/sysconfig/graylog2-web'

    post_install 'files/centos/post-install'
    pre_uninstall 'files/centos/pre-uninstall'
  end

  def build
  end

  def install
    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog2-web.conf'
      etc('default').install osfile('default'), 'graylog2-web'
    when :debian
      etc('init.d').install osfile('init.d'), 'graylog2-web'
      etc('init.d/graylog2-web').chmod(0755)
      etc('default').install osfile('default'), 'graylog2-web'
      etc('logrotate.d').install osfile('logrotate'), 'graylog2-web'
    when :centos
      etc('init.d').install osfile('init.d'), 'graylog2-web'
      etc('init.d/graylog2-web').chmod(0755)
      etc('sysconfig').install osfile('sysconfig'), 'graylog2-web'
    end

    etc('graylog2/web').install Dir['conf/*']
    etc('graylog2/web').install file('logback.xml')

    share('graylog2-web').install %w(README.md lib share)
    share('graylog2-web/bin').install 'bin/graylog2-web-interface'

    safesystem "ln -sf /etc/graylog2/web #{share("graylog2-web/conf")}"
  end

  private

  def osfile(name)
    workdir(File.join('files', FPM::Cookery::Facts.platform.to_s, name))
  end

  def file(name)
    workdir(File.join('files', name))
  end
end
