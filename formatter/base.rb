# frozen_string_literal: true

module Formatter
  ##
  # The Formatter::Base module defines the structure for the modules to format
  # the standard data structures used by the chat-bots.
  #
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
