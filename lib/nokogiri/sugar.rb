# Add some sugar to Nokogiri
class Nokogiri::XML::Node
  def to_outline
    children.find_all(&:element?).map(&:to_outline).join
  end
  def depth
    ancestors.size
  end
end

class Nokogiri::XML::Element
  def to_outline
    if self['id'] && self['class']
      "<#{name} id=\"#{self['id']}\" class=\"#{self['class']}\">#{super}</#{name}>"
    elsif self['id']
      "<#{name} id=\"#{self['id']}\">#{super}</#{name}>"
    elsif self['class']
      "<#{name} class=\"#{self['class']}\">#{super}</#{name}>"
    else
      "<#{name}>#{super}</#{name}>"
    end
  end
end

module Nokogiri::XML
  def self.remove_markup_outline(str)
    f = Nokogiri::XML.fragment(str)
    ['b', 'strong', 'strike', 'i', 'u'].each do |s|
      f.search('.//' + s).remove
    end
    f.to_outline
  end
end
