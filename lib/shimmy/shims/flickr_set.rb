require 'flickraw'
require 'iiif/presentation'

# Before you can use this, you need to set your Flickr API credentials:
#
# >>> FlickRaw.api_key = 'YOUR_API_KEY'
# >>> FlickRaw.shared_secret = 'YOUR_SHARED_SECRET'

module Shimmy
  module Shims
    # A shim for Flickr sets
    class FlickrSet < BaseShim

      attr_accessor :set_id, :set_metadata, :set_photos

      def initialize(set_id: 72157652638432993)
        @set_id = set_id
        @set_metadata = flickr.photosets.getInfo(photoset_id: @set_id)
        @set_photos = flickr.photosets.getPhotos(
          photoset_id: @set_id,
          extras: 'o_dims, url_o'
        )
      end

      def to_iiif(manifest_uri)
        manifest = IIIF::Presentation::Manifest.new(
          '@id' => manifest_uri,
          'label' => @set_metadata.title
        )

        sequence = IIIF::Presentation::Sequence.new

        @set_photos.photo.each do |photo|
          canvas = IIIF::Presentation::Canvas.new
          canvas.width = photo.o_width.to_i
          canvas.height = photo.o_height.to_i
          canvas.label = photo.title
          canvas['@id'] = Shimmy::ImageRequestor.new(photo.url_o).iiifify
          anno = IIIF::Presentation::Annotation.new()
          iiifified = Shimmy::ImageRequestor.new(photo.url_o)
          ic = IIIF::Presentation::ImageResource.create_image_api_image_resource(
            resource_id: photo.url_o,
            service_id: iiifified.service_url,
            width: iiifified.width,
            height: iiifified.height
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
