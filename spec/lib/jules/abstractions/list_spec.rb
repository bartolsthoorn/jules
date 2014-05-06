require 'spec_helper'

describe Jules::Abstractions::List do
  subject { described_class.new('abc', 'abc') }

  describe 'responds to attributes' do
    it { should respond_to :title }
    it { should respond_to :content }
  end
end
