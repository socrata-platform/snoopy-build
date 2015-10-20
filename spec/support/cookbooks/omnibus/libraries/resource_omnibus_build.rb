# Encoding: UTF-8

require 'chef/resource'

class Chef
  class Resource
    # A fake omnibus_build resource
    #
    # @author Jonathan Hartman <j@hartman.io>
    class OmnibusBuild < Resource
      action(:execute) {}
      property :project_dir, String
      property :install_dir, String
      property :config_overrides, Hash
    end
  end
end
