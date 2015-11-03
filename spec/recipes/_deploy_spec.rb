# Encoding: UTF-8

require_relative '../spec_helper'

describe 'snoopy-build::_deploy' do
  let(:publish_artifacts) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new do |node|
      unless publish_artifacts.nil?
        node.set['snoopy_build']['publish_artifacts'] = publish_artifacts
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'default attributes' do
    it 'does not execute the artifact push' do
      expect(chef_run).to_not run_ruby_block('Push artifacts to PackageCloud')
    end
  end

  context 'artifact publishing enabled' do
    let(:publish_artifacts) { true }

    it 'executes the artifact push' do
      expect(chef_run).to run_ruby_block('Push artifacts to PackageCloud')
    end
  end
end
