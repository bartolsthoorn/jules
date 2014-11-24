require 'helper'

class TestNokogiri < Test::Unit::TestCase
  def setup
    @html = '<li><b>Unit Testing</b></li><li>X</li>'
  end

  def test_nokogiri_sugar
    assert_equal(
      '<li></li><li></li>',
      Nokogiri::XML.remove_markup_outline(@html)
    )
  end
end
