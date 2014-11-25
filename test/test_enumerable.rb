require 'helper'

class TestEnumerable < Test::Unit::TestCase
  def test_enumerable_sugar
    map = []

    # Slight variation of .each_cons(2)
    # Yields (nil, elem0) for the first element, as opposed to (elem0, elem1)
    ['div', 'li', 'table'].each_with_previous do |a,b|
      map << [a,b]
    end 

    assert_equal([[nil, 'div'], ['div', 'li'], ['li', 'table']], map)
  end
end
