# Encoding: UTF-8
#
# Cookbook Name:: snoopy-build
# Recipe:: deploy
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

gem_package 'package_cloud'

user = node['snoopy_build']['package_cloud_user']
repo = node['snoopy_build']['package_cloud_repo']
version = node['snoopy_build']['build_version']
revision = node['snoopy_build']['build_revision']

pc_token = node['snoopy_build']['package_cloud_token']
pc_path = "#{user}/#{repo}/#{node['platform']}/#{node['lsb']['codename']}"
pkg_path = File.join(File.expand_path('~/fpm-recipes/snoopy/pkg/'),
                     "snoopy_#{version}-#{revision}_amd64.deb")

execute "package_cloud push #{pc_path} #{pkg_path}" do
  environment 'PACKAGECLOUD_TOKEN' => pc_token
end
