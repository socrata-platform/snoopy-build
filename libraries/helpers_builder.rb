# Encoding: UTF-8
#
# Cookbook Name:: snoopy-build
# Library:: helpers_builder
#
# Copyright 2015 Socrata, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'json'
require_relative 'helpers'

module SnoopyBuildCookbook
  class Helpers
    # Builder methods are for use on the individual build servers. They
    # control configuration that is platform-specific or related to building,
    # testing, and uploading build artifacts.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class Builder < Helpers
      class << self
        attr_reader :platform,
                    :platform_version,
                    :lsb_codename,
                    :platform_family,
                    :version,
                    :revision
        #
        # Add additional required config keys to those of the inherited Helpers
        # class.
        #
        # (see Helpers.configure!)
        #
        def configure!(config)
          super
          %i(
            platform platform_version platform_family version revision
          ).each do |c|
            instance_variable_set(:"@#{c}", config.delete(c)) || \
              fail(MissingConfig, c)
          end
          @lsb_codename = config.delete(:lsb_codename)
          self
        end

        #
        # Upload a completed package to PackageCloud. This requires enough
        # config to satisfy the `package` method.
        #
        def push_package!
          client.put_package(repo, package)
        end

        #
        # Return a package instance for the configured package and distro. This
        # requires enough config to satisfy the `package_file` and `distro_id`
        # methods.
        #
        # @return [Packagecloud::Package] a package instance for upload
        #
        def package
          Packagecloud::Package.new(open(package_file), distro_id)
        end

        #
        # Build the path to the package file based on the configured platform
        # information. This requires enough config to satisfy the `revision`
        # method, as well as a platform family.
        #
        # @return [String] the package file's path
        #
        def package_file
          File.join(File.expand_path('~/fpm-recipes/snoopy/pkg'),
                    case platform_family
                    when 'debian'
                      "snoopy_#{version}-#{revision}_amd64.deb"
                    when 'rhel'
                      "snoopy-#{version}-#{revision}.x86_64.rpm"
                    end)
        end

        #
        # Use the saved platform information to build the appropriate distro ID.
        # This requires enough config to satisfy the `client` method, as well
        # as a platform, platform family, platform version, and (for Ubuntu
        # systems) an LSB codename.
        #
        # @return [Hash] a Packagecloud distro ID
        #
        def distro_id
          distro_version = case platform_family
                           when 'debian'
                             "#{platform}/#{lsb_codename}"
                           when 'rhel'
                             "el/#{platform_version.to_i}"
                           end
          client.find_distribution_id(distro_version)
        end
      end
    end
  end
end
