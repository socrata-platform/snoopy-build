# Encoding: UTF-8
#
# Cookbook Name:: snoopy-omnibus
# Recipe:: build
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

include_recipe 'apt' if node['platform_family'] == 'debian'
include_recipe 'omnibus'

# A few extra build tools not included with build-essential are needed
%w(debhelper dh-autoreconf socat).each { |p| package p }

execute 'bundle install' do
  user node['omnibus']['build_user']
  cwd node['omnibus']['build_dir']
end

execute 'bundle exec omnibus build snoopy' do
  user node['omnibus']['build_user']
  cwd node['omnibus']['build_dir']
end

directory node['omnibus']['install_dir'] do
  recursive true
  action :delete
end

# TODO: Install the package artifact
