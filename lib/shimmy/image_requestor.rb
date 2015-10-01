require 'hurley'
require 'json'

module Shimmy
  ##
  # IIIFifies a static image url
  class ImageRequestor
    IIIFIFY_SERVICE = 'http://dlss-dev-azaroth.stanford.edu/services/iiif/submit'
    attr_reader :response
    ##
    # @param {String} request_url Url to be IIIFified
    # @param {String} iiifify_service a Iiifify service url
    def initialize(request_url, iiifify_service = IIIFIFY_SERVICE)
      @request_url = request_url
      @iiifify_service = iiifify_service
      @response = parse_response
    end

    def service_url
      @response['@id']
    end

    def profile
      @repsonse['profile'][0]
    end

    def width
      @response['width']
    end

    def height
      @response['height']
    end

    private

    def parse_response
      JSON.parse(iiif_service.body)
    end

    ##
    # @return {Hurley::Response}
    def iiif_service
      response = Hurley.get(@iiifify_service, url: @request_url)
      fail 'Bad response' if response.status_code != 200
      fail 'Incorrect content type' if response.header['Content-Type'] != 'application/json' && response.header['Content-Type'] != 'application/ld+json'
      response
    end
  end
end
