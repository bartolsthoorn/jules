require 'spec_helper'

describe DamerauLevenshtein do
  describe 'damerau-levenshtein' do
    it 'can compare html outlines' do
      a = Nokogiri::HTML('<div>A<span>B</span></div>').to_outline
      b = Nokogiri::HTML('<div>A<span>B</span></div>').to_outline
      c = Nokogiri::HTML('<div>A</div>').to_outline
      described_class.distance(a, b).should == 0
      described_class.distance(a, c).should == 11
      described_class.distance('xx', 'aa').should == 2
    end

    it 'can compare relatively' do
      described_class.relative('aaa', 'bbb').should == 1.0
      described_class.relative('aaa', 'aaa').should == 0.0
      described_class.relative('aaa', 'aab').should == 1.0/3.0
    end
  end
end
