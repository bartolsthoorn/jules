require 'spec_helper'

describe Jules::Document do
  describe '::HTML' do
    subject { Jules::HTML('<html><h1>Hello</h1>') }
    it 'raises error when feeding NOT a string' do
      expect { Jules::HTML([]) }.to raise_error
    end

    it 'does not raise an error when feeding a string' do
      expect { Jules::HTML('') }.to_not raise_error
    end

    it 'returns a Jules::Document' do
      subject.class.should == Jules::Document
    end

    it 'parsed the HTML' do
      subject.html.class.should == Nokogiri::HTML::Document
    end
  end
end
