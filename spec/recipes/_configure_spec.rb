# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::_configure' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'installs the packagecloud gem' do
    expect(chef_run).to install_chef_gem('packagecloud-ruby')
      .with(compile_time: false)
  end

  it 'runs the configuration ruby block' do
    expected = 'Configure the package builder helpers'
    expect(chef_run).to run_ruby_block(expected)
  end
end
