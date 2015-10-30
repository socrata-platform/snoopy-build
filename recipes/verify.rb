# Encoding: UTF-8
#
# Cookbook Name:: snoopy-build
# Recipe:: verify
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

gem_package 'serverspec'

version = node['snoopy_build']['build_version']
revision = node['snoopy_build']['build_revision']

case node['platform_family']
when 'debian'
  dpkg_package File.join(File.expand_path('~/fpm-recipes/snoopy/pkg'),
                         "snoopy_#{version}-#{revision}_amd64.deb")
when 'rhel'
  rpm_package File.join(File.expand_path('~/fpm-recipes/snoopy/pkg'),
                        "snoopy-#{version}-#{revision}.x86_64.rpm")
end

remote_directory File.expand_path('~/spec')

execute 'rspec */*_spec.rb -f d' do
  cwd File.expand_path('~/spec')
end
