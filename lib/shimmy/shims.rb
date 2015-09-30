module Shimmy
  # Require all of the Shimmy shims
  module Shims
    Dir[File.dirname(__FILE__) + '/shims/*.rb'].each {|file| require file }
  end
end
