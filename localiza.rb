#!/usr/bin/ruby -w
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
require 'gnomecanvas2'

require 'about'
require 'file_diag'
require 'algorithm'

# Joel ---------------------- start
require 'lib/structures'
require 'lib/painter'
require 'lib/reader'
require 'lib/simple_algorithm'
# Joel ---------------------- end

class LocalizaGlade

  include GetText

  attr :glade
  attr_accessor :canvas

  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, 'UTF-8')
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}

    w = @glade['main_window']
    w.signal_connect('destroy') { |w| gtk_main_quit(w) }
    w.show_all
  end

  def gtk_main_quit(widget)
    Gtk.main_quit
  end

  def change_drawing_widget
    drawing_area = @glade['draw_area1']
    parent = drawing_area.parent
    
    width = drawing_area.allocation.width
    height = drawing_area.allocation.height

    @canvas = Gnome::Canvas.new(true)
    @canvas.set_size_request(width,height)
    @canvas.set_scroll_region(0,0,width,height)
    Gnome::CanvasRect.new(@canvas.root, 
                     :x1 => 0, :y1 => 0,
                     :x2 => width, :y2 => height,
                     :fill_color => BLACK,
                     :width_units => 1.0)

    parent.remove(drawing_area)
    parent.add(@canvas)

    bar = @glade['statusbar_alg1']
    parent.remove(bar)
    parent.add(bar)

    parent.show_all
  end

end


####### methods for GTK stuff #########


def open_diag_about
  AboutDialog.new.show
end

def open_diag_file
  OpenFileDialog.new.show do |fname|

    # Joel ---------------------- start
    $map, $queries = Reader.read(fname)

    $painter1 = Painter.new($map.points + $queries, $prog.canvas)

    $map.paint($painter1)
    simple = Simple.new($map)
    simple.build_grid($painter1)
    # Joel ---------------------- end

    $file_ok.val = true
    # fim
    write_status_bar("open_file", :open_file_end)
  end
end

def change_algorithm
  $row_alg.val = $prog.glade['combobox_alg'].active
end

def toggle_step
  $pap.val = !$pap.val
end

def change_speed
  update_delay
end

def play_pause
  bt_active = $prog.glade['bt_play_pause'].active?
  if $started.val
    if bt_active # continuing
      update_delay
      $thread.wakeup
    else # pausing
      $delay = nil
    end
  else
    if bt_active # this is necessary because finish fires play_pause
      $started.val = true
      update_delay
      start_it_all
    end
  end
end

def stop
  finish
  Thread.kill($thread)
end

def step
  $mutex_pap.synchronize do
    $cv_pap.signal
  end
end

def next
  $last_part.val = true

  $mutex_jump.synchronize do
    $jump = true
  end

  $prog.glade['bt_play_pause'].active = false # pauses if necessary; TODO só funciona se já tiver iniciado

  #unlocks the last step, if necessary
  $mutex_pap.synchronize do
    $cv_pap.signal
  end

  unless $started.val
    $started.val = true
    $delay = nil # say pause again; TODO muito feio!
    start_it_all
  end
end


####### algorithm thread control #########
def update_delay
  # We have a linear funcion for the FPS speed
  #   with points (0, 1/5) - 5 seconds of delay -
  #   and (100, 10) - 3x slower than a cartoon
  # the delay is the inverse of that
  speed = $prog.glade['speed_bar'].value
  $delay = 1.0/(0.098*speed + 0.2) # TODO generalizar pra não precisar recalcular na mão
end

# TODO renomear estes métodos e colocar em outros arquivos
def alg1
  # must yield something not nil just before starting the second phase
  5.times do
    puts "Running one step of alg1"
    yield nil
  end
  yield 1
  5.times do
    puts "Running one step of alg1 - second phase"
    yield nil
  end
end

def alg2
  # must yield something not nil just before starting the second phase
  5.times do
    puts "Running one step of alg2"
    yield nil
  end
end

def run_alg(&blk)
  case $row_alg.val
  when 0
    alg1(&blk)
  when 1
    alg2(&blk)
  end
end

def start_it_all
  $thread = Thread.new do
    # TODO tratar passo a passo / fast forward
    run_alg do |stage|
      unless stage.nil? # second stage starts now
        $last_part.val = true
        $mutex_jump.synchronize do # stop jumping
          $jump = false
        end
      end

      unless $jump
        if $pap.val
          $mutex_pap.synchronize do
            $cv_pap.wait($mutex_pap)
          end
        else
          if $delay.nil?
            sleep
          else
            sleep $delay
          end
        end
      end
    end
    finish
  end
end

def finish
  $started.val = false
  $last_part.val = false
  $jump = false # just for certifying
  $prog.glade['bt_play_pause'].active = false
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
$row_alg = BtFlag.new(-1)
$pap = BtFlag.new(false)
$last_part = BtFlag.new(false)

def update_bts
  $prog.glade['label_combo'].sensitive = $prog.glade['combobox_alg'].sensitive = !$started.val
  $prog.glade['check_step'].sensitive = !$started.val
  $prog.glade['label_speed'].sensitive = $prog.glade['speed_bar'].sensitive = !$pap.val
  $prog.glade['bt_play_pause'].sensitive = $file_ok.val && ($row_alg.val != -1) && !($started.val && $pap.val)
  $prog.glade['bt_stop'].sensitive = $started.val
  $prog.glade['bt_step'].sensitive = $started.val && $pap.val
  $prog.glade['bt_ff'].sensitive = $file_ok.val && ($row_alg.val != -1) && !$last_part.val
end    

# controlling status bar
$status_msg = {
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

  update_bts

  $mutex_pap = Mutex.new
  $cv_pap = ConditionVariable.new
  $mutex_jump = Mutex.new
  $jump = false


  $prog.change_drawing_widget

  $alg = Algorithm.new($prog.canvas, $prog.glade['statusbar_alg1'])

  Gtk.main
end
