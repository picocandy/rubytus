module Rubytus
  module Common
    def generate_uid
      SecureRandom.hex(16)
    end

    def error!(status, message)
      raise Goliath::Validation::Error.new(status, message)
    end
  end
end
