#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: rplac file-reading tool
* Description: reads a file and builds the basic data structures.
* Author: Joel Uchoa
* Date: 2009-12-09
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

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


