# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy::app' do
  describe package('snoopy') do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end

  describe file('/etc/snoopy.ini') do
    it 'links to the Omnibussed file' do
      expect(subject).to be_linked_to('/opt/snoopy/etc/snoopy.ini')
    end
  end

  describe file('/lib/libsnoopy.so') do
    it 'links to the Omnibussed file' do
      expect(subject).to be_linked_to('/opt/snoopy/lib/libsnoopy.so')
    end
  end
end
