class Graylog2Radio < FPM::Cookery::Recipe
  description 'Graylog2 radio'

  name     'graylog2-radio'
  version  '0.20.3'
  revision 1
  homepage 'http://graylog2.org/'
  arch     'all'

  source "https://github.com/Graylog2/graylog2-server/releases/download/#{version}/graylog2-radio-#{version}.tgz"
  sha256 '6ab30925184328178480d8878024a32bbe5cac9cac03c3dbb7ce660a0b64981d'

  maintainer 'TORCH GmbH <hello@torch.sh>'
  vendor     'torch'
  license    'GPLv3'

  config_files '/etc/graylog2-radio.conf',
               '/etc/graylog2/radio/log4j.xml'

  platforms [:ubuntu, :debian] do
    section 'net'
    depends 'openjdk-7-jre-headless', 'uuid-runtime'

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
    depends 'java-1.7.0-openjdk', 'util-linux-ng'

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

  private

  def osfile(name)
    workdir(File.join('files', FPM::Cookery::Facts.platform.to_s, name))
  end

  def file(name)
    workdir(File.join('files', name))
  end
end
