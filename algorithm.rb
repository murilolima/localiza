#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: rplac algorithm abstract class
* Description: this class defines the behavior of an algorithm in the
  program, in an independent way from the algorithm implementation
* Author: Murilo de Lima
* Date: 2009-11-21
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

class Algorithm
  
  def initialize(painter, statusbar)
    @painter = painter

    @memory = 0
    @compar = 0
    
    @statusbar = statusbar
    @statusbar.push(0, "Consumo de memória: #{@memory} bytes        Número de comparações: #{@compar}")
  end

end
