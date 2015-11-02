# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/helpers'

describe SnoopyBuildCookbook::Helpers do
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
    let(:repo) { 'a_repo' }
    let(:user) { 'a_user' }
    let(:token) { 'abc123' }

    it 'saves the input strings as variables for use later' do
      described_class.configure!(repo, user, token)
      expect(described_class.repo).to eq(repo)
      expect(described_class.user).to eq(user)
      expect(described_class.token).to eq(token)
    end
  end
end
