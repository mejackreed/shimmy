require 'nypl_repo'
require 'iiif/presentation'

# Before you can use this, you need to get an NYPL API key:
# http://api.repo.nypl.org/

module Shimmy
  module Shims
    # A shim for the NYPL API, originally for public domain maps. Some
    # images have larger sizes available.
    class NyplApi < BaseShim

      attr_accessor :host_item_id, :captures, :client

      # @param params [Hash] Keys :host_item_id and :nypl_api_key must have
      #   values
      def initialize(params)
        @host_item_id = params[:host_item_id]
        @client = NyplRepo::Client.new(params[:nypl_api_key])
        @captures = @client.get_capture_items(@host_item_id)
      end

      def to_iiif(manifest_uri)

        # Unfortunately, unless it's a capture, it appears that the associated
        # MODS is not available
        manifest = IIIF::Presentation::Manifest.new(
          '@id' => manifest_uri,
          'attribution' => 'Provided by The New York Public Library',
          'logo' => 'http://cdn-prod.www.aws.nypl.org/sites/default/files/images/NYPL_mark_1_black_pos-sm_0.jpg',
          'label' => @client.get_mods_item(@captures.first["uuid"])["relatedItem"]["titleInfo"]["title"]["$"]
        )

        sequence = IIIF::Presentation::Sequence.new

        @captures.each do |capture|
          canvas = IIIF::Presentation::Canvas.new
          canvas['@id'] = capture["itemLink"]
          anno = IIIF::Presentation::Annotation.new()

          # To my knowledge, only the public domain maps have a `highResLink`
          # key. The reliably present maximum image size is `?t=w`, which is
          # 760px on the longest side. For some images (e.g. certain public
          # domain ones) larger sizes are available, but the available sizes
          # aren't available from the API.
          source_image = capture["highResLink"] || "http://images.nypl.org/index.php?id=#{capture["imageID"]}&t=w"
          iiifified = Shimmy::ImageRequestor.new(source_image)
          ic = IIIF::Presentation::ImageResource.create_image_api_image_resource(
            resource_id: source_image,
            service_id: iiifified.service_url,
            width: iiifified.width,
            height: iiifified.height
          )
          mods = @client.get_mods_item(capture["uuid"])
          canvas.width = ic.width
          canvas.height = ic.height
          canvas.label = mods["titleInfo"]["title"]["$"]
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
