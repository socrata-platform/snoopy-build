# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::default' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'runs the build recipe' do
    expect(chef_run).to include_recipe('snoopy-build::build')
  end

  it 'runs the verify recipe' do
    expect(chef_run).to include_recipe('snoopy-build::verify')
  end

  it 'does _not_ run the deploy recipe' do
    expect(chef_run).to_not include_recipe('snoopy-build::deploy')
  end
end
