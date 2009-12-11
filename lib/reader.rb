# -*- coding: utf-8 -*-
require 'lib/structures'

class Reader

  private
  def initialize(file_name)
    file = File.open(file_name)
    raise unless file
    @data = file.read.to_s.split
    @token_index = 0
  ensure
    !file || file.close
  end

  public
  def get_next_token
    ret = @data[@token_index]
    @token_index += 1
    ret
  end

  def self.read(fname)
    # TODO levantar excecao se entrada nao for válida
    reader = Reader.new(fname)
    map = Map.new
    queries = Array.new

    n_points = reader.get_next_token.to_i
    n_edges = reader.get_next_token.to_i

    n_points.times do
      x = reader.get_next_token.to_i
      y = reader.get_next_token.to_i
      map.add_point(Point.new(x,y))
    end

    n_edges.times do
      point1_idx = reader.get_next_token.to_i
      point2_idx = reader.get_next_token.to_i
      map.add_edge(point1_idx, point2_idx)
    end

    n_queries = reader.get_next_token.to_i

    n_queries.times do
      x = reader.get_next_token.to_i
      y = reader.get_next_token.to_i
      queries << Point.new(x,y) 
    end

    [map, queries]
  end

end


