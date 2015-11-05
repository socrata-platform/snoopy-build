# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/helpers_builder'

describe SnoopyBuildCookbook::Helpers::Builder do
  describe '.configure!' do
    let(:user) { 'a_user' }
    let(:token) { 'abc123' }
    let(:repo) { 'a_repo' }
    let(:platform) { 'a_platform' }
    let(:platform_version) { '1.2' }
    let(:lsb_codename) { 'a_codename' }
    let(:platform_family) { 'a_platform_family' }
    let(:version) { '1.2.3' }
    let(:revision) { 4 }
    let(:configured_class) do
      described_class.configure!(user: user,
                                 token: token,
                                 repo: repo,
                                 platform: platform,
                                 platform_version: platform_version,
                                 lsb_codename: lsb_codename,
                                 platform_family: platform_family,
                                 version: version,
                                 revision: revision)
    end

    context 'all attributes provided' do
      let(:user) { 'a_user' }
      let(:token) { 'abc123' }
      let(:repo) { 'a_repo' }
      let(:platform) { 'a_platform' }
      let(:platform_version) { '1.2' }
      let(:lsb_codename) { 'a_codename' }
      let(:platform_family) { 'a_platform_family' }
      let(:version) { '1.2.3' }
      let(:revision) { 4 }

      %i(
        user token repo platform platform_version lsb_codename platform_family
        version revision
      ).each do |a|
        it "saves the #{a}" do
          expect(configured_class.send(a)).to eq(send(a))
        end
      end

      it 'returns itself' do
        expect(configured_class).to eq(described_class)
      end
    end

    %i(
      user token repo platform platform_version platform_family version
      revision
    ).each do |a|
      context "missing the #{a} attribute" do
        let(a) { nil }

        it 'raises an error' do
          expected = SnoopyBuildCookbook::Helpers::MissingConfig
          expect { configured_class }.to raise_error(expected)
        end
      end
    end

    context 'missing the lsb_codename attribute' do
      let(:lsb_codename) { nil }

      it 'saves nil as the lsb_codename' do
        expect(configured_class.lsb_codename).to eq(nil)
      end
    end
  end

  describe '.push_package!' do
    let(:client) { double }
    let(:package) { 'dummy package' }

    before(:each) do
      allow(described_class).to receive(:client).and_return(client)
      allow(client).to receive(:put_package)
      allow(described_class).to receive(:package).and_return(package)
    end

    it 'uploads the package to PackageCloud' do
      expect(client).to receive(:put_package).with('a_repo', package)
      described_class.push_package!
    end
  end

  describe '.package' do
    let(:package_file) { 'dummy package _file' }
    let(:distro_id) { 'dummy distro id' }

    before(:each) do
      %i(package_file distro_id).each do |a|
        allow(described_class).to receive(a).and_return(send(a))
      end
      allow(described_class).to receive(:open).with(package_file)
        .and_return(package_file)
    end

    it 'returns a Packagecloud::Package object' do
      require 'packagecloud'
      expect(Packagecloud::Package).to receive(:new).with(package_file,
                                                          distro_id)
      described_class.package
    end
  end

  describe '.package_file' do
    let(:platform_family) { nil }
    let(:version) { '1.2.3' }
    let(:revision) { 4 }

    before(:each) do
      %i(platform_family version revision).each do |a|
        allow(described_class).to receive(a).and_return(send(a))
      end
    end

    context 'Ubuntu' do
      let(:platform_family) { 'debian' }

      it 'returns the expected path' do
        expected = File.expand_path('~/fpm-recipes/snoopy/pkg/' \
                                    'snoopy_1.2.3-4_amd64.deb')
        expect(described_class.package_file).to eq(expected)
      end
    end

    context 'CentOS' do
      let(:platform_family) { 'rhel' }

      it 'returns the expected path' do
        expected = File.expand_path('~/fpm-recipes/snoopy/pkg/' \
                                    'snoopy-1.2.3-4.x86_64.rpm')
        expect(described_class.package_file).to eq(expected)
      end
    end
  end

  describe '.distro_id' do
    let(:platform) { nil }
    let(:platform_version) { nil }
    let(:platform_family) { nil }
    let(:lsb_codename) { nil }
    let(:client) { double }

    before(:each) do
      %i(
        platform platform_version platform_family lsb_codename client
      ).each do |a|
        allow(described_class).to receive(a).and_return(send(a))
      end
    end

    context 'Ubuntu' do
      let(:platform) { 'ubuntu' }
      let(:platform_family) { 'debian' }

      context '14.04' do
        let(:platform_version) { '14.04' }
        let(:lsb_codename) { 'trusty' }

        it 'uses the proper distro name' do
          expected = 'ubuntu/trusty'
          expect(client).to receive(:find_distribution_id).with(expected)
          described_class.distro_id
        end
      end

      context '12.04' do
        let(:platform_version) { '12.04' }
        let(:lsb_codename) { 'precise' }

        it 'uses the proper distro name' do
          expected = 'ubuntu/precise'
          expect(client).to receive(:find_distribution_id).with(expected)
          described_class.distro_id
        end
      end
    end

    context 'CentOS' do
      let(:platform) { 'centos' }
      let(:platform_family) { 'rhel' }

      context '7.0' do
        let(:platform_version) { '7.0' }

        it 'uses the proper distro name' do
          expected = 'el/7'
          expect(client).to receive(:find_distribution_id).with(expected)
          described_class.distro_id
        end
      end

      context '6.6' do
        let(:platform_version) { '6.6' }

        it 'uses the proper distro name' do
          expected = 'el/6'
          expect(client).to receive(:find_distribution_id).with(expected)
          described_class.distro_id
        end
      end
    end
  end
end
