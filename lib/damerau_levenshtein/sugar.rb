module DamerauLevenshtein
  # returns 1.0 for completely different strings
  # returns 0.0 for completely identical strings
  def self.relative(a, b)
    length = [a.length, b.length].max
    return DamerauLevenshtein.distance(a, b).to_f / length
  end
end
DL = DamerauLevenshtein
