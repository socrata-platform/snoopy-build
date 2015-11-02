# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::_build' do
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
      expect(chef_run).to install_gem_package('fpm-cookery')
    end

    it 'syncs the fpm-recipes directory' do
      d = File.expand_path('~/fpm-recipes')
      expect(chef_run).to create_remote_directory(d)
    end

    it 'runs fpm-cook' do
      expect(chef_run).to run_execute('fpm-cook')
        .with(cwd: File.expand_path('~/fpm-recipes/snoopy'),
              environment: { 'BUILD_VERSION' => '2.4.4',
                             'BUILD_REVISION' => '1' })
    end
  end

  context 'Ubuntu 14.04' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }

    it_behaves_like 'any platform'

    it 'ensures the APT cache is refreshed' do
      expect(chef_run).to include_recipe('apt')
    end

    it 'does not configure EPEL' do
      expect(chef_run).to_not include_recipe('yum-epel')
    end
  end

  context 'Ubuntu 12.04' do
    let(:platform) { { platform: 'ubuntu', version: '12.04' } }

    it_behaves_like 'any platform'

    it 'ensures the APT cache is refreshed' do
      expect(chef_run).to include_recipe('apt')
    end

    it 'does not configure EPEL' do
      expect(chef_run).to_not include_recipe('yum-epel')
    end
  end

  context 'CentOS 7.0' do
    let(:platform) { { platform: 'centos', version: '7.0' } }

    it_behaves_like 'any platform'

    it 'does not run the APT recipe' do
      expect(chef_run).to_not include_recipe('apt')
    end

    it 'does not configure EPEL' do
      expect(chef_run).to_not include_recipe('yum-epel')
    end
  end

  context 'CentOS 6.7' do
    let(:platform) { { platform: 'centos', version: '6.7' } }

    it_behaves_like 'any platform'

    it 'does not run the APT recipe' do
      expect(chef_run).to_not include_recipe('apt')
    end

    it 'configures EPEL' do
      expect(chef_run).to include_recipe('yum-epel')
    end
  end
end
