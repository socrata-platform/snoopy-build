# Encoding: UTF-8
#
# Cookbook Name:: snoopy-build
# Recipe:: _build
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

package 'snoopy' do
  action :remove
end

directory File.expand_path('~/fpm-recipes/snoopy/pkg') do
  action :delete
  recursive true
end

if node['platform'] == 'ubuntu' && node['platform_version'].to_i < 12
  file '/etc/apt/sources.list' do
    content lazy {
      File.read('/etc/apt/sources.list')
          .gsub('archive.ubuntu.com', 'old-releases.ubuntu.com')
          .gsub('security.ubuntu.com', 'old-releases.ubuntu.com')
    }
  end

  apt_repository 'neurodebian' do
    uri 'http://masi.vuse.vanderbilt.edu/neurodebian'
    distribution node['lsb']['codename']
    components %w(main)
    keyserver 'pgp.mit.edu'
    key '0xA5D32F012649A5A9'
  end
end

apt_update 'periodic' if node['platform_family'] == 'debian'
include_recipe 'build-essential'
if node['platform_family'] == 'rhel' && node['platform_version'].to_i < 7
  include_recipe 'yum-epel'
end

chef_gem 'fpm-cookery' do
  compile_time false
end

remote_directory File.expand_path('~/fpm-recipes')

execute '/opt/chef/embedded/bin/fpm-cook' do
  cwd File.expand_path('~/fpm-recipes/snoopy')
  environment lazy {
    {
      'BUILD_VERSION' => node['snoopy_build']['build_version'],
      'BUILD_REVISION' => node['snoopy_build']['build_revision'].to_s
    }
  }
end
