# Add some sugar to Nokogiri
# http://stackoverflow.com/questions/7176094/how-do-i-create-an-outline-of-the-html-tag-structure-on-the-page-using-nokogiri
# http://stackoverflow.com/questions/5694759/how-do-you-calculate-the-number-of-levels-of-descendants-of-a-nokogiri-node
class Nokogiri::XML::Node
  def to_outline
    children.find_all(&:element?).map(&:to_outline).join
  end
  def depth
    ancestors.size
    # The following is ~10x slower: xpath('count(ancestor::node())').to_i
  end
  def leaves
    xpath('.//*[not(*)]').to_a
  end
  def height
    tallest = leaves.map{ |leaf| leaf.depth }.max
    tallest ? tallest - depth : 0
  end
  def deepest_leaves
    by_height = leaves.group_by{ |leaf| leaf.depth }
    by_height[ by_height.keys.max ]
  end
  def deepest_level
    by_height = leaves.group_by{ |leaf| leaf.depth }
    by_height.keys.max
  end
end

module Nokogiri::XML
  def self.remove_markup_outline(str)
    f = Nokogiri::XML.fragment(str)
    ['b', 'strong', 'strike', 'i', 'u', 'img'].each do |s|
      f.search('.//' + s).remove
    end
    f.to_outline
  end
end

class Nokogiri::XML::Element
  def to_outline
    "<#{name}>#{super}</#{name}>"
  end
end
