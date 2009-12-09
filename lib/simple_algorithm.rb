require 'rubygems'
require 'rbtree'
require 'lib/structures'
require 'lib/painter'

class Simple 

  INF = 1<<30

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

  def initialize(map)
    @map = map
  end

  def get_y(point1, point2, x) # TODO: conferir
    v1 = x - point1.x
    v2 = point2.x - x

    return point1.y if v1 + v2 == 0

    (point1.y * v2 + point2.y & v1) / (v1 + v2)
  end

  def build_grid(painter)
    events = @map.points.map{ |p| p.x } # O(n)
    events << INF
    events.sort! # O(n*lg(n))
    events.uniq! # O(n) # acho que comentando isso ja funciona pra arestas verticais

    ordered_edges = []
    edges = @map.edges.map {|e| [@map.points[e[0]],@map.points[e[1]]] }
    edges.each_with_index { |e,i| ordered_edges << Element.new(e,i) }
    ordered_edges.sort! do |a,b|
      a.edge[0] <=> b.edge[0]
    end
    index = 0;
    ordered_edges.each{ |e| puts e }

    linesweep = RBTree.new

    grid = RBTree.new

    Thread.new do
      events.each do |x|
        #@map.paint(painter)

        painter.draw_line(Point.new(x,-10), Point.new(x,20), YELLOW)
        sleep 1

        #linesweep.keys.each { |e| STDERR.puts "L "+e.to_s; painter.draw_line(e.edge[0],e.edge[1],GREY); sleep 1 }
        order = linesweep.keys.sort do |a,b| # ordenado faixa
          ya = get_y(a.edge[0],a.edge[1],x)
          yb = get_y(b.edge[0],b.edge[1],x)
          ya <=> yb
        end
        grid[x] = order # adicionado faixa que limita superiormente por 'x'
        order.each { |e| STDERR.puts "O "+e.to_s; painter.draw_line(e.edge[0],e.edge[1],LIME); sleep 1 }

        while index < ordered_edges.size # adicionando arestas entrando na faixa
          break if ordered_edges[index].edge[0].x > x
          STDERR.puts "I "+ordered_edges[index].to_s
          linesweep[ordered_edges[index]] = 1 # o valor 1 eh apenas para efetuar a insercao
          index += 1
        end

        while linesweep.first != nil and linesweep.first[0].edge[1].x <= x # removendo as aresta que sairam da faixa
          STDERR.puts "D "+linesweep.first[0].to_s
          linesweep.delete(linesweep.first[0])
        end
      end
    end

  end

  def query(point)

  end

end
