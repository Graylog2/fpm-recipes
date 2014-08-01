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

  def osfile(name)
    workdir(File.join('files', FPM::Cookery::Facts.platform.to_s, name))
  end

  def file(name)
    workdir(File.join('files', name))
  end
end

# WOW, monkeypatch! Calls after_build_package(output) on recipe if it exists.
module FPM
  module Cookery
    class Packager
      def build_package(recipe, config)
        recipe.pkgdir.mkdir
        Dir.chdir(recipe.pkgdir) do
          version = FPM::Cookery::Package::Version.new(recipe, @target, config)
          maintainer = FPM::Cookery::Package::Maintainer.new(recipe, config)

          input = recipe.input(config)

          input.version = version
          input.maintainer = maintainer.to_s
          input.vendor = version.vendor if version.vendor
          input.epoch = version.epoch if version.epoch

          add_scripts(recipe, input)
          remove_excluded_files(recipe)

          output_class = FPM::Package.types[@target]

          output = input.convert(output_class)

          begin
            output.output(output.to_s)

            if recipe.respond_to?(:after_build_package)
              recipe.after_build_package(output)
            end
          rescue FPM::Package::FileAlreadyExists
            Log.info "Removing existing package file: #{output.to_s}"
            FileUtils.rm_f(output.to_s)
            retry
          ensure
            input.cleanup if input
            output.cleanup if output
            Log.info "Created package: #{File.join(Dir.pwd, output.to_s)}"
          end
        end
      end
    end
  end
end
