# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::default' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'installs the packagecloud gem' do
    expect(chef_run).to install_chef_gem('packagecloud-ruby')
      .with(compile_time: false)
  end

  it 'runs the version calculator ruby block' do
    expect(chef_run).to run_ruby_block('Calculate package version')
  end

  %w(_build _verify _deploy).each do |r|
    it "runs the '#{r}' recipe" do
      expect(chef_run).to include_recipe("snoopy-build::#{r}")
    end
  end
end
