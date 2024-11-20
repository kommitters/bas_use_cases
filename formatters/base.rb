module Formatters
  class Base
    attr_reader :data

    def initialize
      @data = {}
    end

    def format(data)
      raise ArgumentError, 'Data must be a Hash' unless data.is_a?(Hash)
      @data = data
    end

    def process
      raise NotImplementedError, "#{self.class} must implement the #process method"
    end
  end
end
