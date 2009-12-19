#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: simple point location algorithm
* Description: simple algorithm, line-sweep based. The data structure
consumes O(n²) space and O(n²) time to be built. A query consumes
O(lg n) time. For a detailed description, see
de Berg et al. Computational geometry, algorithms and applications,
Springer Verlag, 2nd edition, 2000, ch. 6, beginning of section 6.1.
* Author: Joel Uchoa
* Date: 2009-12-09
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

require 'rubygems'
require 'rbtree'
require 'lib/structures'
require 'lib/painter'
require 'lib/algorithm'

class Simple < Algorithm

  class Element
    include Comparable
    attr_accessor :edge, :idx

    def initialize(e, idx)
      if e[0] < e[1] 
        @edge = [e[0],e[1]]
        @idx = 2 * idx
      elsif
        @edge = [e[1], e[0]]
        @idx = 2 * idx + 1
      end
    end

    def <=>(other)
       if @edge[1] != other.edge[1]
        @edge[1] < other.edge[1] ? -1 : 1
       elsif @edge[0] != other.edge[0]
         @edge[0] < other.edge[0] ? -1 : 1
       else
         0
       end
    end

    def to_s
      idx.to_s + " " + @edge[0].to_s + " " + @edge[1].to_s
    end
  end

  def build_struct
    @map.paint(@painter)
    yield

    @mainbar.push(0, "Construindo estrutura de dados... ordenando pontos-eventos")

    events = @map.points.dup # O(n)
    events << Point.new(@painter.plus_inf, @painter.plus_inf)
    events.sort! do |a, b|
      l1 = @painter.draw_line(Point.new(a.x,@painter.minus_inf), Point.new(a.x,@painter.plus_inf), YELLOW)
      p1 = @painter.draw_point(a, RED)
      l2 = @painter.draw_line(Point.new(b.x,@painter.minus_inf), Point.new(b.x,@painter.plus_inf), YELLOW)
      p2 = @painter.draw_point(b, RED)
      yield
      l1.destroy; l2.destroy
      p1.destroy; p2.destroy
      a <=> b
    end

    @mainbar.push(0, "Construindo estrutura de dados... ordenando arestas pela ponta mais à esquerda")

    ordered_edges = []
    edges = @map.edges.map {|e| [@map.points[e[0]],@map.points[e[1]]] }
    edges.each_with_index { |e,i| ordered_edges << Element.new(e,i) }
    ordered_edges.sort! do |a,b|
      e1 = @painter.draw_line(a.edge[0], a.edge[1], LIME)
      e2 = @painter.draw_line(b.edge[0], b.edge[1], LIME)
      yield
      e1.destroy; e2.destroy
      a.edge[0] <=> b.edge[0]
    end
    index = 0;

    @mainbar.push(0, "Construindo estrutura de dados...")

    linesweep = RBTree.new

    @grid = RBTree.new

    last_line = nil
    events.each do |p|
      yell = @painter.draw_line(Point.new(p.x,@painter.minus_inf), Point.new(p.x,@painter.plus_inf), YELLOW)
      redp = @painter.draw_point(p, RED)
      yield

      order = linesweep.keys.sort do |a,b| # ordenado faixa
        e1 = @painter.draw_line(a.edge[0], a.edge[1], BLUE)
        e2 = @painter.draw_line(b.edge[0], b.edge[1], BLUE)
        yield
        e1.destroy; e2.destroy
        if (right(a.edge[0], a.edge[1], b.edge[0]) and right(a.edge[0], a.edge[1], b.edge[1])) or
          (left(b.edge[0], b.edge[1], a.edge[0]) and left(b.edge[0], b.edge[1], a.edge[1]))
          1
        else
          -1
        end
      end
      @grid[p] = order # adicionado faixa que limita superiormente por 'x'

      while index < ordered_edges.size # adicionando arestas entrando na faixa
        e = ordered_edges[index]
        break if e.edge[0] > p
        linesweep[e] = @painter.draw_line(e.edge[0],e.edge[1], LIME)
        yield
        index += 1
      end

      while linesweep.first != nil and (e = linesweep.first[0]).edge[1] <= p # removendo as aresta que sairam da faixa
        linesweep.first[1].destroy
        linesweep.delete(e)
        yield
      end

      last_line.destroy unless last_line.nil?
      last_line = yell
      redp.destroy
    end
  end

  def query(point)
    @mainbar.push(0, "Buscando ponto #{point}...")
    pred = @painter.draw_point(point, RED)
    yield

    pivot, stripe = @grid.lower_bound(point) # TODO pintar arestas na busca (criar classe)
    
    if pivot == point
      on_the_point(point)
      yield
    elsif stripe.size == 0
      outside(point)
      yield
      # ponto estah fora de todas as regioes
    else
      lower = 0; upper = (stripe.size) -1

      x1 = stripe.first.edge[0]
      y1 = stripe.first.edge[1]
      l1 = @painter.draw_line(x1, y1, LIME)
      yield
      l1.destroy
      x2 = stripe.last.edge[0]
      y2 = stripe.last.edge[1]
      l2 = @painter.draw_line(x2, y2, LIME)
      l2.destroy
      yield
      if rights(x1, y1, point) or lefts(x2, y2, point)
        outside(point)
        yield
      else
        while lower < upper -1
          mid = (lower + upper) / 2
          e = stripe[mid].edge
          edge = @painter.draw_line(e[0],e[1], LIME)
          yield
          edge.destroy
          if right(e[0], e[1], point)
            upper = mid
          else
            lower = mid
          end
        end

        if area2(stripe[lower].edge[0], stripe[lower].edge[1], point) == 0
          on_the_edge(point, stripe[lower].edge)
          yield
        elsif area2(stripe[upper].edge[0], stripe[upper].edge[1], point) == 0
          on_the_edge(point, stripe[upper].edge)
          yield
        else
          face_points = @map.structure.get_face_of_edge(stripe[lower].idx).map { |e| e.origin.point }
          poly = @painter.draw_polygon(face_points, LIME, GREY)
          pred.destroy
          pred = @painter.draw_point(point, RED)
          @mainbar.push(0, "--->>> Ponto localizado!")
          yield
          poly.destroy
        end
      end
    end
    pred.destroy
  end

end
