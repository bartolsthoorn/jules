require 'spec_helper'

describe Jules::Miners do
  subject { Jules::HTML('<html><h1>Fromage</h1>') }

  describe '.titles' do
    it 'returns an array' do
      subject.titles.class.should == Array
    end
    it 'returns the title as abstraction' do
      subject.titles.first.class.should == Jules::Abstractions::Title
    end
    it 'returns the title level' do
      subject.titles.first.level.should == 1
    end
    it 'returns the title text' do
      subject.titles.first.text.should == 'Fromage'
    end
    it 'detects the title language' do
      subject.titles.first.language.should == :french
    end
  end
end
