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

package 'snoopy' do
  action :remove
end

include_recipe 'apt' if node['platform_family'] == 'debian'
include_recipe 'omnibus'

# A few extra build tools not included with build-essential are needed
%w(debhelper dh-autoreconf socat).each { |p| package p }

build_user = node['omnibus']['build_user']
build_group = node['omnibus']['build_user_group']
staging_dir = node['omnibus']['staging_dir']
project_dir = node['omnibus']['project_dir']
install_dir = node['omnibus']['install_dir']

ENV['BUILD_VERSION'] = build_version = node['omnibus']['build_version']
ENV['BUILD_ITERATION'] = build_iteration = node['omnibus']['build_iteration']
                                           .to_s

# Sync the project's staging dir to the build dir, ensuring the copy is owned
# by the build user (because some syncing methods result in a directory
# permanently owned by the vagrant user).
execute 'fix project dir ownership' do
  command "chown -R #{build_user}:#{build_group} #{project_dir}"
  action :nothing
end

execute 'copy project dir' do
  command "cp -a #{staging_dir} #{project_dir}"
  creates project_dir
  notifies :run, 'execute[fix project dir ownership]', :immediately
end

omnibus_build 'snoopy' do
  project_dir project_dir
  install_dir install_dir
  # TODO: The omnibus cookbook generates an invalid build command if no
  # overrides are passed in.
  config_overrides(use_git_caching: false,
                   append_timestamp: false)
end

directory install_dir do
  recursive true
  action :delete
end

package ::File.join(project_dir,
                    'pkg',
                    "snoopy_#{build_version}-#{build_iteration}_amd64.deb") do
  provider Chef::Provider::Package::Dpkg
end

artifact_dir = ::File.join(staging_dir,
                           'pkg',
                           node['platform'],
                           node['lsb']['codename'])
directory artifact_dir do
  recursive true
end

execute 'copy package artifacts' do
  command "cp -rp #{project_dir}/pkg/* #{artifact_dir}/"
end
