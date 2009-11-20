#!/usr/bin/env ruby -w
# -*- coding: utf-8 -*-
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#

=begin
* Nome: rplac main file
* Descrição: programa principal
* Autor: Joel Uchoa, Murilo de Lima
* Data: 2009-11-06
* Licença:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

require 'libglade2'

require 'about'
require 'open_file'

$prog = nil

class LocalizaGlade
  include GetText

  attr :glade
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, 'UTF-8')
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    
  end
  
end

def close_diag_about
  Gtk.main_quit
end

def open_diag_about
  AboutDialog.new.show
end

def open_diag_file
  OpenFileDialog.new.show do |file_string|
    # TODO tratar arquivo
    puts file_string
  end
end

def gtk_main_quit(widget)
  Gtk.main_quit
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = 'localiza.glade'
  PROG_NAME = 'POINT_LOCATION'
  $prog = LocalizaGlade.new(PROG_PATH, nil, PROG_NAME)
  w = $prog.glade['main_window']
  w.signal_connect('destroy') { |w| gtk_main_quit(w) }
  w.show_all
  Gtk.main
end
