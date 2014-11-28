require 'helper'

class TestSimhash < Test::Unit::TestCase
  def setup
    @hash1 = Jules.simhash('jules uses simhash')
    @hash2 = Jules.simhash('jules likes simhash')
    @hash3 = Jules.simhash('something else')
  end

  def test_simhash_similarity
    # Similar
    assert_equal(1.0, Simhash.similarity(@hash1, @hash1))

    # Quite similar
    assert_operator(1.0, :>, Simhash.similarity(@hash1, @hash2))
    assert_operator(0.5, :<, Simhash.similarity(@hash1, @hash2))

    # Not similar
    assert_operator(0.5, :>, Simhash.similarity(@hash1, @hash3))
    assert_operator(0.0, :<, Simhash.similarity(@hash1, @hash3))
  end

  def test_simhash_lotate
    # Create a fake set of bits: 1101000000000000...
    hash = ('1101' + ('0' * (Jules::SIMHASH_BITLENGTH - 4))).to_i(2)
    bits = ("%0#{Jules::SIMHASH_BITLENGTH}b" % hash)

    # First four bits
    assert_equal("1101", bits.chars.first(4).join)
    # Last four bits
    assert_equal("0000", bits.chars.last(4).join)

    lbits = ("%0#{Jules::SIMHASH_BITLENGTH}b" % Simhash.lotate(hash))

    assert_not_equal(lbits, bits)

    # First three bits
    assert_equal("101", lbits.chars.first(3).join)
    # Last three bits
    assert_equal("00001", lbits.chars.last(5).join)
  end

  def test_clustering
    # Three clusters with different hamming distances
    monsters = [
      'karolin and kathrin is three',         # 0
      'something else entirely',              # 1
      'karolin and kathrin iz three',         # 2
      '<div id="test">Test</div><p>Yes</p>',  # 3
      'karolin and kathrin iz thr33',         # 4
      'something 3lse entirely',              # 5
      'someth1ng els3 entirely',              # 6
      '<div id="test">Test</div><li>Yes</li>' # 7
    ]
    hashes = monsters
      .map { |monster| {simhash: Jules.simhash(monster), item: monster} }

    long_d = Simhash.hamming_distance(hashes[0][:simhash], hashes[1][:simhash])
    short_d = Simhash.hamming_distance(hashes[0][:simhash], hashes[2][:simhash])
    assert_operator(long_d, :>, short_d)

    long_d = Simhash.hamming_distance(hashes[3][:simhash], hashes[4][:simhash])
    short_d = Simhash.hamming_distance(hashes[3][:simhash], hashes[7][:simhash])
    assert_operator(long_d, :>, short_d)
    
    hashes.sort_by! {|item| item[:simhash] }

    assert_equal('karolin and kathrin iz thr33', hashes[0][:item])
    assert_equal('karolin and kathrin iz three', hashes[1][:item])
    assert_equal('karolin and kathrin is three', hashes[2][:item])
    assert_equal('someth1ng els3 entirely', hashes[3][:item])

    long_d = Simhash.hamming_distance(hashes[0][:simhash], hashes[3][:simhash])
    short_d = Simhash.hamming_distance(hashes[0][:simhash], hashes[1][:simhash])
    assert_operator(long_d, :>, short_d)
  end
end
