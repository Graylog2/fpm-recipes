module Tools
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def fact(key)
      Facter.fact(key).value
    rescue NoMethodError
      raise "No fact for: #{key}"
    end

    def os
      fact('operatingsystem').downcase
    end

    def osrel
       osrel = fact('operatingsystemrelease').downcase

       case os
       when 'debian', 'centos'
         osrel.split('.').first
       else
         osrel
       end
    end
  end

  def fact(key)
    self.class.fact(key)
  end

  def os
    self.class.os
  end

  def osrel
    self.class.osrel
  end

  def install
    case os
    when 'debian', 'ubuntu'
      install_deb
    when 'centos'
      install_rpm
    else
      raise "Unknown OS: #{os}"
    end
  end
end
