require 'spec_helper'

describe Jules::Miners do
  subject { Jules::HTML('<li><h3>A</h3><li><h3>B</h3></li>') }

  describe '.lists' do
    it 'returns an array' do
      subject.lists.class.should == Array
    end
    it 'returns list level' do
      subject.lists.first[:level].should == 2
    end

    context ':items' do
      subject { Jules::HTML('<li><h3>A</h3><li><h3>B</h3></li>').lists[0][:items] }

      it 'returns list items' do
        subject.count.should == 2
      end
      it 'returns list item title' do
        titles = subject.first[:titles]
        titles.first.class.should == Jules::Abstractions::Title
        titles.first.text.should == 'A'
      end
    end
  end

  describe '.zebra_list?' do
    context 'AAAAAA' do
      subject {
        [
          Nokogiri::HTML('<tr><h3>A</h3></tr>'),
          Nokogiri::HTML('<tr><h3>B</h3></tr>'),
          Nokogiri::HTML('<tr><h3>C</h3></tr>'),
          Nokogiri::HTML('<tr><h3>D</h3><strong>Buy Now</strong></tr>')
        ]
      }
      it 'detects non zebra patterns' do
        Jules::Miners.zebra_list?(subject)[:stride].should == 0
        Jules::Miners.zebra_list?(subject)[:certainty].should > 0.9
      end
    end
    context 'ABABAB' do
      context 'certain' do
        subject {
          [
            Nokogiri::HTML('<div><h1>A</h1></div>'),
            Nokogiri::HTML('<div><span>Comments (1)</span></div>'),
            Nokogiri::HTML('<div><h1>B</h1></div>'),
            Nokogiri::HTML('<div><span>Comments (3)</span></div>'),
            Nokogiri::HTML('<div><h1>C</h1></div>'),
            Nokogiri::HTML('<div><span>Comments (8)</span></div>')
          ]
        }
        it 'detects zebra pattern stride of 1' do
          Jules::Miners.zebra_list?(subject)[:stride].should == 1
          Jules::Miners.zebra_list?(subject)[:certainty].should == 1.0
        end
      end
      context 'uncertain' do
        subject {
          [
            Nokogiri::HTML('<div><h1>A</h1></div>'),
            Nokogiri::HTML('<div><span>Comments (1)</span></div>'),
            Nokogiri::HTML('<div><h1>B</h1></div>'),
            Nokogiri::HTML('<div><span>Comments (3)</span></div>'),
            Nokogiri::HTML('<div><h1>C</h1></div>'),
            Nokogiri::HTML('<div><span><i>No Comments</i></span></div>')
          ]
        }
        it 'detects zebra pattern stride of 1' do
          Jules::Miners.zebra_list?(subject)[:stride].should == 1
          Jules::Miners.zebra_list?(subject)[:certainty].should > 0.95
          Jules::Miners.zebra_list?(subject)[:certainty].should < 1.00
        end
      end
    end
  end
end
