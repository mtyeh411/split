require 'pry'
require 'spec_helper'
require 'split/user'

describe Split::User do
  let(:context) { double(session: {}) }
  subject    { described_class.new(context) }

  xit 'should return a Split::Persistence instance' do
    subject.should be_instanceof(Split::Persistence)
  end
end