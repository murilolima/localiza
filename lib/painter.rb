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

require 'gnomecanvas2'
require 'lib/structures'

AQUA	= CYAN = '#00FFFF'
GREY	= '#808080'
NAVY	= '#000080'
SILVER  = '#C0C0C0'
BLACK	= '#000000'
GREEN	= '#008000'
OLIVE	= '#808000'
TEAL	= '#008080'
BLUE	= '#0000FF'
LIME	= '#00FF00'
PURPLE  = '#800080'
WHITE	= '#FFFFFF'
FUCHSIA = MAGENTA = '#FF00FF'
MAROON  = '#800000'
RED	= '#FF0000'
YELLOW  = '#FFFF00'


class Painter
  attr_reader :wigth, :height, :minus_inf, :plus_inf, :x1bd, :x2bd, :y1bd, :y2bd

  BORDER = 10
  POINT_RADIO = 3

  def initialize(points, canvas)
    @canvas = canvas
    @root = nil
    @width  = canvas.width
    @height = canvas.height

    # getting data for to calc scale and translate params
    @x_min = @x_max = points[0].x
    @y_min = @y_max = points[0].y

    points.each do |p|
      @x_min = [@x_min, p.x].min
      @x_max = [@x_max, p.x].max
      @y_min = [@y_min, p.y].min
      @y_max = [@y_max, p.y].max
    end

    x_diff = @x_max - @x_min + 1
    y_diff = @y_max - @y_min + 1
    w = @width - 2 * BORDER
    h = @height - 2 * BORDER

    @scale = [w/x_diff, h/y_diff].min # scale to fit points in drawing_area

    x_center = (@x_min + @x_max) * 0.5
    y_center = (@y_min + @y_max) * 0.5

    # offset to position the scaled points
    @x_offset = w * 0.5 - x_center * @scale + BORDER
    @y_offset = h * 0.5 - y_center * @scale + BORDER

    @minus_inf = @x_min - BORDER
    @plus_inf = [@x_max, @y_max].max + BORDER

    @x1bd = @x_min - BORDER
    @x2bd = @x_max + BORDER
    @y1bd = @y_min - BORDER
    @y2bd = @y_max + BORDER

    clear
  end

  def scale_and_translate(point)
    p = ((point * @scale) + Point.new(@x_offset, @y_offset))
    Point.new(p.x, @height - BORDER - p.y) # convert the origin for left-botton
  end

  def clear
    @root.destroy unless @root.nil?
    @root = Gnome::CanvasGroup.new(@canvas.root)
    
    Gnome::CanvasRect.new(@root, 
                     :x1 => 0, :y1 => 0,
                      :x2 => @width, :y2 => @height,
                     :fill_color => BLACK,
                     :width_units => 1.0)
  end

  def draw_circle(center, radio, color)
    center = scale_and_translate(center) - Point.new(radio,radio)
    Gnome::CanvasEllipse.new(@root,
                            :x1 => center.x, :y1 => center.y,
                            :x2 => center.x+2*radio, :y2 => center.y+2*radio,
                            :fill_color => color,
                            :width_units => 1.0)

  end

  def draw_point(point, color)
    draw_circle(point, POINT_RADIO, color)
  end

  def draw_line(point1, point2, color)
    point1 = scale_and_translate(point1)
    point2 = scale_and_translate(point2)
    Gnome::CanvasLine.new(@root,
                         :points => [[point1.x,point1.y], [point2.x, point2.y]],
                         :fill_color => color,
                         :width_units => 1.0)
  end

  def draw_polygon(points, edges_color, fill_color = BLACK, points_color = WHITE, draw_points = false)
    points = points.map { |p| scale_and_translate(p) } 
    ps = points.map { |p| [p.x,p.y] } 
    Gnome::CanvasPolygon.new(@root,
                             :points => ps,
                             :fill_color => fill_color,
                             :outline_color => edges_color,
                             :width_units => 1.0)
    #points.each { |p| draw_point(p, points_color) } if draw_points
  end

end
