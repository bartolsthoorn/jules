require 'spec_helper'

describe 'basic_list.html' do
  let(:file) { 'spec/integration/html/basic_list.html' }
  subject {
    html = File.open(file, 'rb') { |f| f.read }
    Jules::HTML(html)
  }
  describe '.titles' do
    it 'has titles' do
      subject.titles.count.should == 4
    end
    it 'finds text of titles' do
      subject.titles[0].text.should == 'My Favourite Food'
      subject.titles[1].text.should == 'Other Favourite Stuff'
    end
  end
  describe '.lists' do
    context 'food list' do
      it 'finds the level of the food list' do
        subject.lists[0][:level].should == 4
      end
      it 'finds food list' do
        subject.lists[0][:items].count.should == 4
      end
      it 'finds food list text' do
        subject.lists[0][:items].first[:text].should == 'Strawberry Pie'
      end
    end
    context 'other list' do
      it 'finds the level of the other list' do
        subject.lists[1][:level].should == 4
      end
      it 'finds two items' do
        subject.lists[1][:items].count.should == 2
      end
    end
    context 'composed list' do
      it 'finds the composed list as two seperate items' do
        #pp subject.lists[2][:items].map{|x| x[:node] }
        subject.lists[2][:level].should == 4
        subject.lists[2][:items].count.should == 2
      end
    end
  end
end
