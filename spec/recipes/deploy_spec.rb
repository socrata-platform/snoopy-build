# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-omnibus::deploy' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'succeeds' do
    expect(chef_run).to be
  end
end
