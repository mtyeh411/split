require 'pry'
require 'spec_helper'
require 'split/experiment_catalog'
require 'split/experiment'
require 'split/user'

describe Split::User do
  let(:context) do
    double(:session => { split: { 'link_color' => 'blue' } })
  end

  subject { described_class.new(context) }

  it 'delegates methods correctly' do
    expect(subject.user).to receive(:[]).with('link_color').once
    subject['link_color']
  end

  context '#cleanup_old_experiments' do
    let(:experiment) { Split::Experiment.new('link_color') }

    before(:each) do
      Split.configuration.allow_multiple_experiments = true
    end

    it 'removes key if experiment is not found' do
      allow_any_instance_of(Split::ExperimentCatalog).to receive(:find).with('link_color').and_return(nil)
      expect(subject.user).to receive(:delete).with('link_color')
    end

    it 'removes key if experiment has a winner' do
      allow_any_instance_of(Split::ExperimentCatalog).to receive(:find).with('link_color').and_return(experiment)
      allow(experiment).to receive(:has_winner?).and_return(true)
      expect(subject.user).to receive(:delete).with('link_color')
    end
  end
end