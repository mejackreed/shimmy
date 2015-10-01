require 'faraday'

module Shimmy
  module JsonBlob

    def blob_location
      jsonify unless @blob
      @blob.header['Location'].gsub('http:', 'https:')
    end

    ##
    # Updates a blob hosted on JsonBlob with IIIF manifest. Preferred interface
    # module
    # @returns {String} url to blob
    def update_blob
      Hurley.put(blob_location) do |req|
        req.header[:content_type] = 'application/json'
        req.header[:accept] = 'application/json'
        req.body = to_iiif(blob_location)
      end
      blob_location
    end

    private

    def jsonify
      @blob ||= Hurley.post('https://jsonblob.com/api/jsonBlob') do |req|
        req.header[:content_type] = 'application/json'
        req.body = {}.to_json
      end
    end

    def blob_id
      jsonify unless @blob
      @blob.header['X-Jsonblob']
    end
  end
end
