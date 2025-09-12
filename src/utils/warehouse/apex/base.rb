# frozen_string_literal: true

module Utils
  module Warehouse
    module Apex
      ##
      # Base class for APEX data handling.
      # This class can be extended to include specific data processing methods.
      class Base
        def initialize(apex_data)
          @data = apex_data
        end
      end
    end
  end
end
