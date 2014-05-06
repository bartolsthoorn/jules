require 'spec_helper'

describe Jules::Abstractions::Title do
  subject { described_class.new(1, 'Arcade Fire') }

  context 'wrong level argument' do
    it 'raises error when not providing fixnum' do
      expect { described_class.new('', '') }.to raise_error ArgumentError
    end
  end

  context 'wrong text argument' do
    it 'raises error when not providing a string' do
      expect { described_class.new(1, []) }.to raise_error ArgumentError
    end
  end

  describe 'attributes' do
    it 'has level' do
      subject.level.should == 1
    end
    it 'has text' do
      subject.text.should == 'Arcade Fire'
    end
    it 'has language' do
      subject.language.should == :english
    end
  end
end
