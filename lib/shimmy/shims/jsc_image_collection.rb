require 'hurley'
require 'nokogiri'
require 'iiif/presentation'

module Shimmy
  module Shims
    # A shim for the Johnson Space Center Image Collection
    class JscImageCollection < BaseHttpShim
      attr_accessor :ng
      def initialize
        @ng = Nokogiri::HTML(response.body)
      end

      def response
        Hurley.get(base_url, params)
      end

      def base_url
        'http://images.jsc.nasa.gov/search/search.cgi'
      end

      def params
        {
          searchpage: true,
          selections: 'AS13',
          browsepage: 'Go',
          hitsperpage: 200,
          'submit.x' => 0,
          'submit.y' => 0,
          submit: 'submit'
        }
      end

      def to_iiif(manifest_uri)
        manifest = IIIF::Presentation::Manifest.new(
          '@id' => manifest_uri,
          'label' => 'Apollo XIII'
        )

        sequence = IIIF::Presentation::Sequence.new

        parse.each do |row|
          canvas = IIIF::Presentation::Canvas.new
          canvas.width = row.width
          canvas.height = row.height
          canvas.label = row.label
          canvas['@id'] = row.image_url
          anno = IIIF::Presentation::Annotation.new()
          ic = IIIF::Presentation::ImageResource.create_image_api_image_resource(resource_id: row.static_image, service_id: row.image_url)
          anno.resource = ic
          canvas.images << anno
          sequence.canvases << canvas
        end
        manifest.sequences << sequence
        manifest.to_json(pretty: true)
      end

      private

      def odd_rows
        @ng.css('tr[bgcolor="#CECFCE"]')
      end

      def even_rows
        @ng.css('tr[bgcolor="#DDDEDA"]')
      end

      def parse
        object_array = odd_rows.map { |row| RowParser.new(row) }

        even_rows.each_with_index do |row, index|
          object_array.insert((index + 1), RowParser.new(row))
        end
        object_array
      end
    end

    class RowParser
      attr_reader :md
      def initialize(md)
        @md = md
      end

      def label
        @md.css('td').first.css('font').to_s
          .match(%r{<br>(.*?)<\/font>}).captures[0].strip
      end

      def image
        @md.css('img')
      end

      def static_image
        image.attr('src').to_s.gsub('thumb', 'lores')
      end

      def image_requestor
        ImageRequestor.new(static_image)
      end

      def image_url
        image_requestor.iiifify
      end

      def width
        640
      end

      def height
        480
      end
    end
  end
end
