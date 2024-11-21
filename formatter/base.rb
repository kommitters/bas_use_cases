module Formatter
  class Base
    attr_reader :data

    def initialize
      @data = {}
    end

    def process
      raise NotImplementedError, "#{self.class} must implement the #process method"
    end
  end
end
