require 'rack'

module Rubytus
  class Response < Rack::Response
    def initialize(body = [], status = 200, header = {})
      header['Content-Type'] = 'text/plain; charset=utf-8'
      super
    end
  end
end
