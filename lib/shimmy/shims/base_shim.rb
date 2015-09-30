require 'hurley'

module Shimmy
  module Shims
    class BaseShim

      def initialize
      end

      ##
      # Method should return a serialized JSON string
      # @param :manifest_uri URI for the manifest (used to populate top-level
      #   `@id` on the manifest JSON-LD)
      # @returns {String}
      def to_iiif(:manifest_uri)
      end
    end
  end
end
