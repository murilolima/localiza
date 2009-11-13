#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'

$prog = nil

class LocalizaGlade
  include GetText

  attr :glade
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, 'UTF-8')
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    
  end
  
end

def open_diag_help
  $prog.glade['diag_help'].show_all
end

def open_diag_file
  $prog.glade['diag_file'].show_all
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
