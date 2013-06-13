require 'rubytus/uid'

module Rubytus
  class Handler
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
      prepare
    end

    def prepare
      # catch error if we can't make directory
      unless File.directory?(configuration.data_dir)
        Dir.mkdir(configuration.data_dir)
        File.chmod(0777, configuration.data_dir)
      end
    end

    def uid
      Rubytus::Uid.uid
    end
  end
end
