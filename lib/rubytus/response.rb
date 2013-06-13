require 'rack'

module Rubytus
  class Response < Rack::Response
    def initialize(body = [], status = 200, header = {})
      header['Content-Type']                  = 'text/plain; charset=utf-8'
      header['Access-Control-Allow-Origin']   = '*'
      header['Access-Control-Allow-Methods']  = 'HEAD,GET,PUT,POST,PATCH,DELETE'
      header['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, Content-Disposition, Final-Length, Offset'
      header['Access-Control-Expose-Headers'] = 'Location, Range, Content-Disposition, Offset'
      super
    end
  end
end
