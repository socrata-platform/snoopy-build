# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/helpers'

describe SnoopyBuildCookbook::Helpers do
  describe '.configure!' do
    let(:user) { 'a_user' }
    let(:token) { 'abc123' }
    let(:repo) { 'a_repo' }
    let(:configured_class) do
      described_class.configure!(user: user, token: token, repo: repo)
    end

    context 'all required attributes provided' do
      let(:user) { 'a_user' }
      let(:token) { 'abc123' }
      let(:repo) { 'a_repo' }

      %i(user token repo).each do |a|
        it "saves the #{a}" do
          expect(configured_class.send(a)).to eq(send(a))
        end
      end

      it 'returns itself' do
        expect(configured_class).to eq(described_class)
      end
    end

    %i(user token repo).each do |a|
      context "missing the #{a} attribute" do
        let(a) { nil }

        it 'raises an error' do
          expected = SnoopyBuildCookbook::Helpers::MissingConfig
          expect { configured_class }.to raise_error(expected)
        end
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
end

describe SnoopyBuildCookbook::Helpers::MissingConfig do
  describe '#initialize' do
    it 'returns a custom error message' do
      expected = 'Config item `test` is required, but was not provided'
      expect(described_class.new('test').message).to eq(expected)
    end
  end
end
