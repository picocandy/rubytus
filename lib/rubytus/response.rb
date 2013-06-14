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

    def method_not_allowed!
      self.status = 405
    end

    def not_found!
      self.status = 404
    end

    def bad_request!
      self.status = 400
    end

    def server_error!
      self.status = 500
    end

    def created!
      self.status = 201
    end
  end
end
