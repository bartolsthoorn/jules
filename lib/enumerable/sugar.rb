module Enumerable
  def each_with_previous
    self.inject(nil){|prev, curr| yield prev, curr; curr}
    self
  end
end

class Array
  def find_by_partial_hash(hash)
    self.select { |h| h.includes_hash?(hash) }
  end
end

class Hash
  def includes_hash?(other)
    included = true

    other.each do |key, value|
      included &= self[key] == other[key]
    end

    included
  end
end
