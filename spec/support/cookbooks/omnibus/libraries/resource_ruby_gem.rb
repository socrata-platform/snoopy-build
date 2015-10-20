# Encoding: UTF-8

require 'chef/resource'

class Chef
  class Resource
    # A fake ruby_gem resource
    #
    # @author Jonathan Hartman <j@hartman.io>
    class RubyGem < Resource
      action(:install) {}
      property :ruby, String
    end
  end
end
