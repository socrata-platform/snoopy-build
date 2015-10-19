# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-omnibus::default' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'runs the build recipe' do
    expect(chef_run).to include_recipe('snoopy-omnibus::build')
  end
end
