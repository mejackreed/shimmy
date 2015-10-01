require 'hurley'
require 'nokogiri'
require 'iiif/presentation'

module Shimmy
  module Shims
    # A shim for the Johnson Space Center Image Collection
    class NaraSearch < BaseHttpShim
      attr_accessor :serach_term

      def initialize(search_term = 'donuts', rows = 10)
        @search_term = search_term
        @rows = rows
      end

      def response
        Hurley.get(base_url, params)
      end

      def base_url
        'https://catalog.archives.gov/api/v1/'
      end

      def parsed_response
        JSON.parse(response.body)['opaResponse']['results']['result']
      end

      def params
        {
          resultTypes: 'item,fileUnit',
          'objects.object.@objectSortNum' => 1,
          rows: @rows,
          q: @search_term
        }
      end

      def to_iiif(manifest_uri)
        manifest = IIIF::Presentation::Manifest.new(
          '@id' => manifest_uri,
          'label' => @search_term
        )

        sequence = IIIF::Presentation::Sequence.new

        parsed_response.each do |result|
          canvas = IIIF::Presentation::Canvas.new
          puts result['objects']['object']['file']['@url']
          puts result['description']['item']['title']
          iiifified = Shimmy::ImageRequestor.new(result['objects']['object']['file']['@url'])
          puts iiifified.service_url
          puts iiifified.profile
          canvas.width = iiifified.width.to_i
          canvas.height = iiifified.height.to_i
          canvas.label = result['description']['item']['title']
          canvas['@id'] = iiifified.service_url
          anno = IIIF::Presentation::Annotation.new()
          ic = IIIF::Presentation::ImageResource.create_image_api_image_resource(
            resource_id: result['objects']['object']['file']['@url'],
            service_id: iiifified.service_url,
            width: iiifified.width.to_i,
            height: iiifified.height.to_i,
            profile: iiifified.profile
          )
          anno.resource = ic
          canvas.images << anno
          sequence.canvases << canvas
        end
        manifest.sequences << sequence
        manifest.to_json(pretty: true)
      end
    end
  end
end