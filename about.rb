#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: rplac about dialog
* Description: about dialog class
* Author: Murilo de Lima
* Date: 2009-11-20
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

require 'gtk2'

class AboutDialog

  def initialize
    @diag = Gtk::AboutDialog.new

    @diag.signal_connect('response') do |w, resp_id|
      w.destroy
    end
    
    @diag.program_name = 'rplac'
    @diag.version = '0.1'
    @diag.copyright = 'Copyright © 2009 Joel Uchoa, Murilo de Lima'
    @diag.comments = 'Ruby Point Location Algorithm Comparator'
    @diag.website = 'http://github.com/murilolima/localiza/'
    @diag.logo = Gdk::Pixbuf.new('mapa_brasil.png', 86, 80)
    @diag.license = "Este programa é um software livre; você pode redistribuí-lo e/ou modificá-lo
sob os termos da GNU General Public License (GPL) como publicada pela
Free Software Foundation; tanto na versão 2 da Licença ou (caso queira)
qualquer versão posterior.

O rplac é distribuído na esperança de que será útil,
mas SEM NENHUMA GARANTIA; até mesmo sem a garantia implícita
de COMERCIALIZAÇÃO ou de ADAPTAÇÃO A UM PROPÓSITO
PARTICULAR. Veja a GNU General Public License (GPL) para mais detalhes.

Você deve ter recebido uma cópia da GNU General Public License (GPL)
junto com este programa; se não, escreva para a Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA."
  end

  def show
    @diag.show
  end

end
