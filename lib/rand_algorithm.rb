# -*- coding: utf-8 -*-
require 'lib/algorithm'
require 'lib/painter'
require 'lib/structures'

class Node
  attr_accessor :type, :data, :right, :left, :parents

  def initialize(type, data)
    @type = type
    @data = data

    @right = @left = nil
    @parents = []
  end

  def find_trapezoid(e)
    if @type == :TRAP
      self
    elsif @type == :EDGE
      line = @painter.draw_line(@data[0], @data[1], YELLOW)
      yield
      line.destroy
      v = area2(@data[0], @data[1], e[0])
      if v > 0 or (v == 0 and (@data[1] - @data[0]).angle > (e[1] - e[0]).angle)
        @left.find_trapezoid(e)
      else
        @right.find_trapezoid(e)
      end
    else
      line = @painter.draw_line(Point.new(@data.x, @painter.minus_inf), Point.new(@data.x, @painter.plus_inf), YELLOW)
      yield
      line.destroy

      if @data.x < e[0].x
        @left.find_trapezoid(e)
      else
        @right.find_trapezoid(e)
      end
    end
  end

  def find_point(p)
    if @type == :TRAP
      idx = @edge_map[@data.bottom]
      if (idx == -1)
        puts "FORA!"
      else
        face_points = @map.structure.get_face_of_edge(idx).map { |e| e.origin.point }
        poly = @painter.draw_polygon(face_points, LIME, GREY)
        pred = @painter.draw_point(p, RED)
        yield
        poly.destroy
        pred.destroy
      end
    elsif @type == :EDGE
      line = @painter.draw_line(@data[0], @data[1], LIME)
      yield
      line.destroy

      v = area2(@data[0], @data[1], p)
      if v > 0
        @left.find_trapezoid(e)
      elsif v < 0
        @right.find_trapezoid(e)
      else
        puts "caiu na aresta"
      end
    else
      line = @painter.draw_line(Point.new(@data.x, @painter.minus_inf), Point.new(@data.x, @painter.plus_inf), YELLOW)
      yield
      line.destroy

      if @data > p
        @left.find_trapezoid(e)
      elsif @data < p
        @right.find_trapezoid(e)
      else
        puts "caiu no ponto"
      end
    end
  end
end

class Trapezoid
  attr_accessor :leftp, :rightp, :bottom, :top
  attr_accessor :uln, :urn, :bln, :brn # isso tem que ser ponteiro pra nó
  def initialize(leftp, rightp, bottom, top)
    @leftp, @rightp, @bottom, @top = leftp, rightp, bottom, top
    @uln = @urn = @bln = @brn = nil
  end
end

class Tree < Node
end

class Randomized < Algorithm

  def follow_segment(e)
    traps = [@tree.find_trapezoid(e)]

    while e[1].x > (lt = traps.last).data.rightp.x
      pt = @painter.draw_point(lt.data.rightp, RED)
      yield
      pt.destroy
      if right(e[0], e[1], lt.data.rightp)
        traps << lt.data.brn
      else
        traps << lt.data.urn
      end
    end

    traps
  end

  def build_struct
    @map.paint(@painter)
    yield

    @mainbar.push(0, "Construindo estrutura de dados... bagunçando arestas")

    p1 = Point.new(@painter.x1bd, @painter.y1bd)
    p2 = Point.new(@painter.x2bd, @painter.y2bd)
    p3 = Point.new(@painter.x2bd, @painter.y1bd)
    p4 = Point.new(@painter.x1bd, @painter.y2bd)
    @tree = Tree.new(:TRAP, Trapezoid.new(p1, p2, [p1, p3], [p4, p2]))
    @edge_map = {[p1, p3] => -1, [p1, p3] => -1}
    @map.edges.each_with_index do |e, id|
      line = @painter.draw_line(@map.points[e[0]], @map.points[e[1]], LIME)
      yield
      line.destroy
      @edge_map[[@map.points[e[0]], @map.points[e[1]]]] = 2*id
      @edge_map[[@map.points[e[1]], @map.points[e[0]]]] = 2*id+1
    end

    @mainbar.push(0, "Construindo estrutura de dados...")

    @map.edges.map {|e| [@map.points[e[0]], @map.points[e[1]]].sort}.shuffle.each do |e|
      line = @painter.draw_line(e[0], e[1], LIME)
      yield
      traps = follow_segment(e)

      i = 0
      trap = traps[i]
      pi = Node.new(:POINT, e[0])
      a = Node.new(:TRAP, Trapezoid.new(trap.data.leftp, e[0], trap.data.top, trap.data.bottom))
      a.parents = [pi]
      pi.left = a
      pi.right = trap
      pi.parents = trap.parents
      trap.parents.each do |parent|
        if parent.left.object_id == trap.object_id
          parent.left = pi
        else
          parent.right = pi
        end
      end
      trap.parents = [pi]

      c = Node.new(:TRAP, Trapezoid.new(e[0], nil, trap.data.top, e))
      d = Node.new(:TRAP, Trapezoid.new(e[0], nil, e, trap.data.bottom))
      c.parents = []
      d.parents = []
      c.data.uln = d.data.urn = a

      a.data.uln = trap.data.uln
      a.data.bln = trap.data.bln
      a.data.urn = c
      a.data.brn = d

      while i < traps.size and e[1].x > (trap = traps[i]).data.rightp.x
        si = Node.new(:EDGE, e)
        si.parents = trap.parents
        trap.parents.each do |parent|
          if parent.left.object_id == trap.object_id
            parent.left = si
          else
            parent.right = si
          end
        end

        c.parents << si
        d.parents << si
        si.left = c
        si.right = d

        if left(e[0], e[1], trap.data.rightp)
          # fecha o trapézio de cima (C)
          c.data.rightp = trap.data.rightp
          c1 = c
          c = Node.new(:TRAP, Trapezoid.new(trap.data.rightp, nil, trap.data.top, e))
          c.parents = []
          c1.data.urn = c
          c.data.uln = c1
        else
          # fecha o D
          d.data.rightp = trap.data.rightp
          d1 = d
          d = Node.new(:TRAP, Trapezoid.new(trap.data.rightp, nil, e, trap.data.bottom))
          d.parents = []
          d1.data.brn = d
          d.data.bln = d1
        end

        i = i+1
      end

      trap = traps.last
      si = Node.new(:EDGE, e)

      c.parents << si
      d.parents << si
      si.left = c
      si.right = d

      c.data.rightp = e[1]
      d.data.rightp = e[1]

      b = Node.new(:TRAP, Trapezoid.new(e[1], trap.data.rightp, trap.data.top, trap.data.bottom))
      qi = Node.new(:POINT, e[1])
      qi.left = si
      qi.right = b
      qi.parents = trap.parents
      trap.parents.each do |parent|
        if parent.left.object_id == trap.object_id
          parent.left = qi
        else
          parent.right = qi
        end
      end
      b.parents = [qi]

      si.parents = [qi]
      c.data.urn = d.data.brn = b
      b.data.uln = c
      b.data.bln = d
      b.data.urn = trap.data.urn
      b.data.brn = trap.data.brn

      line.destroy
    end
  end

  def query(point)
    pred = @painter.draw_point(p, RED)
    # TODO atualizar barra de status, fazer visualização e colocar yield's
    @tree.find_point(point)
    pred.destroy
  end

end
