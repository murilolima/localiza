#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: rplac open file dialog
* Description: open file dialog class
* Author: Murilo de Lima
* Date: 2009-11-20
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

require 'gtk2'

class OpenFileDialog

  def initialize
    @diag = Gtk::FileChooserDialog.new
    @bt_cancel = @diag.add_button(Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL)
    @bt_cancel.signal_connect('clicked') { @diag.destroy }
    @bt_open = @diag.add_button(Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT)
    @bt_open.signal_connect('clicked') do
      # testing: open normal file, open directory, open nothing
      fname = @diag.filename
      if fname && !File.directory?(fname)
        @callback.call(fname)
        @diag.destroy
      end
    end
  end

  def show(&callback)
    @diag.show
    @callback = callback
  end

end
