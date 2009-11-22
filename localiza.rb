#!/usr/bin/env ruby -w
# -*- coding: utf-8 -*-
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#

=begin
* Name: rplac main file
* Description: programa principal
* Author: Joel Uchoa, Murilo de Lima
* Date: 2009-11-06
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

require 'libglade2'

require 'about'
require 'file_diag'
require 'algorithm'


class LocalizaGlade

  include GetText

  attr :glade
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, 'UTF-8')
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
  end

end


####### methods for GTK stuff #########

def gtk_main_quit(widget)
  Gtk.main_quit
end

def open_diag_about
  AboutDialog.new.show
end

def open_diag_file
  OpenFileDialog.new.show do |fname|
    write_status_bar("open_file", :open_file_st)
    # TODO tratar arquivo
    puts File.new(fname).read.to_s # lembrar de fazer 'ensure f.close'
    $file_ok.val = true
    # fim
    write_status_bar("open_file", :open_file_end)
  end
end

def change_alg(bt_name)
  if $prog.glade[bt_name].active?
    $n_alg.val += 1
  else
    $n_alg.val -= 1
  end
end

def toggle_alg1
  change_alg('check_alg1')
end

def toggle_alg2
  change_alg('check_alg2')
end

def toggle_step
  $pap.val = !$pap.val
end

def change_speed
end

def play_pause
  $started.val = true
end

def stop
  # TODO talvez mudar essas coisas de lugar, pois tambem precisa executá-las quando o algoritmo chega ao final por si só
  $prog.glade['bt_play_pause'].active = false
  $started.val = false
  $last_part.val = false
end

def step
end

def next
  $started.val = true
  $last_part.val = true
end


####### methods for our control #########

# flags controlling buttons
class BtFlag
  # note that the value can have any type (we use boolean or integer)
  attr_reader :val
  
  def initialize(new_val)
    @val = new_val
  end

  def val=(new_val)
    @val = new_val
    update_bts
  end
end

$file_ok = BtFlag.new(false)
$started = BtFlag.new(false)
$n_alg = BtFlag.new(0)
$pap = BtFlag.new(false)
$last_part = BtFlag.new(false)

def update_bts
  $prog.glade['check_alg1'].sensitive =
    $prog.glade['check_alg2'].sensitive = !$started.val
  $prog.glade['check_step'].sensitive = !$started.val && ($n_alg.val <= 1)
  $prog.glade['label_speed'].sensitive =
    $prog.glade['speed_bar'].sensitive = !$pap.val || $n_alg.val == 2
  $prog.glade['bt_play_pause'].sensitive = $file_ok.val && ($n_alg.val > 0) && !($started.val && $pap.val)
  $prog.glade['bt_stop'].sensitive = $started.val
  $prog.glade['bt_step'].sensitive = $started.val && ($n_alg.val == 1) && $pap.val
  $prog.glade['bt_ff'].sensitive = $file_ok.val && ($n_alg.val > 0) && !$last_part.val
end    

# controlling status bar
$status_msg = {
  :open_file_st => "Lendo arquivo...",
  :open_file_end => "Arquivo lido com sucesso",
  :open_file_err => "Erro lendo arquivo"
}

def write_status_bar(ctx, msg_id)
  sbar = $prog.glade['main_statusbar']
  sbar.push(sbar.get_context_id(ctx), $status_msg[msg_id])
end

# Main program
if __FILE__ == $0
  PROG_PATH = 'localiza.glade'
  PROG_NAME = 'POINT_LOCATION'
  $prog = LocalizaGlade.new(PROG_PATH, nil, PROG_NAME)
  w = $prog.glade['main_window']
  w.signal_connect('destroy') { |w| gtk_main_quit(w) }
  w.show_all

  update_bts

  $alg1 = Algorithm.new($prog.glade['draw_area1'], $prog.glade['statusbar_alg1'])
  $alg2 = Algorithm.new($prog.glade['draw_area2'], $prog.glade['statusbar_alg2'])
  
  Gtk.main
end
