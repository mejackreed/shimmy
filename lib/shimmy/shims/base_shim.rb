require 'hurley'

module Shimmy
  module Shimmy
    class BaseShim

      def initialize
        Hurley.get(base_url, params)
      end

      def base_url
        'http://www.example.com'
      end

      def params
        {}
      end

      ##
      # Method should return a serialized JSON string
      # @returns {String}
      def to_iiif
      end
    end
  end
end
