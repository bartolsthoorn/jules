module Simhash
  def self.hamming_distance(hash1, hash2)
    (hash1 ^ hash2).to_s(2).count('1')
  end

  def self.similarity(hash1, hash2)
    1 - (Simhash.hamming_distance(hash1, hash2) / Jules::SIMHASH_BITLENGTH.to_f)
  end
end
