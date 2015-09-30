require 'hurley'

module Shimmy
  module Shims
    ##
    # Base for creating an HTTP Shim
    class BaseHttpShim < BaseShim

      def initialize
        Hurley.get(base_url, params)
      end

      def base_url
        'http://www.example.com'
      end

      def params
        {}
      end
    end
  end
end
