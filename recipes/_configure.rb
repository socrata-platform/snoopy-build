# Encoding: UTF-8
#
# Cookbook Name:: snoopy-build
# Recipe:: _configure
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

chef_gem 'packagecloud-ruby' do
  if Chef::Resource::ChefGem.instance_methods(false).include?(:compile_time)
    compile_time false
  end
end

ruby_block 'Configure the package builder helpers' do
  block do
    SnoopyBuildCookbook::Helpers.configure!(node)
  end
end
