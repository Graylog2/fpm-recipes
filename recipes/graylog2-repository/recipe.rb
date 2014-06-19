require_relative '../tools'

class Graylog2Release < FPM::Cookery::Recipe
  include Tools

  description 'Package to install Graylog2 GPG key and repository'

  name    "graylog2-repository-#{os}#{osrel}"
  version '1.0.0'
  revision 1
  source  '', :with => :noop
  arch    'all'

  def build
  end

  def install_deb
    dist = fact('lsbdistcodename').downcase

    File.open('graylog2.list', 'w') do |file|
      file.puts "deb http://packages.graylog2.org/repo/debian/ #{dist} main"
    end

    etc('apt/trusted.gpg.d').install workdir('files/deb/graylog2-keyring.gpg')
    etc('apt/sources.list.d').install 'graylog2.list'
  end

  def install_rpm
    etc('pki/rpm-gpg').install workdir('files/rpm/RPM-GPG-KEY-graylog2')
    etc('yum.repos.d').install workdir('files/rpm/graylog2.repo')
  end
end
