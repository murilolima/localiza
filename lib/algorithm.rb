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
  attr_reader :map, :painter, :mainbar
  attr_accessor :delay
  
  def initialize(map, painter, statusbar, mainbar, mainwindow)
    @map = map
    @painter = painter
    @statusbar = statusbar
    @mainbar = mainbar
    @mainwindow = mainwindow

    @memory = 0
    @compar = 0

    @statusbar.push(0, "Consumo de memória: #{@memory} bytes        Número de comparações: #{@compar}")
  end

  def inc_counter(memory, compar)
    @memory += memory
    @compar += compar
    @statusbar.push(0, "Consumo de memória: #{@memory} bytes        Número de comparações: #{@compar}")
  end

  def build_struct # to be inherited
  end

  def query(point) # to be inherited
  end

  def outside(p)
    message("--->>> O ponto #{p} está na face externa")
  end

  def on_the_point(p)
    message("--->>> O ponto #{p} é um ponto da entrada")
  end

  def on_the_edge(p, e)
    message("--->>> O ponto #{p} está sobre a aresta #{e.inspect}")
  end

  private
  def message(msg)
#    puts msg
    @mainbar.push(0, msg)
    # TODO dando erro com thread
#    dialog = Gtk::MessageDialog.new(@mainwindow,
#                                    Gtk::Dialog::DESTROY_WITH_PARENT, # TODO ver se mudando aqui dá certo
#                                    Gtk::MessageDialog::INFO,
#                                    Gtk::MessageDialog::BUTTONS_CLOSE,
#                                    msg)
#    dialog.run
#    dialog.destroy
  end
end
