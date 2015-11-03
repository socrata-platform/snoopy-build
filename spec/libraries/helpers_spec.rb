# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/helpers'

describe SnoopyBuildCookbook::Helpers do
  describe '.push_package!' do
    let(:client) { double }
    let(:package) { 'dummy package' }

    before(:each) do
      allow(described_class).to receive(:client).and_return(client)
      allow(client).to receive(:put_package)
      allow(described_class).to receive(:package).and_return(package)
    end

    it 'uploads the package to PackageCloud' do
      expect(client).to receive(:put_package).with('snoopy', package)
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

  describe '.version' do
    before(:each) do
      uri = URI('http://source.a2o.si/download/snoopy/' \
                'snoopy-latest-version.txt')
      allow(Net::HTTP).to receive(:get).with(uri).and_return("1.2.3\n")
    end

    it 'returns the most recent released version' do
      expect(described_class.version).to eq('1.2.3')
    end
  end

  describe '.revision' do
    let(:packages) { [] }
    let(:token) { 'token' }

    before(:each) do
      %i(token packages).each do |i|
        allow(described_class).to receive(i).and_return(send(i))
      end
    end

    context 'no configured PackageCloud token' do
      let(:token) { nil }

      it 'returns 1' do
        expect(described_class.revision).to eq(1)
      end
    end

    context 'an empty list of packages' do
      let(:packages) { [] }

      it 'returns 1' do
        expect(described_class.revision).to eq(1)
      end
    end

    context 'a populated list of packages' do
      let(:packages) do
        [
          { 'version' => '1.2.3', 'release' => '1' },
          { 'version' => '1.2.3', 'release' => '2' },
          { 'version' => '1.2.3', 'release' => '3' }
        ]
      end

      it 'returns 1 greater than the current revision' do
        expect(described_class.revision).to eq(4)
      end
    end
  end

  describe '.packages' do
    let(:packages) do
      [
        { 'version' => '1.0.0', 'release' => '3' },
        { 'version' => '1.0.0', 'release' => '4' },
        { 'version' => '1.2.3', 'release' => '1' },
        { 'version' => '1.2.3', 'release' => '2' }
      ]
    end
    let(:client) { double(list_packages: double(response: packages)) }
    let(:version) { '1.2.3' }

    before(:each) do
      allow(described_class).to receive(:repo).and_return('repo')
      %i(client version).each do |i|
        allow(described_class).to receive(i).and_return(send(i))
      end
    end

    it 'returns the packages that match the most recent version' do
      expected = [
        { 'version' => '1.2.3', 'release' => '1' },
        { 'version' => '1.2.3', 'release' => '2' }
      ]
      expect(described_class.packages).to eq(expected)
    end
  end

  describe '.client' do
    let(:credentials) { 'somecreds' }

    before(:each) do
      allow(described_class).to receive(:credentials).and_return(credentials)
    end

    it 'returns a Packagecloud::Client instance' do
      require 'packagecloud'
      expect(Packagecloud::Client).to receive(:new).with(credentials)
      described_class.client
    end
  end

  describe '.credentials' do
    let(:user) { 'someuser' }
    let(:token) { 'abc123' }

    before(:each) do
      %i(user token).each do |i|
        allow(described_class).to receive(i).and_return(send(i))
      end
    end

    it 'returns a Packagecloud::Credentials instance' do
      require 'packagecloud'
      expect(Packagecloud::Credentials).to receive(:new).with(user, token)
      described_class.credentials
    end
  end

  describe '.configure!' do
    let(:platform) { nil }
    let(:attrs) { { repo: 'a_repo', user: 'a_user', token: 'abc123' } }
    let(:node) do
      n = Mash.new(Fauxhai.mock(platform).data)
      n['snoopy_build'] = { package_cloud_repo: attrs[:repo],
                            package_cloud_user: attrs[:user],
                            package_cloud_token: attrs[:token] }
      n
    end

    shared_examples_for 'any platform' do
      %i(repo user token).each do |a|
        it "saves the #{a}" do
          expect(described_class.configure!(node).send(a)).to eq(attrs[a])
        end
      end
    end

    shared_examples_for 'ubuntu' do
      it 'saves the platform name' do
        expect(described_class.configure!(node).platform).to eq('ubuntu')
      end

      it 'saves the platform family' do
        expect(described_class.configure!(node).platform_family).to eq('debian')
      end
    end

    shared_examples_for 'centos' do
      it 'saves the platform name' do
        expect(described_class.configure!(node).platform).to eq('centos')
      end

      it 'saves the platform family' do
        expect(described_class.configure!(node).platform_family).to eq('rhel')
      end
    end

    context 'Ubuntu 14.04' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it_behaves_like 'any platform'
      it_behaves_like 'ubuntu'

      it 'saves the platform version' do
        expect(described_class.configure!(node).platform_version).to eq('14.04')
      end

      it 'saves the lsb codename' do
        expect(described_class.configure!(node).lsb_codename).to eq('trusty')
      end
    end

    context 'Ubuntu 12.04' do
      let(:platform) { { platform: 'ubuntu', version: '12.04' } }

      it_behaves_like 'any platform'

      it 'saves the platform version' do
        expect(described_class.configure!(node).platform_version).to eq('12.04')
      end

      it 'saves the lsb codename' do
        expect(described_class.configure!(node).lsb_codename).to eq('precise')
      end
    end

    context 'CentOS 7.0' do
      let(:platform) { { platform: 'centos', version: '7.0' } }

      it_behaves_like 'any platform'

      it 'saves the platform version' do
        expect(described_class.configure!(node).platform_version)
          .to eq('7.0.1406')
      end

      it 'does not save the lsb codename' do
        expect(described_class.configure!(node).lsb_codename).to eq(nil)
      end
    end

    context 'CentOS 6.6' do
      let(:platform) { { platform: 'centos', version: '6.6' } }

      it_behaves_like 'any platform'

      it 'saves the platform version' do
        expect(described_class.configure!(node).platform_version).to eq('6.6')
      end

      it 'does not save the lsb codename' do
        expect(described_class.configure!(node).lsb_codename).to eq(nil)
      end
    end
  end
end
