# Encoding: UTF-8
#
# Cookbook Name:: snoopy-build
# Recipe:: default
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

chef_gem 'packagecloud' do
  if Chef::Resource::ChefGem.instance_methods(false).include?(:compile_time)
    compile_time false
  end
end

ruby_block 'Calculate package version' do
  block do
    require 'json'
    require 'net/http'
    require 'packagecloud'

    version = Net::HTTP.get(
      URI('http://source.a2o.si/download/snoopy/snoopy-latest-version.txt')
    ).strip
    node.default['snoopy_build']['build_version'] = version

    if node['snoopy_build']['package_cloud_token']
      credentials = Packagecloud::Credentials.new(
        node['snoopy_build']['package_cloud_user'],
        node['snoopy_build']['package_cloud_token']
      )
      client = Packagecloud::Client.new(credentials)
      pkgs = client.list_packages(node['snoopy_build']['package_cloud_repo'])
             .response.select { |p| p['version'] == version }
      revision = if pkgs.length > 0
                   pkgs.sort_by { |p| p['release'] }.last['release'].to_i
                 else
                   0
                 end
      node.default['snoopy_build']['build_revision'] = revision + 1
    else
      node.default['snoopy_build']['build_revision'] = 1
    end
  end
end

include_recipe "#{cookbook_name}::_build"
include_recipe "#{cookbook_name}::_verify"
include_recipe "#{cookbook_name}::_deploy"
