# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-omnibus::deploy' do
  let(:ruby_version) { '1.2.3' }
  let(:runner) do
    ChefSpec::SoloRunner.new do |node|
      node.set['omnibus']['ruby_version'] = ruby_version
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  it 'installs the package_cloud gem' do
    expect(chef_run).to install_ruby_gem('package_cloud')
      .with(ruby: ruby_version)
  end
end
