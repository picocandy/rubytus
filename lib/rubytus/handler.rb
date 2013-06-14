require 'rubytus/uid'

module Rubytus
  class Handler
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def uid
      Rubytus::Uid.uid
    end
  end
end
