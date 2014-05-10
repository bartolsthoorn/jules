require 'spec_helper'

describe Nokogiri::HTML do
  subject { Nokogiri::HTML('<html><body><h1 id="x">X</h1>') }

  describe '.to_outline' do
    it 'converts HTML document to outline' do
      subject.to_outline.should == '<html><body><h1></h1></body></html>'
    end
  end

  describe '.deepest_level' do
    it 'finds the depth of the document' do
      subject.deepest_level.should == 3
    end
  end

  describe '.deepest_leaves' do
    it 'finds the deepest leaves' do
      subject.deepest_leaves.first.name.should == 'h1'
    end
  end

  describe '.height' do
    it 'finds the height of selected element (relative to deepest level)' do
      body = subject.at_xpath('//body')
      body.height.should == 1
    end
  end

  describe '.leaves' do
    it 'finds all the leaves' do
      subject.leaves.map(&:name).should == ['h1']
    end
  end

  describe '.remove_markup_outline' do
    it 'deletes HTML markup' do
      Nokogiri::XML.remove_markup_outline('<div>T<b>e</b>st').should == '<div></div>'
    end
  end
end
