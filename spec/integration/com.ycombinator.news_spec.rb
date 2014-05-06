require 'spec_helper'
=begin
describe 'news.ycombinator.com' do
  let(:file) { 'spec/integration/html/com.ycombinator.news.html' }
  subject {
    html = File.open(file, 'rb') { |f| f.read }
    Jules::HTML(html)
  }
  describe '.titles' do
    it 'has zero titles' do
      subject.titles.count.should == 0
    end
  end
  describe '.lists' do
    it 'has multiple lists' do
      subject.lists.count.should == 3
    end
  end
end
=end
