require 'json'

module Rubytus
  class Info < Hash
    def initialize(args = {})
      self['Offset']       = args[:offset]        || 0
      self['EntityLength'] = args[:entity_length] || 0
      self['Meta']         = args[:meta]          || nil
    end

    def offset=(value)
      self['Offset'] = value.to_i
    end

    def offset
      self['Offset']
    end

    def entity_length=(value)
      self['EntityLength'] = value.to_i
    end

    def entity_length
      self['EntityLength']
    end

    def remaining_length
      entity_length - offset
    end
  end
end
