#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: randomized point location algorithm
* Description: randomized incremental algorithm. The data structure
consumes expected O(n) space and O(n lg n) time to be built. A query
consumes expected O(lg n) time. For a detailed description, see
de Berg et al. Computational geometry, algorithms and applications,
Springer Verlag, 2nd edition, 2000, ch. 6.

* Author: Murilo de Lima, Joel Uchoa
* Date: 2009-12-11
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

require 'lib/algorithm'
require 'lib/painter'
require 'lib/structures'

class Node
  attr_accessor :type, :data, :right, :left

  def initialize(type, data)
    @type = type
    @data = data

    @right = @left = nil
  end

  def find_trapezoid(e, alg)
    if @type == :TRAP
      self
    elsif @type == :EDGE
      lines = alg.painter.draw_triang(@data[0], @data[1], e[0], YELLOW)
      yield
      lines.each { |l| l.destroy }
      
      v = area2(@data[0], @data[1], e[0])
      if v > 0 or (v == 0 and (@data[1] - @data[0]).angle < (e[1] - e[0]).angle)
        @left.find_trapezoid(e, alg) { yield }
      else
        @right.find_trapezoid(e, alg) { yield }
      end
    else # @type == :POINT
      line = alg.painter.draw_line(@data, e[0], YELLOW)
      yield
      line.destroy

      if @data <= e[0]
        @right.find_trapezoid(e, alg) { yield }
      else
        @left.find_trapezoid(e, alg) { yield }
      end
    end
  end

  def find_point(p, alg)
    if @type == :TRAP
      idx = alg.edge_map[@data.bottom]
      if (idx == -1)
        alg.outside(p)
        yield
      else
        face_points = alg.map.structure.get_face_of_edge(idx).map { |e| e.origin.point }
        poly = alg.painter.draw_polygon(face_points, LIME, BLUE)
        pred = alg.painter.draw_point(p, RED)
        alg.mainbar.push(0, "--->>> Ponto localizado!")
        yield
        poly.destroy
        pred.destroy
      end
    elsif @type == :EDGE
      lines = alg.painter.draw_triang(@data[0], @data[1], p, YELLOW)
      yield
      lines.each { |l| l.destroy }

      v = area2(@data[0], @data[1], p)
      if v > 0
        @left.find_point(p, alg) { yield }
      elsif v < 0
        @right.find_point(p, alg) { yield }
      else
        alg.on_the_edge(p, @data)
        yield
      end
    else # @type == :POINT
      line = alg.painter.draw_line(@data, p, YELLOW)
      yield
      line.destroy

      if @data > p
        @left.find_point(p, alg) { yield }
      elsif @data < p
        @right.find_point(p, alg) { yield }
      else
        alg.on_the_point(p)
        yield
      end
    end
  end

  def inspect
    "#<Tree/Node:#{object_id}, @type=#{@type}, @data=#{@data.inspect},\n@left=#{@left.inspect},\n@right=#{@right.inspect}>"
  end
end

class Trapezoid
  attr_accessor :leftp, :rightp, :bottom, :top, :drawing
  attr_accessor :uln, :urn, :bln, :brn # isso tem que ser ponteiro pra nó
  def initialize(leftp, rightp, top, bottom)
    @leftp, @rightp, @bottom, @top = leftp, rightp, bottom, top
    @uln = @urn = @bln = @brn = @drawing = nil
  end

  def draw(painter, color)
    x1 = @leftp.x
    x2 = @rightp.x
    if x1 != x2
      p1 = Point.new(x1, y_find(@top, x1))
      p2 = Point.new(x1, y_find(@bottom, x1))
      p3 = Point.new(x2, y_find(@bottom, x2))
      p4 = Point.new(x2, y_find(@top, x2))
      @drawing = painter.draw_polygon([p1, p2, p3, p4], BLACK, color)
    end
  end

  private
  def y_find(e, x)
#    puts e.inspect + ", " + x.to_s
    if e[0].x == e[1].x
      e[0].y
    else
      (e[1].y*(x - e[0].x) - e[0].y*(x - e[1].x)).to_f/(e[1].x - e[0].x).to_f
    end
  end

  public
  def erase
    @drawing.destroy unless @drawing.nil?
    @drawing = nil
  end

  def inspect
    "#<Trapezoid @uln=#{@uln.object_id}, @bln=#{@bln.object_id}, @urn=#{@urn.object_id}, @brn=#{@brn.object_id}, @leftp=#{@leftp.inspect}, @rightp=#{@rightp.inspect}, @bottom=#{@bottom.inspect}, @top=#{@top.inspect}>"
  end
end

class Tree < Node
end

class Randomized < Algorithm
  attr_reader :edge_map
  
  def follow_segment(e)
    traps = [@tree.find_trapezoid(e, self) { yield }]
    traps[0].data.erase
    traps[0].data.draw(@painter, BLUE)
    redraw_edge(e)
    yield

    l1 = @painter.draw_line(e[1], traps.last.data.rightp, YELLOW)
    yield
    l1.destroy
    while e[1] > (lt = traps.last).data.rightp
      ls = @painter.draw_triang(e[0], e[1], lt.data.rightp, YELLOW)
      yield
      ls.each { |l| l.destroy }
      if right(e[0], e[1], lt.data.rightp)
        traps << lt.data.urn
      else
        traps << lt.data.brn
      end
      traps.last.data.erase
      traps.last.data.draw(@painter, BLUE)
      redraw_edge(e)
      yield
      l1 = @painter.draw_line(e[1], traps.last.data.rightp, YELLOW)
      yield
      l1.destroy
    end

    traps
  end

  def redraw_edge(e)
    @line.destroy unless @line.nil?
    @line = @painter.draw_line(e[0], e[1], RED)
  end

  def build_struct
    @painter.clear
    yield

    @mainbar.push(0, "Construindo estrutura de dados...")

    p1 = Point.new(@painter.x1bd, @painter.y1bd)
    p2 = Point.new(@painter.x2bd, @painter.y2bd)
    p3 = Point.new(@painter.x2bd, @painter.y1bd)
    p4 = Point.new(@painter.x1bd, @painter.y2bd)
    @tree = Tree.new(:TRAP, Trapezoid.new(p1, p2, [p4, p2], [p1, p3]))
    @tree.data.draw(@painter, GREY)
    yield
    
    @edge_map = {[p1, p3] => -1, [p1, p3] => -1}
    @map.edges.each_with_index do |e, id|
      @edge_map[[@map.points[e[0]], @map.points[e[1]]]] = 2*id
      @edge_map[[@map.points[e[1]], @map.points[e[0]]]] = 2*id+1
    end

    rand_edges = @map.edges.map {|e| [@map.points[e[0]], @map.points[e[1]]].sort}.shuffle
#    puts rand_edges.inspect
    rand_edges.each do |e|
#      puts "árvore:"
#      puts @tree.inspect
      @line = nil
      redraw_edge(e)
      yield
      traps = follow_segment(e) { yield }

      i = 0
      trap = traps[i]

      if e[0] != trap.data.leftp # creates left trapezoid (A)
        traps[i], pi = Node.new(:TRAP, traps[i].data), traps[i]
        trap = traps[i]
        trap.data.erase
        pi.type, pi.data = :POINT, e[0]
      
        a = Node.new(:TRAP, Trapezoid.new(trap.data.leftp, e[0], trap.data.top, trap.data.bottom))
        a.data.draw(@painter, GREY)
        redraw_edge(e)
        yield

        # updating left neighbors
        a.data.uln = trap.data.uln
        trap.data.uln.data.urn = a unless trap.data.uln.nil?
        a.data.bln = trap.data.bln
        trap.data.bln.data.brn = a unless trap.data.bln.nil?

        pi.left, pi.right = a, trap

        # keeping invariants for the rest
        trap.data.uln = trap.data.bln = a
        trap.data.leftp = e[0]
        trap.data.draw(@painter, BLUE)
        redraw_edge(e)
        yield
      end

      c = Node.new(:TRAP, Trapezoid.new(e[0], nil, nil, e))
      d = Node.new(:TRAP, Trapezoid.new(e[0], nil, e, nil))
      
      while i < traps.size - 1
        trap = traps[i]
        trap, si = Node.new(:TRAP, trap.data), trap
        trap.data.erase
        si.type, si.data = :EDGE, e

        si.left, si.right = c, d

        # updates left neighbors
        ar = area2(e[0], e[1], trap.data.leftp)
        if ar >= 0 and !trap.data.uln.nil?
          c.data.uln = trap.data.uln
          trap.data.uln.data.urn = c
        end
        if ar <= 0 and !trap.data.bln.nil?
          d.data.bln = trap.data.bln
          trap.data.bln.data.brn = d
        end

        # updates right neighbors
        ar = area2(e[0], e[1], trap.data.rightp)
        if ar >= 0 and !trap.data.urn.nil?
          c.data.urn = trap.data.urn
          trap.data.urn.data.uln = c
        end
        if ar <= 0 and !trap.data.brn.nil?
          d.data.brn = trap.data.brn
          trap.data.brn.data.bln = d
        end

        lines = @painter.draw_triang(e[0], e[1], trap.data.rightp, YELLOW)
        yield
        lines.each { |l| l.destroy }
        if left(e[0], e[1], trap.data.rightp)
          # closes the upper trapezoid (C)
          c.data.rightp = trap.data.rightp
          c.data.top = trap.data.top
          c1, c = c, Node.new(:TRAP, Trapezoid.new(trap.data.rightp, nil, nil, e))
          c1.data.brn, c.data.bln = c, c1

          c1.data.draw(@painter, GREY)
          redraw_edge(e)
          yield
        else
          # closes D
          d.data.rightp = trap.data.rightp
          d.data.bottom = trap.data.bottom
          d1, d = d, Node.new(:TRAP, Trapezoid.new(trap.data.rightp, nil, e, nil))
          d1.data.urn, d.data.uln = d, d1

          d1.data.draw(@painter, GREY)
          redraw_edge(e)
          yield
        end

        i = i+1
      end

      trap = traps.last
      trap.data.erase
      si = Node.new(:EDGE, e)
      si.left, si.right = c, d

      c.data.rightp = e[1]
      c.data.top = trap.data.top
      c.data.draw(@painter, GREY)
      redraw_edge(e)
      yield

      d.data.rightp = e[1]
      d.data.bottom = trap.data.bottom
      d.data.draw(@painter, GREY)
      redraw_edge(e)
      yield

      # updating left neighbors
      ar = area2(e[0], e[1], trap.data.leftp)
      if ar >= 0 and !trap.data.uln.nil?
        c.data.uln = trap.data.uln
        trap.data.uln.data.urn = c
      end
      if ar <= 0 and !trap.data.bln.nil?
        d.data.bln = trap.data.bln
        trap.data.bln.data.brn = d
      end

      # creates right trapezoid (B)
      b = Node.new(:TRAP, Trapezoid.new(e[1], trap.data.rightp, trap.data.top, trap.data.bottom))
      b.data.draw(@painter, GREY)
      redraw_edge(e)
      yield

      trap, qi = Node.new(:TRAP, trap.data), trap
      qi.type, qi.data = :POINT, e[1]
      qi.left, qi.right = si, b

      c.data.urn = d.data.brn = b
      b.data.uln, b.data.bln = c, d

      # updating right neighbors
      b.data.urn = trap.data.urn
      trap.data.urn.data.uln = b unless trap.data.urn.nil?
      b.data.brn = trap.data.brn
      trap.data.brn.data.bln = b unless trap.data.brn.nil?

      @line.destroy
    end

    @map.paint(@painter)
  end

  def query(point)
    @mainbar.push(0, "Buscando ponto #{point}...")
    pred = @painter.draw_point(point, RED)
    @tree.find_point(point, self) { yield }
    pred.destroy
  end
end
