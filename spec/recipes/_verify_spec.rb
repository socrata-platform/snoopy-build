# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::_verify' do
  let(:platform) { nil }
  let(:package_file) { '/tmp/package.pkg' }
  let(:runner) { ChefSpec::SoloRunner.new(platform) }
  let(:chef_run) { runner.converge(described_recipe) }

  before(:each) do
    allow(SnoopyBuildCookbook::Helpers).to receive(:package_file)
      .and_return(package_file)
  end

  shared_examples_for 'any platform' do
    it 'installs the serverspec gem' do
      expect(chef_run).to install_gem_package('serverspec')
    end

    it 'copies over the spec directory' do
      expect(chef_run).to create_remote_directory(File.expand_path('~/spec'))
    end

    it 'runs the ServerSpec tests' do
      expect(chef_run).to run_execute('rspec */*_spec.rb -f d')
        .with(cwd: File.expand_path('~/spec'))
    end
  end

  context 'Ubuntu' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }

    it_behaves_like 'any platform'

    it 'uses the correct package resource' do
      expect(chef_run).to install_dpkg_package('snoopy')
    end
  end

  context 'CentOS' do
    let(:platform) { { platform: 'centos', version: '7.0' } }

    it_behaves_like 'any platform'

    it 'uses the correct package resource' do
      expect(chef_run).to install_rpm_package('snoopy')
    end
  end
end
