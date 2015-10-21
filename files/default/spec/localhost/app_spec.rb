# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy::app' do
  describe package('snoopy') do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end

  describe file('/etc/snoopy.ini') do
    it 'exists' do
      expect(subject).to be_file
    end
  end

  describe file('/lib/libsnoopy.so') do
    it 'exists' do
      expect(subject).to be_file
    end
  end

  describe file('/var/log/auth.log') do
    it 'is logging system commands' do
      command('ls')
      expect(subject.content).to match(%r{snoopy.*filename:/bin/ls})
    end
  end
end
