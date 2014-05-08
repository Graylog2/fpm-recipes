class Graylog2Server < FPM::Cookery::Recipe
  description 'Graylog2 server'

  name     'graylog2-server'
  version  '0.20.1'
  homepage 'http://graylog2.org/'
  arch     'all'

  source "https://github.com/Graylog2/graylog2-server/releases/download/#{version}/graylog2-server-#{version}.tgz"
  sha256 'b8e37ad46f3a4cdd5369f2c5e794b494d55af5b3aac1ae4a81432760caa27fa3'

  maintainer 'TORCH GmbH <hello@torch.sh>'
  vendor     'torch'
  license    'GPLv3'

  config_files '/etc/graylog2.conf',
               '/etc/graylog2/server/log4j.xml'

  platforms [:ubuntu] do
    section 'net'
    depends 'openjdk-7-jre-headless'#, 'mongodb', 'elasticsearch'

    config_files '/etc/init/graylog2-server.conf',
                 '/etc/default/graylog2-server'

    post_install 'files/ubuntu/post-install'
    post_uninstall 'files/ubuntu/post-uninstall'
  end

  platforms [:centos] do
    depends 'java-1.7.0-openjdk'#, 'mongodb', 'elasticsearch'
  end

  def build
    patch(workdir('patches/graylog2-server.conf.patch'))
  end

  def install
    etc.install 'graylog2.conf.example', 'graylog2.conf'
    etc('graylog2/server').install file('log4j.xml')

    case FPM::Cookery::Facts.platform
    when :ubuntu
      etc('init').install osfile('upstart.conf'), 'graylog2-server.conf'
      etc('default').install osfile('default'), 'graylog2-server'
    end

    share('graylog2-server').install 'graylog2-server.jar'
    share('graylog2-server/plugin').mkpath
  end

  private

  def osfile(name)
    workdir(File.join('files', FPM::Cookery::Facts.platform.to_s, name))
  end

  def file(name)
    workdir(File.join('files', name))
  end
end
