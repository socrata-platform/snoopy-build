# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::_configure' do
  let(:user) { 'a_user' }
  let(:token) { 'a_token' }
  let(:repo) { 'a_repo' }
  let(:platform) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %i(user token repo).each do |a|
        node.set['snoopy_build']["package_cloud_#{a}"] = send(a)
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  before(:each) do
    # The libraries have already been loaded; don't let ChefSpec reload them
    # and clear out our stubs.
    allow(Kernel).to receive(:load)
  end

  shared_examples_for 'any platform' do
    it 'installs the packagecloud gem' do
      expect(chef_run).to install_chef_gem('packagecloud-ruby')
        .with(compile_time: false)
    end
  end

  context 'Ubuntu 14.04' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'ubuntu',
              platform_version: '14.04',
              lsb_codename: 'trusty',
              platform_family: 'debian')
      chef_run
    end
  end

  context 'Ubuntu 12.04' do
    let(:platform) { { platform: 'ubuntu', version: '12.04' } }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'ubuntu',
              platform_version: '12.04',
              lsb_codename: 'precise',
              platform_family: 'debian')
      chef_run
    end
  end

  context 'CentOS 7.0' do
    let(:platform) { { platform: 'centos', version: '7.0' } }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'centos',
              platform_version: '7.0.1406',
              lsb_codename: nil,
              platform_family: 'rhel')
      chef_run
    end
  end

  context 'CentOS 6.6' do
    let(:platform) { { platform: 'centos', version: '6.6' } }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'centos',
              platform_version: '6.6',
              lsb_codename: nil,
              platform_family: 'rhel')
      chef_run
    end
  end
end
