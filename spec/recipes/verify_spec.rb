# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::verify' do
  let(:platform) { nil }
  let(:build_version) { '2.4.4' }
  let(:build_revision) { 1 }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %w(build_version build_revision).each do |a|
        node.set['snoopy_build'][a] = send(a)
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

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

  context 'Ubuntu 14.04' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }

    it_behaves_like 'any platform'

    it 'installs the correct package file' do
      path = File.expand_path('~/fpm-recipes/snoopy/pkg/' \
                              'snoopy_2.4.4-1_amd64.deb')
      expect(chef_run).to install_dpkg_package(path)
    end
  end

  context 'CentOS 7.0' do
    let(:platform) { { platform: 'centos', version: '7.0' } }

    it_behaves_like 'any platform'

    it 'installs the correct package file' do
      path = File.expand_path('~/fpm-recipes/snoopy/pkg/' \
                              'snoopy-2.4.4-1.x86_64.rpm')
      expect(chef_run).to install_rpm_package(path)
    end
  end
end
