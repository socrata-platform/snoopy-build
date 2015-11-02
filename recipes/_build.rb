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

include_recipe 'apt' if node['platform_family'] == 'debian'
include_recipe 'build-essential'
include_recipe 'ruby'

gem_package 'fpm-cookery'

remote_directory File.expand_path('~/fpm-recipes')

execute 'fpm-cook' do
  cwd File.expand_path('~/fpm-recipes/snoopy')
  environment lazy {
    {
      'BUILD_VERSION' => node['snoopy_build']['build_version'],
      'BUILD_REVISION' => node['snoopy_build']['build_revision'].to_s
    }
  }
end
