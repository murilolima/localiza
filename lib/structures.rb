#!/usr/bin/ruby -w
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
    @x, @y = x.to_i, y.to_i
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
    return x < other.x ? -1 : 1 if x != other.x
    return y < other.y ? -1 : 1 if y != other.y
    return 0
  end

  def to_s
    "(#@x, #@y)"
  end

  def inspect
    "#Point<#{to_s}>"
  end

end

# geometric functions/predicates (global)
def area2(p1, p2, p3)
  v1 = p1.x * p2.y + p2.x * p3.y + p3.x * p1.y
  v2 = p1.y * p2.x + p2.y * p3.x + p3.y * p1.x
  v1 - v2
end

def left(p1, p2, p3)
  area2(p1, p2, p3) >= 0
end

def lefts(p1, p2, p3)
  area2(p1, p2, p3) > 0
end

def right(p1, p2, p3)
  !lefts(p1, p2, p3)
end

def rights(p1, p2, p3)
  !left(p1, p2, p3)
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
  attr_reader :origin, :dual, :angle, :size
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
    vertex_a = @vertexes[vertex1_idx]
    vertex_b = @vertexes[vertex2_idx]

    edge_a = Edge.new(vertex_a, vertex_b)
    edge_b = edge_a.dual

    @edges << edge_a
    @edges << edge_b

    iterator_edge_a = vertex_a.edges.insert(edge_a)
    iterator_edge_b = vertex_b.edges.insert(edge_b)

    edge_a.prev = iterator_edge_a.next_node.info.dual
    iterator_edge_a.next_node.info.dual.next = edge_a

    edge_a.next = iterator_edge_b.previous_node.info
    iterator_edge_b.previous_node.info.prev = edge_a

    edge_b.prev = iterator_edge_b.next_node.info.dual
    iterator_edge_b.next_node.info.dual.next = edge_b

    edge_b.next = iterator_edge_a.previous_node.info
    iterator_edge_a.previous_node.info.prev = edge_b

  end

  def get_face_of_edge(edge_idx)
    iterator = first = @edges[edge_idx]
    vector = [first]
    while iterator.next != first 
      iterator = iterator.next
      vector << iterator
    end
    vector
  end

  def debug(painter)
    Thread.new do
      @edges.each_with_index do |e,i| 
        v = get_face_of_edge(i).map{ |e| e.origin.point }
        STDERR.puts "FACES -----\n"+v.to_s
        sleep 3
        yield
        painter.draw_polygon(v,i%2==0 ? BLUE : RED)
      end
    end
  end
  
end

class Map
  attr_reader :points, :edges, :structure
  
  def initialize
    @points = []
    @edges = []
  end

  def add_point(point)
    @points << point
  end

  def add_edge(point1_idx, point2_idx)
    @edges << [point1_idx, point2_idx]
  end

  def build_structure
    @structure = DoubleConnectedEdgeList.new
    @points.each { |p| @structure.add_vertex(p) }
    @edges.each { |e| @structure.add_edge(e[0], e[1]) }
  end

  def paint(painter)
    painter.clear
    @edges.each { |e| painter.draw_line(@points[e[0]], @points[e[1]], GREY) }
    @points.each { |p| painter.draw_point(p, GREY) }
  end

end
