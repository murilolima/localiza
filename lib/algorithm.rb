# -*- coding: utf-8 -*-
class Algorithm
  def initialize(map, painter, statusbar, mainbar)
    @map = map
    @painter = painter
    @statusbar = statusbar
    @mainbar = mainbar

    @memory = 0
    @compar = 0

    @statusbar.push(0, "Consumo de memória: #{@memory} bytes        Número de comparações: #{@compar}")
  end

  def inc_counter(memory, compar)
    @memory += memory
    @compar += compar
    @statusbar.push(0, "Consumo de memória: #{@memory} bytes        Número de comparações: #{@compar}")
  end

  def area2(p1, p2, p3)
    v1 = p1.x * p2.y + p2.x * p3.y + p3.x * p1.y
    v2 = p1.y * p2.x + p2.y * p3.x + p3.y * p1.x
    v1 - v2
  end

  def left(p1, p2, p3)
    area2(p1, p2, p3) >= 0
  end

  def lefts(p1, p2, p3)
    area2(p1, p2, p3) > 0
  end

  def right(p1, p2, p3)
    !lefts(p1, p2, p3)
  end

  def rights(p1, p2, p3)
    !left(p1, p2, p3)
  end
end
