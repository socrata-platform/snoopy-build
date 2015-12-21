# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::_build' do
  let(:platform) { nil }
  let(:version) { '2.4.4' }
  let(:revision) { 1 }
  let(:runner) { ChefSpec::SoloRunner.new(platform) }
  let(:converge) { runner.converge(described_recipe) }

  before(:each) do
    %i(version revision).each do |m|
      allow(SnoopyBuildCookbook::Helpers).to receive(m).and_return(send(m))
    end
  end

  shared_examples_for 'any platform' do
    it 'removes any currently installed snoopy package' do
      expect(chef_run).to remove_package('snoopy')
    end

    it 'cleans up any current package directory' do
      d = File.expand_path('~/fpm-recipes/snoopy/pkg')
      expect(chef_run).to delete_directory(d).with(recursive: true)
    end

    it 'includes build-essential' do
      expect(chef_run).to include_recipe('build-essential')
    end

    it 'includes ruby' do
      expect(chef_run).to include_recipe('ruby')
    end

    it 'installs fpm-cookery' do
      expect(chef_run).to install_chef_gem('fpm-cookery')
        .with(compile_time: false)
    end

    it 'syncs the fpm-recipes directory' do
      d = File.expand_path('~/fpm-recipes')
      expect(chef_run).to create_remote_directory(d)
    end

    it 'runs fpm-cook' do
      expect(chef_run).to run_execute('/opt/chef/embedded/bin/fpm-cook')
        .with(cwd: File.expand_path('~/fpm-recipes/snoopy'))
    end
  end

  shared_examples_for 'a Ubuntu platform' do
    it 'ensures the APT cache is refreshed' do
      expect(chef_run).to include_recipe('apt')
    end

    it 'does not configure EPEL' do
      expect(chef_run).to_not include_recipe('yum-epel')
    end
  end

  shared_examples_for 'a CentOS platform' do
    it 'does not run the APT recipe' do
      expect(chef_run).to_not include_recipe('apt')
    end

    it 'does not configure the neurodebian APT repo' do
      expect(chef_run).to_not add_apt_repository('neurodebian')
    end
  end

  %w(15.10 14.04 12.04).each do |v|
    context "Ubuntu #{v}" do
      let(:platform) { { platform: 'ubuntu', version: v } }
      cached(:chef_run) { converge }

      it_behaves_like 'any platform'
      it_behaves_like 'a Ubuntu platform'

      it 'does not configure the neurodebian APT repo' do
        expect(chef_run).to_not add_apt_repository('neurodebian')
      end
    end
  end

  context 'Ubuntu 10.04' do
    let(:platform) { { platform: 'ubuntu', version: '10.04' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'
    it_behaves_like 'a Ubuntu platform'

    it 'configures the neurodebian APT repo' do
      expect(chef_run).to add_apt_repository('neurodebian').with(
        uri: 'http://masi.vuse.vanderbilt.edu/neurodebian',
        distribution: 'lucid',
        components: %w(main),
        keyserver: 'pgp.mit.edu',
        key: '0xA5D32F012649A5A9'
      )
    end
  end

  context 'CentOS 7.0' do
    let(:platform) { { platform: 'centos', version: '7.0' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'
    it_behaves_like 'a CentOS platform'

    it 'does not configure EPEL' do
      expect(chef_run).to_not include_recipe('yum-epel')
    end
  end

  context 'CentOS 6.6' do
    let(:platform) { { platform: 'centos', version: '6.6' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'
    it_behaves_like 'a CentOS platform'

    it 'configures EPEL' do
      expect(chef_run).to include_recipe('yum-epel')
    end
  end
end
