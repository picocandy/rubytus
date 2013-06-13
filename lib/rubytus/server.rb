module Rubytus
  class Server
    def initialize(app)
      @app = app
    end

    def call(env)
      @response = Rubytus::Response.new
      @response.finish
    end
  end
end
