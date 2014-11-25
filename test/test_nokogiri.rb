require 'helper'

class TestNokogiri < Test::Unit::TestCase
  def setup
    @html1 = '<li id="x"><b>Unit</b> Testing</li><li><a href="#">X</a></li>'
    @html2 = '<li class="a b">Testing</li>'
    @html3 = '<div class="a" id="b">Testing</div>'
  end

  def test_nokogiri_sugar
    assert_equal(
      '<li id="x"></li><li><a></a></li>',
      Nokogiri::XML.remove_markup_outline(@html1)
    )
    assert_equal(
      '<li class="a b"></li>',
      Nokogiri::XML.remove_markup_outline(@html2)
    )
    assert_equal(
      '<div id="b" class="a"></div>',
      Nokogiri::XML.remove_markup_outline(@html3)
    )
  end
end
