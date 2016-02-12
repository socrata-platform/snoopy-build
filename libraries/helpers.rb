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

require 'net/http'
require 'json'

module SnoopyBuildCookbook
  # Helper methods that are shared, to be used in both the individual builder
  # servers as well as the central instance coordinating them.
  #
  # @author Jonathan Hartman <jonathan.hartman@socrata.com>
  class Helpers
    class << self
      attr_reader :user, :token, :repo

      #
      # Configure the class based on an input config hash.
      #
      # @param config [Hash] a hash containing, at a minimum, :user, :token and
      #                      :repo keys
      #
      def configure!(config)
        config ||= {}
        @user = config.delete(:user) || raise(MissingConfig, :user)
        @token = config.delete(:token) || raise(MissingConfig, :token)
        @repo = config.delete(:repo) || raise(MissingConfig, :repo)
        self
      end

      #
      # Iterate over the packages released for this repo and return the ones
      # matching the desired version. This requires enough configuration to
      # satisfy the `client` method and a repo.
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
      # Return the PackageCloud client instance for package queries. This
      # requires enough configuration to satisfy the `credentials` method.
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
      # This requires a configuration that includes a PackageCloud user and
      # token.
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
      # Grab the text file with the latest released version of Snoopy and
      # return that version string.
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
      # the next build number should be. This requires enough config to
      # satisfy the `packages` method. It will fallback to 1 if no token is
      # configured.
      #
      # @return [FixNum] the next build revision
      #
      def revision
        @revision ||= begin
          return 1 if token.nil? || packages.empty?
          packages.sort_by { |p| p['release'] }.last['release'].to_i + 1
        end
      end
    end

    # A custom exception class for missing configuration items.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class MissingConfig < StandardError
      #
      # Just re-raise a StandardError exception with a custom message.
      #
      # (see StandardError#initialize)
      #
      def initialize(item)
        super("Config item `#{item}` is required, but was not provided")
      end
    end
  end
end
