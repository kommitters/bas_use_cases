module Formatter
  class Base
    attr_reader :data

    def initialize
      @data = {}
    end

    def process
      raise NotImplementedError, "#{self.class} must implement the #process method"
    end

    protected

    def format(data)
      raise ArgumentError, 'Data must be a Hash' unless data.is_a?(Hash)
      @data = data
    end
  end
end
