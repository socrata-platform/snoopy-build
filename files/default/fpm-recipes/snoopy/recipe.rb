# Encoding: UTF-8
#
# FPM Recipe:: snoopy
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
require 'fpm/cookery/recipe'

# A FPM Cookery recipe for Snoopy Logger
#
# @author Jonathan Hartman <jonathan.hartman@socrata.com>
class Snoopy < FPM::Cookery::Recipe
  DOWNLOAD_ROOT = 'http://source.a2o.si/download/snoopy'.freeze

  name 'snoopy'

  version ENV['BUILD_VERSION']
  revision ENV['BUILD_REVISION']
  description 'Snoopy Logger'

  homepage 'https://github.com/a2o/snoopy'
  source File.join(DOWNLOAD_ROOT, "snoopy-#{version}.tar.gz")
  md5 Net::HTTP.get(URI(File.join(DOWNLOAD_ROOT,
                                  "snoopy-#{version}.tar.gz.md5"))).split[0]

  maintainer 'Jonathan Hartman <jonathan.hartman@socrata.com>'
  vendor 'Socrata, Inc.'

  license 'Apache, version 2.0'

  build_depends %w(curl tar socat automake autoconf libtool)

  platforms [:debian, :ubuntu] do
    build_depends %w(debhelper dh-autoreconf)
    depends 'debconf'
  end

  platforms [:redhat, :centos, :scientific] do
    build_depends %w(rpm-build)
  end

  def build
    inline_replace 'configure.ac' do |s|
      # This macro doesn't exist in RHEL6 and isn't really needed, since we
      # already know the version at this point anyway.
      s.gsub!(/m4_esyscmd_s.*/, "[#{version}],")
    end
    safesystem './bootstrap.sh'
    configure prefix: '/', 'enable-thread-safety' => true
    make
  end

  def install
    make :install, DESTDIR: destdir
  end
end
