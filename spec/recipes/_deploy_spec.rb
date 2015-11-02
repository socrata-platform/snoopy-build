# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::_deploy' do
  let(:platform) { nil }
  let(:publish_artifacts) { nil }
  let(:package_cloud_user) { 'socrata-platform' }
  let(:package_cloud_repo) { 'snoopy' }
  let(:build_version) { '2.4.4' }
  let(:build_revision) { 1 }
  let(:package_cloud_token) { 'testtest' }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %w(
        publish_artifacts package_cloud_user package_cloud_repo build_version
        build_revision package_cloud_token
      ).each do |a|
        node.set['snoopy_build'][a] = send(a) unless send(a).nil?
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'default attributes' do
    shared_examples_for 'any platform' do
      it 'does not install the package_cloud gem' do
        expect(chef_run).to_not install_gem_package('package_cloud')
      end

      it 'does not execute the artifact push' do
        expect(chef_run).to_not run_execute('Push artifacts to PackageCloud')
      end
    end

    context 'Ubuntu 14.04' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it_behaves_like 'any platform'
    end

    context 'Ubuntu 12.04' do
      let(:platform) { { platform: 'ubuntu', version: '12.04' } }

      it_behaves_like 'any platform'
    end

    context 'CentOS 7.0' do
      let(:platform) { { platform: 'centos', version: '7.0' } }

      it_behaves_like 'any platform'
    end

    context 'CentOS 6.6' do
      let(:platform) { { platform: 'centos', version: '6.6' } }

      it_behaves_like 'any platform'
    end
  end

  context 'artifact publishing enabled' do
    let(:publish_artifacts) { true }

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
              "#{File.expand_path('~/fpm-recipes/snoopy/pkg')}/snoopy_2.4.4" \
              '-1_amd64.deb'
        expect(chef_run).to run_execute(cmd).with(
          environment: { 'PACKAGECLOUD_TOKEN' => 'testtest' }
        )
      end
    end

    context 'Ubuntu 12.04' do
      let(:platform) { { platform: 'ubuntu', version: '12.04' } }

      it_behaves_like 'any platform'

      it 'uploads the correct new package' do
        cmd = 'package_cloud push socrata-platform/snoopy/ubuntu/precise ' \
              "#{File.expand_path('~/fpm-recipes/snoopy/pkg')}/snoopy_2.4.4" \
              '-1_amd64.deb'
        expect(chef_run).to run_execute(cmd).with(
          environment: { 'PACKAGECLOUD_TOKEN' => 'testtest' }
        )
      end
    end

    context 'CentOS 7.0' do
      let(:platform) { { platform: 'centos', version: '7.0' } }

      it_behaves_like 'any platform'

      it 'uploads the correct new package' do
        cmd = 'package_cloud push socrata-platform/snoopy/el/7 ' \
              "#{File.expand_path('~/fpm-recipes/snoopy/pkg')}/snoopy-2.4.4" \
              '-1.x86_64.rpm'
        expect(chef_run).to run_execute(cmd).with(
          environment: { 'PACKAGECLOUD_TOKEN' => 'testtest' }
        )
      end
    end

    context 'CentOS 6.6' do
      let(:platform) { { platform: 'centos', version: '6.6' } }

      it_behaves_like 'any platform'

      it 'uploads the correct new package' do
        cmd = 'package_cloud push socrata-platform/snoopy/el/6 ' \
              "#{File.expand_path('~/fpm-recipes/snoopy/pkg')}/snoopy-2.4.4" \
              '-1.x86_64.rpm'
        expect(chef_run).to run_execute(cmd).with(
          environment: { 'PACKAGECLOUD_TOKEN' => 'testtest' }
        )
      end
    end
  end
end
