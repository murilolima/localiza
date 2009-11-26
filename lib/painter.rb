#!/usr/bin/env ruby -w
# -*- coding: utf-8 -*-
=begin
* Name: rplac painter class
* Description: this class turn easy draw in Gtk::Drawing_area
* Author: Joel Uchoa
* Date: 2009-11-25
* License:

rplac 0.1, Copyright (C) 2009  Joel Uchoa, Murilo de Lima
rplac comes with ABSOLUTELY NO WARRANTY; for detais see `gpl-2.0.txt'.
This is free software, and you are welcome to redistribute it
under certain conditions; see `gpl-2.0.txt' for details.

=end

require 'gtk2'

AQUA	= CYAN = Gdk::Color.new(0x0000,0xFFFF,0xFFFF)
GREY	= Gdk::Color.new(0x8800,0x8800,0x8800)
NAVY	= Gdk::Color.new(0x0000,0x0000,0x8800)
SILVER  = Gdk::Color.new(0xCC00,0xCC00,0xCC00)
BLACK	= Gdk::Color.new(0x0000,0x0000,0000)
GREEN	= Gdk::Color.new(0x0000,0x8800,0000)
OLIVE	= Gdk::Color.new(0x8800,0x8800,0x0000)
TEAL	= Gdk::Color.new(0x0000,0x8800,0x8800)
BLUE	= Gdk::Color.new(0x0000,0x0000,0xFFFF)
LIME	= Gdk::Color.new(0x0000,0xFFFF,0x0000)
PURPLE  = Gdk::Color.new(0x8800,0x0000,0x8800)
WHITE	= Gdk::Color.new(0xFFFF,0xFFFF,0xFFFF)
FUCHSIA = MAGENTA = Gdk::Color.new(0xFFFF,0x0000,0xFFFF)
MAROON  = Gdk::Color.new(0x8800,0x0000,0x0000)
RED	= Gdk::Color.new(0xFFFF,0x0000,0x0000)
YELLOW= Gdk::Color.new(0xFFFF,0xFFFF,0x0000)


class Painter
  attr_reader :drawing_area

  BORDER = 10
  POINT_RADIO = 5

  def initialize(points, drawing_area)
    @drawing_area = drawing_area
    @style = @drawing_area.style.black_gc

    # getting data for to calc scale and translate params
    @x_min = @y_min = Float::MAX
    @x_max = @y_max = Float::MIN

    points.each do |p| 
      @x_min = [@x_min, p.x].min
      @x_max = [@x_max, p.x].max
      @y_min = [@y_min, p.y].min
      @y_max = [@y_max, p.y].max
    end

    x_diff = @x_max - @x_min + 1
    y_diff = @y_max - @y_min + 1
    width  = @drawing_area.allocation.width - 2 * BORDER
    height = @drawing_area.allocation.height - 2 * BORDER

    @scale = [width/x_diff, height/y_diff].min # scale to fit points in drawing_area

    x_center = (@x_min + @x_max) * 0.5
    y_center = (@y_min + @y_max) * 0.5

    # offset to position the scaled points
    @x_offset = width * 0.5 - x_center * @scale + BORDER
    @y_offset = height * 0.5 - y_center * @scale + BORDER

  end

  def scale_and_translate(point)
    ((point * @scale) + Point.new(@x_offset, @y_offset))
  end

  def clear_drawing_area
    @drawing_area.window.clear
  end

  def set_background_color(color)
    @style.rgb_bg_color = color
  end

  def set_foreground_color(color)
    @style.rgb_fg_color = color
  end

  def draw_circle(center, radio, color)
    set_foreground_color(color)
    center = scale_and_translate(center)
    @drawing_area.window.draw_arc(@style, true, center.x-radio, center.y-radio, 2*radio, 2*radio, 0, 64*360)
  end

  def draw_point(point, color)
    draw_circle(point, POINT_RADIO, color)
  end

  def draw_line(point1, point2, color)
    set_foreground_color(color)
    point1 = scale_and_translate(point1)
    point2 = scale_and_translate(point2)
    @drawing_area.window.draw_line(@style, point1.x, point1.y, point2.x, point2.y)
  end

end
