module Simhash
  def self.hamming_distance(hash1, hash2)
    (hash1 ^ hash2).to_s(2).count('1')
  end

  def self.similarity(hash1, hash2)
    1 - (Simhash.hamming_distance(hash1, hash2) / Jules::SIMHASH_BITLENGTH.to_f)
  end

  # Bitwise left rotate
  def self.lotate(hash, n=1)
    (hash << n | hash >> (Jules::SIMHASH_BITLENGTH - n)) &
      ('1'*Jules::SIMHASH_BITLENGTH).to_i(2)
  end

  # Cluster
  def self.cluster(simhashes, threshold)
  end
end
