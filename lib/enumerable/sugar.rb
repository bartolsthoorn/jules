module Enumerable
  def each_with_previous
    self.inject(nil){|prev, curr| yield prev, curr; curr}
    self
  end
end
