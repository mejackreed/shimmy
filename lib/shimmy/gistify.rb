module Shimmy
  module Gistify
    ##
    # Requires access to an environment variable "GITHUB_BASIC" which is
    # "username:password"
    def gistify
      @github = Github.new basic_auth: ENV["GITHUB_BASIC"]
      @gist ||= @github.gists.create(
        description: 'IIIF Presentation API Manifest',
        public: true,
        files: {
          'manifest.json' => {
            content: '{}'
          }
        }
      ).body
    end

    def gist_raw_url
      @gist['files']['manifest.json']['raw_url']
        .gsub(%r{\/raw.*}, '/raw/manifest.json') if @gist
    end

    def gist_id
      @gist['id'] if @gist
    end

    ##
    # @param {String} content JSON to be updated
    def update_gist(content)
      @gist = @github.gists.edit(
        gist_id,
        public: true,
        files: {
          'manifest.json' => {
            content: content
          }
        }
      )
    end
  end
end
