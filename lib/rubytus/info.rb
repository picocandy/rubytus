require 'json'

module Rubytus
  class Info < Hash
    def initialize(args = {})
      self['Offset']      = args[:offset]       || 0
      self['FinalLength'] = args[:final_length] || 0
      self['Meta']        = args[:meta]         || nil
    end

    def offset=(value)
      self['Offset'] = value.to_i
    end

    def offset
      self['Offset']
    end

    def final_length=(value)
      self['FinalLength'] = value.to_i
    end

    def final_length
      self['FinalLength']
    end

    def remaining_length
      final_length - offset
    end
  end
end
