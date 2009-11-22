
EPS = 1e-9

class Point
  attr_accessor :x, :y

  def initialize(x=0, y=0)
    @x, @y = x.to_f, y.to_f
  end

  def +(other)
    Point.new(@x + other.x, @y + other.y)
  end

  def -(other)
    Point.new(@x - other.x, @y - other.y)
  end

  def *(scalar)
    Point.new(@x * scalar, @y * scalar)
  end

  def %(other) # cross product
    Point.new(@x * other.y, @y * other.x)
  end

  def <=>(other)
    return x < other.x ? -1 : 1 if (x - other.x).abs > EPS
    return y < other.y ? -1 : 1 if (y - other.y).abs > EPS
    return 0
  end

  def ==(other)
    (self <=> other) == 0
  end

  def to_s
    "(#@x, #@y)"
  end

end
