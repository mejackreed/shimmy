# Shimmy

Shimmy is a Ruby gem designed to help you build shims to provide compliance
with the [IIIF Presentation API](http://iiif.io/api/presentation/2.0/) for
sets of images. In particular, it's designed to make it so you can quickly
build manifests if you have a way to expose existing images to an
[IIIF Image API](http://iiif.io/api/image/2.0/)-compliant image server.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shimmy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shimmy

## Usage

Implemented shims should inherit from `Shimmy::Shims::BaseShim` or 
`Shimmy::Shims::BaseHttpShim`, and at a minimum should implement the
`#initialize` and `#to_iiif` methods.

Example shims can be found in `lib/shimmy/shims`. 

## Example (Flickr sets)

Start up `pry`: 

```bash
$ pry --gem
```

Add in your Flickr API credentials ... 

```ruby
[1] pry(main)> FlickRaw.api_key = 'a1b2c3d4e5f6API_KEY'
=> "a1b2c3d4e5f6API_KEY"
[2] pry(main)> FlickRaw.shared_secret = 'f9e8d7c6b5a4SHARED_SECRET'
=> "f9e8d7c6b5a4SHARED_SECRET"

```

Pick a Flickr set and generate a manifest:

```
[3] pry(main)> manifest = Shimmy::Shims::FlickrSet.new(set_id: 72157626120220831)
=> #<Shimmy::Shims::FlickrSet:0x007fc03dbfa130
 @set_id=72157626120220831,
 @set_metadata=
  {"id"=>"72157626120220831", "owner"=>"35740357@N03", "username"=>"The U.S. National Archives", ...}, 
 @set_photos=
  {"id"=>"72157626120220831", "primary"=>"4546092598", "owner"=>"35740357@N03", "ownername"=>"The U.S. National Archives", ...}>
[4] pry(main)> File.write('manifest.json', manifest.to_iiif(manifest_uri: 'http://foo/bar'))
=> 70407
```

## Publishing your manifest

You can quickly publish manifests that are created by using the Githubify or JsonBlob mixins.

### Example
1. Create an instance of your shim `s = Shimmy::Shims::JscImageCollection.new`
1. Call `update_blob` on your shim

```
> s = Shimmy::Shims::JscImageCollection.new
> s.update_blog
=> "https://jsonblob.com/api/jsonBlob/560d3e36e4b01190df3a3ad7"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mejackreed/shimmy.

## License

This software is released under a public domain waiver (Unlicense).