# Encoding: UTF-8
#
# Cookbook Name:: snoopy-build
# Library:: helpers_coordinator
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
require_relative 'helpers'

module SnoopyBuildCookbook
  class Helpers
    # Coordinator methods are to be run by the central server coordinating the
    # various build instances. For example, the package version and revision
    # need to be the same across all builders.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class Coordinator < Helpers
      class << self
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
    end
  end
end
