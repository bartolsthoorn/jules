module Jules
  class << self
    def HTML(html, options = {})
      raise ArgumentError if html.class != String
      Jules::Document.new html
    end
  end

  class Document
    attr_accessor :html

    def initialize(html)
      @html = Nokogiri::HTML::Document.parse html
    end

    def titles
      Jules::Miners.titles @html
    end
    def lists
      Jules::Miners.lists @html
    end
  end
end
