# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::_configure' do
  let(:user) { 'a_user' }
  let(:token) { 'a_token' }
  let(:repo) { 'a_repo' }
  let(:platform) { nil }
  let(:version) { '1.2.3' }
  let(:revision) { 4 }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %i(user token repo).each do |a|
        node.set['snoopy_build']["package_cloud_#{a}"] = send(a)
      end
      node.set['snoopy_build']['build_version'] = version
      node.set['snoopy_build']['build_revision'] = revision
    end
  end
  let(:converge) { runner.converge(described_recipe) }

  before(:each) do
    allow(Kernel).to receive(:load)
  end

  shared_examples_for 'any platform' do
    it 'installs the packagecloud gem' do
      expect(chef_run).to install_chef_gem('packagecloud-ruby')
        .with(compile_time: false)
    end

    it 'executes the configuration ruby block' do
      expected = 'Configure the package builder helpers'
      expect(chef_run).to run_ruby_block(expected)
    end
  end

  context 'Ubuntu 15.10' do
    let(:platform) { { platform: 'ubuntu', version: '15.10' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'ubuntu',
              platform_version: '15.10',
              lsb_codename: 'wily',
              platform_family: 'debian',
              version: '1.2.3',
              revision: 4)
      chef_run.ruby_block('Configure the package builder helpers')
        .old_run_action(:run)
    end
  end

  context 'Ubuntu 14.04' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'ubuntu',
              platform_version: '14.04',
              lsb_codename: 'trusty',
              platform_family: 'debian',
              version: '1.2.3',
              revision: 4)
      chef_run.ruby_block('Configure the package builder helpers')
        .old_run_action(:run)
    end
  end

  context 'Ubuntu 12.04' do
    let(:platform) { { platform: 'ubuntu', version: '12.04' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'ubuntu',
              platform_version: '12.04',
              lsb_codename: 'precise',
              platform_family: 'debian',
              version: '1.2.3',
              revision: 4)
      chef_run.ruby_block('Configure the package builder helpers')
        .old_run_action(:run)
    end
  end

  context 'Ubuntu 10.04' do
    let(:platform) { { platform: 'ubuntu', version: '10.04' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'ubuntu',
              platform_version: '10.04',
              lsb_codename: 'lucid',
              platform_family: 'debian',
              version: '1.2.3',
              revision: 4)
      chef_run.ruby_block('Configure the package builder helpers')
        .old_run_action(:run)
    end
  end

  context 'CentOS 7.0' do
    let(:platform) { { platform: 'centos', version: '7.0' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'centos',
              platform_version: '7.0.1406',
              lsb_codename: nil,
              platform_family: 'rhel',
              version: '1.2.3',
              revision: 4)
      chef_run.ruby_block('Configure the package builder helpers')
        .old_run_action(:run)
    end
  end

  context 'CentOS 6.6' do
    let(:platform) { { platform: 'centos', version: '6.6' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'

    it 'correctly configures the builder' do
      expect(SnoopyBuildCookbook::Helpers::Builder).to receive(:configure!)
        .with(user: user,
              token: token,
              repo: repo,
              platform: 'centos',
              platform_version: '6.6',
              lsb_codename: nil,
              platform_family: 'rhel',
              version: '1.2.3',
              revision: 4)
      chef_run.ruby_block('Configure the package builder helpers')
        .old_run_action(:run)
    end
  end
end
