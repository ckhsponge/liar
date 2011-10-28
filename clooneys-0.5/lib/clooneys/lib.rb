class Fixnum
  def factorial
    return 1 if self == 0
    self.downto(1).inject(:*)
  end

  def choose( k )
    self.factorial / ( k.factorial * (self - k).factorial )
  end

  def clone
    self
  end
end

class TrueClass
  def clone
    self
  end
end

class FalseClass
  def clone
    self
  end
end
