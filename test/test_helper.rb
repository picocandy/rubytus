require 'simplecov'
require 'minitest/autorun'
require 'minitest/pride'
require 'rr'
require 'goliath/test_helper'
require 'rubytus/error'
require 'rubytus/uid'
require 'pry'

Goliath.env = :test

module Rubytus
  module Mock
    def pdf
      File.expand_path('../files/protocol.pdf', __FILE__)
    end

    def data_dir
      "/tmp/rubytus-#{rand(1000)}"
    end

    def remove_data_dir
      FileUtils.rm_rf(Dir.glob("/tmp/rubytus-*"))
    end

    def uid
      Rubytus::Uid.uid
    end
  end
end
