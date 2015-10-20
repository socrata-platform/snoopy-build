# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-omnibus::build' do
  let(:platform) { nil }
  let(:build_user) { 'omnibus' }
  let(:build_group) { 'omnibus' }
  let(:staging_dir) { '/snoopy' }
  let(:project_dir) { '/home/omnibus/snoopy' }
  let(:install_dir) { '/opt/snoopy' }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %w(
        build_user build_group staging_dir project_dir install_dir
      ).each do |a|
        node.set['omnibus'][a] = send(a)
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  shared_examples_for 'any platform' do
    it 'includes the omnibus cookbook' do
      expect(chef_run).to include_recipe('omnibus')
    end

    %w(debhelper dh-autoreconf socat).each do |p|
      it "installs the '#{p}' package" do
        expect(chef_run).to install_package(p)
      end
    end

    it 'declares an execute resource to fix project dir ownership' do
      expect(chef_run.execute('fix project dir ownership')).to do_nothing
    end

    it 'copies the project dir into place' do
      expect(chef_run).to run_execute('copy project dir')
        .with(command: "cp -a #{staging_dir} #{project_dir}",
              creates: project_dir)
      expect(chef_run.execute('copy project dir')).to notify(
        'execute[fix project dir ownership]'
      ).to(:run)
    end

    it 'executes the Omnibus build' do
      expect(chef_run).to execute_omnibus_build('snoopy').with(
        project_dir: project_dir,
        install_dir: install_dir
      )
    end

    it 'cleans up after itself' do
      expect(chef_run).to delete_directory(install_dir).with(recursive: true)
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
