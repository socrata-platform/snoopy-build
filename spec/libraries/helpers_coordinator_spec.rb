# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/helpers_coordinator'

describe SnoopyBuildCookbook::Helpers::Coordinator do
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
end
