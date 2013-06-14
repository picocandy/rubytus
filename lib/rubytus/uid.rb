# encoding: utf-8
require 'securerandom'

module Rubytus
  class Uid
    def self.uid
      SecureRandom.hex(16)
    end
  end
end
