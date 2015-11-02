# Encoding: UTF-8
#
# Cookbook Name:: snoopy-build
# Recipe:: _deploy
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

gem_package 'package_cloud' do
  only_if { node['snoopy_build']['publish_artifacts'] }
end

execute 'Push artifacts to PackageCloud' do
  command lazy {
    user = node['snoopy_build']['package_cloud_user']
    repo = node['snoopy_build']['package_cloud_repo']
    version = node['snoopy_build']['build_version']
    revision = node['snoopy_build']['build_revision']
    pc_path = case node['platform_family']
              when 'debian'
                "#{user}/#{repo}/#{node['platform']}/#{node['lsb']['codename']}"
              when 'rhel'
                "#{user}/#{repo}/el/#{node['platform_version'].to_i}"
              end
    pkg_dir = File.expand_path('~/fpm-recipes/snoopy/pkg')
    pkg_file = case node['platform_family']
               when 'debian'
                 "snoopy_#{version}-#{revision}_amd64.deb"
               when 'rhel'
                 "snoopy-#{version}-#{revision}.x86_64.rpm"
               end
    "package_cloud push #{pc_path} #{File.join(pkg_dir, pkg_file)}"
  }
  environment lazy {
    { 'PACKAGECLOUD_TOKEN' => node['snoopy_build']['package_cloud_token'] }
  }
  only_if { node['snoopy_build']['publish_artifacts'] }
end
