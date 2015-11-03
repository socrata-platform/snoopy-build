# Encoding: UTF-8
#
# Cookbook Name:: snoopy-build
# Library:: helpers
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
require 'net/http'

module SnoopyBuildCookbook
  # A set of helper methods for determining versions and build numbers.
  #
  # @author Jonathan Hartman <jonathan.hartman@socrata.com>
  module Helpers
    class << self
      #
      # Upload a completed package to PackageCloud.
      #
      def push_package!
        client.put_package('snoopy', package)
      end

      #
      # Return a package instance for the configured package and distro.
      #
      # @return [Packagecloud::Package] a package instance for upload
      #
      def package
        Packagecloud::Package.new(open(package_file), distro_id)
      end

      #
      # Build the path to the package file based on the configured platform
      # information.
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
      #
      # @return [Hash] a Packagecloud distro ID
      #
      def distro_id
        distro = case platform_family
                 when 'debian'
                   "#{platform}/#{lsb_codename}"
                 when 'rhel'
                   "el/#{platform_version.to_i}"
                 end
        client.find_distribution_id(distro)
      end

      #
      # Grab the text file with the latest released version of Snoopy.
      #
      # @return [String] the most recent version
      #
      def version
        @version ||= begin
          u = 'http://source.a2o.si/download/snoopy/snoopy-latest-version.txt'
          Net::HTTP.get(URI(u)).strip
        end
      end

      #
      # Iterate over the packages released for this version and return what
      # the next build number should be.
      #
      # @return [FixNum] the next build revision
      #
      def revision
        @revision ||= begin
          return 1 if token.nil? || packages.empty?
          packages.sort_by { |p| p['release'] }.last['release'].to_i + 1
        end
      end

      #
      # Iterate over the packages released for this repo and return the ones
      # matching the desired version.
      #
      # @return [Array<Hash>] an array of released packages
      #
      def packages
        @packages ||= begin
          client.list_packages(repo).response.select do |p|
            p['version'] == version
          end
        end
      end

      #
      # Return the PackageCloud client instance for package queries.
      #
      # @return [Packagecloud::Client] the client
      #
      def client
        @client ||= begin
          require 'packagecloud'
          Packagecloud::Client.new(credentials)
        end
      end

      #
      # Return the PackageCloud credentials needed for client instantiation.
      #
      # @return [Packagecloud::Credentials] the credentials
      #
      def credentials
        @credentials ||= begin
          require 'packagecloud'
          Packagecloud::Credentials.new(user, token)
        end
      end

      #
      # Provide a single method one can use to pass in and save the requisite
      # PackageCloud and platform attributes.
      #
      # @param node [Chef::Node] a Chef node object with the attributes we need
      #
      def configure!(node)
        @repo = node['snoopy_build']['package_cloud_repo']
        @user = node['snoopy_build']['package_cloud_user']
        @token = node['snoopy_build']['package_cloud_token']
        @platform = node['platform']
        @platform_version = node['platform_version']
        @lsb_codename = node['lsb'] && node['lsb']['codename']
        @platform_family = node['platform_family']
        self
      end

      attr_reader :repo,
                  :user,
                  :token,
                  :platform,
                  :platform_version,
                  :lsb_codename,
                  :platform_family
    end
  end
end
