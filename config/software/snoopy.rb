# Encoding: UTF-8
#
# Copyright 2015 Socrata, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'net/http'

name 'snoopy'

default_version Net::HTTP.get(URI('http://source.a2o.si/download/snoopy/' \
                                  'snoopy-latest-version.txt')).strip

source url: "http://source.a2o.si/download/snoopy/snoopy-#{version}.tar.gz",
       md5: Net::HTTP.get(URI('http://source.a2o.si/download/snoopy/' \
                              "snoopy-#{version}.tar.gz.md5")).split[0]

relative_path "snoopy-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env['CFLAGS'] << ' -DNO_VIZ' if solaris?

  # The only files the package builds are the config, config scripts, and main
  # libs, all of which belong the level above embedded/.
  command "rm -rf #{install_dir}/embedded #{install_dir}/bin"
  command './bootstrap.sh'
  command [
    './configure',
    "--prefix=#{install_dir}/embedded",
    "--libdir=#{install_dir}/lib",
    "--sbindir=#{install_dir}/sbin",
    "--sysconfdir=#{install_dir}/etc"
  ], env: env
  command "make -j #{workers}", env: env
  command "make -j #{workers} install", env: env
end
