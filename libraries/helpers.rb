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

module SnoopyBuildCookbook
  # Helper methods that are shared, to be used in both the coordinator and
  # builder servers.
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
        @user = config.delete(:user) || fail(MissingConfig, :user)
        @token = config.delete(:token) || fail(MissingConfig, :token)
        @repo = config.delete(:repo) || fail(MissingConfig, :repo)
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
