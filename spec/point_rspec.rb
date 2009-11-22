require 'rubygems'
require 'spec'
require 'lib/point'

describe Point do
  
  it "should to set coordenates values" do
    a = Point.new
    b = Point.new(1,2)
    a.x.should == 0 and a.y.should == 0 and b.x.should == 1 and b.y.should == 2
  end

  it "should to add two points" do
    a = Point.new(3.2, 4.1)
    b = Point.new(1.7, 3.91)
    c = a + b
    c.should == Point.new(4.9, 8.01)
  end

  it "should to subtract two points" do
    a = Point.new(3.2, 4.1)
    b = Point.new(1.7, 3.91)
    c = a - b
    c.should == Point.new(1.5, 0.19)
  end

  it "should to multiply a point for a scalar" do
    a = Point.new(3.2, 4.1)
    b = a * 3
    b.should == Point.new(9.6, 12.3)
  end

  it "should to make the cross product for two points" do
    a = Point.new(3.2, 4.1)
    b = Point.new(1.7, 3.91)
    c = a % b
    c.should == Point.new(3.2 * 3.91, 4.1 * 1.7)
  end

end
