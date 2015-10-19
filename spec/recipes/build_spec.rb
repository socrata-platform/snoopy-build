# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-omnibus::build' do
  let(:platform) { nil }
  let(:runner) { ChefSpec::SoloRunner.new(platform) }
  let(:chef_run) { runner.converge(described_recipe) }

  shared_examples_for 'any platform' do
    %w(debhelper dh-autoreconf socat).each do |p|
      it "installs the '#{p}' package" do
        expect(chef_run).to install_package(p)
      end
    end

    it 'does a bundle install' do
      expect(chef_run).to run_execute('bundle install')
    end

    it 'runs the build' do
      expect(chef_run).to run_execute('bundle exec omnibus build snoopy')
    end

    it 'cleans up the build workspace' do
      expect(chef_run).to delete_directory('/opt/snoopy')
        .with(recursive: true)
    end
  end

  context 'Ubuntu 14.04' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }

    it_behaves_like 'any platform'

    it 'ensures the APT cache is refreshed' do
      expect(chef_run).to include_recipe('apt')
    end
  end

  context 'CentOS 7.0' do
    let(:platform) { { platform: 'centos', version: '7.0' } }

    it_behaves_like 'any platform'

    it 'does not run the APT recipe' do
      expect(chef_run).to_not include_recipe('apt')
    end
  end
end
