# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::default' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  %w(_configure _build _verify _deploy).each do |r|
    it "runs the '#{r}' recipe" do
      expect(chef_run).to include_recipe("snoopy-build::#{r}")
    end
  end
end
