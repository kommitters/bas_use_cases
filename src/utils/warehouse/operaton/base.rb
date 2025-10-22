# frozen_string_literal: true

module Utils
  module Warehouse
    module Operaton
      ##
      # Base class for Operaton data handling.
      # This class can be extended to include specific data processing methods.
      class Base
        def initialize(operaton_data)
          @data = operaton_data
        end
      end
    end
  end
end
