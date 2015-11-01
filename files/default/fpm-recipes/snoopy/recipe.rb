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
  DOWNLOAD_ROOT = 'http://source.a2o.si/download/snoopy'

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

  platforms [:debian, :ubuntu] do
    build_depends %w(curl debhelper dh-autoreconf socat)
    depends 'debconf'
  end

  platforms [:redhat, :centos, :scientific] do
    build_depends %w(autoconf automake socat rpm-build)
  end

  def build
    safesystem './bootstrap.sh'
    configure prefix: '/'
    make
  end

  def install
    make :install, DESTDIR: destdir
  end
end
