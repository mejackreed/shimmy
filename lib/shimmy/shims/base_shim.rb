require 'hurley'
require 'github_api'
require 'shimmy/json_blob'

module Shimmy
  module Shims
    class BaseShim
      include Shimmy::Gistify
      include Shimmy::JsonBlob
      attr_reader :gist
      def initialize(params)
        @params = params
        gistify if params[:gistify] == true
      end

      ##
      # Method should return a serialized JSON string
      # @param :manifest_uri URI for the manifest (used to populate top-level
      #   `@id` on the manifest JSON-LD)
      # @returns {String}
      def to_iiif(manifest_uri: nil)
      end
    end
  end
end
