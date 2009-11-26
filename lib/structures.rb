#!/usr/bin/env ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: rplac structures file
* Description: this file contains the definitions of the geometric 
structures neededs for the algorithms
* Author: Joel Uchoa
* Date: 2009-11-21
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

require 'lib/circular_sorted_list'
require 'lib/painter'

EPS = 1e-9

class Point
  include Comparable
  attr_reader :x, :y

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

  def angle # angle of the vector (0,0)--(x,y)
    Math.atan2(@y, @x)
  end

  def hypot # hypotenuse, size of the vector (0,0)--(x,y)
    Math.hypot(@x,@y)
  end

  def <=>(other)
    return x < other.x ? -1 : 1 if (x - other.x).abs >= EPS
    return y < other.y ? -1 : 1 if (y - other.y).abs >= EPS
    return 0
  end

  def to_s
    "(#@x, #@y)"
  end

end

class Vertex
  attr_reader :point
  attr_accessor :edges

  def initialize(point)
    @point = point
    @edges = CircularSortedList.new
  end

end

class Edge
  include Comparable
  attr_reader :origin, :dual
  attr_accessor :next, :prev, :face
  
  def initialize(origin, destination, dual = nil)
    @origin = origin
    @dual = dual || Edge.new(destination, origin, self)

    @angle = (destination.point - origin.point).angle
    @size = (destination.point - origin.point).hypot
  end

  def <=>(other)
    return @origin < other.origin ? -1 : 1 if @origin != other.origin
    return @angle < other.angle ? -1 : 1 if (@angle - other.angle).abs >= EPS
    return @size < other.size ? -1 : 1 if (@size - other.size).abs >= EPS
    return 0
  end

end

class Face
  
end

class DoubleConnectedEdgeList
  
  def initialize
    @vertexes = []
    @edges = []
    @faces = []
  end

  def add_vertex(point)
    @vertexes << Vertex.new(point)
  end

  def add_edge(vertex1_idx, vertex2_idx)
    @edges << Edge.new(@vertexes[vertex1_idx], @vertexes[vertex2_idx])
    #TODO
  end
  
end

class Map
  attr_reader :points, :edges
  
  def initialize
    @points = []
    @edges = []
    @structure = DoubleConnectedEdgeList.new
  end

  def add_point(point)
    @points << point
    @structure.add_vertex(point)
  end

  def add_edge(point1_idx, point2_idx)
    @edges << [point1_idx, point2_idx]
    @structure.add_edge(point1_idx, point2_idx)
  end

  def paint(painter)
    @points.each { |p| painter.draw_point(p, WHITE) }
    @edges.each { |e| painter.draw_line(@points[e[0]], @points[e[1]], WHITE) }
  end

end
