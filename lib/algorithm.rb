#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: rplac basic algorithm class
* Description: abstract class that implements some stuff common
to both algorithms.
* Author: Joel Uchoa, Murilo de Lima
* Date: 2009-12-10
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

class Algorithm
  def initialize(map, painter, statusbar, mainbar)
    @map = map
    @painter = painter
    @statusbar = statusbar
    @mainbar = mainbar

    @memory = 0
    @compar = 0

    @statusbar.push(0, "Consumo de memória: #{@memory} bytes        Número de comparações: #{@compar}")
  end

  def inc_counter(memory, compar)
    @memory += memory
    @compar += compar
    @statusbar.push(0, "Consumo de memória: #{@memory} bytes        Número de comparações: #{@compar}")
  end
end
