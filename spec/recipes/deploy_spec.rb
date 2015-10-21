# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::deploy' do
  let(:platform) { nil }
  let(:build_version) { '2.4.4' }
  let(:build_revision) { 1 }
  let(:package_cloud_token) { 'testtest' }
  let(:package_cloud_user) { 'socrata-platform' }
  let(:package_cloud_repo) { 'snoopy' }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %w(
        build_version build_revision package_cloud_token package_cloud_user
        package_cloud_repo
      ).each do |a|
        node.set['snoopy_build'][a] = send(a)
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  before(:each) do
    ENV['PACKAGECLOUD_TOKEN'] = 'testtest'
  end

  shared_examples_for 'any platform' do
    it 'installs the package_cloud gem' do
      expect(chef_run).to install_gem_package('package_cloud')
    end
  end

  context 'Ubuntu 14.04' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }

    it_behaves_like 'any platform'

    it 'uploads the correct new package' do
      cmd = 'package_cloud push socrata-platform/snoopy/ubuntu/trusty ' \
            "#{File.expand_path('~/fpm-recipes/snoopy/pkg')}/snoopy_2.4.4-1_" \
            'amd64.deb'
      expect(chef_run).to run_execute(cmd).with(
        environment: { 'PACKAGECLOUD_TOKEN' => 'testtest' }
      )
    end
  end
end
