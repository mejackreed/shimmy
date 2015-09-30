module Shimmy
  # Require all of the Shimmy shims
  module Shims
    require 'shimmy/shims/base_shim'
    Dir[File.dirname(__FILE__) + '/shims/*.rb'].each {|file| require file }
  end
end
