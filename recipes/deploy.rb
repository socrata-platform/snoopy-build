# Encoding: UTF-8
#
# Cookbook Name:: snoopy-omnibus
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

ruby_gem 'package_cloud' do
  ruby node['omnibus']['ruby_version']
end

# TODO: Push artifacts to PackageCloud.io
# cmd =  "chruby-exec #{node['omnibus']['ruby_version']} -- " \
#        "package_cloud push #{node['package_cloud']['user']}/" \
#        "#{node['package_cloud']['repo']}/#{node['platform']}/" \
#        "#{version} #{path_to_package}"
