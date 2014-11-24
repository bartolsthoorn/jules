# Add some sugar to Nokogiri
class Nokogiri::XML::Node
  def to_outline
    children.find_all(&:element?).map(&:to_outline).join
  end
end

class Nokogiri::XML::Element
  def to_outline
    "<#{name}>#{super}</#{name}>"
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
