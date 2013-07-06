class Position
  attr_reader :x, :y
 
  def initialize(x=0, y=0)
    @x = x
    @y = y
  end

  def x= arg
    @x = arg.to_i
  end

  def y= arg
    @y = arg.to_i
  end
  
  def xy= arg1, arg2
    @x = arg1.to_i
    @y = arg2.to_i
  end

  def xy
    [@x, @y]
  end

  def yx
    [@y, @x]
  end

end


