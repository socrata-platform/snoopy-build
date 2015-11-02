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
      # Return the node repo, token, and user attributes.
      #
      %w(repo token user).each do |m|
        define_method(m) { node['snoopy_build']["package_cloud_#{m}"] }
      end
    end
  end
end
